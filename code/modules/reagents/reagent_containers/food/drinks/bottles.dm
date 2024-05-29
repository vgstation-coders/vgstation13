
///////////////////////////////////////////////Alchohol bottles! -Agouri //////////////////////////
//Functionally identical to regular drinks. The only difference is that the default bottle size is 100. - Darem
//Bottles now weaken and break when smashed on people's heads. - Giacom


/obj/item/weapon/reagent_containers/food/drinks/bottle
	amount_per_transfer_from_this = 10
	volume = 100
	starting_materials = list(MAT_GLASS = 500)
	bottleheight = 31
	melt_temperature = MELTPOINT_GLASS
	w_type=RECYK_GLASS
	can_flip = TRUE

//Keeping this here for now, I'll ask if I should keep it here.
/obj/item/weapon/broken_bottle

	name = "broken bottle" // changed to lowercase - Hinaichigo
	desc = "A bottle with a sharp broken bottom."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "broken_bottle"
	force = 9.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	sharpness = 0.8 //same as glass shards
	sharpness_flags = SHARP_TIP | SHARP_BLADE
	w_class = W_CLASS_TINY
	item_state = "beer"
	attack_verb = list("stabs", "slashes", "attacks")
	var/icon/broken_outline = icon('icons/obj/drinks.dmi', "broken")
	starting_materials = list(MAT_GLASS = 500)
	melt_temperature = MELTPOINT_GLASS
	w_type=RECYK_GLASS

/obj/item/weapon/broken_bottle/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()


/obj/item/weapon/reagent_containers/food/drinks/bottle/gin
	name = "Griffeater Gin"
	desc = "A bottle of high quality gin, produced in the New London Space Station."
	icon_state = "ginbottle"
	vending_cat = "spirits"
	bottleheight = 30
	isGlass = 1
	molotov = -1
	reagents_to_add = GIN

/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey
	name = "Uncle Git's Special Reserve"
	desc = "A premium single-malt whiskey, gently matured inside the tunnels of a nuclear shelter. TUNNEL WHISKEY RULES."
	icon_state = "whiskeybottle"
	vending_cat = "spirits"
	isGlass = 1
	molotov = -1
	reagents_to_add = WHISKEY

/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka
	name = "Tunguska Triple Distilled"
	desc = "Aah, vodka. Prime choice of drink AND fuel by Russians worldwide."
	icon_state = "vodkabottle"
	vending_cat = "spirits"
	isGlass = 1
	molotov = -1
	reagents_to_add = VODKA

/obj/item/weapon/reagent_containers/food/drinks/bottle/tequila
	name = "Caccavo Guaranteed Quality Tequila"
	desc = "Made from premium petroleum distillates, pure thalidomide and other fine quality ingredients!"
	icon_state = "tequilabottle"
	vending_cat = "spirits"
	isGlass = 1
	molotov = -1
	reagents_to_add = TEQUILA

/obj/item/weapon/reagent_containers/food/drinks/bottle/bluecuracao
	name = "Bluespace Curacao"
	desc = "This is either Blue Curacao, or window cleaner. Take a sip and find out."
	icon_state = "bluecuracaobottle"
	vending_cat = "spirits"
	isGlass = 1
	molotov = -1
	reagents_to_add = BLUECURACAO

/obj/item/weapon/reagent_containers/food/drinks/bottle/bitters
	name = "Wizard's Bitters"
	desc = "Named for it's seemingly magical ability to take the place of any variety of bitters. Abracadabra, Angostura!"
	icon_state = "bittersbottle"
	vending_cat = "spirits"
	isGlass = 1
	molotov = -1
	reagents_to_add = BITTERS

/obj/item/weapon/reagent_containers/food/drinks/bottle/triplesec
	name = "Cufftreau Triple Sec"
	desc = "Named for what'll be wrapped around your wrists by the end of the night if you keep drinking like this."
	icon_state = "triplesecbottle"
	vending_cat = "spirits"
	isGlass = 1
	molotov = -1
	reagents_to_add = TRIPLESEC

