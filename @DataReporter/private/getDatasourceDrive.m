function [ldLoc, ldxLoc] = getDatasourceDrive(MoTeCFile,savePath)
    % Polls Google Drive to download the requested MoTeC Log files
    % MoTeCFile: Struct w/ the following fields
    %   ld: The file id of the .ld file to download
    %   ldx: The file id of the .ldx file to download
    % 
    % ldLoc: filepath where the .ld file is saved
    % ldxLoc: filepath where the .ldx file is saved
    
    %Report Start of Download
    fprintf('\n\tDownloading from Google Drive...');
    sTime = tic;
    
    %Download the .ld and .ldx files to temporary files
    ldLoc = retryDownload( [tempname '.ld'], MoTeCFile.ld);
    ldxLoc = retryDownload([tempname, '.ldx'], MoTeCFile.ldx);
    
    %Report Done
    fprintf('done in %3.2f s\n',toc(sTime));tic
end

function saveLoc = retryDownload(saveLoc, fileId)
    %Download the given Goolge Drive File ID using it's webContentLink
    % saveLoc: path to save the downloaded file
    % fileID: the id used by Google to identify a given file
    
    %Setting for back off
    maxTries = 5;       %Max Attempts to make
    pauseTime = 0.5;    %Baseline time to wait
    
    %Google Drive Service URL
    gDriveURL = 'https://drive.google.com/uc';
    
    nTry = 0;
    while nTry < maxTries
        try
            %Attempt to download the file
            saveLoc = websave(saveLoc, gDriveURL,...
                'id', fileId,...
                'export', 'download');
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