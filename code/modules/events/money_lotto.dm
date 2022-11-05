/datum/event/money_lotto
	startWhen = 2
	announceWhen = 1
	var/list/winning_numbers = list()

/datum/event/money_lotto/can_start()
	return 20

/datum/event/money_lotto/setup()
	startWhen = rand(5,10) * 60

/datum/event/money_lotto/start()
	var/list/luck_skewed_papers = list()
	for(var/obj/item/weapon/paper/lotto_numbers/LN in lotto_papers)
		if(LN.fingerprintslast)
			var/client/foundclient = directory[ckey(LN.fingerprintslast)]
			if(foundclient)
				var/mob/foundmob = foundclient.mob
				if(foundmob)
					luck_skewed_papers[LN] = foundmob.luck()

	var/luck_copy_amount = 0
	var/list/copied_winning_numbers = list()
	if(luck_skewed_papers.len)
		var/obj/item/weapon/paper/lotto_numbers/picked_ticket = pickweight(luck_skewed_papers)
		if(picked_ticket.fingerprintslast)
			var/client/foundclient = directory[ckey(picked_ticket.fingerprintslast)]
			if(foundclient)
				var/mob/foundmob = foundclient.mob
				for(var/i in LOTTO_SAMPLE-3 to LOTTO_SAMPLE)
					if(foundmob?.lucky_prob(100/combinations(LOTTO_BALLCOUNT,i), luckfactor = 1/12000, maxskew = 49.9))
						luck_copy_amount = i
						copied_winning_numbers = picked_ticket.winning_numbers.Copy()

	var/list/nums_to_copy = list()
	if(luck_copy_amount)
		nums_to_copy.Add(LOTTO_SAMPLE)
		for(var/i in 1 to (luck_copy_amount-1))
			var/num_to_copy = 0
			do
				num_to_copy = rand(1,LOTTO_SAMPLE-1)
			while(num_to_copy in nums_to_copy)
			nums_to_copy.Add(num_to_copy)

	for(var/i in 1 to LOTTO_SAMPLE)
		if((i in nums_to_copy) && copied_winning_numbers.len)
			winning_numbers.Add(copied_winning_numbers[i])
		else
			var/newnumber = 0
			do
				newnumber = rand(1,LOTTO_BALLCOUNT)
			while(newnumber in winning_numbers)
			winning_numbers.Add(newnumber)

	var/mob/living/carbon/human/dummy/announcer = null
	for(var/obj/machinery/computer/security/telescreen/entertainment/E in machines)
		if(E.active_camera?.c_tag != "Arena")
			var/list/cameras = E.get_available_cameras()
			if(!("Arena" in cameras))
				continue

			var/obj/machinery/camera/selected_camera = cameras["Arena"]
			E.active_camera = selected_camera

			if(!selected_camera)
				continue

			E.active_camera.camera_twitch()
			E.update_active_camera_screen()
		if(!announcer && E.active_camera)
			var/turf/T = get_turf(E.active_camera)
			announcer = new(T)
			announcer.generate_name()
			var/datum/outfit/special/with_id/nt_rep/NT = new
			NT.equip(announcer,TRUE)

	if(announcer)
		announcer.say("Hello and welcome to another edition of Central Command's Grand Slam -Stellar- Lottery. The numbers are now due to be announced.")
		spawn(8 SECONDS) // This has to be sleep instead of spawn for some reason
			for(var/i in 1 to winning_numbers.len)
				sleep(2 SECONDS)
				announcer.say("[i < winning_numbers.len ? "T" : "And finally t"]he [i]\th number[i == 1 ? " of the draw" : ""] is [winning_numbers[i]].[i == winning_numbers.len ? " Be sure to collect any winnings. This concludes another edition of the Central Command Grand Slam -Stellar- Lottery." : ""]")
			for(var/obj/machinery/vending/lotto/L in machines)
				L.winning_numbers = winning_numbers.Copy()
				for(var/datum/data/vending_product/R in L.product_records)
					if(R.product_path == /obj/item/weapon/paper/lotto_numbers)
						L.product_records.Remove(R)
			spawn(5 SECONDS)
				announcer.forceMove(null)
				qdel(announcer)
	else
		for(var/obj/machinery/computer/security/telescreen/entertainment/E in machines)
			E.say("Central Command's Grand Slam -Stellar- Lottery is off air due to technical difficulties. The numbers have been relayed to us as [english_list(winning_numbers)]. We apologize for the inconvenience.")
		for(var/obj/machinery/vending/lotto/L in machines)
			L.winning_numbers = winning_numbers.Copy()
			for(var/datum/data/vending_product/R in L.product_records)
				if(R.product_path == /obj/item/weapon/paper/lotto_numbers)
					L.product_records.Remove(R)

/datum/event/money_lotto/announce()
	var/datum/command_alert/lotto_announce/LA = new
	LA.message = "A lotto number draw is scheduled to happen within the next [startWhen / 60] minutes. The station's lottery machines now have an exclusive type of ticket available for purchase. All nearby entertainment monitors will be broadcasting the results!"
	command_alert(LA)
	for(var/obj/machinery/vending/lotto/V in machines)
		V.build_inventory(list(/obj/item/weapon/paper/lotto_numbers = 20))
