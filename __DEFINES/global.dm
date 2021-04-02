var/list/protected_global_vars = list(
	"sqlfdbklogin",
	"sqlfdbkpass",
	"sqlfdbkdb",
	"sqladdress",
	"sqlport",
	"sqllogin",
	"sqlpass",
	"sqlfdbkdb",

	"forbidden_varedit_object_types",
	"unviewable_varedit_object_types",
	"protected_global_vars", // Hhaha!
)

/proc/writeglobal(var/which, var/what)
	if (which in protected_global_vars)
		return "Cannot write variable."
	global.vars[which] = what

/proc/readglobal(var/which)
	if (which in protected_global_vars)
		return "Cannot read variable."
	return global.vars[which]


//Content of the Round End Information window
var/round_end_info = ""

//List of ckeys that have de-adminned themselves during this round
var/global/list/deadmins = list()

//List of vars that require DEBUG on top of VAREDIT to be able to edit
var/list/lockedvars = list("vars", "client", "holder", "step_x", "step_y", "step_size")

/var/global/datum/map/active/map = new() //Current loaded map
//Defined in its .dm, see maps/_map.dm for more info.

var/global/obj/effect/datacore/data_core = null
var/global/obj/effect/overlay/plmaster = null
var/global/obj/effect/overlay/slmaster = null

var/global/list/account_DBs = list()

// Used only by space turfs. TODO: Remove.
// The comment below is no longer accurate.
var/global/list/global_map = null

	//list/global_map = list(list(1,5),list(4,3))//an array of map Z levels.
	//Resulting sector map looks like
	//|_1_|_4_|
	//|_5_|_3_|
	//
	//1 - SS13
	//4 - Derelict
	//3 - AI satellite
	//5 - empty space

var/global/datum/universal_state/universe = new

var/list/paper_tag_whitelist = list("center","p","div","span","h1","h2","h3","h4","h5","h6","hr","pre",	\
	"big","small","font","i","u","b","s","sub","sup","tt","br","hr","ol","ul","li","caption","col",	\
	"table","td","th","tr")
var/list/paper_blacklist = list("java","onblur","onchange","onclick","ondblclick","onfocus","onkeydown",	\
	"onkeypress","onkeyup","onload","onmousedown","onmousemove","onmouseout","onmouseover",	\
	"onmouseup","onreset","onselect","onsubmit","onunload")

var/eventchance = 10 //% per 5 mins
var/event = 0
var/hadevent = 0
var/blobevent = 0
	///////////////
var/starticon = null
var/midicon = null
var/endicon = null
var/diary = null
var/diaryofmeanpeople = null
var/admin_diary = null
var/station_name = null
var/game_version = "veegee"
var/changelog_hash = ""
var/game_year = (text2num(time2text(world.realtime, "YYYY")) + 544)

var/going = 1.0
var/master_mode = "extended"//"extended"
var/secret_force_mode = "secret" // if this is anything but "secret", the secret rotation will forceably choose this mode

var/host = null
var/aliens_allowed = 1
var/ooc_allowed = 1
var/looc_allowed = 1
var/dooc_allowed = 1
var/traitor_scaling = 1
var/abandon_allowed = 1
var/enter_allowed = 1
var/guests_allowed = 1
var/tinted_weldhelh = 1

var/list/bombers = list(  )
var/list/admin_log = list (  )
var/list/lawchanges = list(  ) //Stores who uploaded laws to which silicon-based lifeform, and what the law was
var/list/shuttles = list(  )
var/list/reg_dna = list(  )

var/CELLRATE = 0.002  // multiplier for watts per tick <> cell storage (eg: .002 means if there is a load of 1000 watts, 20 units will be taken from a cell per second)
var/CHARGELEVEL = 0.001 // Cap for how fast cells charge, as a percentage-per-tick (.001 means cellcharge is capped to 1% per second)

// COORDINATE OFFSETS
// Used for telescience.  Only apply to GPSes and other things that display coordinates to players.
// The idea is that coordinates given will be entirely different from those displayed on the map in DreamMaker,
//  while still making it very simple to lock onto someone who is drifting in space.
var/list/WORLD_X_OFFSET = list()
var/list/WORLD_Y_OFFSET = list()

