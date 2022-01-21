#define MAX_DESIGNS 10

#define SCANMODE_NONE		0
#define SCANMODE_MEDICAL	1
#define SCANMODE_FORENSIC	2
#define SCANMODE_REAGENT	3
#define SCANMODE_HALOGEN	4
#define SCANMODE_ATMOS		5
#define SCANMODE_DEVICE		6
#define SCANMODE_ROBOTICS	7
#define SCANMODE_HAILER		8
#define SCANMODE_CAMERA		9

// Don't ask.
#define PDA_MODE_BEEPSKY 46
#define PDA_MODE_DELIVERY_BOT 48
#define PDA_MODE_APP 1
#define PDA_MODE_JANIBOTS 1000 // Initially I wanted to make it a "FUCK" "OLD" "CODERS" defines, but it would actually take some memory as string prototypes, so let's not.
#define PDA_MODE_FLOORBOTS 1001
#define PDA_MODE_MEDBOTS 1002

#define PDA_MINIMAP_WIDTH	256
#define PDA_MINIMAP_OFFSET_X	8
#define PDA_MINIMAP_OFFSET_Y	233

//The advanced pea-green monochrome lcd of tomorrow.

var/global/list/obj/item/device/pda/PDAs = list()
var/global/msg_id = 0

/obj/item/device/pda
	name = "\improper PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a pre-programmed ROM cartridge. Can download additional applications from PDA terminals."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	item_state = "electronic"
	w_class = W_CLASS_TINY
	flags = FPRINT
	slot_flags = SLOT_ID | SLOT_BELT

	//Main variables
	var/owner = null
	var/default_cartridge = 0 // Access level defined by cartridge
	var/obj/item/weapon/cartridge/cartridge = null //current cartridge
	var/mode = 0 //Controls what menu the PDA will display. 0 is hub; the rest are either built in or based on cartridge.

	//Secondary variables
	var/scanmode = SCANMODE_NONE //used for various PDA scanning functions
	var/fon = 0 //Is the flashlight function on?
	var/f_lum = 2 //Luminosity for the flashlight function
	var/silent = 0 //To beep or not to beep, that is the question
	var/toff = 0 //If 1, messenger disabled
	var/list/tnote = list() //Current Texts
	var/last_text //No text spamming
	var/last_honk //Also no honk spamming that's bad too
	var/ttone = "beep" //The ringtone!
	var/lock_code = "" // Lockcode to unlock uplink
	var/honkamt = 0 //How many honks left when infected with honk.exe
	var/mimeamt = 0 //How many silence left when infected with mime.exe
	var/cart = "" //A place to stick cartridge menu information
	var/detonate = 1 // Can the PDA be blown up?
	var/hidden = 0 // Is the PDA hidden from the PDA list?
	var/reply = null //Where are replies directed? For multicaster. Most set this to self in new.
	var/show_overlays = TRUE

	var/obj/item/weapon/card/id/id = null //Making it possible to slot an ID card into the PDA so it can function as both.
	var/ownjob = null //related to above

	var/obj/item/device/paicard/pai = null	// A slot for a personal AI device
	var/obj/item/weapon/photo/photo = null	// A slot for a photo
	var/list/icon/imglist = list() // Viewable message photos
	var/obj/item/device/analyzer/atmos_analys = new
	var/obj/item/device/robotanalyzer/robo_analys = new
	var/obj/item/device/hailer/integ_hailer = new
	var/obj/item/device/device_analyser/dev_analys = null

	var/MM = null
	var/DD = null

	//All applications in this PDA
	var/list/datum/pda_app/applications = list()
	//Associative list with header to file under and list of apps underneath, built from header defined in app.
	var/list/categorised_applications = list("General Functions" = list())
	var/list/starting_apps = list(/datum/pda_app/alarm,/datum/pda_app/notekeeper,/datum/pda_app/events,/datum/pda_app/manifest,/datum/pda_app/balance_check)
	var/datum/pda_app/current_app = null
	var/datum/asset/simple/assets_to_send = null

	var/list/incoming_transactions = list()

/obj/item/device/pda/New()
	..()
	for(var/app_type in starting_apps)
		var/datum/pda_app/app = new app_type()
		app.onInstall(src)

	PDAs += src
	if(default_cartridge)
		cartridge = new default_cartridge(src)
		// PDA being given out to people during the cuck cube
		if(ticker && ticker.current_state >= GAME_STATE_SETTING_UP)
			cartridge.initialize()
	new /obj/item/weapon/pen(src)
	MM = text2num(time2text(world.timeofday, "MM")) 	// get the current month
	DD = text2num(time2text(world.timeofday, "DD")) 	// get the day

/obj/item/device/pda/initialize()
	. = ..()
	if (cartridge)
		cartridge.initialize()

/obj/item/device/pda/update_icon()
	underlays.Cut()
	underlays = list()
	if (cartridge && cartridge.access_camera)
		var/image/cam_under
		if(scanmode == SCANMODE_CAMERA)
			cam_under = image("icon" = "icons/obj/pda.mi", "icon_state" = "cart-gbcam2")
		else
			cam_under = image("icon" = "icons/obj/pda.mi", "icon_state" = "cart-gbcam")
		cam_under.pixel_y = 8
		underlays += cam_under

/obj/item/device/pda/ert
	name = "ERT PDA"
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-ert"

/obj/item/device/pda/medical
	name = "Medical PDA"
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-m"

/obj/item/device/pda/medical/New()
	..()
	var/datum/pda_app/ringer/app = new /datum/pda_app/ringer()
	app.onInstall(src)
	app.frequency = deskbell_freq_medbay

/obj/item/device/pda/viro
	name = "Virology PDA"
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-v"

/obj/item/device/pda/viro/New()
	..()
	var/datum/pda_app/ringer/app = new /datum/pda_app/ringer()
	app.onInstall(src)
	app.frequency = deskbell_freq_medbay

/obj/item/device/pda/engineering
	name = "Engineering PDA"
	default_cartridge = /obj/item/weapon/cartridge/engineering
	icon_state = "pda-e"

/obj/item/device/pda/security
	name = "Security PDA"
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-s"

/obj/item/device/pda/security/New()
	..()
	var/datum/pda_app/ringer/app = new /datum/pda_app/ringer()
	app.onInstall(src)
	app.frequency = deskbell_freq_brig

/obj/item/device/pda/detective
	name = "Detective PDA"
	default_cartridge = /obj/item/weapon/cartridge/detective
	icon_state = "pda-det"

/obj/item/device/pda/detective/New()
	..()
	var/datum/pda_app/light_upgrade/app = new /datum/pda_app/light_upgrade()
	app.onInstall(src)

/obj/item/device/pda/warden
	name = "Warden PDA"
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-warden"

/obj/item/device/pda/warden/New()
	..()
	var/datum/pda_app/ringer/app = new /datum/pda_app/ringer()
	app.onInstall(src)
	app.frequency = deskbell_freq_brig

/obj/item/device/pda/janitor
	name = "Janitor PDA"
	default_cartridge = /obj/item/weapon/cartridge/janitor
	icon_state = "pda-j"
	ttone = "slip"

/obj/item/device/pda/toxins
	name = "Science PDA"
	default_cartridge = /obj/item/weapon/cartridge/signal/toxins
	icon_state = "pda-tox"
	ttone = "boom"

/obj/item/device/pda/toxins/New()
	..()
	var/datum/pda_app/ringer/app = new /datum/pda_app/ringer()
	app.onInstall(src)
	app.frequency = deskbell_freq_rnd

/obj/item/device/pda/clown
	name = "Clown PDA"
	default_cartridge = /obj/item/weapon/cartridge/clown
	icon_state = "pda-clown"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The surface is coated with polytetrafluoroethylene and banana drippings."
	ttone = "honk"

/obj/item/device/pda/mime
	name = "Mime PDA"
	default_cartridge = /obj/item/weapon/cartridge/mime
	icon_state = "pda-mime"
	silent = 1
	ttone = "silence"

/obj/item/device/pda/heads
	name = "Head of department PDA"
	default_cartridge = /obj/item/weapon/cartridge/head
	icon_state = "pda-h"

/obj/item/device/pda/heads/assassin
	name = "Reaper PDA"
	ownjob = "Reaper"

/obj/item/device/pda/heads/nt_rep
	name = "Nanotrasen Navy Representative PDA"
	ownjob = "Nanotrasen Navy Representative"

/obj/item/device/pda/heads/nt_officer
	name = "Nanotrasen Navy Officer PDA"
	ownjob = "Nanotrasen Navy Officer"

/obj/item/device/pda/heads/nt_captain
	name = "Nanotrasen Navy Captain PDA"
	ownjob = "Nanotrasen Navy Captain"

/obj/item/device/pda/heads/nt_captain/New()
	starting_apps.Cut()
	starting_apps = get_all_installable_apps()
	..()

/obj/item/device/pda/heads/nt_supreme
	name = "Nanotrasen Supreme Commander PDA"
	ownjob = "Nanotrasen Supreme Commander"

/obj/item/device/pda/heads/nt_supreme/New()
	starting_apps.Cut()
	starting_apps = get_all_installable_apps()
	..()

/obj/item/device/pda/heads/hop
	name = "Head of Personnel PDA"
	default_cartridge = /obj/item/weapon/cartridge/hop
	icon_state = "pda-hop"

/obj/item/device/pda/heads/hop/New()
	..()
	var/datum/pda_app/ringer/app = new /datum/pda_app/ringer()
	app.onInstall(src)
	app.frequency = deskbell_freq_hop

/obj/item/device/pda/heads/hos
	name = "Head of Security PDA"
	default_cartridge = /obj/item/weapon/cartridge/hos
	icon_state = "pda-hos"

/obj/item/device/pda/heads/hos/New()
	..()
	var/datum/pda_app/ringer/app = new /datum/pda_app/ringer()
	app.onInstall(src)
	app.frequency = deskbell_freq_brig

