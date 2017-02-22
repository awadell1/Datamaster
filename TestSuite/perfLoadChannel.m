dm = Datamaster;

%% Check Single Channel Loading speed
ds = dm.getDatasource('limit', 1);
channel = ds.getEntry.Channel;
ds.getChannel(channel{1});


%% Check Multi-Channel Loading
ds = dm.getDatasource('limit', 1);
channel = ds.getEntry.Channel;
ds.getChannel(channel(1:5));





