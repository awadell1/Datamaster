function openInMoTeC(ds)
    
    %Set Google Drive Location
    pathGoogleDrive = 'C:\Users\Alex\';
    
    %Check a datasource was provided
    if ~isempty(ds)
        %Start MoTeC COM Server
        i2 = actxserver('MoTeC.i2Application');
        i2.Visible = 1;
        pause(1);   %Wait for MoTeC to Open
        
        for i = 1:length(ds)
            %Open Datasource in MoTeC
            path = fullfile(pathGoogleDrive,ds(i).Entry.Origin);
            i2.DataSources.Open(path);
        end
        
    end