/obj/item/device/pda/heads/ce
	name = "Chief Engineer PDA"
	default_cartridge = /obj/item/weapon/cartridge/ce
	icon_state = "pda-ce"

/obj/item/device/pda/heads/cmo
	name = "Chief Medical Officer PDA"
	default_cartridge = /obj/item/weapon/cartridge/cmo
	icon_state = "pda-cmo"

/obj/item/device/pda/heads/cmo/New()
	..()
	var/datum/pda_app/ringer/app = new /datum/pda_app/ringer()
	app.onInstall(src)
	app.frequency = deskbell_freq_medbay

/obj/item/device/pda/heads/rd
	name = "Research Director PDA"
	default_cartridge = /obj/item/weapon/cartridge/rd
	icon_state = "pda-rd"

/obj/item/device/pda/heads/rd/New()
	..()
	var/datum/pda_app/ringer/app = new /datum/pda_app/ringer()
	app.onInstall(src)
	app.frequency = deskbell_freq_rnd

/obj/item/device/pda/captain
	name = "Captain PDA"
	default_cartridge = /obj/item/weapon/cartridge/captain
	icon_state = "pda-c"
	detonate = 0
	//toff = 1

/obj/item/device/pda/captain/New()
	starting_apps.Cut()
	starting_apps = get_all_installable_apps()
	..()

/obj/item/device/pda/cargo
	name = "Cargo PDA"
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-cargo"

/obj/item/device/pda/cargo/New()
	..()
	var/datum/pda_app/ringer/app = new /datum/pda_app/ringer()
	app.onInstall(src)
	app.frequency = deskbell_freq_cargo

/obj/item/device/pda/quartermaster
	name = "Quartermaster PDA"
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-q"

/obj/item/device/pda/quartermaster/New()
	..()
	var/datum/pda_app/ringer/app = new /datum/pda_app/ringer()
	app.onInstall(src)
	app.frequency = deskbell_freq_cargo

/obj/item/device/pda/shaftminer
	name = "Mining PDA"
	icon_state = "pda-miner"

/obj/item/device/pda/syndicate
	default_cartridge = /obj/item/weapon/cartridge/syndicate
	icon_state = "pda-syn"
	name = "Military PDA"
	hidden = 1

/obj/item/device/pda/syndicate/door
	default_cartridge = /obj/item/weapon/cartridge/syndicatedoor

/obj/item/device/pda/chaplain
	name = "Chaplain PDA"
	icon_state = "pda-holy"
	ttone = "holy"

/obj/item/device/pda/lawyer
	name = "Lawyer PDA"
	default_cartridge = /obj/item/weapon/cartridge/lawyer
	icon_state = "pda-lawyer"
	ttone = "..."

/obj/item/device/pda/botanist
	name = "Botany PDA"
	//default_cartridge = /obj/item/weapon/cartridge/botanist
	icon_state = "pda-hydro"

/obj/item/device/pda/roboticist
	name = "Robotics PDA"
	default_cartridge = /obj/item/weapon/cartridge/robotics
	icon_state = "pda-robot"

/obj/item/device/pda/librarian
	name = "Librarian PDA"
	icon_state = "pda-libb"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a WGW-11 series e-reader."
	silent = 1 //Quiet in the library!

/obj/item/device/pda/librarian/New()
	starting_apps += /datum/pda_app/newsreader
	..()
	var/datum/pda_app/notekeeper/app = locate(/datum/pda_app/notekeeper) in applications
	if(app)
		app.note = "Congratulations, your station has chosen the Thinktronic 5290 WGW-11 Series E-reader and Personal Data Assistant!"

/obj/item/device/pda/clear
	icon_state = "pda-transp"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a special edition with a transparent case."

/obj/item/device/pda/clear/New()
	..()
	var/datum/pda_app/notekeeper/app = locate(/datum/pda_app/notekeeper) in applications
	if(app)
		app.note = "Congratulations, you have chosen the Thinktronic 5230 Personal Data Assistant Deluxe Special Max Turbo Limited Edition!"

/obj/item/device/pda/trader
	name = "Trader PDA"
	desc = "Much good for trade."
	icon_state = "pda-trader"
	default_cartridge = /obj/item/weapon/cartridge/trader
	show_overlays = FALSE

/obj/item/device/pda/trader/New()
	..()
	var/datum/pda_app/notekeeper/app = locate(/datum/pda_app/notekeeper) in applications
	if(app)
		app.note = "Congratulations, your statio RUNTIME FAULT AT 0x3ae46dc1"

/obj/item/device/pda/chef
	name = "Chef PDA"
	default_cartridge = /obj/item/weapon/cartridge/chef
	icon_state = "pda-chef"

/obj/item/device/pda/bar
	name = "Bartender PDA"
	icon_state = "pda-bar"

/obj/item/device/pda/atmos
	name = "Atmospherics PDA"
	default_cartridge = /obj/item/weapon/cartridge/atmos
	icon_state = "pda-atmo"

/obj/item/device/pda/mechanic
	name = "Mechanic PDA"
	default_cartridge = /obj/item/weapon/cartridge/mechanic
	icon_state = "pda-atmo"

/obj/item/device/pda/chemist
	name = "Chemistry PDA"
	default_cartridge = /obj/item/weapon/cartridge/chemistry
	icon_state = "pda-chem"

/obj/item/device/pda/geneticist
	name = "Genetics PDA"
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-gene"


// Special AI/pAI PDAs that cannot explode.
/obj/item/device/pda/ai
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "pda_server-on"
	ttone = "data"
	detonate = 0

/obj/item/device/pda/ai/New()
	starting_apps += /datum/pda_app/spam_filter
	..()

/obj/item/device/pda/ai/proc/set_name_and_job(newname as text, newjob as text)
	owner = newname
	ownjob = newjob
	name = newname + " (" + ownjob + ")"


//AI verb and proc for sending PDA messages.
/mob/living/silicon/ai/proc/cmd_send_pdamesg()
	var/list/names = list()
	var/list/plist = list()
	var/list/namecounts = list()

	if(usr.stat == 2)
		to_chat(usr, "You can't send PDA messages because you are dead!")
		return

	if(src.aiPDA.toff)
		to_chat(usr, "Turn on your receiver in order to send messages.")
		return

	for (var/obj/item/device/pda/P in get_viewable_pdas())
		if (P == src)
			continue
		else if (P == src.aiPDA)
			continue

		var/name = P.owner
		if (name in names)
			namecounts[name]++
			name = text("[name] ([namecounts[name]])")
		else
			names.Add(name)
			namecounts[name] = 1

		plist[text("[name]")] = P

	var/c = input(usr, "Please select a PDA") as null|anything in sortList(plist)

	if (!c)
		return

	var/selected = plist[c]

	if(aicamera.aipictures.len)
		var/list/nametemp = list()
		for(var/datum/picture/t in aicamera.aipictures)
			nametemp += t.fields["name"]
		var/find = input("Select image") in nametemp
		for(var/datum/picture/q in aicamera.aipictures)
			if(q.fields["name"] == find)
				aiPDA.photo = new /obj/item/weapon/photo(aiPDA)
				aiPDA.photo.name = q.fields["name"]
				aiPDA.photo.icon = q.fields["icon"]
				aiPDA.photo.img = q.fields["img"]
				aiPDA.photo.info = q.fields["info"]
				aiPDA.photo.pixel_x = q.fields["pixel_x"]
				aiPDA.photo.pixel_y = q.fields["pixel_y"]
				aiPDA.photo.blueprints = q.fields["blueprints"]
				break

	aiPDA.create_message(src, selected)
	aiPDA.photo = null

//AI verb and proc for sending PDA messages.
/obj/item/device/pda/ai/verb/cmd_send_pdamesg()
	set category = "AI Commands"
	set name = "Send Message"
	set src in usr
	if(usr.isDead())
		to_chat(usr, "You can't send PDA messages because you are dead!")
		return
	var/list/plist = available_pdas()
	if (plist)
		var/c = input(usr, "Please select a PDA") as null|anything in sortList(plist)
		if (!c) // if the user hasn't selected a PDA file we can't send a message
			return
		var/selected = plist[c]

		var/obj/item/device/camera/silicon/targetcam = null
		if(isAI(usr))
			var/mob/living/silicon/ai/A = usr
			targetcam = A.aicamera
		else if((isrobot(usr)))
			var/mob/living/silicon/robot/R = usr
			if(R.connected_ai)
				targetcam = R.connected_ai.aicamera
			else
				targetcam = R.aicamera

		if(targetcam && targetcam.aipictures.len)
			var/list/nametemp = list()
			for(var/datum/picture/t in targetcam.aipictures)
				nametemp += t.fields["name"]
			var/find = input("Select image") in nametemp
			for(var/datum/picture/q in targetcam.aipictures)
				if(q.fields["name"] == find)
					photo = new /obj/item/weapon/photo(src)
					photo.name = q.fields["name"]
					photo.icon = q.fields["icon"]
					photo.img = q.fields["img"]
					photo.info = q.fields["info"]
					photo.pixel_x = q.fields["pixel_x"]
					photo.pixel_y = q.fields["pixel_y"]
					photo.blueprints = q.fields["blueprints"]
					break

		create_message(usr, selected)
		photo = null


/obj/item/device/pda/ai/verb/cmd_toggle_pda_receiver()
	set category = "AI Commands"
	set name = "Toggle Sender/Receiver"
	set src in usr
	if(usr.isDead())
		to_chat(usr, "You can't do that because you are dead!")
		return
	toff = !toff
	to_chat(usr, "<span class='notice'>PDA sender/receiver toggled [(toff ? "Off" : "On")]!</span>")


/obj/item/device/pda/ai/verb/cmd_toggle_pda_silent()
	set category = "AI Commands"
	set name = "Toggle Ringer"
	set src in usr
	if(usr.isDead())
		to_chat(usr, "You can't do that because you are dead!")
		return
	silent=!silent
	to_chat(usr, "<span class='notice'>PDA ringer toggled [(silent ? "Off" : "On")]!</span>")


