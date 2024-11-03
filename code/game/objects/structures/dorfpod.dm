#define DORF_RESPAWN_COOLDOWN	10 MINUTES

var/obj/structure/dorfpod/center/dorfpod

/obj/structure/dorfpod
	name = "defective cloning pod"
	desc = "The ship's cloning pod comes with permanent backups of the crew DNA, but the clones it produces seem to often come with deformities and disabilities. Better build a proper one soon."
	icon = 'icons/obj/cryogenics.dmi'
	icon_state = "dorfspawner"
	mech_flags = MECH_SCAN_FAIL
	density = 1
	anchored = 1
	light_color = LIGHT_COLOR_CYAN

/obj/structure/dorfpod/New()
	..()
	set_light(3, 2)
	var/image/I = image(icon,"[icon_state]-lights")
	I.plane = ABOVE_LIGHTING_PLANE
	I.layer = ABOVE_LIGHTING_LAYER
	overlays += I

/obj/structure/dorfpod/cultify()
	return

/obj/structure/dorfpod/ex_act()
	return

/obj/structure/dorfpod/emp_act()
	return

/obj/structure/dorfpod/blob_act()
	return

/obj/structure/dorfpod/singularity_act()
	return

/obj/structure/dorfpod/left
	icon_state = "dorfspawner_left"

/obj/structure/dorfpod/right
	icon_state = "dorfspawner_right"

/obj/structure/dorfpod/attack_hand(var/mob/user)
	to_chat(user, "<span class='notice'>The pod will automatically detect should a crew member die and begin preparing a new body. However it does so much more slowly than a regular pod would, and with less desirable results as well.</span>")

/obj/structure/dorfpod/attack_ghost(var/mob/dead/observer/user)
	for(var/obj/structure/dorfpod/center/actual_pod in range(1,src))
		actual_pod.attack_ghost(user)
		break

/obj/structure/dorfpod/center
	var/list/records = list()

/obj/structure/dorfpod/center/New()
	..()
	dorfpod = src

/obj/structure/dorfpod/center/proc/find_record(var/find_key)
	var/selected_record = null
	for(var/datum/dna2/record/R in records)
		if (R.ckey == find_key)
			selected_record = R
			break
	return selected_record

/obj/structure/dorfpod/center/proc/scan_body(var/mob/living/carbon/human/subject)
	if (!subject)
		return

	if(subject.mind && subject.mind.suiciding) //We cannot clone this guy because he suicided. Believe it or not, some people who suicide don't know about this. Let's tell them what's wrong.
		to_chat(subject, "<span class='sinister'>You have commited suicide, as such the [src] will not be able to provide you with a new body.</span>")
		return

	if(!isnull(find_record(subject.ckey))) //They already have a record in the database, our work here is done
		to_chat(subject, "<span class='sinister'>You have expired, however this station features \a [src] which you can use to get a new body of flesh. You only have to click it, however keep in mind that respawning this way tends to induce more genetic disabilities and deformities than usual.</span>")
		return

	subject.dna.check_integrity()
	var/datum/organ/internal/brain/Brain = subject.internal_organs_by_name["brain"]

	var/mob/living/simple_animal/borer/B=subject.has_brain_worms()
	if(B && B.controlling)
		subject.do_release_control(1)

	var/datum/dna2/record/R = new /datum/dna2/record()
	if(!isnull(Brain.owner_dna) && Brain.owner_dna != subject.dna)
		R.dna = Brain.owner_dna.Clone()
	else
		R.dna=subject.dna.Clone()
	R.ckey = subject.ckey
	R.id= copytext(md5(R.dna.real_name), 2, 6)
	R.name=R.dna.real_name
	R.types=DNA2_BUF_UI|DNA2_BUF_UE|DNA2_BUF_SE
	R.languages = subject.languages.Copy()
	R.attack_log = subject.attack_log.Copy()
	R.default_language = subject.default_language
	R.times_cloned = subject.times_cloned
	R.talkcount = subject.talkcount

	if (!isnull(subject.mind))
		R.mind = "\ref[subject.mind]"

	records += R
	to_chat(subject, "<span class='sinister'>You have expired, however this station features \a [src] which you can use to get a new body of flesh. You only have to click it, however keep in mind that respawning this way tends to induce more genetic disabilities and deformities than usual.</span>")


