function Value = getKeyValue(filename, key)

%Open File
fid = fopen(filename);

%Read in line by line
while ~feof(fid)
    lineText = fgetl(fid);
    
    %Check for key
    if regexpi(lineText, sprintf('%s=', key))
        %Extact Value
        Value = regexpi(lineText, '=(.+)', 'tokens');
        Value = Value{:}{:};
        break
    end 
end

%Close Config File
fclose(fid);