/obj/item/weapon/reagent_containers/food/drinks/bottle/schnapps
	name = "All-in-One Fancy Space Schnapps"
	desc = "For when you can't be bothered to stock a dozen varieties of Schnapps - just don't complain when it doesn't taste quite right."
	icon_state = "schnappsbottle"
	vending_cat = "spirits"
	isGlass = 1
	molotov = -1
	reagents_to_add = SCHNAPPS

/obj/item/weapon/reagent_containers/food/drinks/bottle/champagne
	name = "Captain's Finest Champagne"
	desc = "A premium brand of champagne, intended for only the most discerning of tastes - for Captains, by Captains."
	icon_state = "champagnebottle"
	vending_cat = "fermented"
	isGlass = 1
	molotov = -1
	reagents_to_add = CHAMPAGNE

/obj/item/weapon/reagent_containers/food/drinks/bottle/fireballwhisky
	name = "Oni Soma's Fireball Whisky"
	desc = "A cinnamon flavored Whisky - without the E - favored by cheap drunks with no taste buds."
	icon_state = "fireballwhiskybottle"
	vending_cat = "spirits"
	isGlass = 1
	molotov = -1
	reagents_to_add = CINNAMONWHISKY

/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing
	name = "Bottle of Nothing"
	desc = "A bottle filled with nothing."
	icon_state = "bottleofnothing"
	desc = ""
	isGlass = 1
	molotov = -1
	smashtext = ""
	reagents_to_add = NOTHING

/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing/New()
	if(Holiday == APRIL_FOOLS_DAY)
		name = "Bottle of Something"
		desc = "A bottle filled with something."
		reagents_to_add = pick(BEER, VOMIT, ZOMBIEPOWDER, SOYSAUCE, KETCHUP, HONEY, BANANA, ABSINTHE, SALTWATER, WATER, BLOOD, LUBE, MUTATIONTOXIN, AMUTATIONTOXIN, GOLD, TRICORDRAZINE, GRAVY)
	..()

/obj/item/weapon/reagent_containers/food/drinks/bottle/patron
	name = "Wrapp Artiste Patron"
	desc = "Silver laced tequila, served in space night clubs across the galaxy."
	icon_state = "patronbottle"
	bottleheight = 26 //has a cork but for now it goes on top of the cork
	molotov = -1
	isGlass = 1
	reagents_to_add = PATRON

/obj/item/weapon/reagent_containers/food/drinks/bottle/rum
	name = "Captain Pete's Cuban Spiced Rum"
	desc = "This isn't just rum, oh no. It's practically GRIFF in a bottle."
	icon_state = "rumbottle"
	vending_cat = "spirits"
	molotov = -1
	isGlass = 1
	reagents_to_add = RUM

/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth
	name = "Goldeneye Vermouth"
	desc = "Sweet, sweet dryness~"
	icon_state = "vermouthbottle"
	vending_cat = "fermented"
	molotov = -1
	isGlass = 1
	reagents_to_add = VERMOUTH

/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua
	name = "Robert Robust's Coffee Liqueur"
	desc = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936, HONK"
	icon_state = "kahluabottle"
	vending_cat = "fermented"
	molotov = -1
	isGlass = 1
	reagents_to_add = KAHLUA

/obj/item/weapon/reagent_containers/food/drinks/bottle/goldschlager
	name = "College Girl Goldschlager"
	desc = "Because they are the only ones who will drink 100 proof cinnamon schnapps."
	icon_state = "goldschlagerbottle"
	molotov = -1
	isGlass = 1
	reagents_to_add = GOLDSCHLAGER

/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac
	name = "Chateau De Baton Premium Cognac"
	desc = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. You might as well not scream 'SHITCURITY' this time."
	icon_state = "cognacbottle"
	vending_cat = "spirits"
	molotov = -1
	isGlass = 1
	reagents_to_add = COGNAC

/obj/item/weapon/reagent_containers/food/drinks/bottle/wine
	name = "Doublebeard Bearded Special Wine"
	desc = "A faint aura of unease and asspainery surrounds the bottle."
	icon_state = "winebottle"
	vending_cat = "fermented"
	bottleheight = 30
	molotov = -1
	isGlass = 1
	reagents_to_add = WINE

