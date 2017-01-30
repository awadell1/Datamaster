function ax = TimePlot(ds,varargin)
    
    %Create Input Parser Object
    persistent p
    if ~isempty(p) || true
        p = inputParser;
        p.FunctionName = 'TimePlot';
        p.addRequired('ds',@(x) isa(x,'datasource')); %ds must be a single datasource
        p.addOptional('ax',gca, @(x) isa(x,matlab.graphics.axis.Axes));
        p.addRequired('chanName',@(x) ischar(x));
        p.addParameter('unit',		 'base',    @ischar);
    end
    
    parse(p,ds,varargin{:});
    ds = p.Results.ds;
    chanName = p.Results.chanName;
    unit = p.Results.unit;
    ax = p.Results.ax;
    
    %Load required channels
    ds.loadChannel(chanName);
    
    %Plot the Channel
    channel = ds.getChannel(chanName, 'unit', unit);
    plot(ax, channel.Time,channel.Value);
        
    %Annotate Plot
    xlabel('Time [s]')
    ylabel(sprintf('[%s]',unit));