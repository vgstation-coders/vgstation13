/obj/item/device/pda/ert
	name = "ERT PDA"
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-ert"

/obj/item/device/pda/medical
	name = "Medical PDA"
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-m"

/obj/item/device/pda/medical/New()
	starting_apps += /datum/pda_app/ringer
	..()
	var/datum/pda_app/ringer/app = locate(/datum/pda_app/ringer) in applications
	if(app)
		app.frequency = deskbell_freq_medbay

/obj/item/device/pda/viro
	name = "Virology PDA"
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-v"

/obj/item/device/pda/viro/New()
	starting_apps += /datum/pda_app/ringer
	..()
	var/datum/pda_app/ringer/app = locate(/datum/pda_app/ringer) in applications
	if(app)
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
	starting_apps += /datum/pda_app/ringer
	..()
	var/datum/pda_app/ringer/app = locate(/datum/pda_app/ringer) in applications
	if(app)
		app.frequency = deskbell_freq_brig

/obj/item/device/pda/detective
	name = "Detective PDA"
	default_cartridge = /obj/item/weapon/cartridge/detective
	icon_state = "pda-det"

/obj/item/device/pda/detective/New()
	starting_apps += /datum/pda_app/light_upgrade
	..()

/obj/item/device/pda/warden
	name = "Warden PDA"
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-warden"

/obj/item/device/pda/warden/New()
	starting_apps += /datum/pda_app/ringer
	..()
	var/datum/pda_app/ringer/app = locate(/datum/pda_app/ringer) in applications
	if(app)
		app.frequency = deskbell_freq_brig

/obj/item/device/pda/janitor
	name = "Janitor PDA"
	default_cartridge = /obj/item/weapon/cartridge/janitor
	icon_state = "pda-j"

/obj/item/device/pda/janitor/New()
	..()
	var/datum/pda_app/messenger/app = locate(/datum/pda_app/messenger) in applications
	if(app)
		app.ttone = "slip"

/obj/item/device/pda/toxins
	name = "Science PDA"
	default_cartridge = /obj/item/weapon/cartridge/signal/toxins
	icon_state = "pda-tox"

/obj/item/device/pda/toxins/New()
	starting_apps += /datum/pda_app/ringer
	..()
	var/datum/pda_app/ringer/app = locate(/datum/pda_app/ringer) in applications
	if(app)
		app.frequency = deskbell_freq_rnd
	var/datum/pda_app/messenger/app2 = locate(/datum/pda_app/messenger) in applications
	if(app2)
		app2.ttone = "boom"

/obj/item/device/pda/clown
	name = "Clown PDA"
	default_cartridge = /obj/item/weapon/cartridge/clown
	icon_state = "pda-clown"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The surface is coated with polytetrafluoroethylene and banana drippings."

/obj/item/device/pda/clown/New()
	..()
	var/datum/pda_app/messenger/app = locate(/datum/pda_app/messenger) in applications
	if(app)
		app.ttone = "honk"

/obj/item/device/pda/mime
	name = "Mime PDA"
	default_cartridge = /obj/item/weapon/cartridge/mime
	icon_state = "pda-mime"

/obj/item/device/pda/mime/New()
	..()
	var/datum/pda_app/messenger/app = locate(/datum/pda_app/messenger) in applications
	if(app)
		app.silent = TRUE
		app.ttone = "silence"

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
	starting_apps += /datum/pda_app/ringer
	..()
	var/datum/pda_app/ringer/app = locate(/datum/pda_app/ringer) in applications
	if(app)
		app.frequency = deskbell_freq_hop

/obj/item/device/pda/heads/hos
	name = "Head of Security PDA"
	default_cartridge = /obj/item/weapon/cartridge/hos
	icon_state = "pda-hos"

/obj/item/device/pda/heads/hos/New()
	starting_apps += /datum/pda_app/ringer
	starting_apps += /datum/pda_app/light_upgrade
	..()
	var/datum/pda_app/ringer/app = locate(/datum/pda_app/ringer) in applications
	if(app)
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
	starting_apps += /datum/pda_app/ringer
	..()
	var/datum/pda_app/ringer/app = locate(/datum/pda_app/ringer) in applications
	if(app)
		app.frequency = deskbell_freq_medbay

