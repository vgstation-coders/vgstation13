
/obj/item/weapon/reagent_containers/food/drinks/soda_cans
	vending_cat = "carbonated drinks"
	flags = FPRINT //Starts sealed until you pull the tab! Lacks OPENCONTAINER for this purpose
	//because playsound(user, 'sound/effects/can_open[rand(1,3)].ogg', 50, 1) just wouldn't work. also so badmins can varedit these
	var/list/open_sounds = list('sound/effects/can_open1.ogg', 'sound/effects/can_open2.ogg', 'sound/effects/can_open3.ogg')
	var/tabself = "You pull back the tab of"

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/update_icon()
	..()
	if (flags & OPENCONTAINER)
		overlays += image(icon = icon, icon_state = "soda_open")
		update_blood_overlay()

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/attack_self(var/mob/user)
	if(!is_open_container())
		return pop_open(user)
	if (reagents.total_volume > 0)
		return ..()
	else if (!isGlass && (user.a_intent == I_HURT))
		var/turf/T = get_turf(user)
		user.drop_item(src, T, 1)
		var/obj/item/trash/soda_cans/crushed_can = new (T, icon_state = icon_state)
		crushed_can.name = "crushed [name]"
		user.put_in_active_hand(crushed_can)
		playsound(user, 'sound/items/can_crushed.ogg', 75, 1)
		qdel(src)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/proc/pop_open(var/mob/user)
	to_chat(user, "[tabself] \the [src] with a satisfying pop.")
	flags |= OPENCONTAINER
	src.verbs |= /obj/item/weapon/reagent_containers/verb/empty_contents
	playsound(user, pick(open_sounds), 50, 1)
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola
	name = "Space Cola"
	desc = "Cola. in space."
	icon_state = "cola"
	randpix = TRUE
	reagents_to_add = list(COLA = 30)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/tonic
	name = "T-Borg's Tonic Water"
	desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
	icon_state = "tonic"
	randpix = TRUE
	reagents_to_add = TONIC

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sodawater
	name = "Soda Water"
	desc = "A can of soda water. Why not make a scotch and soda?"
	icon_state = "sodawater"
	randpix = TRUE
	reagents_to_add = SODAWATER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lemon_lime
	name = "Lemon-Lime"
	desc = "You wanted ORANGE. It gave you Lemon Lime."
	icon_state = "lemon-lime"
	randpix = TRUE
	reagents_to_add = list(LEMON_LIME = 30)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_up
	name = "Space-Up"
	desc = "Tastes like a hull breach in your mouth."
	icon_state = "space-up"
	randpix = TRUE
	reagents_to_add = list(SPACE_UP = 30)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/starkist
	name = "Star-kist"
	desc = "The taste of a star in liquid form. And, a bit of tuna...?"
	icon_state = "starkist"
	randpix = TRUE
	reagents_to_add = list(COLA = 15, ORANGEJUICE = 15)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/starkist/New()
	..()
	if(prob(30))
		new /obj/item/weapon/reagent_containers/food/drinks/soda_cans/lemon_lime(get_turf(src))
		qdel(src) //You wanted ORANGE. It gave you lemon lime!

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_mountain_wind
	name = "Space Mountain Wind"
	desc = "Blows right through you like a space wind."
	icon_state = "space_mountain_wind"
	randpix = TRUE
	reagents_to_add = list(SPACEMOUNTAINWIND = 30)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/thirteenloko
	name = "Thirteen Loko"
	desc = "The CMO has advised crew members that consumption of Thirteen Loko may result in seizures, blindness, drunkeness, or even death. Please Drink Responsably."
	icon_state = "thirteen_loko"
	randpix = TRUE
	reagents_to_add = list(THIRTEENLOKO = 30)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/dr_gibb
	name = "Dr. Gibb"
	desc = "A delicious mixture of 42 different flavors."
	icon_state = "dr_gibb"
	randpix = TRUE
	reagents_to_add = list(DR_GIBB = 30)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/nuka
	name = "Nuka Cola"
	desc = "Cool, refreshing, Nuka Cola."
	icon_state = "nuka"
	tabself = "You pop the cap off"
	molotov = -1 //can become a molotov
	isGlass = 1
	can_flip = TRUE
	randpix = TRUE
	reagents_to_add = list(NUKA_COLA = 30)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/nuka/New()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/nuka/pop_open(var/mob/user)
	..()
	user.put_in_hands(new /obj/item/weapon/coin/nuka)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/nuka/create_broken_bottle()
	if (!(flags & OPENCONTAINER))
		overlays.len = 0
		new /obj/item/weapon/coin/nuka(get_turf(src))
	..()

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/nuka/update_icon()
	overlays.len = 0
	if (!(flags & OPENCONTAINER))
		overlays += image(icon = icon, icon_state = "bottle_cap")
	update_blood_overlay()

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/quantum
	name = "Nuka Cola Quantum"
	desc = "Take the leap... enjoy a Quantum!"
	icon_state = "quantum"
	molotov = -1 //can become a molotov
	isGlass = 1
	can_flip = TRUE
	randpix = TRUE
	reagents_to_add = list(QUANTUM = 30)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/quantum/pop_open(var/mob/user)
	..()
	user.put_in_hands(new /obj/item/weapon/coin/nuka)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/quantum/create_broken_bottle()
	if (!(flags & OPENCONTAINER))
		overlays.len = 0
		new /obj/item/weapon/coin/nuka(get_turf(src))
	..()

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/quantum/update_icon()
	overlays.len = 0
	if (!(flags & OPENCONTAINER))
		overlays += image(icon = icon, icon_state = "bottle_cap")
	update_blood_overlay()

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sportdrink
	name = "Brawndo"
	icon_state = "brawndo"
	desc = "It has what plants crave! Electrolytes!"
	randpix = TRUE
	reagents_to_add = list(SPORTDRINK = 30)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/gunka_cola
	name = "Gunka-Cola Family Sized"
	desc = "An unnaturally-sized can for unnaturally-sized men. Taste the Consumerism!"
	icon_state = "gunka_cola"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')
	volume = 100
	possible_transfer_amounts = list(5,10,15,25,30,50,100)
	reagents_to_add = list(COLA = 60, SUGAR = 20, SODIUM = 10, COCAINE = 5, BLACKCOLOR = 5)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/roentgen_energy
	name = "Roentgen Energy"
	desc = "Roentgen Energy, a meltdown in your mouth! Contains real actinides!"
	icon_state = "roentgenenergy"
	reagents_to_add = list(CAFFEINE = 5, COCAINE = 1.4, URANIUM = 3.6, /*not great, not terrible*/ SPORTDRINK = 20)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/canned_matter
	name = "\improper canned bread"
	desc = "Wow, they have it!"
	icon_state = "cannedbread"
	var/obj/item/storeditem = null
	//no actual chemicals in the can

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/canned_matter/attackby(var/obj/item/I, mob/user as mob)
	if(!storeditem && !(flags & OPENCONTAINER)) // Won't work if already opened
		if(user.drop_item(I,src))
			storeditem = I

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/canned_matter/pop_open(var/mob/user)
	. = ..()
	spawn(0.5 SECONDS)
		playsound(src, pick('sound/effects/splat_pie1.ogg','sound/effects/splat_pie2.ogg'), 50)
		storeditem.forceMove(get_turf(src))
		storeditem = null

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/canned_matter/bread/New()
	. = ..()
	storeditem = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/bread(src)

