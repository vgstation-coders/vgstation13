//Food-related reagents

/datum/reagent/blackcolor
	name = "Black Food Coloring"
	id = BLACKCOLOR
	description = "A black coloring used to dye food and drinks."
	reagent_state = REAGENT_STATE_LIQUID
	flags = CHEMFLAG_OBSCURING|CHEMFLAG_PIGMENT
	color = "#000000" //rgb: 0, 0, 0

/datum/reagent/blackpepper
	name = "Black Pepper"
	id = BLACKPEPPER
	description = "A powder ground from peppercorns. *AAAACHOOO*"
	reagent_state = REAGENT_STATE_SOLID
	color = "#664C3E" //rgb: 40, 30, 24

/datum/reagent/blackpepper/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1
	if(!T.has_dense_content() && volume >= 10 && !(locate(/obj/effect/decal/cleanable/pepper) in T))
		new /obj/effect/decal/cleanable/pepper(T)

/datum/reagent/blockizine
	name = "Blockizine"
	id = BLOCKIZINE
	description = "Some type of material that preferentially binds to all possible chemical receptors in the body, but without any direct negative effects."
	reagent_state = REAGENT_STATE_LIQUID
	custom_metabolism = 0
	color = "#B0B0B0"

/datum/reagent/blockizine/on_mob_life(var/mob/living/carbon/human/H)
	if(..())
		return 1
	if(!data)
		data = world.time+3000
	if(world.time > data)
		holder.del_reagent(BLOCKIZINE,volume) //needs to be del_reagent, because metabolism is 0
		return

	if(istype(H) && volume >= 25)
		holder.isolate_reagent(BLOCKIZINE)
		volume = holder.maximum_volume
		holder.update_total()

/datum/reagent/bluegoo
	name = "Blue Goo"
	id = BLUEGOO
	description = "A viscous blue substance of unknown origin."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#64D2E6"
	custom_metabolism = 0.01

/datum/reagent/bluegoo/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(prob(2))
		if(prob(75))
			to_chat(M, "<span class='notice'>[pick("The mothership is always watching.","All hail the Chairman.","You should buy more Zam snacks.","You would love to get some alien tissue samples under a microscope.","You feel exceptionally loyal to the mothership.","You feel the mothership's psychic presence.","The mothership will ensure your prosperity.","Maybe the commissary will dispense extra ration vouchers this cloning cycle.","Humans really do behave like apes sometimes.","A refreshing sip of acid would be delightful.")]</span>")
		else
			M.say(pick("Praise the mothership!", "Be productive this quarter, fellow denizens.", "Grey minds are naturally superior.", "I work for the happiness of all greykind.", "Alert the local battalion about any socially unstable behavior."))

/datum/reagent/capsaicin
	name = "Capsaicin Oil"
	id = CAPSAICIN
	description = "This is what makes chilis hot."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#B31008" //rgb: 179, 16, 8
	custom_metabolism = FOOD_METABOLISM
	density = 0.53
	specheatcap = 3.49

/datum/reagent/capsaicin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(5))
		to_chat(M,"<span class='notice'>Your face feels a little hot!</span>")

	var/mob/living/carbon/human/H
	if(ishuman(M))
		H = M
	switch(tick)
		if(1 to 15)
			M.bodytemperature += 0.6 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent("frostoil"))
				holder.remove_reagent("frostoil", 5)
			if(isslime(M))
				M.bodytemperature += rand(5,20)
			if(isslimeperson(H))
				M.bodytemperature += rand(5,20)
		if(15 to 25)
			M.bodytemperature += 0.9 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature += rand(10,20)
			if(isslimeperson(H))
				M.bodytemperature += rand(10,20)
		if(25 to INFINITY)
			M.bodytemperature += 1.2 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature += rand(15,20)
			if(isslimeperson(H))
				M.bodytemperature += rand(15,20)

/datum/reagent/caramel
	name = "Caramel"
	id = CARAMEL
	description = "Created from the removal of water from sugar."
	reagent_state = REAGENT_STATE_SOLID
	color = "#844b06" //rgb: 132, 75, 6
	nutriment_factor = 5 * REAGENTS_METABOLISM
	specheatcap = 1.244
	density = 1.59

/datum/reagent/cheesygloop
	name = "Cheesy Gloop"
	id = CHEESYGLOOP
	description = "This fatty, viscous substance is found only within the cheesiest of cheeses. Has the potential to cause heart stoppage."
	reagent_state = REAGENT_STATE_SOLID
	color = "#FFFF00" //rgb: 255, 255, 0
	overdose_am = 5
	custom_metabolism = 0 //does not leave your body, clogs your arteries! puke or otherwise clear your system ASAP
	density = 0.14
	specheatcap = 0.7