var/shuttle_z = map.zCentcomm	//default
var/airtunnel_start = 68 // default
var/airtunnel_stop = 68 // default
var/airtunnel_bottom = 72 // default
var/list/monkeystart = list()
var/list/wizardstart = list()
var/list/grinchstart = list()
var/list/newplayer_start = list()
var/list/latejoin = list()
var/list/assistant_latejoin = list()
var/list/prisonwarp = list()	//prisoners go to these
var/list/holdingfacility = list()	//captured people go here
var/list/xeno_spawn = list()//Aliens spawn at these.
var/list/endgame_safespawns = list()
var/list/endgame_exits = list()
var/list/tdome1 = list()
var/list/tdome2 = list()
var/list/tdomeobserve = list()
var/list/tdomeadmin = list()
var/list/prisonsecuritywarp = list()	//prison security goes to these
var/list/prisonwarped = list()	//list of players already warped
var/list/blobstart = list()
var/list/ninjastart = list()
var/list/prisonerstart = list()
var/list/voxstart = list() //Vox raider spawn points
var/list/voxlocker = list() //Vox locker spawn points
//	list/traitors = list()	//traitor list
var/list/cardinal = list( NORTH, SOUTH, EAST, WEST )
var/list/diagonal = list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
var/list/alldirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)

var/global/universal_cult_chat = 0 //if set to 1, even human cultists can use cultchat

var/datum/station_state/start_state = null
var/datum/configuration/config = null

var/suspend_alert = 0

var/Debug = 0	// global debug switch
var/Debug2 = 0

var/datum/debug/debugobj

var/datum/moduletypes/mods = new()

var/gravity_is_on = 1

var/join_motd = null

var/polarstar = 0 //1 means that the polar star has been found, 2 means that the spur modification kit has been found

// nanomanager, the manager for Nano UIs
var/datum/nanomanager/nanomanager = new()

	// MySQL configuration

var/sqladdress = "localhost"
var/sqlport = 3306
var/sqldb = "tgstation"
var/sqllogin = "root"
var/sqlpass = ""

	// Feedback gathering sql connection

var/sqlfdbkdb = "test"
var/sqlfdbklogin = "root"
var/sqlfdbkpass = ""

var/sqllogging = 0 // Should we log deaths, population stats, etc?



	// Forum MySQL configuration (for use with forum account/key authentication)
	// These are all default values that will load should the forumdbconfig.txt
	// file fail to read for whatever reason.

var/forumsqladdress = "localhost"
var/forumsqlport = "3306"
var/forumsqldb = "tgstation"
var/forumsqllogin = "root"
var/forumsqlpass = ""
var/forum_activated_group = "2"
var/forum_authenticated_group = "10"

	// For FTP requests. (i.e. downloading runtime logs.)
	// However it'd be ok to use for accessing attack logs and such too, which are even laggier.
var/fileaccess_timer = 0
var/custom_event_msg = null

//Recall time limit:  2 hours
var/recall_time_limit = 72000

