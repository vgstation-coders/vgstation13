var/list/clients = list()							//list of all clients
var/list/admins = list()							//list of all clients whom are admins
var/list/directory = list()							//list of all ckeys with associated client

//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

var/list/mixed_modes = list()							//Set when admins wish to force specific modes to be mixed

var/global/list/player_list = list()				//List of all mobs **with clients attached**. Excludes /mob/new_player
var/global/list/mob_list = list()					//List of all mobs, including clientless
var/global/list/living_mob_list = list()			//List of all alive mobs, including clientless. Excludes /mob/new_player
var/global/list/dead_mob_list = list()				//List of all dead mobs, including clientless. Excludes /mob/new_player
var/list/observers = new/list()
var/global/list/areas = list()
var/global/list/active_component_containers = list() 	//List of all component containers that have registered for updating

var/global/list/chemical_reactions_list				//list of all /datum/chemical_reaction datums. Used during chemical reactions
var/global/list/chemical_reagents_list				//list of all /datum/reagent datums indexed by reagent id. Used by chemistry stuff
var/global/list/landmarks_list = list()				//list of all landmarks created
var/global/list/surgery_steps = list()				//list of all surgery steps  |BS12
var/global/list/mechas_list = list()				//list of all mechs. Used by hostile mobs target tracking.

// Posters
var/global/list/datum/poster/poster_designs = typesof(/datum/poster) - /datum/poster - /datum/poster/goldstar

//Preferences stuff
	//Underwear
var/global/list/underwear_m = list("White", "Grey", "Green", "Blue", "Black", "Mankini", "Love-Hearts", "Black2", "Grey2", "Stripey", "Kinky", "Freedom", "Tea", "Communist", "None") //Curse whoever made male/female underwear diffrent colours
var/global/list/underwear_f = list("Red", "White", "Yellow", "Blue", "Black", "Thong", "Babydoll", "Baby-Blue", "Green", "Pink", "Kinky", "Freedom", "Communist", "Tea", "None")
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


var/list/rcd_list = list()
var/list/red_tool_list = list()
var/list/brig_lockers = list()
var/list/communications_circuitboards = list()
var/list/pinpointer_list = list()
var/list/crematorium_list = list()
var/list/tracking_implants = list()
var/list/chemical_implants = list()
var/list/mech_tracking_beacons = list()
var/list/mop_list = list()
var/list/mopbucket_list = list()
var/list/cleanbot_list = list()
var/list/janicart_list = list()
var/list/janikeys_list = list()
var/list/vehicle_list = list()
var/list/paicard_list = list()
var/list/effects_list = list()
