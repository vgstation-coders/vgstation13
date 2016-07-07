/obj/item/device/codebreaker
	name = "code breaker"
	desc = "Can be used to decipher a Nuclear Bomb's activation code"
	icon_state = "codebreaker"
	item_state = "electronic"
	flags = FPRINT
	siemens_coefficient = 1
	force = 5.0
	w_class = W_CLASS_SMALL
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	starting_materials = list(MAT_IRON = 50, MAT_GLASS = 20)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_SILICON
	origin_tech = "magnets=3;programming=6;syndicate=7"
	slot_flags = SLOT_BELT
	var/operation = 0

/obj/item/device/codebreaker/afterattack(obj/machinery/nuclearbomb/O, mob/living/carbon/user)
	if(istype(O) && !operation)
		operation = 1
		icon_state = "codebreaker-working"
		to_chat(user, "<span class='notice'>Stand still and keep the [src] in your hands while it cracks the [O]'s activation code.</span>")
		var/turf/loc_user = get_turf(user)
		var/turf/loc_nuke = get_turf(O)
		var/crackduration = rand(100,300)
		var/delayfraction = round(crackduration/6)

		for(var/i = 0, i<6, i++)
			sleep(delayfraction)
			if(!user || user.incapacitated() || !(user.loc == loc_user) || !(O.loc == loc_nuke) || !user.is_holding_item(src))
				to_chat(user, "<span class='warning'>You need to stand still for the whole duration of the code breaking for the device to work, and keep it in one of your hands.</span>")
				icon_state = "codebreaker"
				operation = 0
				return

		icon_state = "codebreaker-found"
		playsound(src, 'sound/machines/info.ogg', 50, 1)
		to_chat(user, "It worked! The code is \"[O.r_code]\".")
		sleep(20)
		icon_state = "codebreaker"
		operation = 0
	else
		return ..()
