/datum/reagent/holywater
	name = "Holy Water"
	id = "holywater"
	description = "An ashen-obsidian-water mix, this solution will alter certain sections of the brain's rationality."
	reagent_state = LIQUID
	color = "#0064C8" // rgb: 0, 100, 200

/datum/reagent/holywater/reaction_obj(var/obj/O, var/volume)
	src = null //WHAT
	if(volume >= 1)
		O.blessed = 1 //You're blessed and shit who cares

/datum/reagent/holywater/on_mob_life(var/mob/living/M as mob,var/alien)

	if(!holder)
		return
	if(ishuman(M))
		if(iscult(M))
			if(prob(10)) //1/10 chance of removing cultist status, so 50 units on average to uncult (half a hole water bottle)
				ticker.mode.remove_cultist(M.mind)
				M.visible_message("<span class='notice'>[M] suddenly becomes calm and collected again, his eyes clear up.</span>",
				"<span class='notice'>Your blood cools down and you are inhabited by a sensation of untold calmness.</span>")
			else //Warn the Cultist that it is fucking him up
				M << "<span class='danger'>A freezing liquid permeates your bloodstream. Your arcane knowledge is becoming osbscure again.</span>"
		//Vampires react to this like acid, and it massively spikes their smitecounter. And they are guaranteed to have adverse effects.
		if(M.mind.vampire)
			if(!M)
				M = holder.my_atom
			if(!(VAMP_MATURE in M.mind.vampire.powers))
				M << "<span class='danger'>A freezing liquid permeates your bloodstream. Your vampiric powers fade and your insides burn.</span>"
				M.take_organ_damage(0, 5) //FIRE
				M.mind.vampire.smitecounter += 10 //50 units to catch on fire. Generally you'll get fucked up quickly
			else
				M << "<span class='warning'>A freezing liquid permeates your bloodstream. Your vampiric powers counter most of the damage.</span>"
				M.mind.vampire.smitecounter += 2 //Basically nothing, unless you drank multiple bottles of holy water (250 units to catch on fire !)
	holder.remove_reagent(src.id, 5 * REAGENTS_METABOLISM) //High metabolism to prevent extended uncult rolls. Approx 5 units per roll

/datum/reagent/holywater/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//Splashing people with water can help put them out!
	src = null
	//Vampires react to this like acid, and it massively spikes their smitecounter. And they are guaranteed to have adverse effects.
	if(ishuman(M))
		if(M.mind.vampire)
			var/mob/living/carbon/human/H=M
			if(!(VAMP_UNDYING in M.mind.vampire.powers))
				if(method == TOUCH)
					if(H.wear_mask)
						H << "<span class='warning'>Your mask protects you from the holy water!</span>"
						return

					if(H.head)
						H << "<span class='warning'>Your helmet protects you from the holy water!</span>"
						return
					if(!M.unacidable)
						if(prob(15) && volume >= 30)
							var/datum/organ/external/affecting = H.get_organ("head")
							if(affecting)
								if(!(VAMP_MATURE in M.mind.vampire.powers))
									M << "<span class='danger'>A freezing liquid covers your face. Its melting!</span>"
									M.mind.vampire.smitecounter += 60 //Equivalent from metabolizing all this holy water normally
									if(affecting.take_damage(30, 0))
										H.UpdateDamageIcon(1)
									H.status_flags |= DISFIGURED
									H.emote("scream",,, 1)
								else
									M << "<span class='warning'>A freezing liquid covers your face. Your vampiric powers protect you!</span>"
									M.mind.vampire.smitecounter += 12 //Ditto above

						else
							if(!(VAMP_MATURE in M.mind.vampire.powers))
								M << "<span class='danger'>You are doused with a frezzing liquid. You're melting!</span>"
								M.take_organ_damage(min(15, volume * 2)) //Uses min() and volume to make sure they aren't being sprayed in trace amounts (1 unit != insta rape) -- Doohl
								M.mind.vampire.smitecounter += volume * 2
							else
								M << "<span class='warning'>You are doused with a freezing liquid. Your vampiric powers protect you!</span>"
								M.mind.vampire.smitecounter += volume * 0.4
				else
					if(!M.unacidable)
						M.take_organ_damage(min(15, volume * 2))
						M.mind.vampire.smitecounter += 5
	return

/datum/reagent/holywater/reaction_turf(var/turf/T, var/volume)
	src = null
	if(volume >= 5)
		T.holy = 1
	return

/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater
	name = "Flask of Holy Water"
	desc = "A flask of the chaplain's holy water."
	icon_state = "holyflask"
	bottleheight = 25
	molotov = -1
	isGlass = 1
	smashtext = ""
	smashname = "broken flask"

/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater/New()
	..()
	reagents.add_reagent("holywater", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater/attack(mob/living/M as mob, mob/user as mob, def_zone)
	return

/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater/afterattack(var/atom/target, var/mob/user, var/adjacency_flag, var/click_params)
	if(!adjacency_flag)
		return

	//Holy water flasks only splash 5u instead of the whole contents
	transfer(target, user, can_send = TRUE, can_receive = TRUE, splashable_units = 5)
