/datum/event/money_lotto
	endWhen = 2
	announceWhen = 1
	var/list/winning_numbers = list()

/datum/event/money_lotto/can_start()
	return (lotto_papers.len > 0) * (min(20,lotto_papers.len) * 4)

/datum/event/money_lotto/setup()
	var/list/luck_skewed_papers = list()
	for(var/obj/item/weapon/paper/lotto_numbers/LN in lotto_papers)
		if(!LN.fingerprintslast)
			continue
		var/client/foundclient = directory[ckey(LN.fingerprintslast)]
		if(!foundclient)
			continue
		var/mob/foundmob = foundclient.mob
		if(!foundmob)
			continue
		luck_skewed_papers[LN] = foundmob.luck()
	var/luck_copied = FALSE
	if(luck_skewed_papers.len)
		var/obj/item/weapon/paper/lotto_numbers/picked_ticket = pickweight(luck_skewed_papers)
		if(picked_ticket.fingerprintslast)
			var/client/foundclient = directory[ckey(picked_ticket.fingerprintslast)]
			if(foundclient)
				var/mob/foundmob = foundclient.mob
				if(foundmob?.lucky_prob(100/combinations(LOTTO_BALLCOUNT,LOTTO_SAMPLE), luckfactor = 1/12000, maxskew = 49.9))
					winning_numbers = picked_ticket.winning_numbers.Copy()
					luck_copied = TRUE
	if(!luck_copied)
		for(var/i in 1 to LOTTO_SAMPLE)
			var/newnumber = 0
			do
				newnumber = rand(1,LOTTO_BALLCOUNT)
			while(newnumber in winning_numbers)
			winning_numbers.Add(newnumber)
	for(var/obj/machinery/vending/lotto/L in machines)
		L.winning_numbers = winning_numbers.Copy()

/datum/event/money_lotto/announce()
	var/datum/command_alert/lotto_results/LR = new
	LR.message = "A lotto number draw has been announced with the winning numbers [english_list(winning_numbers)]. Please return all lucky winning tickets to lotto vendors to redeem cash prizes"
	command_alert(LR)
