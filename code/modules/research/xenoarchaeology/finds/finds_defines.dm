var/static/list/digsite_types = list()
var/static/list/archaeo_types = list()

/proc/get_responsive_reagent(var/find_type)
	var/datum/find/F = archaeo_types[find_type]
	if(F)
		return F.responsive_reagent
	return PLASMA

//see /turf/unsimulated/mineral/New() in code/modules/mining/mine_turfs.dm
/proc/get_random_digsite_type()
	return pick(100;DIGSITE_GARDEN,95;DIGSITE_ANIMAL,90;DIGSITE_HOUSE,85;DIGSITE_TECHNICAL,80;DIGSITE_TEMPLE,75;DIGSITE_WAR)

/proc/get_random_find_type(var/digsite)
	var/datum/digsite/D = digsite_types[digsite]
	var/datum/find/F = archaeo_types[pick(D.find_types)]
	return F

/proc/get_random_find()
	return get_random_find_type(get_random_digsite_type())

var/list/responsive_carriers = list( \
	"carbon", \
	"potassium", \
	"hydrogen", \
	"nitrogen", \
	"mercury", \
	"iron", \
	"chlorine", \
	"phosphorus", \
	"plasma")

var/list/finds_as_strings = list( \
	"Trace organic cells", \
	"Long exposure particles", \
	"Trace water particles", \
	"Crystalline structures", \
	"Metallic derivative", \
	"Metallic composite", \
	"Metamorphic/igneous rock composite", \
	"Metamorphic/sedimentary rock composite", \
	"Anomalous material" )