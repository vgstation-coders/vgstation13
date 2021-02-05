/obj/structure/essence_printer
	name = "strange stone"
	desc = "A strange stone. It lets off an eerie red glow."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "Essence_imprinter_idle"
	var/datum/dna2/record/R
	var/mob/bound_soul
	var/ready

/obj/structure/essence_printer/New()
	..()
	set_light(3,5,LIGHT_COLOR_RED)

/obj/structure/essence_printer/Destroy()
	new /datum/artifact_postmortem_data(src)
	if(bound_soul)
		bound_soul.lazy_unregister_event(/lazy_event/on_death, src, .proc/print)
		bound_soul = null
	..()

/obj/structure/essence_printer/proc/bind(var/mob/living/carbon/human/H)
	if(H.maxHealth/2 < 25)
		to_chat(H, "<span class = 'warning'>Your essence is too weak to be bound to \the [src].</span>")
		return
	if(R)
		qdel(R)
	R = new /datum/dna2/record()
	var/datum/organ/internal/brain/Brain = H.internal_organs_by_name["brain"]
	if(!isnull(Brain.owner_dna) && Brain.owner_dna != H.dna)
		R.dna = Brain.owner_dna.Clone()
	else
		R.dna=H.dna.Clone()
	R.types=DNA2_BUF_UI|DNA2_BUF_UE|DNA2_BUF_SE
	R.languages = H.languages.Copy()
	R.name=R.dna.real_name
	if(bound_soul)
		bound_soul.lazy_unregister_event(/lazy_event/on_death, src, .proc/print)
	bound_soul = H
	H.lazy_register_event(/lazy_event/on_death, src, .proc/print)

/obj/structure/essence_printer/attack_ghost(mob/user)
	if(!ready)
		to_chat(user, "<span class = 'warning'>\The [src] isn't finished printing yet.</span>")
		return
	var/mob/living/carbon/human/H = locate(/mob/living/carbon/human) in contents
	if(H && user.mind)
		user.mind.transfer_to(H)
		H.ckey = user.ckey
		qdel(user)
		H.forceMove(get_turf(src))

/obj/structure/essence_printer/attack_hand(mob/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		to_chat(H, "<span class = 'notice'>You bind your essence to \the [src].</span>")
		bind(H)

/obj/structure/essence_printer/proc/print(mob/user, body_destroyed)
	do_flick(src,"Essence_imprinter_scan_start",10)
	ready = FALSE
	icon_state = "Essence_imprinter_scan_loop"
	var/mob/living/carbon/human/previous = user
	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src, R.dna.species, delay_ready_dna = TRUE)
	H.dna = R.dna.Clone()
	H.dna.flavor_text = R.dna.flavor_text
	H.dna.species = R.dna.species
	if(H.dna.species != "Human")
		H.set_species(H.dna.species, TRUE)
	H.UpdateAppearance()
	H.set_species(R.dna.species)
	H.dna.mutantrace = R.dna.mutantrace
	H.update_mutantrace()
	for(var/datum/language/L in R.languages)
		H.add_language(L.name)
	H.real_name = H.dna.real_name
	H.flavor_text = H.dna.flavor_text

	H.maxHealth = round(previous.maxHealth/2)

	// Prevent nonhumans from dying immediately in non-ideal atmospheres.
	if (isvox(H))
		// Nitrogen heals tox damage from O2 in environment and is also what cloner uses.
		H.reagents.add_reagent(NITROGEN, 60)

	else if (isplasmaman(H))
		// Plasmamen both catch on fire AND have no plasma to breathe, so...
		H.reagents.add_reagent(LEPORAZINE, 60)
		H.reagents.add_reagent(DEXALIN, 60)

	spawn(rand(30 SECONDS,60 SECONDS))
		do_flick(src,"Essence_imprinter_scan_complete",8)
		icon_state = "Essence_imprinter_idle"
		ready = TRUE
		bind(H)
