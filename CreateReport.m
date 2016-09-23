%Refresh the Databases
dr = DataReporter;
dr.RefreshDatastore

close all

%Publish Report
reportFile = publish('Report.m','format','pdf','showCode',false);

%Email Report
message = 'See the attached file for the summary report';
%matlabmail('awadell@gmail.com',message,'Datamaster Summary Report','html\Report.pdf')