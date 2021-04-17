//snail

var/snail_count = 0
var/max_snail_eggs = 15
var/max_snails = 40

/mob/living/simple_animal/snail
	species_type = /mob/living/simple_animal/snail
	name = "space snail"
	desc = "Taking on the world at its own pace. Larger than its cousins down on Earth."
	icon_state = "snail"
	icon_living = "snail"
	icon_dead = "snail_dead"
	speak_emote = list("") // Silent
	response_help  = "pets"
	response_disarm = "pokes"
	response_harm   = "stomps on"
	maxHealth = 12
	health = 12

	holder_type = /obj/item/weapon/holder/animal/snail

	size = SIZE_TINY

	pass_flags = PASSTABLE | PASSGRILLE | PASSMACHINE
	stop_automated_movement_when_pulled = 1

	turns_per_move = 8 //8 life ticks / move

	density = 0

	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/snail

	var/in_shell = 0
	var/being_romantic = 0
	var/mob/living/simple_animal/snail/loving_partner = null

/mob/living/simple_animal/snail/New()
	snail_count++
	return ..()

/mob/living/simple_animal/snail/Destroy()
	snail_count--
	if (loving_partner)
		loving_partner.loving_partner = null
		loving_partner = null
	return ..()

/mob/living/simple_animal/snail/bite_act(mob/living/carbon/human/H)
	if(size >= H.size)
		return

	playsound(H,'sound/items/eatfood.ogg', rand(10,50), 1)
	H.visible_message("<span class='warning'>[H] tries to eat \the [src], but hurts \his teeth doing so! The idiot!</span>", "<span class='warning'>You break your teeth on \the [src]! Imbecile!</span>")
	return

/mob/living/simple_animal/snail/Life()
	if (timestopped)
		return 0
	if (in_shell)
		in_shell--
		return
	if (!in_shell)
		icon_state = initial(icon_state)
	if (being_romantic)
		being_romantic--
		if (being_romantic == 0)
			new /obj/item/weapon/reagent_containers/food/snacks/egg/snail(get_turf(src))
			visible_message("<span class='notice'>\The [src] gently goes off its partner.</span>")
			loving_partner.being_romantic = 0
			loving_partner.loving_partner = null
			loving_partner = null
		return
	return ..()

/mob/living/simple_animal/snail/Crossed(mob/living/O)
	if (!in_shell && !isDead())
		recoil()
	return ..()

/mob/living/simple_animal/snail/proc/recoil()
	if (loving_partner)
		loving_partner.being_romantic = 0
		loving_partner.loving_partner = null
		loving_partner.recoil()
		being_romantic = 0
		loving_partner = null
	icon_state = "snail_recoil"
	visible_message("<span class = 'notice'>\The [src] stops whatever it was doing and recoils into its shell.</span>")
	in_shell = 5 // Shy for some cycles

/mob/living/simple_animal/snail/wander_move(turf/dest)
	..()
	if (life_tick < 25)
		return
	if (snail_egg_count >= max_snail_eggs)
		return
	if (snail_count >= max_snails)
		return
	for(var/mob/living/simple_animal/snail/partner in loc)
		if (partner == src) // no
			continue
		if (partner.being_romantic)
			return // the other snail is busy

		if (prob(80))
			return

		being_romantic = 45
		loving_partner = partner
		partner.being_romantic = 45
		partner.loving_partner = src
		visible_message("<span class='notice'>\The [src] begins to softly approach \the [partner]...</span>")

/mob/living/simple_animal/snail/examine(var/mob/user)
	. = ..()
	if (in_shell)
		to_chat(user, "It's currently hiding in its shell.")
	if (being_romantic)
		to_chat(user, "It looks pretty busy.")

/mob/living/simple_animal/snail/attackby(var/obj/item/O, var/mob/user, var/no_delay = FALSE, var/originator = null)
	if (!in_shell)
		recoil()
	return ..()

/mob/living/simple_animal/snail/kick_act(mob/living/carbon/human/M)
	if (!in_shell)
		recoil()
	return ..()

/mob/living/simple_animal/snail/airflow_stun()
	if (!in_shell)
		recoil()
	return ..()

/mob/living/simple_animal/snail/airflow_hit(atom/A)
	if (!in_shell)
		recoil()
	return ..()

/mob/living/simple_animal/snail/adjustBruteLoss(var/damage)
	if (in_shell)
		return ..(damage/2)
	return ..()

// -- Greasy snail. Lube up hallways as he go. Tougher than its regular counterpart
/mob/living/simple_animal/snail/greasy
	maxHealth = 40
	health = 40

/mob/living/simple_animal/snail/greasy/wander_move(turf/simulated/dest)
	if (istype(dest) && prob(20))
		dest.wet(800, TURF_WET_LUBE)
	return ..()
