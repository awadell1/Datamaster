function [ldLoc, ldxLoc] = getDatasourceDrive(MoTeCFile,savePath)
    % Polls Google Drive to download the requested MoTeC Log files
    % MoTeCFile: Struct w/ the following fields
    %   ld: The file id of the .ld file to download
    %   ldx: The file id of the .ldx file to download
    % saveLoc: The folder to save the downloaded files to
    %
    % saveLoc: Cell array with the fullpaths to where each file is saved:
    % saveLoc: {ld Filepath, ldx Filepath}
    
    %Create annon function to create the request url
    url = @(id) ['https://docs.google.com/uc?id=', id, '&export=download'];
    
    %Set Filename for the files (But not extension)
    savePath = fullfile(savePath, MoTeCFile.ld);
    
    %Report Start
    fprintf('\n\tDownloading from Google Drive...');
    sTime = tic;
    
    %Download the .ld and .ldx files
    ldLoc = retryDownload([savePath '.ld'], url(MoTeCFile.ld));
    ldxLoc = retryDownload([savePath '.ldx'], url(MoTeCFile.ldx));
    
    %Report Done
    fprintf('done in %3.2f s\n',toc(sTime));tic
    
end

function saveLoc = retryDownload(saveLoc,url)
    %Impliment Exponential Backoff for download
    
    %Setting for back off
    maxTries = 5;       %Max Attempts to make
    pauseTime = 0.5;    %Baseline time to wait
    
    nTry = 0;
    while nTry < maxTries
        try
            %Attempt to download the file
            saveLoc = websave(saveLoc,url);
            break
        catch e
            %If error is thrown due to timeout -> retry, otherwise rethrow
            if ~strcmp(e.identifier,'MATLAB:webservices:Timeout')
                rethrow(e)
            else
                fprintf('timeout');
                pause(pauseTime*2^nTry);
                nTry = nTry +1;
            end
        end
    end
end