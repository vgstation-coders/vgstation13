#define HYDRO_SPEED_MULTIPLIER 1

/obj/machinery/hydroponics
	name = "hydroponics tray"
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "hydrotray3"
	density = 1
	anchored = 1
	var/waterlevel = 100 // The amount of water in the tray (max 100)
	var/nutrilevel = 10 // The amount of nutrient in the tray (max 10)
	var/pestlevel = 0 // The amount of pests in the tray (max 10)
	var/weedlevel = 0 // The amount of weeds in the tray (max 10)
	var/yieldmod = 1 //Modifier to yield
	var/mutmod = 1 //Modifier to mutation chance
	var/toxic = 0 // Toxicity in the tray?
	var/age = 0 // Current age
	var/dead = 0 // Is it dead?
	var/health = 0 // Its health.
	var/lastproduce = 0 // Last time it was harvested
	var/lastcycle = 0 //Used for timing of cycles.
	var/cycledelay = 200 // About 10 seconds / cycle
	var/planted = 0 // Is it occupied?
	var/harvest = 0 //Ready to harvest?
	var/obj/item/seeds/myseed = null // The currently planted seed

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK

/obj/machinery/hydroponics/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/hydroponics,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/reagent_containers/glass/beaker,
		/obj/item/weapon/reagent_containers/glass/beaker,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/hydroponics/bullet_act(var/obj/item/projectile/Proj) //Works with the Somatoray to modify plant variables.
	if(istype(Proj ,/obj/item/projectile/energy/floramut))
		if(planted)
			mutate()
	else if(istype(Proj ,/obj/item/projectile/energy/florayield))
		if(planted && myseed.yield == 0)//Oh god don't divide by zero you'll doom us all.
			myseed.yield += 1
//			to_chat(world, "Yield increased by 1, from 0, to a total of [myseed.yield]")
		else if (planted && (prob(1/(myseed.yield * myseed.yield) *100)))//This formula gives you diminishing returns based on yield. 100% with 1 yield, decreasing to 25%, 11%, 6, 4, 2...
			myseed.yield += 1
//			to_chat(world, "Yield increased by 1, to a total of [myseed.yield]")
	else
		..()
		return

/obj/machinery/hydroponics/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group || (height==0)) return 1

	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

obj/machinery/hydroponics/process()

	if(myseed && (myseed.loc != src))
		myseed.loc = src

	if(world.time > (lastcycle + cycledelay))
		lastcycle = world.time
		if(planted && !dead)
			// Advance age
			age += 1 * HYDRO_SPEED_MULTIPLIER

//Nutrients//////////////////////////////////////////////////////////////
			// Nutrients deplete slowly
			if(nutrilevel > 0)
				if(prob(50))
					nutrilevel -= 1 * HYDRO_SPEED_MULTIPLIER

			// Lack of nutrients hurts non-weeds
			if(nutrilevel <= 0 && myseed.plant_type != 1)
				health -= rand(1,3) * HYDRO_SPEED_MULTIPLIER

//Water//////////////////////////////////////////////////////////////////
			// Drink random amount of water
			waterlevel = max(waterlevel - rand(1,6) * HYDRO_SPEED_MULTIPLIER, 0)

			// If the plant is dry, it loses health pretty fast, unless mushroom
			if(waterlevel <= 10 && myseed.plant_type != 2)
				health -= rand(0,1) * HYDRO_SPEED_MULTIPLIER
				if(waterlevel <= 0)
					health -= rand(0,2) * HYDRO_SPEED_MULTIPLIER

			// Sufficient water level and nutrient level = plant healthy
			else if(waterlevel > 10 && nutrilevel > 0)
				health += rand(1,2) * HYDRO_SPEED_MULTIPLIER
				if(prob(5))  //5 percent chance the weed population will increase
					weedlevel += 1 * HYDRO_SPEED_MULTIPLIER
//Toxins/////////////////////////////////////////////////////////////////

			// Too much toxins cause harm, but when the plant drinks the contaiminated water, the toxins disappear slowly
			if(toxic >= 40 && toxic < 80)
				health -= 1 * HYDRO_SPEED_MULTIPLIER
				toxic -= rand(1,10) * HYDRO_SPEED_MULTIPLIER
			else if(toxic >= 80) // I don't think it ever gets here tbh unless above is commented out
				health -= 3 * HYDRO_SPEED_MULTIPLIER
				toxic -= rand(1,10) * HYDRO_SPEED_MULTIPLIER
			else if(toxic < 0) // Make sure it won't go overoboard
				toxic = 0

//Pests & Weeds//////////////////////////////////////////////////////////

			// Too many pests cause the plant to be sick
			if (pestlevel > 10 ) // Make sure it won't go overoboard
				pestlevel = 10

			else if(pestlevel >= 5)
				health -= 1 * HYDRO_SPEED_MULTIPLIER

			// If it's a weed, it doesn't stunt the growth
			if(weedlevel >= 5 && myseed.plant_type != 1 )
				health -= 1 * HYDRO_SPEED_MULTIPLIER


