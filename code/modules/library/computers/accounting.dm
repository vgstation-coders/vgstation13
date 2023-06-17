/obj/machinery/computer/accounting
	name = "accounting computer"
	desc = "For virtual bookkeeping. This computer is used in the calculation of overages."
	pass_flags = PASSTABLE
	machine_flags = WRENCHMOVE | FIXED2WORK
	icon = 'icons/obj/library.dmi'
	icon_state = "computer"
	req_access = list(access_library)
	var/savings = 0 //Total savings this cycle
	var/oldgood = -1 //Was our last calculation correct? -1 indicates no last query this cycle, resets to -1 at cycle end, 0 is bad, 1 is good
	var/oldentry = 0 //Our last attempted difference

	var/minuend
	var/subtrahend
	var/oldquery
	var/currentqueryname
	var/nextmin
	var/nextsub
	var/entryinfo = "<big>Accounting Report</big><BR>"
	var/list/contributors = list()

/obj/machinery/computer/accounting/New()
	..()
	generatenext()
	readynext()

/obj/machinery/computer/accounting/Destroy()
	contributors.Cut()
	..()

/obj/machinery/computer/accounting/attack_hand(mob/user as mob)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN|FORCEDISABLE))
		return
	ui_interact(user)

/obj/machinery/computer/accounting/ui_interact(mob/user, ui_key="main", datum/nanoui/ui=null, var/force_open=NANOUI_FOCUS)
	user.set_machine(src)

	var/data[0]
	data["src"] = "\ref[src]"
	data["savings"] = savings
	data["oldgood"] = oldgood
	data["oldquery"] = oldquery
	data["oldentry"] = oldentry
	data["minuend"] = minuend
	data["subtrahend"] = subtrahend
	data["currentqueryname"] = currentqueryname
	data["nextquery"] = "[nextmin] - [nextsub]"
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "accounting.tmpl", src.name, 600, 500)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/accounting/Topic(href, href_list)
	if(..())
		return 1
	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>You do not have accounting clearance.</span>")
		return
	if(href_list["reg"])
		if(!in_range(src, usr))
			return 1
		var/sol = text2num(href_list["reg"])
		if(isnull(sol))
			visible_message("<span class='warning'>[src] buzzes rudely.</span>")
			playsound(src, 'sound/machines/buzz-two.ogg', 50, 0)
			return 1
		solve_query(sol)
		if(!(usr.name in contributors))
			contributors += usr.name
	nanomanager.update_uis(src)
	return 1

/obj/machinery/computer/accounting/proc/solve_query(var/sol)
	playsound(loc, "sound/effects/typing[pick(1,2,3)].ogg", 50, 1)
	var/diff = minuend - subtrahend
	if(sol == diff)
		oldgood = TRUE
		savings += sol
		entryinfo += "[currentqueryname]: $[sol] overage saved<BR>"
	else
		oldgood = FALSE

	spawn(1 SECONDS)
		playsound(loc, oldgood ? 'sound/machines/ding2.ogg': 'sound/machines/buzz-sigh.ogg', 50, 1)

	oldquery = "[minuend] - [subtrahend]"
	oldentry = sol
	readynext()


/obj/machinery/computer/accounting/proc/readynext()
	currentqueryname = buildname()
	minuend = nextmin
	subtrahend = nextsub
	generatenext()
	nanomanager.update_uis(src)

/obj/machinery/computer/accounting/proc/new_cycle()
	if(!savings)
		return
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(loc)
	P.name = "accounting report for [worldtime2text()]"
	P.info = "[entryinfo]" + "Total savings: $[savings]<BR>Prepared in part by: [english_list(contributors)]<BR>This document is to be verified by Internal Affairs and faxed to Central Command.<BR>"
	var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
	stampoverlay.icon_state = "paper_stamp-cent"
	if(!P.stamped)
		P.stamped = new
	P.stamped += /obj/item/weapon/stamp
	P.overlays += stampoverlay
	P.stamps += "<HR><i>It has a Central Command accounting stamp: MQAC[round(savings/50)]TRM</i>"
	playsound(loc, "sound/effects/dotmatrixprinter.ogg", 40, 1)
	station_bonus += round(savings/10)
	savings = 0
	oldgood = -1
	oldquery = null
	oldentry = null
	contributors.Cut()
	entryinfo = "<big>Accounting Report</big><BR>"
	nanomanager.update_uis(src)

/obj/machinery/computer/accounting/proc/buildname()
	var/firstpart = pick(list("coordination on", "water resource", "geothermal", "miscellaneous", "programmatic",
	"management", "disposition", "flood and storm", "vacuum", "atmospheric", "interagency nonstructural",
	"other technical", "planning assistance", "communications stream", "ecosystem", "biosphere", "exoplanet", "xenopology",
	"electrical", "culinary", "supply", "genetics", "virology", "command", "horticultural", "human", "fuel", "upgrade",
	"cyberinfrastructure", "scientific", "cybersecurity", "redesign of", "biological", "important"))

	var/lastpart = pick(list("research", "logistics", "recycling", "outreach", "appropriations", "endowments", "study",
	"planning assistance", "gauging", "interests", "reduction", "oversight", "investments", "modeling", "determinations",
	"risk assessment", "inventory", "guidance", "traineeships", "foundations", "repair", "highlights", "splining"))
	return firstpart + " " + lastpart

#define APPROXIMATE_PYTHAG (3/7)
/obj/machinery/computer/accounting/proc/generatenext()
	var/greaterval = rand(1001,9999)
	var/lesserval = rand(201,1000)
	nextmin = round(greaterval + lesserval*APPROXIMATE_PYTHAG)
	nextsub = round(sqrt(greaterval**2 + lesserval**2)) //true pythag
	//Should generate an inaccuracy of 1% to 8.8%