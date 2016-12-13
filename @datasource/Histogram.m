function [count,ax] = Histogram(ds,varargin)
    %Function to generate a histogram of the specified channel for all supplied datasources
    
    persistent p
    if ~isempty(p) || true
        p = inputParser;
        p.FunctionName = 'Histogram';
        p.addRequired('ds',                     @(x) isa(x,'datasource'));
        p.addRequired('chanName',               @(x) ischar(x));
        p.addRequired('Range',                  @(x) isfloat(x) && length(x)==2);
        p.addParameter('unit',		 'base',    @ischar);
        p.addParameter('nBins',		   50,        @isfloat);
        p.addParameter('Normalization',     'pdf',...
            @(x) any(strcmp(x,{'count','probability','pdf'})));
    end
    
    %Parse Input
    parse(p,ds,varargin{:});
    ds = p.Results.ds;
    chanName = p.Results.chanName;
    nBins = p.Results.nBins;
    Range = p.Results.Range;
   
    %Assert that some datasource match
    assert(~isempty(ds),'No Matching Datasources Found');
       
    %Initialize arrays
    edges = linspace(Range(1),Range(2),nBins+1);
    
    %% Process Datasource
    [count,duration] = mapReduce(ds, @mapFun, @reduceFun, chanName);
    
    %Define mapFun
    function [count, duration] = mapFun(ds)
        channel = ds.getChannel(chanName, 'unit', p.Results.unit);
        count = histcounts(channel.Value,edges);
        duration = range(channel.Time);
    end
    
    %Define Reduce Function
    function [count, duration] = reduceFun(count, duration)
       count = sum(cell2mat(count));
       duration = sum([duration{:}]);
    end
    
    %% Normalize Counts
    switch p.Results.Normalization
        case 'pdf'
            count = count ./ (sum(count) * (range(Range)/nBins));
            ylabel('Proablility Density');
        case 'probability'
            count = count ./ sum(count);
            ylabel('Probability');
        case 'count'
            %Do Nothing
            ylabel('Count');
    end
    
    %% Plot the histogram
    ax = gca;
    hold on; box on
    xBarPoints = (edges(1:end-1) + edges(2:end))/2;
    bar(ax,xBarPoints,count,'histc');
    
    %Label Histogram
    xlabel(sprintf('%s [%s]',chanName, p.Results.unit),'interpreter','none')
    ylabel(p.Results.Normalization);
    title(sprintf('Based on %3.2f hrs of data',duration/3600));
    
    %Update axis
    axis normal
    hold off
end