// Tiny green chickens from outer space

/mob/living/carbon/monkey/vox
	name = "chicken"
	voice_name = "chicken"
	icon_state = "chickengreen"
	speak_emote = list("clucks","croons")
	species_type = /mob/living/carbon/monkey/vox
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken
	canWearClothes = 0
	canWearGlasses = 0

/mob/living/carbon/monkey/vox/attack_hand(mob/living/carbon/human/M as mob)


	if((M.a_intent == I_HELP) && !(locked_to) && (isturf(src.loc)) && (M.get_active_hand() == null)) //Unless their location isn't a turf!
		scoop_up(M)

	..()

/mob/living/carbon/monkey/vox/New()

	..()
	setGender(NEUTER)
	dna.mutantrace = "vox"
	greaterform = "Vox"
	alien = 1
	add_language("Vox-pidgin")
	default_language = all_languages["Vox-pidgin"]