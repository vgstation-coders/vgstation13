#define DEFAULT_DRINK_RATE 8 //2x IV drip speed, finishes with a patient in ~7 seconds
#define DANGER_DRINK_RATE 40 //Terrifying speed, can drain a human in 14 seconds or begin to cause damage in 6 seconds
//Notes: Humans have 560u Blood. This bot won't consume below 501u (~90%). Therefore, 59u can be donated if full.
//Humans regain 0.1u blood/tick, +0.6u/t for 0.5 nutriment, +1.2u/t for 0.5 iron.
//One ijzerkoekje is theoretically good for 18u blood over 10 ticks.
//Rewards dispensed once every 55u donated.

/obj/machinery/bot/bloodbot
	name = "Doctor Acula"
	desc = "A blood donation medibot. If wearing a cape, notify security immediately."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "bloodbot00"
	density = 0
	on = 0
	anchored = 0
	health = 40
	maxhealth = 20
	req_access = list(access_medical)
	var/mob/living/carbon/human/target //Only used if emagged
	var/currently_drawing_blood = 0 //One patient at a time.
	var/quiet = 0
	var/since_last_reward = 0 //Once every 55u, dispense reward
	var/list/possible_rewards = list(/obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje,
								/obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje,
								/obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje,
								/obj/item/weapon/reagent_containers/food/snacks/chococoin/wrapped,
								/obj/item/weapon/reagent_containers/food/snacks/chococoin/wrapped,
								/obj/item/weapon/reagent_containers/food/snacks/chococoin/wrapped,
								/obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje_helper_dummy) //3/7 chance for one cookie, 3/7 chance for chococoin, 1/7 for many cookies!
	var/list/contained_bags = list()
	var/obj/item/weapon/reagent_containers/blood/last_bag

/obj/machinery/bot/bloodbot/New()
	..()
	for(var/i = 1 to 8)
		contained_bags += new /obj/item/weapon/reagent_containers/blood/empty(src)

/obj/machinery/bot/bloodbot/Destroy()
	for(var/obj/O in contained_bags)
		O.forceMove(get_turf(src))
	contained_bags = null
	last_bag = null
	..()

/obj/machinery/bot/bloodbot/update_icon()
	if(contained_bags.len || emagged)
		icon_state = "bloodbot[emagged][currently_drawing_blood]"
	else
		icon_state = "bloodbot-e"

/obj/machinery/bot/bloodbot/turn_on()
	..()
	update_icon()
	updateUsrDialog()

/obj/machinery/bot/bloodbot/turn_off()
	if(emagged)
		return
	..()
	currently_drawing_blood = 0
	update_icon()

