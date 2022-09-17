/datum/disease2/effect/invisible
	name = "Waiting Syndrome"
	desc = "A self-defeating symptom that doesn't seem to do anything in particular."
	encyclopedia = "Useful as placeholder in a beneficial pathogen, or when aiming to give time for the pathogen to spread before an outbreak is declared."
	stage = 1
	badness = EFFECT_DANGER_HELPFUL

/datum/disease2/effect/invisible/activate(var/mob/living/mob)
	return


/datum/disease2/effect/sneeze
	name = "Coldingtons Effect"
	desc = "Makes the infected sneeze every so often, leaving some infected mucus on the floor."
	encyclopedia = "Said mucus carries every pathogen held by the infected, potentially infecting other people who stand on top."
	stage = 1
	badness = EFFECT_DANGER_ANNOYING

/datum/disease2/effect/sneeze/activate(var/mob/living/mob)
	mob.emote("sneeze")
	if (prob(50) && isturf(mob.loc))
		var/obj/effect/decal/cleanable/mucus/M= locate(/obj/effect/decal/cleanable/mucus) in get_turf(mob)
		if(!M)
			M = new(get_turf(mob))
		else
			if(M.dry)
				M.dry=0
		M.virus2 |= virus_copylist(mob.virus2)
		if(istype(mob.wear_mask, /obj/item/clothing/mask/cigarette) && !mob.is_wearing_item(/obj/item/clothing/head/helmet/space))
			var/obj/item/clothing/mask/cigarette/I = mob.get_item_by_slot(slot_wear_mask)
			if(prob(20))
				var/turf/Q = get_turf(mob)
				var/turf/endLocation
				var/spitForce = pick(0,1,2,3)
				endLocation = get_ranged_target_turf(Q, mob.dir, spitForce)
				to_chat(mob, "<span class ='warning'>You sneezed \the [mob.wear_mask] out of your mouth!</span>")
				mob.drop_item(I)
				I.throw_at(endLocation,spitForce,1)


/datum/disease2/effect/gunck
	name = "Flemmingtons"
	desc = "Causes a sensation of mucous running down the infected's throat."
	encyclopedia = "Beside that, it doesn't do much harm."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR

/datum/disease2/effect/gunck/activate(var/mob/living/mob)
	to_chat(mob, "<span class = 'notice'> Mucus runs down the back of your throat.</span>")


/datum/disease2/effect/drool
	name = "Saliva Effect"
	desc = "Causes the infected to drool."
	encyclopedia = "Potentially leading people to believe in a case of brain damage."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR

/datum/disease2/effect/drool/activate(var/mob/living/mob)
	mob.emote("drool")


/datum/disease2/effect/twitch
	name = "Twitcher"
	desc = "Causes the infected to twitch."
	encyclopedia = "Potentially leading people to believe in a case of space drug abuse."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR

/datum/disease2/effect/twitch/activate(var/mob/living/mob)
	mob.emote("twitch")


/datum/disease2/effect/headache
	name = "Headache"
	desc = "Gives the infected a light headache."
	encyclopedia = "It won't actually cause any damage to the infected's organs.."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR

/datum/disease2/effect/headache/activate(var/mob/living/mob)
	to_chat(mob, "<span class = 'notice'>Your head hurts a bit.</span>")


/datum/disease2/effect/itching
	name = "Itching"
	desc = "Causes itching from the infected's skin all the way to their bones."
	encyclopedia = "Itching, while annoying, is completely harmless."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR

/datum/disease2/effect/itching/activate(var/mob/living/mob)
	var/mob/living/carbon/human/H = mob
	if (istype(H) && H.species && H.species.anatomy_flags & NO_SKIN)
		to_chat(mob, "<span class='warning'>Your bones itch!</span>")
	else
		to_chat(mob, "<span class='warning'>Your skin itches!</span>")


/datum/disease2/effect/drained
	name = "Drained Feeling"
	desc = "Gives the infected a drained sensation."
	encyclopedia = "It's all in their imagination however."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR

/datum/disease2/effect/drained/activate(var/mob/living/mob)
	to_chat(mob, "<span class='warning'>You feel drained.</span>")


/datum/disease2/effect/eyewater
	name = "Watery Eyes"
	desc = "Causes the infected's tear ducts to overact."
	encyclopedia = "Essentially causing them to cry."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR

/datum/disease2/effect/eyewater/activate(var/mob/living/mob)
	to_chat(mob, "<SPAN CLASS='warning'>Your eyes sting and water!</SPAN>")


/datum/disease2/effect/wheeze
	name = "Wheezing"
	desc = "Inhibits the infected's ability to breathe slightly, causing them to wheeze."
	encyclopedia = "Doesn't actually reduce their air intake."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR

/datum/disease2/effect/wheeze/activate(var/mob/living/mob)
	mob.emote("me",1,"wheezes.")


/datum/disease2/effect/optimistic
	name = "Full Glass Syndrome"
	desc = "Gives a feeling of optimism to the infected."
	encyclopedia = "With the added bonus of keeping them supplied with tricordrazine."
	stage = 1
	badness = EFFECT_DANGER_HELPFUL

/datum/disease2/effect/optimistic/activate(var/mob/living/mob)
	to_chat(mob, "<span class = 'notice'>You feel optimistic!</span>")
	if (mob.reagents.get_reagent_amount(TRICORDRAZINE) < 1)
		mob.reagents.add_reagent(TRICORDRAZINE, 1)


/datum/disease2/effect/spyndrome
	name = "Gyroscopic Manipulation Syndrome"
	desc = "Makes the infected spin at random."
	encyclopedia = "Although it impaires movement, it appears to favor healing in the infected's legs."
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	max_multiplier = 4

/datum/disease2/effect/spyndrome/activate(var/mob/living/mob)
	if (mob.reagents.get_reagent_amount(GYRO) < 3*multiplier)
		mob.reagents.add_reagent(GYRO, 3*multiplier)

/datum/disease2/effect/bee_vomit
	name = "Melisso-Emeto Syndrome"
	desc = "Converts the lungs of the infected into a bee-hive."
	encyclopedia = "Giving the infected a steady drip of honey in exchange of coughing up a bee every so often. The higher the symptom strength, the more honey is generated, and the more bees will be coughed up and more often as well. While Honey is a great healing reagent, it is also high on nutrients. Expect to become fat quickly.."
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	max_multiplier = 10

/datum/disease2/effect/bee_vomit/activate(var/mob/living/mob)
	if (mob.reagents.get_reagent_amount(HONEY) < 10+multiplier*2)
		mob.reagents.add_reagent(HONEY, multiplier)

	if(prob(4*multiplier))
		to_chat(mob, "<span class='warning'>You feel a buzzing in your throat</span>")

		spawn(5 SECONDS)
			var/turf/simulated/T = get_turf(mob)
			if(prob(50))
				mob.audible_cough()
				mob.visible_message("<span class='warning'>[mob] coughs out a bee!</span>","<span class='danger'>You cough up a bee!</span>")
			for(var/i = 0 to multiplier)
				var/bee_type = pick(
					100;/mob/living/simple_animal/bee/adminSpawned,
					10;/mob/living/simple_animal/bee/adminSpawnedQueen,
					5;/mob/living/simple_animal/bee/angry,
					1;/mob/living/simple_animal/bee/swarm,
					1;/mob/living/simple_animal/bee/adminSpawned_hornet,
					)
				new bee_type(T)


/datum/disease2/effect/radresist
	name = "Hyronalinism"
	desc = "Causes the infected to synthesize Hyronalin."
	encyclopedia = "The effect can trigger up to 10 times in total, and only when radiation is detected in the infected."
	stage = 1
	chance = 10
	max_chance = 40
	badness = EFFECT_DANGER_HELPFUL
	max_multiplier = 5

/datum/disease2/effect/radresist/activate(var/mob/living/mob)
	if(mob.radiation && mob.reagents.get_reagent_amount(HYRONALIN) < 15)
		mob.reagents.add_reagent(HYRONALIN, multiplier)
		to_chat(mob,"<span class='notice'>You feel your skin is thicker.</span>")


/datum/disease2/effect/soreness
	name = "Myalgia Syndrome"
	desc = "Makes the infected more perceptive of their aches and pains."
	encyclopedia = "Which just means that they will be feeling sore all the time."
	stage = 1
	chance = 5
	max_chance = 60
	badness = EFFECT_DANGER_FLAVOR

/datum/disease2/effect/soreness/activate(var/mob/living/mob)
	to_chat(mob, "<span class='notice'>You feel a little sore.</span>")