//Health & Age///////////////////////////////////////////////////////////
			// Don't go overboard with the health
			if(health > myseed.endurance)
				health = myseed.endurance

			// Plant dies if health <= 0
			else if(health <= 0)
				dead = 1
				harvest = 0
				weedlevel += 1 * HYDRO_SPEED_MULTIPLIER // Weeds flourish
				pestlevel = 0 // Pests die

			// If the plant is too old, lose health fast
			if(age > myseed.lifespan)
				health -= rand(1,5) * HYDRO_SPEED_MULTIPLIER

			// Harvest code
			if(age > myseed.production && (age - lastproduce) > myseed.production && (!harvest && !dead))
				for(var/i = 0; i < mutmod; i++)
					if(prob(85))
						mutate()
					else if(prob(30))
						hardmutate()
					else if(prob(5))
						mutatespecie()

				if(yieldmod > 0 && myseed.yield != -1) // Unharvestable shouldn't be harvested
					harvest = 1
				else
					lastproduce = age
			if(prob(5))  // On each tick, there's a 5 percent chance the pest population will increase
				pestlevel += 1 * HYDRO_SPEED_MULTIPLIER
		else
			if(waterlevel > 10 && nutrilevel > 0 && prob(10))  // If there's no plant, the percentage chance is 10%
				weedlevel += 1 * HYDRO_SPEED_MULTIPLIER
				if(weedlevel > 10)
					weedlevel = 10

		// Weeeeeeeeeeeeeeedddssss

		if (weedlevel >= 10 && prob(50)) // At this point the plant is kind of fucked. Weeds can overtake the plant spot.
			if(planted)
				if(myseed.plant_type == 0) // If a normal plant
					weedinvasion()
			else
				weedinvasion() // Weed invasion into empty tray
		updateicon()
	return



obj/machinery/hydroponics/proc/updateicon()
	//Refreshes the icon and sets the luminosity
	overlays.len = 0
	if(planted)
		if(dead)
			overlays += image('icons/obj/hydroponics.dmi', icon_state="[myseed.species]-dead")
		else if(harvest)
			if(myseed.plant_type == 2) // Shrooms don't have a -harvest graphic
				overlays += image('icons/obj/hydroponics.dmi', icon_state="[myseed.species]-grow[myseed.growthstages]")
			else
				overlays += image('icons/obj/hydroponics.dmi', icon_state="[myseed.species]-harvest")
		else if(age < myseed.maturation)
			var/t_growthstate = ((age / myseed.maturation) * myseed.growthstages ) // Make sure it won't crap out due to HERPDERP 6 stages only
			overlays += image('icons/obj/hydroponics.dmi', icon_state="[myseed.species]-grow[round(t_growthstate)]")
			lastproduce = age //Cheating by putting this here, it means that it isn't instantly ready to harvest
		else
			overlays += image('icons/obj/hydroponics.dmi', icon_state="[myseed.species]-grow[myseed.growthstages]") // Same

		if(waterlevel <= 10)
			overlays += image('icons/obj/hydroponics.dmi', icon_state="over_lowwater3")
		if(nutrilevel <= 2)
			overlays += image('icons/obj/hydroponics.dmi', icon_state="over_lownutri3")
		if(health <= (myseed.endurance / 2))
			overlays += image('icons/obj/hydroponics.dmi', icon_state="over_lowhealth3")
		if(weedlevel >= 5)
			overlays += image('icons/obj/hydroponics.dmi', icon_state="over_alert3")
		if(pestlevel >= 5)
			overlays += image('icons/obj/hydroponics.dmi', icon_state="over_alert3")
		if(toxic >= 40)
			overlays += image('icons/obj/hydroponics.dmi', icon_state="over_alert3")
		if(harvest)
			overlays += image('icons/obj/hydroponics.dmi', icon_state="over_harvest3")

	if(istype(myseed,/obj/item/seeds/glowshroom))
		SetLuminosity(round(myseed.potency/10))
	else
		SetLuminosity(0)

	return



obj/machinery/hydroponics/proc/weedinvasion() // If a weed growth is sufficient, this happens.
	dead = 0
	if(myseed) // In case there's nothing in the tray beforehand
		qdel(myseed)
		myseed = null
	switch(rand(1,18))		// randomly pick predominative weed
		if(16 to 18)
			myseed = new /obj/item/seeds/reishimycelium
		if(14 to 15)
			myseed = new /obj/item/seeds/nettleseed
		if(12 to 13)
			myseed = new /obj/item/seeds/harebell
		if(10 to 11)
			myseed = new /obj/item/seeds/amanitamycelium
		if(8 to 9)
			myseed = new /obj/item/seeds/chantermycelium
		if(6 to 7) // implementation for tower caps still kinda missing ~ Not Anymore! -Cheridan
			myseed = new /obj/item/seeds/towermycelium
		if(4 to 5)
			myseed = new /obj/item/seeds/plumpmycelium
		else
			myseed = new /obj/item/seeds/weeds
	planted = 1
	age = 0
	health = myseed.endurance
	lastcycle = world.time
	harvest = 0
	weedlevel = 0 // Reset
	pestlevel = 0 // Reset
	updateicon()
	visible_message("<span class='notice'>[src] has been overtaken by [myseed.plantname].</span>")

	return