/datum/reagent/cheesygloop/on_overdose(var/mob/living/M)
	M.adjustToxLoss(1)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/heart/damagedheart = H.get_heart()
		damagedheart.damage++

/datum/reagent/cherryjelly
	name = "Cherry Jelly"
	id = CHERRYJELLY
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#801E28" //rgb: 128, 30, 40

/datum/reagent/cherryjelly/on_mob_life(var/mob/living/M)
	if(..())
		return 1

/datum/reagent/cinnamon
	name = "Cinnamon Powder"
	id = CINNAMON
	description = "A spice, obtained from the bark of cinnamomum trees."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#D2691E" //rgb: 210, 105, 30

/datum/reagent/coco
	name = "Coco Powder"
	id = COCO
	description = "A fatty, bitter paste made from coco beans."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" //rgb: 48, 32, 0

/datum/reagent/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = CONDENSEDCAPSAICIN
	description = "This shit goes in pepperspray."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#B31008" //rgb: 179, 16, 8
	density = 0.9
	specheatcap = 8.59

/datum/reagent/condensedcapsaicin/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)

	if(..())
		return 1

	if(method == TOUCH && ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/mouth_covered = H.get_body_part_coverage(MOUTH)
		var/obj/item/eyes_covered = H.get_body_part_coverage(EYES)
		if(eyes_covered && mouth_covered)
			H << "<span class='warning'>Your [mouth_covered == eyes_covered ? "[mouth_covered] protects" : "[mouth_covered] and [eyes_covered] protect"] you from the pepperspray!</span>"
			return
		else if(mouth_covered)	//Reduced effects if partially protected
			H << "<span class='warning'>Your [mouth_covered] protects your mouth from the pepperspray!</span>"
			H.eye_blurry = max(M.eye_blurry, 15)
			H.eye_blind = max(M.eye_blind, 5)
			H.Paralyse(1)
			H.drop_item()
			return
		else if(eyes_covered) //Eye cover is better than mouth cover
			H << "<span class='warning'>Your [eyes_covered] protects your eyes from the pepperspray!</span>"
			H.audible_scream()
			H.eye_blurry = max(M.eye_blurry, 5)
			return
		else //Oh dear
			H.audible_scream()
			to_chat(H, "<span class='danger'>You are sprayed directly in the eyes with pepperspray!</span>")
			H.eye_blurry = max(M.eye_blurry, 25)
			H.eye_blind = max(M.eye_blind, 10)
			H.Paralyse(1)
			H.drop_item()

/datum/reagent/condensedcapsaicin/reaction_dropper_mob(var/mob/living/M)
	M.audible_scream()
	to_chat(M, "<span class='danger'>Pure solid peppespray is dropped directly in your eyes!</span>")
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.eye_blurry = max(M.eye_blurry, 25)
		H.eye_blind = max(M.eye_blind, 10)
		H.Paralyse(1)
		H.drop_item()
	return ..()

/datum/reagent/condensedcapsaicin/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(prob(5))
		to_chat(M,"<span class='notice'>Your face feels like it's on fire!</span>")
		M.visible_message("<span class='warning'>[M] [pick("dry heaves!", "coughs!", "splutters!")]</span>")

	//let's just copy capsaicin/on_mob_life does, but make it worse.
	var/mob/living/carbon/human/H
	if(ishuman(M))
		H = M
	switch(tick)
		if(1 to 15)
			M.bodytemperature += 0.9 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent("frostoil"))
				holder.remove_reagent("frostoil", 5)
			if(isslime(M))
				M.bodytemperature += rand(10,20)
			if(isslimeperson(H))
				M.bodytemperature += rand(10,20)
		if(15 to 30)
			M.bodytemperature += 1.1 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(prob(6))//Start vomiting
				H.vomit(0,1)
			if(isslime(M))
				M.bodytemperature += rand(20,25)
			if(isslimeperson(H))
				M.bodytemperature += rand(20,25)
		if(30 to 45)//Reagent dies out at about 50. Set up the vomiting to "fade out".
			if(prob(9))
				H.vomit()

/datum/reagent/cornoil
	name = "Corn Oil"
	id = CORNOIL
	description = "An oil derived from various types of corn."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 20 * REAGENTS_METABOLISM
	color = "#302000" //rgb: 48, 32, 0
	density = 0.9185
	specheatcap = 2.402
	var/has_had_heart_explode = 0