/obj/item/device/pda/ai/verb/cmd_show_message_log()
	set category = "AI Commands"
	set name = "Show Message Log"
	set src in usr
	if(usr.isDead())
		to_chat(usr, "You can't do that because you are dead!")
		return
	var/dat = "<html><head><title>AI PDA Message Log</title></head><body>"
	for(var/note in tnote)
		dat += tnote[note]
		var/icon/img = imglist[note]
		if(img)
			usr << browse_rsc(img, "tmp_photo_[note].png")
			dat += "<img src='tmp_photo_[note].png' width = '192' style='-ms-interpolation-mode:nearest-neighbor'><BR>"
	dat += "</body></html>"
	usr << browse(dat, "window=log;size=400x444;border=1;can_resize=1;can_close=1;can_minimize=0")

/mob/living/silicon/ai/proc/cmd_show_message_log()
	if(usr.isDead())
		to_chat(usr, "You can't do that because you are dead!")
		return
	if(!isnull(aiPDA))
		var/dat = "<html><head><title>AI PDA Message Log</title></head><body>"
		for(var/note in aiPDA.tnote)
			dat += aiPDA.tnote[note]
			var/icon/img = aiPDA.imglist[note]
			if(img)
				usr << browse_rsc(img, "tmp_photo_[note].png")
				dat += "<img src='tmp_photo_[note].png' width = '192' style='-ms-interpolation-mode:nearest-neighbor'><BR>"
		dat += "</body></html>"
		usr << browse(dat, "window=log;size=400x444;border=1;can_resize=1;can_close=1;can_minimize=0")
	else
		to_chat(usr, "You do not have a PDA. You should make an issue report about this.")

/obj/item/device/pda/ai/attack_self(mob/user as mob)
	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)
	return


/obj/item/device/pda/ai/pai
	ttone = "assist"


/*
 *	The Actual PDA
 */

/obj/item/device/pda/proc/can_use(mob/user)
	if(user && ismob(user))
		if(user.incapacitated())
			return 0
		if(loc == user)
			return 1
	return 0

/obj/item/device/pda/GetAccess()
	if(id)
		return id.GetAccess()
	else
		return ..()

/obj/item/device/pda/GetID()
	return id

/obj/item/device/pda/get_owner_name_from_ID()
	return owner

/obj/item/device/pda/MouseDropFrom(obj/over_object as obj, src_location, over_location)
	var/mob/M = usr
	if((!istype(over_object, /obj/abstract/screen)) && can_use(M))
		return attack_self(M)
	return ..()

