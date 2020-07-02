var/list/digsite_types = list()
var/list/archaeo_types = list()
/proc/get_random_digsite_type()
	var/value = pick(100;DIGSITE_GARDEN,95;DIGSITE_ANIMAL,90;DIGSITE_HOUSE,85;DIGSITE_TECHNICAL,80;DIGSITE_TEMPLE,75;DIGSITE_WAR)
	return digsite_types[value]

/proc/get_random_find_type(var/digsite)

	var/datum/digsite/D
	if(istype(digsite, /datum/digsite))
		D = digsite
	else
		D = digsite_types[digsite]
	var/find = archaeo_types[pick(D.find_types)]
	var/datum/find/F = new find
	return F

/proc/get_random_find()
	return get_random_find_type(get_random_digsite_type())

var/list/responsive_carriers = list(
	"carbon", \
	"potassium", \
	"hydrogen", \
	"nitrogen", \
	"mercury", \
	"iron", \
	"chlorine", \
	"phosphorus", \
	"plasma")

var/list/finds_as_strings = list(
	CARBON = "Trace organic cells",
	POTASSIUM = "Long exposure particles",
	HYDROGEN = "Trace water particles",
	NITROGEN = "Crystalline structures",
	MERCURY = "Metallic derivative",
	IRON = "Metallic composite",
	CHLORINE = "Metamorphic/igneous rock composite",
	PHOSPHORUS = "Metamorphic/sedimentary rock composite",
	PLASMA = "Anomalous material" )

var/list/color_from_find_reagent = list(
	CARBON = "#008000",
	POTASSIUM = "#FFC0CB",
	HYDROGEN = "#FF0000",
	NITROGEN = "#AFEEEE",
	MERCURY = "#484848",
	IRON = "#b7410e",
	CHLORINE = "#ffff00",
	PHOSPHORUS = "#00ff00",
	PLASMA = "#500064",
	)