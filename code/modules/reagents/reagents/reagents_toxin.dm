//Poisonous chemicals

/datum/reagent/amanatin
	name = "Alpha-Amanatin"
	id = AMANATIN
	description = "A deadly poison derived from certain species of Amanita. Sits in the victim's system for a long period of time, then ravages the body."
	color = "#792300" //rgb: 121, 35, 0
	custom_metabolism = 0.01
	var/activated = 0

/datum/reagent/amanatin/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(volume <= 3 && tick >= 60 && !activated)	//Minimum of 1 minute required to be useful
		activated = 1
	if(activated)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(prob(8))
				H << "<span class='warning'>You feel violently ill.</span>"
			if(prob(min(tick / 10, 100)))
				H.vomit()
			var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
			if(istype(L) && !L.is_broken())
				L.take_damage(tick * 0.01, 0)
				H.adjustToxLoss(round(tick / 20, 1))
			else
				H.adjustToxLoss(round(tick / 10, 1))
				tick += 4
	switch(tick)
		if(1 to 30)
			M.druggy = max(M.druggy, 10)
		if(540 to 600)	//Start barfing violently after 9 minutes
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(prob(12))
					H << "<span class='warning'>You feel violently ill.</span>"
				H.adjustToxLoss(0.1)
				if(prob(8))
					H.vomit()
		if(600 to INFINITY)	//Ded in 10 minutes with a minimum of 6 units
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(prob(20))
					H << "<span class='sinister'>You feel deathly ill.</span>"
				var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
				if(istype(L) && !L.is_broken())
					L.take_damage(10, 0)
				else
					H.adjustToxLoss(60)

/datum/reagent/amatoxin
	name = "Amatoxin"
	id = AMATOXIN
	description = "A powerful poison derived from certain species of mushroom."
	color = "#792300" //rgb: 121, 35, 0

/datum/reagent/amatoxin/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.adjustToxLoss(1.5)

/datum/reagent/aslimetoxin
	name = "Advanced Mutation Toxin"
	id = AMUTATIONTOXIN
	description = "An advanced corruptive toxin produced by slimes."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#13BC5E" //rgb: 19, 188, 94
	overdose_am = REAGENTS_OVERDOSE
	density = 1.35
	specheatcap = 0.135

/datum/reagent/aslimetoxin/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(iscarbon(M) && M.stat != DEAD)

		var/mob/living/carbon/C = M

		if(ismanifested(C))
			to_chat(C, "<span class='warning'>You can feel intriguing reagents seeping into your body, but they don't seem to react at all.</span>")
			C.reagents.del_reagent("amutationtoxin")

		else
			if(C.monkeyizing)
				return
			to_chat(M, "<span class='warning'>Your flesh rapidly mutates!</span>")
			C.monkeyizing = 1
			C.canmove = 0
			C.icon = null
			C.overlays.len = 0
			C.invisibility = 101
			for(var/obj/item/W in C)
				if(istype(W, /obj/item/weapon/implant))	//TODO: Carn. give implants a dropped() or something
					qdel(W)
					continue
				W.reset_plane_and_layer()
				W.forceMove(C.loc)
				W.dropped(C)
			var/mob/living/carbon/slime/new_mob = new /mob/living/carbon/slime(C.loc)
			new_mob.a_intent = I_HURT
			if(C.mind)
				C.mind.transfer_to(new_mob)
			else
				new_mob.key = C.key
			C.transferBorers(new_mob)
			qdel(C)

/datum/reagent/bicarodyne
	name = "Bicarodyne"
	id = BICARODYNE
	description = "Not to be confused with Bicaridine, Bicarodyne is a volatile chemical that reacts violently in the presence of most human endorphins."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	overdose_am = REAGENTS_OVERDOSE * 2 //No need for anyone to get suspicious.
	custom_metabolism = 0.01

