/obj/effect/proc_holder/spell/targeted/tesla
	name = "Tesla Blast"
	desc = "Blast lightning at your foes!"
	charge_type = "recharge"
	charge_max	= 300
	clothes_req = 1
	invocation = "UN'LTD P'WAH!"
	invocation_type = "shout"
	range = 7
	cooldown_min = 30
	selection_type = "view"
	random_target = 1
	var/ready = 0
	var/static/mutable_appearance/halo
	var/sound/Snd // so far only way i can think of to stop a sound, thank MSO for the idea.

	action_icon_state = "lightning"

/obj/effect/proc_holder/spell/targeted/tesla/Click()
	if(!ready && cast_check())
		StartChargeup()
	return 1

/obj/effect/proc_holder/spell/targeted/tesla/proc/StartChargeup(mob/user = usr)
	ready = 1
	to_chat(user, "<span class='notice'>You start gathering the power.</span>")
	Snd = new/sound('sound/magic/lightning_chargeup.ogg',channel = 7)
	halo = halo || mutable_appearance('icons/effects/effects.dmi', "electricity", EFFECTS_LAYER)
	user.add_overlay(halo)
	playsound(get_turf(user), Snd, 50, 0)
	if(do_mob(user,user,100,1))
		if(ready && cast_check(skipcharge=1))
			choose_targets()
		else
			revert_cast(user, 0)
	else
		revert_cast(user, 0)

/obj/effect/proc_holder/spell/targeted/tesla/proc/Reset(mob/user = usr)
	ready = 0
	user.cut_overlay(halo)

/obj/effect/proc_holder/spell/targeted/tesla/revert_cast(mob/user = usr, message = 1)
	if(message)
		to_chat(user, "<span class='notice'>No target found in range.</span>")
	Reset(user)
	..()

/obj/effect/proc_holder/spell/targeted/tesla/cast(list/targets, mob/user = usr)
	ready = 0
	var/mob/living/carbon/target = targets[1]
	Snd=sound(null, repeat = 0, wait = 1, channel = Snd.channel) //byond, why you suck?
	playsound(get_turf(user),Snd,50,0)// Sorry MrPerson, but the other ways just didn't do it the way i needed to work, this is the only way.
	if(get_dist(user,target)>range)
		to_chat(user, "<span class='notice'>They are too far away!</span>")
		Reset(user)
		return

	playsound(get_turf(user), 'sound/magic/lightningbolt.ogg', 50, 1)
	user.Beam(target,icon_state="lightning[rand(1,12)]",time=5)

	Bolt(user,target,30,5,user)
	Reset(user)

/obj/effect/proc_holder/spell/targeted/tesla/proc/Bolt(mob/origin,mob/target,bolt_energy,bounces,mob/user = usr)
	origin.Beam(target,icon_state="lightning[rand(1,12)]",time=5)
	var/mob/living/carbon/current = target
	if(current.anti_magic_check())
		playsound(get_turf(current), 'sound/magic/lightningshock.ogg', 50, 1, -1)
		current.visible_message("<span class='warning'>[current] absorbs the spell, remaining unharmed!</span>", "<span class='userdanger'>You absorb the spell, remaining unharmed!</span>")
	if(bounces < 1)
		current.electrocute_act(bolt_energy,"Lightning Bolt",safety=1)
		playsound(get_turf(current), 'sound/magic/lightningshock.ogg', 50, 1, -1)
	else
		current.electrocute_act(bolt_energy,"Lightning Bolt",safety=1)
		playsound(get_turf(current), 'sound/magic/lightningshock.ogg', 50, 1, -1)
		var/list/possible_targets = new
		for(var/mob/living/M in view_or_range(range,target,"view"))
			if(user == M || target == M && los_check(current,M)) // || origin == M ? Not sure double shockings is good or not
				continue
			possible_targets += M
		if(!possible_targets.len)
			return
		var/mob/living/next = pick(possible_targets)
		if(next)
			Bolt(current,next,max((bolt_energy-5),5),bounces-1,user)
