//Hulk turns your skin green, and allows you to punch through walls.
/datum/mutation/human/hulk
	name = "Hulk"
	quality = POSITIVE
	get_chance = 15
	lowest_value = 256 * 12
	text_gain_indication = "<span class='notice'>Your muscles hurt!</span>"
	species_allowed = list("human") //no skeleton/lizard hulk
	health_req = 25

/datum/mutation/human/hulk/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.add_trait(TRAIT_STUNIMMUNE, TRAIT_HULK)
	owner.add_trait(TRAIT_PUSHIMMUNE, TRAIT_HULK)
	owner.update_body_parts()
	owner.SendSignal(COMSIG_ADD_MOOD_EVENT, "hulk", /datum/mood_event/hulk)

/datum/mutation/human/hulk/on_attack_hand(mob/living/carbon/human/owner, atom/target, proximity)
	if(proximity) //no telekinetic hulk attack
		return target.attack_hulk(owner)

/datum/mutation/human/hulk/on_life(mob/living/carbon/human/owner)
	if(owner.health < 0)
		on_losing(owner)
		to_chat(owner, "<span class='danger'>You suddenly feel very weak.</span>")

/datum/mutation/human/hulk/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.remove_trait(TRAIT_STUNIMMUNE, TRAIT_HULK)
	owner.remove_trait(TRAIT_PUSHIMMUNE, TRAIT_HULK)
	owner.update_body_parts()
	owner.SendSignal(COMSIG_CLEAR_MOOD_EVENT, "hulk")

/datum/mutation/human/hulk/say_mod(message)
	if(message)
		message = "[uppertext(replacetext(message, ".", "!"))]!!"
	return message