/datum/reagent/carpotoxin
	name = "Carpotoxin"
	id = CARPOTOXIN
	description = "A deadly neurotoxin produced by the dreaded spess carp."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#003333" //rgb: 0, 51, 51
	density = 319.27 //Assuming it's Tetrodotoxin
	specheatcap = 41.53

/datum/reagent/carpotoxin/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.adjustToxLoss(2 * REM)

//Quiet and lethal, needs at least 4 units in the person before they'll die
/datum/reagent/chefspecial
	name = "Chef's Special"
	id = CHEFSPECIAL
	description = "An extremely toxic chemical that will surely end in death."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#CF3600" //rgb: 207, 54, 0
	custom_metabolism = 0.01
	overdose_tick = 165
	density = 0.687 //Let's assume it's a compound of cyanide
	specheatcap = 1.335

/datum/reagent/chefspecial/on_overdose(var/mob/living/M)
	M.death(0)
	M.attack_log += "\[[time_stamp()]\]<font color='red'>Died a quick and painless death by <font color='green'>Chef Excellence's Special Sauce</font>.</font>"

//Otherwise known as a "Mickey Finn"
/datum/reagent/chloralhydrate
	name = "Chloral Hydrate"
	id = CHLORALHYDRATE
	description = "A powerful sedative."
	reagent_state = REAGENT_STATE_SOLID
	color = "#000067" //rgb: 0, 0, 103
	flags = CHEMFLAG_DISHONORABLE // NO CHEATING
	density = 11.43
	specheatcap = 13.79

/datum/reagent/chloralhydrate/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	switch(tick)
		if(0)
			M.confused += 2
			M.drowsyness += 2
		if(1 to 79)
			M.sleeping++
		if(80 to INFINITY)
			M.sleeping++
			M.toxloss += (tick - 50)

//Chloral hydrate disguised as normal beer for use by emagged brobots
/datum/reagent/chloralhydrate/beer2
	name = "Beer"
	id = BEER2
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#664300" //rgb: 102, 67, 0
	glass_icon_state = "beerglass"
	glass_desc = "A cold pint of pale lager."

/datum/reagent/chloramine
	name = "Chloramine"
	id = CHLORAMINE
	description = "A chemical compound consisting of chlorine and ammonia. Very dangerous when inhaled."
	reagent_state = REAGENT_STATE_GAS
	color = "#808080" //rgb: 128, 128, 128
	overdose_am = REAGENTS_OVERDOSE
	density = 3.68
	specheatcap = 1299.23

/datum/reagent/chloramine/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.take_organ_damage(REM, 0)

/datum/reagent/chloramine/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if((H.species && H.species.flags & NO_BREATHE) || (M_NO_BREATH in H.mutations))
			return
		for(var/datum/organ/internal/lungs/L in H.internal_organs)
			L.take_damage(REM, 1)

//Fast and lethal
/datum/reagent/cyanide
	name = "Cyanide"
	id = CYANIDE
	description = "A highly toxic chemical."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#CF3600" //rgb: 207, 54, 0
	custom_metabolism = 0.4
	flags = CHEMFLAG_DISHONORABLE // NO CHEATING
	density = 0.699
	specheatcap = 1.328

/datum/reagent/cyanide/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.adjustToxLoss(4)
	M.adjustOxyLoss(4)
	M.sleeping += 1

/datum/reagent/hamserum
	name = "Ham Serum"
	id = HAMSERUM
	description = "Concentrated legal discussions."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#00FF21" //rgb: 0, 255, 33

/datum/reagent/hamserum/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return 1

	empulse(get_turf(M), 1, 2, 1)

	return

/datum/reagent/heartbreaker
	name = "Heartbreaker Toxin"
	id = HEARTBREAKER
	description = "A powerful hallucinogen and suffocant. Not a thing to be messed with."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#ff91b7" //rgb: 255, 145, 183
	density = 0.78
	specheatcap = 5.47

/datum/reagent/heartbreaker/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.hallucination += 5
	M.adjustOxyLoss(4 * REM)

