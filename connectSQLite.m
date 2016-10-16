function [SQLite_Database] = connectSQLite()
    %connectSQLite connects to an SQLite Database and returns a database connection
    
    %Settings for SQLite Connection
    dbpath = getConfigSetting('Datastore','master_directory_path');
    
    %Check if python is installed
    if isempty(pyversion)
        fprintf('Please install <a href="https://www.python.org/">python</a>\n')
        error('Datamaster requires python');
    end
    
    %Check if dbpath exist
    if exist(dbpath,'file') == 2
        %Open Connection
        SQLite_Database = sqlite(dbpath);
    else
        %Report error
        error('Unable to Find Datastore: %s', dbpath);
    end
    