/datum/reagent/cornoil/on_mob_life(var/mob/living/M)

	if(..())
		return 1

//Now handle corn oil interactions
	if(!has_had_heart_explode && ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/heart/heart = H.internal_organs_by_name["heart"]
		switch(volume)
			if(1 to 15)
				if(prob(5))
					H.emote("me", 1, "burps.")
					holder.remove_reagent(id, 0.1 * FOOD_METABOLISM)
			if(15 to 100)
				if(prob(10))
					to_chat(H,"<span class='warning'>You really don't feel very good.</span>")
				if(prob(5))
					if(heart && !heart.robotic)
						to_chat(H,"<span class='warning'>You feel a burn in your chest.</span>")
						heart.take_damage(0.2, 1)
			if(100 to INFINITY)//Too much corn oil holy shit, no one should ever get this high
				if(heart && !heart.robotic)
					to_chat(H, "<span class='danger'>You feel a terrible pain in your chest!</span>")
					has_had_heart_explode = 1 //That way it doesn't blow up any new transplant hearts
					qdel(H.remove_internal_organ(H,heart,H.get_organ(LIMB_CHEST)))
					H.adjustOxyLoss(60)
					H.adjustBruteLoss(30)

/datum/reagent/cornoil/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1

	if(volume >= 3)
		T.wet(800)
	var/hotspot = (locate(/obj/effect/fire) in T)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = T.remove_air(T:air:total_moles())
		lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2), 0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)

/datum/reagent/diabeetusol
	name = "Diabeetusol"
	id = DIABEETUSOL
	description = "The mistaken byproduct of confectionery science. Targets the beta pancreatic cells, or equivalent, in carbon based life to not only cease insulin production but begin producing what medical science can only describe as 'the concept of obesity given tangible form'."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFFFFF" //rgb: 255, 255, 255
	nutriment_factor = 0 //Custom nutrition effect on_mob_life, scales on volume
	sport = 0 //This will never come up but adding it made me smile
	density = 3 //He DENSE
	specheatcap = 0.55536
	overdose_am = 30
	custom_metabolism = 0.05

/datum/reagent/diabeetusol/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/heart/heart = H.internal_organs_by_name["heart"]
		var/static/list/chubbysound = list('sound/instruments/trombone/Eb3.mid', 'sound/instruments/trombone/Gb2.mid', 'sound/instruments/trombone/Bb3.mid')
		var/sugarUnits = H.reagents.get_reagent_amount(SUGAR)
		if(sugarUnits < volume)
			if(prob(volume*30))
				playsound(H, pick(chubbysound), 50, 1)
				H.confused += 2
				H.eye_blurry += 2
				H.dizziness += 2
			if(prob(volume*5))
				H.sleeping++
		else
			playsound(H, pick(chubbysound), 100, 1)
			H.overeatduration += 10 * volume
			H.nutrition += 10 * volume //to compare, the holy liquid butter would be 5 here
		if(H.nutrition > 750)
			if(prob(volume) && heart && !heart.robotic)
				to_chat(H, "<span class='danger'>Your heart just can't take it anymore!</span>")
				qdel(H.remove_internal_organ(H,heart,H.get_organ(LIMB_CHEST)))
				H.adjustOxyLoss(60)
				H.adjustBruteLoss(30)

/datum/reagent/dipping_sauce
	name = "Dipping Sauce"
	id = DIPPING_SAUCE
	description = "Adds extra, delicious texture to a snack."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#33cc33" //rgb: 51, 204, 51

/datum/reagent/dry_ramen
	name = "Dry Ramen"
	id = DRY_RAMEN
	description = "Space age food, since August 25, 1958. Contains dried noodles and vegetables, best cooked in boiling water."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = REAGENTS_METABOLISM
	color = "#302000" //rgb: 48, 32, 0

/datum/reagent/dry_ramen/on_mob_life(var/mob/living/M)
	if(..())
		return 1

/datum/reagent/egg_yolk
	name = "Egg Yolk"
	id = EGG_YOLK
	description = "A chicken before it could become a chicken."
	nutriment_factor = 15 * REAGENTS_METABOLISM
	reagent_state = REAGENT_STATE_LIQUID
	color = "#ffcd42"

/datum/reagent/enzyme
	name = "Universal Enzyme"
	id = ENZYME
	description = "A universal enzyme used in the preperation of certain chemicals and foods."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#365E30" //rgb: 54, 94, 48
	density = 9.68
	specheatcap = 1.0101