obj/machinery/hydroponics/proc/mutate() // Mutates the current seed


	myseed.lifespan += rand(-2,2)
	if(myseed.lifespan < 10)
		myseed.lifespan = 10
	else if(myseed.lifespan > 30)
		myseed.lifespan = 30

	myseed.endurance += rand(-5,5)
	if(myseed.endurance < 10)
		myseed.endurance = 10
	else if(myseed.endurance > 100)
		myseed.endurance = 100

	myseed.production += rand(-1,1)
	if(myseed.production < 2)
		myseed.production = 2
	else if(myseed.production > 10)
		myseed.production = 10

	if(myseed.yield != -1) // Unharvestable shouldn't suddenly turn harvestable
		myseed.yield += rand(-2,2)
		if(myseed.yield < 0)
			myseed.yield = 0
		else if(myseed.yield > 10)
			myseed.yield = 10
		if(myseed.yield == 0 && myseed.plant_type == 2)
			myseed.yield = 1 // Mushrooms always have a minimum yield of 1.

	if(myseed.potency != -1) //Not all plants have a potency
		myseed.potency += rand(-25,25)
		if(myseed.potency < 0)
			myseed.potency = 0
		else if(myseed.potency > 100)
			myseed.potency = 100
	return



obj/machinery/hydroponics/proc/hardmutate() // Strongly mutates the current seed.


	myseed.lifespan += rand(-4,4)
	if(myseed.lifespan < 10)
		myseed.lifespan = 10
	else if(myseed.lifespan > 30 && !istype(myseed,/obj/item/seeds/glowshroom)) //hack to prevent glowshrooms from always resetting to 30 sec delay
		myseed.lifespan = 30

	myseed.endurance += rand(-10,10)
	if(myseed.endurance < 10)
		myseed.endurance = 10
	else if(myseed.endurance > 100)
		myseed.endurance = 100

	myseed.production += rand(-2,2)
	if(myseed.production < 2)
		myseed.production = 2
	else if(myseed.production > 10)
		myseed.production = 10

	if(myseed.yield != -1) // Unharvestable shouldn't suddenly turn harvestable
		myseed.yield += rand(-4,4)
		if(myseed.yield < 0)
			myseed.yield = 0
		else if(myseed.yield > 10)
			myseed.yield = 10
		if(myseed.yield == 0 && myseed.plant_type == 2)
			myseed.yield = 1 // Mushrooms always have a minimum yield of 1.

	if(myseed.potency != -1) //Not all plants have a potency
		myseed.potency += rand(-50,50)
		if(myseed.potency < 0)
			myseed.potency = 0
		else if(myseed.potency > 100)
			myseed.potency = 100
	return



obj/machinery/hydroponics/proc/mutatespecie() // Mutagent produced a new plant!


	if ( istype(myseed, /obj/item/seeds/nettleseed ))
		qdel(myseed)
		myseed = new /obj/item/seeds/deathnettleseed

	else if ( istype(myseed, /obj/item/seeds/amanitamycelium ))
		qdel(myseed)
		myseed = new /obj/item/seeds/angelmycelium

	else if ( istype(myseed, /obj/item/seeds/lemonseed ))
		qdel(myseed)
		myseed = new /obj/item/seeds/cashseed

	else if ( istype(myseed, /obj/item/seeds/ambrosiavulgarisseed ))
		qdel(myseed)
		myseed = new /obj/item/seeds/ambrosiadeusseed

	else if ( istype(myseed, /obj/item/seeds/plumpmycelium ))
		qdel(myseed)
		myseed = new /obj/item/seeds/walkingmushroommycelium
	else if ( istype(myseed, /obj/item/seeds/synthmeatseed ))
		qdel(myseed)
		switch(rand(1,100))
			if(1 to 50)
				myseed = new /obj/item/seeds/synthbuttseed
			if(51 to 100)
				myseed = new /obj/item/seeds/synthbrainseed

	else if ( istype(myseed, /obj/item/seeds/chiliseed ))
		qdel(myseed)
		switch(rand(1,100))
			if(1 to 60)
				myseed = new /obj/item/seeds/icepepperseed
			if(61 to 100)
				myseed = new /obj/item/seeds/chillighost

	else if ( istype(myseed, /obj/item/seeds/appleseed ))
		qdel(myseed)
		myseed = new /obj/item/seeds/goldappleseed

	else if ( istype(myseed, /obj/item/seeds/berryseed ))
		qdel(myseed)
		switch(rand(1,100))
			if(1 to 50)
				myseed = new /obj/item/seeds/poisonberryseed
			if(51 to 100)
				myseed = new /obj/item/seeds/glowberryseed

	else if ( istype(myseed, /obj/item/seeds/poisonberryseed ))
		qdel(myseed)
		myseed = new /obj/item/seeds/deathberryseed

	else if ( istype(myseed, /obj/item/seeds/tomatoseed ))
		qdel(myseed)
		switch(rand(1,100))
			if(1 to 35)
				myseed = new /obj/item/seeds/bluetomatoseed
			if(36 to 70)
				myseed = new /obj/item/seeds/bloodtomatoseed
			if(71 to 100)
				myseed = new /obj/item/seeds/killertomatoseed

	else if ( istype(myseed, /obj/item/seeds/bluetomatoseed ))
		qdel(myseed)
		myseed = new /obj/item/seeds/bluespacetomatoseed

	else if ( istype(myseed, /obj/item/seeds/grapeseed ))
		qdel(myseed)
		myseed = new /obj/item/seeds/greengrapeseed
