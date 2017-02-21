function loadChannel(ds,channelNames)      
%Force channel names into a cell array
if ~iscell(channelNames)
    channelNames = {channelNames};
end

%Loop over each datasource
for i = 1:length(ds)
    %Find missing channels
    isMissing = ~isfield(ds(i).Data,channelNames);
    
    %Load Missing Channels
    if any(isMissing)
        newData = load(ds(i).MatPath,channelNames{isMissing});
        
        %Check that missing was loaded
        assert(all(isfield(newData, channelNames(isMissing))),...
                'Channel Not Logged');
        
        %Append to datasource Data field
        vars = fieldnames(newData);
        for j = 1:length(vars)
            %Temp variable for newChannel
            newChannel = newData.(vars{j});
            
            %Decompress Channel Value
            newChannel.Value = double(dunzip(newChannel.Value));
            
            %Convert Sample Rate to Time
            SampleRate = newChannel.SampleRate;
            newChannel.Time = 0:SampleRate:SampleRate*(length(newChannel.Value)-1);
                        
            %Append new Channel
            ds(i).Data.(vars{j}) = newChannel;
        end
    end
end
end