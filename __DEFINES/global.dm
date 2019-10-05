/proc/writeglobal(var/which, var/what)
	global.vars[which] = what

/proc/readglobal(var/which)
	return global.vars[which]

#define DNA_SE_LENGTH 58

#define VOX_SHAPED "Vox","Skeletal Vox"
#define GREY_SHAPED "Grey"
#define UNATHI_SHAPED "Unathi"
#define SKRELL_SHAPED "Skrell"
#define TAJARAN_SHAPED "Tajaran"
#define PLASMAMAN_SHAPED "Plasmaman"
#define UNDEAD_SHAPED "Skellington","Undead","Plasmaman"
#define MUSHROOM_SHAPED "Mushroom"


//Content of the Round End Information window
var/round_end_info = ""

//List of ckeys that have de-adminned themselves during this round
var/global/list/deadmins = list()

//List of vars that require DEBUG on top of VAREDIT to be able to edit
var/list/lockedvars = list("vars", "client", "holder")

//List of vars that you can NEVER edit through VV itself
var/list/nevervars = list("step_x", "step_y", "step_size")

// List of types and how many instances of each type there are.
var/global/list/type_instances[0]

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

#define FIRE_DAMAGE_MODIFIER 0.0215 //Higher values result in more external fire damage to the skin (default 0.0215)
#define AIR_DAMAGE_MODIFIER 2.025 //More means less damage from hot air scalding lungs, less = more damage. (default 2.025)

	//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
#define MAX_MESSAGE_LEN 1024
#define MAX_PAPER_MESSAGE_LEN 3072
#define MAX_BOOK_MESSAGE_LEN 9216
#define MAX_NAME_LEN 26
#define MAX_BROADCAST_LEN		512

#define shuttle_time_in_station 1800 // 3 minutes in the station
#define shuttle_time_to_arrive 6000 // 10 minutes to arrive

	// MySQL configuration

var/sqladdress = "localhost"
var/sqlport = "3306"
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

//Database connections
//A connection is established on world creation. Ideally, the connection dies when the server restarts (After feedback logging.).
var/DBConnection/dbcon	//Feedback database (New database)
var/DBConnection/dbcon_old	//Tgstation database (Old database) - See the files in the SQL folder for information what goes where.

#define MIDNIGHT_ROLLOVER		864000	//number of deciseconds in a day

//Recall time limit:  2 hours
var/recall_time_limit = 72000

//Goonstyle scoreboard
//NOW AN ASSOCIATIVE LIST
//NO FUCKING EXCUSE FOR THE ATROCITY THAT WAS
var/list/score=list(
	"crewscore"      = 0, //This is the overall var/score for the whole round
	"stuffshipped"   = 0, //How many useful items have cargo shipped out? Currently broken
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
	"disease_good"        = 0, //How many unique diseases currently affecting living mobs of cumulated danger <3
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
)

var/list/trash_items = list()
var/list/decals = list()

// Mostly used for ban systems.
// Initialized on world/New()
var/global/event/on_login
var/global/event/on_ban
var/global/event/on_unban

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

var/global/list/achievements = list()

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

// ECONOMY
// Account default values
#define DEPARTMENT_START_FUNDS 500
#define DEPARTMENT_START_WAGE 50
#define PLAYER_START_WAGE 50

//HUD MINIMAPS
var/list/holoMiniMaps = list()
var/list/centcommMiniMaps = list()
var/list/extraMiniMaps = list()

var/list/holomap_markers = list()

var/holomaps_initialized = 0

//Staff of change
#define SOC_CHANGETYPE_COOLDOWN 2 MINUTES
#define SOC_MONKEY "Primate"
#define SOC_MARTIAN "Martian"
#define SOC_CYBORG "Robot"
#define SOC_MOMMI "MoMMI"
#define SOC_SLIME "Slime"
#define SOC_XENO "Xenomorph"
#define SOC_HUMAN "Human"
#define SOC_CATBEAST "Furry"
#define SOC_FRANKENSTEIN "Frankenstein"

var/list/available_staff_transforms = list(
	SOC_MONKEY,SOC_MARTIAN,
	SOC_CYBORG,
	SOC_SLIME,
	SOC_XENO,
	SOC_HUMAN,
	SOC_CATBEAST,
	SOC_FRANKENSTEIN
	)

