classdef unit
    %Object for handling unit conversions in a general manner
    
    properties
        name = '';
        m = [0, 0];     %Meters
        kg = [0, 0];    %Kilograms
        s = [0, 0];     %Seconds
        A = [0, 0];     %Ampere
        K = [0, 0];     %Kelvin
        mol = [0, 0];   %Mole
        cd = [0, 0];    %Candela
        shift = 0;      %Shift to get to SI
        scale = 1;      %Conversion Factor to get to SI
        
        %Note:
        %SIValue = Scale*NonSIValue + shift
    end
    
    methods
        function obj = unit(name)
            %Set the name of the unit
            obj.name = name;
        end
        
        function newValue = convert(obj, value, newUnit)
            %Convert values from one unit to another
            % Input
            % obj: the unit object the data is currently in
            % value: an array of data to convert
            % newUnit: The unit object to convert to
            
            %% Check that units are convertable
            switch nargin
                case 3 %Convert to newUnit
                    baseUnits = {'m', 'kg', 's', 'A', 'K', 'mol', 'cd'};
                    for i = 1:length(baseUnits)
                        if ~all(obj.(baseUnits{i}) == newUnit.(baseUnits{i}));
                            error('Unit:Invalid:BaseUnitMatch',...
                                'Can not convert %s to %s',...
                                obj.name, newUnit.name);
                        end
                    end
                case 2 %Convert to SI
                    newUnit.shift = 0; newUnit.scale = 1;
                    
                otherwise %Invalide number of inputs
                    error('Unit:InvalidInput:IncorrectNumber',...
                        'Convert takes 2 or 3 inputs');
            end
            
            %Convert from current unit to new Unit
            newValue = (obj.scale .* value + (obj.shift - newUnit.shift)) ./ newUnit.scale;
        end
    end
    
end

