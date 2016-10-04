function [Details] = getDetails(idxFilename)
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    
    %Read in the idx file to a string
    str = fileread(idxFilename);
    
    %Strip to just the details section
    str = regexpi(str,'<Details>([\s\S]+)<\/Details>','tokens'); str = str{:}{:};
    
    %Extract each field
    fields = regexpi(str,'<(.+?) Id="(.+?)" Value="(.*?)"( Unit="(.*?)")?','tokens');
    
    %Create the Details Struct
    for i = 1:length(fields)
        %Grab the current Field sub cell
        current = fields{i};
        
        %Match Unit
        unit = regexpi(current{4},'"(.*)"','tokens');
        if ~isempty(unit)
            current{4} = unit{:}{:};
        end

        %Create a valid struct name
        current{2} = matlab.lang.makeValidName(current{2});
        if ~strcmp(current{1},'Numeric') || length(current)~=4
            Details.(current{2}) = current{3};
        else
            Details.(current{2}).Value = current{3};
            Details.(current{2}).Unit = current{4};
        end
    end
    
end

