function [Details] = getDetails(idxFilename)
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    
    %Read in the idx file to a string
    str = fileread(idxFilename);
    
    %Initalize Details
    Details = struct;
    
    %Strip to just the details section
    str = regexpi(str,'<Details>([\s\S]+)<\/Details>','tokens'); 
    
    %Check if Details were logged
    if ~isempty(str)
        %Extract Details block for str cell array
        str = str{:}{:};
        
        %Extract each field
        fields = regexpi(str,'<(.+?)\/>','tokens');
        
        %Create the Details Struct
        for i = 1:length(fields)
            %Grab the current Field sub cell
            current = regexpi(fields{i}, '(String|Numeric|DateTime) Id="(.+?)" Value="(.*?)"( Unit="(.*?)")?', 'tokens');
            %Skip to next field if current is empty
            if isempty(current{:})
                continue
            end
            
            current = current{:}{:};
            
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
    
end

