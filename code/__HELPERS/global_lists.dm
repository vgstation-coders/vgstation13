var/list/clients = list()							//list of all clients
var/list/admins = list()							//list of all clients whom are admins
var/list/directory = list()							//list of all ckeys with associated client

//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

var/list/mixed_modes = list()							//Set when admins wish to force specific modes to be mixed

var/global/list/player_list = list()				//List of all mobs **with clients attached**. Excludes /mob/new_player
var/global/list/mob_list = list()					//List of all mobs, including clientless
var/global/list/living_mob_list = list()			//List of all alive mobs, including clientless. Excludes /mob/new_player
var/global/list/cyborg_list = list()						//List of all living cyborgs, including clientless cyborgs and mommis
var/global/list/dead_mob_list = list()				//List of all dead mobs, including clientless. Excludes /mob/new_player
var/list/observers = new/list()
var/global/list/areas = list()
var/global/list/active_components = list() 	//List of all components that have registered for updating

var/global/list/chemical_reactions_list				//list of all /datum/chemical_reaction datums. Used during chemical reactions
var/global/list/datum/reagent/chemical_reagents_list	//list of all /datum/reagent datums indexed by reagent id. Used by chemistry stuff
var/global/list/landmarks_list = list()				//list of all landmarks created
var/global/list/surgery_steps = list()				//list of all surgery steps  |BS12
var/global/list/mechas_list = list()				//list of all mechs. Used by hostile mobs target tracking.

//Preferences stuff
	//Underwear
var/global/list/underwear_m = list("None", "White Briefs", "Green Briefs", "Blue Briefs", "Black Briefs", "Grey Briefs", "Mankini", "Love-Hearts Boxers", "Black Boxers", "Grey Boxers", "Stripey Boxers", "Kinky", "Freedom Boxers", "Tea Boxers", "Communist Boxers", "Cowprint Boxers", "Green Wifebeater", "White Wifebeater", "Black Wifebeater") //Curse whoever made male/female underwear different colours
var/global/list/underwear_f = list("None", "White", "Green", "Blue", "Black", "Yellow", "Thong", "Baby-Blue", "Babydoll", "Red", "Pink", "Kinky", "Freedom", "Tea", "Communist", "Cowprint", "Pink Husbandbeater", "White Husbandbeater", "Black Husbandbeater")
	//Backpacks
var/global/list/backbaglist = list("Nothing", "Backpack", "Satchel", "Satchel Alt", "Messenger Bag")

// This is stupid as fuck.
var/list/hit_appends = list("-OOF", "-ACK", "-UGH", "-HRNK", "-HURGH", "-GLORF")
var/list/epilepsy_appends = list("-HRNK", "-HURGH", "-ABLRGH", "-GLORF", "-BLARGH")

//*-hud user lists
var/global/list/table_recipes = list() //list of all table craft recipes
var/global/list/med_hud_users = list() //list of all entities using a medical HUD.
var/global/list/sec_hud_users = list() //list of all entities using a security HUD.
var/list/diagnostic_hud_users = list() // list of all entities using a diagnostic HUD.
var/list/wage_hud_users = list() // list of all entities using a wage HUD.

//Lists for things that make various sounds
var/global/list/comfyfire = list('sound/misc/comfyfire1.ogg','sound/misc/comfyfire2.ogg','sound/misc/comfyfire3.ogg') //list of sounds a fire makes

//fuel list
var/global/list/possible_fuels = list(
	PLASMA = list(
			"max_temperature" = TEMPERATURE_PLASMA,
			"thermal_energy_transfer" = 27000,
			"consumption_rate" = 0.02,
			"o2_cons" = 0.01,
			"co2_cons" = 0,
			"unsafety" = 0),
	GLYCEROL = list(
			"max_temperature" = 1833.15,
			"thermal_energy_transfer" = 18000,
			"consumption_rate" = 0.05,
			"o2_cons" = 0.05,
			"co2_cons" = -0.025,
			"unsafety" = 5),
	FUEL = list(
			"max_temperature" = TEMPERATURE_WELDER,
			"thermal_energy_transfer" = 16200,
			"consumption_rate" = 0.1,
			"o2_cons" = 0.2,
			"co2_cons" = -0.2,
			"unsafety" = 25),
	ETHANOL = list(
			"max_temperature" = 1833.15,
			"thermal_energy_transfer" = 11700,
			"consumption_rate" = 0.1,
			"o2_cons" = 0.08,
			"co2_cons" = -0.04,
			"unsafety" = 10))

//////////////////////////
/////Initial Building/////
//////////////////////////

/proc/make_datum_references_lists()
	var/list/paths
	//Surgery Steps - Initialize all /datum/surgery_step into a list
	paths = typesof(/datum/surgery_step)-/datum/surgery_step
	for(var/T in paths)
		var/datum/surgery_step/S = new T
		surgery_steps += S
	sort_surgeries()

	for(var/path in subtypesof(/datum/emote))
		var/datum/emote/E = new path()
		E.emote_list[E.key] = E

	for(var/path in subtypesof(/datum/rogan_sound))
		var/datum/rogan_sound/S = new path()
		number2rogansound[S.number] = S

/* // Uncomment to debug chemical reaction list.
/client/verb/debug_chemical_list()


	for (var/reaction in chemical_reactions_list)
		. += "chemical_reactions_list\[\"[reaction]\"\] = \"[chemical_reactions_list[reaction]]\"\n"
		if(islist(chemical_reactions_list[reaction]))
			var/list/L = chemical_reactions_list[reaction]
			for(var/t in L)
				. += "    has: [t]\n"
	to_chat(world, .)
*/

var/global/list/escape_list = list()
var/list/bots_list = list()

var/list/radio_list = list()
var/list/rcd_list = list()
var/list/red_tool_list = list()
var/list/brig_lockers = list()
var/list/communications_circuitboards = list()
var/list/pinpointer_list = list()
var/list/crematorium_list = list()
var/list/tracking_implants = list()
var/list/chemical_implants = list()
var/list/remote_implants = list()
var/list/mech_tracking_beacons = list()
var/list/mop_list = list()
var/list/mopbucket_list = list()
var/list/cleanbot_list = list()
var/list/janicart_list = list()
var/list/janikeys_list = list()
var/list/vehicle_list = list()
var/list/paicard_list = list()
var/list/effects_list = list()
var/list/laser_pointers_list = list()
var/list/obj/structure/morgue/morgue_list = list()
var/list/obj/effect/time_anomaly/time_anomaly_list = list()
var/list/map_pickspawners = list()
