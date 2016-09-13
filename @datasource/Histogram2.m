function [count,h,ax] = Histogram2(ds,varargin)
    %Function to generate a histogram of the specified channel for all supplied datasources
    
    persistent p
    if ~isempty(p) || true
        p = inputParser;
        p.FunctionName = 'Histogram';
        p.addRequired('ds',                     @(x) isa(x,'datasource'));
        p.addRequired('chanNameX',              @(x) ischar(x));
        p.addRequired('chanNameY',              @(x) ischar(x));
        p.addRequired('Range',                  @(x) isfloat(x) && all(size(x)==[2,2]));
        p.addParameter('ax',         gca,       @(x) isa(x,matlab.graphics.axis.Axes));
        p.addParameter('unit',		   [],      @(x) iscell(x) && numel(x) == 2);
        p.addParameter('nBins',		   [50,50],        @(x) isfloat(x) && length(x)==2);
        p.addParameter('Normalization',     'pdf',...
            @(x) any(strcmp(x,{'count','probability','pdf'})));
    end
    
    %Parse Input
    parse(p,ds,varargin{:});
    ds = p.Results.ds;
    chanNameX = p.Results.chanNameX;
    chanNameY = p.Results.chanNameY;
    nBins = p.Results.nBins;
    Range = p.Results.Range;
    ax = p.Results.ax;
    
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
    count = zeros(nBins(1),nBins(2));
    edgesX = linspace(Range(1,1),Range(1,2),nBins(1)+1);
    edgesY = linspace(Range(2,1),Range(2,2),nBins(2)+1);

    duration = 0;
    %Loop over each datasource
    for i = 1:length(ds)
        %Check if datasourc has logged Parameter
        if any(strcmp(chanNameX,ds(i).getLogged)) && any(strcmp(chanNameY,ds(i).getLogged))
            %Get Channels
            channelX = ds(i).getChannel(chanNameX);
            channelY = ds(i).getChannel(chanNameY);
            
            %Upsample if needed otherwise just use raw data
            if isequal(channelX.Time,channelY.Time)
                %No Need for Interpolation
                duration = duration + range(channelX.Time);
                channelX = channelX.Value;
                channelY = channelY.Value;
            else
                %Linearly Interpolate between points -> Use higher sampling channel for base time
                if mean(diff(channelX.Time)) <= mean(diff(channelY.Time))
                    %Use channelX as Basis
                    duration = duration + range(channelX.Time);
                    channelY = interp1(channelY.Time,channelY.Value,channelX.Time);
                    channelX = channelX.Value;
                else
                    %Use ChannelY as Basis
                    duration = duration + range(channelY.Time);
                    channelX = interp1(channelX.Time,channelX.Value,channelY.Time);
                    channelY = channelY.Value;
                end

                %Trim Extrapolated Points
                trimNAN = isnan(channelX) | isnan(channelY);
                channelX(trimNAN) = [];
                channelY(trimNAN) = [];
            end

            %Bin logged data for each datasource
            count = histcounts2(channelX,channelY,edgesX,edgesY) + count;
            
            %Clear data to preserve RAM
            ds(i).clearData;
        end
    end
    
    %Normalize Counts
    switch p.Results.Normalization
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
    grid on
    
    %Add and label the colorbar
    cBar = colorbar;
    ylabel(cBar,cBarLabel);
    
    %Set the coloraxis to something reasonable
    m = mean(count(~isinf(count))); s = std(count(~isinf(count)));
    caxis([m-3*s, m+3*s]);
    
    %Label Histogram
    xlabel(sprintf('%s [%s]',chanNameX,unit{1}),'interpreter','none')
    ylabel(sprintf('%s [%s]',chanNameY,unit{2}),'interpreter','none')
    title(sprintf('Based on %3.2f hrs of data',duration/3600));