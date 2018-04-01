#define SIN_ACEDIA "acedia"
#define SIN_GLUTTONY "gluttony"
#define SIN_GREED "greed"
#define SIN_SLOTH "sloth"
#define SIN_WRATH "wrath"
#define SIN_ENVY "envy"
#define SIN_PRIDE "pride"

/datum/antagonist/sintouched
	name = "sintouched"
	roundend_category = "sintouched"
	antagpanel_category = "Devil"
	var/sin

	var/static/list/sins = list(SIN_ACEDIA,SIN_GLUTTONY,SIN_GREED,SIN_SLOTH,SIN_WRATH,SIN_ENVY,SIN_PRIDE)

/datum/antagonist/sintouched/New()
	. = ..()
	sin = pick(sins)

/datum/antagonist/sintouched/proc/forge_objectives()
	var/datum/objective/sintouched/O
	switch(sin)//traditional seven deadly sins... except lust.
		if(SIN_ACEDIA)
			O = new /datum/objective/sintouched/acedia
		if(SIN_GLUTTONY)
			O = new /datum/objective/sintouched/gluttony
		if(SIN_GREED)
			O = new /datum/objective/sintouched/greed
		if(SIN_SLOTH)
			O = new /datum/objective/sintouched/sloth
		if(SIN_WRATH)
			O = new /datum/objective/sintouched/wrath
		if(SIN_ENVY)
			O = new /datum/objective/sintouched/envy
		if(SIN_PRIDE)
			O = new /datum/objective/sintouched/pride
	objectives += O

/datum/antagonist/sintouched/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/sintouched/greet()
	owner.announce_objectives()

/datum/antagonist/sintouched/roundend_report()
	return printplayer(owner)

/datum/antagonist/sintouched/admin_add(datum/mind/new_owner,mob/admin)
	var/choices = sins + "Random"
	var/chosen_sin = input(admin,"What kind ?","Sin kind") as null|anything in choices
	if(!chosen_sin)
		return
	if(chosen_sin in sins)
		sin = chosen_sin
	. = ..()

/datum/antagonist/sintouched/apply_innate_effects(mob/living/mob_override)
	. = ..()
	add_hud()

/datum/antagonist/sintouched/remove_innate_effects(mob/living/mob_override)
	remove_hud()
	. = ..()

/datum/antagonist/sintouched/proc/add_hud()
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_SINTOUCHED]
	hud.join_hud(owner.current)
	set_antag_hud(owner.current, "sintouched")

/datum/antagonist/sintouched/proc/remove_hud()
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_SINTOUCHED]
	hud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)

#undef SIN_ACEDIA
#undef SIN_ENVY
#undef SIN_GLUTTONY
#undef SIN_GREED
#undef SIN_PRIDE
#undef SIN_SLOTH
#undef SIN_WRATH