/obj/item/device/pda/heads/rd
	name = "Research Director PDA"
	default_cartridge = /obj/item/weapon/cartridge/rd
	icon_state = "pda-rd"

/obj/item/device/pda/heads/rd/New()
	starting_apps += /datum/pda_app/ringer
	..()
	var/datum/pda_app/ringer/app = locate(/datum/pda_app/ringer) in applications
	if(app)
		app.frequency = deskbell_freq_rnd

/obj/item/device/pda/captain
	name = "Captain PDA"
	default_cartridge = /obj/item/weapon/cartridge/captain
	icon_state = "pda-c"
	accepted_viruses = list(
		/datum/pda_app/cart/virus/honk,
		/datum/pda_app/cart/virus/silent,
		/datum/pda_app/cart/virus/fake_uplink,
	)

/obj/item/device/pda/captain/New()
	starting_apps.Cut()
	starting_apps = get_all_installable_apps()
	..()

/obj/item/device/pda/cargo
	name = "Cargo PDA"
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-cargo"

/obj/item/device/pda/cargo/New()
	starting_apps += /datum/pda_app/ringer
	..()
	var/datum/pda_app/ringer/app = locate(/datum/pda_app/ringer) in applications
	if(app)
		app.frequency = deskbell_freq_cargo

/obj/item/device/pda/quartermaster
	name = "Quartermaster PDA"
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-q"

/obj/item/device/pda/quartermaster/New()
	starting_apps += /datum/pda_app/ringer
	..()
	var/datum/pda_app/ringer/app = locate(/datum/pda_app/ringer) in applications
	if(app)
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

/obj/item/device/pda/chaplain/New()
	..()
	var/datum/pda_app/messenger/app = locate(/datum/pda_app/messenger) in applications
	if(app)
		app.ttone = "..."

/obj/item/device/pda/lawyer
	name = "Lawyer PDA"
	default_cartridge = /obj/item/weapon/cartridge/lawyer
	icon_state = "pda-lawyer"

/obj/item/device/pda/lawyer/New()
	..()
	var/datum/pda_app/messenger/app = locate(/datum/pda_app/messenger) in applications
	if(app)
		app.ttone = "..."

/obj/item/device/pda/botanist
	name = "Botany PDA"
	//default_cartridge = /obj/item/weapon/cartridge/botanist
	icon_state = "pda-hydro"

/obj/item/device/pda/roboticist
	name = "Robotics PDA"
	default_cartridge = /obj/item/weapon/cartridge/robotics
	icon_state = "pda-robot"

/obj/item/device/pda/roboticist/New()
	starting_apps += /datum/pda_app/ringer
	..()
	var/datum/pda_app/ringer/app = locate(/datum/pda_app/ringer) in applications
	if(app)
		app.frequency = deskbell_freq_rnd

/obj/item/device/pda/librarian
	name = "Librarian PDA"
	icon_state = "pda-libb"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a WGW-11 series e-reader."

/obj/item/device/pda/librarian/New()
	starting_apps += /datum/pda_app/newsreader
	..()
	var/datum/pda_app/notekeeper/app = locate(/datum/pda_app/notekeeper) in applications
	if(app)
		app.note = "Congratulations, your station has chosen the Thinktronic 5290 WGW-11 Series E-reader and Personal Data Assistant!"
	var/datum/pda_app/messenger/app2 = locate(/datum/pda_app/messenger) in applications
	if(app2)
		app2.silent = TRUE //Quiet in the library!

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
	accepted_viruses = list(
		/datum/pda_app/cart/virus/honk,
		/datum/pda_app/cart/virus/silent,
	)

/obj/item/device/pda/ai/New()
	starting_apps += /datum/pda_app/spam_filter
	..()
	var/datum/pda_app/messenger/app = locate(/datum/pda_app/messenger) in applications
	if(app)
		app.ttone = "data"

/obj/item/device/pda/ai/proc/set_name_and_job(newname as text, newjob as text)
	owner = newname
	ownjob = newjob
	name = newname + " (" + ownjob + ")"


