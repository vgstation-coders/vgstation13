import os, sys

foundTypes={}
def extractTypesFrom(file,extractType):
	currentType=''
	currentBase=''
	inType=False
	blankLine=False
	with open(file,'r') as f:
		for line in f:
#			if line.strip() == '':
#				blankLine=True
#				continue
#			if blankLine:
#				blankLine=False
#				if inType:
#					foundTypes[currentBase]+='\r\n'
			if line.startswith('/') and line[0:2] != '//' and line[0:2] != '/*':
				if not line.strip().endswith(')'):
					typepath=line.strip()
					if typepath.startswith(extractType):
						basename = typepath.split('/')[-1]
						if typepath == extractType:
							basename='standard'
						inType=True
						if currentType=='' or not typepath.startswith(currentType):
							currentType=typepath
							currentBase=basename
							if basename in foundTypes:
								foundTypes[basename]+=line
							else:
								print('>>> {0} -> {1}'.format(typepath,basename))
								foundTypes[basename]=line
							continue
						else:
							print('   {0}'.format(typepath))
					else:
						inType=False
			if inType and currentBase in foundTypes:
				foundTypes[currentBase]+=line

extractTypesFrom('subtypes.dm','/mob/living/carbon/metroid/')
extractTypesFrom('metroid.dm','/obj/item/metroid_core/')
			
for basename in foundTypes:
	#basename = typepath.split('/')[-1]
	with open('subtypes/'+basename+'.dm','w') as f:
		f.write(foundTypes[basename])