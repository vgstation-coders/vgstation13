///PDA apps by Deity Link, actual dat being held by them with Topic() on_select proc calls by kanef///
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
	var/no_refresh = FALSE
	var/can_purchase = TRUE //if this can be bought from a PDA terminal
	var/assets_type = null //for asset sending
	var/mode = 0 //for apps with multiple screens

/datum/pda_app/proc/onInstall(var/obj/item/device/pda/device)
	if(istype(device))
		pda_device = device
		pda_device.applications += src
		if(!(category in pda_device.categorised_applications))
			pda_device.categorised_applications[category] = list() //Creates the associative list for this if it doesn't exist.
		pda_device.categorised_applications[category] += src //Adds this app to the appropriate category if it does.

/datum/pda_app/proc/onUninstall()
	if(pda_device)
		var/list/affiliated_apps = pda_device.categorised_applications[category]
		if(islist(affiliated_apps)) //Too much sanity checking, maybe
			affiliated_apps.Remove(src)
			if(!affiliated_apps || !affiliated_apps.len)
				pda_device.categorised_applications.Remove(category)
		else
			pda_device.categorised_applications[category] = null
		pda_device.applications.Remove(src)
		pda_device = null

/datum/pda_app/proc/on_select(var/mob/user)
	return

/datum/pda_app/proc/get_dat(var/mob/user)
	return ""

/datum/pda_app/Topic(href, href_list)
	if(..())
		return TRUE

	var/mob/living/U = usr

	if(!pda_device) // Need this for functionality
		return TRUE
	if (!pda_device.can_use(U)) //From PDA, double check here
		U.unset_machine()
		U << browse(null, "window=pda")
		return TRUE

	pda_device.add_fingerprint(U)
	if(!href_list["skiprefresh"])
		U.set_machine(pda_device)

/datum/pda_app/proc/refresh_pda()
	if(!pda_device)
		return
	if(!no_refresh)
		if(usr.machine == pda_device)
			pda_device.attack_self(usr)
		else
			usr.unset_machine()
			usr << browse(null, "window=pda")
	else
		no_refresh = FALSE

/datum/pda_app/Destroy()
	onUninstall()
	..()

/proc/get_all_installable_apps()
	. = list()
	for(var/apptype in subtypesof(/datum/pda_app))
		var/datum/pda_app/app = new apptype()
		if(app.can_purchase)
			. += apptype
		qdel(app)
