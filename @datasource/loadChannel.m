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
        
        %Append to Data
        vars = fieldnames(newData);
        for j = 1:length(vars)
            ds(i).Data.(vars{j}) = newData.(vars{j});
            
            %Replace ° with def
            ds(i).Data.(vars{j}).Units = ...
                strrep(newData.(vars{j}).Units, '°', 'deg');
        end
    end
end
end