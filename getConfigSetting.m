function [value] = getConfigSetting(Section,Key)
    %getConfigSetting returns an iniConfig file for the current user
    %   Detailed explanation goes here
    
    %Create a config object for reading the .ini file
    persistent configSetting
    if isempty(configSetting) || true
        %Create an iniConfig object
        configSetting = IniConfig();
        
        %Read the default config file
        configSetting.ReadFile('config.ini');
    end
    
    %Get the Requested value
    value = configSetting.GetValues(Section,Key);
end

