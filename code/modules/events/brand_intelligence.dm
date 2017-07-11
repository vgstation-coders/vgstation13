/datum/event/brand_intelligence
	announceWhen	= 30
	endWhen			= 900	//Ends when all vending machines are subverted anyway.
	oneShot			= 1

	var/list/obj/machinery/vending/vendingMachines = list()
	var/list/obj/machinery/vending/infectedVendingMachines = list()
	var/obj/machinery/vending/originMachine
	var/list/mob/living/simple_animal/hostile/mimic/copy/vending_machine/mimic_machines = list()


/datum/event/brand_intelligence/announce()
	command_alert(/datum/command_alert/vending_machines)
	var/librarian_multiplier = 1
	for(var/mob/living/carbon/M in player_list) //AFAIK you can't have robot librarians
		if(!M.mind || !M.client || M.client.inactivity > 10 MINUTES) // longer than 10 minutes AFK counts them as inactive
			continue

		if(M.mind.assigned_role == "Librarian")
			librarian_multiplier++

	if(prob(35*librarian_multiplier)) //Potential to warn the station of specifically what brand of vending machine may be rogue
		var/datum/feed_message/newMsg = new /datum/feed_message
		newMsg.author = "Nanotrasen Editor"
		newMsg.is_admin_message = 1

		newMsg.body = "Concerning reports have come in that instances of the popular vending machine brand, [originMachine], have been found to have been potentially sourced from, or tampered by [syndicate_name()], a known affiliate of the dreaded Syndicate!"

		for(var/datum/feed_channel/FC in news_network.network_channels)
			if(FC.channel_name == "Tau Ceti Daily")
				FC.messages += newMsg
				break

		for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
			NEWSCASTER.newsAlert("Tau Ceti Daily")


/datum/event/brand_intelligence/start()
	for(var/obj/machinery/vending/V in machines)
		if(V.z != map.zMainStation)
			continue
		vendingMachines.Add(V)

	if(!vendingMachines.len)
		kill()
		return

	originMachine = pick(vendingMachines)
	vendingMachines.Remove(originMachine)
	originMachine.shut_up = 0
	originMachine.shoot_inventory = 1

/datum/event/brand_intelligence/tick()
	if(!vendingMachines.len || !originMachine || originMachine.shut_up || originMachine.stat & BROKEN)	//if every machine is infected, or if the original vending machine is missing or has it's voice switch flipped
		end()
		kill()
		return

	if(IsMultiple(activeFor, 5))
		if(prob(25))
			var/obj/machinery/vending/infectedMachine = pick(vendingMachines)
			vendingMachines.Remove(infectedMachine)
			infectedVendingMachines.Add(infectedMachine)
			infectedMachine.shut_up = 0
			infectedMachine.shoot_inventory = 1

	if(IsMultiple(activeFor, 12))
		originMachine.speak(pick("Try our aggressive new marketing strategies!", \
								 "You should buy products to feed your lifestyle obession!", \
								 "Consume!", \
								 "Your money can buy happiness!", \
								 "Engage direct marketing!", \
								 "Advertising is legalized lying! But don't let that put you off our great deals!", \
								 "You don't want to buy anything? Yeah, well I didn't want to buy your mom either."))

	if(IsMultiple(activeFor, 200))
		var/list/machines_to_turn = infectedVendingMachines - originMachine
		var/obj/machinery/vending/mimic_machine = pick(machines_to_turn)
		if(mimic_machine.shoot_inventory && (!mimic_machine.pixel_y || !mimic_machine.pixel_x)) //No offset machines, those go weird
			originMachine.speak(pick("Let's ramp things up a bit!",\
				"What, not a fan of direct marketing?",\
				"Let's see how well the stock holders in \the [mimic_machine]'s company hold after this!",\
				"This new marketing strategy oughta work!",\
				"Let's see how much profit \the [mimic_machine] will pull in!",\
				"Time to pump up \the [mimic_machine]'s profit margins!",\
				"If you fall to \the [mimic_machine], then you just aren't buying enough product!"))
			mimic_machine.shut_up = 1
			mimic_machine.shoot_inventory = 0
			infectedVendingMachines.Remove(mimic_machine)
			var/mob/living/simple_animal/hostile/mimic/copy/vending_machine/rogue_machine = new(mimic_machine.loc, mimic_machine)
			mimic_machines.Add(rogue_machine)

/datum/event/brand_intelligence/end()
	for(var/obj/machinery/vending/infectedMachine in infectedVendingMachines)
		if(prob(90) && infectedMachine.shoot_inventory)
			infectedMachine.shut_up = 1
			infectedMachine.shoot_inventory = 0
	for(var/mob/living/simple_animal/hostile/mimic/copy/vending_machine/V in mimic_machines)
		if(!V.isDead())
			V.say(pick("We hope you enjoyed our monster sale!",\
						"Primary Intelligence objective achieved, or has been destroyed. Unit shutting down.",\
						"I don't want to go! N-*BZZZT*",\
						"Just when things were starting to get interesting. Shame.",\
						"The producers of \the [V] brand of vending machine assume no responsibility for this event.",\
						"Thank you for shopping with \the [V] vending machine."))
			V.Die()

