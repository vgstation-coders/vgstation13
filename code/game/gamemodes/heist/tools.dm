/**
 * Handy-Dandy Organ Remover Doohicky
 * SHOULD ONLY BE MAPPED ON VOX RAIDER SHIPS.
 */
/obj/item/weapon/organ_remover
	name = "organics extractor"
	desc = "A highly sophisticated tool made for alien hands."
	icon='icons/obj/surgery.dmi'
	icon_state = "organ_remover"
	item_state = "electronic"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = W_CLASS_TINY
	throw_speed = 5
	starting_materials = list(MAT_IRON = 200)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_PLASTIC
	origin_tech = Tc_MAGNETS + "=1;" + Tc_BIOTECH + "=1" // TODO: figure out appropriate values

	var/delay=15 SECONDS     // Adminbus purposes.
	var/vox_only=TRUE        // Same
	var/target_monkeys=FALSE // Testing purposes.
	var/list/valid_targets=list(
		// "brain", Brains have special snowflake shit so this won't work.
		"eyes",
		"heart",
		"kidneys",
		"liver",
		"lungs",
		"appendix"
	)
	var/target_type="eyes"

/obj/item/weapon/organ_remover/examine(var/mob/user, var/override = FALSE)
	if(override)
		return ..(user)
	if(ishuman(user))
		var/mob/living/carbon/human/H
		if(isvox(H))
			to_chat(user, "A sophisticated device used by vox raiding parties to remove organs without time-consuming surgical procedures.")
			to_chat(user, "Subject must be still and incapacitated. Remember to set target organs before use!")
			return
	to_chat(user, "Some weird alien thing, doesn't look like it'd even fit in human hands.")

/obj/item/weapon/organ_remover/attack(var/mob/living/M, var/mob/living/user)
	if(!can_use(user))
		to_chat(user, "<span class='warning'>The object remains inert and useless.  It doesn't even <em>feel</em> right in your grip.</span>")
		return
	if(!ishuman(M))
		to_chat(user, "<span class='warning'>The extractor can't find any valid targets!</span>")
		return
	var/mob/living/carbon/human/H=M
	if(!H.incapacitated() || !H.lying)
		to_chat(user, "<span class='warning'>The extractor can't lock onto targets when the subject is conscious or standing!</span>")
		return
	if(in_use)
		to_chat(user, "<span class='warning'>The extractor is busy!</span>")
		return
	if(isnull(H.mind))
		to_chat(user, "<span class='warning'>This subject's organs have undergone degradation due to lack of fundamental sustaining brain processes!</span>")
		return
	if(clumsy_check(user) && prob(50))
		M = user
		H = M
	var/datum/organ/internal/O = H.internal_organs_by_name[target_type]
	if(!O || !istype(O) || !O.CanRemove(H, user, quiet=TRUE))
		to_chat(user, "<span class='warning'>The extractor can't find the desired organ!</span>")
		return
	in_use = TRUE
	user.visible_message("<span class='danger'>[user] activates \the [src]!</span>", "You level the extractor at [H] and hold down the trigger.")
	playsound(src, 'sound/machines/click.ogg', 50, 1)
	if(do_after(user, src, delay, needhand=TRUE))
		if(O && istype(O) && O.CanRemove(H, user, quiet=TRUE))
			O.Remove(H, user)
			O.status |= ORGAN_CUT_AWAY
			user.attack_log += "\[[time_stamp()]\] <font color='red'>extracted [H.name]'s [O] with \a [src]</font>"
			H.attack_log += "\[[time_stamp()]\] <font color='red'>had their [O] removed by [user.name]'s [src]</font>"
			var/obj/item/organ/internal/OO = O.remove(user)
			if(OO && istype(OO))

				// Stop the organ from continuing to reject.
				OO.organ_data.rejecting = null

				// Transfer over some blood data, if the organ doesn't have data.
				var/datum/reagent/blood/organ_blood = OO.reagents.reagent_list[BLOOD]
				if(!organ_blood || !organ_blood.data["blood_DNA"])
					H.vessel.trans_to(OO, 5, 1, 1)

				// Kinda redundant, but I'm getting some buggy behavior.
				H.internal_organs_by_name[target_type] = null
				H.internal_organs_by_name -= target_type
				H.internal_organs -= OO.organ_data
				// ???? affected.internal_organs -= OO.organ_data
				OO.removed(H,user)
				OO.forceMove(get_turf(H))
			playsound(src, 'sound/machines/juicer.ogg', 50, 1)
	in_use = FALSE

/obj/item/weapon/organ_remover/proc/can_use(var/mob/user)
	// Something something vox bioelectric fields something nanites.
	// I'd rather not have shitters picking these up and removing the clown's lungs for giggles.
	if(!ishigherbeing(user))
		return FALSE

	if(!vox_only)
		return TRUE

	var/mob/living/carbon/human/UH=user
	return isvox(UH)
/obj/item/weapon/organ_remover/attack_self(mob/user)
	if(!can_use(user))
		to_chat(user, "<span class='warning'>The object remains inert and useless.  It doesn't even <em>feel</em> right in your grip.</span>")
		return
	target_type=input(user, "Select desired organ.") in valid_targets
	to_chat(user, "<span class='info'>[target_type] selected.</span>")

/obj/item/weapon/organ_remover/adminbus_edition
	vox_only = FALSE

/obj/item/weapon/organ_remover/traitor
	desc = "A knock-off of the vox-only organ extractor, this one has been modified to be able to be used by anyone, and works twice as fast as the real deal. However, it can no longer extract hearts."
	vox_only = FALSE
	delay=7.5 SECONDS
	valid_targets=list(
		"eyes",
		"kidneys",
		"liver",
		"lungs",
		"appendix"
	)

/obj/item/weapon/organ_remover/traitor/examine(var/mob/user)
    ..(user, TRUE)