/obj/machinery/bot/bloodbot/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/bot/bloodbot/attack_hand(mob/user as mob)
	if(..())
		return
	var/dat
	dat += "<TT><B>Acula-class Blood Donation Bot v1.0</B></TT><BR><BR>"
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/datum/reagent/blood/B = H.get_blood(H.vessel)
		if(B && B.data && B.data["virus2"])
			dat += "WARNING: Viral agent detected. Ineligible for blood donation.<BR>"
		else if(!B)
			dat += "WARNING: No blood detected. Ineligible for blood donation.<BR>"
		else
			dat += {"Welcome [H]! Your blood level is [round(B.volume/560*100)]%, and your blood type is [B.data["blood_type"]].<BR>
				You must have at least [round(509/560*100)]% to donate blood. <a href='?src=\ref[src];donate=[1]'>Donate now!</a><BR>
				The next reward will be dispensed after [55 - since_last_reward] units of blood are donated.<BR>"}
	dat += {"Status: <A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A><BR>
			The maintenance panel is [src.open ? "opened" : "closed"]<BR>"}
	if(!src.locked || issilicon(user))
		dat += "<TT>Blood Storage:<BR>"
		var/counter = 0
		if(!contents.len)
			dat += "There are no blood packs available.<BR>"
		for (var/obj/item/weapon/reagent_containers/blood/E in contained_bags)
			counter++
			dat += "Slot [counter]: [E] ([100 * E.reagents.total_volume / E.reagents.maximum_volume]% filled)<A href='?src=\ref[src];slot=\ref[E]'>(Eject)</A><BR>"
		dat += "</TT>The speaker switch is [src.quiet ? "off" : "on"]. <a href='?src=\ref[src];togglevoice=[1]'>Toggle</a><br>"

	dat = jointext(dat,"")
	var/datum/browser/popup = new(usr, "\ref[src]", "[name]", 575, 400)
	popup.set_content(dat)
	popup.open()

/obj/machinery/bot/bloodbot/Topic(href, href_list)
	if(..())
		return TRUE
	usr.set_machine(src)
	add_fingerprint(usr)
	if(href_list["power"] && allowed(usr))
		if(on)
			turn_off()
		else
			turn_on()

	else if(href_list["slot"] && contained_bags.len && allowed(usr))
		var/obj/item/weapon/reagent_containers/blood/E = locate(href_list["slot"])
		if(E.loc != src)
			return //No fishing items with href exploits
		usr.put_in_hands(E) //Try to put it in the user's hands if available.
		contained_bags -= E
		updateUsrDialog()
		update_icon()

	else if(href_list["donate"])
		if(currently_drawing_blood)
			speak("Sorry! One customer at a time!")
			return
		else
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				if(H.species.anatomy_flags & NO_BLOOD)
					to_chat(usr, "<span class = 'notice'>You have no blood to give!</span>")
				else
					speak(pick("I'll just take a quick bite.","You may feel a slight sting.","There will be no anesthetic.","Delicious!","Don't mind if I do...","Thanks!"))
					drink(usr)

	else if(href_list["togglevoice"] && (!src.locked || issilicon(usr)))
		quiet = !quiet

	updateUsrDialog()

/obj/machinery/bot/bloodbot/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (allowed(user) && !emagged)
			locked = !locked
			to_chat(user, "<span class='notice'>Controls are now [locked ? "locked" : "unlocked"].</span>")
			updateUsrDialog()
		else
			if(emagged)
				to_chat(user, "<span class='warning'>ERROR</span>")
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")

	if(istype(W,/obj/item/weapon/reagent_containers/blood))
		var/obj/item/weapon/reagent_containers/blood/B = W
		if(B.reagents.is_full())
			speak("Sorry, nurse. There's no room for more blood in that one.")
		else
			user.drop_from_inventory(B)
			B.forceMove(src)
			contained_bags += B
			speak("Thanks, nurse! Now I've got [contained_bags.len]!")
			update_icon()
			updateUsrDialog()
	if(health < maxhealth && !isscrewdriver(W) && W.force && !emagged) //Retreat if we're not hostile and we're under attack
		step_to(src, get_step_away(src,user))
	..()

/obj/machinery/bot/bloodbot/Emag(mob/user as mob)
	if(!locked)
		visible_message("<span class='danger'>[src] buzzes oddly!</span>", 1)
		emagged = 1
		on = 1
		update_icon()
	else
		locked = 0
		visible_message("<span class='danger'>[src]'s panel clicks open.</span>", 1)

/obj/machinery/bot/bloodbot/process()
	if(!on)
		return
	if(!emagged) //In a normal situation, the bloodbot just loiters around instead of seeking out targets
		if(!quiet && prob(5))
			speak(pick("Donate blood here!","I'm going to want another blood sample.","Give blood so others may live.","Share life. Donate blood.","C’mon! We know you’ve got it in you!","Hey -- you're somebody's type!"))
		if(!currently_drawing_blood && prob(5)) //Wander
			Move(get_step(src, pick(cardinal)))
	else //First priority: drink an adjacent target. Otherwise, pick a target and move toward it if we have none.
		if(prob(5))
			speak(pick("Blaah!","I vant to suck your blood!","I never drink... wine.","The blood is the life.","I must hunt soon!","I hunger!","Death rages.","The night beckons.","Mwa ha ha!"))
		for(var/mob/living/carbon/human/H in view(1,src))
			if(H.vessel.has_reagent(BLOOD) && !(H.species.anatomy_flags & NO_BLOOD))
				drink(H)
				return //Dr. Acula is easily distracted. If he finds anything to drink en route to his target he will stop and drain it first.
		if(target && !target.vessel.get_reagent_amount(BLOOD))
			target = null
		if(!target)
			var/list/possible_targets = list()
			for(var/mob/living/carbon/human/H in view(7,src))
				if(H.vessel.get_reagent_amount(BLOOD) && !(H.species.anatomy_flags & NO_BLOOD))
					possible_targets += H
			if(possible_targets)
				target = pick(possible_targets)
			else
				return
		if(target)
			walk_to(src,get_turf(target),1,0,1)

/obj/machinery/bot/bloodbot/proc/drink(mob/living/carbon/human/H)
	if(!on || !istype(H))
		return
	if(!emagged) //Normal behavior
		if(since_last_reward >= 55)
			since_last_reward -= 55
			dispense_reward()
		if(!Adjacent(H))
			speak("Hey! I wasn't finished!")
			currently_drawing_blood = 0
			update_icon()
			return
		if(round(H.vessel.get_reagent_amount(BLOOD)) <= BLOOD_VOLUME_SAFE)
			speak(pick("No more for now!","Thank you for donating!","I'm O Positive that this will be put to good use!"))
			currently_drawing_blood = 0
			update_icon()
			return
		//look for our last used bag and see if it's still valid.
		var/obj/item/weapon/reagent_containers/blood/B = null
		var/datum/reagent/blood/target_blood = H.get_blood(H.vessel)
		if(last_bag && !last_bag.reagents.is_full() && last_bag.blood_type == target_blood.data["blood_type"])
			B = last_bag
		else
			B = get_matching_bag(target_blood.data["blood_type"])
		if(!istype(B))
			turn_off()
			return
		//Okay, we definitely have a bag.
		currently_drawing_blood = 1
		update_icon()
		H.vessel.trans_id_to(B,BLOOD,DEFAULT_DRINK_RATE)
		since_last_reward += DEFAULT_DRINK_RATE
		updateUsrDialog()
		spawn(1 SECONDS)
			drink(H)

	else //Blah! Splash blood on the floor and drink like crazy!
		if(!Adjacent(H))
			return
		H.vessel.remove_reagent(BLOOD,DANGER_DRINK_RATE)
		getFromPool(/obj/effect/decal/cleanable/blood, get_turf(src))
		playsound(get_turf(src), 'sound/effects/splat.ogg', 50, 1)
		spawn(1 SECONDS)
			drink(H)

/obj/machinery/bot/bloodbot/proc/get_matching_bag(existing_type)
	if(!existing_type)
		speak("Error: Blood type unknown.")
		return null
	if(!contained_bags.len)
		speak("Error: No bags inserted.")
		return null
	for(var/obj/item/weapon/reagent_containers/blood/B in contained_bags)
		if(B.reagents.is_full() || B.blood_type != existing_type)
			continue
		last_bag = B
		return B
	//We don't have a matching bag, but what about an empty bag?
	for(var/obj/item/weapon/reagent_containers/blood/B in contained_bags)
		if(B.reagents.is_empty())
			last_bag = B
			return B
	speak("Error: No valid bags.")
	return null

/obj/machinery/bot/bloodbot/proc/dispense_reward()
	speak(pick("Enjoy!","Come again!","Donate often!"))
	var/path = pick(possible_rewards)
	new path(get_turf(src))

/obj/machinery/bot/bloodbot/proc/speak(var/message)
	if(!src.on || !message)
		return
	say(message)

/obj/machinery/bot/bloodbot/explode()
	visible_message("<span class='danger'>[src] blows apart!</span>", 1)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	..()
