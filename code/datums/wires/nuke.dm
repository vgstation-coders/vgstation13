
/datum/wires/nuke
	holder_type = /obj/machinery/nuclearbomb
	wire_count = 5

/datum/wires/nuke/New()
	wire_names=list(
		"[NUKE_WIRE_BOOM]" 		= "Explode",
		"[NUKE_WIRE_BOLT]" 		= "Bolts",
		"[NUKE_WIRE_DELAY]" 		= "Delay",
		"[NUKE_WIRE_PROCEED]" 	= "Proceed",
		"[NUKE_WIRE_ACTIVATE]" 		= "Activate"
	)
	..()

var/const/NUKE_WIRE_BOOM = 1
var/const/NUKE_WIRE_BOLT = 2
var/const/NUKE_WIRE_DELAY = 4
var/const/NUKE_WIRE_PROCEED = 8
var/const/NUKE_WIRE_ACTIVATE = 16


/datum/wires/nuke/CanUse(var/mob/living/L)
	if(!..())
		return 0
	var/obj/machinery/nuclearbomb/A = holder
	if(A.wiresexposed && A.previously_activated) //only do wire fun if the nuke has been armed and counting down
		return 1
	return 0

/datum/wires/nuke/UpdateCut(var/index, var/mended, var/mob/user)
	var/obj/machinery/nuclearbomb/A = holder
	..()
	switch(index)
		if(NUKE_WIRE_BOOM)
			A.explode()
		if(NUKE_WIRE_BOLT)
			if(!A.anchored)
				A.visible_message("<span class='danger'>[A]'s bolting systems clank up!</span>")
				playsound(A,'sound/effects/bolt.ogg', 70, 1)
				A.anchored = FALSE
		if(NUKE_WIRE_DELAY)
			A.timeleft += 10
			A.visible_message("<span class='notice'>[A]'s clock ticks forwards rapidly!</span>")
			playsound(A, 'sound/machines/dial_reset.ogg', 50, 1)
		if(NUKE_WIRE_PROCEED)
			A.explode()
		if(NUKE_WIRE_ACTIVATE)
			A.timing = FALSE
			A.icon_state = "nuclearbomb1"
			bomb_set = FALSE
			score.nukedefuse = min(A.timeleft, score.nukedefuse)
			var/datum/gamemode/dynamic/dynamic_mode = ticker.mode
			if (istype(dynamic_mode))
				dynamic_mode.update_stillborn_rulesets()

/datum/wires/nuke/UpdatePulsed(var/index)
	var/obj/machinery/nuclearbomb/A = holder
	..()
	switch(index)
		if(NUKE_WIRE_BOOM)
			A.explode()
		if(NUKE_WIRE_BOLT)
			if(!A.anchored)
				A.visible_message("<span class='danger'>[A]'s bolting systems rumble!</span>")
		if(NUKE_WIRE_DELAY)
			A.timeleft += 10
			A.visible_message("<span class='notice'>[A]'s clock ticks forwards rapidly!</span>")
			playsound(A, 'sound/machines/dial_reset.ogg', 50, 1)
		if(NUKE_WIRE_PROCEED)
			A.timeleft = max(0,A.timeleft-10)
			A.visible_message("<span class='danger'>[A]'s clock ticks backwards rapidly</span>")
			playsound(A, 'sound/machines/dial_reset.ogg', 50, 1)
		if(NUKE_WIRE_ACTIVATE)
			A.timing = TRUE
			A.icon_state = "nuclearbomb2"
			bomb_set = !A.safety//There can still be issues with this reseting when there are multiple bombs. Not a big deal tho for Nuke/N
