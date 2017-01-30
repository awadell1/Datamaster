function value = getConfigSetting(Key)
%getConfigSetting returns an iniConfig file for the current user
%   Detailed explanation goes here

%Expected filename for config file
userConfig = fullfile(Datamaster.getPath, 'config.ini');
defaultConfig = fullfile(Datamaster.getPath, 'default.ini');

%Check for both config files
for file = {userConfig, defaultConfig}
    if ~exist(file{:}, 'file')
        if strcmp(file{:}, defaultConfig)
            %Missing Default config file -> throw error
            errorStruct.message = ['Default config file (default.ini) not found. ',...
                'Please Pull an up to date copy from the git repo'];
            errorStruct.identifier = 'Datamaster:MissingConfig';
            error(errorStruct);
        elseif strcmp(file{:}, userConfig)
            %Missing User Config file -> Create empty config file
            warning(['User config file (config.ini) not found. ',...
                'Created blank user config file']);
            
            %Create Blank file
            fid = fopen(userConfig, 'w'); fprintf(fid, ' '); fclose(fid);
        end     
    end
end

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
if ischar(value) 
  %Replace %datastore% with datastore_path
  if strfind(value, '%datastore%')
    value = strrep(value, '%datastore%',...
        Datamaster.getConfigSetting('datastore_path'));
    %Get Valid File Path
    value = fullfile(value);
  end

  %Replace %Datamaster% with path to Datamaster
  if strfind(value, '%Datamaster%')
    value = strrep(value, '%Datamaster%',...
        Datamaster.getPath);
    %Get Valid File Path
    value = fullfile(value);
  end
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
