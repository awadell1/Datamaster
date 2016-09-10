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
    %Loop over each datasource
    for i = 1:length(ds)
        %Bin logged data for each datasource
        count = histcounts(ds(i).getChannel(chanName).Value,edges) + count;

        %Clear data to preserve RAM
        ds(i).clearData;
    end
    
    %Plot the histogram
    xBarPoints = (edges(1:end-1) + edges(2:end))/2;
    bar(ax,xBarPoints,count);
    xlabel(sprintf('%s [%s]',chanName,unit),'interpreter','none')