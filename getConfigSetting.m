function [value] = getConfigSetting(Section,Key)
    %getConfigSetting returns an iniConfig file for the current user
    %   Detailed explanation goes here

    %Expected filename for config file
    configFilename = 'config.ini';
    defaultConfig = 'default.ini';
    
    %Create a config object for reading the .ini file
    persistent configSetting
    if isempty(configSetting) || true
        %Create an iniConfig object
        configSetting = IniConfig();
        
        %Use the default config file unless config.ini exist
        if exist(configFilename,'file'))
            configSetting.ReadFile(configFilename);
        else
            assert(exist(defaultConfig,'file)'), 'Missing the Default Config File');
            configSetting.ReadFile(defaultConfig);
        end
    end
    
    %Check if the requested key exists
    if ~configSetting.IsKeys(Section,Key)
        %Request the key value from the user
        prompt = sprintf('Missing Value for %s:%s\n Please enter it here:',Section,Key);
        value = inputdlg(prompt,'Missing Configuration Setting');

        %Check if empty
        if isempty(value)
            errorStruct.message = sprintf('Missing Value for %s:%s',Section,Key);
            errorStruct.identifier = 'Datamaster:ConfigSetting:MissingKey';
            error(errorStruct);
        else
            %Extract from cell array
            value = value{:};

            %Add the Key 
            configSetting.AddKeys(Section,Key,value);
            configSetting.WriteFile(configFilename);
        end
    else
        %Get the Requested value
        value = configSetting.GetValues(Section,Key);
    end

   
end

