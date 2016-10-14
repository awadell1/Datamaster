function connectSQLite()
    %connectSQLite connects to an SQLite Database and returns a database connection
    
    %Settings for SQLite Connection
    dbpath = getConfigSetting('Datastore','master_directory_path');
    
    %Try to connect using mksqlite
    while true
        try
            %Open Connection
            mksqlite('open',dbpath);
            break;
        catch e
            if strcmp(e.identifier,'MATLAB:scriptNotAFunction')
                %Set up mksqlite
                buildit
            elseif strcmp(e.identifier,'SQLITE:CANTOPEN')
                error('Unable to Connect to Datastore: Check your network connection');
            end
        end
    end    
end

