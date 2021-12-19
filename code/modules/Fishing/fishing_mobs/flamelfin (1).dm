/mob/living/simple_animal/hostile/fishing/flamelfin
	name = "flamelfin"
	desc = "Named for its unique ability to synthesize almost any chemical known to mankind. Its meat is known to be delicious and is a popular last meal for prisoners. The prisoners have not necessarily been on death row."
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/flamelfillet
	size = SIZE_SMALL
	faction = "hostile"
	ranged = 1
	ranged_cooldown_cap = 5 //almost twice that of the default
	minimum_distance = 2
	retreat_distance = 1
	ranged_message = "spits"
	ranged_cooldown = 2 //Let's not have it cyanide people instantly
	projectiletype = /obj/item/projectile/bullet/syringe/flamelfin
	minCatchSize = 10
	maxCatchSize = 30
	var/list/chemTheme = list()
	var/rarityFactor = 2

/mob/living/simple_animal/hostile/fishing/flamelfin/New()
	..()
	meat_amount = round(catchSize/10, 1)

/mob/living/simple_animal/hostile/fishing/flamelfin/create_projectile(mob/user)
	var/obj/item/projectile/bullet/syringe/flamelfin/fS = new projectiletype(user.loc)
	var/mob/living/simple_animal/hostile/fishing/flamelfin/theFish = user
	fS.capacity = theFish.catchSize/2
	fS.create_reagents(capacity)
	var/spitChem = pick(theFish.chemTheme)
	fS.reagents.add_reagents(spitChem, capacity)
	return fS

/obj/item/projectile/bullet/syringe/flamelfin
	name = "flamelfin spit"
	nodamage = 0
	damage = 5
	custom_impact = FALSE
	damage_type = TOX
	decay_type = null
	projectile_speed = 1.5	//Slower than a taser.
	capacity = 5

/obj/item/weapon/holder/animal/flamelfin/attack_self(mob/user)
	if(stored_mob.stat == DEAD)
		return
	to_chat(user, "<span class ='notice'>You begin squeezing \the [src]. It angrily thrashes in your arms!</span>")
	if(do_after(user, src, 15))
		var/turf/T = get_ranged_target_turf(get_turf(user), user.dir, 10)
		stored_mob.OpenFire(T)
		stored_mob.adjustBruteLoss(10)
		if(stored_mob.stat == DEAD)
			var/deadSplash = pick(stored_mob.chemTheme)
			splash_sub(deadSplash, user, stored_mob.catchSize)
			to_chat(user, "<span class ='warning'>\The [src] bursts, splashing chemicals all over you!</span>")
			user.drop_item(src, force_drop = 1)

/mob/living/simple_animal/hostile/fishing/flamelfin/modMeat(var/user, theMeat)
	theMeat.eatverb = pick("bite","chew", "swallow","chomp", "savor", "enjoy")
	var/datum/reagent/chemType = pick(chemTheme)
	var/chemAmount = catchSize/rarityFactor
	theMeat.reagents.add_reagent(chemType, chemAmount)

/obj/item/weapon/reagent_containers/food/snacks/meat/flamelfin
	name = "flamel fillet"
	desc = "A fillet of flamelfin meat"
	icon_state = "flamel_fillet"

/mob/living/simple_animal/hostile/fishing/flamelfin/barman
	icon_state = "flamelfin_bar"
	icon_living = "flamelfin_bar"
	icon_dead = "flamelfin_bar_dead"
	rarityFactor = 1	//big fish, big drink
	chemTheme = list(
		CAFFEINE,
		COFFEE,
		ICETEA,
		TONIC,
		SODAWATER,
		BEER,
		WHISKEY,
		WINE,
		HOOCH,
		ALE,
		GIN,
		ABSINTHE,
		RUM,
		BWINE,
		WWINE,
		COGNAC,
		PWINE,
		WEEDEATER,
		SAKE,
		VODKA,
		TEQUILA,
		SCHNAPPS,
		BITTERS,
		CHAMPAGNE,
		GINTONIC,
		BOOGER,
		BLOODYMARY,
		MANLYDORF,
		MOONSHINE,
		AMERICANO,
		KAMIKAZE,
		MOJITO,
		GINFIZZ,
		SINGULO,
		MEAD,
		GROG,
		DOCTORSDELIGHT,
		SILENCER,
		KARMOTRINE,
	)

