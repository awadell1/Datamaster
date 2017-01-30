%% Create Datamaster Object
dm = Datamaster;
assert(isa(dm, 'Datamaster'))

%Get Datastore path
path1 = Datamaster.getConfigSetting('datastore_path');
path2 = dm.getDatastore;
assert(strcmp(path1, path2))

% Check getDatasource
ds = dm.getDatasource;
assert(isa(ds, 'datasource'))

%Search by Time
ds1 = dm.getDatasource('StartDate', '2016-02-01', 'EndDate', '2016-03-01');
ds2 = dm.getDatasource('StartDate', '2016-02-01', 'EndDate', '2016-04-01');
ds3 = dm.getDatasource('StartDate', '2016-01-01', 'EndDate', '2016-03-01');
ds4 = dm.getDatasource('StartDate', '2016-03-01', 'EndDate', '2016-02-01');


assert(length(ds1) < length(ds2)); %Check EndDate
assert(length(ds1) < length(ds3)); %Check StartDate
assert(length(ds4) == 0); %Invalid Date range

%Helper for picking a random datasource
randDs = @(ds) floor(length(ds) * rand) +1;

%Limit Results - Limit to random number of results
num = randDs(ds);
dsNum = dm.getDatasource('limit', num);
assert(length(dsNum) == num);

%Search by Channel - Single Channel
ds = dm.getDatasource('channel', 'Engine_RPM');
channels = ds(randDs(ds)).getLogged;
assert(any(strcmp('Engine_RPM', channels)));

%Search by Multiple - Single Channel
ds = dm.getDatasource('channel', {'Engine_RPM', 'Engine_Torque'});
channels = ds(randDs(ds)).getLogged;
assert(any(strcmp('Engine_RPM', channels)));
assert(any(strcmp('Engine_Torque', channels)));