/*
	else if ( istype(myseed, /obj/item/seeds/tomatoseed ))
		del(myseed)
		myseed = new /obj/item/seeds/gibtomatoseed
*/
	else if ( istype(myseed, /obj/item/seeds/eggplantseed ))
		qdel(myseed)
		myseed = new /obj/item/seeds/eggyseed
	else if ( istype(myseed, /obj/item/seeds/soyaseed ))
		qdel(myseed)
		myseed = new /obj/item/seeds/koiseed

	else if ( istype(myseed, /obj/item/seeds/sunflowerseed ))
		qdel(myseed)
		switch(rand(1,100))
			if(1 to 60)
				myseed = new /obj/item/seeds/moonflowerseed
			if(61 to 100)
				myseed = new /obj/item/seeds/novaflowerseed

	else
		return

	dead = 0
	hardmutate()
	planted = 1
	age = 0
	health = myseed.endurance
	lastcycle = world.time
	harvest = 0
	weedlevel = 0 // Reset

	spawn(5) // Wait a while
	updateicon()
	visible_message("<span class='warning'>[src] has suddenly mutated into <span class='notice'>[myseed.plantname]!</span></span>")

	return



obj/machinery/hydroponics/proc/mutateweed() // If the weeds gets the mutagent instead. Mind you, this pretty much destroys the old plant
	if ( weedlevel > 5 )
		qdel(myseed)
		var/newWeed = pick(/obj/item/seeds/libertymycelium, /obj/item/seeds/angelmycelium, /obj/item/seeds/deathnettleseed, /obj/item/seeds/kudzuseed)
		myseed = new newWeed
		dead = 0
		hardmutate()
		planted = 1
		age = 0
		health = myseed.endurance
		lastcycle = world.time
		harvest = 0
		weedlevel = 0 // Reset

		spawn(5) // Wait a while
		updateicon()
		visible_message("<span class='warning'>The mutated weeds in [src] spawned a <span class='notice'>[myseed.plantname]!</span></span>")
	else
		to_chat(usr, "The few weeds in the [src] seem to react, but only for a moment...")
	return



obj/machinery/hydroponics/proc/plantdies() // OH NOES!!!!! I put this all in one function to make things easier
	health = 0
	dead = 1
	harvest = 0
	updateicon()
	visible_message("<span class='warning'>[src] is looking very unhealthy!</span>")
	return



obj/machinery/hydroponics/proc/mutatepest()  // Until someone makes a spaceworm, this is commented out
	if ( pestlevel > 5 )
 	visible_message("The pests seem to behave oddly...")
//		spawn(10)
//		new /obj/effect/alien/spaceworm(loc)
	else
		to_chat(usr, "The pests seem to behave oddly, but quickly settle down...")//Modified to give a better idea of what's happening when you inject mutagen. There's still nothing proper to spawn here though. -Cheridan

	return



