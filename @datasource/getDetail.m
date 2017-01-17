function detail = getDetail(ds,Detail)
%Get a sepecfic detail from Detail Log

%Assert that ds is singluar
assert(length(ds) ==1, 'getDetails only supports singular datasources');

%Load Details if missing
if isempty(ds.Detail)
    %Fetch Details from datastore
    DetailLog = ds.dm.mDir.sqlite(sprintf(['SELECT DetailLog.entryId, '...
        'DetailName.fieldName, DetailLog.value, DetailLog.unit FROM DetailLog ',...
        'INNER JOIN DetailName ON DetailName.id = DetailLog.fieldId ',...
        'WHERE DetailLog.entryId IN (%s)'], strjoin(sprintfc('%d',ds.Entry.Index),',')));
    
    %Add DetailLog records to Details
    for j = 1:length(DetailLog)
        if strcmp(DetailLog{j,4},'null')
            ds.Detail.(DetailLog{j,2}) = DetailLog{j,3};
        else
            ds.Detail.(DetailLog{j,2}).Value = DetailLog{j,3};
            ds.Detail.(DetailLog{j,2}).Unit = DetailLog{j,4};
        end
    end
end

%Check if Detail exist
if isfield(ds.Detail, Detail)
    detail = ds.Detail.Detail;  %Return Detail
else
    detail = '';    %Detail is missing return empty
end
end