% DatamasterWiki Location
wiki = Datamaster.getConfigSetting('wiki');
reportFile = [Datamaster.getPath, '\TestSuite\Results.txt'];

%% Validate Datamaster
%Get code to test
exampleCode = getExampleCode(wiki);

%Run Tests
testResults = runtests([pwd; exampleCode(:, 1)]);

%Clean up
for i = 1:length(exampleCode)
    delete(exampleCode{i, 1})
end

%% Run Performance Test
perfTests = {'perfLoadChannel'};
perfResults = runperf(perfTests);

%Report Results
fid = fopen(reportFile, 'a');
for i = 1:length(perfResults)
    fprintf(fid, 'Performance Test: %s\n', perfResults(i).Name);
    fprintf(fid, '\tValid Test: %d\n', perfResults(i).Valid);
    fprintf(fid, '\tTime Mean: %f s\n', mean(perfResults(i).Samples.MeasuredTime));
    fprintf(fid, '\tTime Std. Dev: %f s\n', std(perfResults(i).Samples.MeasuredTime));
    fprintf(fid, '\tSample Count: %d\n\n', length(perfResults(i).Samples.MeasuredTime));
end
fclose(fid);

%% Helper Functions
function exampleCode = getExampleCode(folder)
%Scan Files for matlab code
file = dir(folder);
exampleCode = {};
    for i = 1:length(file)
        path = fullfile(file(i).folder, file(i).name);
        %Ignore Upwards links
        if ~strcmp(file(i).name(1), '.')
            if file(i).isdir
                exampleCode = [exampleCode, getExampleCode(path)];
            else
                %Read in file
                str = fileread(path);

                %Parse for Code marked for error checking with 'MATLAB'
                code = regexp(str, '```MATLAB(.+?)```', 'tokens');

                for j = 1:length(code)
                    % Generate Test Code Name
                    [~, name] = fileparts(file(i).name);
                    name = sprintf('%s_%02d.m', name, j);
                    exampleCode{end+1, 1} = fullfile(tempdir, name);
                    
                    %Create File
                    fid = fopen(exampleCode{end, 1}, 'w');
                    
                    %Add Path to test script header
                    fprintf(fid, '%s', code{j}{:});
                    
                    %Save test script
                    fclose(fid);
                end
            end
        end         
    end
end