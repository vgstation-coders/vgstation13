/spell/changeling/lesserform
	name = "Lesser Form"
	desc = "We debase ourselves and become lesser. We become a monkey."
	abbreviation = "LF"

	spell_flags = NEEDSHUMAN
	max_genedamage = 0
	horrorallowed = 0
	chemcost = 1

/spell/changeling/lesserform/cast_check(var/skipcharge = 0, var/mob/user = usr)
	..()
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
	if(M_HUSK in H.mutations)
		to_chat(user, "<span class = 'warning'>This hosts genetic code is too scrambled. We can not change form until we have removed this burden.</span>")
		return FALSE
		

/spell/changeling/lesserform/cast(var/list/targets, var/mob/living/carbon/human/user)
	..()

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



/spell/changeling/higherform
	name = "Higher Form"
	desc = "We rebase ourselves and become greater. We assume a humanoid form."
	abbreviation = "HF"

	max_genedamage = 0
	horrorallowed = 0	//horrors shouldnt even have this spell available to them
	chemcost = 1
	required_dna = 1

/spell/changeling/higherform/cast_check(var/skipcharge = 0, var/mob/user = usr)
	..()
	if(istype(user.loc, /obj/mecha))
		to_chat(user, "<span class='warning'>We cannot transform here!</span>")
		return FALSE
	if(istype(user.loc, /obj/machinery/atmospherics))
		to_chat(user, "<span class='warning'>We cannot transform here!</span>")
		return FALSE

	var/mob/living/M = user
	if(!ismonkey(M))
		to_chat(user, "<span class='warning'>We cannot perform this ability in this form!</span>")
		return FALSE


/spell/changeling/higherform/cast(var/list/targets, var/mob/living/carbon/human/user)
	..()

	var/datum/role/changeling/C = user.mind.GetRole(CHANGELING)
	if(!C)
		return

	var/list/names = list()
	for(var/datum/dna/DNA in C.absorbed_dna)
		names += "[DNA.real_name]"

	var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!S)
		return

	var/datum/dna/chosen_dna = C.GetDNA(S)
	if(!chosen_dna)
		return

	var/mob/living/carbon/M = src

	M.visible_message("<span class='warning'>[C] transforms!</span>")
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
	sleep(48)
	qdel(animation)
	animation = null

	var/mob/living/carbon/human/O = new /mob/living/carbon/human( user, delay_ready_dna=1 )
	if (C.dna.GetUIState(DNA_UI_GENDER))
		O.setGender(FEMALE)
	else
		O.setGender(MALE)
	C.transferImplantsTo(O)
	C.transferBorers(O)
	O.dna = M.dna.Clone()
	C.dna = null
	O.real_name = chosen_dna.real_name
	O.flavor_text = chosen_dna.flavor_text

	for(var/obj/item/W in src)
		C.drop_from_inventory(W)
	for(var/obj/T in M)
		qdel(T)

	O.forceMove(M.loc)

	O.UpdateAppearance()
	domutcheck(O, null)
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

	return 1
