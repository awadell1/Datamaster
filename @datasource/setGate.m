function setGate(ds, gateHandle)
	%Set the function used to generate the gate

	%Assert the gateHandle is a function handle
	if ~isa(gateHandle, 'function_handle')
		errorStruct.message = 'gateHandle must be a function handle';
        errorStruct.identifier = 'Datamaster:datasource:setGAte';
        error(errorStruct);
	end

	% Add gateHandle to each datasource
	for i = 1:length(ds)
		%Set Filter
		ds(i).Gate.gateFun = gateHandle;

		%Compute Gate
		refreshGate(ds);
	end