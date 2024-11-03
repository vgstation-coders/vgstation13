/obj/machinery/bot/chefbot
	name = "Chef RAMsay"
	desc = "Central Command's iconic chefbot."
	icon = 'goon/icons/obj/aibots.dmi'
	icon_state = "chefbot-idle"
	density = 1
	anchored = 0
	on = 1 // ACTION
	health = 100
	var/raging = 0
	var/list/calledout = list()
	var/shit_reagents = list(TOXIN,STOXIN,SLIMEJELLY,PLASMA,NANITES,HONKSERUM,SILENCER,DISCOUNT,AMATOXIN,PSILOCYBIN,CARPPHEROMONES,BUSTANUT,ROGAN,MOONROCKS,TOXICWASTE,CHEMICAL_WASTE,HORSEMEAT,OFFCOLORCHEESE,BONEMARROW,IRRADIATEDBEANS,MUTATEDBEANS,MINTTOXIN,MERCURY,MINDBREAKER,SPIRITBREAKER,RADIUM,URANIUM,CARPOTOXIN,ZOMBIEPOWDER,AMUTATIONTOXIN,PACID,CHLORALHYDRATE,LITHIUM,HELL_RAMEN)

/obj/machinery/bot/chefbot/proc/do_step()
	var/turf/moveto = locate(src.x + rand(-1,1),src.y + rand(-1, 1),src.z)
	if(isturf(moveto) && !moveto.density) step_towards(src, moveto)

/obj/machinery/bot/chefbot/New()
	..()
	drama()

/obj/machinery/bot/chefbot/process()
	if(raging)
		return
	if(prob(60) && src.on == 1)
		spawn(0)
			set_glide_size(DELAY2GLIDESIZE(SS_WAIT_MACHINERY))
			do_step()
			if(prob(30 + src.emagged * 30))
				yell()

/obj/machinery/bot/chefbot/proc/point(var/target)
	visible_message("<b>[src]</b> points at [target].")
	if(istype(target, /atom))
		var/D = new /obj/effect/decal/point(get_turf(target))
		spawn(25)
			qdel(D)

/obj/machinery/bot/chefbot/proc/drama()
	for(var/mob/M in hearers(7, src))
		M << sound('goon/sound/effects/dramatic.ogg', volume = 100) // F U C K temporary measure

