//Cyborg modules
#define STANDARD_MODULE "Standard"
#define SERVICE_MODULE "Service"
#define SUPPLY_MODULE "Supply"
#define MEDICAL_MODULE "Medical"
#define SECURITY_MODULE "Security"
#define ENGINEERING_MODULE "Engineering"
#define JANITOR_MODULE "Janitor"
#define COMBAT_MODULE "Combat"
#define SYNDIE_BLITZ_MODULE "Syndicate Blitzkrieg"
#define SYNDIE_CRISIS_MODULE "Syndicate Crisis"
#define HUG_MODULE "TG17355"
#define STARMAN_MODULE "Starman"

//MoMMI modules
#define NANOTRASEN_MOMMI "Nanotrasen"
#define SOVIET_MOMMI "Soviet"
#define GRAVEKEEPER_MOMMI "Gravekeeper"

var/global/list/default_nanotrasen_robot_modules = list(
	STANDARD_MODULE			= /obj/item/weapon/robot_module/standard,
	SERVICE_MODULE			= /obj/item/weapon/robot_module/butler,
	SUPPLY_MODULE 			= /obj/item/weapon/robot_module/miner,
	MEDICAL_MODULE			= /obj/item/weapon/robot_module/medical,
	SECURITY_MODULE			= /obj/item/weapon/robot_module/security,
	ENGINEERING_MODULE		= /obj/item/weapon/robot_module/engineering,
	JANITOR_MODULE			= /obj/item/weapon/robot_module/janitor,
    )

var/global/list/emergency_nanotrasen_robot_modules = list(
	COMBAT_MODULE 			= /obj/item/weapon/robot_module/combat
	)

var/global/list/syndicate_robot_modules = list(
	SYNDIE_BLITZ_MODULE		= /obj/item/weapon/robot_module/syndicate/blitzkrieg,
	SYNDIE_CRISIS_MODULE	= /obj/item/weapon/robot_module/syndicate/crisis,
    )

var/global/list/special_robot_modules = list(
	HUG_MODULE				= /obj/item/weapon/robot_module/tg17355,
	STARMAN_MODULE			= /obj/item/weapon/robot_module/starman
    )

var/global/list/mommi_modules = list(
	NANOTRASEN_MOMMI   		= /obj/item/weapon/robot_module/mommi/nt,
	SOVIET_MOMMI 	    	= /obj/item/weapon/robot_module/mommi/soviet,
	GRAVEKEEPER_MOMMI		= /obj/item/weapon/robot_module/mommi/cogspider
	)

//Global list of all Cyborg/MoMMI modules. If you add a new list and forget to add it to this one i'll fucking break your neck.
var/global/list/all_robot_modules = default_nanotrasen_robot_modules + emergency_nanotrasen_robot_modules + syndicate_robot_modules + special_robot_modules + mommi_modules

/proc/getAvailableRobotModules()
	var/list/pickable_modules = default_nanotrasen_robot_modules.Copy()
	if(security_level == SEC_LEVEL_RED)
		pickable_modules += emergency_nanotrasen_robot_modules
	return pickable_modules


//Module quirks
#define MODULE_CAN_BE_PUSHED 1			//What says on the tin.
#define MODULE_CAN_HANDLE_MEDICAL 2		//Can use medbay's machinery
#define MODULE_CAN_HANDLE_CHEMS 4		//Can use chemistry dispensers
#define MODULE_CAN_HANDLE_FOOD 8		//Can use microwaves and bartending machinery
#define MODULE_CAN_BUY 16				//Can use vending machines that need money(uses the station's account to pay)
#define MODULE_CLEAN_ON_MOVE 32			//Will clean everything under it while moving
#define MODULE_HAS_MAGPULSE 64			//Module isn't pushed b ZAS nor can slip in space
#define MODULE_IS_THE_LAW 128			//Module can use *law and *halt
#define MODULE_CAN_LIFT_SECTAPE 256		//Can lift security tape
#define MODULE_CAN_LIFT_ENGITAPE 512	//Can lift atmos/engi tape
#define MODULE_IS_A_CLOWN 1024			//Can handle clown-only items/machinery
#define MODULE_IS_DEFINITIVE 2048		//Can't get a module reset
#define MODULE_HAS_PROJ_RES 4096		//Doesn't slow down from being hit by boolets
#define MODULE_HAS_FLASH_RES 8192		//Recovers from being flashed twice as fast.
#define MODULE_IS_FLASHPROOF 16384		//Flashes do nothing.

#define HAS_MODULE_QUIRK(R, Q) (R.module && (R.module.quirk_flags & Q))

// Cyborgs & MoMMI defines
#define CYBORG_STARTING_TONER 40
#define CYBORG_MAX_TONER 100
#define CYBORG_PHOTO_COST 20

//Respawnable defines
#define MEDICAL_MAX_KIT 10
#define STANDARD_MAX_KIT 15
#define SUPPLY_MAX_WRAP 24
#define ENGINEERING_MAX_COIL 50
#define MOMMI_MAX_COIL 50

//Speed-related defines
#define SILICON_NO_CHARGE_SLOWDOWN 1.4
#define SILICON_NO_CELL_SLOWDOWN 15

#define CYBORG_ENGINEERING_SPEED_MODIFIER 1
#define CYBORG_MEDICAL_SPEED_MODIFIER 1
#define CYBORG_SYNDICATE_SPEED_MODIFIER 1
#define CYBORG_SUPPLY_SPEED_MODIFIER 1
#define CYBORG_JANITOR_SPEED_MODIFIER 1
#define CYBORG_COMBAT_SPEED_MODIFIER 1
#define CYBORG_STANDARD_SPEED_MODIFIER 1
#define CYBORG_SERVICE_SPEED_MODIFIER 1
#define CYBORG_SECURITY_SPEED_MODIFIER 1
#define CYBORG_TG17355_SPEED_MODIFIER 1
#define CYBORG_STARMAN_SPEED_MODIFIER 1

#define MOMMI_SOVIET_SPEED_MODIFIER 1
#define MOMMI_NT_SPEED_MODIFIER 1
#define COGSPIDER_SPEED_MODIFIER 2

#define SILICON_MOBILITY_MODULE_SPEED_MODIFIER 0.75 //Silicon's speed var is multiplied by the mobility module modifier
#define SILICON_VTEC_SPEED_BONUS 0.25 //But the VTEC Bonus is ADDED to their movement_speed_modifier

#define SILICON_TASER_SLOWDOWN_DURATION 18 SECONDS
#define SILICON_TASER_SLOWDOWN_MULTIPLIER 4

#define SILICON_HIGH_DAMAGE_SLOWDOWN_THRESHOLD 30
#define SILICON_HIGH_DAMAGE_SLOWDOWN_DURATION 3 SECONDS
#define SILICON_HIGH_DAMAGE_SLOWDOWN_MULTIPLIER SILICON_TASER_SLOWDOWN_MULTIPLIER