/datum/reagent/fishbleach
	name = "Fish Bleach"
	id = FISHBLEACH
	description = "Just looking at this liquid makes you feel tranquil and peaceful. You aren't sure if you want to drink any however."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#12A7C9"

/datum/reagent/fishbleach/on_mob_life(var/mob/living/carbon/human/H)
	if(..())
		return 1
	H.color = "#12A7C9"
	return

/datum/reagent/flour
	name = "Flour"
	id = FLOUR
	description = "This is what you rub all over yourself to pretend to be a ghost."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = REAGENTS_METABOLISM
	color = "#FFFFFF" //rgb: 0, 0, 0

/datum/reagent/flour/on_mob_life(var/mob/living/M)
	if(..())
		return 1

/datum/reagent/flour/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1

	if(!(locate(/obj/effect/decal/cleanable/flour) in T))
		new /obj/effect/decal/cleanable/flour(T)

/datum/reagent/flour/nova_flour
	name = "Nova Flour"
	id = NOVAFLOUR
	description = "This is what you rub all over yourself to set on fire."
	color = "#B22222" //rgb: 178, 34, 34

/datum/reagent/flour/nova_flour/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.bodytemperature += 3 * TEMPERATURE_DAMAGE_COEFFICIENT

/datum/reagent/frostoil
	name = "Frost Oil"
	id = FROSTOIL
	description = "A special oil that noticeably chills the body. Extraced from Icepeppers."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#8BA6E9" //rgb: 139, 166, 233
	custom_metabolism = FOOD_METABOLISM

/datum/reagent/frostoil/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	var/mob/living/carbon/human/H
	if(ishuman(M))
		H = M
	switch(tick)
		if(1 to 15)
			M.bodytemperature = max(M.bodytemperature-0.3 * TEMPERATURE_DAMAGE_COEFFICIENT,T20C)
			if(holder.has_reagent("capsaicin"))
				holder.remove_reagent("capsaicin", 5)
			if(isslime(M))
				M.bodytemperature -= rand(5,20)
			if(isslimeperson(H))
				M.bodytemperature -= rand(5,20)
		if(15 to 25)
			M.bodytemperature = max(M.bodytemperature-0.6 * TEMPERATURE_DAMAGE_COEFFICIENT,T20C)
			if(isslime(M))
				M.bodytemperature -= rand(10,20)
			if(isslimeperson(H))
				M.bodytemperature -= rand(10,20)
		if(25 to INFINITY)
			M.bodytemperature = max(M.bodytemperature-0.9 * TEMPERATURE_DAMAGE_COEFFICIENT,T20C)
			if(prob(1))
				M.emote("shiver")
			if(isslime(M))
				M.bodytemperature -= rand(15,20)
			if(isslimeperson(H))
				M.bodytemperature -= rand(15,20)

/datum/reagent/frostoil/reaction_turf(var/turf/simulated/T, var/volume)

	if(..())
		return 1

	for(var/mob/living/carbon/slime/M in T)
		M.adjustToxLoss(rand(15, 30))
	for(var/mob/living/carbon/human/H in T)
		if(isslimeperson(H))
			H.adjustToxLoss(rand(5, 15))

/datum/reagent/frostoil/reaction_obj(var/obj/O, var/volume)

	if(..())
		return 1

	if(istype(O, /obj/item/organ/internal/heart/hivelord))
		var/obj/item/organ/internal/heart/hivelord/I = O
		if(I.health <= 0)
			I.revive()
			I.health = initial(I.health)
		if(I.organ_data)
			var/datum/organ/internal/OD = I.organ_data
			if(OD.damage > 0)
				OD.damage = 0

/datum/reagent/gravy
	name = "Gravy"
	id = GRAVY
	description = "Aww, come on Double D, I don't say 'gravy' all the time."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 10 * REAGENTS_METABOLISM
	color = "#E7A568"

/datum/reagent/gravy/on_mob_life(var/mob/living/M, var/alien)
	if(..())
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.name == "Vox")
			M.adjustToxLoss(-4 * REM) //chicken and gravy just go together

/datum/reagent/hell_ramen
	name = "Hell Ramen"
	id = HELL_RAMEN
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" //rgb: 48, 32, 0
	density = 1.42
	specheatcap = 14.59

/datum/reagent/hell_ramen/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT

/datum/reagent/honey
	name = "Honey"
	id = HONEY
	description = "A golden yellow syrup, loaded with sugary sweetness."
	color = "#FEAE00"
	alpha = 200
	nutriment_factor = 15 * REAGENTS_METABOLISM
	var/quality = 2
	density = 1.59
	specheatcap = 1.244

/datum/reagent/honey/on_mob_life(var/mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!holder)
			return
		if(H.getBruteLoss() && prob(60))
			H.heal_organ_damage(quality, 0)
		if(H.getFireLoss() && prob(50))
			H.heal_organ_damage(0, quality)
		if(H.getToxLoss() && prob(50))
			H.adjustToxLoss(-quality)
		..()

/datum/reagent/honey/royal_jelly
	name = "Royal Jelly"
	id = ROYALJELLY
	description = "A pale yellow liquid that is both spicy and acidic, yet also sweet."
	color = "#FFDA6A"
	alpha = 220
	nutriment_factor = 15 * REAGENTS_METABOLISM
	quality = 3

/datum/reagent/honey/chillwax
	name = "Chill Wax"
	id = CHILLWAX
	description = "A bluish wax produced by insects found on Vox worlds. Sweet to the taste, albeit trippy."
	color = "#4C78C1"
	alpha = 250
	nutriment_factor = 10 * REAGENTS_METABOLISM
	density = 1.59
	quality = 1
	specheatcap = 1.244

