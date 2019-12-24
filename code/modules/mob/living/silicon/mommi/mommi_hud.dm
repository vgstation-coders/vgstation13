/mob/living/silicon/robot/mommi/handle_regular_hud_updates()
	. = ..()
	if(!can_see_static()) //what lets us avoid the overlay
		if(static_overlays && static_overlays.len)
			remove_static_overlays()

/mob/living/silicon/robot/mommi/handle_health_hud()
	if(healths)
		if(!isDead())
			switch(health)
				if(60 to INFINITY)
					healths.icon_state = "health0"
				if(40 to 60)
					healths.icon_state = "health1"
				if(30 to 40)
					healths.icon_state = "health2"
				if(10 to 20)
					healths.icon_state = "health3"
				if(0 to 10)
					healths.icon_state = "health4"
				if(config.health_threshold_dead to 0)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"
