classdef sqlite
    %Class for connecting to an sqlite database
    
    properties
        conn = [];
    end
    
    methods
        function obj = sqlite(dbpath)
            import py.sqlite3.*
            
            obj.conn = py.sqlite3.connect(dbpath);
        end
        
        function execute(obj, SQLQuery, varargin)
            try
                if numel(varargin) > 1
                    obj.conn.execute(SQLQuery, varargin);
                else
                    obj.conn.execute(SQLQuery, py.list(varargin{:}));
                end
            catch pyE
                e.message = sprintf('SQL Query Failed: %s\n%s',...
                    SQLQuery, pyE.message);
                e.identifier = 'Datamaster:sqlite:execute';
                error(e);
            end
        end
        
        function executemany(obj, SQLQuery, varargin)
            obj.conn.executemany(SQLQuery,varargin)
        end
        
        function record = fetch(obj, SQLQuery)
            %Run and fetch the query
            cur = obj.conn.execute(SQLQuery);
            results = cur.fetchall();
            
            %Convert py.list to cell
            results = cell(results);
            if ~isempty(results)
                record = cell(length(results),length(results{1}));
                for i = 1:length(results)
                    record(i,:) = cell(results{i});
                end
                
                %Convert python datatypes to matlab
                record = cellfun(@py2Mat,record, 'UniformOutput',0);
            else
                record = [];
            end
        end
    end
end

function matData = py2Mat(pyData)
    switch class(pyData)
        case 'py.str'
            %Convert py.str to char
            matData = char(pyData);
        case 'py.unicode'
            %Convert py.unicode to char
            matData = char(pyData);
        case 'py.int'
            %Convert py.int to double
            matData = double(pyData);
        case 'py.NoneType'
            matData = [];
        otherwise
            %Leave as is
            matData = pyData;
    end
    
end