//Beer cans for the Off Licence
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/blebweiser
	name = "Blebweiser"
	desc = "Based on an American classic, this lager has seen little improvement over the years."
	icon_state = "blebweiser"
	reagents_to_add = BEER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/bluespaceribbon
	name = "Bluespace Ribbon"
	desc = "A cheap lager brewed in enormous bluespace pockets, the brewing process has done little for the flavour."
	icon_state = "bluespaceribbon"
	reagents_to_add = BEER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/codeone
	name = "Code One"
	desc = "The Code One Brewery prides itself on creating the very best beer for cracking open with the boys."
	icon_state = "codeone"
	reagents_to_add = BEER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/gibness
	name = "Gibness"
	desc = "Derived from a classic Irish recipe, there's a strong taste of starch in this dry stout."
	icon_state = "gibness"
	reagents_to_add = list(BEER, POTATO)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/geometer
	name = "Geometer"
	desc = "Summon the Beast."
	icon_state = "geometer"
	reagents_to_add = GEOMETER

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/geometer/blanco
	name = "Geometer Blanco"
	desc = "'member when we had to research words..."
	icon_state = "geometer_blanco"

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/greyshitvodka
	name = "Greyshit Vodka"
	desc = "Experts spent a long time squatting around a mixing bench to bring you this."
	icon_state = "greyshitvodka"
	reagents_to_add = GREYVODKA

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/orchardtides
	name = "Orchard Tides"
	desc = "A sweet apple cider that might quench that kleptomania if only for a while."
	icon_state = "orchardtides"
	reagents_to_add = list(BEER = 20, APPLEJUICE = 30)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sleimiken
	name = "Sleimiken"
	desc = "This Belgium original has been enhanced over the years with the delicious taste of DNA-dissolving slime extract."
	icon_state = "sleimiken"
	reagents_to_add = list(BEER = 45, SLIMEJELLY = 5)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/strongebow
	name = "Strong-eBow"
	desc = "A Syndicate favourite, the sharp flavour of this Cider has been compared to getting shot by an Energy Bow."
	icon_state = "strongebow"
	reagents_to_add = list(BEER = 30, APPLEJUICE = 20)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cannedcoffee
	name = "Kiririn FIRE"
	desc = "Fine, sweet coffee, easy to drink in any scene."
	icon_state = "cannedcoffee"
	reagents_to_add = CAFE_LATTE

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cannedcopcoffee
	name = "HOSS Rainbow Donut Blend"
	desc = "All the essentials, for on the go."
	icon_state = "cannedcopcoffee"
	reagents_to_add = SECCOFFEE

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/engicoffee
	name = "Energizer"
	desc = "Smells a bit like Battery Acid"
	icon_state = "engicoffee"
	reagents_to_add = ENGICOFFEE

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/engicoffee_shard
	name = "Supermatter Sea Salt Soda "
	desc = "Mmmmm Blurple"
	icon_state = "engicoffee_shard"
	reagents_to_add = ENGICOFFEE

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lifeline_white
	name = "Picomed: White edition"
	desc = "Good for the body and good for the bones."
	icon_state = "lifeline_white"
	reagents_to_add = list(MEDCOFFEE = 48, MILK = 2)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lifeline_red
	name = "Picomed: Red edition"
	desc = "I need 50ccs of coffee, stat!"
	icon_state = "lifeline_red"
	reagents_to_add = list(MEDCOFFEE = 48, REDTEA = 2)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lifeline_cryo
	name = "Picomed: Cryo edition"
	desc = "Remember to strip before consuming."
	icon_state = "lifeline_cryo"
	reagents_to_add = list(MEDCOFFEE = 48, LEPORAZINE = 1, FROSTOIL = 1)
	var/list/tubeoverlay = list()

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lifeline_cryo/on_reagent_change()
	..()
	for(var/image/ol in tubeoverlay)
		overlays -= ol
		tubeoverlay -= ol
	var/remaining = Ceiling(reagents.total_volume/reagents.maximum_volume*100,20)
	var/image/status_overlay = image("icon" = 'icons/obj/drinks.dmi', "icon_state" = "cryoverlay_[remaining]")
	overlays += status_overlay
	tubeoverlay += status_overlay

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/bear
	name = "Bear Arms Beer"
	desc = "Crack open a Bear at the end of a long shift."
	icon_state = "bearbeer"

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/bear/set_reagents_to_add()
	reagents_to_add = list(BEER = 30, HYPERZINE = rand(3,5))