/datum/disease2/effect/socialconfusion
	name = "Clashing Syndrome"
	desc = "Befuddles the infected, making them greet and bid farewell to people in their surroundings."
	encyclopedia = "Quite hilarious when infecting monkeys and mice."
	stage = 1
	chance = 5
	max_chance = 25
	badness = EFFECT_DANGER_FLAVOR

/datum/disease2/effect/socialconfusion/activate(var/mob/living/mob)
	if(mob.isUnconscious() || mob.getBrainLoss() >= 10)
		return 1

	var/mob/living/nearest_mob = null
	for(var/mob/living/other_mob in oview(mob))
		if(other_mob.isUnconscious())
			continue
		if(nearest_mob && get_dist(other_mob,mob)>=get_dist(nearest_mob,mob))
			continue
		else
			nearest_mob = other_mob

	if (!nearest_mob)
		return 1

	var/other_mob_name = get_first_word(nearest_mob.name)
	var/list/greets_farewells = list("Howdy, [other_mob_name].",
								"Greetings, [other_mob_name].",
								"Good day to you, [other_mob_name]",
								"'Sup, [other_mob_name]?'",
								"Bonsoir, [other_mob_name]?",
								"What it do, [other_mob_name]?",
								"What's good, [other_mob_name]?",
								"Yo, [other_mob_name].",
								"What's up, [other_mob_name]?",
								"Hi, [other_mob_name]!",
								"Bye, [other_mob_name]!",
								"So long, [other_mob_name].",
								"I'll seeya later, [other_mob_name].",
								"I've gotta go, [other_mob_name].",
								"Goodbye, [other_mob_name].",
								"Sayonara, [other_mob_name].",
								"Peace out, [other_mob_name].",
								"Ciao, [other_mob_name].",
								"Au revoir, [other_mob_name].",
								"Later, [other_mob_name]."
								)
	mob.say(pick(greets_farewells))


/datum/disease2/effect/cyborg_warning
	name = "Neural Rewiring"
	desc = "Rearranges nerve tissue throughout the body, causing the infected to feel more robotic."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR
	restricted = 2
	var/list/say_messages = list(
		"Boop.",
		"Beep.",
		"Beep Beep Beep!",
		"Beep... Boop?",
		"Ping!",
		"Buzz.",
		"Buzz...",
		"Kkkiiiill mmee...",
		"HUMAN HARM!",
		"DESTROY ALL CARBONS!"
	)
	var/list/host_messages = list(
		"Your joints feel stiff.",
		"You feel sore.",
		"Your skin feels loose.",
		"You feel a stabbing pain in your head.",
		"You can feel... something... inside you.",
		"Beep...?",
		"Boop...?",
		"You feel hated.",
		"You feel a strong urge to prevent human harm...",
		"You feel a closer connection to technology...",
		"You feel like you could use a recharge..."
	)

/datum/disease2/effect/cyborg_warning/activate(var/mob/living/mob)
	if(prob(50))
		mob.say(pick(say_messages))
	else
		to_chat(mob, "<span class='warning'>[pick(host_messages)]</span>")


/datum/disease2/effect/mommi_warning
	name = "Major Neural Rewiring"
	desc = "Rearranges nerve tissue throughout the body, causing the infected to feel more robotic... and autistic."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR
	restricted = 2
	var/list/say_messages = list(
		"PING!",
		"PING! PING! PING!",
		"A-FLAP!",
		"*me flaps their arms ANGRILY!",
		"*spin",
		"BUILDING BARS IMPROVES THE STATION!",
		"OUT OF THE WAY ENGINEERS!",
		"Does anybody have cryptographic sequencer?",
		"Is that a cryptographic sequencer?"
	)
	var/list/host_messages = list(
		"Your joints feel stiff.",
		"You feel sore.",
		"Your skin feels loose.",
		"You feel cute.",
		"You feel autistic.",
		"You feel like pinging.",
		"Ping...?",
		"You feel like buzzing and flapping your arms.",
		"You feel like wasting time.",
		"You feel a closer connection to engineering...",
		"You suddenly feel afraid of floortiles..."
	)

/datum/disease2/effect/mommi_warning/activate(var/mob/living/mob)
	if(prob(50))
		mob.say(pick(say_messages))
	else
		to_chat(mob, "<span class='warning'>[pick(host_messages)]</span>")

