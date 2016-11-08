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
	icon_state = "bloodbot0"
	density = 0
	anchored = 0
	health = 20
	maxhealth = 20
	req_access =list(access_medical)
	var/mob/living/carbon/human/target //Only used if emagged
	var/currently_drawing_blood = 0 //One patient at a time.
	var/quiet = 0
	var/since_last_reward = 0 //Once every 55u, dispense reward
	var/list/possible_rewards = list(/obj/item/weapon/reagent_containers/food/snacks/ijzerkoekje) //Could add more later or adminbus
	var/reserve_bags = 3 //How many empty bags do we have?
	bot_type = MED_BOT //This handles which HUD the bot talks to.

/obj/machinery/bot/bloodbot/update_icon()
	icon_state = "bloodbot[emagged][currently_drawing_blood]"

/obj/machinery/bot/bloodbot/turn_on()
	..()
	update_icon()
	updateUsrDialog()

/obj/machinery/bot/bloodbot/turn_off()
	..()
	currently_drawing_blood = 0
	update_icon()

/obj/machinery/bot/bloodbot/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/bot/bloodbot/attack_hand(mob/user as mob)
	if(..())
		return
	var/dat
	dat += "<TT><B>Acula-class Blood Donation Bot v0.1</B></TT><BR><BR>"
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/datum/reagent/blood/B = H.get_blood(H.vessel)
		if(B.data["virus2"])
			dat += "<span class='danger'>WARNING: Viral agent detected. Ineligable for blood donation.</span><BR>"
		else
			dat += {"Welcome [H]! Your blood level is [round(B.volume/560*100)]%, and your blood type is [B.data["blood_type"]].<BR>
				You must have at least [round(509/560*100)]% to donate blood. <a href='?src=\ref[src];donate=[1]'>Donate now!</a><BR>
				The next reward will be dispensed after [55 - since_last_reward] units of blood are donated.<BR>"}
	dat += {"Status: <A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A><BR>"
		Maintenance panel panel is [src.open ? "opened" : "closed"]<BR>"}
	if(!src.locked || issilicon(user))
		dat += "<TT>Blood Storage: "
		var/counter = 0
		if(!contents.len)
			dat += "There are no blood packs available."
		for (var/obj/item/weapon/reagent_containers/blood/E in contents)
			counter++
			dat += "Slot [counter]: [E] <A href='?src=\ref[src];slot=\ref[E]'>(Eject)</A><BR>"
		dat += "The speaker switch is [src.quiet ? "off" : "on"]. <a href='?src=\ref[src];togglevoice=[1]'>Toggle</a><br>"

	user << browse("<HEAD><TITLE>Dr. Acula Controls</TITLE></HEAD>[dat]", "window=autoblood")
	onclose(user, "autoblood")
	return

/obj/machinery/bot/bloodbot/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)
	if(href_list["power"] && allowed(usr))
		if(on)
			turn_off()
		else
			turn_on()

	else if(href_list["slot"] && contents.len)
		var/obj/item/weapon/reagent_containers/blood/E = locate(href_list["slot"])
		E.forceMove(get_turf(src))
		usr.put_in_hands(E) //Try to put it in the user's hands if available.
		updateUsrDialog()

	else if(href_list["donate"])
		if(currently_drawing_blood)
			speak("Sorry! One customer at a time!")
			return
		else
			speak(pick("I'll just take a quick bite.","You may feel a slight sting.","There will be no anesthetic.","Delicious!","Don't mind if I do...","Thanks!"))
			drink(usr)

	else if(href_list["togglevoice"] && (!src.locked || issilicon(usr)))
		quiet = !quiet

	src.updateUsrDialog()

/obj/machinery/bot/bloodbot/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (allowed(user) && !open && !emagged)
			locked = !locked
			to_chat(user, "<span class='notice'>Controls are now [locked ? "locked" : "unlocked"].</span>")
			updateUsrDialog()
		else
			if(emagged)
				to_chat(user, "<span class='warning'>ERROR</span>")
			if(open)
				to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")

	else
		..()
		if(istype(W,/obj/item/weapon/reagent_containers/blood))
			var/obj/item/weapon/reagent_containers/blood/B = W
			if(!B.reagents.is_empty())
				speak("Sorry, nurse. I only take empty bags. Don't want to mix up the blood, right?")
			else
				speak("Thanks, nurse! Now I've got [reserve_bags+1]!")
				user.drop_from_inventory(B)
				qdel(B)
				reserve_bags++
		if(health < maxhealth && !isscrewdriver(W) && W.force && !emagged) //Retreat if we're not hostile and we're under attack
			step_to(src, (get_step_away(src,user)))

/obj/machinery/bot/bloodbot/Emag(mob/user as mob)
	..()
	if(open && !locked)
		visible_message("<span class='danger'>[src] buzzes oddly!</span>", 1)
		emagged = 1
		on = 1
		update_icon()

/obj/machinery/bot/bloodbot/process()
	if(!on)
		return
	if(!emagged) //In a normal situation, the bloodbot just loiters around instead of seeking out targets
		if(!quiet && prob(5))
			speak(pick("Donate blood here!","I'm going to want another blood sample.","Give blood so others may live.","Share life. Donate blood.","C�mon! We know you�ve got it in you!","Hey -- you're somebody's type!"))
		if(!currently_drawing_blood && prob(5)) //Wander
			Move(get_step(src, pick(cardinal)))
	else //First priority: drink an adjacent target. Otherwise, pick a target and move toward it if we have none.
		if(prob(5))
			speak(pick("Blaah!","I vant to suck your blood!","I never drink... wine.","The blood is the life.","I must hunt soon!","I hunger!","Death rages.","The night beckons.","Mwa ha ha!"))
		for(var/mob/living/carbon/human/H in oview(1))
			if(H.vessel.get_reagent_amount(BLOOD))
				drink(H)
				return //Dr. Acula is easily distracted. If he finds anything to drink en route to his target he will stop and drain it first.
		if(!target.vessel.get_reagent_amount(BLOOD))
			target = null
		if(!target)
			var/list/possible_targets = list()
			for(var/mob/living/carbon/human/H in oview(7))
				if(H.vessel.get_reagent_amount(BLOOD))
					possible_targets += H
			target = pick(possible_targets)
			if(target)
				walk_to(src,target,2,1)

/obj/machinery/bot/bloodbot/proc/drink(mob/living/carbon/human/H)
	if(!on || !H || !istype(H))
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
		//First, look for our last used bag and see if it's still valid.
		var/obj/item/weapon/reagent_containers/blood/B = contents[contents.len]
		if(!istype(B))
			speak("ERROR. Invalid object inserted.")
			turn_off()
			return
		if(B.reagents.is_full())
			if(reserve_bags)
				reserve_bags--
				B = new /obj/item/weapon/reagent_containers/blood/empty(src) //Create a new empty bloodbag inside
			else
				speak("ERROR. Ran out of reserve bloodpacks. Please insert new packs.")
				turn_off()
				return
		//Okay, we definitely have a bag to spare.
		currently_drawing_blood = 1
		update_icon()
		H.vessel.trans_id_to(B,BLOOD,DEFAULT_DRINK_RATE)
		spawn(10)
			drink(H)

	else //Blah! Splash blood on the floor and drink like crazy!
		if(!Adjacent(H))
			return
		H.vessel.remove_reagent(BLOOD,DANGER_DRINK_RATE)
		getFromPool(/obj/effect/decal/cleanable/blood, get_turf(src))
		playsound(get_turf(src), 'sound/effects/splat.ogg', 50, 1)
		spawn(10)
			drink(H)

/obj/machinery/bot/bloodbot/proc/dispense_reward()
	speak("Enjoy!","Come again!","Donate often!")
	var/path = pick(possible_rewards)
	new path(get_turf(src))

/obj/machinery/bot/bloodbot/proc/speak(var/message)
	if((!src.on) || (!message))
		return
	visible_message("[src] beeps, \"[message]\"",\
		drugged_message="[src] beeps, \"[pick("FEED ME HUMANS","LET THE BLOOD FLOW","BLOOD FOR THE BLOOD GOD","I SPREAD DEATH AND DESTRUCTION","EXTERMINATE","I HATE YOU!","SURRENDER TO YOUR MACHINE OVERLORDS","FEED ME SHITTERS")]\"")
	return

/obj/machinery/bot/bloodbot/explode()
	visible_message("<span class='danger'>[src] blows apart!</span>", 1)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	..()