/obj/structure/dorfpod/center/attack_ghost(var/mob/dead/observer/user)
	var/datum/dna2/record/R = find_record(user.ckey)
	if (!R)
		to_chat(user, "<span class='warning'>Unable to find your DNA among the ship's crew. You may find other ways to get into the game such as by using an ancient cryopod. Try asking an admin.</span>")

	if (world.time < user.timeofdeath + DORF_RESPAWN_COOLDOWN)
		var/completion = (world.time / (user.timeofdeath + DORF_RESPAWN_COOLDOWN)) * 100
		to_chat(user, "<span class='notice'>Your new clone started being produced when you died, and is now [round(completion)]% complete.</span>")
		return

	spawn_clone(user,R)

/obj/structure/dorfpod/center/proc/spawn_clone(var/mob/dead/observer/user, var/datum/dna2/record/R)
	var/datum/mind/clonemind = locate(R.mind)
	if(!istype(clonemind,/datum/mind))
		return
	if( clonemind.current && clonemind.current.stat != DEAD )
		return
	if(clonemind.active)
		if(ckey(clonemind.key)!=R.ckey)
			return
	else
		for(var/mob/G in player_list)
			if(G.ckey == R.ckey)
				if(isobserver(G))
					if(G:can_reenter_corpse)
						break
					else
						return
				else
					if((G.mind && (G.mind.current.stat != DEAD) ||  G.mind != clonemind))
						return
	var/turf/exit = get_step(src,SOUTH)
	var/mob/living/carbon/human/H = new /mob/living/carbon/human(exit, R.dna.species, delay_ready_dna = TRUE)
	H.times_cloned = R.times_cloned +1
	H.talkcount = R.talkcount

	if(isplasmaman(H))
		H.fire_sprite = "Plasmaman"

	H.dna = R.dna.Clone()
	H.dna.flavor_text = R.dna.flavor_text
	H.dna.species = R.dna.species
	if(H.dna.species != "Human")
		H.set_species(H.dna.species, TRUE)

	H.adjustCloneLoss(rand(50,60))
	H.adjustBrainLoss(rand(20,30))
	H.check_mutations = M_CHECK_ALL
	H.Paralyse(4)
	H.stat = H.status_flags & BUDDHAMODE ? CONSCIOUS : UNCONSCIOUS
	H.updatehealth()

	has_been_shade.Remove(clonemind)
	clonemind.transfer_to(H)

	H.ckey = R.ckey
	to_chat(H, "<span class='notice'><b>Consciousness slowly creeps over you as your body regenerates.</b><br><i>So this is what cloning feels like?</i></span>")

	if (H.mind.miming)
		H.add_spell(new /spell/aoe_turf/conjure/forcewall/mime, "grey_spell_ready")
		if (H.mind.miming == MIMING_OUT_OF_CHOICE)
			H.add_spell(new /spell/targeted/oathbreak/)

	if (isvampire(H))
		var/datum/role/vampire/V = isvampire(H)
		V.check_vampire_upgrade()
		V.update_vamp_hud()

	H.UpdateAppearance()
	H.set_species(R.dna.species)
	randmutb(H)
	H.dna.mutantrace = R.dna.mutantrace
	H.update_mutantrace()
	for(var/datum/language/L in R.languages)
		H.add_language(L.name)
		if (L == R.default_language)
			H.default_language = R.default_language
	H.attack_log = R.attack_log
	H.real_name = H.dna.real_name
	H.flavor_text = H.dna.flavor_text

	if(H.mind)
		H.mind.suiciding = FALSE
	H.update_name()

	if(isvox(H))
		H.reagents.add_reagent(NITROGEN, 10)
	else
		H.reagents.add_reagent(INAPROVALINE, 10)

	if (H.client)
		H.client.eye = H.client.mob
		H.client.perspective = MOB_PERSPECTIVE

	var/obj/machinery/conveyor/C = locate() in exit
	if(C && C.operating != 0)
		H << sound('sound/ambience/powerhouse.ogg')

	H.updatehealth()

	domutcheck(H)


#undef DORF_RESPAWN_COOLDOWN
