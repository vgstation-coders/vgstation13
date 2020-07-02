/mob/living/carbon/slime/death(gibbed)
	if(stat == DEAD)
		return
	stat = DEAD
	icon_state = "[colour] baby slime dead"

	if(!gibbed)
		if(istype(src, /mob/living/carbon/slime/adult))
			//ghostize() - Messes up making momma slime a baby
			var/mob/living/carbon/slime/M1 = new primarytype(loc)
			if(src.mind)
				src.mind.transfer_to(M1)
			else
				M1.key = src.key
				M1.rabid()
			var/mob/living/carbon/slime/M2 = new primarytype(loc)
			M2.rabid()
			if(src)
				qdel(src)
				return
		else
			for(var/mob/O in viewers(src, null))
				O.show_message("<b>The [name]</b> seizes up and falls limp...", 1) //ded -- Urist

	update_canmove()

	return ..(gibbed)
