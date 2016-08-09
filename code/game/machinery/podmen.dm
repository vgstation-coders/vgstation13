/* Moved all the plant people code here for ease of reference and coherency.
Injecting a pod person with a blood sample will grow a pod person with the memories and persona of that mob.
Growing it to term with nothing injected will grab a ghost from the observers. */
#define DIONA_COOLDOWN 18000 // 30 minutes between being diona
var/global/list/hasbeendiona = list() // Stores ckeys and a timestamp for ghost dionas to be picked again, removes the same guy being diona 5 times in 10 minutes.
/*/obj/item/seeds/replicapod
	name = "pack of dionaea-replicant seeds"
	desc = "These seeds grow into 'replica pods' or 'dionaea', a form of strange sapient plantlife."
	icon_state = "seed-replicapod"
	mypath = "/obj/item/seeds/replicapod"
	species = "replicapod"
	plantname = "Dionaea"
	productname = "/mob/living/carbon/human" //verrry special -- Urist
	lifespan = 50 //no idea what those do
	endurance = 8
	maturation = 5
	production = 10
	yield = 1 //seeds if there isn't a dna inside
	oneharvest = 1
	potency = 30
	plant_type = 0
	growthstages = 6
	var/ckey = null
	var/realName = null
	var/mob/living/carbon/human/source //Donor of blood, if any.
	setGender(MALE)
	var/obj/machinery/hydroponics/parent = null
	var/list/found_player = list()
	var/beingharvested = 0*/

/obj/item/seeds/replicapod/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(istype(W,/obj/item/weapon/reagent_containers))

		to_chat(user, "You inject the contents of the syringe into the seeds.")

		var/datum/reagent/blood/B

		//Find a blood sample to inject.
		for(var/datum/reagent/R in W:reagents.reagent_list)
			if(istype(R,/datum/reagent/blood))
				B = R
				break
		if(B)
			source = B.data["donor"]
			to_chat(user, "The strange, sluglike seeds quiver gently and swell with blood.")
			if(!source.client && source.mind)
				var/mob/dead/observer/O = get_ghost_from_mind(source.mind)
				if(O && O.client && config.revival_pod_plants)
					to_chat(O, "<span class='interface'><b><font size = 3>Your blood has been placed into a replica pod seed. Return to your body if you want to be returned to life as a pod person!</b> \)
						(Verbs -> Ghost -> Re-enter corpse, or <a href='?src=\ref[O];reentercorpse=1'>click here!</a>)</font></span>"
					break
		else
			to_chat(user, "Nothing happens.")
			return

		if (!istype(source))
			return

		if(source.ckey)
			realName = source.real_name
			ckey = source.ckey

		W:reagents.clear_reagents()
		return

	return ..()

/obj/item/seeds/replicapod/harvest(mob/user = usr)

	parent = loc
	found_player.len = 0


	if(beingharvested)
		to_chat(user, ("<span class='warning'>You can only harvest the pod once!</span>"))
	else
		user.visible_message("<span class='notice'>[user] carefully begins to open the pod...</span>","<span class='notice'>You carefully begin to open the pod...</span>")
		beingharvested = 1

	//If a sample is injected (and revival is allowed) the plant will be controlled by the original donor.
	if(source && source.stat == 2 && source.client && source.ckey && config.revival_pod_plants)
		if(!transfer_personality(source.client))
			harvest_failure(user)
		return
	//This is fucking dumb but i was butthurt for removing it outright
	else // If no sample was injected or revival is not allowed, we grab an interested observer.
		var/delay = 300
		if(!found_player || !found_player.len)
			request_player()
		else
			delay = 0
		spawn(delay) //If we don't have a ghost or the ghost is now unplayed, we just give the harvester some seeds.
			if(!found_player.len)
				harvest_failure(user)
				return
			else
				shuffle(found_player)
				var/client/C = pick(found_player)
				if(!transfer_personality(C, 1))
					harvest_failure(user)


/obj/item/seeds/replicapod/proc/harvest_failure(mob/user)
	parent.visible_message("The pod has formed badly, and all you can do is salvage some of the seeds.")
	var/seed_count = 1
	if(prob(yield * parent.yieldmod * 20))
		seed_count++
	for(var/i=0,i<seed_count,i++)
		new /obj/item/seeds/replicapod(user.loc)

	parent.update_tray()

/obj/item/seeds/replicapod/proc/request_player()
	for(var/mob/dead/observer/observer in dead_mob_list)
		if(jobban_isbanned(observer, "Dionaea"))
			continue

		if(observer.key)
			if(!isnull(hasbeendiona[observer.key]))
				if((world.time + DIONA_COOLDOWN) < hasbeendiona[observer.key])
					continue

		if(observer.client && observer.client.prefs && observer.client.prefs.be_special & BE_PLANT)
			spawn()
				switch(observer.timed_alert( \
						300, \
						"Someone is harvesting a replica pod. Would you like to play as a Dionaea? (Please answer within 30 seconds)", \
						"Replica pod harvest", \
						"Yes", \
						"No", \
						"Never for this round" \
					))
					if("Yes")
						if(!(observer.client in found_player))
							found_player.Add(observer.client)
					if("Never for this round")
						observer.client.prefs.be_special &= ~BE_PLANT

/obj/item/seeds/replicapod/proc/transfer_personality(var/client/player, var/ghost = 0)


	if(!player) return 0
	if(ghost) hasbeendiona[player.key] = world.time
	//found_player = 1

	var/mob/living/carbon/monkey/diona/podman = new(parent.loc)
	podman.ckey = player.ckey

	if(player.mob && player.mob.mind)
		player.mob.mind.transfer_to(podman)

	if(realName)
		podman.real_name = realName
	else
		podman.real_name = "diona nymph ([rand(100,999)])"

	podman.dna.real_name = podman.real_name

	// Update mode specific HUD icons.
	// Dionas are a brand new being if they came from a ghost.
	if(!ghost)
		switch(ticker.mode.name)
			if ("revolution")
				if (podman.mind in ticker.mode:revolutionaries)
					ticker.mode:add_revolutionary(podman.mind)
					ticker.mode:update_all_rev_icons() //So the icon actually appears
				if (podman.mind in ticker.mode:head_revolutionaries)
					ticker.mode:update_all_rev_icons()
			if ("nuclear emergency")
				if (podman.mind in ticker.mode:syndicates)
					ticker.mode:update_all_synd_icons()
			if ("cult")
				if (podman.mind in ticker.mode:cult)
					ticker.mode:add_cultist(podman.mind)
					podman.add_language(LANGUAGE_CULT)
					ticker.mode:update_all_cult_icons() //So the icon actually appears
		// -- End mode specific stuff


	to_chat(podman, "<span class='good'><B>You awaken slowly, feeling your sap stir into sluggish motion as the warm air caresses your bark.</B></span>")
	if(source && ckey && podman.ckey == ckey && !ghost)
		to_chat(podman, "<B>Memories of a life as [source] drift oddly through a mind unsuited for them, like a skin of oil over a fathomless lake.</B>")
	to_chat(podman, "<B>You are now one of the Dionaea, a race of drifting interstellar plantlike creatures that sometimes share their seeds with human traders.</B>")
	to_chat(podman, "<B>Too much darkness will send you into shock and starve you, but light will help you heal.</B>")
	if(!realName)
		var/newname = input(podman,"Enter a name, or leave blank for the default name.", "Name change","") as text
		if (newname != "")
			podman.real_name = newname

	parent.visible_message("<span class='notice'>The pod disgorges a fully-formed plant creature!</span>")
	parent.update_tray()
