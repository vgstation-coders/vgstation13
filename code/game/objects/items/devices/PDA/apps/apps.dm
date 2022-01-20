///PDA apps by Deity Link///
#define PDA_APP_ALARM			1
#define PDA_APP_RINGER			2
#define PDA_APP_SPAMFILTER		3
#define PDA_APP_BALANCECHECK	4
#define PDA_APP_STATIONMAP		5
#define PDA_APP_NEWSREADER		6
#define PDA_APP_NOTEKEEPER		7

#define PDA_APP_SNAKEII			101
#define PDA_APP_MINESWEEPER		102
#define PDA_APP_SPESSPETS		103

#define NEWSREADER_CHANNEL_LIST	0
#define NEWSREADER_VIEW_CHANNEL	1
#define NEWSREADER_WANTED_SHOW	2

/datum/pda_app
	var/name = "Template Application"
	var/desc = "Template Description"
	var/category = "General Functions" //for category building
	var/price = 10
	var/menu = TRUE //set it to false if your app doesn't need its own menu on the PDA
	var/has_screen = TRUE
	var/obj/item/device/pda/pda_device = null
	var/icon = null	//name of the icon that appears in front of the app name on the PDA, example: "pda_game.png"
	var/no_refresh = 0
	var/can_purchase = TRUE //if this can be bought from a PDA terminal
	var/assets_type = null //for asset sending

/datum/pda_app/proc/onInstall(var/obj/item/device/pda/device)
	if(istype(device))
		pda_device = device
		pda_device.applications += src
		if(!(category in pda_device.categorised_applications))
			pda_device.categorised_applications[category] = list() //Creates the associative list for this if it doesn't exist.
		pda_device.categorised_applications[category] += src //Adds this app to the appropriate category if it does.

/datum/pda_app/proc/get_dat()
	return ""

/datum/pda_app/Topic(href, href_list)
	if(..())
		return TRUE

	var/mob/living/U = usr

	if (!pda_device.can_use(U)) //From PDA, double check here
		U.unset_machine()
		U << browse(null, "window=pda")
		return TRUE

	pda_device.add_fingerprint(U)
	U.set_machine(pda_device)

/datum/pda_app/proc/refresh_pda()
	if(!no_refresh)
		if(usr.machine == pda_device)
			pda_device.attack_self(usr)
		else
			usr.unset_machine()
			usr << browse(null, "window=pda")
	else
		no_refresh = 0

/datum/pda_app/Destroy()
	if(pda_device.applications)
		pda_device.applications -= src
	pda_device = null
	..()

/datum/pda_app/game
	category = "Games"