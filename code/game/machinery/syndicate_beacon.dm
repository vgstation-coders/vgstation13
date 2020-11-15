//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

//  Beacon randomly spawns in space
//	When a non-traitor (no special role in /mind) uses it, he is given the choice to become a traitor
//	If he accepts there is a random chance he will be accepted, rejected, or rejected and killed
//	Bringing certain items can help improve the chance to become a traitor


/obj/machinery/syndicate_beacon
	name = "syndicate beacon"
	desc = "This looks suspicious..."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"

	anchored = 0
	density = 1
	mech_flags = MECH_SCAN_FAIL

	var/temptext = ""
	var/selfdestructing = FALSE
	var/ready= TRUE

/obj/machinery/syndicate_beacon/Destroy()
	new /datum/artifact_postmortem_data(src)
	..()

/obj/machinery/syndicate_beacon/attack_hand(var/mob/user)
	if(isobserver(user))
		to_chat(user, "<span class='rose'>Your ghostly hand goes right through!</span>")
		return

	user.set_machine(src)

	var/dat = "<body link='yellow' alink='white' bgcolor='#601414'><font color='white'>"
	dat += "<i>Scanning [pick("retina pattern", "voice print", "fingerprints", "dna sequence")]...<br>Identity confirmed,<br></i>"
	if (istype(user, /mob/living/carbon/human) || istype(user, /mob/living/silicon/ai))
		if(issyndicate(user))
			dat += "<i>Operative record found. Greetings, Agent [user.real_name].</i><br>"
		else
			var/honorific = "Mr."
			if(user.gender == FEMALE)
				honorific = "Ms."
			dat += "<i>Identity not found in operative database. What can the Syndicate do for you today, [honorific] [user.real_name]?</i><br>"
			if(!selfdestructing)
				dat += "<br><br><A href='?src=\ref[src];betraitor=1'>\"[pick("I want to switch teams.", "I want to work for you.", "Let me join you.", "I can be of use to you.", "You want me working for you, and here's why...", "Give me an objective.", "How's the 401k over at the Syndicate?")]\"</A><BR>"
	dat += temptext
	dat += "</body>"
	user << browse(dat, "window=syndbeacon")
	onclose(user, "syndbeacon")

/obj/machinery/syndicate_beacon/Topic(href, href_list)
	if(..())
		return 1

	var/mob/M = usr

	if (selfdestructing || issyndicate(M))
		add_fingerprint(M)
		updateUsrDialog()
		return

	if(href_list["betraitor"])
		//antag-banned players just cause the beacon to explode
		if (jobban_isbanned(M, TRAITOR) || isantagbanned(M))
			temptext = "<i><b>Double-crosser. You planned to betray us from the start. Allow us to repay the favor in kind.</b></i>"
			updateUsrDialog()
			selfdestruct()
			return

		//so do antags that already belong to a faction (antags that don't belong to a specific factions are tolerated)
		for(var/datum/role/R in M.mind.antag_roles)
			if(R.faction)
				temptext = "<i><b>Double-crosser. You planned to betray us from the start. Allow us to repay the favor in kind.</b></i>"
				updateUsrDialog()
				selfdestruct()
				return

		if(!ready)//further attempts at using the beacon will require admin intervention.
			if (admins.len < 1)
				temptext = "<i>We have no need for you at this time. Have a pleasant day.</i><br>"
				updateUsrDialog()
				return

			var/reason = input(M, "We aren't looking to hire new agents right now, but you are free to make a case for why we should hire you.", "Cover e-mail", "You should hire me because...")
			if (!reason)
				temptext = ""
				return
			message_admins("[key_name(M)] wants to join the Syndicate by using a an already used syndicate beacon. [reason ? "Cover e-mail: [reason]" : "They didn't make a case for themselves."]. (<a href='?_src_=holder;syndbeaconpermission=1;syndbeacon=\ref[src];user=\ref[M];answer=1'>ACCEPT</a>/<a href='?_src_=holder;syndbeaconpermission=1;syndbeacon=\ref[src];user=\ref[M];answer=2'>DENY</a>/<a href='?_src_=holder;syndbeaconpermission=1;syndbeacon=\ref[src];user=\ref[M];answer=3'>DESTROY BEACON</a>)")

			temptext = "<i>Currently awaiting decision from the HR department...</i><br>"
			updateUsrDialog()
			return

		ready = FALSE

		var/datum/role/traitor/newTraitor = new
		newTraitor.AssignToRole(M.mind,1)
		newTraitor.OnPostSetup()
		newTraitor.Greet(GREET_SYNDBEACON)
		newTraitor.ForgeObjectives()
		newTraitor.AnnounceObjectives()

		message_admins("[key_name(M)]) used a syndicate beacon to become a traitor.")

		temptext = ""


	add_fingerprint(usr)
	updateUsrDialog()


/obj/machinery/syndicate_beacon/proc/ready_up()
	if (!ready)
		ready = TRUE
		playsound(src, 'sound/machines/twobeep.ogg', 50, 1)
		visible_message("[bicon(src)] request accepted, please confirm again.")
		temptext = ""
		updateUsrDialog()

/obj/machinery/syndicate_beacon/proc/selfdestruct()
	if (selfdestructing)
		return
	selfdestructing = TRUE
	spark(src, 2)
	icon_state = "syndbeacon-selfdestruct"
	spawn(rand(3 SECONDS, 6 SECONDS))
		if (!gcDestroyed)
			explosion(loc, 1, rand(1,3), rand(3,8), 10)
			if (!gcDestroyed)
				qdel(src)
