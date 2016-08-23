//how do i counter a stove lul: the spell
/spell/mirror_of_pain
	name = "Pain Mirror"
	desc = "An unholy charm that lasts for 5 seconds. While active, it causes everybody around you to receive the same damage that you do."

	school = "necromancy"
	charge_max = 90 SECONDS
	spell_flags = NEEDSCLOTHES

	invocation = "KON TEAH STOV"
	invocation_type = SpI_SHOUT
	cooldown_min = 10 SECONDS

	hud_state = "wiz_reflect_pain"

	duration = 5 SECONDS

	var/image/user_overlay

/spell/mirror_of_pain/New()
	..()
	user_overlay = image('icons/mob/mob.dmi', icon_state = "red_glow")

/spell/mirror_of_pain/before_cast()
	return

/spell/mirror_of_pain/choose_targets(mob/user = usr)
	return list(user)

/spell/mirror_of_pain/cast(list/targets, mob/user)
	for(var/mob/living/L in targets)
		to_chat(L, "<span class='sinister'>Your life essence .</span>")
		var/event_key = L.on_damaged.Add(src, "reflect")
		L.overlays.Add(user_overlay)
		playsound(get_turf(L), 'sound/effects/vampire_intro.ogg', 80, 1, "vary" = 0)

		spawn(duration)
			to_chat(L, "<span class='notice'>You no longer feel protected.</span>")
			L.on_damaged.Remove(event_key)
			L.overlays.Remove(user_overlay)

/spell/mirror_of_pain/proc/reflect(list/arguments)
	var/damage_type = arguments["type"]
	var/amount = arguments["amount"]

	if(amount <= 0)
		return

	for(var/mob/living/L in view(world.view, holder))
		if(L.isDead())
			continue
		if(L == holder)
			continue

		switch(damage_type)
			if(BRUTE)
				to_chat(L, "<span class='userdanger'>A bruise appears on your body!</span>")
			if(BURN)
				to_chat(L, "<span class='userdanger'>A burn appears on your body!</span>")
			else
				to_chat(L, "<span class='userdanger'>You feel very weak.</span>")

		L.apply_damage(amount, damage_type)
		L.attack_log += "\[[time_stamp()]\] <font color='orange'>Received [amount] [damage_type] damage, reflected from [holder] by the [src.name] spell</font>"
