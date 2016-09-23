function reportResults(query,item)
    %Report Status of Search
    if ~isempty(fieldnames(query))
        fprintf('Found %d %s matching your criteria\n',length(fieldnames(query)),item);
    else
        fprintf('Error: Found No %s for your query\n',item);
    end
end