/obj/item/weapon/reagent_containers/food/drinks/bottle/pwine
	name = "Vintage 2018 Special Reserve"
	desc = "Fermented during tumultuous years, and aged to perfection over several centuries."
	icon_state = "pwinebottle"
	vending_cat = "fermented" //doesn't actually matter, will appear under premium
	bottleheight = 30
	molotov = -1
	isGlass = 1
	reagents_to_add = PWINE

/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe
	name = "Jailbreaker Verte"
	desc = "One sip of this and you just know you're gonna have a good time."
	icon_state = "absinthebottle"
	bottleheight = 27
	molotov = -1
	isGlass = 1
	reagents_to_add = ABSINTHE

/obj/item/weapon/reagent_containers/food/drinks/bottle/sake
	name = "Uchuujin Junmai Ginjo Sake"
	desc = "An exotic rice wine from the land of the space ninjas."
	icon_state = "sakebottle"
	vending_cat = "fermented"
	isGlass = 1
	molotov = -1
	reagents_to_add = SAKE

//////////////////////////JUICES AND STUFF ///////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice
	name = "Orange Juice"
	desc = "Full of vitamins and deliciousness!"
	icon_state = "orangejuice"
	vending_cat = "fruit juices"
	starting_materials = null
	reagents_to_add = ORANGEJUICE

/obj/item/weapon/reagent_containers/food/drinks/bottle/cream
	name = "Milk Cream"
	desc = "It's cream. Made from milk. What else did you think you'd find in there?"
	icon_state = "cream"
	vending_cat = "dairy products"
	starting_materials = null
	reagents_to_add = CREAM

/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice
	name = "Tomato Juice"
	desc = "Well, at least it LOOKS like tomato juice. You can't tell with all that redness."
	icon_state = "tomatojuice"
	vending_cat = "fruit juices"
	starting_materials = null
	reagents_to_add = TOMATOJUICE

/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice
	name = "Lime Juice"
	desc = "Sweet-sour goodness."
	icon_state = "limejuice"
	vending_cat = "fruit juices"
	starting_materials = null
	reagents_to_add = LIMEJUICE

/obj/item/weapon/reagent_containers/food/drinks/bottle/greyvodka
	name = "Greyshirt Vodka"
	desc = "Experts spent a long time squatting around a mixing bench to bring you this."
	icon_state = "grey_vodka"
	vending_cat = "spirits"
	starting_materials = null
	isGlass = 1
	molotov = -1
	reagents_to_add = GREYVODKA

