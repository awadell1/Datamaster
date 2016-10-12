function refreshGate(ds)
	%Compute the time and value array for the stored gating function

	%Assert the gateHandle is a function handle
	if ~isa(gateHandle, 'function_handle')
		errorStruct.message = 'gateHandle must be a function handle';
        errorStruct.identifier = 'Datamaster:datasource:setGAte';
        error(errorStruct);
	end

	%Compute Gate
	[ds.Gate.Value, ds.Gate.Time] = gateHandle(ds;

	%Check that the gating is valid
	assert(all(1*ds.Gate.Value == 0 | 1*ds.Gate.Value == 1), 'value must output 1 or 0')
