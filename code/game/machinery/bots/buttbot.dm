/*
I..

I'm so sorry.

I'm so very, very sorry.

Here it is: Buttbot.
*/

/obj/machinery/bot/buttbot
	name = "butt bot"
	desc = "Somehow, this doesn't bode well with you."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "buttbot"
	density = 0
	anchored = 0
	//weight = 1.0E7
	health = 25
	maxhealth = 25
	var/buttchance = 80 //Like an 80% chance of it working. It's just a butt with an arm in it.
	var/sincelastfart = 0
	flags = HEAR

/obj/machinery/bot/buttbot/attack_hand(mob/living/user as mob)
	. = ..()
	if (.)
		return
	if(sincelastfart + 5 < world.timeofday)
		speak("butt")
		playsound(get_turf(src), 'sound/misc/fart.ogg', 50, 1)
		sincelastfart = world.timeofday




/obj/machinery/bot/buttbot/proc/speak(var/message)
	if((!src.on) || (!message))
		return
	for(var/mob/O in hearers(src, null))
		O.show_message("<b>[src]</b> beeps, '[message]'")
	return


/obj/machinery/bot/buttbot/Hear(var/datum/speech/speech, var/rendered_speech="")
	set waitfor = 0 //Buttbots speaking should be queued after the original speech completes
	if(prob(buttchance) && !findtext(speech.message,"butt"))
		sleep(rand(1,3))
		var/list/split_phrase = splittext(speech.message," ") // Split it up into words.

		var/list/prepared_words = split_phrase.Copy()
		var/i = rand(1,3)
		for(,i > 0,i--) //Pick a few words to change.

			if (!prepared_words.len)
				break
			var/word = pick(prepared_words)
			prepared_words -= word //Remove from unstuttered words so we don't stutter it again.
			var/index = split_phrase.Find(word) //Find the word in the split phrase so we can replace it.

			split_phrase[index] = "butt"

		say(jointext(split_phrase," "), speech.language) // No longer need to sanitize, speech is automatically html_encoded at render-time.



/obj/machinery/bot/buttbot/explode()
	src.on = 0
	src.visible_message("<span class='danger'>[src] blows apart!</span>", 1)
	playsound(get_turf(src), 'sound/effects/superfart.ogg', 50, 1) //A fitting end
	var/turf/Tsec = get_turf(src)
	new /obj/item/clothing/head/butt(Tsec)

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/blood/oil(src.loc)
	..()


/obj/item/clothing/head/butt/attackby(var/obj/item/W, mob/user as mob)
	. = ..()
	if(.)
		return .
	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		qdel(W)
		var/turf/T = get_turf(user.loc)
		var/obj/machinery/bot/buttbot/A = new /obj/machinery/bot/buttbot(T)
		A.name = src.created_name
		to_chat(user, "<span class='notice'>You roughly shove the robot arm into the ass! Butt Butt!</span>")//I don't even.

		user.drop_from_inventory(src)
		qdel(src)
	else if (istype(W, /obj/item/weapon/pen))
		var/t = stripped_input(user, "Enter new robot name", src.name, src.created_name)

		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t
