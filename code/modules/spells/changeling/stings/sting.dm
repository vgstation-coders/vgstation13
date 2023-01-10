/spell/changeling/sting
	name = "Sting"
	desc = "We string our target."
	abbreviation = "ST"

	spell_flags = WAIT_FOR_CLICK|CAN_CHANNEL_RESTRAINED|NO_TURNING
	range = 1

	var/silent = 0      //dont show the "tiny prick!" message, takes priority if visible is also set to 1
	var/visible = 0     //shows a visible message upon the sting
	var/allowself = 1   //lets you target yourself
	var/delay = 0 SECONDS

/spell/changeling/sting/before_channel(mob/user)
	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
	if(changeling)
		range = changeling.sting_range

/spell/changeling/sting/cast(var/list/targets, mob/user)
	var/mob/living/L = targets[1]

	if(!istype(L))
		return FALSE
	if(user == L && !allowself)
		to_chat(user, "<span class='warning'>We cannot target ourselves.</span>")
		return FALSE

	if(!sting_can_reach(L, range))
		to_chat(user, "<span class='warning'>We cannot reach the target!</span>")
		return FALSE
	if(silent)
		to_chat(user, "<span class='warning'>We stealthily sting [L.name].</span>")
		user << 'sound/items/hypospray.ogg'
	else if(visible)
		user.visible_message("<span class='danger'>[user.name] shoots out a stinger from their body!</span>")
		to_chat(L, "<span class='warning'>You feel a tiny prick!</span>")
		playsound(user, 'sound/items/syringeproj.ogg', 50, 1)
	else
		to_chat(user, "<span class='warning'>We sting [L.name].</span>")
		to_chat(L, "<span class='warning'>You feel a tiny prick!</span>")
		user << 'sound/items/hypospray.ogg'



	..()

	spawn(delay)
		lingsting(user, L)

/spell/changeling/sting/proc/sting_can_reach(var/mob/M, sting_range = 1)
	if(!isturf(holder.loc) || !isturf(M.loc))
		return 0 //One is inside, the other is outside something.
	if(sting_range < 2)
		return holder.Adjacent(M)
	var/list/L = quick_AStar(get_turf(holder), get_turf(M), /turf/proc/AdjacentTurfs, /turf/proc/Distance, sting_range, reference="\ref[src]")
	if(L.len) //AStar returns an empty list, but since the list is something that's actually returned we check for entries in the list instead.
		return 1
	return 0

/spell/changeling/sting/proc/lingsting(var/mob/user, var/mob/living/target) //override this with the sting effects
	return

