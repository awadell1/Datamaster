function Sync(ds, varargin)
	%Synchronizes the sampling rate of all opened channels

	%Create Input Parser
	persistent p
	if ~isempty(p) || true
		p = inputParser;
		p.FunctionName = 'Sync';

		%ds must be a datasource with at least one channel loaded
        addRequired(p,'ds',@(x) (isa(x,'datasource') && ~isempty(x.Data)));

        %syncType must be one of the available types
        addOptional(p,'syncType','fast', @(x) any(strcmp(x, {'fast', 'slow', 'cheap'})));
	end

	%Read in inputs
	parse(p,ds,varargin{:});
	ds = p.Results.ds;
	syncType = p.Results.syncType;

	%% Identify the sampling period of each channel
	channels = fieldnames(ds.Data);
	samplePeriod = zeros(length(channels),1);
	timeStart = 0;	timeEnd = inf;
	for i = 1:length(channels)
		%Compute the average sample period
		samplePeriod(i) = mean(diff(ds.Data.(channels{i}).Time));

		%Find the inclusive start and stop times
		timeStart = max(timeStart, ds.Data.(channels{i}).Time(1));
		timeEnd	= min(timeEnd, ds.Data.(channels{i}).Time(end));
	end

	%% Decide what the new sampling period will be
	switch syncType
		case 'fast'
			% The Fastest sampling rate has the smallest period
			newSamplePeriod = min(samplePeriod);
		case 'slow'
			% The Slowest sampling rate that the largest period
			newSamplePeriod = max(samplePeriod);
		case 'cheap'
			% The cheapest sampling rate to compute will resample the fewest channels
			newSamplePeriod = mode(samplePeriod);
		otherwise
			errorStruct.message = sprintf('%s is not a valid syncType',syncType);
            errorStruct.identifier = 'Datamaster:datasource:Sync';
            error(errorStruct);
	end

	%Create a new time inclusive time vector at the newSamplingRate
	timeNew = timeStart:newSamplePeriod:timeEnd;

	%% Resample Channels as needed
	for i = 1:length(channels)
		% Only resample if the channel's sampling period doesn't match the newSamplePeriod
		if samplePeriod ~= newSamplePeriod
			% Linearly resample the channel
			ds.Data.(channels{i}).Time = timeNew;
			ds.Data.(channels{i}).Value = interp1(...
				ds.Data.(channels{i}).Time,...
				ds.Data.(channels{i}).Value,...
				timeNew);
		else
			% Match the channel's time vector to the inclusive time vector
			dropStart = find(ds.Data.(channels{i}).Time == timeNew(1), 1, 'first');
			dropEnd = find(ds.Data.(channels{i}).Time == timeNew(end), 1, 'last');

			% Clip to the inclusive time vector
			ds.Data.(channels{i}).Time = timeNew;
			ds.Data.(channels{i}).Value = ds.Data.(channels{i}).Value(dropStart:dropEnd);
		end
	end

