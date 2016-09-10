function duration = driveTime(ds,varargin)
	%Compute the Total time logged on the engine in seconds

	duration = 0;

	% Lop over Log Files
	for i = 1:length(ds)
		duration = duration + range(ds(i).getChannel('Engine_RPM').Time);
	end