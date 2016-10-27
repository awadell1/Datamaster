import numpy
from pint import UnitRegistry

ureg = UnitRegistry(); #Load the Default Unit Definitions
ureg.load_definitions('UnitDefine.txt') #Load additonal definitions

def convertUnit(value, oldUnit='', newUnit='base'):
	

	if not oldUnit:
		#Dimensionless -> Return
		return {'value':value, 'unit':''}
	else:
		# Replace the degree symbol with 'deg'
		oldUnit = oldUnit.decode("utf-8").replace(u"\u00B0", "deg")

		#Get Quanity Object
		valueOld = UnitRegistry().Quantity(numpy.array(value), oldUnit)

		if newUnit == 'base':
			#Convert to base unit
			valueNew = valueOld.to_base_units()
		else:
			#Convert to New Unit
			valueNew = valueOld.to(newUnit)

	#Return as list of magnitude
	return {'value':valueNew.magnitude.tolist(), 'unit':'{}'.format(valueNew.units)}