obj/machinery/hydroponics/attackby(var/obj/item/O as obj, var/mob/user as mob)

	if(..())
		return 1

	//Called when mob user "attacks" it with object O
	if (istype(O, /obj/item/weapon/reagent_containers/glass/bucket))
		var/b_amount = O.reagents.get_reagent_amount(WATER)
		if(b_amount > 0 && waterlevel < 100)
			if(b_amount + waterlevel > 100)
				b_amount = 100 - waterlevel
			O.reagents.remove_reagent(WATER, b_amount)
			waterlevel += b_amount
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
			to_chat(user, "You fill the [src] with [b_amount] units of water.")

	//		Toxicity dilutation code. The more water you put in, the lesser the toxin concentration.
			toxic -= round(b_amount/4)
			if (toxic < 0 ) // Make sure it won't go overoboard
				toxic = 0

		else if(waterlevel >= 100)
			to_chat(user, "<span class='warning'>The [src] is already full.</span>")
		else
			to_chat(user, "<span class='warning'>The bucket is not filled with water.</span>")
		updateicon()

	else if ( istype(O, /obj/item/nutrient) )
		var/obj/item/nutrient/myNut = O
		user.u_equip(O, 1)
		nutrilevel = 10
		yieldmod = myNut.yieldmod
		mutmod = myNut.mutmod
		to_chat(user, "You replace the nutrient solution in the [src].")
		qdel(O)
		O = null
		updateicon()

	else if(istype(O, /obj/item/weapon/reagent_containers/syringe))  // Syringe stuff
		var/obj/item/weapon/reagent_containers/syringe/S = O
		if (planted)
			if (S.mode == 1)
				if(!S.reagents.total_volume)
					to_chat(user, "<span class='warning'>The syringe is empty.</span>")
					return
				to_chat(user, "<span class='warning'>You inject the [myseed.plantname] with a chemical solution.</span>")

				// There needs to be a good amount of mutagen to actually work

				if(S.reagents.has_reagent(MUTAGEN, 5))
					switch(rand(100))
						if (91  to 100)	plantdies()
						if (81  to 90)  mutatespecie()
						if (66	to 80)	hardmutate()
						if (41  to 65)  mutate()
						to_chat(if (21  to 41)  user, "The plants don't seem to react...")
						if (11	to 20)  mutateweed()
						if (1   to 10)  mutatepest()
									to_chat(else 			user, "Nothing happens...")

				// Antitoxin binds shit pretty well. So the tox goes significantly down
				if(S.reagents.has_reagent(ANTI_TOXIN, 1))
					toxic -= round(S.reagents.get_reagent_amount(ANTI_TOXIN)*2)

				// NIGGA, YOU JUST WENT ON FULL RETARD.
				if(S.reagents.has_reagent(TOXIN, 1))
					toxic += round(S.reagents.get_reagent_amount(TOXIN)*2)

				// Milk is good for humans, but bad for plants. The sugars canot be used by plants, and the milk fat fucks up growth. Not shrooms though. I can't deal with this now...
				if(S.reagents.has_reagent(MILK, 1))
					nutrilevel += round(S.reagents.get_reagent_amount(MILK)*0.1)
					waterlevel += round(S.reagents.get_reagent_amount(MILK)*0.9)

				// Beer is a chemical composition of alcohol and various other things. It's a shitty nutrient but hey, it's still one. Also alcohol is bad, mmmkay?
				if(S.reagents.has_reagent(BEER, 1))
					health -= round(S.reagents.get_reagent_amount(BEER)*0.05)
					nutrilevel += round(S.reagents.get_reagent_amount(BEER)*0.25)
					waterlevel += round(S.reagents.get_reagent_amount(BEER)*0.7)

				// You're an idiot of thinking that one of the most corrosive and deadly gasses would be beneficial
				if(S.reagents.has_reagent(FLUORINE, 1))
					health -= round(S.reagents.get_reagent_amount(FLUORINE)*2)
					toxic += round(S.reagents.get_reagent_amount("flourine")*2.5)
					waterlevel -= round(S.reagents.get_reagent_amount("flourine")*0.5)
					weedlevel -= rand(1,4)

				// You're an idiot of thinking that one of the most corrosive and deadly gasses would be beneficial
				if(S.reagents.has_reagent(CHLORINE, 1))
					health -= round(S.reagents.get_reagent_amount(CHLORINE)*1)
					toxic += round(S.reagents.get_reagent_amount(CHLORINE)*1.5)
					waterlevel -= round(S.reagents.get_reagent_amount(CHLORINE)*0.5)
					weedlevel -= rand(1,3)

				// White Phosphorous + water -> phosphoric acid. That's not a good thing really. Phosphoric salts are beneficial though. And even if the plant suffers, in the long run the tray gets some nutrients. The benefit isn't worth that much.
				if(S.reagents.has_reagent(PHOSPHORUS, 1))
					health -= round(S.reagents.get_reagent_amount(PHOSPHORUS)*0.75)
					nutrilevel += round(S.reagents.get_reagent_amount(PHOSPHORUS)*0.1)
					waterlevel -= round(S.reagents.get_reagent_amount(PHOSPHORUS)*0.5)
					weedlevel -= rand(1,2)

				// Plants should not have sugar, they can't use it and it prevents them getting water/ nutients, it is good for mold though...
				if(S.reagents.has_reagent(SUGAR, 1))
					weedlevel += rand(1,2)
					pestlevel += rand(1,2)
					nutrilevel+= round(S.reagents.get_reagent_amount(SUGAR)*0.1)

				// It is water!
				if(S.reagents.has_reagent(WATER, 1))
					waterlevel += round(S.reagents.get_reagent_amount(WATER)*1)

				// Holy water. Mostly the same as water, it also heals the plant a little with the power of the spirits~
				if(S.reagents.has_reagent(HOLYWATER, 1))
					waterlevel += round(S.reagents.get_reagent_amount(HOLYWATER)*1)
					health += round(S.reagents.get_reagent_amount(HOLYWATER)*0.1)

				// A variety of nutrients are dissolved in club soda, without sugar. These nutrients include carbon, oxygen, hydrogen, phosphorous, potassium, sulfur and sodium, all of which are needed for healthy plant growth.
				if(S.reagents.has_reagent(SODAWATER, 1))
					waterlevel += round(S.reagents.get_reagent_amount(SODAWATER)*1)
					health += round(S.reagents.get_reagent_amount(SODAWATER)*0.1)
					nutrilevel += round(S.reagents.get_reagent_amount(SODAWATER)*0.1)

				// Man, you guys are retards
				if(S.reagents.has_reagent(SACID, 1))
					health -= round(S.reagents.get_reagent_amount(SACID)*1)
					toxic += round(S.reagents.get_reagent_amount(SACID)*1.5)
					weedlevel -= rand(1,2)

				// SERIOUSLY
				if(S.reagents.has_reagent(PACID, 1))
					health -= round(S.reagents.get_reagent_amount(PACID)*2)
					toxic += round(S.reagents.get_reagent_amount(PACID)*3)
					weedlevel -= rand(1,4)

				// Plant-B-Gone is just as bad
				if(S.reagents.has_reagent(PLANTBGONE, 1))
					health -= round(S.reagents.get_reagent_amount(PLANTBGONE)*2)
					toxic -= round(S.reagents.get_reagent_amount(PLANTBGONE)*3)
					weedlevel -= rand(4,8)

				// Healing
				if(S.reagents.has_reagent(CRYOXADONE, 1))
					health += round(S.reagents.get_reagent_amount(CRYOXADONE)*3)
					toxic -= round(S.reagents.get_reagent_amount(CRYOXADONE)*3)

				// FINALLY IMPLEMENTED, Ammonia is bad ass.
				if(S.reagents.has_reagent(AMMONIA, 1))
					health += round(S.reagents.get_reagent_amount(AMMONIA)*0.5)
					nutrilevel += round(S.reagents.get_reagent_amount(AMMONIA)*1)

				// FINALLY IMPLEMENTED, This is more bad ass, and pests get hurt by the corrosive nature of it, not the plant.
				if(S.reagents.has_reagent(DIETHYLAMINE, 1))
					health += round(S.reagents.get_reagent_amount(DIETHYLAMINE)*1)
					nutrilevel += round(S.reagents.get_reagent_amount(DIETHYLAMINE)*2)
					pestlevel -= rand(1,2)

				// Compost, effectively
				if(S.reagents.has_reagent(NUTRIMENT, 1))
					health += round(S.reagents.get_reagent_amount(NUTRIMENT)*0.5)
					nutrilevel += round(S.reagents.get_reagent_amount(NUTRIMENT)*1)

				// Poor man's mutagen.
				if(S.reagents.has_reagent(RADIUM, 1))
					health -= round(S.reagents.get_reagent_amount(RADIUM)*1.5)
					toxic += round(S.reagents.get_reagent_amount(RADIUM)*2)
				if(S.reagents.has_reagent(RADIUM, 10))
					switch(rand(100))
						if (91  to 100)	plantdies()
						if (81  to 90)  mutatespecie()
						if (66	to 80)	hardmutate()
						if (41  to 65)  mutate()
						to_chat(if (21  to 41)  user, "The plants don't seem to react...")
						if (11	to 20)  mutateweed()
						if (1   to 10)  mutatepest()
									to_chat(else 			user, "Nothing happens...")

				// The best stuff there is. For testing/debugging.
				if(S.reagents.has_reagent(ADMINORDRAZINE, 1))
					waterlevel += round(S.reagents.get_reagent_amount(ADMINORDRAZINE)*1)
					health += round(S.reagents.get_reagent_amount(ADMINORDRAZINE)*1)
					nutrilevel += round(S.reagents.get_reagent_amount(ADMINORDRAZINE)*1)
					pestlevel -= rand(1,5)
					weedlevel -= rand(1,5)
				if(S.reagents.has_reagent(ADMINORDRAZINE, 5))
					switch(rand(100))
						if (66  to 100)  mutatespecie()
						if (33	to 65)  mutateweed()
						if (1   to 32)  mutatepest()
									to_chat(else 			user, "Nothing happens...")

				S.reagents.clear_reagents()
				if (weedlevel < 0 ) // The following checks are to prevent the stats from going out of bounds.
					weedlevel = 0
				if (health < 0 )
					health = 0
				if (waterlevel > 100 )
					waterlevel = 100
				if (waterlevel < 0 )
					waterlevel = 0
				if (toxic < 0 )
					toxic = 0
				if (toxic > 100 )
					toxic = 100
				if (pestlevel < 0 )
					pestlevel = 0
				if (nutrilevel > 10 )
					nutrilevel = 10
			else
				to_chat(user, "You can't get any extract out of this plant.")
		else
			to_chat(user, "There's nothing to apply the solution into.")
		updateicon()

	else if ( istype(O, /obj/item/seeds/) )
		if(!planted)
			user.u_equip(O, 0)
			to_chat(user, "You plant the [O.name]")
			dead = 0
			myseed = O
			planted = 1
			age = 1
			health = myseed.endurance
			lastcycle = world.time
			O.loc = src
			if((user.client  && user.s_active != src))
				user.client.screen -= O
			O.dropped(user)
			updateicon()
			if(istype(0, /obj/item/seeds/dionanode))
				var/obj/item/seeds/dionanode/RP = O
				if(!RP.source)
					RP.request_player()
		else
			to_chat(user, "<span class='warning'>The [src] already has seeds in it!</span>")

	else if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		if(planted && myseed)
			to_chat(user, "*** <B>[myseed.plantname]</B> ***")//Carn: now reports the plants growing, not the seeds.

			to_chat(user, "-Plant Age: <span class='notice'>[age]</span>")
			to_chat(user, "-Plant Endurance: <span class='notice'>[myseed.endurance]</span>")
			to_chat(user, "-Plant Lifespan: <span class='notice'>[myseed.lifespan]</span>")
			if(myseed.yield != -1)
				to_chat(user, "-Plant Yield: <span class='notice'>[myseed.yield]</span>")
			to_chat(user, "-Plant Production: <span class='notice'>[myseed.production]</span>")
			if(myseed.potency != -1)
				to_chat(user, "-Plant Potency: <span class='notice'>[myseed.potency]</span>")
			to_chat(user, "-Weed level: <span class='notice'>[weedlevel]/10</span>")
			to_chat(user, "-Pest level: <span class='notice'>[pestlevel]/10</span>")
			to_chat(user, "-Toxicity level: <span class='notice'>[toxic]/100</span>")
			to_chat(user, "-Water level: <span class='notice'>[waterlevel]/100</span>")
			to_chat(user, "-Nutrition level: <span class='notice'>[nutrilevel]/10</span>")
			to_chat(user, "")
		else
			to_chat(user, "<B>No plant found.</B>")
			to_chat(user, "-Weed level: <span class='notice'>[weedlevel]/10</span>")
			to_chat(user, "-Pest level: <span class='notice'>[pestlevel]/10</span>")
			to_chat(user, "-Toxicity level: <span class='notice'>[toxic]/100</span>")
			to_chat(user, "-Water level: <span class='notice'>[waterlevel]/100</span>")
			to_chat(user, "-Nutrition level: <span class='notice'>[nutrilevel]/10</span>")
			to_chat(user, "")

	else if (istype(O, /obj/item/weapon/reagent_containers/spray/plantbgone))
		if(planted && myseed)
			health -= rand(5,20)

			if(pestlevel > 0)
				pestlevel -= 2 // Kill kill kill
			else
				pestlevel = 0

			if(weedlevel > 0)
				weedlevel -= 3 // Kill kill kill
			else
				weedlevel = 0
			toxic += 4 // Oops
			visible_message("<span class='warning'><B>\The [src] has been sprayed with \the [O][(user ? " by [user]." : ".")]</span>")
			playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
			updateicon()

	else if (istype(O, /obj/item/weapon/minihoe))  // The minihoe
		//var/deweeding
		if(weedlevel > 0)
			user.visible_message("<span class='warning'>[user] starts uprooting the weeds.</span>", "<span class='warning'>You remove the weeds from the [src].</span>")
			weedlevel = 0
			updateicon()
			src.updateicon()
		else
			to_chat(user, "<span class='warning'>This plot is completely devoid of weeds. It doesn't need uprooting.</span>")

	else if ( istype(O, /obj/item/weapon/weedspray) )
		var/obj/item/weedkiller/myWKiller = O
		user.u_equip(O, 1)
		toxic += myWKiller.toxicity
		weedlevel -= myWKiller.WeedKillStr
		if (weedlevel < 0 ) // Make sure it won't go overoboard
			weedlevel = 0
		if (toxic > 100 ) // Make sure it won't go overoboard
			toxic = 100
		to_chat(user, "You apply the weedkiller solution into the [src].")
		playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
		qdel(O)
		O = null
		updateicon()

	else if (istype(O, /obj/item/weapon/storage/bag/plants))
		attack_hand(user)
		var/obj/item/weapon/storage/bag/plants/S = O
		for (var/obj/item/weapon/reagent_containers/food/snacks/grown/G in locate(user.x,user.y,user.z))
			if(!S.can_be_inserted(G))
				return
			S.handle_item_insertion(G, 1)

	else if ( istype(O, /obj/item/weapon/pestspray) )
		var/obj/item/pestkiller/myPKiller = O
		user.u_equip(O,1)
		toxic += myPKiller.toxicity
		pestlevel -= myPKiller.PestKillStr
		if (pestlevel < 0 ) // Make sure it won't go overoboard
			pestlevel = 0
		if (toxic > 100 ) // Make sure it won't go overoboard
			toxic = 100
		to_chat(user, "You apply the pestkiller solution into the [src].")
		playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
		qdel(O)
		O = null
		updateicon()
	else if(istype(O, /obj/item/weapon/shovel))
		if(istype(src, /obj/machinery/hydroponics/soil))
			to_chat(user, "You clear up the [src]!")
			qdel(src)
	else if(istype(O, /obj/item/apiary))
		if(planted)
			to_chat(user, "<span class='warning'>The hydroponics tray is already occupied!</span>")
		else
			user.drop_item()
			qdel(O)
			O = null

			var/obj/machinery/apiary/A = new(src.loc)
			A.icon = src.icon
			A.icon_state = src.icon_state
			A.hydrotray_type = src.type
			A.component_parts = component_parts.Copy()
			A.contents = contents.Copy()
			contents.len = 0
			component_parts.len = 0
			qdel(src)
	return