/obj/item/weapon/reagent_containers/food/drinks/proc/smash(mob/living/M as mob, mob/living/user as mob)
	if(molotov == 1) //for molotovs
		if(lit)
			new /obj/effect/decal/cleanable/ash(get_turf(src))
		else
			new /obj/item/weapon/reagent_containers/glass/rag(get_turf(src))

	//Creates a shattering noise and replaces the bottle with a broken_bottle
	user.drop_item(force_drop = 1)
	var/obj/item/weapon/broken_bottle/B = new /obj/item/weapon/broken_bottle(user.loc)
	B.icon_state = src.icon_state
	B.name = src.smashname

	if(istype(src, /obj/item/weapon/reagent_containers/food/drinks/drinkingglass))  //for drinking glasses
		B.icon_state = "glass_empty"

	if(prob(33))
		new /obj/item/weapon/shard(get_turf(M || src)) // Create a glass shard at the target's location! O)

	var/icon/I = new('icons/obj/drinks.dmi', B.icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I

	user.put_in_active_hand(B)
	src.transfer_fingerprints_to(B)
	playsound(src, "shatter", 70, 1)

	qdel(src)

//smashing when thrown
/obj/item/weapon/reagent_containers/food/drinks/throw_impact(atom/hit_atom, var/speed, mob/user)
	if(!..() && isGlass && isturf(loc)) // don't shatter if we got caught mid-flight
		isGlass = 0 //to avoid it from hitting the wall, then hitting the floor, which would cause two broken bottles to appear
		visible_message("<span  class='warning'>The [smashtext][name] shatters!</span>","<span  class='warning'>You hear a shatter!</span>")
		playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		if(reagents.total_volume)
			if(molotov == 1 || reagents.has_reagent(FUEL))
				user?.attack_log += text("\[[time_stamp()]\] <span class='danger'>Threw a [lit ? "lit" : "unlit"] molotov to \the [hit_atom], containing [reagents.get_reagent_ids()]</span>")
				log_attack("[lit ? "Lit" : "Unlit"] molotov shattered at [formatJumpTo(get_turf(hit_atom))], thrown by [key_name(user)] and containing [reagents.get_reagent_ids()]")
				message_admins("[lit ? "Lit" : "Unlit"] molotov shattered at [formatJumpTo(get_turf(hit_atom))], thrown by [key_name_admin(user)] and containing [reagents.get_reagent_ids()]")
			reagents.splashplosion(reagents.total_volume >= (reagents.maximum_volume/2))//splashing everything on the tile hit, and the surrounding ones if we're over half full.
		invisibility = INVISIBILITY_MAXIMUM  //so it stays a while to ignite any fuel

		if(molotov == 1) //for molotovs
			if(lit)
				new /obj/effect/decal/cleanable/ash(get_turf(src))
				var/turf/loca = get_turf(src)
				if(loca)
					new /obj/effect/fire(loca)
					loca.hotspot_expose(700, 1000,surfaces=istype(loc,/turf))
			else
				new /obj/item/weapon/reagent_containers/glass/rag(get_turf(src))

		create_broken_bottle()

/obj/item/weapon/reagent_containers/food/drinks/proc/create_broken_bottle()
	//create new broken bottle
	var/obj/item/weapon/broken_bottle/B = new /obj/item/weapon/broken_bottle(loc)
	B.name = smashname
	B.icon_state = icon_state

	if(istype(src, /obj/item/weapon/reagent_containers/food/drinks/drinkingglass))  //for drinking glasses
		B.icon_state = "glass_empty"

	if(prob(33))
		new /obj/item/weapon/shard(get_turf(src)) // Create a glass shard at the hit location)

	var/icon/Q = new('icons/obj/drinks.dmi', B.icon_state)
	Q.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	Q.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = Q
	src.transfer_fingerprints_to(B)
	playsound(src, "shatter", 70, 1)
	qdel(src)

//////////////////////
// molotov cocktail //
//  by Hinaichigo   //
//////////////////////

/obj/item/weapon/reagent_containers/food/drinks/attackby(var/obj/item/I, mob/user as mob)
	if(istype(I, /obj/item/weapon/reagent_containers/glass/rag) && molotov == -1)  //check if it is a molotovable drink - just beer and ale for now - other bottles require different rag overlay positions - if you can figure this out then go for it
		to_chat(user, "<span  class='notice'>You stuff the [I] into the mouth of the [src].</span>")
		QDEL_NULL(I) //??
		var/obj/item/weapon/reagent_containers/food/drinks/dummy = /obj/item/weapon/reagent_containers/food/drinks/molotov
		molotov = initial(dummy.molotov)
		flags = initial(dummy.flags)
		name = initial(dummy.name)
		smashtext = initial(dummy.smashtext)
		desc = initial(dummy.desc)
		slot_flags = initial(dummy.slot_flags)
		update_icon()
		return 1
	else if(I.is_hot())
		attempt_heating(I, user)
		light(user,I)
		update_brightness(user)
	else if(istype(I, /obj/item/device/assembly/igniter))
		var/obj/item/device/assembly/igniter/C = I
		C.activate()
		light(user,I)
		update_brightness(user)
		return
	else if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/donut))
		if(reagents.total_volume)
			var/obj/item/weapon/reagent_containers/food/snacks/donut/D = I
			D.dip(src, user)

/obj/item/weapon/reagent_containers/food/drinks/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(!(molotov == 1))
		return
	if(lit)
		return
	ignite()

