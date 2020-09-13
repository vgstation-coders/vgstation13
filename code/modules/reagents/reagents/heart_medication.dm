/datum/reagent/trinitrine
	name = "Trinitrine"
	id = TRINITRINE
	description = "Glyceryl Trinitrate, also known as diluted nitroglycerin, is a medication used for heart failure and to treat and prevent chest pain due to hyperzine."
	reagent_state = REAGENT_STATE_LIQUID
	overdose_tick = 50
	color = "#CED7D5" //rgb: 206, 215, 213
	alpha = 142
	density = 1.33
	specheatcap = 3.88

/datum/reagent/trinitrine/on_mob_life(var/mob/living/M)
	if(prob(10))
		M.adjustOxyLoss(REM)
	if(prob(50))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/datum/organ/internal/heart/E = H.internal_organs_by_name["heart"]
			if(prob(5))
				H.custom_pain("You feel a pain in your head", 0)
			if(istype(E) && !E.robotic)
				if(E.damage > 0)
					E.damage = max(0, E.damage - 0.2)
	if(prob(10))
		M.drowsyness = max(M.drowsyness, 2)