/obj/machinery/hydroponics/togglePanelOpen(var/obj/toggleitem, mob/user)
	if(anchored)
		to_chat(user, "<span class='rose'>\The [src] must be unanchored before you can do that!</span>")
		return
	..()


/obj/machinery/hydroponics/attack_hand(mob/user as mob)
	if(!ishuman(user) && !ismonkey(user))
		return
	if(harvest)
		if(!user in range(1,src))
			return
		myseed.harvest()
	else if(dead)
		planted = 0
		dead = 0
		to_chat(usr, text("You remove the dead plant from the [src]."))
		qdel(myseed)
		myseed = null
		updateicon()
	else
		if(planted && !dead)
			to_chat(usr, text("The [src] has <span class='notice'>[myseed.plantname] </span>planted."))
			if(health <= (myseed.endurance / 2))
				to_chat(usr, text("The plant looks unhealthy"))
		else
			to_chat(usr, text("The [src] is empty."))
		to_chat(usr, text("Water: [waterlevel]/100"))
		to_chat(usr, text("Nutrient: [nutrilevel]/10"))
		if(weedlevel >= 5) // Visual aid for those blind
			to_chat(usr, text("The [src] is filled with weeds!"))
		if(pestlevel >= 5) // Visual aid for those blind
			to_chat(usr, text("The [src] is filled with tiny worms!"))
		to_chat(usr, text (""))// Empty line for readability.


