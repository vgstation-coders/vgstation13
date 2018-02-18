/datum/role/cultist
	id = CULTIST
	name = "Cultist"
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Chaplain", "Head of Personnel", "Internal Affairs Agent")
	logo_state = "cult-logo"

/datum/role/cultist/OnPostSetup()
	. = ..()
	if(!.)
		return

	antag.current.add_spell(new /spell/trace_rune, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)
	antag.current.add_spell(new /spell/erase_rune, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)

/datum/role/cultist/Greet()
	to_chat(antag.current, {"<span class='sinister'><font size=3>You are a cultist of <span class='danger'><font size=3>Nar-Sie</font></span>!</font><br>
	I, the Geometer of Blood want you to thin the veil between reality and his realm<br>
	so I can pull this place onto my plane of existence.<br>
	You've managed to get a job here, and the time has come to put our plan into motion.<br>
	However the veil is currently so thick that I can barely bestow any power to you.<br>
	Other cultists made their way into the crew. Talk to them. <span class='danger'>Self Other Technology</span>!<br>
	Meet up with them. Raise an altar in my name. <span class='danger'>Blood Technology Join</span>!<br>
	</span>"})

/*
/datum/role/cultist/RoleTopic(href, href_list)
	..()
	if(!ismob(usr))
		return
*/

/mob/living/carbon/proc/muted()
	return (iscultist(src) && reagents && reagents.has_reagent(HOLYWATER))

/datum/role/cultist/AdminPanelEntry(var/show_logo = FALSE,var/datum/admins/A)
	var/dat = ..()
	dat += " - <a href='?src=\ref[A];cult_privatespeak=\ref[antag.current]'>(Nar-Sie whispers)</a>"
	return dat
