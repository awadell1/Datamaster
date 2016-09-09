%Refresh the Databases
dr = DataReporter;
dr.RefreshDatastore

%Publish Report
reportFile = publish('Report.m','stylesheet','ReportStyle.xsl',...
    'showCode',false);

%Email Report
message = 'See the attached file for the summary report';
matlabmail('awadell@gmail.com',message,'Datamaster Summary Report','html\Report.html')