/datum/reagent/hemoscyanine
	name = "Hemoscyanine"
	id = HEMOSCYANINE
	description = "Hemoscyanine is a toxin which can destroy blood cells."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#600000" //rgb: 96, 0, 0
	density = 11.53
	specheatcap = 0.22

/datum/reagent/hemoscyanine/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!(H.species.anatomy_flags & NO_BLOOD))
			H.vessel.remove_reagent(BLOOD, 2)

/datum/reagent/honkserum
	name = "Honk Serum"
	id = HONKSERUM
	description = "Concentrated honking."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#F2C900" //rgb: 242, 201, 0
	custom_metabolism = 0.05
	overdose_am = REAGENTS_OVERDOSE

/datum/reagent/honkserum/on_overdose(var/mob/living/H)
	if (H?.mind?.miming)
		H.mind.miming = 0
		for(var/spell/aoe_turf/conjure/forcewall/mime/spell in H.spell_list)
			H.remove_spell(spell)
		for(var/spell/targeted/oathbreak/spell in H.spell_list)
			H.remove_spell(spell)
		if (istype(H.wear_mask, /obj/item/clothing/mask/gas/mime/stickymagic))
			qdel(H.wear_mask)
			H.visible_message("<span class='warning'>\The [H]'s mask melts!</span>")
		H.visible_message("<span class='notice'>\The [H]'s face goes pale for a split second, and then regains some colour.</span>", "<span class='notice'><i>Where did Marcel go...?</i></span>'")

/datum/reagent/honkserum/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(prob(5))
		M.say(pick("Honk", "HONK", "Hoooonk", "Honk?", "Henk", "Hunke?", "Honk!"))
		playsound(M, 'sound/items/bikehorn.ogg', 50, -1)

/datum/reagent/mercury
	name = "Mercury"
	id = MERCURY
	description = "A chemical element."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#484848" //rgb: 72, 72, 72
	overdose_am = REAGENTS_OVERDOSE
	specheatcap = 0.14
	density = 13.56

/datum/reagent/mercury/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(M.canmove && !M.restrained() && istype(M.loc, /turf/space))
		step(M, pick(cardinal))

	if(prob(5))
		M.emote(pick("twitch","drool","moan"), null, null, TRUE)

	M.adjustBrainLoss(2)

/datum/reagent/mindbreaker
	name = "Mindbreaker Toxin"
	id = MINDBREAKER
	description = "A powerful hallucinogen. Not a thing to be messed with."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#B31008" //rgb: 139, 166, 233
	custom_metabolism = 0.05
	density = 0.78
	specheatcap = 5.47

/datum/reagent/mindbreaker/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.hallucination += 10

/datum/reagent/minttoxin
	name = "Mint Toxin"
	id = MINTTOXIN
	description = "Useful for dealing with undesirable customers. The undiluted version of Mint Extract."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#CF3600" //rgb: 207, 54, 0
	density = 0.898
	specheatcap = 3.58
	custom_metabolism = 0.01 //so it lasts 10x as long as regular minttox
	var/fatgokaboom = TRUE
	nutriment_factor = 2.5 * REAGENTS_METABOLISM //about as nutritious as sugar
	sport = SPORTINESS_SUGAR //a small performance boost from being COOL AND FRESH
	var/chillcounter = 0

