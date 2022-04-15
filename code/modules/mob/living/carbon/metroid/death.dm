/mob/living/carbon/metroid/death(gibbed)
	if(stat == DEAD)	return
	stat = DEAD
	icon_state = "[subtype] baby metroid dead"

	if(!gibbed)
		if(istype(src, /mob/living/carbon/metroid/adult))
			icon_state = "[subtype] adult metroid dead"
		/*
			if(src)
				new /obj/effect/gibspawner/metroid(src.loc)
				del(src)
				return
			ghostize()
			explosion(loc, -1,-1,3,12)
			if(src)	del(src)
		else
		*/
		for(var/mob/O in viewers(src, null))
			O.show_message("<b>The [name]</b> seizes up and falls limp...", 1) //ded -- Urist

	update_canmove()
	if(blind)	blind.layer = 0

	ticker.mode.check_win()

	return ..(gibbed)