//NOTE: graphic resources are loaded on client login
/obj/item/device/pda/attack_self(mob/user as mob)

	user.set_machine(src)

	var/datum/pda_app/station_map/map_app = locate(/datum/pda_app/station_map) in applications
	if (map_app && map_app.holomap)
		map_app.holomap.stopWatching()

	. = ..()
	if(.)
		return

	if(user.client)
		var/datum/asset/simple/C = new/datum/asset/simple/pda()
		send_asset_list(user.client, C.assets)

	var/dat = list()
	dat += {"
	<html>
	<head><title>Personal Data Assistant</title></head>
	<body>
	<link rel="stylesheet" type="text/css" href="pda.css"/> <!--This stylesheet contains all the PDA icons in base 64!-->
	"}
	if ((!isnull(cartridge)) && (mode == 0))
		dat += "<a href='byond://?src=\ref[src];choice=Eject'><span class='pda_icon pda_eject'></span> Eject [cartridge]</a> | "
	if (mode)
		dat += "<a href='byond://?src=\ref[src];choice=Return'><span class='pda_icon pda_menu'></span> Return</a> | "

	dat += {"<a href='byond://?src=\ref[src];choice=Refresh'><span class='pda_icon pda_refresh'></span> Refresh</a>
		<br>"}
	if (!owner)

		dat += {"Warning: No owner information entered.  Please swipe card.<br><br>
			<a href='byond://?src=\ref[src];choice=Refresh'><span class='pda_icon pda_refresh'></span> Retry</a>"}
	else
		switch (mode)
			if (0)
				dat += {"<h2>PERSONAL DATA ASSISTANT v.1.4</h2>
					Owner: [owner], [ownjob]<br>"}
				dat += text("ID: <A href='?src=\ref[src];choice=Authenticate'>[id ? "[id.registered_name], [id.assignment]" : "----------"]")
				dat += text("<br><A href='?src=\ref[src];choice=UpdateInfo'>[id ? "Update PDA Info" : ""]</A><br><br>")


				dat += "Station Time: [worldtime2text()]"
				var/datum/pda_app/alarm/alarm_app = locate(/datum/pda_app/alarm) in applications
				if(alarm_app)
					dat +=  "<a href='byond://?src=\ref[src];choice=appMode;appChoice=\ref[alarm_app]'><span class='pda_icon pda_clock'></span> Set Alarm</a>"
				dat += {"<br><br>
					<ul>
					<li><a href='byond://?src=\ref[src];choice=2'><span class='pda_icon pda_mail'></span> Messenger</a></li>
					<li><a href='byond://?src=\ref[src];choice=Multimessage'><span class='pda_icon pda_mail'></span> Department Messenger</a></li>
					"}

				if (cartridge)
					if (cartridge.access_clown)
						dat += "<li><a href='byond://?src=\ref[src];choice=Honk'><span class='pda_icon pda_honk'></span> Honk Synthesizer</a></li>"

				dat += "</ul>"

				if(applications.len == 0)
					dat += {"<h4>No application currently installed.</h4>"}
				else if(categorised_applications.len == 0)
					dat += {"<h4>Unsorted Applications</h4>"}
					dat += {"<ul>"}
					for(var/datum/pda_app/app in applications)
						if(app.menu)
							dat += {"<li><a href='byond://?src=\ref[src];choice=appMode;appChoice=\ref[app]'>[app.icon ? "<span class='pda_icon [app.icon]'></span> " : ""][app.name]</a></li>"}
					dat += {"</ul>"}
				else
					for(var/category_title in categorised_applications)
						dat += {"<h4>[category_title]</h4>"}
						dat += {"<ul>"}
						for(var/datum/pda_app/app in categorised_applications[category_title])
							if(app.menu)
								dat += {"<li><a href='byond://?src=\ref[src];choice=appMode;appChoice=\ref[app]'>[app.icon ? "<span class='pda_icon [app.icon]'></span> " : ""][app.name]</a></li>"}
						dat += {"</ul>"}

				if (cartridge)
					if (cartridge.access_engine || cartridge.access_atmos)
						dat += {"<h4>Engineering Functions</h4><ul>"}

						if (istype(cartridge.radio, /obj/item/radio/integrated/signal/bot/floorbot))
							dat += {"<li><a href='byond://?src=\ref[src];choice=[PDA_MODE_FLOORBOTS]'><span class='pda_icon pda_atmos'></span> Floor Bot Access</a></li>
									</ul>"}
						else
							dat += {"</ul>"}

					//if (cartridge.access_mechanic)
					if (cartridge.access_medical)

						dat += {"<h4>Medical Functions</h4><ul>"}

						if (istype(cartridge.radio, /obj/item/radio/integrated/signal/bot/medbot))
							dat += {"<li><a href='byond://?src=\ref[src];choice=[PDA_MODE_MEDBOTS]'><span class='pda_icon pda_medical'></span> Medical Bot Access</a></li>
								</ul>"}
						else
							dat += {"</ul>"}

					//if (cartridge.access_security)
					if(cartridge.access_quartermaster)

						dat += {"<h4>Quartermaster Functions:</h4>
							<ul>
							<li><a href='byond://?src=\ref[src];choice=47'><span class='pda_icon pda_crate'></span> Supply Records</A></li>
							<li><a href='byond://?src=\ref[src];choice=delivery_bot'><span class='pda_icon pda_mule'></span> Delivery Bot Control</A></li>
							</ul>"}

				dat += {"</ul>
					<h4>Utilities</h4>
					<ul>"}
				if (cartridge)
					if (cartridge.access_janitor)
						dat += "<li><a href='byond://?src=\ref[src];choice=49'><span class='pda_icon pda_bucket'></span> Custodial Locator</a></li>"
						if (istype(cartridge.radio, /obj/item/radio/integrated/signal/bot/janitor))
							dat += {"<li><a href='byond://?src=\ref[src];choice=[PDA_MODE_JANIBOTS]'><span class='pda_icon pda_bucket'></span> Cleaner Bot Access</a></li>"}
					if (istype(cartridge.radio, /obj/item/radio/integrated/signal))
						dat += "<li><a href='byond://?src=\ref[src];choice=40'><span class='pda_icon pda_signaler'></span> Signaler System</a></li>"
					//if (cartridge.access_reagent_scanner)
					if (cartridge.access_engine)
						dat += "<li><a href='byond://?src=\ref[src];choice=Halogen Counter'><span class='pda_icon pda_reagent'></span> [scanmode == SCANMODE_HALOGEN ? "Disable" : "Enable"] Halogen Counter</a></li>"
					//if (cartridge.access_atmos)
					//if (cartridge.access_remote_door)
					if (cartridge.access_trader)
						dat += "<li><a href='byond://?src=\ref[src];choice=Send Shuttle'><span class='pda_icon pda_rdoor'></span> Send Trader Shuttle</a></li>"
					if (cartridge.access_robotics)
						dat += "<li><a href='byond://?src=\ref[src];choice=Cyborg Analyzer'><span class='pda_icon pda_medical'></span> [scanmode == SCANMODE_ROBOTICS ? "Disable" : "Enable"] Cyborg Analyzer</a></li>"
					if (cartridge.access_camera)
						dat += "<li><a href='byond://?src=\ref[src];choice=PDA Camera'> [scanmode == SCANMODE_CAMERA ? "Disable" : "Enable"] Camera</a></li>"
						dat += "<li><a href='byond://?src=\ref[src];choice=Show Photos'>Show Photos</a></li>"
				dat += {"<li><a href='byond://?src=\ref[src];choice=3'><span class='pda_icon pda_atmos'></span> Atmospheric Scan</a></li>
					<li><a href='byond://?src=\ref[src];choice=Light'><span class='pda_icon pda_flashlight'></span> [fon ? "Disable" : "Enable"] Flashlight</a></li>"}
				if (pai)
					if(pai.loc != src)
						pai = null
					else

						dat += {"<li><a href='byond://?src=\ref[src];choice=pai;option=1'>pAI Device Configuration</a></li>
							<li><a href='byond://?src=\ref[src];choice=pai;option=2'>Eject pAI Device</a></li>"}
				dat += "</ul>"

			//(1) is for the app screen, and not here

			if (2)

				dat += {"<h4><span class='pda_icon pda_mail'></span> SpaceMessenger V3.9.4</h4>
					<a href='byond://?src=\ref[src];choice=Toggle Ringer'><span class='pda_icon pda_bell'></span> Ringer: [silent == 1 ? "Off" : "On"]</a> |
					<a href='byond://?src=\ref[src];choice=Toggle Messenger'><span class='pda_icon pda_mail'></span> Send / Receive: [toff == 1 ? "Off" : "On"]</a> |
					<a href='byond://?src=\ref[src];choice=Ringtone'><span class='pda_icon pda_bell'></span> Set Ringtone</a> |
					<a href='byond://?src=\ref[src];choice=21'><span class='pda_icon pda_mail'></span> Messages</a>"}
				if(photo)
					dat += " | <a href='byond://?src=\ref[src];choice=Eject Photo'><span class='pda_icon pda_eject'></span>Eject Photo</a>"
				dat += "<br>"
				if (istype(cartridge, /obj/item/weapon/cartridge/syndicate))
					dat += "<b>[cartridge:shock_charges] detonation charges left.</b><HR>"
				if (istype(cartridge, /obj/item/weapon/cartridge/clown))
					dat += "<b>[cartridge:honk_charges] viral files left.</b><HR>"
				if (istype(cartridge, /obj/item/weapon/cartridge/mime))
					dat += "<b>[cartridge:mime_charges] viral files left.</b><HR>"


				dat += {"<h4><span class='pda_icon pda_menu'></span> Detected PDAs</h4>
					<ul>"}
				var/count = 0

				if (!toff)
					for (var/obj/item/device/pda/P in sortNames(get_viewable_pdas()))
						if (P == src)
							continue
						if(P.hidden)
							continue
						dat += "<li><a href='byond://?src=\ref[src];choice=Message;target=\ref[P]'>[P]</a>"
						if (id && !istype(P,/obj/item/device/pda/ai))
							dat += " (<a href='byond://?src=\ref[src];choice=transferFunds;target=\ref[P]'><span class='pda_icon pda_money'></span>*Send Money*</a>)"
						if (istype(cartridge, /obj/item/weapon/cartridge/syndicate) && P.detonate)
							dat += " (<a href='byond://?src=\ref[src];choice=Detonate;target=\ref[P]'><span class='pda_icon pda_boom'></span>*Detonate*</a>)"
						if (istype(cartridge, /obj/item/weapon/cartridge/clown))
							dat += " (<a href='byond://?src=\ref[src];choice=Send Honk;target=\ref[P]'><span class='pda_icon pda_honk'></span>*Send Virus*</a>)"
						if (istype(cartridge, /obj/item/weapon/cartridge/mime))
							dat += " (<a href='byond://?src=\ref[src];choice=Send Silence;target=\ref[P]'>*Send Virus*</a>)"
						dat += "</li>"
						count++
				dat += "</ul>"
				if (count == 0)
					dat += "None detected.<br>"

			if(21)

				dat += {"<h4><span class='pda_icon pda_mail'></span> SpaceMessenger V3.9.4</h4>
					<a href='byond://?src=\ref[src];choice=Clear'><span class='pda_icon pda_blank'></span> Clear Messages</a>
					<h4><span class='pda_icon pda_mail'></span> Messages</h4>"}
				for(var/note in tnote)
					dat += tnote[note]
					var/icon/img = imglist[note]
					if(img)
						user << browse_rsc(ImagePDA(img), "tmp_photo_[note].png")
						dat += "<img src='tmp_photo_[note].png' width = '192' style='-ms-interpolation-mode:nearest-neighbor'><BR>"
				dat += "<br>"

			if (3)
				dat += "<h4><span class='pda_icon pda_atmos'></span> Atmospheric Readings</h4>"

				if (isnull(user.loc))
					dat += "Unable to obtain a reading.<br>"
				else
					var/datum/gas_mixture/environment = user.loc.return_air()

					if(!environment)
						dat += "No gasses detected.<br>"

					else
						var/pressure = environment.return_pressure()
						var/total_moles = environment.total_moles()

						dat += "Air Pressure: [round(pressure,0.1)] kPa<br>"

						if (total_moles)
							var/o2_level = environment[GAS_OXYGEN]/total_moles
							var/n2_level = environment[GAS_NITROGEN]/total_moles
							var/co2_level = environment[GAS_CARBON]/total_moles
							var/plasma_level = environment[GAS_PLASMA]/total_moles
							var/unknown_level =  1-(o2_level+n2_level+co2_level+plasma_level)

							dat += {"Nitrogen: [round(n2_level*100)]%<br>
								Oxygen: [round(o2_level*100)]%<br>
								Carbon Dioxide: [round(co2_level*100)]%<br>
								Plasma: [round(plasma_level*100)]%<br>"}
							if(unknown_level > 0.01)
								dat += "OTHER: [round(unknown_level)]%<br>"
						dat += "Temperature: [round(environment.temperature-T0C)]&deg;C<br>"
				dat += "<br>"

			if (PDA_MODE_DELIVERY_BOT)
				if (!istype(cartridge.radio, /obj/item/radio/integrated/signal/bot/mule))
					dat += {"<span class='pda_icon pda_mule'></span>Commlink bot error <br/>"}
					return
				// Building the data in the list
				dat += {"<span class='pda_icon pda_mule'></span><b>M.U.L.E. bot Interlink V1.0</h4> </b><br/>"}
				dat += "<ul>"
				for (var/obj/machinery/bot/mulebot/mule in bots_list)
					if (mule.z != user.z)
						continue
					dat += {"<li>
							<i>[mule]</i>: [mule.return_status()] in [get_area_name(mule)] <br/>
							<a href='?src=\ref[cartridge.radio];bot=\ref[mule];command=summon;user=\ref[user]'>[mule.summoned ? "Halt" : "Summon"] <br/>
							<a href='?src=\ref[cartridge.radio];bot=\ref[mule];command=switch_power;user=\ref[user]'>Turn [mule.on ? "off" : "on"] <br/>
							<a href='?src=\ref[cartridge.radio];bot=\ref[mule];command=return_home;user=\ref[user]'>Send home</a> <br/>
							<a href='?src=\ref[cartridge.radio];bot=\ref[mule];command=[cartridge.saved_destination];user=\ref[user]'>Send to:</a> <a href='?src=\ref[cartridge];change_destination=1'>[cartridge.saved_destination] - EDIT</a> <br/>
							</li>"}
				dat += "</ul>"

			if (PDA_MODE_JANIBOTS)
				if (!istype(cartridge.radio, /obj/item/radio/integrated/signal/bot/janitor))
					dat += {"<span class='pda_icon pda_bucket'></span>Commlink bot error <br/>"}
					return
				dat += {"<span class='pda_icon pda_bucket'></span><b>C.L.E.A.N bot Interlink V1.0</b> <br/>"}
				dat += "<ul>"
				for (var/obj/machinery/bot/cleanbot/clean in bots_list)
					if (clean.z != user.z)
						continue
					dat += {"<li>
							<i>[clean]</i>: [clean.return_status()] in [get_area_name(clean)] <br/>
							<a href='?src=\ref[cartridge.radio];bot=\ref[clean];command=summon;user=\ref[user]'>[clean.summoned ? "Halt" : "Summon"]</a> <br/>
							<a href='?src=\ref[cartridge.radio];bot=\ref[clean];command=switch_power;user=\ref[user]'>Turn [clean.on ? "off" : "on"]</a> <br/>
							Auto-patrol: <a href='?src=\ref[cartridge.radio];bot=\ref[clean];command=auto_patrol;user=\ref[user]'>[clean.auto_patrol ? "Enabled" : "Disabled"]</a><br/>
							</li>"}
				dat += "</ul>"
			if (PDA_MODE_FLOORBOTS)
				if (!istype(cartridge.radio, /obj/item/radio/integrated/signal/bot/floorbot))
					dat += {"<span class='pda_icon pda_atmos'></span> Commlink bot error <br/>"}
					return
				dat += {"<span class='pda_icon pda_atmos'></span><b>F.L.O.O.R bot Interlink V1.0</b> <br/>"}
				dat += "<ul>"
				for (var/obj/machinery/bot/floorbot/floor in bots_list)
					if (floor.z != user.z)
						continue
					dat += {"<li>
							<i>[floor]</i>: [floor.return_status()] in [get_area_name(floor)] <br/>
							<a href='?src=\ref[cartridge.radio];bot=\ref[floor];command=summon;user=\ref[user]'>[floor.summoned ? "Halt" : "Summon"]</a> <br/>
							<a href='?src=\ref[cartridge.radio];bot=\ref[floor];command=switch_power;user=\ref[user]'>Turn [floor.on ? "off" : "on"]</a> <br/>
							Auto-patrol: <a href='?src=\ref[cartridge.radio];bot=\ref[floor];command=auto_patrol;user=\ref[user]'>[floor.auto_patrol ? "Enabled" : "Disabled"]</a><br/>
							</li>"}
				dat += "</ul>"
			if (PDA_MODE_MEDBOTS)
				if (!istype(cartridge.radio, /obj/item/radio/integrated/signal/bot/medbot))
					dat += {"<span class='pda_icon pda_medical'></span> Commlink bot error <br/>"}
					return
				dat += {"<span class='pda_icon pda_medical'></span><b>M.E.D bot Interlink V1.0</b> <br/>"}
				dat += "<ul>"
				for (var/obj/machinery/bot/medbot/med in bots_list)
					if (med.z != user.z)
						continue
					dat += {"<li>
							<i>[med]</i>: [med.return_status()] in [get_area_name(med)] <br/>
							<a href='?src=\ref[cartridge.radio];bot=\ref[med];command=summon;user=\ref[user]'>[med.summoned ? "Halt" : "Summon"]</a> <br/>
							<a href='?src=\ref[cartridge.radio];bot=\ref[med];command=switch_power;user=\ref[user]'>Turn [med.on ? "off" : "on"]</a> <br/>
							</li>"}
				dat += "</ul>"

			if(1998) //Viewing photos
				dat += {"<h4>View Photos</h4>"}
				if(!cartridge || !istype(cartridge,/obj/item/weapon/cartridge/camera))
					dat += {"No camera found!"}
				else
					dat += {"<a href='byond://?src=\ref[src];choice=Clear Photos'>Delete All Photos</a><hr>"}
					var/obj/item/weapon/cartridge/camera/CM = cartridge
					if(!CM.stored_photos.len)
						dat += {"None found."}
					else
						var/i = 0
						for(var/obj/item/weapon/photo/PH in CM.stored_photos)
							user << browse_rsc(PH.img, "tmp_photo_gallery_[i].png")
							var/displaylength = 192
							switch(PH.photo_size)
								if(5)
									displaylength = 320
								if(7)
									displaylength = 448

							dat += {"<img src='tmp_photo_gallery_[i].png' width='[displaylength]' style='-ms-interpolation-mode:nearest-neighbor' /><hr>"}
							i++
			else//Else it links to the cart menu proc. Although, it really uses menu hub 4--menu 4 doesn't really exist as it simply redirects to hub.
				dat += cart

	if(assets_to_send && user.client) //If we have a client to send to, in reality none of this proc is needed in that case but eh I don't care.
		send_asset_list(user.client, assets_to_send.assets)

	if(current_app)
		if(current_app.pda_device) // Taking it from a PDA app instead
			dat += current_app.get_dat(user)
		else if(!current_app.pda_device)
			dat += "<br><h4>ERROR #0x327AA0EF: App failed to start. Please report this issue to your vendor of purchase.</h4>"

	dat += "</body></html>"
	dat = jointext(dat,"") //Optimize BYOND's shittiness by making "dat" actually a list of strings and join it all together afterwards! Yes, I'm serious, this is actually a big deal

	user << browse(dat, "window=pda;size=400x444;border=1;can_resize=1;can_minimize=0")
	onclose(user, "pda", src)

/obj/item/device/pda/Topic(href, href_list)
	if(..())
		return
	var/mob/living/U = usr

	if (href_list["close"])
		if (U.machine == src)
			U.unset_machine()

		return

	//Looking for master was kind of pointless since PDAs don't appear to have one.
	//if ((src in U.contents) || ( istype(loc, /turf) && in_range(src, U) ) )
	var/no_refresh = FALSE
	if ((href_list["choice"] != "1") || (href_list["choice"] == "1" && href_list["appChoice"] != "5"))//The holomap app
		var/datum/pda_app/station_map/map_app = locate(/datum/pda_app/station_map) in applications
		if (map_app && map_app.holomap)
			map_app.holomap.stopWatching()

	if (!can_use(U)) //Why reinvent the wheel? There's a proc that does exactly that.
		U.unset_machine()
		U << browse(null, "window=pda")
		return

	add_fingerprint(U)
	U.set_machine(src)
	var/datum/pda_app/old_app = current_app
	var/datum/asset/simple/old_assets = assets_to_send
	current_app = null // Reset to make it something else
	assets_to_send = null // Reset to make it something else

	switch(href_list["choice"])

//BASIC FUNCTIONS===================================
		if("Refresh")//Refresh, goes to the end of the proc.
			current_app = old_app //To keep it around afterwards.
			assets_to_send = old_assets //Same here.
		if("Return")//Return
			if((mode<=9) || (mode==1998) || (mode==PDA_MODE_APP))
				mode = 0
			else
				mode = round(mode/10)//TODO: fix this shit up
				if(mode==4)//Fix for cartridges. Redirects to hub.
					mode = 0
				else if(mode >= 40 && mode <= 53)//Fix for cartridges. Redirects to refresh the menu.
					cartridge.mode = mode
					cartridge.unlock()
		if ("Authenticate")//Checks for ID
			id_check(U, 1)
		if("UpdateInfo")
			ownjob = id.assignment
			name = "PDA-[owner] ([ownjob])"
		if("Eject")//Ejects the cart, only done from hub.
			if (!isnull(cartridge))
				for(var/datum/pda_app/app in cartridge.applications)
					app.onUninstall()
				var/turf/T = loc
				if(ismob(T))
					T = T.loc
				U.put_in_hands(cartridge)
				scanmode = SCANMODE_NONE
				if (cartridge.radio)
					cartridge.radio.hostpda = null
				cartridge = null
				update_icon()

//MENU FUNCTIONS===================================

		if("0")//Hub
			mode = 0
		if("2")//Messenger
			mode = 2
		if("21")//Read messeges
			mode = 21
		if("3")//Atmos scan
			mode = 3
		if("4")//Redirects to hub
			mode = 0

//Fuck this shit this file makes no sense FUNCTIONS===

		if ("delivery_bot")
			mode = PDA_MODE_DELIVERY_BOT

//APPLICATIONS FUNCTIONS===========================
		if("appMode")
			current_app = locate(href_list["appChoice"]) in applications
			current_app.on_select(U)
			no_refresh = current_app.no_refresh //If set in on_select
			current_app.no_refresh = FALSE //Resets for next time
			if(current_app.has_screen)
				mode = PDA_MODE_APP

			if(current_app.assets_type && usr.client)
				assets_to_send = new current_app.assets_type()

//MAIN FUNCTIONS===================================

		if("Light")
			if(fon)
				fon = 0
				set_light(0)
			else
				fon = 1
				set_light(f_lum)
		if("Halogen Counter")
			if(scanmode == SCANMODE_HALOGEN)
				scanmode = SCANMODE_NONE
			else if((!isnull(cartridge)) && (cartridge.access_engine))
				scanmode = SCANMODE_HALOGEN
		if("Honk")
			if ( !(last_honk && world.time < last_honk + 20) )
				playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
				last_honk = world.time
		if("Gas Scan")
			if(scanmode == SCANMODE_ATMOS)
				scanmode = SCANMODE_NONE
			else if((!isnull(cartridge)) && (cartridge.access_atmos))
				scanmode = SCANMODE_ATMOS
		if("Cyborg Analyzer")
			if(scanmode == SCANMODE_ROBOTICS)
				scanmode = SCANMODE_NONE
			else if((!isnull(cartridge)) && (cartridge.access_robotics))
				scanmode = SCANMODE_ROBOTICS
		if("PDA Camera")
			if(scanmode == SCANMODE_CAMERA)
				scanmode = SCANMODE_NONE
			else if((!isnull(cartridge)) && (cartridge.access_camera))
				scanmode = SCANMODE_CAMERA
			update_icon()
		if("Show Photos")
			mode = 1998
		if("Clear Photos")
			if(cartridge && istype(cartridge, /obj/item/weapon/cartridge/camera))
				var/obj/item/weapon/cartridge/camera/CM = cartridge
				for(var/obj/item/weapon/photo/PH in CM.stored_photos)
					qdel(PH)
				CM.stored_photos = list()

//MESSENGER/NOTE FUNCTIONS===================================

		if("Toggle Messenger")
			toff = !toff
		if("Toggle Ringer")//If viewing texts then erase them, if not then toggle silent status
			silent = !silent
		if("Clear")//Clears messages
			imglist.Cut()
			tnote.Cut()
		if("Ringtone")
			var/t = input(U, "Please enter new ringtone", name, ttone) as text
			if (loc == U)
				if (t)
					if(INVOKE_EVENT(src, /event/pda_change_ringtone, "user" = U, "new_ringtone" = t))
						to_chat(U, "The PDA softly beeps.")
						U << browse(null, "window=pda")
						src.mode = 0
					else
						t = copytext(sanitize(t), 1, 20)
						ttone = t
					return
			else
				U << browse(null, "window=pda")
				return
		if("Message")
			var/obj/item/device/pda/P = locate(href_list["target"])
			src.create_message(U, P)
		if("viewPhoto")
			var/obj/item/weapon/photo/PH = locate(href_list["image"])
			PH.show(U)
		if("Multimessage")
			var/list/department_list = list("security","engineering","medical","research","cargo","service")
			var/target = input("Select a department", "CAMO Service") as null|anything in department_list
			if(!target)
				return
			var/t = input(U, "Please enter message", "Message to [target]", null) as text|null
			t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
			if (!t || toff || (!in_range(src, U) && loc != U)) //If no message, messaging is off, and we're either out of range or not in usr
				return
			if (last_text && world.time < last_text + 5)
				return
			last_text = world.time
			for(var/obj/machinery/pda_multicaster/multicaster in pda_multicasters)
				if(multicaster.check_status())
					multicaster.multicast(target,src,usr,t)
					tnote["msg_id"] = "<i><b>&rarr; To [target]:</b></i><br>[t]<br>"
					msg_id++
					return
			to_chat(usr, "[bicon(src)]<span class='warning'>The PDA's screen flashes, 'Error, CAMO server is not responding.'</span>")

		if("transferFunds")
			if(!id)
				return
			var/obj/machinery/message_server/useMS = null
			if(message_servers)
				for (var/obj/machinery/message_server/MS in message_servers)
					if(MS.is_functioning())
						useMS = MS
						break
			if(!useMS)
				to_chat(usr, "[bicon(src)]<span class='warning'>The PDA's screen flashes, 'Error, Messaging server is not responding.'</span>")
				return
			var/obj/item/device/pda/P = locate(href_list["target"])
			var/datum/signal/signal = src.telecomms_process()

			var/useTC = 0
			if(signal)
				if(signal.data["done"])
					useTC = 1
					var/turf/pos = get_turf(P)
					if(pos.z in signal.data["level"])
						useTC = 2

			if(!useTC) // only send the message if it's stable
				to_chat(usr, "[bicon(src)]<span class='warning'>The PDA's screen flashes, 'Error, Unable to receive signal from local subspace comms. PDA outside of comms range.'</span>")
				return
			if(useTC != 2) // Does our recepient have a broadcaster on their level?
				to_chat(usr, "[bicon(src)]<span class='warning'>The PDA's screen flashes, 'Error, Unable to receive handshake signal from recipient PDA. Recipient PDA outside of comms range.'</span>")
				return

			var/amount = round(input("How much money do you wish to transfer to [P.owner]?", "Money Transfer", 0) as num)
			if(!amount || (amount < 0) || (id.virtual_wallet.money <= 0))
				to_chat(usr, "[bicon(src)]<span class='warning'>The PDA's screen flashes, 'Invalid value.'</span>")
				return
			if(amount > id.virtual_wallet.money)
				amount = id.virtual_wallet.money

			switch(P.receive_funds(owner,amount,name))
				if(1)
					to_chat(usr, "[bicon(src)]<span class='notice'>The PDA's screen flashes, 'Transaction complete!'</span>")
				if(2)
					to_chat(usr, "[bicon(src)]<span class='notice'>The PDA's screen flashes, 'Transaction complete! The recipient will earn the funds once he enters his ID in his PDA.'</span>")
				else
					to_chat(usr, "[bicon(src)]<span class='warning'>The PDA's screen flashes, 'Error, transaction canceled'</span>")
					return

			id.virtual_wallet.money -= amount
			new /datum/transaction(id.virtual_wallet, "Money transfer", "-[amount]", src.name, P.owner)

		if("Send Honk")//Honk virus
			if(istype(cartridge, /obj/item/weapon/cartridge/clown))//Cartridge checks are kind of unnecessary since everything is done through switch.
				var/obj/item/device/pda/P = locate(href_list["target"])//Leaving it alone in case it may do something useful, I guess.
				if(!isnull(P))
					if (!P.toff && cartridge:honk_charges > 0)
						cartridge:honk_charges--
						U.show_message("<span class='notice'>Virus sent!</span>", 1)
						P.honkamt = (rand(15,20))
				else
					to_chat(U, "PDA not found.")
			else
				U << browse(null, "window=pda")
				return
		if("Send Silence")//Silent virus
			if(istype(cartridge, /obj/item/weapon/cartridge/mime))
				var/obj/item/device/pda/P = locate(href_list["target"])
				if(!isnull(P))
					if (!P.toff && cartridge:mime_charges > 0)
						cartridge:mime_charges--
						U.show_message("<span class='notice'>Virus sent!</span>", 1)
						P.silent = 1
						P.ttone = "silence"
				else
					to_chat(U, "PDA not found.")
			else
				U << browse(null, "window=pda")
				return
		if("Eject Photo")
			if(photo)
				U.put_in_hands(photo)
				photo = null


//TRADER FUNCTIONS======================================
		if("Send Shuttle")
			if(cartridge && cartridge.access_trader && id && can_access(id.access,list(access_trade)))
				var/obj/machinery/computer/shuttle_control/C = global.trade_shuttle.control_consoles[1] //There should be exactly one
				if(C)
					global.trade_shuttle.travel_to(pick(global.trade_shuttle.docking_ports - global.trade_shuttle.current_port),C,U) //Just send it; this has all relevant checks


//SYNDICATE FUNCTIONS===================================

		if("Detonate")//Detonate PDA
			if(istype(cartridge, /obj/item/weapon/cartridge/syndicate))
				var/obj/item/device/pda/P = locate(href_list["target"])
				if(isnull(P))
					to_chat(U, "PDA not found.")
				else
					var/pass = FALSE
					for (var/obj/machinery/message_server/MS in message_servers)
						if(MS.is_functioning())
							pass = TRUE
							break
					if(!pass)
						to_chat(U, "<span class='notice'>ERROR: Messaging server is not responding.</span>")
					else
						if (!P.toff && cartridge:shock_charges > 0)

							var/difficulty = 0

							if(P.cartridge)
								if(locate(/datum/pda_app/cart/medical_records) in P.cartridge)
									difficulty += 1
								if(locate(/datum/pda_app/cart/security_records) in P.cartridge)
									difficulty += 1
								difficulty += P.cartridge.access_engine
								difficulty += P.cartridge.access_clown
								difficulty += P.cartridge.access_janitor
								difficulty += 2
							else
								difficulty += 2

							if(P.get_component(/datum/component/uplink))
								U.show_message("<span class='warning'>An error flashes on your [src]; [pick(syndicate_code_response)]</span>", 1)
								U << browse(null, "window=pda")
								create_message(null, P, null, null, pick(syndicate_code_phrase)) //friendly fire
								log_admin("[key_name(U)] attempted to blow up syndicate [P] with the Detomatix cartridge but failed")
								message_admins("[key_name_admin(U)] attempted to blow up syndicate [P] with the Detomatix cartridge but failed", 1)
								cartridge:shock_charges--
							else if (!P.detonate || prob(difficulty * 2))
								U.show_message("<span class='warning'>An error flashes on your [src]; [pick("Encryption","Connection","Verification","Handshake","Detonation","Injection")] error!</span>", 1)
								U << browse(null, "window=pda")
								var/list/garble = list()
								var/randomword
								for(garble = list(), garble.len<10,garble.Add(randomword))
									randomword = pick("stack.Insert","KillProcess(","-DROP TABLE","kernel = "," / 0",";",";;","{","(","((","<"," ","-", "null", " * 1.#INF")
								var/message = english_list(garble, "", "", "", "")
								create_message(null, P, null, null, message) //the jig is up
								log_admin("[key_name(U)] attempted to blow up [P] with the Detomatix cartridge but failed")
								message_admins("[key_name_admin(U)] attempted to blow up [P] with the Detomatix cartridge but failed", 1)
								cartridge:shock_charges--
							else
								U.show_message("<span class='notice'>Success!</span>", 1)
								log_admin("[key_name(U)] attempted to blow up [P] with the Detomatix cartridge and succeeded")
								message_admins("[key_name_admin(U)] attempted to blow up [P] with the Detomatix cartridge and succeeded", 1)
								cartridge:shock_charges--
								P.explode(U)
			else
				U.unset_machine()
				U << browse(null, "window=pda")
				return

//pAI FUNCTIONS===================================
		if("pai")
			switch(href_list["option"])
				if("1")		// Configure pAI device
					pai.attack_self(U)
				if("2")		// Eject pAI device
					U.put_in_hands(pai)

//LINK FUNCTIONS===================================

		else//Cartridge menu linking
			mode = text2num(href_list["choice"])
			if(cartridge)
				cartridge.mode = mode
				cartridge.unlock()


//EXTRA FUNCTIONS===================================

	if (mode == 2||mode == 21)//To clear message overlays.
		overlays.len = 0

	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)

	if (!no_refresh)
		if(U.machine == src && href_list["skiprefresh"]!="1")//Final safety.
			attack_self(U)//It auto-closes the menu prior if the user is not in range and so on.
		else
			U.unset_machine()
			U << browse(null, "window=pda")

//Receive money transferred from another PDA
/obj/item/device/pda/proc/receive_funds(var/creditor_name,var/arbitrary_sum,var/other_pda)
	var/datum/pda_app/balance_check/app = locate(/datum/pda_app/balance_check) in applications
	if(!app.linked_db)
		app.reconnect_database()
	if(!app.linked_db || !app.linked_db.activated || app.linked_db.stat & (BROKEN|NOPOWER))
		return 0 //This sends its own error message
	var/turf/U = get_turf(src)
	if(!silent)
		playsound(U, 'sound/machines/twobeep.ogg', 50, 1)

	for (var/mob/O in hearers(3, U))
		if(!silent)
			O.show_message(text("[bicon(src)] *[src.ttone]*"))

	var/mob/living/L = null
	if(src.loc && isliving(src.loc))
		L = src.loc
	else
		L = get_holder_of_type(src, /mob/living/silicon)

	if(L)
		to_chat(L, "[bicon(src)] <b>Money transfer from [creditor_name] ([arbitrary_sum]$) </b>[id ? "" : "Insert your ID in the PDA to receive the funds."]")

	tnote["msg_id"] = "<i><b>&larr; Money transfer from [creditor_name] ([arbitrary_sum]$)<br>"
	msg_id++

	if(id)
		if(!id.virtual_wallet)
			id.update_virtual_wallet()
		id.virtual_wallet.money += arbitrary_sum
		new /datum/transaction(id.virtual_wallet, "Money transfer", arbitrary_sum, other_pda, creditor_name, send2PDAs = FALSE)
		return 1
	else
		incoming_transactions |= list(list(creditor_name,arbitrary_sum,other_pda))
		return 2

//Receive money transferred from another PDA
/obj/item/device/pda/proc/receive_incoming_transactions(var/obj/item/weapon/card/id/ID_card)
	var/mob/living/L = null
	if(src.loc && isliving(src.loc))
		L = src.loc
	to_chat(L, "[bicon(src)]<span class='notice'> <b>Transactions successfully received! </b></span>")

	for(var/transac in incoming_transactions)
		if(!id.virtual_wallet)
			id.update_virtual_wallet()
		id.virtual_wallet.money += transac[2]
		new /datum/transaction(id.virtual_wallet, "Money transfer", transac[2], transac[3], transac[1])

	incoming_transactions = list()

/obj/item/device/pda/proc/remove_id()
	if (id)
		if (ismob(loc))
			var/mob/M = loc
			M.put_in_hands(id)
			to_chat(usr, "<span class='notice'>You remove \the [id] from the [name].</span>")
		else
			id.forceMove(get_turf(src))
		id = null

/obj/item/device/pda/proc/create_message(var/mob/living/U = usr, var/obj/item/device/pda/P, var/multicast_message = null, obj/item/device/pda/reply_to, var/overridemessage)
	if(!reply_to)
		reply_to = src
	if (!istype(P)||P.toff)
		return
	var/t = null
	if(overridemessage)
		t = overridemessage
	if(multicast_message)
		t = multicast_message
	if(!t)
		t = input(U, "Please enter message", "Message to [P]", null) as text|null
		t = copytext(parse_emoji(sanitize(t)), 1, MAX_MESSAGE_LEN)
		if (!t || toff || (!in_range(src, U) && loc != U)) //If no message, messaging is off, and we're either out of range or not in usr
			return

		if (last_text && world.time < last_text + 5)
			return
		last_text = world.time
	// check if telecomms I/O route 1459 is stable
	//var/telecomms_intact = telecomms_process(P.owner, owner, t)
	var/obj/machinery/message_server/useMS = null
	if(message_servers)
		for (var/obj/machinery/message_server/MS in message_servers)
		//PDAs are now dependant on the Message Server.
			if(MS.is_functioning())
				useMS = MS
				break

	var/datum/signal/signal = src.telecomms_process()

	var/useTC = 0
	if(signal)
		if(signal.data["done"])
			useTC = 1
			var/turf/pos = get_turf(P)
			if(pos.z in signal.data["level"])
				useTC = 2
				//Let's make this barely readable
				if(signal.data["compression"] > 0)
					t = Gibberish(t, signal.data["compression"] + 50)

	if(useMS && useTC) // only send the message if it's stable
		if(useTC != 2) // Does our recepient have a broadcaster on their level?
			to_chat(U, "ERROR: Cannot reach recepient.")
			return

		var/obj/item/weapon/photo/current_photo = null

		if(photo)
			current_photo = photo

		if(cartridge && istype(cartridge, /obj/item/weapon/cartridge/camera))
			var/obj/item/weapon/cartridge/camera/CM = cartridge
			if(CM.stored_photos.len)
				current_photo = input(U, "Photos found in [cartridge]. Please select one", "Cartridge Photo Selection") as null|anything in CM.stored_photos

		if(current_photo)
			imglist["[msg_id]"] = current_photo.img
			P.imglist["[msg_id]"] = current_photo.img

		useMS.send_pda_message("[P.owner]","[owner]","[t]",imglist["[msg_id]"])

		tnote["[msg_id]"] = "<i><b>&rarr; To [P.owner]:</b></i><br>[t]<br>"
		P.tnote["[msg_id]"] = "<i><b>&larr; From <a href='byond://?src=\ref[P];choice=Message;target=\ref[reply_to]'>[owner]</a> ([ownjob]):</b></i><br>[t]<br>"
		msg_id++
		for(var/mob/dead/observer/M in player_list)
			if(!multicast_message && M.stat == DEAD && M.client && (M.client.prefs.toggles & CHAT_GHOSTPDA)) // src.client is so that ghosts don't have to listen to mice
				M.show_message("<a href='?src=\ref[M];follow=\ref[U]'>(Follow)</a> <span class='game say'>PDA Message - <span class='name'>\
					[U.real_name][U.real_name == owner ? "" : " (as [owner])"]</span> -> <span class='name'>[P.owner]</span>: <span class='message'>[t]</span>\
					[photo ? " (<a href='byond://?src=\ref[P];choice=viewPhoto;image=\ref[photo];skiprefresh=1;target=\ref[reply_to]'>View Photo</a>)</span>" : ""]")


		if (prob(15)&&!multicast_message) //Give the AI a chance of intercepting the message
			var/who = src.owner
			if(prob(50))
				who = P:owner
			for(var/mob/living/silicon/ai/ai in mob_list)
				// Allows other AIs to intercept the message but the AI won't intercept their own message.
				if(ai.aiPDA != P && ai.aiPDA != src)
					ai.show_message("<i>Intercepted message from <b>[who]</b>: [t]</i>")

		if (!P.silent)
			playsound(P.loc, 'sound/machines/twobeep.ogg', 50, 1)
		for (var/mob/O in hearers(3, P.loc))
			if(!P.silent)
				O.show_message(text("[bicon(P)] *[P.ttone]*"))
		//Search for holder of the PDA.
		var/mob/living/L = null
		if(P.loc && isliving(P.loc))
			L = P.loc
		//Maybe they are a pAI!
		else
			L = get_holder_of_type(P, /mob/living/silicon)

		if(L)
			L.show_message("[bicon(P)] <b>Message from [src.owner] ([ownjob]), </b>\"[t]\" [photo ? "(<a href='byond://?src=\ref[P];choice=viewPhoto;image=\ref[photo];skiprefresh=1;target=\ref[reply_to]'>View Photo</a>)" : ""] (<a href='byond://?src=\ref[P];choice=Message;skiprefresh=1;target=\ref[reply_to]'>Reply</a>)", 2)
		U.show_message("[bicon(src)] <span class='notice'>Message for <a href='byond://?src=\ref[src];choice=Message;skiprefresh=1;target=\ref[P]'>[P]</a> has been sent.</span>")
		log_pda("[key_name(usr)] (PDA: [src.name]) sent \"[t]\" to [P.name]")
		P.overlays.len = 0
		if(P.show_overlays)
			P.overlays += image('icons/obj/pda.dmi', "pda-r")
	else
		to_chat(U, "[bicon(src)] <span class='notice'>ERROR: Messaging server is not responding.</span>")


/obj/item/device/pda/verb/verb_remove_id()
	set category = "Object"
	set name = "Remove id"
	set src in usr

	if(issilicon(usr))
		return

	if ( can_use(usr) )
		if(id)
			remove_id()
		else
			to_chat(usr, "<span class='notice'>This PDA does not have an ID in it.</span>")
	else
		to_chat(usr, "<span class='notice'>You cannot do this while restrained.</span>")

/obj/item/device/pda/CtrlClick()
	if ( can_use(usr) ) // Checks that the PDA is in our inventory. This will be checked by the proc anyways, but we don't want to generate an error message if not.
		verb_remove_pen(usr)
		return
	return ..()

/obj/item/device/pda/verb/verb_remove_pen()
	set category = "Object"
	set name = "Remove pen"
	set src in usr

	if(issilicon(usr))
		return

	if ( can_use(usr) )
		var/obj/item/weapon/pen/O = locate() in src
		if(O)
			if (istype(loc, /mob))
				var/mob/M = loc
				if(M.get_active_hand() == null)
					M.put_in_hands(O)
					to_chat(usr, "<span class='notice'>You remove \the [O] from \the [src].</span>")
					return
			O.forceMove(get_turf(src))
		else
			to_chat(usr, "<span class='notice'>This PDA does not have a pen in it.</span>")
	else
		to_chat(usr, "<span class='notice'>You cannot do this while restrained.</span>")

/obj/item/device/pda/AltClick()
	if ( can_use(usr) ) // Checks that the PDA is in our inventory. This will be checked by the proc anyways, but we don't want to generate an error message if not.
		verb_remove_id(usr)
		return
	return ..()

/obj/item/device/pda/proc/id_check(mob/user as mob, choice as num)//To check for IDs; 1 for in-pda use, 2 for out of pda use.
	if(choice == 1)
		if (id)
			remove_id()
		else
			var/obj/item/I = user.get_active_hand()
			if (istype(I, /obj/item/weapon/card/id))
				if(user.drop_item(I, src))
					id = I
	else
		var/obj/item/weapon/card/I = user.get_active_hand()
		if (istype(I, /obj/item/weapon/card/id) && I:registered_name)
			var/obj/old_id = id
			if(user.drop_item(I, src))
				id = I
				user.put_in_hands(old_id)
	if(id && incoming_transactions.len)
		receive_incoming_transactions(id)
	return

// access to status display signals
/obj/item/device/pda/attackby(obj/item/C as obj, mob/user as mob)
	. = ..()
	if(.)
		return
	if(istype(C, /obj/item/weapon/cartridge) && !cartridge)
		if(user.drop_item(C, src))
			cartridge = C
			to_chat(user, "<span class='notice'>You insert [cartridge] into [src].</span>")
			update_icon()
			if(cartridge.radio)
				cartridge.radio.hostpda = src
			for(var/datum/pda_app/app in cartridge.applications)
				if(istype(app,/datum/pda_app/cart))
					var/datum/pda_app/cart/cart_app = app
					cart_app.onInstall(src,cartridge)
				else
					app.onInstall(src)

	else if(istype(C, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/idcard = C
		if(!idcard.registered_name)
			to_chat(user, "<span class='notice'>\The [src] rejects the ID.</span>")
			return
		if(!owner)
			owner = idcard.registered_name
			ownjob = idcard.assignment
			name = "PDA-[owner] ([ownjob])"
			to_chat(user, "<span class='notice'>Card scanned.</span>")
		else
			//Basic safety check. If either both objects are held by user or PDA is on ground and card is in hand.
			if(((src in user.contents) && (C in user.contents)) || (istype(loc, /turf) && in_range(src, user) && (C in user.contents)) )
				if( can_use(user) )//If they can still act.
					id_check(user, 2)
					to_chat(user, "<span class='notice'>You put \the [C] into \the [src]'s slot.</span>")
					if(incoming_transactions.len)
						receive_incoming_transactions(id)
					updateSelfDialog()//Update self dialog on success.
			return	//Return in case of failed check or when successful.
		updateSelfDialog()//For the non-input related code.
	else if(istype(C, /obj/item/device/paicard) && !src.pai)
		if(user.drop_item(C, src))
			pai = C
			to_chat(user, "<span class='notice'>You slot \the [C] into [src].</span>")
			updateUsrDialog()
	else if(istype(C, /obj/item/weapon/photo) && !src.photo)
		if(user.drop_item(C, src))
			photo = C
			to_chat(user, "<span class='notice'>You slot \the [C] into [src].</span>")
			updateUsrDialog()
	else if(istype(C, /obj/item/weapon/pen))
		var/obj/item/weapon/pen/O = locate() in src
		if(O)
			to_chat(user, "<span class='notice'>There is already a pen in \the [src].</span>")
		else
			if(user.drop_item(C, src))
				to_chat(user, "<span class='notice'>You slide \the [C] into \the [src].</span>")
	else if(istype(C,/obj/item/weapon/spacecash))
		if(!id)
			to_chat(user, "[bicon(src)]<span class='warning'>There is no ID in the PDA!</span>")
			return
		var/obj/item/weapon/spacecash/dosh = C
		if(add_to_virtual_wallet(dosh.worth * dosh.amount, user))
			to_chat(user, "<span class='info'>You insert [dosh.worth * dosh.amount] credit\s into the PDA.</span>")
			qdel(dosh)
		updateDialog()

/obj/item/device/pda/proc/add_to_virtual_wallet(var/amount, var/mob/user, var/atom/giver)
	if(!id)
		return 0
	if(id.add_to_virtual_wallet(amount, user, giver))
		if(prob(50))
			playsound(loc, 'sound/items/polaroid1.ogg', 50, 1)
		else
			playsound(loc, 'sound/items/polaroid2.ogg', 50, 1)
		return 1
	return 0

/obj/item/device/pda/attack(mob/living/carbon/C, mob/living/user as mob)
	if(istype(C))
		switch(scanmode)

			if(SCANMODE_MEDICAL)
				healthanalyze(C,user,1)

			if(SCANMODE_FORENSIC)
				if (!istype(C:dna, /datum/dna))
					to_chat(user, "<span class='notice'>No fingerprints found on [C]</span>")
				else if(!istype(C, /mob/living/carbon/monkey))
					if(!isnull(C:gloves))
						to_chat(user, "<span class='notice'>No fingerprints found on [C]</span>")
				else
					to_chat(user, text("<span class='notice'>[C]'s Fingerprints: [md5(C.dna.uni_identity)]</span>"))
				if ( !(C:blood_DNA) )
					to_chat(user, "<span class='notice'>No blood found on [C]</span>")
					if(C:blood_DNA)
						qdel(C:blood_DNA)
						C:blood_DNA = null
				else
					to_chat(user, "<span class='notice'>Blood found on [C]. Analysing...</span>")
					spawn(15)
						for(var/blood in C:blood_DNA)
							to_chat(user, "<span class='notice'>Blood type: [C:blood_DNA[blood]]\nDNA: [blood]</span>")

			if(SCANMODE_HALOGEN)
				for (var/mob/O in viewers(C, null))
					O.show_message("<span class='warning'>[user] has analyzed [C]'s radiation levels!</span>", 1)

				user.show_message("<span class='notice'>Analyzing Results for [C]:</span>")
				if(C.radiation)
					user.show_message("<span class='good'>Radiation Level: </span>[C.radiation]")
				else
					user.show_message("<span class='notice'>No radiation detected.</span>")

/obj/item/device/pda/afterattack(atom/A, mob/user, proximity_flag)
	if(scanmode == SCANMODE_ATMOS)
		if(!atmos_analys || !proximity_flag)
			return
		atmos_analys.cant_drop = 1
		if(!A.attackby(atmos_analys, user))
			atmos_analys.afterattack(A, user, 1)

	else if(scanmode == SCANMODE_ROBOTICS)
		if(!robo_analys || !proximity_flag)
			return
		robo_analys.cant_drop = 1
		if(!A.attackby(robo_analys, user))
			robo_analys.afterattack(A, user, 1)

	else if(scanmode == SCANMODE_HAILER)
		if(!integ_hailer)
			return
		integ_hailer.cant_drop = 1
		integ_hailer.afterattack(A, user, proximity_flag)

	else if (scanmode == SCANMODE_CAMERA && cartridge && istype(cartridge, /obj/item/weapon/cartridge/camera))
		var/obj/item/weapon/cartridge/camera/CM = cartridge
		if(!CM.cart_cam)
			return
		CM.cart_cam.captureimage(A, user, proximity_flag)
		to_chat(user, "<span class='notice'>New photo added to camera.</span>")
		playsound(loc, "polaroid", 75, 1, -3)

	else if (!scanmode && istype(A, /obj/item/weapon/paper) && owner)
		var/datum/pda_app/notekeeper/app = locate(/datum/pda_app/notekeeper) in applications
		if(app)
			app.note = A:info
			to_chat(user, "<span class='notice'>Paper scanned.</span>")//concept of scanning paper copyright brainoblivion 2009

/obj/item/device/pda/preattack(atom/A as mob|obj|turf|area, mob/user as mob)
	switch(scanmode)
		if(SCANMODE_REAGENT)
			if(!A.Adjacent(user))
				return
			if(!isnull(A.reagents))
				if(A.reagents.reagent_list.len > 0)
					var/reagents_length = A.reagents.reagent_list.len
					to_chat(user, "<span class='notice'>[reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found.</span>")
					for (var/datum/reagent/re in A.reagents.reagent_list)
						to_chat(user, "<span class='notice'>\t [re]: [re.volume] units</span>")
				else
					to_chat(user, "<span class='notice'>No active chemical agents found in [A].</span>")
			else
				to_chat(user, "<span class='notice'>No significant chemical agents found in [A].</span>")
			. = 1

		if (SCANMODE_DEVICE)
			if(dev_analys) //let's use this instead. Much neater
				dev_analys.cant_drop = 1
				dev_analys.max_designs = 5
				if(A.Adjacent(user))
					return dev_analys.preattack(A, user, 1)

/obj/item/device/pda/proc/explode(var/mob/user) //This needs tuning.
	var/turf/T = get_turf(src.loc)

	if (ismob(loc))
		var/mob/M = loc
		M.show_message("<span class='warning'>Your [src] explodes!</span>", 1)

	if(T)
		T.hotspot_expose(700,125,surfaces=istype(loc,/turf))

		explosion(T, -1, -1, 2, 3, whodunnit = user)

	qdel(src)
	return

/obj/item/device/pda/Destroy()
	PDAs -= src

	if (src.id)
		src.id.forceMove(get_turf(src.loc))
		id = null

	if(src.pai)
		src.pai.forceMove(get_turf(src.loc))
		pai = null

	if(cartridge)
		if (cartridge.radio)
			cartridge.radio.hostpda = null
		qdel(cartridge)
		cartridge = null

	if(atmos_analys)
		qdel(atmos_analys)
		atmos_analys = null

	if(robo_analys)
		qdel(robo_analys)
		robo_analys = null

	if(dev_analys)
		qdel(dev_analys)
		dev_analys = null

	for(var/A in applications)
		qdel(A)

	..()

/obj/item/device/pda/Del()
	var/loop_count = 0
	while(null in PDAs)
		PDAs.Remove(null)
		if(loop_count > 10)
			break
		loop_count++
	PDAs -= src
	..()

/obj/item/device/pda/dropped(var/mob/user)
	var/datum/pda_app/station_map/map_app = locate(/datum/pda_app/station_map) in applications
	if (map_app && map_app.holomap)
		map_app.holomap.stopWatching()

/obj/item/device/pda/clown/Crossed(AM as mob|obj) //Clown PDA is slippery.
	if (istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		if (M.Slip(8, 5, 1))
			to_chat(M, "<span class='notice'>You slipped on the PDA!</span>")

			if ((istype(M, /mob/living/carbon/human) && (M.real_name != src.owner) && (istype(src.cartridge, /obj/item/weapon/cartridge/clown))))
				var/obj/item/weapon/cartridge/clown/honkcartridge = src.cartridge
				if (honkcartridge.honk_charges < 5)
					honkcartridge.honk_charges++

/obj/item/device/pda/proc/available_pdas()
	var/list/names = list()
	var/list/plist = list()
	var/list/namecounts = list()

	if (toff)
		to_chat(usr, "Turn on your receiver in order to send messages.")
		return

	for (var/obj/item/device/pda/P in PDAs)
		if (!P.owner)
			continue
		else if(P.hidden)
			continue
		else if (P == src)
			continue
		else if (P.toff)
			continue

		var/name = P.owner
		if (name in names)
			namecounts[name]++
			name = text("[name] ([namecounts[name]])")
		else
			names.Add(name)
			namecounts[name] = 1

		plist[text("[name]")] = P
	return plist


//Some spare PDAs in a box
/obj/item/weapon/storage/box/PDAs
	name = "spare PDAs"
	desc = "A box of spare PDA microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdabox"

/obj/item/weapon/storage/box/PDAs/New()
	..()
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)
	new /obj/item/weapon/cartridge/head(src)

	var/newcart = pick(	/obj/item/weapon/cartridge/engineering,
						/obj/item/weapon/cartridge/security,
						/obj/item/weapon/cartridge/medical,
						/obj/item/weapon/cartridge/signal/toxins,
						/obj/item/weapon/cartridge/quartermaster)
	new newcart(src)

// Pass along the pulse to atoms in contents, largely added so pAIs are vulnerable to EMP
/obj/item/device/pda/emp_act(severity)
	for(var/atom/A in src)
		A.emp_act(severity)

/proc/get_viewable_pdas()
	. = list()
	// Returns a list of PDAs which can be viewed from another PDA/message monitor.
	for(var/obj/item/device/pda/P in PDAs)
		if(!P.owner || P.toff || P.hidden)
			continue
		. += P
	return .

#undef PDA_MINIMAP_WIDTH
