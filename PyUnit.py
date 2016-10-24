import numpy
from pint import UnitRegistry

ureg = UnitRegistry(); #Load the Default Unit Definitions
ureg.load_definitions('UnitDefine.txt') #Load additonal definitions

def convertUnit(value, oldUnit, newUnit='base'):
	#Convert to numpy array
	value = numpy.array(value)

	#Get Quanity Object
	valueOld = value * ureg(oldUnit)

	if newUnit == 'base':
		#Convert to base unit
		valueNew = valueOld.to_base_units()
	else:
		#Convert to New Unit
		valueNew = valueOld.to(newUnit)

	#Return as list of magnitude
	return {'value':valueNew.magnitude.tolist(), 'unit':'{:~}'.format(valueNew.units)}
