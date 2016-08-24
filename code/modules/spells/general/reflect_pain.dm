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

	//Some statistics that will be shown at round end
	var/absorbed_damage = 0
	var/dealt_damage = 0

/spell/mirror_of_pain/New()
	..()
	user_overlay = image('icons/mob/mob.dmi', icon_state = "red_glow")

/spell/mirror_of_pain/before_cast()
	return

/spell/mirror_of_pain/choose_targets(mob/user = usr)
	return list(user)

/spell/mirror_of_pain/cast(list/targets, mob/user)
	for(var/mob/living/L in targets)
		L.visible_message("<span class='sinister'>You feel bound to \the [L].</span>",\
		"<span class='sinister'>You bind your life essence to this plane. Any pain you endure will be also felt by everybody around you.</span>")
		var/event_key = L.on_damaged.Add(src, "reflect")
		L.overlays.Add(user_overlay)
		playsound(get_turf(L), 'sound/effects/vampire_intro.ogg', 80, 1, "vary" = 0)

		spawn(duration)
			to_chat(L, "<span class='sinister'>Your life essence is no longer bound to this plane. You won't share received damage with your enemies anymore.</span>")
			L.on_damaged.Remove(event_key)
			L.overlays.Remove(user_overlay)

/spell/mirror_of_pain/proc/reflect(list/arguments)
	var/damage_type = arguments["type"]
	var/amount = arguments["amount"]

	if(amount <= 0)
		return

	absorbed_damage += amount

	var/affected_amount = 0
	for(var/mob/living/L in view(world.view, src.holder))
		if(L.isDead())
			continue
		if(L == src.holder)
			continue

		affected_amount++

		switch(damage_type)
			if(BRUTE, BURN, CLONE)
				to_chat(L, "<span class='sinister'>\The [src.holder]'s wounds appear on your body!</span>")
			else
				to_chat(L, "<span class='sinister'>You feel deathly sick!</span>")

		if(prob(30) && amount >= 10)
			L.audible_scream()

		L.apply_damage(amount, damage_type, ignore_events = 1) //The ignore_events part is to prevent recursion with two wizards
		L.attack_log += "\[[time_stamp()]\] <font color='orange'>Received [amount] [damage_type] damage, reflected from [src.holder] by the [src.name] spell</font>"
		dealt_damage += amount

	var/mob/living/holder = src.holder
	if(istype(holder))
		holder.attack_log += "\[[time_stamp()]\] <font color='orange'>Received [amount] [damage_type] damage with [src.name] active. Reflected to [affected_amount] people.</font>"

/spell/mirror_of_pain/get_scoreboard_suffix()
	return " ([absorbed_damage] damage taken, [dealt_damage] damage dealt)"
