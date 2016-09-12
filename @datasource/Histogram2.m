function [count,ax] = Histogram2(ds,varargin)
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
        p.addParameter('Normalization',     'probability',...
            @(x) any(strcmp(x,{'count','probability'})));
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

    duration = 0; XMax = 0; YMax = 0;
    %Loop over each datasource
    for i = 1:length(ds)
        %Check if datasourc has logged Parameter
        if any(strcmp(chanNameX,ds(i).getLogged)) && any(strcmp(chanNameY,ds(i).getLogged))
            %Get Channels
            channelX = ds(i).getChannel(chanNameX);
            channelY = ds(i).getChannel(chanNameY);
            
            XMax = max([channelX.Value,XMax]);
            YMax = max([channelY.Value,YMax]);

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
        case 'probability'
            count = count ./ sum(sum(count));
        case 'count'
            %Do Nothing
    end

    %Plot the histogram
    xBarPoints = (edgesX(1:end-1) + edgesX(2:end))/2;
    yBarPoints = (edgesY(1:end-1) + edgesY(2:end))/2;
    [~,h] = contourf(xBarPoints,yBarPoints,count');
    
    %Set Levels for contour lines to be placed every 10% percentile
    percentiles = 0:20:100;
    Levels = prctile(count(count>0),percentiles);
    h.LevelList = Levels;
    
     h.ShowText = 'on'; drawnow;
    Text = h.TextPrims;
    for i = 1:length(Text)
        %Match Label to Level
        [~,index] = min(abs(str2double(Text(i).String) - Levels));
        
        %Replace with Percentile
        Text(i).String = sprintf('%.f%%',100-percentiles(index));
        
    end
    
    %Label Histogram
    xlabel(sprintf('%s [%s]',chanNameX,unit{1}),'interpreter','none')
    ylabel(sprintf('%s [%s]',chanNameY,unit{2}),'interpreter','none')
    title(sprintf('Based on %3.2f hrs of data',duration/3600));
    
    fprintf('XMax :%f YMax: %f\n',XMax,YMax);