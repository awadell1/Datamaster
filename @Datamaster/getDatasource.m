function [datasource,entry] = getDatasource(dm,varargin)
    %Function to handle extracting a datasource from Datamaster
    
    %Get Enteries for requested datasource
    entry = dm.getEntry(varargin{:});
    
    %Access requested datasources
    if length(entry.FinalHash) == 1
        %Only One Datasource Requested -> Return struct
        datasource = LoadDatasource(dm,entry.FinalHash);
    else
        %Multiple datasources requested -> Return Cell array
        datasource = cell(1,length(entry.FinalHash));
        for i = 1:length(entry.FinalHash)
            datasource{i} = LoadDatasource(dm,entry.FinalHash{i});
        end
    end
end

function datasource = LoadDatasource(dm,FinalHash)
    %Function to handle reading in a datastore .mat file
    datasource = load(fullfile(dm.Datastore,[FinalHash '.mat']));
end