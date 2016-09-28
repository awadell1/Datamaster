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
            mainHeight = 600; mainWidth = 1000;
            obj.mainFig = figureGUI('Datamaster',[mainWidth mainHeight]);
            
            %% Create a Panel for inputing search quereys
            
            %Set Parameters for sizing
            panelHeight = 400; panelWidth = 400; %Height and Width of Panel
            pad = 5;    %Space between figure and panel
            
            %Text Boxes to create
            fieldNames = {'Event','Venue','Length','Driver','VehicleID',...
                'VehicleNumber','VehicleDesc','EngineID','Session',...
                'StartLap','Short','Long'};
            
            %Create the Panel
            obj.getEntry = uipanel('Parent',obj.mainFig,...
                'Title','Search for Datasources',...
                'Units','pixels',...
                'Position',[pad, mainHeight-panelHeight-pad, panelWidth, panelHeight]);
            
            %Add Textboxes for each Search fields
            xCord = pad;
            yCord = linspace(panelHeight-10-pad,pad/2,length(fieldNames)+1); %Create Array of upper and lower edges of Textboxes
            
            %Set the Height of each textbox
            entryHeight = abs(diff(yCord)) - pad;
            
            yCord(1) = []; %Drop First Entry as we only need the bottom edges
            
            for i = 1:length(fieldNames)
                addTextbox(obj.getEntry,fieldNames{i},[fieldNames{i} ':'],xCord, yCord(i)+pad/2, entryHeight(i));
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

