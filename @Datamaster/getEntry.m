function [entry, index] = getEntry(dm,varargin)
    %Function to retrieve directory entries from Datamaster
    
    %Create Persistent Input Parser to handle reading inputs
    persistent p
    if isempty(p)
        p = inputParser;
        p.FunctionName = 'getEntry';
        addRequired(p,'obj',@(x) isa(x,'Datamaster'));
        addOptional(p,'Hash','',@(x) dm.validateHash(x));
        addParameter(p,'Driver',    [],     @(x) ischar(x) || iscell(x));
        addParameter(p,'Event',     [],     @(x) ischar(x) || iscell(x));
        addParameter(p,'Venue',     [],     @(x) ischar(x) || iscell(x));
        addParameter(p,'Short',     [],     @(x) ischar(x) || iscell(x));
        addParameter(p,'StartDate', [],     @(x) isa(x,'datetime') && length(x) == 1);
        addParameter(p,'EndDate',   [],     @(x) isa(x,'datetime') && length(x) == 1);
    end
    
    %Parse Inputs and expand to vectors
    parse(p,dm,varargin{:});
    Hash = p.Results.Hash;
    Driver = p.Results.Driver;
    Event = p.Results.Event;
    Venue = p.Results.Venue;
    Short = p.Results.Short;
    StartDate = p.Results.StartDate;
    EndDate = p.Results.EndDate;
    
    if nargin == 1
        index = true(1,dm.numEnteries);
    elseif ~strcmp(Hash,'')
        %Return Database enteries for that contain the supplied hash
        
        %Force Hash into a cell array
        if ~iscell(Hash)
            Hash = {Hash};
        end
        
        %Find Entry
        index = false(1,dm.numEnteries);
        for i = 1:length(Hash)
            cur_index = strcmp(Hash{i},{dm.mDir.OriginHash}) | strcmp(Hash{i},{dm.mDir.FinalHash});
            
            %Check if multiple entries matched -> May indicated duplication in
            %the directory
            if sum(cur_index) > 1
                warning('Expected only one entry match. Directory may contain duplicates');
            end
            
            %Combine with prior results
            if ~isempty(cur_index)
                index = cur_index | index;
            end
        end
    else
        %Search by Request
        Details = [dm.mDir.Details];
        Parameters = {dm.mDir.Parameters};
        
        %Match Index -> Assume Match Until Not a Match
        index = true(1,dm.numEnteries);
        
        %% Search for Driver
        if ~isempty(Driver)
            index = index & FieldMatch(Details,index,'Driver',Driver);
        end
        
        %% Search for Event
        if ~isempty(Event)
            index = index & FieldMatch(Details,index,'Event',Event);
        end

        %% Search for Venue
        if ~isempty(Venue)
            index = index & FieldMatch(Details,index,'Venue',Venue);
        end

        %% Search for Short
        if ~isempty(Short)
            index = index & FieldMatch(Details,index,'Short',Short);
        end

        %% Search for Date Range
        if ~isempty(StartDate) && ~isempty(EndDate)            
            index = index & isbetween([Details.Datetime],StartDate,EndDate);
        elseif ~isempty(StartDate)
            index = index & ([Details.Datetime] >= StartDate);
        elseif ~isempty(EndDate)
            index = index & ([Details.Datetime] <= EndDate);
        end
    end
    
    %Return Entry to User
    entry = dm.mDir(index);
end

function index = FieldMatch(Details,index,Field,Options)
    %Check to see if the option string is in the field

    %Force options into a cell
    if ~iscell(Options)
        Options = {Options};
    end
    
    %Regexp to Check
    regexpStr = ['(' strjoin(Options,'|') ')'];
    
    for i = find(index)
        %Search for Options in Field
        index(i) = any(regexpi(Details(i).(Field),regexpStr));
    end
end