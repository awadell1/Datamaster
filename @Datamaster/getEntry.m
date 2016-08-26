function [entry, index] = getEntry(dm,varargin)
    %Function to retrieve directory entries from Datamaster
    
    %Create Persistent Input Parser to handle reading inputs
    %persistent p
    %if isempty(p)
    p = inputParser;
    p.FunctionName = 'getEntry';
    addRequired(p,'obj',@(x) isa(x,'Datamaster'));
    addOptional(p,'Hash','',@validateHash);
    %end
    
    %Parse Inputs
    parse(p,dm,varargin{:});
    in = p.Results;
    
    %Initalize outputs
    entry = {}; index = {};
    
    if ~strcmp(in.Hash,'')
        %Return Database enteries for that contain the supplied hash
        
        %Force Hash into a cell array
        if ~iscell(in.Hash)
            in.Hash = {in.Hash};
        end
        
        %Find Entry
        index = zeros(1,length(dm.mDir.OriginHash));
        for i = 1:length(in.Hash)
            cur_index = strcmp(in.Hash{i},dm.mDir.OriginHash) | strcmp(in.Hash{i},dm.mDir.FinalHash);
            
            %Check if multiple entries matched -> May indicated duplication in
            %the directory
            if sum(cur_index) > 1
                warning('Expected only one entry match. Directory may contain duplicates');
            end
            
            %Combine with prior results
            index = cur_index | index;
        end
        
        %Return Entry to User
        vars = fieldnames(dm.mDir);
        for i = 1:length(vars)
            entry.(vars{i}) = dm.mDir.(vars{i})(index);
        end
        
    elseif nargin == 1
        %Return entire Directory
        entry = dm.mDir;
        index = ones(1,length(dm.mDir.FinalHash));
    end
    
end