/obj/item/weapon/reagent_containers/food/drinks/ignite()
	if(lit)
		return
	light("<span class='danger'>The raging fire sets \the [src] alight.</span>")

/obj/item/weapon/reagent_containers/food/drinks/extinguish()
	lit = 0
	update_brightness()
	update_icon()
	..()

/obj/item/weapon/reagent_containers/food/drinks/molotov
	name = "incendiary cocktail"
	smashtext = ""
	desc = "A rag stuffed into a bottle."
	slot_flags = SLOT_BELT
	flags = FPRINT
	molotov = 1
	isGlass = 1
	icon_state = "vodkabottle" //not strictly necessary for the "abstract" molotov type that the molotov-making-process copies variables from, but is used for pre-spawned molotovs
	can_flip = TRUE
	reagents_to_add = FUEL //not strictly necessary for the "abstract" molotov type that the molotov-making-process copies variables from, but is used for pre-spawned molotovs

/obj/item/weapon/reagent_containers/food/drinks/molotov/New()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/proc/light(mob/user,obj/item/I)
	var/flavor_text = "<span  class='rose'>[user] lights \the [name] with \the [I].</span>"
	if(!lit && molotov == 1)
		lit = 1
		visible_message(flavor_text)
		processing_objects.Add(src)
		update_icon()
	if(!lit && can_be_lit)
		lit = 1
		visible_message(flavor_text)
		can_be_lit = 0
		update_icon()

/obj/item/weapon/reagent_containers/food/drinks/blow_act(var/mob/living/user)
	if(lit)
		lit = 0
		visible_message("<span  class='rose'>The light on \the [name] goes out.</span>")
		processing_objects.Remove(src)
		set_light(0)
		update_icon()

/obj/item/weapon/reagent_containers/food/drinks/proc/update_brightness(var/mob/user = null)
	if(lit)
		set_light(src.brightness_lit)
	else
		set_light(0)

//todo: can light cigarettes with
//todo: is force = 15 overwriting the force? //Yes, of broken bottles, but that's been fixed now

////////  Could be expanded upon:
//  make it work with more chemicals and reagents, more like a chem grenade
//  only allow the bottle to be stuffed if there are certain reagents inside, like fuel
//  different flavor text for different means of lighting
//  new fire overlay - current is edited version of the IED one
//  a chance to not break, if desired
//  fingerprints appearing on the object, which might already happen, and the shard
//  belt sprite and new hand sprite
//	ability to put out with water or otherwise
//	burn out after a time causing the contents to ignite
//	make into its own item type so they could be spawned full of fuel with New()
//  colored light instead of white light
//	the rag can store chemicals as well so maybe the rag's chemicals could react with the bottle's chemicals before or upon breaking
//  somehow make it possible to wipe down the bottles instead of exclusively stuffing rags into them
//  make rag retain chemical properties or color (if implemented) after smashing
////////

/obj/item/weapon/reagent_containers/food/drinks/update_icon()
	..()
	var/image/Im
	if(molotov == 1)
		Im = image('icons/obj/grenade.dmi', icon_state = "molotov_rag")
		Im.pixel_y += src.bottleheight-23 * PIXEL_MULTIPLIER //since the molotov rag and fire are placed one pixel above the mouth of the bottle, and start out at a height of 23 (for beer and ale)
		overlays += Im
	if(molotov == 1 && lit)
		Im = image('icons/obj/grenade.dmi', icon_state = "molotov_fire")
		Im.pixel_y += src.bottleheight-23 * PIXEL_MULTIPLIER
		overlays += Im
	else
		item_state = initial(item_state)
	if(ishuman(src.loc))
		var/mob/living/carbon/human/H = src.loc
		H.update_inv_belt()

	return


/obj/item/weapon/reagent_containers/food/drinks/process()
	var/turf/loca = get_turf(src)
	if(lit && loca)
//		to_chat(world, "<span  class='warning'>Burning...</span>")
		loca.hotspot_expose(700, 1000,surfaces=istype(loc,/turf))
	return
