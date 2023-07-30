#define SUTURABLE_DAMAGE min_broken_damage * 0.75
//you can't stitch a mangled spaceman to full health, he'll retain some injuries still
//~56 on chest/groin
//30 on the head
//20 on arms/legs
//10 on feet/hands

/datum/surgery_step/suture_wounds
	allowed_tools = list(
		/obj/item/tool/suture = 100)
	can_infect = 1


	duration = 2 SECONDS

/datum/surgery_step/suture_wounds/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool/suture/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(affected.open > 0) //in the middle of proper surgery
		to_chat(user,"<span class='warning'>the [affected.display_name] is cut wide open!")
		return FALSE
	if(!affected.is_organic()) //can't suture robolimbs OR PEG LIMBS
		to_chat(user, "<span class='warning'>That limb isn't biological!")
		return FALSE

	if(tool.heal_brute)
		if(affected.brute_dam > affected.SUTURABLE_DAMAGE)
			return TRUE
		else
			to_chat(user,"<span class='warning'>[target]'s [affected.display_name] wounds are not severe enough to stitch together.")
	if(tool.heal_burn)
		if(affected.burn_dam > affected.SUTURABLE_DAMAGE)
			return TRUE
		else
			to_chat(user,"<span class='warning'>[target]'s [affected.display_name] burns are not severe enough to graft.")

/datum/surgery_step/suture_wounds/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool/suture/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	//no message here to not spam your chat too much
	target.custom_pain("Something in your [affected.display_name] is causing you a lot of pain!",1, scream=TRUE)
	..()

/datum/surgery_step/suture_wounds/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool/suture/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	affected.heal_damage(tool.heal_brute, tool.heal_burn)//heal damage first so we know which message to display
	target.UpdateDamageIcon()
	if(tool.heal_brute)
		if(affected.brute_dam > affected.SUTURABLE_DAMAGE)//there's still more wound to stitch
			user.visible_message("<span class='notice'>[user] sutures some of the wounds in [target]'s [affected.display_name] with [tool].</span>", \
			"<span class='notice'>You suture some of the wounds in [target]'s [affected.display_name] with [tool].</span>")
		else //we're under the suture threshold, so we can't do it anymore on this limb
			user.visible_message("<span class='notice'>[user] finishes stitching [target]'s [affected.display_name] with [tool].</span>", \
			"<span class='notice'>You finish stitching [target]'s [affected.display_name] with [tool].</span>")
	if(tool.heal_burn)
		if(affected.burn_dam > affected.SUTURABLE_DAMAGE)
			user.visible_message("<span class='notice'>[user] grafts some fresh skin to [target]'s [affected.display_name] with [tool].</span>", \
			"<span class='notice'>You graft some fresh skin to [target]'s [affected.display_name] with [tool].</span>")
		else
			user.visible_message("<span class='notice'>[user] finishes applying new skin to [target]'s [affected.display_name] with [tool].</span>", \
			"<span class='notice'>You finish applying new skin to [target]'s [affected.display_name] with [tool].</span>")



/datum/surgery_step/suture_wounds/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool/suture/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	//oh shit, i'm sorry
	user.visible_message("<span class='warning'>[user] pulls on [target]'s [affected.display_name] too hard and rips the skin!</span>" , \
	"<span class='warning'>You pull on [target]'s [affected.display_name] so hard, you rip the skin!</span>")
	target.apply_effects(agony = 30)
