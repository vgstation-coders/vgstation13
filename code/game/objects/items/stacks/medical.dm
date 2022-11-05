/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/items.dmi'
	amount = 5
	max_amount = 5
	restock_amount = 2
	w_class = W_CLASS_TINY
	throw_speed = 4
	throw_range = 10
	var/heal_brute = 0
	var/heal_burn = 0
	autoignition_temperature = AUTOIGNITION_FABRIC

/obj/item/stack/medical/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(restraint_resist_time > 0)
		if(restraint_apply_check(M, user))
			return attempt_apply_restraints(M, user)

	if(!istype(M))
		to_chat(user, "<span class='warning'>\The [src] cannot be applied to [M]!</span>")
		return 1

	if (!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 1

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.display_name == LIMB_HEAD)
			if(H.head && istype(H.head,/obj/item/clothing/head/helmet/space))
				to_chat(user, "<span class='warning'>You can't apply \the [src] through \the [H.head]!</span>")
				return 1
		else
			if(H.wear_suit && istype(H.wear_suit,/obj/item/clothing/suit/space))
				to_chat(user, "<span class='warning'>You can't apply \the [src] through \the [H.wear_suit]!</span>")
				return 1

		if(affecting.status & ORGAN_ROBOT)
			to_chat(user, "<span class='warning'>This isn't useful at all on a robotic limb.</span>")
			return 1

		if(affecting.status & ORGAN_PEG)
			to_chat(user, "<span class='warning'>This isn't useful at all on a peg limb.</span>")
			return 1

		H.UpdateDamageIcon()

	else

		M.heal_organ_damage((src.heal_brute/2), (src.heal_burn/2))
		user.visible_message( \
			"<span class='notice'>[user] applies \the [src] to [M].</span>", \
			"<span class='notice'>You apply \the [src] to [M].</span>" \
		)
		use(1)

	M.updatehealth()

/obj/item/stack/medical/bruise_pack
	name = "roll of gauze"
	singular_name = "gauze length"
	desc = "Some sterile gauze to wrap around bloody stumps."
	icon_state = "brutepack"
	origin_tech = Tc_BIOTECH + "=1"
	restraint_resist_time = 2 SECONDS
	toolsounds = list('sound/weapons/cablecuff.ogg')

/obj/item/stack/medical/bruise_pack/bandaid
	name = "small bandage"
	desc = "A small bandage to stop bleeding."
	icon_state = "bandaid"
	amount = 1
	max_amount = 1
	restraint_resist_time = 1 SECONDS

/obj/item/stack/medical/bruise_pack/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(!affecting.bandage())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.display_name] have already been bandaged.</span>")
				return 1
			else
				for(var/datum/wound/W in affecting.wounds)
					if(W.internal)
						continue
					if(W.current_stage <= W.max_bleeding_stage)
						user.visible_message("<span class='notice'>[user] bandages \the [W.desc] on [M]'s [affecting.display_name].</span>", \
										"<span class='notice'>You bandage \the [W.desc] on [M]'s [affecting.display_name].</span>")
						//H.add_side_effect("Itch")
					else if(istype(W,/datum/wound/bruise))
						user.visible_message("<span class='notice'>[user] places a bruise patch over \the [W.desc] on [M]'s [affecting.display_name].</span>", \
										"<span class='notice'>You place a bruise patch over \the [W.desc] on [M]'s [affecting.display_name].</span>")
					else
						user.visible_message("<span class='notice'>[user] places a bandaid over \the [W.desc] on [M]'s [affecting.display_name].</span>", \
										"<span class='notice'>You place a bandaid over \the [W.desc] on [M]'s [affecting.display_name].</span>")
				use(1)
		else
			if(can_operate(H, user, src))        //Checks if mob is lying down on table for surgery
				if(do_surgery(H,user,src))
					return
			else
				to_chat(user, "<span class='notice'>[H]'s [affecting.display_name] is cut wide open, you'll need more than a bandage!</span>")

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burns."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	origin_tech = Tc_BIOTECH + "=1"

/obj/item/stack/medical/ointment/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(!affecting.salve())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.display_name] have already been salved.</span>")
				return 1
			else
				user.visible_message("<span class='notice'>[user] salves the wounds on [M]'s [affecting.display_name].</span>", \
										"<span class='notice'>You salve the wounds on [M]'s [affecting.display_name].</span>" )
				use(1)
		else
			if(can_operate(H, user, src))        //Checks if mob is lying down on table for surgery
				if(do_surgery(H,user,src))
					return
			else
				to_chat(user, "<span class='notice'>[H]'s [affecting.display_name] is cut wide open, you'll need more than some ointment!</span>")

/obj/item/stack/medical/bruise_pack/tajaran
	name = "\improper S'rendarr's Hand leaf"
	singular_name = "S'rendarr's Hand leaf"
	desc = "A poultice made of soft leaves that is rubbed on bruises."
	icon = 'icons/obj/hydroponics/shand.dmi'
	icon_state = "pack"
	heal_brute = 5

/obj/item/stack/medical/ointment/tajaran
	name = "\improper Messa's Tear petals"
	singular_name = "Messa's Tear petals"
	desc = "A poultice made of cold, blue petals that is rubbed on burns."
	icon = 'icons/obj/hydroponics/mtear.dmi'
	icon_state = "pack"
	heal_burn = 5


