function varargout = TimePlot(varargin)
    
    persistent p
    if empty(p)
       p = inputParser;
       p.FunctionName = 'TimePlot';
       p.addOptional('axes',@(x) isa(x,'matlab.graphics.axis.Axes'));
    end