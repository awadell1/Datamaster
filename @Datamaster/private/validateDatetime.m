function valid = validateDatetime(datestr)
    %Function to validate that a string is a valid datetime to pass to
    %sqlite
    
    %Assume string is invalid
    valid = false;
    
    %Assert that datestr is a string
    if ~ischar(datestr)
        return
    end
    
    %Parse the dateString into a date vector
    %ie. {YYYY, MM, DD, HH, MM}
    dateVec = regexp(datestr,...
        '(\d{4})-(\d{1,2})-(\d{1,2})(?> (\d{1,2}):(\d{1,2}))?', 'tokens');
    
    %Assert that something matched
    if isempty(dateVec)
        return
    else
        %Extract Results
        dateVec = dateVec{:};
    end
    
    %Validate magnitudes
    dateVec = str2double(dateVec);
    
    %Check months
    if ~(dateVec(2) <= 12 && dateVec(2) >= 1)
        return
    end
    
    %Check Days
    if ~(dateVec(3) <= 31 && dateVec(3) >= 1)
        return
    end
    
    %If hous and minutes are supplied also check
    if length(dateVec) == 5
        %Check Hours
        if ~(dateVec(4) <= 24 && dateVec(4) >= 0)
            return
        end
        
        %Check Minutes
        if ~(dateVec(5) <= 59 && dateVec(5) >= 0)
            return
        end
    end
    
    %All checks pased -> valid datestring
    valid = true;
        
        