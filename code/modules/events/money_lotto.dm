/datum/event/money_lotto
	endWhen = 360
	startWhen = 300
	announceWhen = 1
	var/list/winning_numbers = list()

/datum/event/money_lotto/can_start()
	return (lotto_papers.len > 0) * (min(20,lotto_papers.len) * 4)

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
	for(var/obj/machinery/computer/security/telescreen/entertainment/E in machines)
		E.say("Hello and welcome to another edition of Central Command's Grand Slam -Stellar- Lottery. The numbers are now due to be announced.")
	sleep(10 SECONDS)
	for(var/i in 1 to winning_numbers.len - 1)
		for(/obj/machinery/computer/security/telescreen/entertainment/E in machines)
			E.say("[i < winning_numbers.len ? "T" : "And finally t"]he [i]\th number[i == 1 ? " of the draw" : ""] is [winning_numbers[i]].[i == winning_numbers.len ? "Be sure to collect any winnings. This concludes another edition of the Central Command Grand Slam -Stellar- Lottery." : ""]")
		sleep(2 SECONDS)
	for(var/obj/machinery/vending/lotto/L in machines)
		L.winning_numbers = winning_numbers.Copy()

/datum/event/money_lotto/announce()
	command_alert(/datum/command_alert/lotto_announce)
