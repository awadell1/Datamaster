function [SQLite_Database] = connectSQLite(dbpath)
    %connectSQLite connects to an SQLite Database and returns a database connection
    
    %Check if python is installed
    if isempty(pyversion)
        fprintf(['Please install <a href="https://www.python.org/">python</a>\n',...
            'Be sure to check the option to "Add Python to Path"\n'...
            'Python can be found at the above link or www.python.org\n']);
        error('Datamaster requires <a href="https://www.python.org/">python</a>');
    end
    
    %Check if dbpath exist
    if exist(dbpath,'file') == 2
        %Open Connection
        SQLite_Database = sqlite(dbpath);
    else
        %Report error
        error('Unable to Find Datastore: %s', dbpath);
    end
    