/obj/item/stack/medical/advanced/bruise_pack
	name = "advanced trauma kit"
	singular_name = "advanced trauma kit"
	desc = "An advanced trauma kit for severe injuries."
	icon_state = "traumakit"
	heal_brute = 10
	origin_tech = Tc_BIOTECH + "=2"

/obj/item/stack/medical/advanced/bruise_pack/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(!affecting.bandage())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.display_name] have already been treated.</span>")
				return 1
			else
				for(var/datum/wound/W in affecting.wounds)
					if(W.internal)
						continue
					if(W.current_stage <= W.max_bleeding_stage)
						user.visible_message("<span class='notice'>[user] cleans \the [W.desc] on [M]'s [affecting.display_name] and seals the edges with bioglue.</span>", \
										"<span class='notice'>You clean \the [W.desc] on [M]'s [affecting.display_name] and seal the edges with bioglue .</span>")
						//H.add_side_effect("Itch")
					else if(istype(W,/datum/wound/bruise))
						user.visible_message("<span class='notice'>[user] disinfects and places a medicine patch over \the [W.desc] on [M]'s [affecting.display_name].</span>", \
										"<span class='notice'>You disinfect and place a medicine patch over \the [W.desc] on [M]'s [affecting.display_name].</span>")
					else
						user.visible_message("<span class='notice'>[user] smears some bioglue over \the [W.desc] on [M]'s [affecting.display_name].</span>", \
										"<span class='notice'>You smear some bioglue over \the [W.desc] on [M]'s [affecting.display_name].</span>")
				affecting.heal_damage(rand(heal_brute, heal_brute + 5), 0)
				use(1)
		else
			if(can_operate(H, user, src))        //Checks if mob is lying down on table for surgery
				if(do_surgery(H,user,src))
					return
			else
				to_chat(user, "<span class='notice'>[H]'s [affecting.display_name] is cut wide open, even bioglue won't do!</span>")

/obj/item/stack/medical/advanced/ointment
	name = "advanced burn kit"
	singular_name = "advanced burn kit"
	desc = "An advanced treatment kit for severe burns."
	icon_state = "burnkit"
	heal_burn = 10
	origin_tech = Tc_BIOTECH + "=2"


/obj/item/stack/medical/advanced/ointment/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(!affecting.salve())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.display_name] have already been salved.</span>")
				return 1
			else
				user.visible_message("<span class='notice'>[user] disinfects the wounds on [M]'s [affecting.display_name] and covers them with a regenerative membrane.</span>", \
										"<span class='notice'>You disinfect the wounds on [M]'s [affecting.display_name] and cover them with a regenerative membrane.</span>")
				affecting.heal_damage(0, rand(heal_burn, heal_burn + 5))
				use(1)
		else
			if(can_operate(H, user, src))        //Checks if mob is lying down on table for surgery
				if(do_surgery(H,user,src))
					return
			else
				to_chat(user, "<span class='notice'>[H]'s [affecting.display_name] is cut wide open, even a regenerative membrane won't do!</span>")

/obj/item/stack/medical/splint
	name = "advanced medical splints"
	desc = "Used to secure a fracture in any bodypart."
	singular_name = "advanced medical splint"
	icon_state = "splint"
	amount = 5
	max_amount = 5

/obj/item/stack/medical/splint/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)
		var/limb = affecting.display_name
		if(affecting.status & ORGAN_SPLINTED)
			to_chat(user, "<span class='warning'>[M]'s [limb] is already splinted!</span>")
			return
		if (M != user)
			user.visible_message("<span class='warning'>[user] starts to apply \the [src] to [M]'s [limb].</span>", \
								"<span class='warning'>You start to apply \the [src] to [M]'s [limb].</span>", \
								"<span class='warning'>You hear something being wrapped.</span>")
		else
			user.visible_message("<span class='warning'>[user] starts to apply \the [src] to their [limb].</span>", \
								"<span class='warning'>You start to apply \the [src] to your [limb].</span>", \
								"<span class='warning'>You hear something being wrapped.</span>")
		if(do_mob(user, M, 50))
			if (M != user)
				user.visible_message("<span class='warning'>[user] finishes applying \the [src] to [M]'s [limb].</span>", \
									"<span class='warning'>You finish applying \the [src] to [M]'s [limb].</span>", \
									"<span class='warning'>You hear something being wrapped.</span>")
			else
				if(prob(75))
					user.visible_message("<span class='warning'>[user] successfully applies \the [src] to their [limb].</span>", \
										"<span class='warning'>You successfully apply \the [src] to your [limb].</span>", \
										"<span class='warning'>You hear something being wrapped.</span>")
				else
					user.visible_message("<span class='warning'>[user] fumbles \the [src].</span>", \
										"<span class='warning'>You fumble \the [src].</span>", \
										"<span class='warning'>You hear something being wrapped.</span>")
					return
			affecting.status |= ORGAN_SPLINTED
			use(1)
		return

/obj/item/stack/medical/splint/ghetto
	name = "ghetto splints"
	icon_state = "ghettosplintcomplete"
	desc = "A makeshift splint made out of rods, cable and a newspaper."
	singular_name = "ghetto splint"
	amount = 1
	max_amount = 5
