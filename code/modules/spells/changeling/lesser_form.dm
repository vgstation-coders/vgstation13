/spell/changeling/lesserform
	name = "Lesser Form (1)"
	desc = "We debase ourselves and become lesser. We become a monkey."
	abbreviation = "LF"
	hud_state = "lesserform"

	spell_flags = NEEDSHUMAN
	max_genedamage = 0
	horrorallowed = 0
	chemcost = 1

/spell/changeling/lesserform/cast_check(var/skipcharge = 0, var/mob/user = usr)
	. = ..()
	if (!.)
		return FALSE
	if(istype(user.loc, /obj/mecha))
		to_chat(user, "<span class='warning'>We cannot transform here!</span>")
		return FALSE
	if(istype(user.loc, /obj/machinery/atmospherics))
		to_chat(user, "<span class='warning'>We cannot transform here!</span>")
		return FALSE

	var/mob/living/carbon/human/H = user
	if(!istype(H) || !H.species.primitive)
		to_chat(user, "<span class='warning'>We cannot perform this ability in this form!</span>")
		return FALSE
	if(M_HUSK in user.mutations)
		to_chat(user, "<span class = 'warning'>This hosts genetic code is too scrambled. We can not change form until we have removed this burden.</span>")
		return FALSE


/spell/changeling/lesserform/cast(var/list/targets, var/mob/living/carbon/human/user)
	..()
	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)

	user.visible_message("<span class='danger'>[user] transforms!</span>")
	changeling.geneticdamage = 30
	to_chat(user, "<span class='warning'>Our genes cry out!</span>")

	var/mob/living/carbon/monkey/O = user.monkeyize(ignore_primitive = 1) // stops us from becoming the monkey version of whoever we were pretending to be
	O.make_changeling()
	var/datum/role/changeling/Ochangeling = O.mind.GetRole(CHANGELING)
	O.changeling_update_languages(Ochangeling.absorbed_languages)
	feedback_add_details("changeling_powers","LF")
	qdel(user)





/spell/changeling/higherform
	name = "Higher Form (1)"
	desc = "We rebase ourselves and become greater. We assume a humanoid form."
	abbreviation = "HF"
	hud_state = "lesserform"

	max_genedamage = 0
	horrorallowed = 0	//horrors shouldnt even have this spell available to them
	chemcost = 1

/spell/changeling/higherform/cast_check(var/skipcharge = 0, var/mob/user = usr)
	. = ..()
	if (!.)
		return FALSE
	if(istype(user.loc, /obj/mecha))
		to_chat(user, "<span class='warning'>We cannot transform here!</span>")
		return FALSE
	if(istype(user.loc, /obj/machinery/atmospherics))
		to_chat(user, "<span class='warning'>We cannot transform here!</span>")
		return FALSE

	if(!ismonkey(user))
		to_chat(user, "<span class='warning'>We cannot perform this ability in this form!</span>")
		return FALSE


/spell/changeling/higherform/cast(var/list/targets, var/mob/living/user)
	..()
	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
	if(!changeling)
		return

	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		names += "[DNA.real_name]"

	if(!names.len)
		to_chat(user, "<span class='warning'>We cannot transform into anyone!</span>")
		return
	var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!S)
		return

	var/datum/dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	var/mob/living/carbon/M = user

	M.visible_message("<span class='danger'>[user] transforms!</span>")
	M.dna = chosen_dna.Clone()

	M.monkeyizing = 1
	M.canmove = 0
	M.icon = null
	M.overlays.len = 0
	M.invisibility = 101
	M.delayNextAttack(50)
	var/atom/movable/overlay/animation = new /atom/movable/overlay( M.loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	var/anim_name = M.get_unmonkey_anim()
	flick(anim_name, animation)
	sleep(20)
	QDEL_NULL(animation)

	var/mob/living/carbon/human/O = new /mob/living/carbon/human( user, delay_ready_dna=1 )
	if (M.dna.GetUIState(DNA_UI_GENDER))
		O.setGender(FEMALE)
	else
		O.setGender(MALE)
	M.transferImplantsTo(O)
	M.transferBorers(O)
	O.dna = M.dna.Clone()
	M.dna = null
	O.real_name = chosen_dna.real_name
	O.flavor_text = chosen_dna.flavor_text

	for(var/obj/item/W in M)
		M.drop_from_inventory(W)
	for(var/obj/T in M)
		qdel(T)

	O.forceMove(M.loc)

	O.UpdateAppearance()
	domutcheck(O, null)
	O.update_name()
	O.setToxLoss(M.getToxLoss())
	O.adjustBruteLoss(M.getBruteLoss())
	O.setOxyLoss(M.getOxyLoss())
	O.adjustFireLoss(M.getFireLoss())
	O.stat = M.stat
	O.delayNextAttack(0)
	M.mind.transfer_to(O)
	O.make_changeling()
	O.changeling_update_languages(changeling.absorbed_languages)

	feedback_add_details("changeling_powers","HF")
	qdel(M)

