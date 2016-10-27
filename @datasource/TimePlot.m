function ax = TimePlot(ds,varargin)
    
    %Create Input Parser Object
    persistent p
    if ~isempty(p) || true
        p = inputParser;
        p.FunctionName = 'TimePlot';
        p.addRequired('ds',@(x) isa(x,'datasource')); %ds must be a single datasource
        p.addOptional('ax',gca, @(x) isa(x,matlab.graphics.axis.Axes));
        p.addRequired('chanName',@(x) ischar(x));
        p.addParameter('units','',@ischar);
    end
    
    parse(p,ds,varargin{:});
    ds = p.Results.ds;
    chanName = p.Results.chanName;
    units = p.Results.units;
    ax = p.Results.ax;
    
    %Load required channels
    ds.loadChannel(chanName);
    
    %Set Unit
    if strcmp(units,'')
        %Units unset by User -> Default to first Datasources's Units
        units = ds.getChannel(chanName).Units;
    end
    
    %Plot the Channel
    channel = ds.getChannel(chanName);
    plot(ax, channel.Time,channel.Value);
    
    %Set the Legend Text
    legendText = sprintf('%s @ %s on %s',ds.getDetail('Driver'),...
        ds.getDetail('Venue'),datestr(ds.getDetail('Datetime')));
    
    %Get the current Legend
    leg = legend(ax);
    legendText = [leg.String legendText];
    
    %Append New Legend Entry to Legend
    legend(ax,legendText);
    
    %Anotate Plot
    xlabel('Time [s]')
    ylabel(sprintf('[%s]',units));