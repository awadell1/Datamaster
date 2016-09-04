function [entry, index] = getEntry(dm,varargin)
    %Function to retrieve directory entries from Datamaster
    
    %Create Persistent Input Parser to handle reading inputs
    persistent p
    if isempty(p)
    p = inputParser;
    p.FunctionName = 'getEntry';
    addRequired(p,'obj',@(x) isa(x,'Datamaster'));
    addOptional(p,'Hash','',@validateHash);
    end
    
    %Parse Inputs
    parse(p,dm,varargin{:});
    in = p.Results;

    if ~strcmp(in.Hash,'')
        %Return Database enteries for that contain the supplied hash
        
        %Force Hash into a cell array
        if ~iscell(in.Hash)
            in.Hash = {in.Hash};
        end
        
        %Find Entry
        index = false(1,dm.numEnteries);
        for i = 1:length(in.Hash)
            cur_index = strcmp(in.Hash{i},{dm.mDir.OriginHash}) | strcmp(in.Hash{i},{dm.mDir.FinalHash});
            
            %Check if multiple entries matched -> May indicated duplication in
            %the directory
            if sum(cur_index) > 1
                warning('Expected only one entry match. Directory may contain duplicates');
            end
            
            %Combine with prior results
            index = cur_index | index;
        end
        
    elseif nargin == 1
        index = true(1,dm.numEnteries);
    end
    
    %Return Entry to User
    entry = dm.mDir(index);
end