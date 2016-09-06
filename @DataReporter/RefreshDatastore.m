function stats = RefreshDatastore(dr)
    %Searches the ADL3 Data Folder on Google Drive for any new MoTeC Log
    %Files. New Log Files are then exported and added to the Datastore by
    %Datamaster. 
    %Also records summary satistics such as number of new, modified and
    %corrupt log files currently on the Google Drive.
    %Returns a cell array containg the OriginHashes of all newly exported
    %Log Files

%Top Level Directory
%baseDir = 'C:\Users\Alex\Google Drive\ADL3 Data';

%% Recursivly Search for New Log Files

%% Setup input Stuct

%Top Level Directory
s.dir = 'C:\Users\Alex\Google Drive\ADL3 Data';

%Create MoTeC COM Server
s.i2 = actxserver('MoTeC.i2Application');
s.i2.Visible = 1;
pause(1);   %Wait for MoTeC to Open

%Pull Datamaster handle from DataReporter
s.Datamaster = dr.dm;

%Set Up Console
startTime = tic;
fprintf('\nSearching for New MoTeC Log Files...\n');

% Start Search
stats = DataReporter.RecursivelyOpen(s);

%Clean up Datastore
s.Datamaster.Cleanup

%Report Duration
fprintf('\n\nDatabase Refresh Complete\n');

%Report Export Stats
vars = fieldnames(stats);
for i = 1:length(vars)
    switch class(stats.(vars{i}))
        case 'double'
            fprintf('%s Log Files: %.1d\n',vars{i},stats.(vars{i}));
        case 'cell'
            fprintf('Newly Exported Log Files:\n')
            
            temp = stats.(vars{i});
            fprintf('\t%s\n',temp{:});
    end
end
fprintf('\n')
toc(startTime);

%Get Git Version and report
reportGitInfo;
