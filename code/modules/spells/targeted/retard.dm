//Brain damage spell. This unholy spell was removed but it returns with a vengence.
/spell/targeted/retard
	name = "Brain Damage"
	desc = "Give an unlucky person brain damage."
	abbreviation = "BD"
	user_type = USER_TYPE_SPELLBOOK //Whereas previously this was a normal spell, it is now found only in the ancient spellbook.
	school = "evocation"
	charge_max = 200 // 20 seconds
	//Invocation is noted below
	invocation_type = SpI_WHISPER //Wizard will whisper what they say instead of shouting
	range = 3 // Target anyone within 3 tiles of you
	amt_dam_brain = 30 //30 brain damage
	max_targets = 1 // Can only target one person
	compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey) // Only works on humans and monkeys
	spell_flags = WAIT_FOR_CLICK //Click on whoever you want to get brain damaged
	message = "<span class='danger'>You feel dumber!<span>" //What the victim sees when affected
	mind_affecting = 1 //Blocked by tinfoil hat
	hud_state = "wiz_retard" //Icon is from screen_spells.dmi