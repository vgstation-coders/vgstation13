#define SLOT_WEAR_SUIT_STR "11"

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

	compatible_mobs = list(/mob/living/carbon/human)
	equipped_summons = list(SLOT_WEAR_SUIT_STR = /obj/item/clothing/suit/storage/draculacoat)

	hud_state = "vamp_coat"

#undef SLOT_WEAR_SUIT_STR