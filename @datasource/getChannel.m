function channel = getChannel(ds,chanName)
    
    %Validate Channel Names
    assert(validateChannel(ds,chanName),'Invalid Channel Name');
    
    if isa(chanName,'cell')
        for i = 1:length(chanName)
            channel.(chanName{i}) = ds.getChannel(chanName{i});
        end
    else
        %Check if Channel has been loaded
        if ~any(strcmp(chanName,fieldnames(ds.Data)))
            ds.loadChannels(chanName);
        end
        
        %Return Channel
        channel = ds.Data.(chanName);
    end
    
end

function valid = validateChannel(ds,channel)
    valid = true;
    if isa(channel,'cell')
        i = 1;
        while i <= length(channel) && valid
            %Recursivly Validate Each entry in the cell
            valid = valid && validateChannel(ds,channel{i});
            i = i+1;
        end
    elseif isa(channel,'char')
        %Check if Channel was logged
        valid = any(strcmp(channel,ds.getLogged()));
    else
        valid = false;
    end
end
