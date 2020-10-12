/spell/changeling/lesserform
	name = "Lesser Form"
	desc = "Changes your name and appearance, either to someone in view or randomly. Has a cooldown of 3 minutes."
	abbreviation = "LF"

	spell_flags = NEEDSHUMAN

	horrorallowed = 0
	chemcost = 1


/spell/lesserform/cast_check(var/skipcharge = 0, var/mob/user = usr)
	..()
	var/datum/role/changeling/C = user.mind.GetRole(CHANGELING)
	if(istype(user.loc, /obj/mecha))
		return FALSE
	if(istype(user.loc, /obj/machinery/atmospherics))
		return FALSE

	var/mob/living/carbon/human/H = user
	if(!istype(H) || !H.species.primitive)
		to_chat(user, "<span class='warning'>We cannot perform this ability in this form!</span>")
		return FALSE
	if(M_HUSK in H.mutations)
		to_chat(user, "<span class = 'warning'>This hosts genetic code is too scrambled. We can not change form until we have removed this burden.</span>")
		return FALSE
	


/spell/lesserform/cast(var/list/targets, var/mob/living/carbon/human/user)
	var/mob/living/carbon/human/H = user

	H.remove_changeling_powers()
	H.visible_message("<span class='warning'>[C] transforms!</span>")
	changeling.geneticdamage = 30
	to_chat(H, "<span class='warning'>Our genes cry out!</span>")
	H.remove_changeling_verb() //remove the verb holder
	
	var/mob/living/carbon/monkey/O = H.monkeyize(ignore_primitive = 1) // stops us from becoming the monkey version of whoever we were pretending to be
	O.make_changeling(1)
	var/datum/role/changeling/Ochangeling = O.mind.GetRole(CHANGELING)
	O.changeling_update_languages(Ochangeling.absorbed_languages)
	feedback_add_details("changeling_powers","LF")
	qdel(H)

