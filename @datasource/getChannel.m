function channel = getChannel(ds,chanName,varargin)
    
    %Validate Channel Names
    persistent p
    if ~isempty(p) || true
        p = inputParser;
        p.FunctionName = 'Histogram2';
        p.addRequired('ds',@(x) isa(x,'datasource') && length(x)==1);
        p.addRequired('chanName',@(x) ischar(x) || iscell(x));
        p.addOptional('filter',[],@(x) any(strcmp(x,{'none','hampel','median'})));
    end
    
    %Extract Parameters
    parse(p,ds,chanName,varargin{:});
    ds = p.Results.ds;
    chanName = p.Results.chanName;
    filter = p.Results.filter;
    
    if isa(chanName,'cell')
        for i = 1:length(chanName)
            channel.(chanName{i}) = ds.getChannel(chanName{i});
        end
    else
        %Check if Channel has been loaded or filtering is set
        if ~isfield(ds.Data,chanName) || ~isempty(filter)
            ds.clearData(chanName);
            ds.loadChannels(chanName);
        end
        
        %Apply Filtering
        if ~isempty(filter)
            switch filter
                case 'hampel'
                    %Number of samples on either side to be used when computing the std and median
                    k = 13;
                    
                    %Number of Standard of deviations a sample must deviate to be an outlier
                    nSigma = 3;
                    
                    %Apply Filer
                    ds.Data.(chanName).Value = hampel(ds.Data.(chanName).Value,k,nSigma);
                case 'median'
                    %Number of samples on either side to be used when computing the median
                    n = 13;
                    
                    %Apply Filer
                    ds.Data.(chanName).Value = medfilt1(ds.Data.(chanName).Value,n);
            end
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
