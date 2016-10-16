function addEntry(dm, MoTeCFile, FinalHash, Details, channels)
    try
        
        %Start SQL Transaction
        try
            dm.mDir.execute('BEGIN');
        catch
            %Catch errors caused by old transactions
            dm.mDir.execute('ROLLBACK');
            dm.mDir.execute('BEGIN');
        end
            
        
        %Create cell array of column names and values
        colNames = {'ldId', 'ldxId', 'OriginHash', 'FinalHash', 'Datetime'};
        values = {MoTeCFile.ld, MoTeCFile.ldx, MoTeCFile.OriginHash, FinalHash, MoTeCFile.createdTime};
        
        %Insert into the datastore
        fastinsert(dm.mDir, 'masterDirectory', colNames, values)
        
        %Get id for datasource
        query = sprintf('select id from MasterDirectory where FinalHash=''%s''',FinalHash);
        datasourceId = dm.mDir.fetch(query);
        
        %Add Missing Names to Details Logged
        DetailName = m.mDir.fetch('select fieldName from DetailName');
        fieldName = fieldnames(Details); fieldName = fieldName(:);
        [~,indexMissing] = setxor(fieldName,DetailName);
        
        %Check if no Detail Names are missing
        if ~isempty(indexMissing)
            %Add missing Detail names to the DetailName table
            fastinsert(dm.mDir, 'DetailName', fieldName, fieldName(indexMissing))
        end
        
        
        %Record Details
        for i =1:length(fieldName)
            if isstruct(Details.(fieldName{i}))
                %Check that Detail was actually logged
                if ~isempty(Details.(fieldName{i}).Value)
                    %Add Entry to datastore
                    dm.mDir.execute(sprintf(['INSERT INTO DetailLog (entryId, value, unit, fieldId) ',...
                        'VALUES (%d, ''%s'', ''%s'', (SELECT id FROM DetailName WHERE fieldName = ''%s''))'],...
                        datasourceId,...
                        Details.(fieldName{i}).Value, Details.(fieldName{i}).Unit,...
                        fieldName{i}));
                end
            else
                %Check that Details was actually logged
                if ~isempty(Details.(fieldName{i}))
                    %Add Entry to datastore
                    dm.mDir.execute(sprintf(['INSERT INTO DetailLog (entryId, value, fieldId) ',...
                        'VALUES (%d, ''%s'', (SELECT id FROM DetailName WHERE fieldName = ''%s''))'],...
                        datasourceId,...
                        Details.(fieldName{i}),...
                        fieldName{i}));
                end

            end
        end
        
        %Add missing Channels
        ChannelName = m.mDir.fetch('select id, channelName from ChannelName');
        if ~isempty(ChannelName)
            [~,indexMissing] = setxor(channels,ChannelName(:,2));
        else
            indexMissing = true(length(channels),1);
        end
        
        %Check if no channels are missing
        if ~isempty(indexMissing)
            %Add Channels to ChannelName Table -> Ensure channel is a column
            %array
            fastinsert(dm.mDir, 'ChannelName', 'channelName', channels(indexMissing));
            %if size(channels,1) > size(channels,2)
            %    dm.mDir.fastinsert('ChannelName',{'channelName'},channels(indexMissing));
            %else
            %    dm.mDir.fastinsert('ChannelName',{'channelName'},channels(indexMissing)');
            %end
        end
        
        %Record Channels Logged
        query = cell(length(channels),1);
        for i = 1:length(channels)
            query{i} = sprintf(['INSERT INTO ChannelLog (entryId, channelId) ',...
                'VALUES (%d, (SELECT id FROM ChannelName WHERE channelName = ''%s''));'],...
                datasourceId,channels{i});
        end
        query = strjoin(query,'\n');
        dm.mDir.execute(query);
        
        %Commit Changes to databse
        dm.mDir.execute('COMMIT');
    catch e
        %If something goes wrong -> roll back changes
        mksqlite('ROLLBACK');
        
        %Rethrow error
        rethrow(e);
    end
end

function fastinsert(dbid, table, fieldnames, values)
    %Helper function for adding entries to the datastore
    dm.mDir.execute(sprintf('INSERT INTO %s (%s) VALUES (''%s'')',...
        table, strjoin(fieldnames,','), strjoin(values,''',''')));
end