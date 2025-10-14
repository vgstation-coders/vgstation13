
/datum/artifact_effect/mood
	effecttype = "mood"
	valid_style_types = list(ARTIFACT_STYLE_ANOMALY, ARTIFACT_STYLE_ELDRITCH)
	effect = list(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_hint = EFFECT_HINT_INTERMITTENT_PSIONIC_WAVEFRONT
	var/positive = 1
	var/alteration_cap = 70
	copy_for_battery = list("positive")

	var/list/styles = list(
		["red","blue"],
		["warning","notice"],
		)

	var/list/messages = list(
		["You feel worried."										, "You feel good."														],
		["Something doesn't feel right."							, "Everything seems to be going alright"								],
		["You get a strange feeling in your gut."					, "You've got a good feeling about this"								],
		["Your instincts are trying to warn you about something."	, "Your instincts tell you everything is going to be getting better."	],
		["Someone just walked over your grave."						, "There's a good feeling in the air."									],
		["There's a strange feeling in the air."					, "Something smells... good."											],
		["There's a strange smell in the air."						, "The tips of your fingers feel tingly."								],
		["The tips of your fingers feel tingly."					, "You've got a good feeling about this."								],
		["You feel twitchy."										, "You feel happy."														],
		["You have a terrible sense of foreboding."					, "You fight the urge to smile."										],
		["You've got a bad feeling about this."						, "Your scalp prickles."												],
		["Your scalp prickles."										, "All the colours seem a bit more vibrant."							],
		["The light seems to flicker."								, "Everything seems a little lighter."									],
		["The shadows seem to lengthen."							, "The troubles of the world seem to fade away."						],
		["The walls are getting closer."							, "It's good to be alive."												],
		["Something is wrong"										, "There's a music in the air."											]
		)

	var/list/drastic_messages = list(
		["You've got to get out of here!"	, "You want to hug everyone you meet!"							],
		["Someone's trying to kill you!"	, "Everything is going so well!"								],
		["There's something out there!"		, "You feel euphoric."											],
		["What's happening to you?"			, "You feel giddy."												],
		["OH GOD!"							, "You're so happy suddenly, you almost want to dance and sing."],
		["HELP ME!"							, "You feel like the world is out to help you."					]
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
