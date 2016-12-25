/mob/living/carbon/alien/disarm_mob(mob/living/target)
	if(target.disarmed_by(src))
		return

	if(prob(80))
		playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
		target.Knockdown(rand(3,4))

		visible_message("<span class='danger'>[src] has tackled down [target]!</span>")

	else if (prob(80))
		playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
		target.drop_item()
		target.break_pulls()
		target.break_grabs()
		visible_message("<span class='danger'>[src] has disarmed [target]!</span>")
	else
		playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
		visible_message("<span class='danger'>[src] has tried to disarm [target]!</span>")