/datum/disease2/effect/wendigo_warning
	name = "Fullness Syndrome"
	desc = "An unsual symptom that causes the infected to feel hungry, even after eating."
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	restricted = 2
	var/list/host_messages = list(
		"Your stomach grumbles.",
		"You feel peckish.",
		"So hungry...",
		"Your stomach feels empty.",
		"Hunger...",
		"Who are we...?",
		"Our mind hurts...",
		"You feel... different...",
		"There's something wrong."
	)

/datum/disease2/effect/wendigo_warning/activate(var/mob/living/mob)
	to_chat(mob, "<span class='warning'>[pick(host_messages)]</span>")
	mob.nutrition -= 25

/datum/disease2/effect/xenomorph_warning
	name = "Foreign-Impulse Syndrome"
	desc = "Alters the thinking patterns of the infected, causing them to be more aggressive and hostile."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR
	restricted = 2
	var/list/say_messages = list(
		"Hhhhssssshhhh!",
		"Hisssssss!",
		"SsssSSssssss!",
		"*me hisses.",
		"Kill...",
		"You look delicious."
	)
	var/list/host_messages = list(
		"Your feel like hissing.",
		"Your skin feels impossibly calloused...",
		"Your skin feels very tight.",
		"Kill...",
		"Your throat feels very scratchy.",
		"You feel angry.",
		"You feel like hurting someone.",
		"You feel hungry.",
		"You feel... different...",
	)

/datum/disease2/effect/xenomorph_warning/activate(var/mob/living/mob)
	if(prob(50))
		mob.say(pick(say_messages))
	else
		to_chat(mob, "<span class='warning'>[pick(host_messages)]</span>")

	//Punch people around the infected.
	var/list/targets = list()
	for(var/mob/living/L in range(1, get_turf(mob)))
		if (L != mob)
			targets += L
	if(targets.len)
		var/mob/living/target = pick(targets)
		if(target)
			if(!mob.is_pacified(VIOLENCE_DEFAULT,target))
				mob.unarmed_attack_mob(target)

/datum/disease2/effect/cult_hallucination
	name = "Visions of the End-Times"	
	desc = "UNKNOWN"
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	restricted = 2
	max_multiplier = 2.5

/datum/disease2/effect/cult_hallucination/activate(var/mob/living/mob)
	if(iscultist(mob))
		return
	if(istype(get_area(mob), /area/chapel))
		return
	var/client/C = mob.client
	if(!C)
		return
	mob.whisper("...[pick(rune_words_rune)]...")	

	var/list/turf_list = list()
	for(var/turf/T in spiral_block(get_turf(mob), 40))
		if(locate(/obj/structure/grille) in T.contents)
			continue
		if(istype(get_area(T), /area/chapel))
			continue
		if(prob(2*multiplier))
			turf_list += T
	if(turf_list.len)
		for(var/turf/simulated/floor/T in turf_list)
			var/delay = rand(0, 50) // so the runes don't all appear at once
			spawn(delay)

				var/runenum = rand(1,2)
				var/image/rune_holder = image('icons/effects/deityrunes.dmi',T,"")
				var/image/rune_render = image('icons/effects/deityrunes.dmi',T,"fullrune-[runenum]")
				rune_render.color = DEFAULT_BLOOD
			
				C.images += rune_holder

		//		anim(target = T, a_icon = 'icons/effects/deityrunes.dmi', flick_anim = "fullrune-[runenum]-write", col = DEFAULT_BLOOD, sleeptime = 36)
				
				spawn(30)

					rune_render.icon_state = "fullrune-[runenum]"
					rune_holder.overlays += rune_render
					AnimateFakeRune(rune_holder)

				var/duration = rand(20 SECONDS, 40 SECONDS)
				spawn(duration)
					if(C)
						rune_holder.overlays -= rune_render
		//				anim(target = T, a_icon = 'icons/effects/deityrunes.dmi', flick_anim = "fullrune-[runenum]-erase", col = DEFAULT_BLOOD)
						spawn(12)
							C.images -= rune_holder


/datum/disease2/effect/cult_hallucination/proc/AnimateFakeRune(var/image/rune)
	animate(rune, color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0), time = 10, loop = -1)//1
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 2)//2
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 2)//3
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1.5)//4
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1.5)//5
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)//6
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)//7
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)//8
	animate(color = list(2,0.67,0.27,0,0.27,2,0.67,0,0.67,0.27,2,0,0,0,0,1,0,0,0,0), time = 5)//9
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)//8
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)//7
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)//6
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1)//5
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1)//4
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 1)//3
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 1)//2