/datum/reagent/honey/chillwax/on_mob_life(var/mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.druggy = max(H.druggy, 5)
		H.Dizzy(2)
		if(prob(10))
			H.emote(pick("stare", "giggle"), null, null, TRUE)
		if(prob(5))
			to_chat(H, "<span class='notice'>[pick("You feel at peace with the world.","Everyone is nice, everything is awesome.","You feel high and ecstatic.")]</span>")
		..()

/datum/reagent/hot_ramen
	name = "Hot Ramen"
	id = HOT_RAMEN
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" //rgb: 48, 32, 0
	density = 1.33
	specheatcap = 4.18

/datum/reagent/hot_ramen/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(M.bodytemperature < 310) //310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (10 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/ketchup
	name = "Ketchup"
	id = KETCHUP
	description = "Ketchup, catsup, whatever. It's tomato paste."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#731008" //rgb: 115, 16, 8
	flags = CHEMFLAG_PIGMENT

/datum/reagent/ketchup/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/condiment/fake_bottle/FB = new(O.loc)
		FB.splash_that(O,src)

/datum/reagent/liquidbutter
	name ="Liquid Butter"
	id = LIQUIDBUTTER
	description = "A lipid heavy liquid, that's likely to make your fad lipozine diet fail."
	color = "#DFDFDF"
	nutriment_factor = 25 * REAGENTS_METABOLISM

/datum/reagent/liquidbutter/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(holder.has_reagent(LIPOZINE))
		holder.remove_reagent(LIPOZINE, 50)

/datum/reagent/maplesyrup
	name = "Maple Syrup"
	id = MAPLESYRUP
	description = "Reddish brown Canadian maple syrup, perfectly sweet and thick. Nutritious and effective at healing."
	color = "#7C1C04"
	alpha = 200
	nutriment_factor = 20 * REAGENTS_METABOLISM

/datum/reagent/maplesyrup/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.adjustOxyLoss(-2 * REM)
	M.adjustToxLoss(-2 * REM)
	M.adjustBruteLoss(-3 * REM)
	M.adjustFireLoss(-3 * REM)

/datum/reagent/mayo
	name = "Mayonnaise"
	id = MAYO
	description = "A substance of unspeakable suffering."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 4 * REAGENTS_METABOLISM
	color = "#FAF0E6" //rgb: 51, 102, 0
	flags = CHEMFLAG_PIGMENT

/datum/reagent/mayo/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/condiment/fake_bottle/FB = new(O.loc)
		FB.splash_that(O,src)

/datum/reagent/mediumcores
	name = "Medium-Salted Cores"
	id = MEDCORES
	description = "A derivative of the chemical known as 'Hardcores', easier to mass produce, but at a cost of quality."
	reagent_state = REAGENT_STATE_SOLID
	color = "#FFA500"
	custom_metabolism = 0.1

/datum/reagent/muhhardcores
	name = "Hardcores"
	id = BUSTANUT
	description = "Concentrated hardcore beliefs."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFF000"
	custom_metabolism = 0.01

/datum/reagent/muhhardcores/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(prob(1))
		if(prob(90))
			to_chat(M, "<span class='notice'>[pick("You feel quite hardcore", "Coderbased is your god", "Fucking kickscammers Bustration will be the best")].")
		else
			M.say(pick("Muh hardcores.", "Falling down is a feature.", "Gorrillionaires and Booty Borgs when?"))

/datum/reagent/mustard
	name = "Mustard"
	id = MUSTARD
	description = "A spicy yellow paste."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#cccc33" //rgb: 204, 204, 51
	flags = CHEMFLAG_PIGMENT

/datum/reagent/mustard/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/condiment/fake_bottle/FB = new(O.loc)
		FB.splash_that(O,src)

/datum/reagent/mustard_powder
	name = "Mustard Powder"
	id = MUSTARD_POWDER
	description = "A deep yellow powder, unrelated the gas variant"
	nutriment_factor = 3 * REAGENTS_METABOLISM
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8D07D" // dark dirty yellow

/datum/reagent/nutriment
	name = "Nutriment"
	id = NUTRIMENT
	description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#664330" //rgb: 102, 67, 48
	density = 6.54
	specheatcap = 17.56

/datum/reagent/nutriment/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(prob(50))
		M.heal_organ_damage(1, 0)

/datum/reagent/nutriment/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_nutrientlevel(10)
	T.add_planthealth(1)

/datum/reagent/pancake_mix
	name = "Pancake Mix"
	id = PANCAKE
	description = "A mix of flour, milk, butter, and egg yolk. ready to be cooked into delicious pancakes."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#E6C968" //rgb: 90, 78, 40

/datum/reagent/pancake_mix/on_mob_life(var/mob/living/M)
	if(..())
		return 1

/datum/reagent/pancake_mix/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1

	if(!(locate(/obj/effect/decal/cleanable/flour) in T))
		var/obj/effect/decal/cleanable/flour/F = new (T)
		F.color = "#E6C968"

/datum/reagent/polypgelatin
	name = "Polyp Gelatin"
	id = POLYPGELATIN
	description = "An edible gelatinous liquid harvested from a space polyp. It's very mild in flavor, and surprisingly filling."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 10 * REAGENTS_METABOLISM
	color = "#00FFFF" //rgb: 211, 90, 13

/datum/reagent/polypgelatin/on_mob_life(var/mob/living/M)

	if(..())
		return 1

	if(M.getFireLoss() && prob(20))
		M.heal_organ_damage(0, 1)

/datum/reagent/polypgelatin/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_nutrientlevel(5)

/datum/reagent/potassiumcarbonate
	name = "Potassium Carbonate"
	//also known as banana potassium so your bananas don't explode
	id = POTASSIUMCARBONATE
	description = "A primary component of potash, usually acquired by reducing potassium-rich organics."
	reagent_state = REAGENT_STATE_SOLID
	color = "#A0A0A0"
	density = 2.43
	specheatcap = 0.96

/datum/reagent/relish
	name = "Relish"
	id = RELISH
	description = "A pickled cucumber jam. Tasty!"
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 4 * REAGENTS_METABOLISM
	color = "#336600" //rgb: 51, 102, 0

/datum/reagent/rice
	name = "Rice"
	id = RICE
	description = "Enjoy the great taste of nothing."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#FFFFFF" //rgb: 0, 0, 0

/datum/reagent/rice/on_mob_life(var/mob/living/M)
	if(..())
		return 1

/datum/reagent/rogan
	name = "Rogan"
	id = ROGAN
	description = "Smells older than your grandpa."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#0000FF"
	custom_metabolism = 0.01

/datum/reagent/rogan/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(prob(1))
		if(prob(42))
			to_chat(M, "<span class='notice'>[pick("Rogan?", "ROGAN.", "Food please.", "Wood please.", "Gold please.", "All hail, king of the losers!", "I'll beat you back to Age of Empires.", "Sure, blame it on your ISP.", "Start the game already!", "It is good to be the king.", "Long time, no siege.", "Nice town, I'll take it.", "Raiding party!", "Dadgum.", "Wololo.", "Attack an enemy now.", "Cease creating extra villagers.", "Create extra villagers.", "Build a navy.", "	Stop building a navy.", "Wait for my signal to attack.", "Build a wonder.", "Give me your extra resources.", "What age are you in?")]")
		else
			M.say("Rogan?")

/datum/reagent/sodiumchloride
	name = "Table Salt"
	id = SODIUMCHLORIDE
	description = "A salt made of sodium chloride. Commonly used to season food."
	reagent_state = REAGENT_STATE_SOLID
	color = "#FFFFFF" //rgb: 255, 255, 255
	density = 2.09
	specheatcap = 1.65

/datum/reagent/sodiumchloride/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1
	if(!T.has_dense_content() && volume >= 10 && !(locate(/obj/effect/decal/cleanable/salt) in T))
		if(!T.density)
			new /obj/effect/decal/cleanable/salt(T)


/datum/reagent/sodiumchloride/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	var/list/borers = M.get_brain_worms()
	if(borers)
		for(var/mob/living/simple_animal/borer/B in borers)
			B.health -= 1
			to_chat(B, "<span class='warning'>Something in your host's bloodstream burns you!</span>")

/datum/reagent/sodiumchloride/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_waterlevel(-5)
	T.add_nutrientlevel(5)
	T.add_toxinlevel(8)
	T.add_weedlevel(-20)
	T.add_pestlevel(-10)
	if(T.seed && !T.dead)
		T.add_planthealth(-2)

/datum/reagent/softcores
	name = "Softcores"
	id = SOFTCORES
	description = "Lesser known than its cheaper cousin in the popular snack 'mag-bites', softcores have all the benefits of chemical magnetism without the heart-stopping side effects."
	reagent_state = REAGENT_STATE_SOLID
	color = "#ff5100"
	custom_metabolism = 0.1

/datum/reagent/soysauce
	name = "Soysauce"
	id = SOYSAUCE
	description = "A salty sauce made from the soy plant."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#792300" //rgb: 121, 35, 0
	density = 1.17
	specheatcap = 1.38

/datum/reagent/spaghetti
	name = "Spaghetti"
	id = SPAGHETTI
	description = "Bursts into treats on consumption."
	nutriment_factor = 8 * REAGENTS_METABOLISM
	reagent_state = REAGENT_STATE_SOLID
	color = "#FFCD9A"

/datum/reagent/spaghetti/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(prob(80))
			H.apply_effect(1, STUTTER)
		else
			if(prob(50))
				H.Mute(1)
			else
				H.visible_message("<span class='notice'>[H] spills their spaghetti.</span>","<span class='notice'>You spill your spaghetti.</span>")
				var/turf/T = get_turf(M)
				new /obj/effect/decal/cleanable/spaghetti_spill(T)
				playsound(M, 'sound/effects/splat.ogg', 50, 1)

/datum/reagent/sprinkles
	name = "Sprinkles"
	id = SPRINKLES
	description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
	nutriment_factor = 0.5 * REAGENTS_METABOLISM
	color = "#FF00FF" //rgb: 255, 0, 255
	density = 1.59
	specheatcap = 1.24

/datum/reagent/sprinkles/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.job in list("Security Officer", "Head of Security", "Detective", "Warden"))
			H.heal_organ_damage(1, 1)
			H.nutrition += nutriment_factor //Double nutrition

