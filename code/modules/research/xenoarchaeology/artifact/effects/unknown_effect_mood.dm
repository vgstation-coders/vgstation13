
/datum/artifact_effect/mood
	effecttype = "mood"
	valid_artifact_styles = list(ARTIFACT_STYLE_ANOMALY, ARTIFACT_STYLE_ELDRITCH)
	effect = list(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_hint = EFFECT_HINT_INTERMITTENT_PSIONIC_WAVEFRONT
	var/positive = 1
	var/alteration_cap = 70
	copy_for_battery = list("positive")

	var/list/styles = list(
		list("red","blue"),
		list("warning","notice"),
		)

	var/list/messages = list(
		list("You feel worried."										, "You feel good."														),
		list("Something doesn't feel right."							, "Everything seems to be going alright"								),
		list("You get a strange feeling in your gut."					, "You've got a good feeling about this"								),
		list("Your instincts are trying to warn you about something."	, "Your instincts tell you everything is going to be getting better."	),
		list("Someone just walked over your grave."						, "There's a good feeling in the air."									),
		list("There's a strange feeling in the air."					, "Something smells... good."											),
		list("There's a strange smell in the air."						, "The tips of your fingers feel tingly."								),
		list("The tips of your fingers feel tingly."					, "You've got a good feeling about this."								),
		list("You feel twitchy."										, "You feel happy."														),
		list("You have a terrible sense of foreboding."					, "You fight the urge to smile."										),
		list("You've got a bad feeling about this."						, "Your scalp prickles."												),
		list("Your scalp prickles."										, "All the colours seem a bit more vibrant."							),
		list("The light seems to flicker."								, "Everything seems a little lighter."									),
		list("The shadows seem to lengthen."							, "The troubles of the world seem to fade away."						),
		list("The walls are getting closer."							, "It's good to be alive."												),
		list("Something is wrong"										, "There's a music in the air."											)
		)

	var/list/drastic_messages = list(
		list("You've got to get out of here!"	, "You want to hug everyone you meet!"							),
		list("Someone's trying to kill you!"	, "Everything is going so well!"								),
		list("There's something out there!"		, "You feel euphoric."											),
		list("What's happening to you?"			, "You feel giddy."												),
		list("OH GOD!"							, "You're so happy suddenly, you almost want to dance and sing."),
		list("HELP ME!"							, "You feel like the world is out to help you."					)
		)

/datum/artifact_effect/mood/New()
	..()
	if (prob(50))
		positive = 0

/datum/artifact_effect/mood/DoEffectTouch(var/mob/user)
	if(user)
		if (istype(user, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			if(prob(50))
				if(prob(75))
					var/message = pick(drastic_messages)
					var/style = styles[0]
					to_chat(H, "<b><font color='[style[positive]]' size='[num2text(rand(1,5))]'><b>[message[positive]]</b></font>")
				else
					var/message = pick(messages)
					var/style = styles[1]
					to_chat(H, "<span class='[style[positive]]'>[message[positive]]</span>")

			if(prob(50))
				if (positive)
					H.druggy = min(H.druggy + rand(3,5), alteration_cap)
				else
					H.dizziness = min(H.dizziness + rand(3,5), alteration_cap)

/datum/artifact_effect/mood/DoEffectAura()
	if(holder)
		for (var/mob/living/carbon/human/H in range(src.effectrange,get_turf(holder)))
			if(prob(5))
				if(prob(75))
					var/message = pick(messages)
					var/style = styles[1]
					to_chat(H, "<span class='[style[positive]]'>[message[positive]]</span>")
				else
					var/message = pick(drastic_messages)
					var/style = styles[0]
					to_chat(H, "<font color='[style[positive]]' size='[num2text(rand(1,5))]'><b>[message[positive]]</b></font>")

			if(prob(10))
				if (positive)
					H.druggy = min(H.druggy + rand(3,5), alteration_cap)
				else
					H.dizziness = min(H.dizziness + rand(3,5), alteration_cap)

/datum/artifact_effect/mood/DoEffectPulse()
	if(holder)
		for (var/mob/living/carbon/human/H in range(src.effectrange,get_turf(holder)))
			if(prob(50))
				if(prob(95))
					var/message = pick(drastic_messages)
					var/style = styles[0]
					to_chat(H, "<font color='[style[positive]]' size='[num2text(rand(1,5))]'><b>[message[positive]]</b></font>")
				else
					var/message = pick(messages)
					var/style = styles[1]
					to_chat(H, "<span class='[style[positive]]'>[message[positive]]</span>")

			if(prob(50))
				if (positive)
					H.druggy = min(H.druggy + rand(3,5), alteration_cap)
				else
					H.dizziness = min(H.dizziness + rand(3,5), alteration_cap)
			else if(prob(25))
				if (positive)
					H.druggy = min(H.druggy + rand(5,15), alteration_cap)
				else
					H.dizziness = min(H.dizziness + rand(5,15), alteration_cap)
