
/obj/item/weapon/tome
	name = "arcane tome"
	desc = "An old, dusty tome with frayed edges and a sinister looking cover."
	icon = 'icons/obj/cult.dmi'
	icon_state ="tome"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	flags = FPRINT

/obj/item/weapon/paper/talisman
	icon_state = "paper_talisman"

/obj/item/weapon/melee/cultblade
	name = "cult blade"
	desc = "An arcane weapon wielded by the followers of Nar-Sie."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	icon_state = "cultblade"
	item_state = "cultblade"
	flags = FPRINT
	w_class = W_CLASS_LARGE
	force = 30
	throwforce = 10
	sharpness = 1.35
	sharpness_flags = SHARP_TIP | SHARP_BLADE
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")
	var/checkcult = 1

/obj/item/weapon/melee/cultblade/nocult
	checkcult = 0
	force = 15

/obj/item/weapon/melee/cultblade/cultify()
	return

/obj/item/weapon/melee/cultblade/attack(mob/living/target as mob, mob/living/carbon/human/user as mob)
	if(!checkcult || iscultist(user))
		playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
		return ..()
	else
		user.Paralyse(5)
		to_chat(user, "<span class='warning'>An unexplicable force powerfully repels the sword from [target]!</span>")
		var/datum/organ/external/affecting = user.get_active_hand_organ()
		if(affecting && affecting.take_damage(rand(force/2, force))) //random amount of damage between half of the blade's force and the full force of the blade.
			user.UpdateDamageIcon()


/obj/item/weapon/melee/cultblade/pickup(mob/living/user as mob)
	if(checkcult && !iscultist(user))
		to_chat(user, "<span class='warning'>An overwhelming feeling of dread comes over you as you pick up the cultist's sword. It would be wise to rid yourself of this blade quickly.</span>")
		user.Dizzy(120)


/obj/item/clothing/head/culthood
	name = "cult hood"
	icon_state = "culthood"
	desc = "A hood worn by the followers of Nar-Sie."
	flags = FPRINT
	armor = list(melee = 30, bullet = 10, laser = 5,energy = 5, bomb = 0, bio = 0, rad = 0)
	body_parts_covered = EARS|HEAD
	siemens_coefficient = 0
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY

/obj/item/clothing/head/culthood/cultify()
	return

/obj/item/clothing/head/culthood/alt
	icon_state = "cult_hoodalt"
	item_state = "cult_hoodalt"

/obj/item/clothing/suit/cultrobes/alt
	icon_state = "cultrobesalt"
	item_state = "cultrobesalt"

/obj/item/clothing/suit/cultrobes
	name = "cult robes"
	desc = "A set of armored robes worn by the followers of Nar-Sie."
	icon_state = "cultrobes"
	item_state = "cultrobes"
	flags = FPRINT
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade)
	armor = list(melee = 50, bullet = 30, laser = 50,energy = 20, bomb = 25, bio = 10, rad = 0)
	siemens_coefficient = 0

/obj/item/clothing/suit/cultrobes/cultify()
	return

/obj/item/clothing/head/magus
	name = "magus helm"
	icon_state = "magus"
	item_state = "magus"
	desc = "A helm worn by the followers of Nar-Sie."
	flags = FPRINT
	body_parts_covered = FULL_HEAD|BEARD
	armor = list(melee = 30, bullet = 30, laser = 30,energy = 20, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0

/obj/item/clothing/suit/magusred
	name = "magus robes"
	desc = "A set of armored robes worn by the followers of Nar-Sie."
	icon_state = "magusred"
	item_state = "magusred"
	flags = FPRINT
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade)
	armor = list(melee = 50, bullet = 30, laser = 50,energy = 20, bomb = 25, bio = 10, rad = 0)
	siemens_coefficient = 0


/obj/item/clothing/head/helmet/space/cult
	name = "cult helmet"
	desc = "A space worthy helmet used by the followers of Nar-Sie"
	icon_state = "cult_helmet"
	item_state = "cult_helmet"
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
	siemens_coefficient = 0

/obj/item/clothing/suit/space/cult
	name = "cult armor"
	icon_state = "cult_armour"
	item_state = "cult_armour"
	desc = "A bulky suit of armor bristling with spikes. It looks space proof."
	w_class = W_CLASS_MEDIUM
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen)
	slowdown = NO_SLOWDOWN
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
	siemens_coefficient = 0


/obj/item/weapon/bloodcult_pamphlet
	name = "cult of Nar-Sie pamphlet"
	desc = "Looks like a page torn from a tome. One glimpse at it surely can't hurt you."
	icon = 'icons/obj/cult.dmi'
	icon_state ="pamphlet"
	throwforce = 0
	w_class = W_CLASS_TINY
	w_type = RECYK_WOOD
	throw_range = 1
	throw_speed = 1
	layer = ABOVE_DOOR_LAYER
	pressure_resistance = 1
	attack_verb = list("slaps")
	autoignition_temperature = AUTOIGNITION_PAPER
	fire_fuel = 1

/obj/item/weapon/bloodcult_pamphlet/attack_self(var/mob/user)
	initialize_cultwords()
	var/datum/faction/bloodcult/cult = find_active_faction(BLOODCULT)
	if (cult)
		cult.HandleRecruitedMind(user.mind)
	user.add_spell(new /spell/trace_rune, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)
	user.add_spell(new /spell/erase_rune, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)
