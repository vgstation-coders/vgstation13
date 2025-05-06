/spell/targeted/norwood_curse
	name = "Curse of Norwood"
	desc = "Target a person to make them permanently bald and sad. Target mirrors to infuse them with the curse of norwood."
	abbreviation = "CoN"
	user_type = USER_TYPE_WIZARD
	specialization = SSOFFENSIVE

	charge_type = Sp_RECHARGE

	school = "transmutation"
	charge_max = 10 SECONDS
	spell_flags = WAIT_FOR_CLICK | IS_HARMFUL
	cooldown_min = 4 SECONDS
	range = 1
	max_targets = 1
	invocation = "C'R'S O' N'WOOD!"

	invocation_type = SpI_SHOUT

	hud_state = "pumpkin"

/spell/targeted/norwood_curse/cast(var/list/targets, mob/user)
	..()
	for(var/mob/living/carbon/human/target in targets)
		if(isjusthuman(target))
			to_chat(target, "<span class = 'userwarning'>Oh no! It's the curse of Norwood!</span>")
			target.my_appearance.h_style = "Bald"
			target.update_hair()
			target.my_appearance.permanently_bald = TRUE

	for(var/obj/structure/mirror/M in targets)
		to_chat(user, "<span class='notice'>Mwahaha! This [M] is now cursed! Any soul attempting to use it shall lose their hair!</span>")
		M.norwood_cursed = TRUE

	for(var/obj/item/weapon/pocket_mirror/M in targets)
		to_chat(user, "<span class='notice'>Mwahaha! This [M] is now cursed! Any soul attempting to use it shall lose their hair!</span>")
		M.norwood_cursed = TRUE
