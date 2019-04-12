/obj/item/device/harmalarm
	name = "sonic harm prevention tool"
	desc = "Releases a harmless blast that confuses most organics. For when the harm is JUST TOO MUCH"
	icon_state = "megaphone"
	var/cooldown = 0
	var/alarm = "HUMAN HARM"
	var/alarm_sound = 'sound/AI/harmalarm.ogg'
	var/emagged_alarm = "BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZT"
	var/emagged_alarm_sound = 'sound/machines/warning-buzzer.ogg'
	var/vary = TRUE

/obj/item/device/harmalarm/attack_self(mob/user)
	var/safety = TRUE
	if(cooldown > world.time)
		to_chat(user,"<span class='warning'>The device is still recharging!</span>")
		return

	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(R.cell.charge < 1200)
			to_chat(user, "<span class='warning'>You don't have enough charge to do this!</span>")
			return
		R.cell.charge -= 1000
		if(R.emagged)
			safety = FALSE
		if(R.connected_ai)
			to_chat(R.connected_ai,"<br><span class='bnotice'>NOTICE - [src] used by: [user]</span><br>")

	if(safety == TRUE)
		user.visible_message("<span class='big danger'>[alarm]</span>")
		playsound(src, alarm_sound, 70, 3, vary = src.vary)
		add_gamelogs(user, "used \the [src]", admin = TRUE, tp_link = TRUE, tp_link_short = FALSE, span_class = "notice")
		for(var/mob/living/carbon/M in hearers(9, user))
			if(M.earprot() || M.is_deaf())
				continue
			to_chat(M, "<span class='warning'>[user] blares out a near-deafening siren from its speakers!</span>")
			to_chat(M, "<span class='danger'>The siren pierces your hearing!</span>")
			M.stuttering += 5
			M.ear_deaf += 1
			M.dizziness += 5
			M.confused +=  5
			M.Jitter(5)
			add_gamelogs(user, "alarmed [key_name(M)] with \the [src]", admin = FALSE, tp_link = FALSE)
		cooldown = world.time + 20 SECONDS
		return

	if(safety == FALSE)
		user.visible_message("<span class='big danger'>[emagged_alarm]</span>")
		playsound(src, emagged_alarm_sound, 130, 3, vary = src.vary)
		add_gamelogs(user, "used an emagged [name]", admin = TRUE, tp_link = TRUE, tp_link_short = FALSE, span_class = "danger")
		for(var/mob/living/carbon/M in hearers(6, user))
			if(M.earprot())
				continue
			M.sleeping = 0 // WAKE ME UP
			M.stuttering += 30
			M.ear_deaf += 10
			M.Knockdown(7) // CAN'T WAKE UP
			M.Stun(7)
			M.Jitter(30)
			add_gamelogs(user, "knocked out [key_name(M)] with an emagged [name]", admin = FALSE, tp_link = FALSE)
		cooldown = world.time + 1 MINUTES

/obj/item/device/harmalarm/proc/Lawize()
	name = "sonic law breaking prevention tool"
	desc = "Releases a harmless blast that confuses most organics. For when the crime is JUST TOO MUCH"
	alarm = "HALT! SECURITY!"
	alarm_sound = 'sound/voice/halt.ogg'
	emagged_alarm = "FUCK YOUR CUNT YOU SHIT EATING COCKSUCKER MAN EAT A DONG FUCKING ASS RAMMING SHITFUCK. EAT PENISES IN YOUR FUCKFACE AND SHIT OUT ABORTIONS OF FUCK AND DO A SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FUCK ASS WANKER FROM THE DEPTHS OF SHIT."
	emagged_alarm_sound = 'sound/voice/binsult.ogg'
	vary = FALSE

/obj/item/device/harmalarm/proc/Honkize()
	name = "\improper HoNkER BlAsT 2500"
	desc = "Releases a harmless blast that confuses most organics. For when the FUN is JUST TOO MUCH"
	alarm = "HONK!"
	alarm_sound = 'sound/items/bikehorn.ogg'
	emagged_alarm = "HOOOOOOONK!"
	emagged_alarm_sound = 'sound/items/AirHorn.ogg'
