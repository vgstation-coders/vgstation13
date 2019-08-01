/spell/targeted/feint
	name = "Feint"
	desc = "This spell grants you a magic weapon and causes you to vanish, before reappearing behind the enemy."
	abbreviation = "FT"
	user_type = USER_TYPE_WIZARD
	specialization = OFFENSIVE

	school = "transmutation"
	charge_max = 300
	spell_flags = NEEDSCLOTHES
	invocation_type = SpI_NONE
	cooldown_min = 100 //50 deciseconds reduction per rank
	duration = 30 //in deciseconds

	hud_state = "wiz_feint"

/spell/targeted/feint/cast(list/targets)
	var/mob/living/L = holder
	if(!istype(L) || !targets || !targets.len)
		return

	var/mobloc = get_turf(L)
	L.unlock_from()

	anim(location = mobloc, target = L, a_icon = 'icons/mob/mob.dmi', flick_anim = "liquify", direction = L.dir, name = "water")
	L.ExtinguishMob()
	var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
	steam.set_up(10, 0, mobloc)
	steam.start()

	var/obj/item/weapon/katana/magic/sword
	for(var/obj/item/I in L.held_items)
		if(istype(I, /obj/item/weapon/katana/magic))
			sword = I
			break
	if(!sword)
		sword = new(get_turf(L))
		if(!L.put_in_active_hand(sword))
			if(!L.put_in_hands(sword))
				qdel(sword)	//No sword if the wizard doesn't have a free hand

	L.invisibility = INVISIBILITY_MAXIMUM
	L.flags |= INVULNERABLE
	var/old_density = L.density
	L.setDensity(FALSE)
	L.candrop = 0
	L.alphas["etheral_jaunt"] = 125 //Spoopy mode to know you are jaunting
	L.handle_alpha()
	for(var/obj/abstract/screen/movable/spell_master/SM in L.spell_masters)
		SM.silence_spells(duration)
	L.delayNextAttack(duration)
	L.click_delayer.setDelay(duration)
	L.delayNextMove(duration)

	sleep(duration)

	var/mob/M = pick(targets)
	var/targloc = get_turf(get_step(M,turn(M.dir,180)))

	var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
	smoke.set_up(3, 0, targloc)
	smoke.start()
	L.forceMove(targloc)
	L.dir = get_dir(get_turf(src),get_turf(M))
	L.invisibility = 0
	for(var/obj/abstract/screen/movable/spell_master/SM in L.spell_masters)
		SM.silence_spells(0)
	L.flags &= ~INVULNERABLE
	L.setDensity(old_density)
	L.candrop = 1
	L.alphas -= "etheral_jaunt"
	L.handle_alpha()
	to_chat(M, "<span class='danger'>\The [L] teleports behind you!</span>")