var/mob/living/carbon/human/H /*var H=src*/
var/obj/item/clothing/under/G
var/mob/living/M
var/mob/living/carbon/human/target
var/mob/living/user
/datum/disease/periods
	name = "Periods"
	max_stages = 4
	spread = "None"
	spread_type = SPECIAL
	cure = "None"
	cure_chance = 99
	agent = "Periods"
	affected_species = list("Human")
	longevity = 3000
	permeability_mod = 0.75
	desc = "Just This days."
	severity = "Medium"

/datum/disease/periods/stage_act()
	..()
	switch(stage)
		if(1)
			if(H.gender == FEMALE)
				if(prob(3))
					affected_mob << "\red Your feel something is flowing from your groin. Oh, it's blood."
					var/mob/living/carbon/human/H = user
					H.bloody_body(target,0)
			if(H.gender == MALE)
				stage--
				return


		if(2)
			if(prob(5))
				affected_mob << "\red You feels something is flow from your groin. Oh, it's blood"
				var/mob/living/carbon/human/H = user
				H.bloody_body(target,0)
			if(prob(2))
				affected_mob << "\red You feels sensitivity."
			if(prob(2))
				affected_mob << "\red You feels nervous."
			if(prob(2))
				affected_mob << "\red You feels depressive."
			if(prob(2))
				affected_mob << "\red You feels tired."


		if(3)
			if(prob(5))
				affected_mob << "\red You feels something is flow from your groin. Oh, it's blood."
				var/mob/living/carbon/human/H = user
				H.bloody_body(target,0)
			if(prob(2))
				affected_mob << "\red You feels sensitivity."
			if(prob(2))
				affected_mob << "\red You feels nervous."
			if(prob(2))
				affected_mob << "\red You feels depressive."
			if(prob(2))
				affected_mob << "\red You feels tired."
			if(prob(2))
				affected_mob << "\red You feels very agressive!"

		if(4)
			if(prob(5))
				affected_mob << "\red You feels something is flow from your groin. Oh, it's blood."
				var/mob/living/carbon/human/H = user
				H.bloody_body(target,0)
			if(prob(2))
				affected_mob << "\red You feels sensitivity."
			if(prob(2))
				affected_mob << "\red You feels nervous."
			if(prob(2))
				affected_mob << "\red You feels depressive."
			if(prob(2))
				affected_mob << "\red You feels tired."
			if(prob(2))
				affected_mob << "\red You feels very agressive!"
			if(prob(1))
				affected_mob << "\red You feels great."
				src.cure()
				return