/obj/item/weapon/armblade
	name = "arm blade"
	desc = "A vicious looking blade made of flesh and bone that tears through people with horrifying ease."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "armblade"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	force = 30
	armor_penetration = 75
	sharpness = 1.5
	sharpness_flags = SHARP_TIP | SHARP_BLADE | CHOPWOOD
	throwforce = 0
	throw_speed = 0
	throw_range = 0
	w_class = W_CLASS_LARGE
	attack_verb = list("attacks", "slashes", "rends", "slices", "tears", "rips", "shreds", "cuts")
	hitsound = "sound/weapons/bloodyslice.ogg"
	cant_drop = 1
	var/spin_last_used
	var/spin_cooldown = 30 SECONDS
	//Spin attack variables
	var/spin_duration = 1.5 SECONDS //How many seconds the spin lasts
	var/attack_modulo = 0.5 SECONDS //How often everyone nearby is attacked, every X seconds
	var/step_modulo = 0.2 SECONDS //How often the changeling moves one step, every X seconds
	var/sound_modulo = 0.8 SECONDS //How often the sound effect plays, every X seconds, current audio file lasts ~0.8 seconds


/obj/item/weapon/armblade/New()
	..()
	spin_last_used = world.timeofday //Always the latest on New() so that one can't just remake the armblade.

/obj/item/weapon/armblade/IsShield()
    return 1

/obj/item/weapon/armblade/dropped()
	qdel(src)

/obj/item/weapon/armblade/examine(mob/user, size, show_name)
	..()
	if(ischangeling(user) && is_holder_of(user, src))
		if((spin_last_used + spin_cooldown) <= world.timeofday)
			to_chat(user, "<span class='good'>The spin attack is ready to be used! Activate it in your hand to initiate it.</span>")
		else
			to_chat(user, "<span class='warning'>The spin attack is not available yet! It will be available in [((spin_last_used + spin_cooldown) - world.timeofday)/10] seconds.</span>")

/obj/item/weapon/armblade/attack_self(mob/user)
	..()
	if(!ischangeling(user))
		return
	if((spin_last_used + spin_cooldown) <= world.timeofday)
		if(user.incapacitated()) //Sanity
			to_chat(user, "<span class='warning'>You cannot move your armblade around!</span>")
			return
		if(user.locked_to) //Can't use while buckled up AKA no chairs, vehicles or anything like that
			to_chat(user, "<span class='warning'>You need to be on foot to perform the spin attack!</span>")
			return
		if(!isturf(user.loc)) //In a mecha, locker or something else
			to_chat(user, "<span class='warning'>You do not have enough room to move your armblade around!</span>")
			return
		spin_attack(user)
	else
		to_chat(user, "<span class='warning'>Your arm is too exhausted to perform the spin attack! It will be available in [((spin_last_used + spin_cooldown) - world.timeofday)/10] seconds.</span>")

/obj/item/weapon/armblade/proc/spin_attack(var/mob/user)
	var/initial_direction = user.dir //Direction in which the changeling will move
	var/spin_direction = (user.active_hand == GRASP_RIGHT_HAND) ? "Left" : "Right" //Different spinning directions depending on arm
	var/spin_facing = initial_direction //For the purpose of where to spin next
	var/delay_track = spin_duration //If the action ends prematurely for some reason it will free the changeling of the remaining duration

	visible_message("<span class='sinister'>\The [user] starts wildly spinning their armblade around!</span>")
	user.delayNextMove(spin_duration, 1) //Can't move during the spin
	user.delayNextAttack(spin_duration, 1) //Can't attack extra times during the spin
	for(var/i = 0 to spin_duration)
		if(user.incapacitated() || user.locked_to || !isturf(user.loc) || gcDestroyed) //Double-checking to see if the changeling is allowed to do this
			user.delayNextMove(-delay_track, 1) //So that the changeling doesn't get magically stuck if it ends early
			user.delayNextAttack(-delay_track, 1)
			break
		if(i % step_modulo == 0)
			step(user, initial_direction)
		if(i % attack_modulo == 0)
			for(var/mob/living/L in range(1))
				if(L == user) //No self-hitting with the spin attack
					continue
				if(L.lying) //Armblade swings over them!
					continue
				var/targeted_area = ran_zone(LIMB_CHEST) //Primarily focuses the attacks around the torso rather than where the user is aiming
				attack(L, user, targeted_area)
		if(i % sound_modulo == 0)
			playsound(src, 'sound/weapons/blade_whirlwind.ogg', 75)
		spin_facing = spin_turn(spin_facing, spin_direction)
		user.change_dir(spin_facing)
		delay_track--
		sleep(1)
	user.change_dir(initial_direction)
	spin_last_used = world.timeofday

//Returns a value depending on the spin direction and where the user is currently facing.
/obj/item/weapon/armblade/proc/spin_turn(var/facing, var/direction)
	switch(direction)
		if("Left")
			return turn(facing, 90)
		if("Right")
			return turn(facing, -90)
