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

 %Assert that the host computer is a pc
assert(ispc,'Only a pc can export MoTeC Log files')

% Top Level Directory
s.dir = [getenv('userprofile') '\Google Drive\ADL3 Data'];

% Get Location of Google Drive if guessed wrong
if ~exist(s.dir)
    s.dir = uigetdir('','Open the ADL3 Data Folder');
end

assert(ischar(s.dir) && exist(s.dir),'Could Not Find the ADL3 Folder');

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
