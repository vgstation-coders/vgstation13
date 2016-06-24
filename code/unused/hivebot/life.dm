/mob/living/silicon/hivebot/Life()
	set invisibility = 0
	set background = 1
	if(timestopped) return 0 //under effects of time magick

	if (monkeyizing)
		return

	if (stat != 2)
		use_power()

	blinded = null

	clamp_values()

	handle_regular_status_updates()

	if(client)
		shell = 0
		handle_regular_hud_updates()
		update_items()
		if(dependent)
			mainframe_check()

	update_canmove()


/mob/living/silicon/hivebot
	proc
		clamp_values()

			stunned = max(min(stunned, 10),0)
			paralysis = max(min(paralysis, 1), 0)
			weakened = max(min(weakened, 15), 0)
			sleeping = max(min(sleeping, 1), 0)
			setToxLoss(0)
			setOxyLoss(0)

		use_power()

			if (energy)
				if(energy <= 0)
					death()

				else if (energy <= 10)
					module_active = null
					module_state_1 = null
					module_state_2 = null
					module_state_3 = null
					energy -=1
				else
					if(module_state_1)
						energy -=1
					if(module_state_2)
						energy -=1
					if(module_state_3)
						energy -=1
					energy -=1
					blinded = 0
					stat = 0
			else
				blinded = 1
				stat = 1

		update_canmove()
			if(incapacitated()) canmove = 0
			else canmove = 1


		handle_regular_status_updates()

			health = health_max - (getFireLoss() + getBruteLoss())

			if(health <= 0)
				death()

			if (stat != 2) //Alive.

				if (incapacitated()) //Stunned etc.
					if (stunned > 0)
						stunned--
						stat = 0
					if (weakened > 0)
						weakened--
						lying = 0
						stat = 0
					if (paralysis > 0)
						paralysis--
						blinded = 0
						lying = 0
						stat = 1

				else	//Not stunned.
					lying = 0
					stat = 0

			else //Dead.
				blinded = 1
				stat = 2

			density = !( lying )

			if ((sdisabilities & 1))
				blinded = 1
			if ((sdisabilities & 4))
				ear_deaf = 1

			if (eye_blurry > 0)
				eye_blurry--
				eye_blurry = max(0, eye_blurry)

			if (druggy > 0)
				druggy--
				druggy = max(0, druggy)

			return 1

		handle_regular_hud_updates()

			if (stat == 2 || M_XRAY in mutations)
				sight |= SEE_TURFS
				sight |= SEE_MOBS
				sight |= SEE_OBJS
				see_in_dark = 8
				see_invisible = SEE_INVISIBLE_LEVEL_TWO
			else if (stat != 2)
				sight &= ~SEE_MOBS
				sight &= ~SEE_TURFS
				sight &= ~SEE_OBJS
				see_in_dark = 8
				see_invisible = SEE_INVISIBLE_LEVEL_TWO

			if (healths)
				if (stat != 2)
					switch(health)
						if(health_max to INFINITY)
							healths.icon_state = "health0"
						if(health_max*0.80 to health_max)
							healths.icon_state = "health1"
						if(health_max*0.60 to health_max*0.80)
							healths.icon_state = "health2"
						if(health_max*0.40 to health_max*0.60)
							healths.icon_state = "health3"
						if(health_max*0.20 to health_max*0.40)
							healths.icon_state = "health4"
						if(0 to health_max*0.20)
							healths.icon_state = "health5"
						else
							healths.icon_state = "health6"
				else
					healths.icon_state = "health7"

			if (cells)
				switch(energy)
					if(energy_max*0.75 to INFINITY)
						cells.icon_state = "charge4"
					if(0.5*energy_max to 0.75*energy_max)
						cells.icon_state = "charge3"
					if(0.25*energy_max to 0.5*energy_max)
						cells.icon_state = "charge2"
					if(0 to 0.25*energy_max)
						cells.icon_state = "charge1"
					else
						cells.icon_state = "charge0"

			switch(bodytemperature) //310.055 optimal body temp

				if(335 to INFINITY)
					bodytemp.icon_state = "temp2"
				if(320 to 335)
					bodytemp.icon_state = "temp1"
				if(300 to 320)
					bodytemp.icon_state = "temp0"
				if(260 to 300)
					bodytemp.icon_state = "temp-1"
				else
					bodytemp.icon_state = "temp-2"


			update_pull_icon()

			client.screen -= hud_used.blurry
			client.screen -= hud_used.druggy
			client.screen -= hud_used.vimpaired

			if ((blind && stat != 2))
				if ((blinded))
					blind.layer = 18
				else
					blind.layer = 0

					if (disabilities & 1)
						client.screen += hud_used.vimpaired

					if (eye_blurry)
						client.screen += hud_used.blurry

					if (druggy)
						client.screen += hud_used.druggy

			if (stat != 2)
				if (machine)
					if (!( machine.check_eye(src) ))
						reset_view(null)
				else
					if(!client.adminobs)
						reset_view(null)

			return 1


		update_items()
			if (client)
				client.screen -= contents
				client.screen += contents
			if(module_state_1)
				module_state_1:screen_loc = ui_inv1
			if(module_state_2)
				module_state_2:screen_loc = ui_inv2
			if(module_state_3)
				module_state_3:screen_loc = ui_inv3

		mainframe_check()
			if(mainframe)
				if(mainframe.stat == 2)
					mainframe.return_to(src)
			else
				death()