/mob/living/simple_animal/hostile/fishing/flamelfin/chef
	icon_state = "flamelfin_chef"
	icon_living = "flamelfin_chef"
	icon_dead = "flamelfin_chef_dead"
	rarityFactor = 3
	chemTheme = list(
		CARAMEL,
		HONEY,
		TOMATO_SOUP,
		NUTRIMENT,
		SOYSAUCE,
		KETCHUP,
		MUSTARD,
		RELISH,
		MAYO,
		CAPSAICIN,
		SODIUMCHLORIDE,
		CINNAMON,
		HOT_COCO,
		SPRINKLES,
		CORNOIL,
		ENZYME,
		DRY_RAMEN,
		HOT_RAMEN,
		HELL_RAMEN,
		FLOUR,
		RICE,
		MILK,
		SOYMILK,
		CREAM,
		GRAVY,
		CHEESYGLOOP,
		MAPLESYRUP,
		LIQUIDBUTTER,
		DIABEETUSOL,
		MINTTOXIN,
		CHEFSPECIAL,
	)

/mob/living/simple_animal/hostile/fishing/flamelfin/lowMed
	icon_state = "flamelfin_lowMed"
	icon_living = "flamelfin_lowMed"
	icon_dead = "flamelfin_lowMed_dead"
	chemTheme = list(
		ANTI_TOXIN,
		TOXIN,
		STOXIN,
		INAPROVALINE,
		TRAMADOL,
		KELOTANE,
		DERMALINE,
		DEXALIN,
		DEXALINP,
		BICARIDINE,
		CRYOXADONE,
		ALLICIN,
		SPACEACILLIN,
		METHYLIN,
		PEPTOBISMOL,
		RYETALYN,
		OXYCODONE,
		LEPORAZINE,
		CRYPTOBIOLIN,
		LEXORIN,
		TRICORDRAZINE,
		SIMPOLINOL,
		HYRONALIN,
		ALKYSINE,
		ALKYCOSINE,
		IMIDAZOLINE,
		INACUSIATE,
		CLONEXADONE,
		CHLORALHYDRATE,
		MUCUS,
	)


/mob/living/simple_animal/hostile/fishing/flamelfin/highMed
	icon_state = "flamelfin_highMed"
	icon_living = "flamelfin_highMed"
	icon_dead = "flamelfin_highMed_dead"
	rarityFactor = 5
	chemTheme = list(
		SYNAPTIZINE,
		IMPEDREZENE,
		ARITHRAZINE,
		LITHOTORCRAZINE,
		PERIDAXON,
		SYNTHOCARISOL,
		REZADONE,
		NANOFLOXACIN,
		PRESLOMITE,
		MEDNANOBOTS,
	)


/mob/living/simple_animal/hostile/fishing/flamelfin/lowUtil
	icon_state = "flamelfin_lowUtil"
	icon_living = "flamelfin_lowUtil"
	icon_dead = "flamelfin_lowUtil_dead"
	chemTheme = list(
		PICCOLYN,
		GLYCEROL,
		MUTAGEN,
		FUEL,
		PLATBGONE,
		SALTWATER,
		PLASTICIDE,
		THERMITE,
		BLEACH,
		HYPERZINE,
		CARPOTOXIN,
		ETHYLREDOXRAZINE,
		CHLORALHYDRATE,
		LIPOZINE,
		CARPPHEROMONES,
		HONKSERUM,
		QUANTUM,
		SLIMEJELLY,
		LUBE,
		PACID,
		MINDBREAKER,
		CHILLWAX,
		ROYALJELLY,
		FROSTOIL,
		COCAINE,
		SPACE_DRUGS,
		HOLYWATER,
		VOMIT,
	)

/mob/living/simple_animal/hostile/fishing/flamelfin/highUtil
	icon_state = "flamelfin_highUtil"
	icon_living = "flamelfin_highUtil"
	icon_dead = "flamelfin_highUtil_dead"
	rarityFactor = 5
	chemTheme = list(
		NANITES,
		NANOBOTS,
		COMNANOBOTS,
		CREATINE,
		MAGICADELUXE,
		ZOMBIEPOWDER,
		MINTTOXIN,
		PHAZON,
		SPIDERS,
		HEARTBREAKER,
		SPIRITBREAKER,
		COLORFUL_REAGENT,
		AMINOMICIN,
		AMINOCYPRINIDOL,
		LUMINOL,
	)

/mob/living/simple_animal/hostile/fishing/flamelfin/mineral
	icon_state = "flamelfin_mineral"
	icon_living = "flamelfin_mineral"
	icon_dead = "flamelfin_mineral_dead"
	chemTheme = list(
		GOLD,
		SILVER,
		URANIUM,
		ALUMINUM,
		IRON,
		PLASMA,
	)

/mob/living/simple_animal/hostile/fishing/flamelfin/rare
	icon_state = "flamelfin_rare"
	icon_living = "flamelfin_rare"
	icon_dead = "flamelfin_rare_dead"
	rarityFactor = 10
	chemTheme = list(
		BICARODYNE,
		HYPOZINE,
		CHEFSPECIAL,
		XENOMICROBES,
		AUTISTNANITES,
		PETRITRICIN,
		SCIENTISTS_SERENDIPITY,
		BLOCKAZINE,
		HEMOSCYANINE,
		KARMOTRINE,
	)
