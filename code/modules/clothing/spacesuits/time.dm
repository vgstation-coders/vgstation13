/obj/item/clothing/head/helmet/space/time
	name = "time helmet"
	desc = "Though it possesses no special abilities of its own, this helmet is necessary to properly seal a time suit."
	icon_state = "time_helmet"
	item_state = "time_helmet"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing.dmi')
	armor = list(melee = 25, bullet = 25, laser = 15, energy = 15, bomb = 15, bio = 100, rad = 30)
	siemens_coefficient = 0.6
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	clothing_flags = PLASMAGUARD
	pressure_resistance = 200 * ONE_ATMOSPHERE
	eyeprot = 3
	body_parts_visible_override = 0

/obj/item/clothing/head/helmet/space/time/equipped(mob/living/carbon/human/H, equipped_slot)
	..()
	if(istype(H) && H.get_item_by_slot(slot_head) == src)
		var/obj/item/clothing/suit/space/time/T = H.get_item_by_slot(slot_wear_suit)
		if(istype(T))
			T.activate_suit(H)

/obj/item/clothing/head/helmet/space/time/unequipped(mob/living/carbon/human/user, var/from_slot = null)
	..()
	if(from_slot == slot_head && istype(user))
		var/obj/item/clothing/suit/space/time/T = user.get_item_by_slot(slot_wear_suit)
		if(istype(T))
			T.deactivate_suit(user)

/obj/item/clothing/suit/space/time
	name = "time suit"
	desc = "In addition to possessing various time-related abilities, this suit is capable of separating the flow of time inside it from the flow of time outside it, when properly sealed."
	icon_state = "time_suit"
	item_state = "time_suit"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing.dmi')
	w_class = W_CLASS_LARGE
	slowdown = NO_SLOWDOWN
	armor = list(melee = 30, bullet = 25, laser = 15, energy = 15, bomb = 15, bio = 100, rad = 30)
	clothing_flags = PLASMAGUARD | ONESIZEFITSALL
	pressure_resistance = 200 * ONE_ATMOSPHERE
	allowed = list(/obj/item/device/flashlight, /obj/item/weapon/tank, /obj/item/device/radio, /obj/item/weapon/gun, /obj/item/weapon/grenade)
	siemens_coefficient = 0.6
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	var/suit_active = FALSE
	var/spell/aoe_turf/time_suit/time_stop/timestop
	var/spell/aoe_turf/time_suit/future_jump/futurejump
	var/spell/aoe_turf/time_suit/past_jump/pastjump

/obj/item/clothing/suit/space/time/New()
	..()
	timestop = new
	timestop.suit = src
	futurejump = new
	futurejump.suit = src
	pastjump = new
	pastjump.suit = src

/obj/item/clothing/suit/space/time/proc/refresh_spells(mob/living/carbon/human/H)
	if(!istype(H))
		return
	H.add_spell(timestop, "time_spell_ready", /obj/abstract/screen/movable/spell_master/time)
	H.add_spell(futurejump, "time_spell_ready", /obj/abstract/screen/movable/spell_master/time)
	H.add_spell(pastjump, "time_spell_ready", /obj/abstract/screen/movable/spell_master/time)

/obj/item/clothing/suit/space/time/proc/activate_suit(mob/living/carbon/human/H)
	if(!istype(H))
		return
	suit_active = TRUE
	H.flags |= TIMELESS
	refresh_spells(H)
	playsound(src, 'sound/misc/timesuit_activate.ogg', 50)

/obj/item/clothing/suit/space/time/proc/deactivate_suit(mob/living/carbon/human/H)
	if(!istype(H))
		return
	suit_active = FALSE
	H.flags &= ~TIMELESS
	H.remove_spell(timestop)
	H.remove_spell(futurejump)
	H.remove_spell(pastjump)
	playsound(src, 'sound/misc/timesuit_deactivate.ogg', 50)

/obj/item/clothing/suit/space/time/equipped(mob/living/carbon/human/H, equipped_slot)
	..()
	if(istype(H) && H.get_item_by_slot(slot_wear_suit) == src)
		if(istype(H.get_item_by_slot(slot_head), /obj/item/clothing/head/helmet/space/time))
			activate_suit(H)

/obj/item/clothing/suit/space/time/unequipped(mob/living/carbon/human/user, var/from_slot = null)
	..()
	if(from_slot == slot_wear_suit && istype(user))
		deactivate_suit(user)

/spell/aoe_turf/time_suit
	panel = "Time Powers"
	override_base = "time"
	invocation = "none"
	invocation_type = SpI_NONE
	range = 0
	still_recharging_msg = "<span class='notice'>The suit is still recharging.</span>"
	var/obj/item/clothing/suit/space/time/suit

/spell/aoe_turf/time_suit/time_stop
	name = "Stop Time"
	desc = "Halt the progression of time in a small area for five seconds."
	abbreviation = "ST"
	hud_state = "time_stop"
	charge_max = 30 SECONDS

/spell/aoe_turf/time_suit/time_stop/before_cast(list/targets, mob/user, bypass_range = 0)
	if(user.timestopped)
		return list()
	else
		return ..()

/spell/aoe_turf/time_suit/time_stop/cast(var/list/targets, mob/user)
	timestop(user, 5 SECONDS, 2)

/spell/aoe_turf/time_suit/future_jump
	name = "Jump to Future"
	desc = "Jump ten seconds into the future."
	abbreviation = "FJ"
	hud_state = "time_future"
	charge_max = 30 SECONDS

/spell/aoe_turf/time_suit/future_jump/before_cast(list/targets, mob/user, bypass_range = 0)
	if(user.timestopped)
		return list()
	else
		return ..()

/spell/aoe_turf/time_suit/future_jump/cast(var/list/targets, mob/user)
	future_rift(user, 10 SECONDS, 1, TRUE, TRUE)

/spell/aoe_turf/time_suit/past_jump
	name = "Jump to Past"
	desc = "Prepare the suit for a jump to the past and execute it after ten seconds."
	abbreviation = "RF"
	hud_state = "time_past"
	charge_max = 60 SECONDS

/spell/aoe_turf/time_suit/past_jump/before_cast(list/targets, mob/user, bypass_range = 0)
	if(user.timestopped)
		return list()
	else
		return ..()

/spell/aoe_turf/time_suit/past_jump/cast(var/list/targets, mob/user)
	past_rift(user, 10 SECONDS, 1, TRUE, TRUE)
	spawn(10 SECONDS)
		if(suit)
			suit.refresh_spells(user)
