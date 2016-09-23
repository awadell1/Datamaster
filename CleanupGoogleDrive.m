function CleanupGoogleDrive
%Recursivly checks over the Google Drive Folder and Removes any sync conflicts

%Regex to check if file should be deleted
RegEx = '~msxf';

%Assert that the host computer is a pc
assert(ispc,'Only pcs are supported')

%Path to Google Drive ADL3 folder
GoogleDrivePath = [getenv('userprofile') '\Google Drive\ADL3 Data'];

%Search and Distroy
RecursiveRegExpDelete(GoogleDrivePath,RegEx);

end

function RecursiveRegExpDelete(Path,RegEx)
	item = dir(Path);
	for i = 1:length(item)
        itemPath = fullfile(Path,item(i).name);
		if any(strcmp(item(i).name,{'.','..'}));
            %Do Nothing -> Referance to higher directory
        elseif item(i).isdir
			%Search subfolder
			RecursiveRegExpDelete(itemPath,RegEx);
		elseif any(regexpi(item(i).name,RegEx))
			%File Matches Pattern -> Delete File
			try
				delete(itemPath);
                fprintf('Deleted: %s\n',itemPath);
			catch
				fprintf('Failed to delete: %s\n',itemPath);
            end
		end
	end
end