/datum/reagent/minttoxin/on_mob_life(var/mob/living/M, var/alien)
	if(..())
		return 1

	if(prob(5))
		to_chat(M, "<span class='notice'>[pick("You feel minty fresh!","If freshness could kill you'd be a serial killer!","You feel the strange urge to share this minty freshness with others!","You have a sudden craving to drink ice cold water.","Ahh, so refreshing!")]</span>")

	if(M.bodytemperature > 310) //copypasted from the cold drinks check so I don't have to change minttox internally and maybe most certainly break shit in the process
		M.bodytemperature = max(310, M.bodytemperature + (-5 * TEMPERATURE_DAMAGE_COEFFICIENT)) //that minty freshness my dude, chill out

	if(fatgokaboom && (M_FAT in M.mutations))
		M.gib()

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(holder.has_any_reagents(COLDDRINKS) & prob(25))
			var/datum/butchering_product/teeth/J = locate(/datum/butchering_product/teeth) in H.butchering_drops
			if(J.amount == 0)
				return
			else
				H.custom_pain(pick("AHHH YOUR TEETH HURT!","You didn't know you had a cavity. You do now.","DAMN YOUR TEETH HURT"),5)
				holder.add_reagent(SACID,1) //just a smidgeon
				chillcounter = 30 //60 seconds

		if(chillcounter > 0)
			chillcounter--
			if(holder.has_any_reagents(HOTDRINKS) & prob(30))
				var/datum/butchering_product/teeth/J = locate(/datum/butchering_product/teeth) in H.butchering_drops
				if(J.amount == 0)
					return
				else
					J.amount = 0
					H.custom_pain("Your teeth crack and tremble before breaking all of a sudden! THE PAIN!", 100) //you dun fucked up lad
					H.visible_message("<span class='warning'>[H]'s teeth start cracking and suddenly explode! That must hurt.</span>")
					H.pain_level = 2 * BASE_CARBON_PAIN_RESIST //so you go into shock from pain
					playsound(H, 'sound/effects/toothshatter.ogg', 50, 1)
					H.audible_scream()
					H.adjustBruteLoss(50) //imagine all your teeth violently exploding, shrapnel and shit

/datum/reagent/minttoxin/essence
	name = "Mint Essence"
	id = MINTESSENCE
	description = "Minty freshness in liquid form!"
	custom_metabolism = 0.1 //toxin lasts 10x as long
	fatgokaboom = FALSE

/datum/reagent/mutagen
	name = "Unstable Mutagen"
	id = MUTAGEN
	description = "Might cause unpredictable mutations. Keep away from children."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#13BC5E" //rgb: 19, 188, 94
	density = 3.35
	specheatcap = 0.09686

/datum/reagent/mutagen/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return 1

	if(!M.dna) //No robots, AIs, aliens, Ians or other mobs should be affected by this.
		return
	if((method == TOUCH && prob(33)) || method == INGEST)
		if(prob(98))
			randmutb(M)
		else
			randmutg(M)
		domutcheck(M, null)
		if(M.last_appearance_mutation + 1 SECONDS < world.time)
			randmuti(M)
			M.UpdateAppearance()

/datum/reagent/mutagen/on_mob_life(var/mob/living/M)
	if(!M.dna)
		return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	if(!M)
		M = holder.my_atom
	if(..())
		return 1
	M.apply_radiation(10,RAD_INTERNAL)

/datum/reagent/mutagen/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	if(!holder)
		return
	if(!T)
		T = holder.my_atom //Try to find the mob through the holder
	if(!istype(T)) //Still can't find it, abort
		return
	var/amount = T.reagents.get_reagent_amount(id)
	if(amount >= 1)
		if(prob(15))
			T.mutate(GENE_PHYTOCHEMISTRY)
			T.reagents.remove_reagent(id, 1)
	else if(amount > 0)
		T.reagents.remove_reagent(id, amount)

/datum/reagent/mutagen/untable
	name = "Untable Mutagen"
	id = UNTABLE_MUTAGEN
	description = "Untable Mutagen is a substance that is highly corrosive to tables."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#84121D" //rgb: 132, 18, 29
	overdose_am = REAGENTS_OVERDOSE

/datum/reagent/mutagen/untable/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()

/datum/reagent/mutagen/untable/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	if(!(O.dissolvable() == PACID))
		return

	if(istype(O,/obj/structure/table))
		var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
		I.desc = "Looks like this was \an [O] some time ago."
		O.visible_message("<span class='warning'>\The [O] melts.</span>")
		qdel(O)

/datum/reagent/nanites
	name = "Nanites"
	id = NANITES
	description = "Microscopic construction robots."
	reagent_state = REAGENT_STATE_SOLID
	dupeable = FALSE
	color = "#535E66" //rgb: 83, 94, 102
	var/disease_type = DISEASE_CYBORG

/datum/reagent/nanites/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return 1

	if((prob(10) && method == TOUCH) || method == INGEST)
		M.infect_disease2_predefined(disease_type, 1, "Robotic Nanites")

/datum/reagent/nanites/reaction_dropper_mob(var/mob/living/M)
	if(prob(30))
		M.infect_disease2_predefined(disease_type, 1, "Robotic Nanites")
	return ..()

/datum/reagent/nanites/autist
	name = "Autist Nanites"
	id = AUTISTNANITES
	description = "Microscopic construction robots. They look more autistic than usual."
	disease_type = DISEASE_MOMMI

/datum/reagent/potassium_hydroxide
	name = "Potassium Hydroxide"
	id = POTASSIUM_HYDROXIDE
	description = "A corrosive chemical used in making soap and batteries."
	reagent_state = REAGENT_STATE_SOLID
	overdose_am = REAGENTS_OVERDOSE
	custom_metabolism = 0.1
	color = "#ffffff" //rgb: 255, 255, 255
	density = 2.12
	specheatcap = 65.87 //how much energy in joules it takes to heat this thing up by 1 degree (J/g). round to 2dp

/datum/reagent/potassium_hydroxide/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.adjustFireLoss(1.5 * REM)

/datum/reagent/slimetoxin
	name = "Mutation Toxin"
	id = MUTATIONTOXIN
	description = "A corruptive toxin produced by slimes."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#13BC5E" //rgb: 19, 188, 94
	overdose_am = REAGENTS_OVERDOSE
	density = 1.245
	specheatcap = 0.25

/datum/reagent/slimetoxin/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ismanifested(M))
		to_chat(M, "<span class='warning'>You can feel intriguing reagents seeping into your body, but they don't seem to react at all.</span>")
		M.reagents.del_reagent("mutationtoxin")

	if(ishuman(M))

		var/mob/living/carbon/human/human = M
		if(!isslimeperson(human))

			to_chat(M, "<span class='warning'>Your flesh rapidly mutates!</span>")
			human.set_species("Slime")

			human.regenerate_icons()

			//Let the player choose their new appearance
			var/list/species_hair = valid_sprite_accessories(hair_styles_list, null, (human.species.name || null))
			if(human.my_appearance.f_style && species_hair.len)
				var/new_hstyle = input(M, "Select an ooze style", "Grooming")  as null|anything in species_hair
				if(new_hstyle)
					human.my_appearance.h_style = new_hstyle

			var/list/species_facial_hair = valid_sprite_accessories(facial_hair_styles_list, null, (human.species.name || null))
			if(human.my_appearance.f_style && species_facial_hair.len)
				var/new_fstyle = input(M, "Select a facial ooze style", "Grooming")  as null|anything in species_facial_hair
				if(new_fstyle)
					human.my_appearance.f_style = new_fstyle

			//Slime hair color is just darkened slime skin color (for now)
			human.my_appearance.r_hair = round(human.multicolor_skin_r * 0.8)
			human.my_appearance.g_hair = round(human.multicolor_skin_g * 0.8)
			human.my_appearance.b_hair = round(human.multicolor_skin_b * 0.8)

			human.regenerate_icons()
			M.setCloneLoss(0)

