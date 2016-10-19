function Report(hash)
%% Summary Report for Recent Logging Events
% This report was automatically generated using the following version of
% the Datamaster project
dr = DataReporter;

%% Database Integrity Report
% If you were involved with the creation of the following log files contact
% Alexius Wadell (alw224) ASAP to make the necessary corrections to the
% Logged Details.

dr.checkDetails(hash);

%% Engine RPM
dr.dm.getDatasource(hash).Histogram('Engine_RPM',[0 5000]);
