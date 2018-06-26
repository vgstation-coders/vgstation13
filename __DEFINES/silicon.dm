//Global list of all Cyborg/MoMMI modules.
var/global/list/robot_modules = list(
	"Standard"		= /obj/item/weapon/robot_module/standard,
	"Service" 		= /obj/item/weapon/robot_module/butler,
	"Supply" 		= /obj/item/weapon/robot_module/miner,
	"Medical" 		= /obj/item/weapon/robot_module/medical,
	"Security" 		= /obj/item/weapon/robot_module/security,
	"Engineering"	= /obj/item/weapon/robot_module/engineering,
	"Janitor" 		= /obj/item/weapon/robot_module/janitor,
	"Combat" 		= /obj/item/weapon/robot_module/combat,
	"Syndicate"		= /obj/item/weapon/robot_module/syndicate,
	"TG17355"		= /obj/item/weapon/robot_module/tg17355
    )

var/global/list/mommi_modules = list(
	"Nanotrasen"    = /obj/item/weapon/robot_module/mommi/nt,
	"Soviet" 	    = /obj/item/weapon/robot_module/mommi/soviet,
	"Gravekeeper"	= /obj/item/weapon/robot_module/mommi/cogspider
	)

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

#define MOMMI_SOVIET_SPEED_MODIFIER 1
#define MOMMI_NT_SPEED_MODIFIER 1
#define COGSPIDER_SPEED_MODIFIER 2

#define SILICON_MOBILITY_MODULE_SPEED_MODIFIER 0.75 //Silicon's speed var is multiplied by the mobility module modifier
#define SILICON_VTEC_SPEED_BONUS 0.25 //But the VTEC Bonus is ADDED to their movement_speed_modifier

//Bitflags for module quirks
#define MODULE_CAN_BE_PUSHED 1
#define MODULE_CAN_HANDLE_MEDICAL 2
#define MODULE_CAN_HANDLE_CHEMS 4
#define MODULE_CAN_HANDLE_FOOD 8
#define MODULE_CAN_BUY 16
#define MODULE_CLEAN_ON_MOVE 32
#define MODULE_HAS_MAGPULSE 64
#define MODULE_IS_THE_LAW 128
#define MODULE_CAN_LIFT_SECTAPE 256
#define MODULE_CAN_LIFT_ENGITAPE 512
