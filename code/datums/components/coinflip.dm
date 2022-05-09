/datum/component/coinflip
	var/sideup

/datum/component/coinflip/initialize()
	if(!iscoin(parent))
		return FALSE

	parent.register_event(/event/item_attack_self, src, .proc/on_attack_self)
	parent.register_event(/event/throw_impact, src, .proc/on_throw_impact)
	parent.register_event(/event/equipped, src, .proc/equipped)
	parent.register_event(/event/examined, src, .proc/examined)

	sideup = pick(COIN_HEADS, COIN_TAILS)

	return TRUE

/datum/component/coinflip/Destroy()
	parent.unregister_event(/event/item_attack_self, src, .proc/on_attack_self)
	parent.unregister_event(/event/throw_impact, src, .proc/on_throw_impact)
	parent.unregister_event(/event/equipped, src, .proc/equipped)
	parent.unregister_event(/event/examined, src, .proc/examined)
	..()

/datum/component/coinflip/proc/on_attack_self(mob/living/user, obj/item/item)
	if(!isfood(parent))
		coinflip(user, TRUE)

/datum/component/coinflip/proc/on_throw_impact(atom/hit_atom, var/speed, mob/user)
	coinflip(thrown = TRUE)

/datum/component/coinflip/proc/equipped()
	if(sideup == COIN_SIDE)
		sideup = pick(COIN_HEADS, COIN_TAILS)
	var/obj/O = parent as obj
	O.transform = null

/datum/component/coinflip/proc/examined(mob/examiner)
	to_chat(examiner, "<span class='notice'>[parent] is [sideup]</span>")

/datum/component/coinflip/proc/coinflip(var/mob/user, thrown, rigged = FALSE)
	var/matrix/flipit = matrix()
	flipit.Scale(0.2,1)
	animate(parent, transform = flipit, time = 1.5, easing = QUAD_EASING)
	flipit.Scale(5,1)
	flipit.Invert()
	flipit.Turn(rand(1,359))
	animate(transform = flipit, time = 1.5, easing = QUAD_EASING)
	flipit.Scale(0.2,1)
	animate(transform = flipit, time = 1.5, easing = QUAD_EASING)
	if (pick(0,1))
		sideup = COIN_HEADS
		flipit.Scale(5,1)
		flipit.Turn(rand(1,359))
		animate(transform = flipit, time = 1.5, easing = QUAD_EASING)
	else
		sideup = COIN_TAILS
		flipit.Scale(5,1)
		flipit.Invert()
		flipit.Turn(rand(1,359))
		animate(transform = flipit, time = 1.5, easing = QUAD_EASING)
	if (prob(0.1) || rigged)
		flipit.Scale(0.2,1)
		animate(transform = flipit, time = 1.5, easing = QUAD_EASING)
		sideup = COIN_SIDE
	if(!thrown)
		user.visible_message("<span class='notice'>[user] flips [parent]. It lands [sideup]</span>", \
							 "<span class='notice'>You flip [parent]. It lands [sideup]</span>", \
							 "<span class='notice'>You hear [parent] landing.</span>")
	else
		var/obj/O = parent as obj
		if(!O.throwing) //coin was thrown and is coming to rest
			O.visible_message("<span class='notice'>[parent] stops spinning, landing [sideup]</span>")

//todo: Check parent.transform versus transform.