/datum/reagent/spiritbreaker
	name = "Spiritbreaker Toxin"
	id = SPIRITBREAKER
	description = "An extremely dangerous hallucinogen often used for torture. Extracted from the leaves of the rare Ambrosia Cruciatus plant."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#3B0805" //rgb: 59, 8, 5
	custom_metabolism = 0.05

/datum/reagent/spiritbreaker/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(tick >= 165)
		M.adjustToxLoss(0.2)
		M.adjustBrainLoss(5)
		M.hallucination += 100
		M.dizziness += 100
		M.confused += 2

/datum/reagent/stoxin
	name = "Sleep Toxin"
	id = STOXIN
	description = "An effective hypnotic used to treat insomnia."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#E895CC" //rgb: 232, 149, 204
	custom_metabolism = 0.1
	density = 3.56
	specheatcap = 17.15
	overdose_am = REAGENTS_OVERDOSE // So you can't pretend that you "didn't know it was an OD"

/datum/reagent/stoxin/on_mob_life(var/mob/living/M, var/alien)
	if(..())
		return 1

	switch(tick)
		if(1 to 15)
			M.eye_blurry = max(M.eye_blurry, 10)
		if(15 to 25)
			M.drowsyness  = max(M.drowsyness, 20)
		if (25 to 240)
			M.Paralyse(20)
			M.drowsyness  = max(M.drowsyness, 30)
		if(240 to INFINITY) // 8 minutes
			var/mob/living/carbon/human/H = M
			var/datum/organ/internal/heart/damagedheart = H.get_heart()
			damagedheart.damage += 10

