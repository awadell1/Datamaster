function addEntry(dm, MoTeCFile, FinalHash, Details, channels)
    
    %Turn off AutoCommit so changes happen all at once
    set(dm.mDir, 'AutoCommit', 'off');
    
    %     %Detirmine Creation Date for Log File
    %     if isfield(Details,'LogDate')
    %         %Extract the Date
    %         date = regexpi(Details.LogDate,'(\d{2})\\(\d{2})\\(\d{4})-');
    %
    %         %Check if the creation time was also logged
    %         if isfield(Details,'LogTime')
    
    
    %Create cell array of column names and values
    colNames = {'ldId', 'ldxId', 'OriginHash', 'FinalHash', 'Datetime'};
    values = {MoTeCFile.ld, MoTeCFile.ldx, MoTeCFile.OriginHash, FinalHash, MoTeCFile.createdTime};
    
    %Insert into the directory
    dm.mDir.fastinsert('masterDirectory',colNames,values);
    
    %Get id for datasource
    query = sprintf('select id from MasterDirectory where FinalHash=''%s''',FinalHash);
    datasourceId = dm.mDir.fetch(query); datasourceId = datasourceId{:};
    
    %Add Missing Names to Details Logged
    DetailName = dm.mDir.fetch('select fieldName from DetailName');
    fieldName = fieldnames(Details); fieldName = fieldName(:);
    [~,indexMissing] = setxor(fieldName,DetailName);
    
    %Chec if no Detail Names are missing
    if ~isempty(indexMissing)
        %Add missing Detail names to the DetailName table
        dm.mDir.fastinsert('DetailName',{'fieldName'},fieldName(indexMissing));
        
        %Refresh list of DetailNames
        DetailName = dm.mDir.fetch('select fieldName from DetailName');
    end
    
    
    %Record Details
    for i =1:length(fieldName)
        %Find fieldId
        fieldId = find(strcmp(fieldName{i},DetailName));
        
        if isstruct(Details.(fieldName{i}))
            %Check that Detail was actually logged
            if ~isempty(Details.(fieldName{i}).Value)
                dm.mDir.datainsert('DetailLog',{'entryId', 'fieldId', 'value', 'unit'},...
                    {datasourceId, fieldId, Details.(fieldName{i}).Value, Details.(fieldName{i}).Unit});
            end
        else
            %Check that Details was actually logged
            if ~isempty(Details.(fieldName{i}))
                dm.mDir.datainsert('DetailLog',{'entryId', 'fieldId', 'value'},...
                    {datasourceId, fieldId, Details.(fieldName{i})});
            end
        end
    end
    
    %Add missing Channels
    ChannelName = dm.mDir.fetch('select channelName from ChannelName');
    [~,indexMissing] = setxor(channels,ChannelName);
    
    %Check if no channels are missing
    if ~isempty(indexMissing)
        %Add Channels to ChannelName Table -> Ensure channel is a column
        %array
        if size(channels,1) > size(channels,2)
            dm.mDir.fastinsert('ChannelName',{'channelName'},channels(indexMissing));
        else
            dm.mDir.fastinsert('ChannelName',{'channelName'},channels(indexMissing)');
        end
        
        
        %Refresh List of Channel Names
        ChannelName = dm.mDir.fetch('select channelName from ChannelName');
    end
    
    %Record Channels Logged
    [~, channelId] = union(channels,ChannelName);
    for i = 1:length(channelId)
        data{i,1} = datasourceId;
        data{i,2} = channelId(i);
    end
    
    dm.mDir.fastinsert('ChannelLog',{'entryId','channelId'},data);
    
    %Commit Changes to databse
    dm.mDir.commit;
    
    %Turn AutoCommit back on
    set(dm.mDir, 'AutoCommit', 'on');
    
end