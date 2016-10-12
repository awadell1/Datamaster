function [value, time] = gateSample(ds)
	% This is a sample function to show how to create a gating function
	% At a bare minimum the function must take the form:
	% [value, time, otherOutputs] = gateFunction(datasource)
	% Input:
	% ds: a single datasource object
	% Other Inputs: gateFunction will only be pasted a datasource
	% 	If other inputs are required they should be passed via an anonymous function
	%
	% Output: The order must be [value, time]
	% value: Strictly 1 or 0 (Not Logical) 
	% time: the time when the sample is valid/invalid

	%First Load all channels needed for the gating function
	%Strictly speaking channels can be loaded at any point
	%However there is a significant speed penalty for not loading at once
	ds.loadChannels({'Engine_RPM', 'Throttle_Pos', 'Manifold_Pres'});

	% Apply any filtering that is required at this point
	ds.getChannel('Throttle_Pos','filter','hampel');

	%Synchronize sampling rates for all loaded channels
	%Save the new time vector to each 
	%Note: filtering via getChannel will break synchronization
	time = ds.Sync;

	%Now create the value array
	%Set to 1: To include data into the results
	%Set to 0: To excluded data from results

	%Get each channels
	speed = ds.getChannel('Engine_RPM');
	throttle = ds.getChannel('Throttle_Pos');
	map = ds.getChannel('Manifold_Pres');

	%Compute values for each time points
	value = (speed.Value >= 1000 & speed.Value <= 6000);
	value = (abs(gradient(throttle.Value)./gradient(throttle.Time)) < 10) & value;
	value = (map.Value >= 90 & map.Value <= 180) & value;

	%Remember value must be strictly 0 or 1 (Or Logical)
	value = 1 * value;