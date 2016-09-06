function TimePlot(ds,varargin)
    
    %Create Input Parser Object
    p = inputParser;
    p.FunctionName = 'TimePlot';
    p.addRequired('ds',@(x) isa(x,'datasource')); %ds must be a single datasource
    p.addOptional('ax',gca, @(x) isa(x,matlab.graphics.axis.Axes));
    p.addRequired('chanName',@(x) ischar(x));
    p.addParameter('Units','',@ischar);
    
    parse(p,ds,varargin{:});
    in = p.Results;
    chanName = in.chanName;
    ds = in.ds;
    
    %Load required channels
    ds.loadChannels(in.chanName);
    
    %Set Unit
    if strcmp(in.Units,'')
        %Units unset by User -> Default to first Datasources's Units
        Units = ds.getChannel(chanName).Units;
    else
        Units = in.Units;
    end
    
    %Plot each channel
    hold on
    %Plot the Channel
    channel = ds.getChannel(chanName);
    plot(channel.Time,channel.Value);
    
    %Set the Legend Text
    legendText = sprintf('%s @ %s on %s',ds.getDetails('Driver'),...
        ds.getDetails('Venue'),datestr(ds.getDetails('Datetime')));
    
    %Get the current Legend
    leg = legend(in.ax);
    legendText = [leg.String legendText];
    
    %Append New Legend Entry to Legend
    legend(in.ax,legendText);
    
    %Anotate Plot
    xlabel('Time [s]')
    ylabel(sprintf('[%s]',Units));
    
    hold off