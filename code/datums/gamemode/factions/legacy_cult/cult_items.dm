/obj/item/weapon/melee/legacy_cultblade
	name = "Cult Blade"
	desc = "An arcane weapon wielded by the followers of Nar-Sie."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	icon_state = "cultblade"
	item_state = "cultblade-old"
	flags = FPRINT
	w_class = W_CLASS_LARGE
	force = 30
	throwforce = 10
	sharpness = 1.35
	sharpness_flags = SHARP_TIP | SHARP_BLADE
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")
	var/checkcult = 1 // If we have to be a cultist to use it or not.

/obj/item/weapon/melee/legacy_cultblade/nocult
	checkcult = 0
	force = 15

/obj/item/weapon/melee/legacy_cultblade/cultify()
	return

/obj/item/weapon/melee/legacy_cultblade/attack(mob/living/target as mob, mob/living/carbon/human/user as mob)
	if(!checkcult || islegacycultist(user))
		playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
		return ..()
	else
		user.Paralyse(5)
		to_chat(user, "<span class='warning'>An unexplicable force powerfully repels the sword from [target]!</span>")
		var/datum/organ/external/affecting = user.get_active_hand_organ()
		if(affecting && affecting.take_damage(rand(force/2, force))) //random amount of damage between half of the blade's force and the full force of the blade.
			user.UpdateDamageIcon()


/obj/item/weapon/melee/legacy_cultblade/pickup(mob/living/user as mob)
	if(checkcult && !islegacycultist(user))
		to_chat(user, "<span class='warning'>An overwhelming feeling of dread comes over you as you pick up the cultist's sword. It would be wise to rid yourself of this blade quickly.</span>")
		user.Dizzy(120)


/obj/item/clothing/head/legacy_culthood
	name = "cult hood"
	icon_state = "culthood"
	desc = "A hood worn by the followers of Nar-Sie."
	flags = FPRINT|HIDEHAIRCOMPLETELY
	armor = list(melee = 30, bullet = 10, laser = 5,energy = 5, bomb = 0, bio = 0, rad = 0)
	body_parts_covered = EARS|HEAD
	siemens_coefficient = 0
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY

/obj/item/clothing/head/legacy_culthood/cultify()
	return

/obj/item/clothing/head/legacy_culthood/alt
	icon_state = "culthelmet_old"
	item_state = "culthelmet_old"

/obj/item/clothing/suit/legacy_cultrobes/alt
	icon_state = "cultarmor_old"
	item_state = "cultarmor_old"

/obj/item/clothing/suit/legacy_cultrobes
	name = "cult robes"
	desc = "A set of armored robes worn by the followers of Nar-Sie."
	icon_state = "cultrobes"
	item_state = "cultrobes"
	flags = FPRINT
	allowed = list(/obj/item/weapon/tome_legacy,/obj/item/weapon/melee/legacy_cultblade)
	armor = list(melee = 50, bullet = 30, laser = 50,energy = 20, bomb = 25, bio = 10, rad = 0)
	siemens_coefficient = 0

/obj/item/clothing/suit/legacy_cultrobes/cultify()
	return

/obj/item/clothing/head/legacy_magus
	name = "magus helm"
	icon_state = "magus"
	item_state = "magus"
	desc = "A helm worn by the followers of Nar-Sie."
	flags = FPRINT
	body_parts_covered = FULL_HEAD|BEARD
	armor = list(melee = 30, bullet = 30, laser = 30,energy = 20, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0

/obj/item/clothing/suit/legacy_magusred
	name = "magus robes"
	desc = "A set of armored robes worn by the followers of Nar-Sie."
	icon_state = "magusred"
	item_state = "magusred"
	flags = FPRINT
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS
	allowed = list(/obj/item/weapon/tome_legacy,/obj/item/weapon/melee/legacy_cultblade)
	armor = list(melee = 50, bullet = 30, laser = 50,energy = 20, bomb = 25, bio = 10, rad = 0)
	siemens_coefficient = 0


/obj/item/clothing/head/helmet/space/legacy_cult
	name = "cult helmet"
	desc = "A space worthy helmet used by the followers of Nar-Sie"
	icon_state = "culthelmet_old"
	item_state = "cult_helmet"
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
	siemens_coefficient = 0

/obj/item/clothing/suit/space/legacy_cult
	name = "cult armor"
	icon_state = "cultarmor_old"
	item_state = "cult_armour"
	desc = "A bulky suit of armor bristling with spikes. It looks space proof."
	w_class = W_CLASS_MEDIUM
	allowed = list(/obj/item/weapon/tome_legacy,/obj/item/weapon/melee/legacy_cultblade,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen)
	slowdown = NO_SLOWDOWN
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
	siemens_coefficient = 0
