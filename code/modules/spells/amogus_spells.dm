/spell/targeted/amogus_piercer
	name = "Piercer"
	desc = "Overload your flash bulb to blind a target creature."
	hud_state = "amogusflash_piercer"
	charge_max = 300 SECONDS
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
	charge_max = 30 SECONDS
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
