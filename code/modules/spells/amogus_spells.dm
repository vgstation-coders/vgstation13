/spell/targeted/amogus_piercer
	name = "Piercer"
	desc = "Overload your flash bulb to blind a target creature."
	hud_state = "amogusflash_piercer"
	charge_cooldown_max = 300 SECONDS
	range = 3
	user_type = USER_TYPE_NOUSER
	spell_flags = WAIT_FOR_CLICK

/spell/targeted/amogus_piercer/cast(list/targets, mob/user = usr)
	..()
	for(var/mob/living/carbon/target in targets)

		playsound(usr, 'sound/weapons/flash.ogg', 100, 1)
		user.visible_message("<span class='notice'>[usr] emits a blinding beam of light!</span>")

		if(target.blinded)
			to_chat(usr, "<span class='warning'>You fail to blind [target]!</span>")
			return 0
		else
			target.Knockdown(15)
			target.Stun(15)
			target.flash_eyes(visual = 1)
			to_chat(usr, "<span class='warning'>You blind [target]!</span>")

	for(var/mob/living/silicon/robot/target in targets)

		if(target.blinded)
			to_chat(usr, "<span class='warning'>You fail to overload [target]'s sensors!</span>")
			return 0
		else
			target.Knockdown(15)
			target.Stun(15)
			target.flash_eyes(affect_silicon = 1)
			to_chat(usr, "<span class='warning'>You overload [target]'s sensors!</span>")

/spell/targeted/amogus_flasher
	name = "Flasher"
	desc = "Blind a vulnerable target creature."
	hud_state = "amogusflash_flasher"
	range = 1
	charge_cooldown_max = 30 SECONDS
	user_type = USER_TYPE_NOUSER
	spell_flags = WAIT_FOR_CLICK

/spell/targeted/amogus_flasher/cast(list/targets, mob/user = usr)
	..()
	for(var/mob/living/carbon/target in targets)

		playsound(usr, 'sound/weapons/flash.ogg', 100, 1)

		if(target.eyecheck() > 0 || target.blinded)
			to_chat(usr, "<span class='warning'>You fail to blind [target]!</span>")
			return 0
		else
			target.Knockdown(10)
			target.Stun(10)
			target.flash_eyes(visual = 1)
			to_chat(usr, "<span class='warning'>You blind [target]!</span>")

	for(var/mob/living/silicon/robot/target in targets)

		if(target && (HAS_MODULE_QUIRK(target, MODULE_IS_FLASHPROOF)) || target.blinded)
			to_chat(usr, "<span class='warning'>You fail to overload [target]'s sensors!</span>")
			return 0
		else
			target.Knockdown(10)
			target.Stun(10)
			target.flash_eyes(affect_silicon = 1)
			to_chat(usr, "<span class='warning'>You overload [target]'s sensors!</span>")


/spell/strooigoed //putting this here since this seems to be the meme spell file
	name = "Strooigoed"
	desc = "Summon a handful of candy to throw at someone."
	user_type = USER_TYPE_WIZARD
	specialization = SSOFFENSIVE
	spell_flags = null
	school = "conjuration"
	charge_cooldown_max = 10 SECONDS
	cooldown_min = 5 SECONDS
	range = 1

	spell_levels = list()
	level_max = list()

	charge_type = SP_RECHARGE
	invocation = "H'RD G'KLP'T"
	invocation_type = SP_INV_SHOUT
	hud_state = "kruidnoten"
	override_icon = 'icons/obj/food_seasonal.dmi'

/spell/strooigoed/cast(list/targets, mob/user)
	..()
	user.drop_hands(force_drop = 1)
	var/kruid = new /obj/item/weapon/reagent_containers/food/snacks/kruidnoten(user.get_active_hand())
	user.put_in_hands(kruid)

/spell/strooigoed/choose_targets(mob/user = usr)
	return list(user)

/spell/strooigoed/perform(mob/user = usr, skipcharge = 0, list/target_override)
	..()
