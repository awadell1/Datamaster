function addEntry(dm, MoTeCFile, FinalHash, Details, channels)
    try
        %Check if the Log Date and Time were recorded
        if isfield(Details, 'LogDate') && isfield(Details, 'LogTime')
            try %#ok<TRYNC>
                %Use date time found in details instead of file creation date
                logDatetime = [Details.LogTime ' ' Details.LogDate];
                logDatetime = datetime(logDatetime, 'InputFormat', 'HH:mm:ss dd/MM/yyyy');
                logDatetime = datevec(logDatetime);
                
                MoTeCFile.createdTime = sprintf('%04d-%02d-%02dT%02d:%02d:%02.3fZ',logDatetime);
            end
        end
        
        
        %Create cell array of column names and values
        colNames = {'ldId', 'ldxId', 'OriginHash', 'FinalHash', 'Datetime'};
        values = {MoTeCFile.ld, MoTeCFile.ldx, MoTeCFile.OriginHash, FinalHash, MoTeCFile.createdTime};
        
        %Insert into the datastore
        fastinsert(dm.mDir, 'masterDirectory', colNames, values)
        
        %Get id for datasource
        query = sprintf('select id from MasterDirectory where FinalHash=''%s''',FinalHash);
        datasourceId = dm.mDir.fetch(query); datasourceId = datasourceId{:};
        
        %% Check for Missing Fields
        %Add Missing Names to Details Logged
        DetailName = dm.mDir.fetch('select fieldName from DetailName');
        fieldName = fieldnames(Details); fieldName = fieldName(:);
        [~,indexMissing] = setxor(fieldName, DetailName);
        
        %Check if no Detail Names are missing
        if ~isempty(indexMissing)
            %Add missing Detail names to the DetailName table
            for i = 1:length(indexMissing)
                fastinsert(dm.mDir, 'DetailName', 'fieldName', fieldName(indexMissing(i)))
            end
        end
        
        %Add missing Channels
        ChannelName = dm.mDir.fetch('select id, channelName from ChannelName');
        if ~isempty(ChannelName)
            [~,indexMissing] = setxor(channels,ChannelName(:,2));
        else
            indexMissing = true(length(channels),1);
        end
        
        %Check if no channels are missing
        if ~isempty(indexMissing)
            %Add Channels to ChannelName Table -> Ensure channel is a column array
            for i = 1:length(indexMissing)
                dm.mDir.execute('INSERT INTO ChannelName (channelName) VALUES (?)', channels(indexMissing(i)));
            end
        end
        
        %Commit Changes
        dm.mDir.conn.commit
        
        %% Add Entries
        
        %Record Details
        for i =1:length(fieldName)
            if isstruct(Details.(fieldName{i}))
                %Check that Detail was actually logged
                if ~isempty(Details.(fieldName{i}).Value)
                    %Add Entry to datastore
                    dm.mDir.execute(['INSERT INTO DetailLog (entryId, value, unit, fieldId) ',...
                        'VALUES (?, ?, ?, (SELECT id FROM DetailName WHERE fieldName = ?))'],...
                        datasourceId,...
                        Details.(fieldName{i}).Value, Details.(fieldName{i}).Unit,...
                        fieldName{i});
                end
            else
                %Check that Details was actually logged
                if ~isempty(Details.(fieldName{i}))
                    %Add Entry to datastore
                    dm.mDir.execute(['INSERT INTO DetailLog (entryId, value, fieldId) ',...
                        'VALUES (?, ?, (SELECT id FROM DetailName WHERE fieldName = ?))'],...
                        datasourceId,...
                        Details.(fieldName{i}),...
                        fieldName{i});
                end
                
            end
        end
        
        %Record Channels Logged
        for i = 1:length(channels)
            query = sprintf(['INSERT INTO ChannelLog (entryId, channelId) ',...
                'VALUES (%d, (SELECT id FROM ChannelName WHERE channelName = ''%s''));'],...
                datasourceId,channels{i});
            dm.mDir.execute(query)
        end
        
        %Commit Changes
        dm.mDir.conn.commit
    catch e
        %Rollback Changes
        dm.mDir.conn.rollback();
        
        %Re throw Error
        rethrow(e);
    end
end

function fastinsert(conn, table, fieldnames, values)
    %Helper function for adding entries to the datastore
    if ischar(values)
        values = {values};
    end
    if ischar(fieldnames)
        fieldnames = {fieldnames};
    end
    conn.execute(sprintf('INSERT INTO %s (%s) VALUES (''%s'')',...
        table, strjoin(fieldnames,','), strjoin(values,''',''')));
end