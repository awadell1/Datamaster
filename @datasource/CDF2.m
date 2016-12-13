function [cdf_2, x, y, duration] = CDF2(ds,varargin)
%Function to generate a CDF along the y axis of a bivariate histogram
%of the specified channel for all supplied datasources

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
    p.addParameter('ContourLevel', [0.99, 0.975, 0.95], @isnumeric);
end

%Parse Input
parse(p,ds,varargin{:});
ds = p.Results.ds;
chanNameX = p.Results.chanNameX;
chanNameY = p.Results.chanNameY;
nBins = p.Results.nBins;
Range = p.Results.Range;
ContourLevel = p.Results.ContourLevel;

%Assert that some datasource match
assert(~isempty(ds),'No Matching Datasources Found');

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
        count = sum(cat(3,count{:}),3)';
        duration = sum([duration{:}]);
    end

%Compute Center Locations of each bin
x = (edgesX(1:end-1) + edgesX(2:end))/2;
y = (edgesY(1:end-1) + edgesY(2:end))/2;

%Create CDF Curves - Power
cdf_2 = bsxfun(@rdivide, cumsum(count), sum(count));
cdf_2(isnan(cdf_2)) = inf;

% Plot Contours
gcf; box on
Datamaster.colormap('warm')
hold on
for i =1:length(ContourLevel)
    contour(x, y, cdf_2, 'LevelList', ContourLevel(i));
end
caxis([0.95*min(ContourLevel), max(ContourLevel)]);
hold off

%Label
xlabel(sprintf('%s [%s]',chanNameX, p.Results.unit{1}),'interpreter','none')
ylabel(sprintf('%s [%s]',chanNameY, p.Results.unit{2}),'interpreter','none')
title(sprintf('Based on %3.2f hrs of data',duration/3600));
end