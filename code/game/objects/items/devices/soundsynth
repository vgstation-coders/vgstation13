/*
I originaly had a thing that would allow for less tedius sound adding,
But it got scrapped because I dont know anything about byond.
This is probably the most complex thing I have coded in BYOND thus far, and is probably
overcomplex bullshit.

Not only is the mechinism for cycling sounds pants on head retarded, but you cant even know
what sound you are on. I origionaly attempted to include it, but Im far too simple to figure out
how to make multiple ifs.

The mechanism used in this code is probably the most retarded thing you have ever seen,
and will most likely be fixed by someone with much more talent then I currently possess.

Take refuge in the fact that I /may/ actually be getting bettter, but at a slow rate.

Atleast this will be a nice learning experiance for me.

Have fun trying to use this.
- Heredth
*/

/obj/item/device/soundsynth
	name = "sound synthesizer"
	desc = "A device that is able to create sounds."
	icon_state = "megaphone"
	item_state = "radio"
	w_class = 1.0
	flags = FPRINT | TABLEPASS | CONDUCT

	var/spam_flag = 0 //To prevent mashing the button to cause annoyance like a huge idiot.
	var/sound_flag = 1

/*
This is to cycle sounds forward
*/
/obj/item/device/soundsynth/verb/CycleForward()
	set category = "Object"
	set name = "Cycle Sound Forward"

	if(sound_flag <= 12)
		sound_flag += 1
	else
		return

/*
And backwards
*/
/obj/item/device/soundsynth/verb/CycleBackward()
	set category = "Object"
	set name = "Cycle Sound Backward"

	if(sound_flag >= 0)
		sound_flag -= 1
	else
		return

/*
This long ass as fuck shit plays the sounds. Im a huge fucking faggot.
If you can make this smaller, please do.
*/


/obj/item/device/soundsynth/attack_self(mob/user as mob)
	if(sound_flag == 0)
		if (spam_flag == 0)
			spam_flag = 1
			playsound(get_turf(src), 'sound/items/bikehorn.ogg', 50, 1)
			usr << "Honk!"
			spawn(20)
				spam_flag = 0
		return

	if(sound_flag == 1)
		if (spam_flag == 0)
			spam_flag = 1
			playsound(get_turf(src), 'sound/effects/adminhelp.ogg', 50, 1)
			spawn(20)
				spam_flag = 0
		return

	if(sound_flag == 2)
		if (spam_flag == 0)
			spam_flag = 1
			playsound(get_turf(src), 'sound/effects/Explosion1.ogg', 50, 1)
			spawn(20)
				spam_flag = 0
		return

	if(sound_flag == 3)
		if (spam_flag == 0)
			spam_flag = 1
			playsound(get_turf(src), 'sound/mecha/nominal.ogg', 50, 1)
			spawn(20)
				spam_flag = 0


	if(sound_flag == 4)
		if (spam_flag == 0)
			spam_flag = 1
			playsound(get_turf(src), 'sound/effects/alert.ogg', 50, 1)
			spawn(20)
				spam_flag = 0
		return


	if(sound_flag == 5)
		if (spam_flag == 0)
			spam_flag = 1
			playsound(get_turf(src), 'sound/items/AirHorn.ogg', 50, 1)
			spawn(20)
				spam_flag = 0
		return

	if(sound_flag == 6)
		if (spam_flag == 0)
			spam_flag = 1
			playsound(get_turf(src), 'sound/misc/sadtrombone.ogg', 50, 1)
			spawn(20)
				spam_flag = 0
		return


	if(sound_flag == 7)
		if (spam_flag == 0)
			spam_flag = 1
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
			spawn(20)
				spam_flag = 0
		return

	if(sound_flag == 8)
		if (spam_flag == 0)
			spam_flag = 1
			playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
			spawn(20)
				spam_flag = 0
		return

	if(sound_flag == 9)
		if (spam_flag == 0)
			spam_flag = 1
			playsound(get_turf(src), 'sound/hallucinations/turn_around1.ogg', 50, 1)
			spawn(20)
				spam_flag = 0
		return


	if(sound_flag == 10)
		if (spam_flag == 0)
			spam_flag = 1
			playsound(get_turf(src), 'sound/machines/ding.ogg', 50, 1)
			spawn(20)
				spam_flag = 0
		return


	if(sound_flag == 11)
		if (spam_flag == 0)
			spam_flag = 1
			playsound(get_turf(src), 'sound/machines/disposalflush.ogg', 50, 1)
			spawn(20)
				spam_flag = 0
		return


	if(sound_flag == 12)
		if (spam_flag == 0)
			spam_flag = 1
			playsound(get_turf(src), 'sound/machines/twobeep.ogg', 50, 1)
			spawn(20)
				spam_flag = 0
		return

	else
		return
