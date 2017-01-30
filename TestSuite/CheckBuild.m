%% DatamasterWiki Location
wiki = Datamaster.getConfigSetting('wiki');

%Get code to test
exampleCode = getExampleCode(wiki);

%Run Tests
runtests([pwd; exampleCode(:, 1)])

%Clean up
for i = 1:length(exampleCode)
    delete(exampleCode{i, 1})
end

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