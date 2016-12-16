function [steady, time] = SteadyStateDetection(ds, channelName, tWindow, maxError)
    %Filter to detect when a channel is at a steady state point
    %Channel
    
    %Get Channel Data
    channel = ds.getChannel(channelName);
    data = channel.Value;
    time = channel.Time;
    
    %Set Window size
    k = floor(tWindow/mean(diff(time)));
    
    %Intalize array of channel data for each window period
    nWindow = 2*k +1;
    dev = zeros(length(data), nWindow);
    
    for i = 1:nWindow
        dev(max(2+k-i,1):(end+min(k-i,0)),i) = ...
            data(max(1,1+i-k):(end+min(0,i-k-1)));
    end
    
    %Find the standard error of each window
    stdError = range(dev, 2);
    
    %Stead if standard error is less then criteria
    steady = stdError < 2*maxError;
end

