function checkDetails(dr,hash)
    %Checks that the datasources (Given by hash) followed Standard Data
    %Logging Practices
    
    %Get Datasources
    ds = dr.dm.getDatasource(hash);
    Error = zeros(1,length(ds));

    %Check Each Datasource
    for i = 1:length(ds)
    	%%Report Current Log File
    	fprintf('Logged Date: %s\n',ds(1).getEntry.Datetime)
    	fprintf('Origin Hash: %s\n',ds(i).getEntry.OriginHash);
        
        %% Validate Event
        Error(i) = Error(i) + SelectionField(ds(i),'Event',...
        	{'ACCEL', 'AUTOX', 'ENDUR', 'SKID', 'HOLD', 'SWEEP', 'WARM', 'OTHER'});

        %% Validate Venue
		Error(i) = Error(i) + SelectionField(ds(i),'Venue',... 
			{'BLOT', 'DYNO', 'LAB', 'MIS', 'GLEN', 'DESTINY', 'GROTON'});

		%% Validate Engine ID -> Tune File name
		%TODO: Find Tune Files
		fprintf('\t%s: ''%s''\n','Engine ID',ds(i).getDetail('EngineID'));

		%% Validate Vehicle ID -> Vehicle Configuration Spreadsheet Filename
		%TODO: Find/Set up Spreadsheet
		fprintf('\t%s: ''%s''\n','Vehicle ID',ds(i).getDetail('VehicleID'));

		%% Validate Driver -> Must be a NetID
		Error(i) = Error(i)	+ RegExpTester(ds(i),'Driver','^(([a-z]{2,3}\d+)\s*)+$');

		%% Validate Session -> Subteam ID + netid
		SubteamID = {'DRIVE', 'DYNO', 'FLOW', 'AERO', 'ERGO', 'UNSPRUNG', 'DTRAIN' };	%Cell Array of Allowed Subteam ID's

		%Check if valid entry
		Error(i) = Error(i)	+ RegExpTester(ds(i),'Session',...
			['^(' strjoin(SubteamID,'|') ')[^a-z0-9]([a-z]{2,3}\d+)$']);

		%% Validate Short Comment
		Sys_Id = {'ENG', 'CHA', 'EE'};
		FaultCode = {'ISU', 'FAIL', 'CAT'};

		Error(i) = Error(i)	+ RegExpTester(ds(i),'Short',...
			['^(' strjoin(Sys_Id,'|') ')[^a-z0-9](' strjoin(FaultCode,'|') ')$']);

		%Insert Space before Next Report
		fprintf('\n');
    end
    
end

function valid = SelectionField(ds,Field,Allowed)
	%Checks if field in Details was filled in with one of the allowed values
	%If it wasn't report an error

	fieldValue = ds.getDetail(Field);
	regexpStr = ['^(' strjoin(Allowed,'|') ')$'];

	if ~any(regexpi(fieldValue,regexpStr))
		fprintf('\tIllegal Entry: ''%s'' is not a valid entry for %s\n',fieldValue,Field)
		valid = false;
	else
		fprintf('\t%s: ''%s''\n',Field,fieldValue);
		valid = true;
	end
end

function valid = RegExpTester(ds,Field,regexpStr)
	%Uses the supplied RegExp to check if Field in the datasource's details was completed correctly

	fieldValue = ds.getDetail(Field);

	if ~any(regexpi(fieldValue,regexpStr))
		fprintf('\tIllegal Entry: ''%s'' is not a valid entry for %s\n',fieldValue,Field)
		valid = false;
	else
		fprintf('\t%s: ''%s''\n',Field,fieldValue);
		valid = true;
	end
end