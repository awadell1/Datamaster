function [entry] = getEntry(dm,varargin)
    %Function to retrieve directory entries from Datamaster
    %StartDate/EndData must be either a datetime or string of the format
    %MM/dd/uuuu/
    
    %Run Search through getIndex
    index = dm.getIndex(varargin{:});
    
    %% Create Entries from database
    query = sprintf(['SELECT ChannelLog.entryId, group_concat(ChannelName.channelName) FROM ChannelLog ',...
        'INNER JOIN ChannelName ON ChannelName.id = ChannelLog.channelId ',...
        'WHERE ChannelLog.entryId IN (%s) GROUP BY ChannelLog.entryId'],...
        strjoin(sprintfc('%d',index),','));
    ChannelLog = dm.mDir.fetch(query);
    
    MasterLog = dm.mDir.fetch(sprintf(['SELECT id, OriginHash, FinalHash, Datetime FROM masterDirectory ',...
        'WHERE masterDirectory.id IN (%s)'], strjoin(sprintfc('%d',index),',')));
    
    % Create Entries from Logs
    entry = repmat(struct('Index', [], 'OriginHash', [], 'FinalHash', [], 'Channel', [], 'Detail', [], 'Datetime', []),[size(MasterLog,1),1]);
    
    %If no entries were found skip
    if ~isempty(entry)
        %Extract entryId from ChannelLog
        channelEntryId = [ChannelLog{:,1}];
        
        %Preallocate MasterLogIndex for locating entries
        MasterLogIndex = [MasterLog{:,1}];
        for i = 1:size(MasterLog, 1)
            %Add Channels to entry
            matchIndex = channelEntryId == index(i);    %Find Record in ChannelLog
            record = ChannelLog(matchIndex,2);    %Extract Channels from ChannelLog

            %Check if record is empty
            if ~isempty(record)
                record = textscan(record{:},'%s','Delimiter',','); %Extract channels to cell array
                entry(i).Channel = record{:}; %Extract inner cell array
            else
                entry(i).Channel = {};
            end
            
            %Add from MasterLog
            masterIndex = MasterLogIndex == index(i);
            entry(i).Index = MasterLog{masterIndex,1};
            entry(i).OriginHash = MasterLog{masterIndex,2};
            entry(i).FinalHash = MasterLog{masterIndex,3};
            entry(i).Datetime = MasterLog{masterIndex,4};
        end
    end
end