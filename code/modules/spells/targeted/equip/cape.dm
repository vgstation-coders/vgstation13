/spell/targeted/equip_item/cape
	name = "Spawn Cape"
	desc = "Acquire a fabulous, yet fearsome cape."
	abbreviation = "SC"
	user_type = USER_TYPE_VAMPIRE

	charge_max = 300
	invocation_type = SpI_NONE
	range = SELFCAST
	spell_flags = INCLUDEUSER

	delete_old = 0 //Players shouldn't lose their hardsuits because they decided to summon some cape.

	cooldown_min = 5 MINUTES
	charge_max = 5 MINUTES
	duration = 0

	override_base = "vamp"
	hud_state = "vampire_enthrall"

	compatible_mobs = list(/mob/living/carbon/human)
	equipped_summons = list(slot_wear_suit = /obj/item/clothing/suit/storage/draculacoat)

	hud_state = "vamp_coat"