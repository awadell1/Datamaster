function TimePlot(ds,chanName,varargin)
        
    %Create Input Parser Object
    p = inputParser;
    p.FunctionName = 'TimePlot';
    p.addRequired('ds',@(x) isa(ds,'datasource'));
    p.addRequired('chanName',@(x) ischar(x) || iscell(x));
    p.addParameter('Units','',@ischar);
    
    parse(p,ds,chanName,varargin{:});
    in = p.Results;
    chanName = in.chanName;
    ds = in.ds;
    
    %Load required channels
    ds.loadChannels(in.chanName);
    
    %Force chanName into cell
    if ~isa(chanName,'cell')
        chanName = {chanName};
    end
    
    %Plot each channel
    hold on
    units = cell(1,length(chanName));
    for i = 1:length(in.chanName)
        %Get the Channel
        channel = ds.getChannel(chanName{i});
        units{i} = channel.Units;
        plot(channel.Time,channel.Value);
    end
    
    %
    
    %Anotate Plot
    xlabel('Time [s]')
    legend(chanName,'Interpreter','none')