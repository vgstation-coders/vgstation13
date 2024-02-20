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
	var/initial_direction = user.dir //Move in this direction, spinning also constantly resets the user's direction
	var/targeted_area = ran_zone(LIMB_CHEST) //Primarily focuses the attacks around the torso
	visible_message("<span class='sinister'>[user] starts wildly spinning their armblade around!</span>")
	user.delayNextMove(15) //Can't move during the spin
	user.emote("spin")
	for(var/i=0, i<15, i++) //1.5 seconds duration
		if(user.incapacitated() || user.locked_to || !isturf(user.loc)) //Double-checking to see if the changeling is allowed to do this
			break
		if(i % 2 == 0) //Moves in the set direction every 0.2 seconds, slower than default movement speed
			step(user, initial_direction)
		if(i % 5 == 0) //Attacks everyone nearby every 0.5 seconds
			for(var/mob/living/L in range(1))
				if(L == user) //No self-hitting with the spin attack
					continue
				if(L.lying) //Armblade swings over them!
					continue
				attack(L, user, targeted_area)
		if(i % 8 == 0) //Roughly the duration of the sound file
			playsound(src, 'sound/weapons/blade_whirlwind.ogg', 75)
		sleep(1)
	spin_last_used = world.timeofday
