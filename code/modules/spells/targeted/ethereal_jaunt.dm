/spell/targeted/ethereal_jaunt
	name = "Ethereal Jaunt"
	desc = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."
	abbreviation = "EJ"

	school = "transmutation"
	charge_max = 300
	spell_flags = Z2NOCAST | NEEDSCLOTHES | INCLUDEUSER
	invocation = "Rah'dee K'Alari"
	invocation_type = SpI_SHOUT
	range = SELFCAST
	max_targets = 1
	cooldown_min = 100 //50 deciseconds reduction per rank
	duration = 50 //in deciseconds

	hud_state = "wiz_jaunt"

	var/enteranim = "liquify"
	var/exitanim = "reappear"
	var/mist = 1

/image/jaunter

/image/jaunter/proc/update_dir(params)
	dir = params["dir"]

/spell/targeted/ethereal_jaunt/cast(list/targets)
	if(targets.len > 1)
		mass_jaunt(targets, duration, enteranim, exitanim, mist)
	else
		ethereal_jaunt(targets[1], duration, enteranim, exitanim, mist)

/proc/ethereal_jaunt(var/mob/living/target, duration, enteranim = "liquify", exitanim = "reappear", mist = 1)
	var/mobloc = get_turf(target)
	var/previncorp = target.incorporeal_move //This shouldn't ever matter under usual circumstances
	if(target.incorporeal_move == INCORPOREAL_ETHEREAL) //they're already jaunting, we have another fix for this but this is sane
		return
	target.unlock_from()
	//Begin jaunting with an animation
	anim(location = mobloc, target = target, a_icon = 'icons/mob/mob.dmi', flick_anim = enteranim, direction = target.dir, name = "water")
	if(mist)
		target.ExtinguishMob()
		var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
		steam.set_up(10, 0, mobloc)
		steam.start()

	//Turn on jaunt incorporeal movement, make him invincible and invisible
	target.incorporeal_move = INCORPOREAL_ETHEREAL
	target.invisibility = INVISIBILITY_MAXIMUM
	target.flags |= INVULNERABLE
	var/old_density = target.density
	target.density = 0
	target.candrop = 0
	target.alphas["etheral_jaunt"] = 125 //Spoopy mode to know you are jaunting
	target.handle_alpha()
	for(var/obj/screen/movable/spell_master/SM in target.spell_masters)
		SM.silence_spells(duration+25)
	target.delayNextAttack(duration+25)
	target.click_delayer.setDelay(duration+25)

	sleep(duration)

	//Begin unjaunting
	mobloc = get_turf(target)
	if(mist)
		var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
		steam.set_up(10, 0, mobloc)
		steam.start()
	target.delayNextMove(25)
	target.dir = SOUTH
	sleep(20)
	anim(location = mobloc, target = target, a_icon = 'icons/mob/mob.dmi', flick_anim = exitanim, direction = target.dir, name = "water")
	sleep(5)

	//Forcemove him onto the tile and make him visible and vulnerable
	target.forceMove(mobloc)
	target.invisibility = 0
	for(var/obj/screen/movable/spell_master/SM in target.spell_masters)
		SM.silence_spells(0)
	target.flags &= ~INVULNERABLE
	target.density = old_density
	target.candrop = 1
	target.incorporeal_move = previncorp
	target.alphas -= "etheral_jaunt"
	target.handle_alpha()

/proc/mass_jaunt(targets, duration, enteranim, exitanim, mist)
	var/list/jaunts = list()
	for(var/mob/living/target in targets)
		var/image/jaunter/I = new(icon = target.icon, loc = target, icon_state = target.icon_state)
		I.appearance = target.appearance
		I.alpha = 125
		jaunts[target] = I
	for(var/mob/living/target in targets)
		spawn(0)
			if(target.incorporeal_move != INCORPOREAL_ETHEREAL) //To avoid the potential for infinite jaunt
				if(target.client)
					for(var/A in jaunts)
						target.client.images += jaunts[A]
				var/on_moved_holder = target.on_moved
				target.on_moved = new("owner"=src)
				target.on_moved.Add(jaunts[target],"update_dir")
				ethereal_jaunt(target, duration, enteranim, exitanim, mist)
				qdel(target.on_moved)
				target.on_moved = on_moved_holder
				if(target.client)
					for(var/A in jaunts)
						target.client.images -= jaunts[A]

/spell/targeted/ethereal_jaunt/jauntgroup
	name = "Group Jaunt"
	desc = "This spell allows all people within range to be jaunted along with the user"
	hud_state = "group_jaunt"

	spell_flags = Z2NOCAST | INCLUDEUSER //Adminbus spell, so we'll exclude robe requirement for ease of use

	invocation = "Tc'ln Oc'lip"
	max_targets = 0
	range = 3

	charge_max = 600 //Double cooldown, makes it less spammable
	duration = 100 //Double jaunt time, makes it easier to cooperate

/spell/targeted/ethereal_jaunt/shift
	name = "Phase Shift"
	desc = "This spell allows you to pass through walls"

	charge_max = 200
	spell_flags = Z2NOCAST | INCLUDEUSER | CONSTRUCT_CHECK
	invocation_type = SpI_NONE
	range = SELFCAST
	duration = 50 //in deciseconds

	hud_state = "const_shift"

	enteranim = "phase_shift"
	exitanim = "phase_shift2"
	mist = 0