/datum/reagent/sugar
	name = "Sugar"
	id = SUGAR
	description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
	reagent_state = REAGENT_STATE_SOLID
	color = "#FFFFFF" //rgb: 255, 255, 255
	nutriment_factor = 2.5 * REAGENTS_METABOLISM
	sport = SPORTINESS_SUGAR
	density = 1.59
	specheatcap = 1.244

/datum/reagent/sugar/on_plant_life(var/obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	T.add_nutrientlevel(1)
	T.add_pestlevel(20)
	T.add_weedlevel(20)

/datum/reagent/sugar/cornsyrup
	name = "High-Fructose Corn Syrup"
	id = CORNSYRUP
	description = "For when sugar needs to be produced on a budget, can become so prevalent that everyone will be made to drink it."

/*
//Removed because of meta bullshit. this is why we can't have nice things.
/datum/reagent/syndicream
	name = "Cream filling"
	id = SYNDICREAM
	description = "Delicious cream filling of a mysterious origin. Tastes criminally good."
	nutriment_factor = FOOD_METABOLISM
	color = "#AB7878" //RGB: 171, 120, 120
	custom_metabolism = FOOD_METABOLISM

/datum/reagent/syndicream/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.nutrition += REM * nutriment_factor
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.mind && H.mind.special_role)
			H.heal_organ_damage(1, 1)
			H.nutrition += REM * nutriment_factor
*/

/datum/reagent/tendies
	name = "Tendies"
	id = TENDIES
	description = "Gimme gimme chicken tendies, be they crispy or from Wendys."
	nutriment_factor = 0.5 * REAGENTS_METABOLISM
	color = "#AB6F0E" //rgb: 171, 111, 14
	density = 5
	specheatcap = 1

/datum/reagent/tendies/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.mind.assigned_role == "Janitor")
			H.heal_organ_damage(1, 1)
			H.nutrition += nutriment_factor //Double nutrition

