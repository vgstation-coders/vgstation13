// Called if the reagent has passed the overdose threshold and is set to be triggering overdose effects

datum/reagents/proc/metabolize(var/mob/M)
	if(M)
		chem_temp = M.bodytemperature
		handle_reactions()
	if(last_tick == 3)
		last_tick = 1
		for(var/A in reagent_list)
			var/datum/reagent/R = A
			if(M && R)
				if(R.volume >= R.overdose_threshold && !R.overdosed && R.overdose_threshold > 0)
					R.overdosed = 1
					M << "<span class = 'userdanger'>You feel like you took too much of [R.name]!</span>"
					R.overdose_start(M)
				if(R.volume >= R.addiction_threshold && !is_type_in_list(R, addiction_list) && R.addiction_threshold > 0)
					var/datum/reagent/new_reagent = new R.type()
					addiction_list.Add(new_reagent)
				if(R.overdosed)
					R.overdose_process(M)
				if(is_type_in_list(R,addiction_list))
					for(var/datum/reagent/addicted_reagent in addiction_list)
						if(istype(R, addicted_reagent))
							addicted_reagent.addiction_stage = -15 // you're satisfied for a good while.
				R.on_mob_life(M)
	if(addiction_tick == 6)
		addiction_tick = 1
		for(var/A in addiction_list)
			var/datum/reagent/R = A
			if(M && R)
				if(R.addiction_stage <= 0)
					R.addiction_stage++
				if(R.addiction_stage > 0 && R.addiction_stage <= 10)
					R.addiction_act_stage1(M)
					R.addiction_stage++
				if(R.addiction_stage > 10 && R.addiction_stage <= 20)
					R.addiction_act_stage2(M)
					R.addiction_stage++
				if(R.addiction_stage > 20 && R.addiction_stage <= 30)
					R.addiction_act_stage3(M)
					R.addiction_stage++
				if(R.addiction_stage > 30 && R.addiction_stage <= 40)
					R.addiction_act_stage4(M)
					R.addiction_stage++
				if(R.addiction_stage > 40)
					M << "<span class = 'notice'>You feel like you've gotten over your need for [R.name].</span>"
					addiction_list.Remove(R)
	addiction_tick++
	last_tick++
	update_total()