/datum/reagent/suxameth
	name = "Suxameth"
	id = SUX
	description = "A name for Suxamethonium chloride. A medical full-body paralytic preferred because it is easy to purge."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#CFC5E9" //rgb: 207, 197, 223
	flags = CHEMFLAG_DISHONORABLE
	overdose_am = 21
	custom_metabolism = 1

/datum/reagent/suxameth/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(tick >= 2)
		M.SetStunned(2)
		M.SetKnockdown(2)

/datum/reagent/suxameth/on_overdose(var/mob/living/M)
	M.adjustOxyLoss(6) //Paralyzes the diaphragm if they go over 20 units

/datum/reagent/toxin
	name = "Toxin"
	id = TOXIN
	description = "A Toxic chemical."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#CF3600" //rgb: 207, 54, 0
	custom_metabolism = 0.01
	density = 1.4 //Let's just assume it's alpha-solanine

/datum/reagent/toxin/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	//Toxins are really weak, but without being treated, last very long
	M.adjustToxLoss(0.2)

/datum/reagent/toxin/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_toxinlevel(2)

/datum/reagent/xenomicrobes
	name = "Xenomicrobes"
	id = XENOMICROBES
	description = "Microbes with an entirely alien cellular structure."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#535E66" //rgb: 83, 94, 102

/datum/reagent/xenomicrobes/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return 1
	if((prob(10) && method == TOUCH) || method == INGEST)
		M.infect_disease2_predefined(DISEASE_XENO, 1, "Xenimicrobes")

/datum/reagent/xenomicrobes/reaction_dropper_mob(var/mob/living/M)
	if(prob(30))
		M.infect_disease2_predefined(DISEASE_XENO, 1, "Xenimicrobes")
	return ..()

/datum/reagent/zombiepowder
	name = "Zombie Powder"
	id = ZOMBIEPOWDER
	description = "A strong neurotoxin that puts the subject into a death-like state."
	color = "#669900" //rgb: 102, 153, 0
	density = 829.48
	specheatcap = 274.21

/datum/reagent/zombiepowder/on_mob_life(var/mob/living/carbon/M)
	if(..())
		return 1

	if(volume >= 1) //Hotfix for Fakedeath never ending.
		M.status_flags |= FAKEDEATH
	else
		M.status_flags &= ~FAKEDEATH
	M.adjustOxyLoss(0.5 * REM)
	M.adjustToxLoss(0.5 * REM)
	M.Knockdown(10)
	M.Stun(10)
	M.silent = max(M.silent, 10)
	M.tod = worldtime2text()

/datum/reagent/zombiepowder/reagent_deleted()
	return on_removal(volume)

//Hotfix for Fakedeath never ending.
/datum/reagent/zombiepowder/on_removal(var/amount)
	if(!..(amount))
		return 0

	var/newvol = max(0, volume - amount)
	if(iscarbon(holder.my_atom))
		var/mob/living/carbon/M = holder.my_atom
		if(newvol >= 1)
			M.status_flags |= FAKEDEATH
		else
			M.status_flags &= ~FAKEDEATH
	return 1
