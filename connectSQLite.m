function [SQLite_Database] = connectSQLite()
    %connectSQLite connects to an SQLite Database and returns a database connection
    
    %Settings for SQLite Connection
    dbpath = getConfigSetting('Datastore','master_directory_path');
    
    %Check if the mksqlite mex file has been loaded
    if exist('mksqlite','file') ~=3
        %% Complie mksqlite
        %Save current path
        currentPath = pwd;
        
        %Move to mkslite folder
        cd([fileparts(which('connectSQLite')) '\mksqlite']);
        
        %Compile Mex file
        buildit
        
        %Move mex file to Datamaster
        movefile('mksqlite.mex*',fileparts(which('connectSQLite')))
        
        %Return to old path
        cd(currentPath);
    end
    
    %Check if dbpath exist
    if exist(dbpath,'file') == 2
        %Open Connection
        SQLite_Database = mksqlite('open',dbpath);

        %Set default output type to cell matrix
        mksqlite( 'result_type', 2 );
    else
        %Report error
        error('Unable to Find Datastore: %s', dbpath);
    end
    
