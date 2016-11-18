function [value, unit] = convertUnit(value, oldUnit, varargin)
    
    persistent p
    if ~isempty(p) || true
        p = inputParser;
        p.FunctionName = 'convertUnit';
        p.addRequired('value',              @isnumeric);
        p.addRequired('oldUnit',            @ischar);
        p.addOptional('newUnit', 'base',    @ischar);
    end
    
    %Parse Input
    parse(p, value, oldUnit, varargin{:});
    value = p.Results.value;
    oldUnit = p.Results.oldUnit;
    newUnit = p.Results.newUnit;
    
%     %Inport Python Libraies
%     import py.pint.UnitRegistry
%     
    %If dimensionless -> Return
    if strcmp(oldUnit, '')
        return
    else
        %Remove Unicode Charaters from oldUnit
        oldUnit = strrep(oldUnit, '°', 'deg');  %Remove Degree symbol
        oldUnit = strrep(oldUnit, '·', '*');    %Remove Times symbol
        
        %Put array into numpy array for conversion
        value = py.numpy.array(value);
        
        %Get Quanity Object
        ureg = py.pint.UnitRegistry;
        valueOld = ureg.Quantity(py.numpy.array(value), oldUnit);
        
        %Convert Quanity to desired Unit
        if strcmp(newUnit, 'base')
            %Convert to base unit
            valueNew = valueOld.to_base_units();
        else
            %Convert to New Unit
            valueNew = valueOld.to(newUnit);
        end
        
        %Extract Unit String
        unit = valueNew.units.char;
        
        %Extract Magnitude to array
        value = cell(valueNew.magnitude.tolist);
        value = cell2mat(value);
    end