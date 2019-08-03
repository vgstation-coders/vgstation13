/spell/targeted/pumpkin_head
	name = "pass the pumpkin"
	desc = "whomever you select with this spell is given a carnivorous pumpkin, that will eat the head of whomever is holding it after 60 seconds"
	abbreviation = "PTP"
	user_type = USER_TYPE_WIZARD
	specialization = OFFENSIVE

	school = "transmutation"
	charge_max = 600
	spell_flags = NEEDSCLOTHES | WAIT_FOR_CLICK
	range = 1
	max_targets = 1
	invocation = "H'T POT'TO"
	invocation_type = SpI_SHOUT
	cooldown_min = 200 //100 deciseconds reduction per rank

	hud_state = "pumpkin"


/spell/targeted/pumpkin_head/cast(var/list/targets, mob/user)
	..()
	for(var/mob/living/target in targets)
		to_chat(target, "<span class = 'userwarning'>\The [src] has been forced onto you by \the [user]! Find somebody else to give it to before it consumes your head!</span>")
		target.drop_item(target.get_active_hand(), force_drop = 1)
		target.put_in_hands(new /obj/item/weapon/carnivorous_pumpkin(target))