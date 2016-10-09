function [entry] = getEntry(dm,varargin)
    %Function to retrieve directory entries from Datamaster
    %StartDate/EndData must be either a datetime or string of the format
    %MM/dd/uuuu/
   
    %Run Search through getIndex
    index = dm.getIndex(varargin{:});
    
    %% Create Enteries from database
    query = sprintf(['SELECT ChannelLog.entryId, ChannelName.channelName FROM ChannelLog ',...
        'INNER JOIN ChannelName ON ChannelName.id = ChannelLog.channelId ',...
        'WHERE ChannelLog.entryId IN (%s)'], strjoin(sprintfc('%d',index),','));
    ChannelLog = dm.mDir.fetch(query);
    
    DetailLog = dm.mDir.fetch(sprintf(['SELECT DetailLog.entryId, DetailName.fieldName, DetailLog.value, DetailLog.unit FROM DetailLog ',...
        'INNER JOIN DetailName ON DetailName.id = DetailLog.fieldId ',...
        'WHERE DetailLog.entryId IN (%s)'], strjoin(sprintfc('%d',index),',')));
    MasterLog = dm.mDir.fetch(sprintf(['SELECT id, OriginHash, FinalHash, Datetime FROM masterDirectory ',...
        'WHERE masterDirectory.id IN (%s)'], strjoin(sprintfc('%d',index),',')));
    
    % Create Enteries from Logs
    entry = repmat(struct('OriginHash', [], 'FinalHash', [], 'channel', [], 'Detail', [], 'Datetime', []),[length(MasterLog),1]);
    for i = 1:length(MasterLog)
        %Add Channels to entry
        entry(i).channel = {ChannelLog{[ChannelLog{:,1}] == index(i),2}}';
        
        %Add from MasterLog
        masterIndex = [[MasterLog{:,1}] == index(i)];
        entry(i).OriginHash = MasterLog{masterIndex,2};
        entry(i).FinalHash = MasterLog{masterIndex,3};
        entry(i).Datetime = MasterLog{masterIndex,4};
        
        %Addd from Details Log
        detailIndex = [[DetailLog{:,1}] == index(i)];
        for j = 1:length(detailIndex)
            if strcmp(DetailLog{j,4},'null')
                entry(i).Detail.(DetailLog{j,2}) = DetailLog{j,3};
            else
                entry(i).Detail.(DetailLog{j,2}).Value = DetailLog{j,3};
                entry(i).Detail.(DetailLog{j,2}).Unit = DetailLog{j,4};
            end
        end
    end
end