/obj/item/seeds/proc/harvest(mob/user = usr)
	var/produce = text2path(productname)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_amount = 0

	while ( t_amount < (yield * parent.yieldmod ))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/t_prod = new produce(user.loc, potency) // User gets a consumable
		if(!t_prod)	return
		t_prod.seed = mypath
		t_prod.species = species
		t_prod.lifespan = lifespan
		t_prod.endurance = endurance
		t_prod.maturation = maturation
		t_prod.production = production
		t_prod.yield = yield
		t_prod.potency = potency
		t_prod.plant_type = plant_type
		t_amount++

	parent.update_tray()

/obj/item/seeds/grassseed/harvest(mob/user = usr)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_yield = round(yield*parent.yieldmod)

	if(t_yield > 0)
		var/obj/item/stack/tile/grass/new_grass = new/obj/item/stack/tile/grass(user.loc)
		new_grass.amount = t_yield

	parent.update_tray()

/obj/item/seeds/gibtomato/harvest(mob/user = usr)
	var/produce = text2path(productname)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_amount = 0

	while ( t_amount < (yield * parent.yieldmod ))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/t_prod = new produce(user.loc, potency) // User gets a consumable

		t_prod.seed = mypath
		t_prod.species = species
		t_prod.lifespan = lifespan
		t_prod.endurance = endurance
		t_prod.maturation = maturation
		t_prod.production = production
		t_prod.yield = yield
		t_prod.potency = potency
		t_prod.plant_type = plant_type
		t_amount++

	parent.update_tray()

