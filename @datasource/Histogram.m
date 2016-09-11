function ax = Histogram(ds,varargin)
    %Function to generate a histogram of the specified channel for all supplied datasources
    
    persistent p
    if ~isempty(p) || true
        p = inputParser;
        p.FunctionName = 'Histogram';
        p.addRequired('ds',                     @(x) isa(x,'datasource'));
        p.addRequired('chanName',               @(x) ischar(x));
        p.addRequired('Range',                  @(x) isfloat(x) && length(x)==2);
        p.addParameter('ax',         gca,       @(x) isa(x,matlab.graphics.axis.Axes));
        p.addParameter('unit',		   [],        @ischar);
        p.addParameter('nBins',		   50,        @isfloat);
        p.addParameter('Normalization',     'count',...
            @(x) any(strcmp(x,{'count','probability'})));
    end
    
    %Parse Input
    parse(p,ds,varargin{:});
    ds = p.Results.ds;
    chanName = p.Results.chanName;
    nBins = p.Results.nBins;
    Range = p.Results.Range;
    ax = p.Results.ax;
    
    %Set the Unit
    %Set Unit
    if isempty(p.Results.unit)
        %Units unset by User -> Default to first Datasources's Units
        unit = ds(1).getChannel(chanName).Units;
    else
        unit = p.Results.unit;
    end
    
    %Initialize arrays
    count = zeros(1,nBins);
    edges = linspace(Range(1),Range(2),nBins+1);
    duration = 0;
    %Loop over each datasource
    h = waitbar(0,'Generating Histogram');
    nDatasource = length(ds);
    for i = 1:nDatasource
        %Check if datasourc has logged Parameter
        if any(strcmp(chanName,ds(i).getLogged))
            %Bin logged data for each datasource
            count = histcounts(ds(i).getChannel(chanName).Value,edges) + count;
            duration = range(ds(i).getChannel(chanName).Time) + duration;
            
            %Clear data to preserve RAM
            ds(i).clearData; 
        end
        
        %Update Waitbar
        waitbar(i/nDatasource)
    end
    delete(h);
    
    %Normalize Counts
    switch p.Results.Normalization
        case 'probability'
           count = count ./ sum(count);
        case 'count'
            %Do Nothing
    end
    %Plot the histogram
    xBarPoints = (edges(1:end-1) + edges(2:end))/2;
    bar(ax,xBarPoints,count);
    
    %Label Histogram
    xlabel(sprintf('%s [%s]',chanName,unit),'interpreter','none')
    ylabel(p.Results.Normalization);
    title(sprintf('Based on %3.2f hrs of data',duration/3600));