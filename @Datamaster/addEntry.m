function addEntry(dm, MoTeCFile, FinalHash, Details, channels)
    try
        
        %Start SQL Transaction
        try
            mksqlite(dm.mDir, 'BEGIN');
        catch
            %Catch errors caused by old transactions
            mksqlite(dm.mDir, 'ROLLBACK');
            mksqlite(dm.mDir, 'BEGIN');
        end
            
        
        %Create cell array of column names and values
        colNames = {'ldId', 'ldxId', 'OriginHash', 'FinalHash', 'Datetime'};
        values = {MoTeCFile.ld, MoTeCFile.ldx, MoTeCFile.OriginHash, FinalHash, MoTeCFile.createdTime};
        
        %Insert into the datastore
        fastinsert(dm.mDir, 'masterDirectory', colNames, values)
        
        %Get id for datasource
        query = sprintf('select id from MasterDirectory where FinalHash=''%s''',FinalHash);
        datasourceId = mksqlite(dm.mDir, query);
        
        %Add Missing Names to Details Logged
        DetailName = mksqlite(dm.mDir, 'select fieldName from DetailName');
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
                    mksqlite(dm.mDir, sprintf(['INSERT INTO DetailLog (entryId, value, unit, fieldId) ',...
                        'VALUES (%d, ''%s'', ''%s'', (SELECT id FROM DetailName WHERE fieldName = ''%s''))'],...
                        datasourceId,...
                        Details.(fieldName{i}).Value, Details.(fieldName{i}).Unit,...
                        fieldName{i}));
                end
            else
                %Check that Details was actually logged
                if ~isempty(Details.(fieldName{i}))
                    %Add Entry to datastore
                    mksqlite(dm.mDir, sprintf(['INSERT INTO DetailLog (entryId, value, fieldId) ',...
                        'VALUES (%d, ''%s'', (SELECT id FROM DetailName WHERE fieldName = ''%s''))'],...
                        datasourceId,...
                        Details.(fieldName{i}),...
                        fieldName{i}));
                end

            end
        end
        
        %Add missing Channels
        ChannelName = mksqlite(dm.mDir, 'select id, channelName from ChannelName');
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
        mksqlite(dm.mDir, query);
        
        %Commit Changes to databse
        mksqlite(dm.mDir, 'COMMIT');
    catch e
        %If something goes wrong -> roll back changes
        mksqlite('ROLLBACK');
        
        %Rethrow error
        rethrow(e);
    end
end

function fastinsert(dbid, table, fieldnames, values)
    %Helper function for adding entries to the datastore
    mksqlite(dbid, sprintf('INSERT INTO %s (%s) VALUES (''%s'')',...
        table, strjoin(fieldnames,','), strjoin(values,''',''')));
end