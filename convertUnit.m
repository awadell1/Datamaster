function [value, unit] = convertUnit(value, oldUnit, varargin)

persistent p
if ~isempty(p) || true
    p = inputParser;
    p.FunctionName = 'convertUnit';
    p.addRequired('value',              @isnumeric);
    p.addRequired('oldUnit',            @ischar);
    p.addOptional('newUnit', 'base',    @ischar);
end

%Get Quantity Object
persistent ureg
if isempty(ureg)
    ureg = py.pint.UnitRegistry;
    ureg.load_definitions(fullfile(Datamaster.getPath, 'UnitDefine.txt'));
end

%Parse Input
parse(p, value, oldUnit, varargin{:});
value = p.Results.value;
oldUnit = p.Results.oldUnit;
newUnit = p.Results.newUnit;

%If dimensionless -> Return
if strcmp(oldUnit, '')
    return
    
elseif strcmp(oldUnit, newUnit)
    unit = oldUnit;
else
    %Remove Unicode Characters from oldUnit
    oldUnit = strrep(oldUnit, '°', 'deg');  %Remove Degree symbol
    oldUnit = strrep(oldUnit, '·', '*');    %Remove Times symbol
    oldUnit = strrep(oldUnit, 'psi a', 'psi');    %Remove Times symbol
    
    %Put array into numpy array for conversion
    value = py.numpy.array(value);
    
    %Convert to Pint Quantity
    valueOld = ureg.Quantity(py.numpy.array(value), oldUnit);
    
    %Convert Quantity to desired Unit
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
    newValue = py.numpy.array(valueNew.magnitude.tolist);
    value = double(py.array.array('d', py.numpy.nditer(newValue)));
end