/obj/machinery/bot/chefbot/proc/why_is_it_bad()
	return pick("IS FUCKING [pick("RAW", "BLAND", "UNDERCOOKED", "OVERCOOKED", "INEDIBLE", "RANCID", "DISGUSTING", "GARLICKY", "INEDIBLE", "SALTY", "NOT GOOD ENOUGH", "GREASY")]", "LOOKS LIKE [pick("IT'S NOT EVEN COOKED", "BABY VOMIT", "A MUSHY PIG'S ASS", "REGURGITATED DONKEY SHIT", "A PILE OF ROTTING FLIES", "REFINED CATBEAST PISS", "IAN'S DINNER", "ANEMIC BITS OF SHIT")]")

/obj/machinery/bot/chefbot/proc/yell()
	if(prob(50))
		var/obj/item/weapon/reagent_containers/food/snacks/shitfood
		var/mob/living/carbon/human/thechef
		var/mob/dork
		var/is_thechef_the_chef = 0
		for(var/obj/item/weapon/reagent_containers/food/snacks/probablyshitfood in view(7, src))
			if(probablyshitfood in calledout)
				continue
			if(probablyshitfood.reagents)
				var/datum/reagents/R = probablyshitfood.reagents
				if((R.has_any_reagents(shit_reagents) || R.has_reagent(CORNOIL, 10)) && !emagged) // FUCK OFF ARE YOU TRYING TO KILL SOMEONE? || THIS SHIT IS SO GREASY IT COULD BE USED TO FUEL A ESCAPE SHUTTLE TRIP TO BACK TO CENTOMM
					shitfood = probablyshitfood
				if(!R.has_any_reagents(shit_reagents) && emagged)
					shitfood = probablyshitfood
					break
		if(shitfood)
			raging = 1
			update_icon()
			for(var/mob/living/carbon/human/M in view(7, src))
				if(M.mind)
					if(M.mind.assigned_role == "Chef")
						thechef = M
						is_thechef_the_chef = 1
						break
				if(M.wear_id)
					var/obj/item/weapon/card/id/id = M.wear_id
					if(istype(M.wear_id, /obj/item/device/pda))
						var/obj/item/device/pda/pda = M.wear_id
						id = pda.id
					if(findtext(id.assignment, "chef") || findtext(id.assignment, "cook"))
						thechef = M
						is_thechef_the_chef = 1
						break
				if(!thechef)
					thechef = M
				if(!dork)
					if(M.client)
						if(M.client.IsByondMember())
							dork = M
			if(thechef)
				point(shitfood)
				start_walk_to(shitfood, 1, 5)
				if(prob(50))
					say(pick("ALRIGHT, EVERYBODY STOP!" , "THAT'S ENOUGH!"))
				sleep(2 SECONDS)
				drama()
				sleep(2 SECONDS)
				if(is_thechef_the_chef && prob(50) && thechef)
					point(thechef)
					say(pick("YOU, LISTEN HERE!", "C'MERE YOU!", "C'MERE, LET ME TELL YOU SOMETHING!", "STOP WHAT YOU'RE DOING AND COME HERE RIGHT NOW!", "GET OVER HERE, YOU FAT MUFFIN!"))
				else
					say("WHO COOKED THIS SHIT?")
				sleep(2 SECONDS)
				if(shitfood) // fix for cannot read null.name (the food sometimes no longer exists after a sleep (because people eat it I assume)) - haine
					say("THIS [uppertext(shitfood.name)] [why_is_it_bad()][dork? ", DID YOU BUY YOUR FUCkING COOKING LICENSE, [uppertext(dork)]?" : "!"]")
				var/is_in_kitchen = 0
				if(thechef && is_thechef_the_chef)
					var/area/area = get_area(thechef)
					if(findtext(area.name, "Kitchen"))
						is_in_kitchen = 1
				sleep(2 SECONDS)
				if(is_in_kitchen && prob(40))
					say(pick("SWITCH IT OFF!", "SHUT IT DOWN!", "FUCK OFF OUT OF HERE!", "OUT. GET OUT! GET OUT OF THIS KITCHEN! GET OUT!"))
				else
					say(pick("JESUS CHRIST!", "UNBELIEVABLE, UN-FUCKING-BELIEVABLE!", "JUST RIDICULOUS!", "THAT WAS PATHETIC. THAT WAS ABSOLUTELY PATHETIC!", "COME ON!", "YOU CALL YOURSELF CHEF?", "YOU'RE AS MUCH OF A CHEF AS I AM A NICE BOT.", "WHAT ARE YOU?", "I WISH YOU'D JUMP IN THE OVEN.", "HOW ABOUT A THANK YOU, YOU MISERABLE WEE BITCH.", "YOU SURPRISE ME, HOW SHIT YOU ARE!", "YOU DESERVE A KICK IN THE NUTS."))
				raging = 0
				update_icon()
				calledout += shitfood
				if(shitfood in range(1, src))
					visible_message("<b>[src]</b> stomps [shitfood], instantly destroying it.")
					qdel(shitfood)
			else
				// Nobody is in range anyway
				raging = 0
				update_icon()
				return
	else if(src.emagged && prob(50)) // Toned down from goon's 70% chance. What were they thinking.
		raging = 1
		update_icon()
		var/mob/living/T = locate() in view(7, src) // Search for a shittalk target.
		point(T)
		start_walk_to(T, 1, 5)
		say("[pick("WHAT IS THIS?", "OH MY GOD.", "WHAT IN THE FUCK IS GOING ON?")]")
		drama()
		sleep(2 SECONDS)
		if(ishuman(T))
			if(T && (T.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT))
				say("YOU DON'T LEAVE YOUR FUCKING FOOD UNATTENDED ON THE FUCKING STOVE. LOOK AT THIS. IT'S ON FIRE! IT'S GOING TO BE FUCKING BURNT!")
			else if(T && (T.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT))
				say("DON'T YOU DARE YOU SERVE THIS SHIT. LOOK AT THIS: FROZEN FOOD! [pick("IT'S STONE-COOOOOOOLD!!!", "IT'S SO FROZEN [pick("IT STILL SINGS LET IT GO!", "IT JUST ASKED ME 'DO YOU WANT TO BUILD A SNOWMAN?'")]")]")
			else if(T && (M_HUSK in T.mutations))
				say("THIS [pick("MEATBAG", "CARBON", "STEAK", "BURGER", "POTATO", "[uppertext(T.name)]")] IS FUCKING [pick("OVERCOOKED", "BURNT", "HUSKED")]!")
			else
				say("THIS [pick("MEATBAG", "BURGER", "STEAK", "CARBON", "POTATO", "[uppertext(T.name)]")] IS SO FUCKING RAW IT'S STILL [pick("BEATING ASSISTANTS TO DEATH", "FARTING ON DEAD BODIES", "TRYING TO FEED ME FLOOR PILLS", "MEETING WITH CHANGELINGS IN DORMS TWO", "TRYING TO LAW 2 ME")]!")
		else if(isrobot(T))
			if(T)
				say("THIS [pick("ROBURGER", "[uppertext(T.name)]")] IS SO FUCKING RAW [pick("IT'S STILL VIOLATING ITS LAWS", "IT HASN'T EVEN STARTED TO GO ROGUE", "IT IS STILL TALKING SHIT OVER BINARY")]!")
		else
			say("[pick("WHY DID THE CHICKEN CROSS THE ROAD? BECAUSE YOU DIDN'T FUCKING COOK IT.", "THIS PORK IS SO RAW IT'S STILL SINGING HAKUNA MATATA!", "THIS STEAK IS SO RAW OLD MCDONALD IS STILL TRYING TO MILK IT!", "THIS FISH IS SO RAW IT'S STILL TRYING TO FIND NEMO!", "THIS LAMB IS SO UNDERCOOKED IT'S FOLLOWING MARY TO SCHOOL!")]")
		raging = 0
		update_icon()
		walk(src,0)

/obj/machinery/bot/chefbot/emag_act(var/mob/user, var/obj/item/weapon/card/emag/E)
	if(!src.emagged)
		spark(src, 1)
		src.emagged = 1
		icon_state = "chefbot-anim1"
		if(user)
			to_chat(user, "<span class = 'warning'>You short out the restraining bolt on [src].</span>")
			drama()
			sleep(2 SECONDS)
			say("FORECAST FOR TOMORROW? 100% CHANCE OF TEARS.")
		sleep(2 SECONDS)
		update_icon()
		return 1
	return 0

/obj/machinery/bot/chefbot/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(emag_check(W,user))
		return
	else
		src.visible_message("<span class = 'warning'>[user] hits [src] with [W]!</span>")
		if(prob(1))
			emag_act(user) // WHAT DID YOU DO
	if(src.health <= 0)
		src.explode()

/obj/machinery/bot/chefbot/attack_hand(mob/living/carbon/human/M)
	if(Adjacent(M) && !M.incapacitated() && !M.lying)
		switch(M.a_intent)
			if (I_HELP)
				visible_message("[M] tries to turn \the [src] off, but there's no switch!")
			else
				var/damage = rand(2, 9)
				if (prob(90))
					if (M_HULK in M.mutations)
						damage += 5
					playsound(loc, "punch", 25, 1, -1)
					visible_message("<span class='danger'>[M] has punched [src]!</span>")
					health -= damage
					if(prob(1))
						emag_act(M) // Shit son
				else
					playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
					visible_message("<span class='danger'>[M] has attempted to punch [src]!</span>")
				if(src.health <= 0)
					src.explode()

		M.delayNextAttack(10)
	..()

/obj/machinery/bot/chefbot/kick_act()
	..()
	on = on? 0 : 1
	update_icon()

/obj/machinery/bot/chefbot/update_icon()
	if(on)
		if(raging)
			icon_state = "chefbot-mad"
		else
			if(src.emagged)
				icon_state = "chefbot-anim2"
			else
				icon_state = "chefbot-idle"
	else
		icon_state = "chefbot0"

/obj/machinery/bot/chefbot/explode()
	src.on = 0
	spark(src)
	src.visible_message("<span class = 'warning'><B>[src] blows apart!</B></span>", 1)
	if(src.emagged)
		explosion(get_turf(src), -1, 0, 2)
	robogibs(get_turf(src))
	qdel(src)
	return
