classdef DatamasterGUI < handle
    %GUI for interacting with Datamaster
    properties
        %Stores the main contol figure
        mainFig;
        getEntry
        dm = Datamaster;
    end
    
    methods
        function obj = DatamasterGUI()
            %Initalize the main figure
            obj.mainFig = figureGUI('Datamaster',[1000 600]);
            
            %Create a Panel for getEntry
            obj.getEntry = uipanel('Parent',obj.mainFig,...
                'Title','Search for Datasources',...
                'Units','normalized',...
                'Position',[0.01 0.350 0.6 0.65]);
            
            %Add Textboxes for Search fields
            fieldNames = {'Event','Venue','Length','Driver','VehicleID',...
                'VehicleNumber','VehicleDesc','EngineID','Session',...
                'StartLap','Short','Long'};
            PosY = 340; stepY = 30;
            for i = 1:length(fieldNames)
                addTextbox(obj.getEntry,fieldNames{i},[fieldNames{i} ':'],5, PosY);
                PosY = PosY -stepY;
            end
            
            %Add Buttons to search for Entries
            addButton(obj.mainFig,'Get Entries',@obj.getEntryCallback,20,20)
            
            %Add Button to search for Datasources
            addButton(obj.mainFig,'Get Datasources',@obj.getDatasourceCallback,170,20)
            
            %Add Button to Open in MoTeC
            addButton(obj.mainFig,'Open in MoTeC',@obj.openMoTeC,320,20)
            
            %Make Main figure visable
            obj.mainFig.Visible  = 'on';
        end
        
        function openMoTeC(obj,varargin)
            %Collect Datasources
            datasource = getDatasourceCallback(obj,varargin);
            
            %Warn User
            prompt = sprintf('Are you sure you want to open %d datasource(s) in MoTeC?',length(datasource));
            choice = questdlg(prompt,'Confirm Open','Yes','No','No');
            
            if strcmp(choice,'Yes')
                datasource.openInMoTeC;
            end
        end
        function datasource = getDatasourceCallback(obj,varargin)
            %Collect Query
            query = runGetEntry(obj);
            
            %Run Query and return to workspace
            if ~isempty(fieldnames(query))
                datasource = obj.dm.getDatasource(query);
                assignin('base','datasource',datasource);
            end
            
            fprintf('Found %d Datasources matching your criteria\n',length(datasource))
        end
        
        function getEntryCallback(obj,varargin)
            %Collect Query
            query = runGetEntry(obj);
            
            %Run Query and return to workspace
            entry = obj.dm.getEntry(query);
            assignin('base','entry',entry);
            
            fprintf('Found %d Entries matching your criteria\n',length(entry))
        end
        
        function query = runGetEntry(obj)
            %Consolidates selections into a getEntry query
            textBoxes = obj.getEntry.Children;
            
            %Only look at filled in textboxes
            index = strcmp('edit',{textBoxes.Style});
            index = index & ~strcmp('',{textBoxes.String});
            
            %Loop over each textbox
            query = struct;
            for i = find(index)
                query.(textBoxes(i).Tag) = textBoxes(i).String;
            end
        end
        
    end
end