// Here be ayy canned drinks

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_sulphuricsplash
	name = "Zam Sulphuric Splash"
	desc = "Taste the splashy tang! The flavor will melt your taste buds."
	icon_state = "Zam_SulphuricSplash"
	randpix = TRUE
	reagents_to_add = list(LEMONJUICE, SACID = 15)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_formicfizz
	name = "Zam Formic Fizz"
	desc = "Sulphuric Splash is for brainless minions. This is a REAL grey's drink."
	icon_state = "Zam_FormicFizz"
	randpix = TRUE
	reagents_to_add = list(LIMEJUICE, FORMIC_ACID = 15)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_tannicthunder
	name = "Zam Tannic Thunder"
	desc = "Humans and lightweights may find this beverage agreeable if they dislike the stronger acids." // This is supposed to be a way to heal burns caused by consuming the more acidic drinks. But humans take brute damage from ingesting acid for some reason?
	icon_state = "Zam_TannicThunder"
	randpix = TRUE
	reagents_to_add = list(ORANGEJUICE, TANNIC_ACID = 15)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_trustytea
	name = "Zam Trusty Tea"
	desc = "All trusty tea is made with real opok juice. Zam's honor!" // Now with REAL Opok Juice!
	icon_state = "Zam_TrustyTea"
	randpix = TRUE
	reagents_to_add = list(ACIDTEA = 25, OPOKJUICE = 10, CAFFEINE = 5)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_trustytea/New()
	..()
	if(prob(5))
		name = "Zam Old Fashioned Tea"
		desc = "One of the original cans! The design has been discontinued, and it might be worth something to a collector."
		icon_state = "Zam_TrustyClassic"

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_humanhydrator
	name = "Zam Human Hydrator"
	desc = "The mothership provides only the best mineral water for humans to drink, REAL minerals included."
	icon_state = "Zam_HumanHydrator"
	randpix = TRUE
	reagents_to_add = list(WATER = 35, IRON = 1, COPPER = 1, SILVER = 1, GOLD = 1, DIAMONDDUST = 1)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/zam_polytrinicpalooza
	name = "Zam Polytrinic Palooza"
	desc = "This drink has been banned in all mothership controlled territories. Consume at your own risk."
	icon_state = "Zam_PolytrinicPalooza"
	randpix = TRUE
	reagents_to_add = list(HOOCH = 20, PACID = 14, MINDBREAKER = 1, COCAINE = 5)