//Goonstyle scoreboard
//NOW AN ASSOCIATIVE LIST
//NO FUCKING EXCUSE FOR THE ATROCITY THAT WAS
var/list/score=list(
	"crewscore"      = 0, //This is the overall var/score for the whole round
	"plasmashipped"   = 0,//How much plasma has been sent to centcom?
	"stuffshipped"   = 0, //How many centcom orders have cargo fulfilled?
	"stuffharvested" = 0, //How many harvests have hydroponics done (per crop)?
	"oremined"       = 0, //How many chunks of ore were smelted
	"eventsendured"  = 0, //How many random events did the station endure?
	"powerloss"      = 0, //How many APCs have alarms (under 30 %)?
	"maxpower"       = 0, //Most watts in grid on any of the world's powergrids.
	"escapees"       = 0, //How many people got out alive?
	"deadcrew"       = 0, //Humans who died during the round
	"deadsilicon"	 = 0, //Silicons who died during the round
	"mess"           = 0, //How much messes on the floor went uncleaned
	"litter"		 = 0, //How much trash is laying on the station floor
	"meals"          = 0, //How much food was actively cooked that day
	"artifacts"      = 0, //How many large artifacts were analyzed and activated
	"disease_good"        = 0, //How many unique diseases currently affecting living mobs of cumulated danger <3
	"disease_vaccine"	= null, //Which many vaccine antibody isolated
	"disease_vaccine_score"	= 0, //the associated score
	"disease_extracted"	= 0, //Score based on the unique extracted effects
	"disease_effects"	= 0, //Score based on the unique extracted effects
	"disease_bad"        = 0, //How many unique diseases currently affecting living mobs of cumulated danger >= 3
	"disease_most"        = null, //Most spread disease
	"disease_most_count"        = 0, //Most spread disease

	//These ones are mainly for the stat panel
	"powerbonus"    = 0, //If all APCs on the station are running optimally, big bonus
	"messbonus"     = 0, //If there are no messes on the station anywhere, huge bonus
	"deadaipenalty" = 0, //AIs who died during the round
	"foodeaten"     = 0, //How much food was consumed
	"clownabuse"    = 0, //How many times a clown was punched, struck or otherwise maligned
	"slips"			= 0, //How many people have slipped during this round
	"gunsspawned"	= 0, //Guns spawned by the Summon Guns spell. Only guns, not other artifacts.
	"dimensionalpushes" = 0, //Amount of times a wizard casted Dimensional Push.
	"assesblasted"  = 0, //Amount of times a wizard casted Buttbot's Revenge.
	"shoesnatches"  = 0, //Amount of shoes magically snatched.
	"greasewiz"     = 0, //Amount of times a wizard casted Grease.
	"lightningwiz"  = 0, //Amount of times a wizard casted Lighting.
	"random_soc"    = 0, //Staff of Change bolts set to "random" that hit a human.
	"heartattacks"  = 0, //Amount of times the "Heart Attack" virus reached final stage, unleashing a hostile floating heart.
	"richestname"   = null, //This is all stuff to show who was the richest alive on the shuttle
	"richestjob"    = null,  //Kinda pointless if you dont have a money system i guess
	"richestcash"   = 0,
	"richestkey"    = null,
	"dmgestname"    = null, //Who had the most damage on the shuttle (but was still alive)
	"dmgestjob"     = null,
	"dmgestdamage"  = 0,
	"dmgestkey"     = null,
	"explosions"	= 0, //How many explosions happened total
	"deadpets"		= 0, //Only counts 'special' simple_mobs, like Ian, Poly, Runtime, Sasha etc
	"buttbotfarts"  = 0, //Messages mimicked by buttbots.
	"turfssingulod" = 0, //Amount of turfs eaten by singularities.
	"shardstouched" = 0, //+1 for each pair of shards that bump into eachother.
	"kudzugrowth"   = 0, //Amount of kudzu tiles successfully grown, even if they were later eradicated.
	"nukedefuse"	= 9999, //Seconds the nuke had left when it was defused.
	"tobacco"        = 0, //Amount of cigarettes, pipes, cigars, etc. lit
	"lawchanges"	 = 0, //Amount of AI modules used.


	"arenafights"   = 0,
	"arenabest"		= null,

	"money_leaderboard" = list(),
)

var/list/isolated_antibodies = list(
	ANTIGEN_O	= 0,
	ANTIGEN_A	= 0,
	ANTIGEN_B	= 0,
	ANTIGEN_RH	= 0,
	ANTIGEN_Q	= 0,
	ANTIGEN_U	= 0,
	ANTIGEN_V	= 0,
	ANTIGEN_M	= 0,
	ANTIGEN_N	= 0,
	ANTIGEN_P	= 0,
	ANTIGEN_X	= 0,
	ANTIGEN_Y	= 0,
	ANTIGEN_Z	= 0,
	)
var/list/extracted_gna = list()

var/list/trash_items = list()
var/list/decals = list()

// Space get this to return for things i guess?
var/global/datum/gas_mixture/space_gas = new

//Announcement intercom
var/global/obj/item/device/radio/intercom/universe/announcement_intercom = new

//used by jump-to-area etc. Updated by area/updateName()
var/list/sortedAreas = list()

var/global/bomberman_mode = 0
var/global/bomberman_hurt = 0
var/global/bomberman_destroy = 0

var/global/list/volunteer_gladiators = list()
var/global/list/ready_gladiators = list()
var/global/list/never_gladiators = list()

//icons that appear on the Round End pop-up browser
var/global/list/end_icons = list()

var/global/list/arena_leaderboard = list()
var/arena_rounds = 0
var/arena_top_score = 0

var/endgame_info_logged = 0

var/explosion_newmethod = 1	// 1 = explosions take walls and obstacles into account; 0 = explosions pass through walls and obstacles without any impediments;

//PDA games vars
//Snake II leaderboard
var/global/list/snake_station_highscores = list()
var/global/list/snake_best_players = list()

//Minesweeper leaderboard
var/global/list/minesweeper_station_highscores = list()
var/global/list/minesweeper_best_players = list()

var/nanocoins_rates = 1
var/nanocoins_lastchange = 0

var/minimapinit = 0

var/list/bees_species = list()

var/datum/stat_collector/stat_collection = new

//Hardcore mode
//When enabled, starvation kills
var/global/hardcore_mode = 0

//Global list of all unsimulated mineral turfs for xenoarch
var/global/list/mineral_turfs = list()
var/global/list/static_list = list('sound/effects/static/static1.ogg','sound/effects/static/static2.ogg','sound/effects/static/static3.ogg','sound/effects/static/static4.ogg','sound/effects/static/static5.ogg',)

