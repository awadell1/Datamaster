function [value] = getConfigSetting(Section,Key)
%getConfigSetting returns an iniConfig file for the current user
%   Detailed explanation goes here

%Expected filename for config file
userConfig = 'config.ini';
defaultConfig = 'default.ini';

%% Create a persistent variable for accessing the default config file
persistent defaultSetting
if isempty(defaultSetting) || true
    %Load the Default Configuration File
    if  exist(defaultConfig,'file')
        defaultSetting = IniConfig;
        defaultSetting.ReadFile(defaultConfig);
    else
        % Missing Default config file -> Thow error so user goes and gets it
        assert('Missing Default Settings File -> Obtain from Git Repo')
    end
end

%% Create a persistent variable for accessing the user config file
persistent userSetting
if isempty(userSetting) || true
    %Load User Config file
    if exist(userConfig,'file')
        userSetting = IniConfig;
        userSetting.ReadFile(userConfig);
    else
        userSetting = [];
    end
end

%Check if the user has set the key
if isa(userSetting, 'IniConfig') && userSetting.IsKeys(Section,Key)
    %Return Key from user settings
    value = userSetting.GetValues(Section,Key);
    
    %Check for a default setting
elseif isa(defaultSetting, 'IniConfig') && defaultSetting.IsKeys(Section,Key)
    %Return key from default settings
    value = defaultSetting.GetValues(Section,Key);
    
else % Abort and notify User
    errorStruct.message = sprintf('Missing Value for %s:%s',Section,Key);
    errorStruct.identifier = 'Datamaster:ConfigSetting:MissingKey';
    error(errorStruct);
end

%% Post Processing If Needed

%Replace %Datamaster% with path to Datamaster
if ischar(value)
    value = strrep(value, '%Datamaster%',...
        fileparts(which(defaultConfig)));
    
    %Get Valid File Path
    value = fullfile(value);    
end

end

