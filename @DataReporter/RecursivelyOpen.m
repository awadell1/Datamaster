function stats = RecursivelyOpen(s)
    %RecursivelyOpen Recursivly Open all MoTeC Log files
    
    % Inputs:
    % s: Stuct with following Fields
    %   s.dir: Full path to current directory to step over
    %   s.ParentDir: Full path to top level Directory (Optional)
    %   s.i2: Handle to COM server for MoTeC i2 Pro
    %   s.Datamaster: Handle to the Datamaster Object
    %
    % stats: Struct of running counts of export progress
    %   stats.New: Count of New Log Files
    %   stats.Duplicate: Count of Duplicate Log Files
    %   stats.Modified: Count of Modified Log Files
    %   stats.Prior: Count of Log Files previously exported
    %   stats.Corupt: Count of Failed Exports
    
    %Initalize Stats
    stats = struct('New',0,'Duplicate',0,'Modified',0,'Prior',0,'Corupt',0,'NewHash','');
    stats.NewHash = {}; %Make NewHash an empty cell array
    
    %Get the directory contents
    contents = dir(s.dir);
   
    %Sort from oldest to newest -> Assume older log file is correct one
    [~,index] = sortrows([contents.datenum].'); contents = contents(index(end:-1:1)); clear index
    
    %Set ParentDir
    if ~isfield(s,'ParentDir')
        s.ParentDir = s.dir;
    end
    
    %Loop over contents
    for i = 1:length(contents)
        %Get item name and path
        itemName = contents(i).name;
        itemLoc = fullfile(s.dir,contents(i).name);
        
        %Check if referance to parent folder
        if ~strcmp(itemName,'.') && ~strcmp(itemName,'..')
            
            %Check if item is a directory
            if contents(i).isdir
                %Set up struct for child directory
                nS = s;
                nS.dir = itemLoc;
                
                %Search Child Directory
                nStats = DataReporter.RecursivelyOpen(nS);
                
                %Add sub directory count to running count
                vars = fieldnames(stats);
                for j = 1:length(vars)
                    %Select method for concating entrys based on data type
                    fieldClass = class(stats.(vars{j}));
                    switch fieldClass
                        case 'double'
                            stats.(vars{j}) = nStats.(vars{j}) + stats.(vars{j});
                        case 'cell'
                            stats.(vars{j}) = [nStats.(vars{j}) stats.(vars{j})];
                    end
                end
            else
                %Check if item is a .id
                [~,~,type] = fileparts(itemLoc);
                if strcmp(type,'.ld')
                    %Check if file as already been exported
                    switch CheckLogFileStatus(s.Datamaster,itemLoc)
                        case 'new'
                            %New Data source -> Export
                            [success, FinalHash] = DataReporter.ExportDatasource(itemLoc,s);
                            
                            %Check if export was successful
                            if success
                                stats.New = stats.New +1;
                                stats.NewHash = [stats.NewHash FinalHash];
                            else
                                stats.Corupt = stats.Corupt +1;
                            end
                        case 'modified'
                            stats.Modified = stats.Modified +1;
                            fprintf('Modified: .%s...Skipping\n',itemLoc(length(s.ParentDir)+1:end));
                        case 'duplicate'
                            stats.Duplicate = stats.Duplicate +1;
                            fprintf('Duplicate: .%s...Skipping\n',itemLoc(length(s.ParentDir)+1:end));
                        case 'exported'
                            stats.Prior = stats.Prior +1;
                            fprintf('Prior Export: .%s...Skipping\n',itemLoc(length(s.ParentDir)+1:end));
                    end                        
                end
            end
        end
        
    end
end