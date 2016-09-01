function ds = getDatasource(dm,varargin)
    %Function to handle extracting a datasource from Datamaster
    
    %Get Enteries for requested datasource
    entry = dm.getEntry(varargin{:});
    
    %Access requested datasources
    for i = 1:length(entry)
        ds(i) = datasource(dm,entry(i));
    end
end