//AI verb and proc for sending PDA messages.
/mob/living/silicon/ai/proc/cmd_send_pdamesg()
	var/list/names = list()
	var/list/plist = list()
	var/list/namecounts = list()

	if(usr.isDead())
		to_chat(usr, "You can't send PDA messages because you are dead!")
		return

	var/datum/pda_app/messenger/message_app = locate(/datum/pda_app/messenger) in aiPDA.applications
	if(!message_app)
		to_chat(usr, "You don't have a messenger to speak with!")
		return
	if(message_app.toff)
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
		if(alert("Would you like to attach photo to this message?", "Add Photo Attachment?", "Yes", "No") == "No")
			message_app.create_message(src, selected)
			aiPDA.photo = null
			return
		var/list/nametemp = list()
		for(var/datum/picture/t in aicamera.aipictures)
			nametemp += t.fields["name"]
		var/find = input("Select image") as null|anything in nametemp
		if(!find)
			message_app.create_message(src, selected)
			aiPDA.photo = null
			return
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

	message_app.create_message(src, selected)
	aiPDA.photo = null

//AI verb and proc for sending PDA messages.
/obj/item/device/pda/ai/verb/cmd_send_pdamesg()
	set category = "AI Commands"
	set name = "Send Message"
	set src in usr
	if(usr.isDead())
		to_chat(usr, "You can't send PDA messages because you are dead!")
		return
	var/datum/pda_app/messenger/message_app = locate(/datum/pda_app/messenger) in applications
	if(!message_app)
		to_chat(usr, "You don't have a messenger to speak with!")
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

		message_app.create_message(usr, selected)
		photo = null


/obj/item/device/pda/ai/verb/cmd_toggle_pda_receiver()
	set category = "AI Commands"
	set name = "Toggle Sender/Receiver"
	set src in usr
	if(usr.isDead())
		to_chat(usr, "You can't do that because you are dead!")
		return
	var/datum/pda_app/messenger/app = locate(/datum/pda_app/messenger) in applications
	if(!app)
		to_chat(usr, "You don't have a messenger to toggle!")
		return
	app.toff = !app.toff
	to_chat(usr, "<span class='notice'>PDA sender/receiver toggled [(app.toff ? "Off" : "On")]!</span>")


/obj/item/device/pda/ai/verb/cmd_toggle_pda_silent()
	set category = "AI Commands"
	set name = "Toggle Ringer"
	set src in usr
	if(usr.isDead())
		to_chat(usr, "You can't do that because you are dead!")
		return
	var/datum/pda_app/messenger/app = locate(/datum/pda_app/messenger) in applications
	if(!app)
		to_chat(usr, "You don't have a messenger to toggle!")
		return
	app.silent=!app.silent
	to_chat(usr, "<span class='notice'>PDA ringer toggled [(app.silent ? "Off" : "On")]!</span>")


/obj/item/device/pda/ai/verb/cmd_show_message_log()
	set category = "AI Commands"
	set name = "Show Message Log"
	set src in usr
	if(usr.isDead())
		to_chat(usr, "You can't do that because you are dead!")
		return
	var/datum/pda_app/messenger/app = locate(/datum/pda_app/messenger) in applications
	if(!app)
		to_chat(usr, "You don't have a messenger to read!")
		return
	var/dat = "<html><head><title>AI PDA Message Log</title></head><body>"
	for(var/note in app.tnote)
		dat += app.tnote[note]
		var/icon/img = app.imglist[note]
		if(img)
			usr << browse_rsc(img, "tmp_photo_[note].png")
			dat += "<img src='tmp_photo_[note].png' width = '192' style='-ms-interpolation-mode:nearest-neighbor'><BR>"
	dat += "</body></html>"
	usr << browse(dat, "window=log;size=400x444;border=1;can_resize=1;can_close=1;can_minimize=0")

/mob/living/silicon/ai/proc/cmd_show_message_log()
	if(usr.isDead())
		to_chat(usr, "You can't do that because you are dead!")
		return
	var/datum/pda_app/messenger/app = locate(/datum/pda_app/messenger) in aiPDA.applications
	if(!app)
		to_chat(usr, "You don't have a messenger to read!")
		return
	if(!isnull(aiPDA))
		var/dat = "<html><head><title>AI PDA Message Log</title></head><body>"
		for(var/note in app.tnote)
			dat += app.tnote[note]
			var/icon/img = app.imglist[note]
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

/obj/item/device/pda/ai/pai/New()
	..()
	var/datum/pda_app/messenger/app = locate(/datum/pda_app/messenger) in applications
	if(app)
		app.ttone = "assist"
