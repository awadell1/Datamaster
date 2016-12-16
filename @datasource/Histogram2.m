function [count,h,ax] = Histogram2(ds,varargin)
    %Function to generate a histogram of the specified channel for all supplied datasources
    
    persistent p
    if ~isempty(p) || true
        p = inputParser;
        p.FunctionName = 'Histogram2';
        p.addRequired('ds',                     @(x) isa(x,'datasource'));
        p.addRequired('chanNameX',              @(x) ischar(x));
        p.addRequired('chanNameY',              @(x) ischar(x));
        p.addRequired('Range',                  @(x) isfloat(x) && all(size(x)==[2,2]));
        p.addParameter('unit',{'base', 'base'}, @(x) iscell(x) && numel(x) == 2);
        p.addParameter('nBins',		   [50,50],        @(x) isfloat(x) && length(x)==2);
        p.addParameter('normalization',     'pdf',...
            @(x) any(strcmp(x,{'count','probability','pdf'})));
    end
    
    %Parse Input
    parse(p,ds,varargin{:});
    ds = p.Results.ds;
    chanNameX = p.Results.chanNameX;
    chanNameY = p.Results.chanNameY;
    nBins = p.Results.nBins;
    Range = p.Results.Range;
    
    %Assert that some datasource match
    assert(~isempty(ds),'No Matching Datasources Found');
    
    %Set the Unit
    %Set Unit
    if isempty(p.Results.unit)
        %Units unset by User -> Default to first Datasources's Units
        unit{1} = ds(1).getChannel(chanNameX).Units;
        unit{2} = ds(2).getChannel(chanNameY).Units;
    else
        unit = p.Results.unit;
    end
    
    %Initialize arrays
    edgesX = linspace(Range(1,1),Range(1,2),nBins(1)+1);
    edgesY = linspace(Range(2,1),Range(2,2),nBins(2)+1);
    
    %% Process Datasource
    [count,duration] = mapReduce(ds, @mapFun,...
        @reduceFun, {chanNameX, chanNameY});
    
    %Define mapFun
    function [count, duration] = mapFun(ds)
        %Load Required Channels and sync sampling Rates
        ds.loadChannel({chanNameX, chanNameY});
        ds.Sync;
        
        %Get Channels
        channelX = ds.getChannel(chanNameX, 'unit', p.Results.unit{1}).Value;
        channelY = ds.getChannel(chanNameY, 'unit', p.Results.unit{2}).Value;
        
        count = histcounts2(channelX,channelY,edgesX,edgesY);
        duration = range(ds.getChannel(chanNameX).Time);
    end
    
    %Define Reduce Function
    function [count, duration] = reduceFun(count, duration)
        count = sum(cat(3,count{:}),3);
        duration = sum([duration{:}]);
    end
    
    %% Normalize Counts
    switch p.Results.normalization
        case 'pdf'
            %Compute Area of each bin
            cellArea = range(Range(1,:))*range(Range(2,:));
            cellArea = cellArea / numel(count);
            
            %Norm by number of bins and area of each bin
            count = count ./(sum(count(:))*cellArea);
            
            %Set label for colorbar
            cBarLabel = 'log10(Probability Density)';
        case 'probability'
            count = count ./ sum(sum(count));
            
            %Set label for colorbar
            cBarLabel = 'log10(Probability)';
        case 'count'
            %Set label for colorbar
            cBarLabel = 'log10(Count)';
    end
    
    %Due to the wide range of orders of magnitude-> take the log
    count = log10(count);
    
    %Plot the histogram and turn of countour lines
    xBarPoints = (edgesX(1:end-1) + edgesX(2:end))/2;
    yBarPoints = (edgesY(1:end-1) + edgesY(2:end))/2;
    [~,h] = contourf(xBarPoints,yBarPoints,count'); %Transpose as countourf and histocounts define x differently
    h.LineStyle = 'none';
    box on
    
    %Add and label the colorbar
    cBar = colorbar; Datamaster.colormap('warm');
    ylabel(cBar,cBarLabel, 'FontSize', 12);
    
    %Set the coloraxis to something reasonable
    m = mean(count(~isinf(count))); s = std(count(~isinf(count)));
    caxis([m-3*s, m+3*s]);
    
    %Label Histogram
    xlabel(sprintf('%s [%s]',chanNameX,unit{1}),'interpreter','none')
    ylabel(sprintf('%s [%s]',chanNameY,unit{2}),'interpreter','none')
    title(sprintf('Based on %3.2f hrs of data',duration/3600));
end