	%% Get Datasource
dm = Datamaster
ds = dm.getDatasource('limit', 1);

detail = ds.getDetail('Driver')
assert(ischar(detail));

ds = dm.getDatasource('limit', 1);
detail = ds.getDetail('FuelTankCapacity')
assert(ischar(detail.Unit))
assert(ischar(detail.Value))