//Broken mob list
var/list/blacklisted_mobs = list(
		/mob/living/simple_animal/space_worm,							// Unfinished. Very buggy, they seem to just spawn additional space worms everywhere and eating your own tail results in new worms spawning.
		/mob/living/simple_animal/hostile/humanoid,						// JUST DON'T DO IT, OK?
		/mob/living/simple_animal/hostile/retaliate/cockatrice,			// I'm just copying this from transmog.
		/mob/living/simple_animal/hostile/giant_spider/hunter/dead,		// They are dead.
		/mob/living/simple_animal/hostile/asteroid/hivelordbrood,		// They aren't supposed to be playable.
		/mob/living/simple_animal/hologram,								// Can't live outside the holodeck.
		/mob/living/simple_animal/hostile/carp/holocarp,				// These can but they're just a retarded hologram carp reskin for the love of god.
		/mob/living/slime_pile,											// They are dead.
		/mob/living/adamantine_dust, 									// Ditto
		/mob/living/simple_animal/hostile/viscerator,					// Nope.
		/mob/living/simple_animal/hostile/mining_drone,					// This thing is super broken in the hands of a player and it was never meant to be summoned out of actual mining drone cubes.
		/mob/living/simple_animal/bee,									// Aren't set up to be playable
		/mob/living/simple_animal/hostile/asteroid/goliath/david/dave,	// Isn't supposed to be spawnable by xenobio
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
	)

// Set by traitor item, affects cargo supplies
var/station_does_not_tip = FALSE

#define CARD_CAPTURE_SUCCESS 0 // Successful charge
#define CARD_CAPTURE_FAILURE_GENERAL 1 // General error
#define CARD_CAPTURE_FAILURE_NOT_ENOUGH_FUNDS 2 // Not enough funds in the account.
#define CARD_CAPTURE_ACCOUNT_DISABLED 3 // Account locked.
#define CARD_CAPTURE_ACCOUNT_DISABLED_MERCHANT 4 // Destination account disabled.
#define CARD_CAPTURE_FAILURE_BAD_ACCOUNT_PIN_COMBO 5 // Bad account/pin combo
#define CARD_CAPTURE_FAILURE_SECURITY_LEVEL 6 // Security level didn't allow current authorization or another exception occurred
#define CARD_CAPTURE_FAILURE_USER_CANCELED 7 // The user canceled the transaction
#define CARD_CAPTURE_FAILURE_NO_DESTINATION 8 // There was no linked account to send funds to.
#define CARD_CAPTURE_FAILURE_NO_CONNECTION 9 // Account database not available.

#define BANK_SECURITY_EXPLANATION {"Choose your bank account security level.
Vendors will try to subtract from your virtual wallet if possible.
If you're too broke, they'll try to access your bank account directly.
This setting decides how much info you have to enter to allow for that.
Zero; Only your account number is required to deduct funds.
One; Your account number and PIN are required.
Two; Your ID card, account number and PIN are required.
You can change this mid-game at an ATM."}

proc/bank_security_num2text(var/num)
	switch(num)
		if(0)
			return "Zero"
		if(1)
			return "One"
		if(2)
			return "Two"
		else
			return "OUT OF RANGE"

var/list/bank_security_text2num_associative = list(
	"Zero" = 0,
	"One" = 1,
	"Two" = 2
) // Can't use a zero. Throws a fit about out of bounds indices if you do.
// Also if you add more security levels, please also update the above BANK_SECURITY_EXPLANATION

//Radial menus currently existing in the world.
var/global/list/radial_menus = list()

// Copying atoms is stupid and this is a stupid solution
var/list/variables_not_to_be_copied = list(
	"type","loc","locs","vars","parent","parent_type","verbs","ckey","key",
	"group","on_login","on_ban","on_unban","on_pipenet_tick","on_item_added",
	"on_item_removed","on_moved","on_destroyed","on_density_change",
	"on_z_transition","on_use","on_emote","on_life","on_resist",
	"on_spellcast","on_uattack","on_ruattack","on_logout","on_damaged",
	"on_irradiate","on_death","on_clickon","on_attackhand","on_attackby",
	"on_explode","on_projectile","in_chamber","power_supply","contents",
	"x","y","z"
)

//Item lists
var/global/list/ties = list(/obj/item/clothing/accessory/tie/blue,/obj/item/clothing/accessory/tie/red,/obj/item/clothing/accessory/tie/horrible)