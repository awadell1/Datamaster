%Import Python Module for downloading Log File metadata
% import py.ConnectGoogleDrive.getFileList
% files = cell(getFileList());

%Convert from py.dict to struct
files = cellfun(@struct,files,'UniformOutput',false);

%Convert py.str to char
files = cellfun(@(x) structfun(@char,x,'UniformOutput',false),...
                files,'UniformOutput',false);
            
%Remove items without all fields present
fields = {'id','name','md5Checksum'};
index = cellfun(@(x) all(isfield(x,fields)),files); %Find cells missing parameters
files = [files{index}]; %Only keep the ones with everything