//Used to set an atom's color var to "grayscale". The magic of color matrixes.
var/list/grayscale = list(0.3,0.3,0.3,0,0.59,0.59,0.59,0,0.11,0.11,0.11,0,0,0,0,1,0,0,0,0)

//For adminbus blob looks
var/adminblob_icon = null
var/adminblob_size = 64
var/adminblob_beat = 'sound/effects/blob_pulse.ogg'

//HUD MINIMAPS
var/list/holoMiniMaps = list()
var/list/centcommMiniMaps = list()
var/list/extraMiniMaps = list()

var/list/holomap_markers = list()

var/holomaps_initialized = 0

//Broken mob list
var/list/blacklisted_mobs = list(
		/mob/living/simple_animal/space_worm,							// Unfinished. Very buggy, they seem to just spawn additional space worms everywhere and eating your own tail results in new worms spawning.
		/mob/living/simple_animal/hostile/humanoid,						// JUST DON'T DO IT, OK?
		/mob/living/simple_animal/hostile/retaliate/cockatrice,			// I'm just copying this from transmog.
		/mob/living/simple_animal/hostile/giant_spider/hunter/dead,		// They are dead.
		/mob/living/simple_animal/hostile/asteroid/hivelordbrood,		// Your motherfucking life ends in 5 seconds.
		/mob/living/simple_animal/hologram,								// Can't live outside the holodeck.
		/mob/living/simple_animal/hostile/carp/holocarp,				// These can but they're just a retarded hologram carp reskin for the love of god.
		/mob/living/slime_pile,											// They are dead.
		/mob/living/adamantine_dust, 									// Ditto
		/mob/living/simple_animal/hostile/viscerator,					// Nope.
		/mob/living/simple_animal/hostile/mining_drone,					// This thing is super broken in the hands of a player and it was never meant to be summoned out of actual mining drone cubes.
		/mob/living/simple_animal/bee,									// Aren't set up to be playable
		/mob/living/simple_animal/hostile/asteroid/goliath/david/dave,	// Isn't supposed to be spawnable by xenobio
		/mob/living/simple_animal/hostile/bunnybot,						// See viscerator
		/mob/living/carbon/human/NPC,									// Unfinished, with its own AI that conflicts with player movements.
		)

//Boss monster list
var/list/boss_mobs = list(
	/mob/living/simple_animal/scp_173,								// Just a statue.
	/mob/living/simple_animal/hostile/hivebot/tele,					// Hivebot spawner WIP thing
	/mob/living/simple_animal/hostile/wendigo,						// Stupid strong evolving creature things that scream for help
	/mob/living/simple_animal/hostile/mechahitler,					// Sieg heil!
	/mob/living/simple_animal/hostile/alien/queen/large,			// The bigger and beefier version of queens.
	/mob/living/simple_animal/hostile/asteroid/rockernaut/boss, 	// Angie
	/mob/living/simple_animal/hostile/humanoid/surgeon/boss, 		// First stage of Doctor Placeholder
	/mob/living/simple_animal/hostile/humanoid/surgeon/skeleton,	// Second stage of Doctor Placeholder
	/mob/living/simple_animal/hostile/roboduck,						// The bringer of the end times
	/mob/living/simple_animal/hostile/bear/spare,					// Captain bear
	/mob/living/simple_animal/hostile/ginger/gingerbroodmother		// Gingerbominations...
	)

// Set by traitor item, affects cargo supplies
var/station_does_not_tip = FALSE

//Set by Malf AI Blackout
var/malf_radio_blackout = FALSE
var/malf_rcd_disable = FALSE

//Cyborg killswitch time. If set at a time other than zero, cyborgs will self destruct at that time
var/cyborg_detonation_time = 0


//Radial menus currently existing in the world.
var/global/list/radial_menus = list()

// Copying atoms is stupid and this is a stupid solution
var/list/variables_not_to_be_copied = list(
	"type","loc","locs","vars","parent","parent_type","verbs","ckey","key",
	"group","registered_events",
	"on_attackby",
	"on_explode","on_projectile","in_chamber","power_supply","contents",
	"x","y","z"
)

//Item lists
var/global/list/ties = list(/obj/item/clothing/accessory/tie/blue,/obj/item/clothing/accessory/tie/red,/obj/item/clothing/accessory/tie/horrible,/obj/item/clothing/accessory/tie/bolo)

//Observers
var/global_poltergeist_cooldown = 300 //30s by default, badmins can var-edit this to reduce the poltergeist cooldown globally

var/list/all_machines = list()
var/list/machinery_rating_cache = list() // list of type path -> number
