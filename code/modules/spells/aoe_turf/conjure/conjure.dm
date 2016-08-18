/*
Conjure spells spawn things (mobs, objs, turfs) in their summon_type
How they spawn stuff is decided by behaviour vars, which are explained below
*/

/spell/aoe_turf/conjure
	name = "Conjure"
	desc = "This spell conjures objs of the specified types in range."

	school = "conjuration" //funny, that

	var/list/summon_type = list() //determines what exactly will be summoned
	//should be text, like list("/obj/machinery/bot/ed209")

	range = 0		//default values: only spawn on the player tile
	selection_type = "view"

	duration = 0 // 0=permanent, any other time in deciseconds - how long the summoned objects last for
	var/summon_amt = 1 //amount of objects summoned
	var/summon_exclusive = 0 //spawn one of everything, instead of random things

	var/list/newVars = list() //vars of the summoned objects will be replaced with those where they meet
	//should have format of list("emagged" = 1,"name" = "Wizard's Justicebot"), for example

/spell/aoe_turf/conjure/cast(list/targets, mob/user)
	playsound(get_turf(user), cast_sound, 50, 1)

	var/placed_successfully = 0
	for(var/i=1,i <= summon_amt,i++)
		if(!targets.len)
			break
		var/summoned_object_type
		if(summon_exclusive)
			if(!summon_type.len)
				break
			summoned_object_type = summon_type[1]
			summon_type -= summoned_object_type
		else
			summoned_object_type = pick(summon_type)
		var/turf/spawn_place = pick(targets)

		if(spell_flags & NODUPLICATE) //No spawning duplicates
			var/list/possible_targets = targets.Copy()
			while((locate(summoned_object_type) in spawn_place) && possible_targets.len)
				possible_targets -= spawn_place
				if(possible_targets.len)
					spawn_place = pick(possible_targets)
			if(!possible_targets.len)
				continue

		if(spell_flags & IGNOREPREV)
			targets -= spawn_place

		var/atom/summoned_object

		placed_successfully = 1

		if(ispath(summoned_object_type,/turf))
			if(istype(get_turf(user),/turf/simulated/shuttle) || istype(spawn_place, /turf/simulated/shuttle))
				to_chat(user, "<span class='warning>You can't build things on shuttles!</span>")
				continue
			spawn_place.ChangeTurf(summoned_object_type)
			summoned_object = spawn_place
		else
			summoned_object = new summoned_object_type(spawn_place)

		var/atom/movable/overlay/animation = new /atom/movable/overlay(spawn_place)
		animation.name = "conjure"
		animation.density = 0
		animation.anchored = 1
		animation.icon = 'icons/effects/effects.dmi'
		animation.layer = OBJ_LAYER
		animation.master = summoned_object

		for(var/varName in newVars)
			if(varName in summoned_object.vars)
				summoned_object.vars[varName] = newVars[varName]

		if(duration)
			spawn(duration)
				if(summoned_object && !istype(summoned_object, /turf))
					qdel(summoned_object)
		conjure_animation(animation, spawn_place)

	return !placed_successfully //prevent charge if we didn't cast anything

/spell/aoe_turf/conjure/proc/conjure_animation(var/atom/movable/overlay/animation, var/turf/target)
	qdel(animation)
	animation = null

/spell/aoe_turf/conjure/choice
	var/input_message = "What would you like to spawn?"
	var/input_title = "Spawn Object"
	//full list should be formatted an associated list of "Choice name" = Choicepath
	var/full_list = list()

//We're going to pick which of the things we would like to try spawning and set it
/spell/aoe_turf/conjure/choice/before_target(mob/user)
	var/choice = input(user, input_message, input_title) as null|anything in full_list
	if(!choice)
		return 1
	summon_type = list(full_list[choice])
	return ..()