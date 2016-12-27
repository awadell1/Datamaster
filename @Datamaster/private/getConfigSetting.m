function [value] = getConfigSetting(Key)
%getConfigSetting returns an iniConfig file for the current user
%   Detailed explanation goes here

%Expected filename for config file
userConfig = 'config.ini';
defaultConfig = 'default.ini';

userValue = getKeyValue(userConfig, Key);
defaultValue = getKeyValue(defaultConfig, Key);

%Check if the user has set the key
if ~isempty(userValue)
    %Return Key from user settings
    value = userValue;
    
    %Check for a default setting
elseif ~isempty(defaultValue)
    %Return key from default settings
    value = defaultValue;
    
else % Abort and notify User
    errorStruct.message = sprintf('Missing Value for %s:%s',Section,Key);
    errorStruct.identifier = 'Datamaster:ConfigSetting:MissingKey';
    error(errorStruct);
end

%% Post Processing If Needed

%Replace %Datamaster% with path to Datamaster
if ischar(value) & strfind(value, '%Datamaster%')
    value = strrep(value, '%Datamaster%',...
        getConfigSetting('datastore_path'));
    
    %Get Valid File Path
    value = fullfile(value);    
end

end

function value = getKeyValue(filename, key)
%Scan config files and return the correct value for the request key

%Preallocate null value
value = [];

%Get File id
fid = fopen(filename);
while ~feof(fid)
   line = fgetl(fid);
   
   %Scan for key
   if regexpi(line, sprintf('^%s=', key))
       %Extract value
       value = regexpi(line, sprintf('^%s=(.+)$', key), 'tokens');
       value = value{:}{:};
       break
   end
end

%Close File
fclose(fid);
end
