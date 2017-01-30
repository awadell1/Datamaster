function value = getDetail(ds, fieldName)
%Get a specific detail from Detail Log

%Assert that ds is singular
assert(length(ds) ==1, 'getDetails only supports singular datasources');

%Load Details if missing
if isempty(ds.Detail)
    %Get Logged Details
    DetailLog = ds.dm.mDirFetch(sprintf(['SELECT DetailLog.entryId, '...
        'DetailName.fieldName, DetailLog.value, DetailLog.unit FROM DetailLog ',...
        'INNER JOIN DetailName ON DetailName.id = DetailLog.fieldId ',...
        'WHERE DetailLog.entryId IN (%s)'], strjoin(sprintfc('%d',ds.Entry.Index),',')));
    
    %Add DetailLog records to Details
    for j = 1:length(DetailLog)
        if isempty(DetailLog{j,4})
            ds.Detail.(DetailLog{j,2}) = DetailLog{j,3};
        else
            ds.Detail.(DetailLog{j,2}).Value = DetailLog{j,3};
            ds.Detail.(DetailLog{j,2}).Unit = DetailLog{j,4};
        end
    end
end

%Check if Detail exist
if isfield(ds.Detail, fieldName)
    value = ds.Detail.(fieldName);  %Return Detail
else
    value = '';    %Detail is missing return empty
end
end