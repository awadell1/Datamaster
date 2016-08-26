%Script to Check for New Log files and Export them to the Datastore
clc

%Create MoTeC COM Server
i2 = actxserver('MoTeC.i2Application');
i2.Visible = 1;
pause(1);   %Wait for MoTeC to Open

%Top Level Directory
baseDir = 'C:\Users\Alex\Google Drive\ADL3 Data';

%% Recursivly Search for New Log Files

%Setup input Stuct
s.dir = 'C:\Users\Alex\Google Drive\ADL3 Data';
s.i2 = i2;

fprintf('Accessing Datamaster\n')
s.Datamaster = Datamaster();

%Set Up Console
startTime = tic;
fprintf('\nSearching for New MoTeC Log Files...\n');

% Start Search
stats = RecursivelyOpen(s);

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
