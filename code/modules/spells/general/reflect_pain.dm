//how do i counter a stove lul: the spell
/spell/mirror_of_pain
	name = "Pain Mirror"
	desc = "An unholy charm that lasts for 5 seconds. While active, it redirects all incoming damage to everybody around you, leaving you unharmed."
	user_type = USER_TYPE_WIZARD
	specialization = DEFENSIVE

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

	//How much damage can be done per one instance. There to prevent instakilling everybody by suiciding (which does 200 damage)
	var/damage_limit = 50

/spell/mirror_of_pain/New()
	..()
	user_overlay = image('icons/mob/mob.dmi', icon_state = "red_glow")

/spell/mirror_of_pain/choose_targets(mob/user = usr)
	return list(user)

/spell/mirror_of_pain/cast(list/targets, mob/user)
	for(var/mob/living/L in targets)
		to_chat(L, "<span class='sinister'>You bind your life essence to this plane. Any pain you endure will be also felt by everybody around you.</span>")
		for(var/mob/living/T in view(L))
			if(!T.isDead() && (T != L))
				to_chat(T, "<span class='sinister'>An unholy charm binds your life to [L]. While the spell is active, any pain \he receive\s will be redirected to you.</span>")
		var/event_key = L.on_damaged.Add(src, "reflect")
		L.overlays.Add(user_overlay)
		playsound(L, 'sound/effects/vampire_intro.ogg', 80, 1, "vary" = 0)

		spawn(duration)
			to_chat(L, "<span class='sinister'>Your life essence is no longer bound to this plane. You won't reflect received damage to your enemies anymore.</span>")
			L.on_damaged.Remove(event_key)
			L.overlays.Remove(user_overlay)

/spell/mirror_of_pain/proc/reflect(list/arguments)
	var/damage_type = arguments["type"]
	var/amount = arguments["amount"]

	if(amount <= 0)
		return
	amount = min(amount, damage_limit)

	absorbed_damage += amount

	var/affected_amount = 0
	for(var/mob/living/L in view(world.view, src.holder))
		if(L.isDead())
			continue
		if(L == src.holder)
			continue

		affected_amount++

		if(amount >= 10)
			var/obj/item/projectile/beam/pain/projectile = new(get_turf(src.holder), get_dir(src.holder, L))

			//The projectile is purely visual - actual damage is done below
			projectile.damage = 0

			projectile.original = L
			projectile.starting = get_turf(src.holder)
			projectile.target = get_turf(L)
			projectile.shot_from = src.holder //fired from the user
			projectile.current = projectile.original
			projectile.yo = L.y - src.holder.y
			projectile.xo = L.x - src.holder.x

			spawn()
				projectile.OnFired()
				projectile.process()

			if(prob(30))
				L.audible_scream()

		if(amount >= 5)
			switch(damage_type)
				if(BRUTE, BURN, CLONE)
					to_chat(L, "<span class='sinister'>\The [src.holder]'s wounds appear on your body!</span>")
				else
					to_chat(L, "<span class='sinister'>You feel deathly sick!</span>")

		L.apply_damage(amount, damage_type, ignore_events = 1) //The ignore_events part is to prevent recursion with two wizards
		L.attack_log += "\[[time_stamp()]\] <font color='orange'>Received [amount] [damage_type] damage, reflected from [src.holder] by the [src.name] spell</font>"
		dealt_damage += amount

	var/mob/living/holder = src.holder
	if(istype(holder))
		holder.attack_log += "\[[time_stamp()]\] <font color='orange'>Received [amount] [damage_type] damage with [src.name] active. Reflected to [affected_amount] people.</font>"

	return TRUE //Block the damage

/spell/mirror_of_pain/get_scoreboard_suffix()
	return " ([absorbed_damage] damage absorbed, [dealt_damage] damage dealt)"
