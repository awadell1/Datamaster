function ds = getDatasource(dm,varargin)
    %Function to handle extracting a datasource from Datamaster
    
    %Get Enteries for requested datasource
    entry = dm.getEntry(varargin{:});
    
    %Access requested datasources
    if ~isa(entry.FinalHash,'cell')
        %Only One Datasource Requested -> Return struct
        ds = datasource(dm,entry);
    else
        %Multiple datasources requested -> Return Cell array
        ds = cell(1,length(entry.FinalHash));
        for i = 1:length(entry.FinalHash)
            ds{i} = datasource(dm,indexSubCell(entry,i));
        end
    end
end

function s2 = indexSubCell(s1,index)
    vars = fieldnames(s1);
    for i = 1:length(vars)
        s2.(vars{i}) = s1.(vars{i}){index};
    end
end