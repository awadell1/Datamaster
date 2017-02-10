function Transient(ds, varargin)
    %Generates Oil Pressure vs Time above idle to assess oil return
    
    persistent p
    if ~isempty(p) || true
        p = inputParser;
        p.FunctionName = 'OilReturnRate';
        p.addRequired('ds',                             @(x) isa(x,'datasource'));
        p.addRequired('TrigChannel',                    @(x) ischar(x));
        p.addRequired('Threshold',                      @isnumeric);
        p.addRequired('TrigUnit',                       @ischar);
        p.addRequired('DataChannel',                    @(x) ischar(x));
        p.addRequired('Range',                          @(x) isfloat(x) && length(x)==2);
        p.addRequired('DataUnit',                       @ischar);
        p.addParameter('nBins',		    50,             @isfloat);
        p.addParameter('SampleRate',   0.5,             @isfloat);
        p.addParameter('Normalization',     'pdf',...
            @(x) any(strcmp(x,{'count','probability','pdf'})));
    end
    
    %Parse Inputs
    parse(p, ds, varargin{:});
    in = p.Results;
    
    %Initialize arrays
    dataEdges = linspace(in.Range(1), in.Range(2), in.nBins+1);
    
    %% Process Datasource
    [count, timeEdges, duration] = mapReduce(ds, @mapFun, @reduceFun,...
        {in.TrigChannel, in.DataChannel});
    
    %Define mapFun
    function [count, duration] = mapFun(ds)
        %Load Channels
        ds.loadChannel({in.TrigChannel, in.DataChannel}); ds.Sync;
        trigger = ds.getChannel(in.TrigChannel, 'unit', in.TrigUnit);
        channel = ds.getChannel(in.DataChannel, 'unit', in.DataUnit);
        
        %% Create trigger timer (Time since last trigger)
        timeData = trigger.Time;
        timeTrig = zeros(1, length(timeData));
        
        trip = find(trigger.Value > in.Threshold);
        
        %Check if Threshold is reached
        if isempty(trip)
            count = [];
            duration = [];
            return
        end
        
        %Handle trip(1) = 1 case
        if trip(1) == 1
            timeTrig(1) = 1;
            trip(1) = [];
        end
        
        dataSampleRate = mean(diff(channel.Time));
        for i = 1:length(trip)
            timeTrig(trip(i)) = timeTrig(trip(i)-1) + dataSampleRate;
        end
        
        %% Bin Data
        
        %Set Edges for time bin
        %Note: all data will land on the left edge of the bin
        timeRange = 0:in.SampleRate:max([timeTrig, 2*in.SampleRate]);
        
        % Run Binning
        count = histcounts2(timeTrig, channel.Value, timeRange, dataEdges);
        duration = range(channel.Time);
    end
    
    %Define Reduce Function
    function [count, timeEdges, duration] = reduceFun(count, duration)
        %Find max count size
        maxRow = 1;
        for i = 1:length(count)
            maxRow = max(maxRow, size(count{i}, 1));
        end
        sumCount= zeros(maxRow, length(dataEdges)-1);
        
        %Concat counts
        for i = 1:length(count)
            curSize = size(count{i});
            sumCount(1:curSize(1), 1:curSize(2)) = ...
                count{i} + sumCount(1:curSize(1), 1:curSize(2));
        end
        count = sumCount;
        
        timeEdges = 0:in.SampleRate:(maxRow*in.SampleRate);
        
        %Concat Duration
        duration = sum([duration{:}]);
    end
    
    %% Normalize Counts
    switch in.Normalization
        case 'pdf'
            %Compute Size of each bin
            cellSize = range(in.Range) / size(count,2);
            
            %Norm by number of bins and area of each bin
            count = bsxfun(@rdivide, count, sum(count,2)*cellSize);
            
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
    tBarPoints = timeEdges(1:end-1);
    yBarPoints = (dataEdges(1:end-1) + dataEdges(2:end))/2;
    [~,h] = contourf(tBarPoints,yBarPoints,count'); %Transpose as countourf and histocounts define x differently
    h.LineStyle = 'none';
    box on
    
    %Add and label the colorbar
    cBar = colorbar; Datamaster.colormap('warm');
    ylabel(cBar,cBarLabel, 'FontSize', 12);
    
    %Set the coloraxis to something reasonable
    valid = ~isinf(count) & ~isnan(count);
    m = mean(count(valid)); s = std(count(valid));
    caxis([m-3*s, m+3*s]);
    
    %Label Histogram
    xlabel('Time [s]','interpreter','none')
    ylabel(sprintf('%s [%s]', in.DataChannel, in.DataUnit), 'interpreter','none')
    
    %Set Title
    durTitle = sprintf('Based on %3.2f hrs of data', duration/3600);
    trigTitle = sprintf('Threshold: %s > %f %s', in.TrigChannel,...
        in.Threshold, in.TrigUnit);
    title({durTitle, trigTitle}, 'interpreter','none');
end