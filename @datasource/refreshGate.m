function refreshGate(ds)
	%Compute the time and value array for the stored gating function

	%Assert the datasource has a gateFunction
	if ~isa(ds.Gate.gateFun, 'function_handle')
		errorStruct.message = 'gateFun must be a function handle';
        errorStruct.identifier = 'Datamaster:datasource:setGate';
        error(errorStruct);
	end

	%Compute Gate
	[ds.Gate.Value, ds.Gate.Time] = ds.Gate.gateFun(ds);

	%Check that the gating is valid
	assert(all(1*ds.Gate.Value == 0 | 1*ds.Gate.Value == 1), 'value must output 1 or 0')