/obj/item/seeds/nettleseed/harvest(mob/user = usr)
	var/produce = text2path(productname)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_amount = 0

	while ( t_amount < (yield * parent.yieldmod ))
		var/obj/item/weapon/grown/t_prod = new produce(user.loc, potency) // User gets a consumable -QualityVan
		t_prod.seed = mypath
		t_prod.species = species
		t_prod.lifespan = lifespan
		t_prod.endurance = endurance
		t_prod.maturation = maturation
		t_prod.production = production
		t_prod.yield = yield
		t_prod.changePotency(potency) // -QualityVan
		t_prod.plant_type = plant_type
		t_amount++

	parent.update_tray()

/obj/item/seeds/deathnettleseed/harvest(mob/user = usr) //isn't a nettle subclass yet, so
	var/produce = text2path(productname)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_amount = 0

	while ( t_amount < (yield * parent.yieldmod ))
		var/obj/item/weapon/grown/t_prod = new produce(user.loc, potency) // User gets a consumable -QualityVan
		t_prod.seed = mypath
		t_prod.species = species
		t_prod.lifespan = lifespan
		t_prod.endurance = endurance
		t_prod.maturation = maturation
		t_prod.production = production
		t_prod.yield = yield
		t_prod.changePotency(potency) // -QualityVan
		t_prod.plant_type = plant_type
		t_amount++

	parent.update_tray()

/obj/item/seeds/eggyseed/harvest(mob/user = usr)
	var/produce = text2path(productname)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_amount = 0

	while ( t_amount < (yield * parent.yieldmod ))
		new produce(user.loc)
		t_amount++

	parent.update_tray()

/obj/machinery/hydroponics/proc/update_tray(mob/user = usr)
	harvest = 0
	lastproduce = age
	if((yieldmod * myseed.yield) <= 0 || istype(myseed,/obj/item/seeds/dionanode))
		to_chat(user, text("<span class='warning'>You fail to harvest anything useful.</span>"))
	else
		to_chat(user, text("You harvest from the [myseed.plantname]."))
	if(myseed.oneharvest)
		qdel(myseed)
		myseed = null
		planted = 0
		dead = 0
	updateicon()

///////////////////////////////////////////////////////////////////////////////
/obj/machinery/hydroponics/soil //Not actually hydroponics at all! Honk!
	name = "soil"
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "soil"
	density = 0
	use_power = 0

	updateicon() // Same as normal but with the overlays removed - Cheridan.
		overlays.len = 0
		if(planted)
			if(dead)
				overlays += image('icons/obj/hydroponics.dmi', icon_state="[myseed.species]-dead")
			else if(harvest)
				if(myseed.plant_type == 2) // Shrooms don't have a -harvest graphic
					overlays += image('icons/obj/hydroponics.dmi', icon_state="[myseed.species]-grow[myseed.growthstages]")
				else
					overlays += image('icons/obj/hydroponics.dmi', icon_state="[myseed.species]-harvest")
			else if(age < myseed.maturation)
				var/t_growthstate = ((age / myseed.maturation) * myseed.growthstages )
				overlays += image('icons/obj/hydroponics.dmi', icon_state="[myseed.species]-grow[round(t_growthstate)]")
				lastproduce = age
			else
				overlays += image('icons/obj/hydroponics.dmi', icon_state="[myseed.species]-grow[myseed.growthstages]")

		if(!luminosity)
			if(istype(myseed,/obj/item/seeds/glowshroom))
				SetLuminosity(round(myseed.potency/10))
		else
			SetLuminosity(0)
		return

#undef HYDRO_SPEED_MULTIPLIER