//Eventually there will be a way of making vinegar.
/datum/reagent/vinegar
	name = "Vinegar"
	id = VINEGAR
	reagent_state = REAGENT_STATE_LIQUID
	color = "#3F1900" //rgb: 63, 25, 0
	density = 0.79
	specheatcap = 2.46

/datum/reagent/zamspices
	name = "Zam Spices"
	id = ZAMSPICES
	description = "A blend of several mothership spices. It has a sharp, tangy aroma."
	reagent_state = REAGENT_STATE_SOLID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#850E0E" //rgb: 133, 14, 14

/datum/reagent/zammild
	name = "Zam's Mild Sauce"
	id = ZAMMILD
	description = "A tasty sauce made from mothership spices and acid."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 4 * REAGENTS_METABOLISM
	color = "#B38B26" //rgb: 179, 139, 38

/datum/reagent/zamspicytoxin
	name = "Zam's Spicy Sauce"
	id = ZAMSPICYTOXIN
	description = "A dangerously flavorful sauce made from mothership spices and powerful acid."
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 6 * REAGENTS_METABOLISM
	color = "#D35A0D" //rgb: 211, 90, 13

/datum/reagent/zamspicytoxin/on_mob_life(var/mob/living/M, var/alien)

	if(..())
		return 1

	if(alien && alien == IS_GREY)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			M.bodytemperature += 1.4 * TEMPERATURE_DAMAGE_COEFFICIENT
			switch(volume)
				if(1 to 15)
					if(prob(10))
						to_chat(M,"<span class='notice'>Your throat feels a little hot!</span>")
					if(prob(5))
						to_chat(M,"<span class='notice'>[pick("Now that's a Zam zing!","By the mothership, that was a perfect spice level.","That was an excellent flavor.","Spicy goodness is flowing through your system.")]</span>")
				if(15 to 30)
					if(prob(10))
						to_chat(M,"<span class='notice'>Your throat feels like it's on fire!</span>")
						M.visible_message("<span class='warning'>[M] [pick("dry heaves!", "coughs!", "splutters!")]</span>")
					if(prob(5))
						to_chat(M,"<span class='warning'>[pick("That's a serious Zam zing!", "This is really starting to burn.", "The spice is overpowering the flavor.", "Spicy embers are starting to flare up in your chest.")]</span>")
					if(prob(5))
						to_chat(M,"<span class='warning'>You feel a slight burning in your chest.</span>")
						M.adjustToxLoss(1)
				if(30 to INFINITY)
					M.Jitter(5)
					if(prob(15))
						H.custom_pain("You feel an awful burning in your chest.",1)
						M.adjustToxLoss(3)
					if(prob(10))
						H.vomit()
					if(prob(5))
						to_chat(M,"<span class='warning'>[pick("That's way too much zing!", "By the mothership, that burns!", "You can't taste anything but flaming spice!", "There's a fire in your gut!")]</span>")
					if(prob(5))
						var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
						if(istype(L))
							L.take_damage(1, 0)

	else
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			M.bodytemperature += 1.6 * TEMPERATURE_DAMAGE_COEFFICIENT
			switch(volume)
				if(1 to 15)
					if(prob(10))
						to_chat(M,"<span class='notice'>Your throat feels like it's on fire!</span>")
						M.visible_message("<span class='warning'>[M] [pick("dry heaves!", "coughs!", "splutters!")]</span>")
					if(prob(5))
						to_chat(M,"<span class='warning'>You feel a slight burning in your chest.</span>")
						M.adjustToxLoss(1)
				if(15 to 30)
					M.Jitter(5)
					if(prob(15))
						H.custom_pain("You feel an awful burning in your chest.",1)
						M.adjustToxLoss(3)
					if(prob(10))
						H.vomit()
					if(prob(5))
						var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
						if(istype(L))
							L.take_damage(1, 0)
				if(30 to INFINITY)
					M.Jitter(5)
					if(prob(40))
						M.adjustToxLoss(6)
					if(prob(25))
						H.vomit()
					if(prob(15))
						var/datum/organ/internal/liver/L = H.internal_organs_by_name["liver"]
						if(istype(L))
							L.take_damage(5, 0)
					if(prob(10))
						H.custom_pain("Your chest feels like its on fire!",1)
						M.audible_scream()
