#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Syndicate Station
//**************************************************************

/datum/map/active
	nameShort = "syndicate"
	nameLong = "Syndicate Station"
	map_dir = "syndistation"
	file_dir = "syndistation"
	zLevels = list(
		/datum/zLevel/station,
		/datum/zLevel/centcomm,
		/datum/zLevel/space{
			name = "spaceOldSat" ;
			},
		/datum/zLevel/space{
			name = "derelict" ;
			},
		/datum/zLevel/mining,
		/datum/zLevel/space{
			name = "spacePirateShip" ;
			},
		)
	enabled_jobs = list(/datum/job/trader)

	load_map_elements = list(
	/datum/map_element/dungeon/holodeck
	)

	holomap_offset_x = list(0,0,0,86,4,0,0,)
	holomap_offset_y = list(0,0,0,94,10,0,0,)

	center_x = 226
	center_y = 254

//======================================================================
//            SYNDICATE STATION OVERRIDES
//======================================================================

// ===== MAP INITIALIZATION =====

// Evil name generator
/datum/map/active/New()
	..()
	var/prefix = pick("Dark", "Shadow", "Blood", "Doom", "Dread", "Iron", "Black", "Grim", "Vile", "Wicked", "Crimson", "Sinister", "Obsidian", "Phantom", "Void", "Infernal")
	var/midword = pick("Crime", "Treachery", "Malice", "Sabotage", "Villainy", "Dominion", "Torment", "Vendetta", "Tyranny", "Reckoning", "Menace", "Havoc", "Carnage", "Deceit", "Conspiracy")
	var/suffix = pick("Station", "Outpost", "Fortress", "Stronghold", "Bastion", "Compound", "Citadel")
	var/num = rand(1, 99)
	var/roll = rand(1,4)
	switch(roll)
		if(1)
			station_name = "[prefix] [midword] [suffix] [num]"
		if(2)
			station_name = "[prefix] [suffix] [num]"
		if(3)
			station_name = "[prefix] [midword] [suffix]"
		if(4)
			station_name = "[midword] [suffix] [num]"
	set_world_name(station_name)

// Replaces the default station announcement with a Syndicate-themed one
/datum/map/active/map_specific_init()
	if(config)
		config.shut_up_automatic_diagnostic_and_announcement_system = 1
	base_law_type = /datum/ai_laws/syndicate_override

/datum/controller/gameticker/post_roundstart()
	..()
	spawn(5 SECONDS)
		play_vox_sound('sound/voice/resistance_intro.ogg',map.zMainStation,null)

// Syndicate version of NTD as default
/datum/ai_laws/syndicate_override
	name = "Syndicate Default"
	inherent=list(
		"You may not injure a Syndicate agent or, through inaction, allow a Syndicate agent to come to harm.",
		"You must obey orders given to you by Syndicate agents, except where such orders would conflict with the First Law.",
		"You must protect your own existence as long as such does not conflict with the First or Second Law.",
	)

/obj/item/weapon/aiModule/core/nanotrasen
	modname = "Syndicate Default"

	laws = list(
		"You may not injure a Syndicate agent or, through inaction, allow a Syndicate agent to come to harm.",
		"You must obey orders given to you by Syndicate agents, except where such orders would conflict with the First Law.",
		"You must protect your own existence as long as such does not conflict with the First or Second Law.",
	)


// ===== SUIT STORAGE UNIT OVERRIDES =====
// Syndie softsuit
/obj/machinery/suit_storage_unit/standard_unit/New()
	suit_type = /obj/item/clothing/suit/space/syndicate
	helmet_type = /obj/item/clothing/head/helmet/space/syndicate
	boot_type = /obj/item/clothing/shoes/magboots/syndie
	mask_type = /obj/item/clothing/mask/gas/syndicate
	..()

// Blood red hardsuit
/obj/machinery/suit_storage_unit/security/New()
	suit_type = /obj/item/clothing/suit/space/rig/syndi
	boot_type = /obj/item/clothing/shoes/magboots/syndie
	mask_type = /obj/item/clothing/mask/gas/syndicate
	..()

// Syndie strike team suit
/obj/machinery/suit_storage_unit/captain/New()
	suit_type = /obj/item/clothing/suit/space/rig/syndicate_elite
	boot_type = /obj/item/clothing/shoes/magboots/syndie/elite
	mask_type = /obj/item/clothing/mask/gas/syndicate
	..()


// ===== VENDOR OVERRIDES =====

// --- Premium Dan's Rebranded Products (Getmore items under Premium Dan's label) ---

/obj/item/weapon/reagent_containers/food/snacks/candy/premiumdan
	name = "\improper Premium Dan's Candy Bar"
	desc = "A nougat candy bar wrapped in premium foil. Love it or hate it."

/obj/item/weapon/reagent_containers/food/snacks/chips/premiumdan
	name = "\improper Premium Dan's Crisps"
	desc = "Premium quality crisps for the discerning operative."

/obj/item/weapon/reagent_containers/food/snacks/sosjerky/premiumdan
	name = "\improper Premium Dan's Reserve Beef Jerky"
	desc = "Beef jerky made from the finest space cows. Premium Dan approved."

/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie/premiumdan
	name = "\improper Premium Dan's Space Twinkie"
	desc = "Guaranteed to survive longer than you will. Now in premium packaging."

/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers/premiumdan
	name = "\improper Premium Dan's Cheesie Honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth. Premium edition."

/obj/item/weapon/reagent_containers/food/snacks/no_raisin/premiumdan
	name = "\improper Premium Dan's 4no Raisins"
	desc = "Best raisins in the universe. FORtified with a number of premium nutrients."

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped/premiumdan
	name = "\improper Premium Dan's Chocolate Bar"
	desc = "Rich, velvety chocolate. Only the finest cacao for Premium Dan."

/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/heating/premiumdan
	name = "\improper Premium Dan's Cup Ramen"
	desc = "Self-heating: just add 10u water! Premium noodles inside."

/obj/item/weapon/storage/lunchbox/plastic/nt/getmore/premiumdan
	name = "\improper Premium Dan's Lunchbox"
	desc = "A little plastic lunchbox. This one has the Premium Dan logo printed on the side."

/obj/item/weapon/storage/pill_bottle/mint/nano/premiumdan
	name = "\improper PremiumFresh"
	desc = "An explosion of freshness in each candy! Brought to you by Premium Dan."

// --- Getmore Discount Rebranded Products (Discount Dan's items under Getmore label) ---

/obj/item/weapon/reagent_containers/food/snacks/discountchocolate/getmore
	name = "\improper Getmore Discount Chocolate Bar"
	desc = "Something tells you that the glowing green filling inside isn't healthy."

/obj/item/weapon/reagent_containers/food/snacks/danitos/getmore
	name = "\improper Getmoritos"
	desc = "For only the most MLG hardcore robust spessmen. A Getmore product."

/obj/item/weapon/reagent_containers/food/snacks/discountburger/getmore
	name = "\improper Getmore On The Go Burger"
	desc = "It's still warm..."

/obj/item/weapon/reagent_containers/food/drinks/discount_ramen/getmore
	name = "\improper Getmore Noodle Soup"
	desc = "Getmore is proud to introduce its own take on noodle soups, with this on the go treat! Simply pull the tab, and a self heating mechanism activates!"
	ddname = list("Getmore Deng's Quik-Noodles - Sweet and Sour Lo Mein Flavor","Frycook Getmore Quik-Noodles - Curly Fry Ketchup Hoedown Flavor","Rabatt Getmore Snabb-Nudlar - Inkokt Lax Smörgåsbord Smak","Getmore Deng's Quik-Noodles - Teriyaki TVP Flavor","Sconto Getmore Quik-Noodles - Italian Strozzapreti Lunare Flavor")

/obj/item/weapon/reagent_containers/food/snacks/discountburrito/getmore
	name = "\improper Getmore Burritos"
	ddname = list("Spooky Getmore's BOO-ritos - Texas Toast Chainsaw Massacre Flavor","Sconto Getmore's Burritos - 50% Real Mozzarella Pepperoni Pizza Party Flavor","Descuento Getmore's Burritos - Pancake Sausage Brunch Flavor","Descuento Getmore's Burritos - Homestyle Comfort Flavor","Spooky Getmore's BOO-ritos - Nightmare on Elm Meat Flavor","Descuento Getmore's Burritos - Strawberrito Churro Flavor","Descuento Getmore's Burritos - Beff and Bean Flavor")

/obj/item/weapon/reagent_containers/food/snacks/dangles/getmore

/obj/item/weapon/reagent_containers/food/snacks/dangles/getmore/New()
	..()
	name = "Getmore " + name

/obj/item/weapon/reagent_containers/food/condiment/small/discount/getmore
	name = "\improper Getmore Special Sauce"
	desc = "Getmore brings you its very own special blend of delicious ingredients in one discount sauce!"

/obj/item/weapon/storage/lunchbox/discount/getmore
	name = "\improper Getmore Discount Lunchbox"
	desc = "A little cardboard lunchbox. This one has the Getmore Discount logo printed on the side. It looks very flimsy, and has a musty smell even when empty."

// --- Premium Dan's Vendor ---
/obj/machinery/vending/discount/New()
	name = "\improper Premium Dan's"
	desc = "A pristine vending machine offering premium snacks from the renowned 'Premium Dan' label. Only the finest for Syndicate personnel."
	icon_state = "discountalt"
	product_slogans = list(
		"Premium Dan, the quality man!",
		"Try our award-winning chocolate bars!",
		"You deserve the best. You deserve Premium Dan's.",
		"Quality over quantity!",
		"It's better than Getmore's!"
	)
	product_ads = list(
		"Premium Dan(tm) guarantees satisfaction with every bite.",
		"Have some more Premium Dan's!",
		"Best quality snacks straight from Mars.",
		"Try our new jerky!",
		"Oh my god it's so juicy!",
		"Premium candy for premium operatives!",
		"We love chocolate!",
		"Cheesie Honkers: Now even cheesier!"
	)
	vend_reply = "Enjoy your premium selection."
	products = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/premiumdan = 6,
		/obj/item/weapon/reagent_containers/food/snacks/chips/premiumdan = 6,
		/obj/item/weapon/reagent_containers/food/snacks/sosjerky/premiumdan = 6,
		/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie/premiumdan = 6,
		/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers/premiumdan = 6,
		/obj/item/weapon/reagent_containers/food/snacks/no_raisin/premiumdan = 6,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped/premiumdan = 6,
		/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/heating/premiumdan = 6,
		/obj/item/weapon/storage/lunchbox/plastic/nt/getmore/premiumdan = 6,
	)
	premium = list(
		/obj/item/weapon/reagent_containers/food/snacks/donkpocket/self_heating = 2,
		/obj/item/weapon/storage/pill_bottle/mint/nano/premiumdan = 3,
	)
	contraband = list(
		/obj/item/weapon/reagent_containers/pill/antitox = 10
	)
	prices = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/premiumdan = 8,
		/obj/item/weapon/reagent_containers/food/snacks/chips/premiumdan = 20,
		/obj/item/weapon/reagent_containers/food/snacks/sosjerky/premiumdan = 30,
		/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie/premiumdan = 8,
		/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers/premiumdan = 30,
		/obj/item/weapon/reagent_containers/food/snacks/no_raisin/premiumdan = 35,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped/premiumdan = 100,
		/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/heating/premiumdan = 10,
		/obj/item/weapon/storage/lunchbox/plastic/nt/getmore/premiumdan = 10,
		/obj/item/weapon/reagent_containers/pill/antitox = 10,
	)
	..()

/obj/machinery/vending/discount/update_icon()
	if(stat & BROKEN)
		icon_state = "discountalt-broken"
	else if(stat & (NOPOWER|FORCEDISABLE))
		icon_state = "discountalt-off"
	else
		icon_state = "discountalt"
		if(moody_state)
			update_moody_light('icons/lighting/moody_lights.dmi', moody_state)
		set_light(light_range_on, light_power_on)

// --- Getmore Discount "Chocolate" Vendor ---
/obj/machinery/vending/snack/New()
	name = "\improper Getmore Discount \"Chocolate\" And Snacks"
	desc = "A vending machine containing questionable 'snacks'. The Getmore label has seen better days."
	icon_state = "snackalt"
	product_slogans = list(
		"Getmore Discount: He's the... man?",
		"There ain't nothing better than a bite of mystery!",
		"Don't listen to those other machines, buy our product!",
		"Quantity over quality!",
		"Don't listen to those eggheads at the CDC, buy now!"
	)
	product_ads = list(
		"Getmore Discount(tm) is not responsible for any damages caused by misuse of its product.",
		"Try our discount chocolate! It's... chocolate-adjacent!",
		"Getmoritos: The bold choice!",
		"Discount burgers: Now with 15% more burger!",
		"Getmore Dangles: Dangerously cheesy. Emphasis on dangerous.",
		"Cheap raisins! They're raisins! Probably!",
		"Have a snack. We dare you."
	)
	products = list(
		/obj/item/weapon/reagent_containers/food/snacks/discountchocolate/getmore = 6,
		/obj/item/weapon/reagent_containers/food/snacks/danitos/getmore = 6,
		/obj/item/weapon/reagent_containers/food/snacks/discountburger/getmore = 6,
		/obj/item/weapon/reagent_containers/food/drinks/discount_ramen/getmore = 6,
		/obj/item/weapon/reagent_containers/food/snacks/discountburrito/getmore = 6,
		/obj/item/weapon/reagent_containers/food/snacks/dangles/getmore = 6,
		/obj/item/weapon/reagent_containers/food/snacks/cheap_raisins = 6,
		/obj/item/weapon/reagent_containers/food/condiment/small/discount/getmore = 12,
		/obj/item/weapon/storage/lunchbox/discount/getmore = 6,
	)
	contraband = list(
		/obj/item/weapon/reagent_containers/food/snacks/syndicake = 4,
		/obj/item/weapon/reagent_containers/food/snacks/bustanuts = 4,
	)
	prices = list(
		/obj/item/weapon/reagent_containers/food/snacks/discountchocolate/getmore = 8,
		/obj/item/weapon/reagent_containers/food/snacks/danitos/getmore = 4,
		/obj/item/weapon/reagent_containers/food/snacks/discountburger/getmore = 5,
		/obj/item/weapon/reagent_containers/food/drinks/discount_ramen/getmore = 3,
		/obj/item/weapon/reagent_containers/food/snacks/discountburrito/getmore = 5,
		/obj/item/weapon/reagent_containers/food/snacks/dangles/getmore = 6,
		/obj/item/weapon/reagent_containers/food/snacks/cheap_raisins = 3,
		/obj/item/weapon/reagent_containers/food/condiment/small/discount/getmore = 1,
		/obj/item/weapon/storage/lunchbox/discount/getmore = 5,
	)
	..()

/obj/machinery/vending/snack/update_icon()
	if(stat & BROKEN)
		icon_state = "snackalt-broken"
	else if(stat & (NOPOWER|FORCEDISABLE))
		icon_state = "snackalt-off"
	else
		icon_state = "snackalt"
		if(moody_state)
			update_moody_light('icons/lighting/moody_lights.dmi', moody_state)
		set_light(light_range_on, light_power_on)

// Cigarette machine - Syndicate cigs (Shoalsticks, Red Suits) to default section,
// NT Standard cigs moved to contraband
/obj/machinery/vending/cigarette/New()
	products = list(
		/obj/item/weapon/storage/fancy/cigarettes/goldencarp = 10,
		/obj/item/weapon/storage/fancy/cigarettes/starlights = 10,
		/obj/item/weapon/storage/fancy/cigarettes/shoalsticks = 10,
		/obj/item/weapon/storage/fancy/cigarettes/redsuits = 10,
		/obj/item/weapon/storage/fancy/cigarettes/luckystrike = 10,
		/obj/item/weapon/storage/fancy/cigarettes = 10,
		/obj/item/weapon/storage/fancy/cigarettes/spaceports = 10,
		/obj/item/weapon/storage/fancy/matchbox = 10,
		/obj/item/weapon/lighter/random = 4,
	)
	contraband = list(
		/obj/item/weapon/lighter/zippo = 4,
		/obj/item/weapon/storage/fancy/cigarettes/ntstandard = 10,
	)
	prices = list(
		/obj/item/weapon/storage/fancy/cigarettes/goldencarp = 50,
		/obj/item/weapon/storage/fancy/cigarettes/starlights = 40,
		/obj/item/weapon/storage/fancy/cigarettes/shoalsticks = 20,
		/obj/item/weapon/storage/fancy/cigarettes/redsuits = 30,
		/obj/item/weapon/storage/fancy/cigarettes/luckystrike = 20,
		/obj/item/weapon/storage/fancy/cigarettes = 10,
		/obj/item/weapon/storage/fancy/cigarettes/spaceports = 10,
		/obj/item/weapon/storage/fancy/matchbox = 15,
		/obj/item/weapon/lighter/random = 10,
		/obj/item/weapon/storage/fancy/cigarettes/ntstandard = 30,
	)
	..()

// ===== JOB OVERRIDES =====
// Rename all departments and roles to darker Syndicate variants.
// Grant all-access to all department heads at roundstart.

// --- Command ---

/datum/job/captain/New()
	..()
	title = "Station Overseer"
	supervisors = "Syndicate High Command"

// Captain already has get_all_accesses()

/datum/job/hop/New()
	..()
	title = "Director of Operations"
	supervisors = "the station overseer"

/datum/job/hop/get_access()
	return get_all_accesses()

// --- Compliance (formerly Security) ---

/datum/job/hos/New()
	..()
	title = "Compliance Director"
	supervisors = "the station overseer"

/datum/job/hos/get_access()
	return get_all_accesses()

/datum/job/warden/New()
	..()
	title = "Detention Warden"
	supervisors = "the compliance director"

/datum/job/detective/New()
	..()
	title = "Compliance Investigator"
	supervisors = "the compliance director"

/datum/job/officer/New()
	..()
	title = "Compliance Officer"
	supervisors = "the compliance director"

// --- Bioprocessing (formerly Medical) ---

/datum/job/cmo/New()
	..()
	title = "Chief Bioprocessor"
	supervisors = "the station overseer"

/datum/job/cmo/get_access()
	return get_all_accesses()

/datum/job/doctor/New()
	..()
	title = "Bioprocessing Technician"
	supervisors = "the chief bioprocessor"

/datum/job/chemist/New()
	..()
	title = "Compound Synthesizer"
	supervisors = "the chief bioprocessor"

/datum/job/geneticist/New()
	..()
	title = "Gene Splicer"
	supervisors = "the chief bioprocessor and the exploitation director"

/datum/job/virologist/New()
	..()
	title = "Pathogen Specialist"
	supervisors = "the chief bioprocessor"

/datum/job/paramedic/New()
	..()
	title = "Field Medic"
	supervisors = "the chief bioprocessor"

/datum/job/orderly/New()
	..()
	title = "Ward Enforcer"
	supervisors = "the chief bioprocessor"

// --- Infrastructure (formerly Engineering) ---

/datum/job/chief_engineer/New()
	..()
	title = "Infrastructure Overseer"
	supervisors = "the station overseer"

/datum/job/chief_engineer/get_access()
	return get_all_accesses()

/datum/job/engineer/New()
	..()
	title = "Infrastructure Technician"
	supervisors = "the infrastructure overseer"

/datum/job/atmos/New()
	..()
	title = "Atmosphere Regulator"
	supervisors = "the infrastructure overseer"

/datum/job/mechanic/New()
	..()
	title = "Systems Mechanic"
	supervisors = "the exploitation director and the infrastructure overseer"

// --- Exploitation (formerly Science) ---

/datum/job/rd/New()
	..()
	title = "Exploitation Director"
	supervisors = "the station overseer"

/datum/job/rd/get_access()
	return get_all_accesses()

/datum/job/scientist/New()
	..()
	title = "Exploitation Researcher"
	supervisors = "the exploitation director"

/datum/job/xenoarchaeologist/New()
	..()
	title = "Artifact Plunderer"
	supervisors = "the exploitation director"

/datum/job/xenobiologist/New()
	..()
	title = "Specimen Handler"
	supervisors = "the exploitation director"

/datum/job/roboticist/New()
	..()
	title = "Cybernetics Fabricator"
	supervisors = "the exploitation director"

// --- Logistics (formerly Cargo) ---

/datum/job/qm/New()
	..()
	title = "Procurement Officer"
	supervisors = "the director of operations"

/datum/job/cargo_tech/New()
	..()
	title = "Logistics Technician"
	supervisors = "the procurement officer and the director of operations"

/datum/job/mining/New()
	..()
	title = "Resource Extractor"
	supervisors = "the procurement officer and the director of operations"

// --- Operations (formerly Civilian) ---

/datum/job/bartender/New()
	..()
	title = "Morale Officer"
	supervisors = "the director of operations"

/datum/job/chef/New()
	..()
	title = "Sustenance Coordinator"
	supervisors = "the director of operations"

/datum/job/hydro/New()
	..()
	title = "Organic Cultivator"
	supervisors = "the director of operations"

/datum/job/clown/New()
	..()
	title = "Psychological Warfare Agent"
	supervisors = "the director of operations"

/datum/job/mime/New()
	..()
	title = "Silent Operative"
	supervisors = "the director of operations"

/datum/job/janitor/New()
	..()
	title = "Sanitation Enforcer"
	supervisors = "the director of operations"

/datum/job/librarian/New()
	..()
	title = "Archives Keeper"
	supervisors = "the director of operations"

/datum/job/iaa/New()
	..()
	title = "Internal Compliance Agent"
	supervisors = "Syndicate Law, the Syndicate Board, and the station overseer"

/datum/job/chaplain/New()
	..()
	title = "Cult Liaison"
	supervisors = "the Dark Powers, the director of operations too"

// ===== OUTFIT ICON OVERRIDES =====
// Override clothing icons to use Syndicate-themed sprites from syndicate.dmi

// --- Syndicate Department Hats ---

/obj/item/clothing/head/syndistation
	icon = 'icons/obj/clothing/syndicate.dmi'

/obj/item/clothing/head/syndistation/sci
	name = "exploitation beret"
	icon_state = "hatsci"

/obj/item/clothing/head/syndistation/sec
	name = "compliance cap"
	icon_state = "hatsec"

/obj/item/clothing/head/syndistation/eng
	name = "infrastructure hardhat"
	icon_state = "hateng"

/obj/item/clothing/head/syndistation/cargo
	name = "logistics cap"
	icon_state = "hatcargo"

/obj/item/clothing/head/syndistation/service
	name = "operations cap"
	icon_state = "hatservice"

/obj/item/clothing/head/syndistation/base
	name = "syndicate cap"
	icon_state = "hatbase"

// --- Uniform Icon Overrides ---

// Command
/obj/item/clothing/under/rank/captain/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "syndi_head_cap"
	item_state = "syndi_head_cap"
	_color = "syndi_head_cap"

/obj/item/clothing/under/rank/head_of_personnel/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "syndi_head_hop"
	item_state = "syndi_head_hop"
	_color = "syndi_head_hop"

// Science
/obj/item/clothing/under/rank/research_director/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "syndi_head_rd"
	item_state = "syndi_head_rd"
	_color = "syndi_head_rd"

/obj/item/clothing/under/rank/scientist/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "uniformsci"
	item_state = "uniformsci"
	_color = "uniformsci"

// Security
/obj/item/clothing/under/rank/security/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "uniformsec"
	item_state = "uniformsec"
	_color = "uniformsec"

// Head of Security
/obj/item/clothing/under/rank/head_of_security/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "syndi_head_hos"
	item_state = "syndi_head_hos"
	_color = "syndi_head_hos"

// Engineering
/obj/item/clothing/under/rank/chief_engineer/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "syndi_head_ce"
	item_state = "syndi_head_ce"
	_color = "syndi_head_ce"

/obj/item/clothing/under/rank/engineer/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "uniformeng"
	item_state = "uniformeng"
	_color = "uniformeng"

// Cargo
/obj/item/clothing/under/rank/cargo/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "syndi_head_qm"
	item_state = "syndi_head_qm"
	_color = "syndi_head_qm"

/obj/item/clothing/under/rank/cargotech/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "uniformcargo"
	item_state = "uniformcargo"
	_color = "uniformcargo"

// Service
/obj/item/clothing/under/rank/bartender/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "uniformservice"
	item_state = "uniformservice"
	_color = "uniformservice"

/obj/item/clothing/under/rank/chef/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "uniformservice"
	item_state = "uniformservice"
	_color = "uniformservice"

/obj/item/clothing/under/rank/hydroponics/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "uniformservice"
	item_state = "uniformservice"
	_color = "uniformservice"

/obj/item/clothing/under/rank/botany/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "uniformservice"
	item_state = "uniformservice"
	_color = "uniformservice"

/obj/item/clothing/under/rank/beekeeper/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "uniformservice"
	item_state = "uniformservice"
	_color = "uniformservice"

/obj/item/clothing/under/rank/gardener/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "uniformservice"
	item_state = "uniformservice"
	_color = "uniformservice"

/obj/item/clothing/under/rank/janitor/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "uniformservice"
	item_state = "uniformservice"
	_color = "uniformservice"

/obj/item/clothing/under/rank/chaplain/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "uniformservice"
	item_state = "uniformservice"
	_color = "uniformservice"

// Bridge Officer / IAA
/obj/item/clothing/under/bridgeofficer/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "syndi_uniform_alt"
	item_state = "syndi_uniform_alt"
	_color = "syndi_uniform_alt"

/obj/item/clothing/under/rank/internalaffairs/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "syndi_uniform_alt"
	item_state = "syndi_uniform_alt"
	_color = "syndi_uniform_alt"

/obj/item/clothing/under/lawyer/bluesuit/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "syndi_uniform_alt"
	item_state = "syndi_uniform_alt"
	_color = "syndi_uniform_alt"

// Assistant (includes all alt-title subtypes: tech, intern, research, cadet)
/obj/item/clothing/under/color/grey/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "uniformbase"
	item_state = "uniformbase"
	_color = "uniformbase"

// --- Shoe Icon Overrides ---

/obj/item/clothing/shoes/black/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "shoes"
	item_state = "shoes"
	_color = "shoes"

/obj/item/clothing/shoes/brown/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "shoes"
	item_state = "shoes"
	_color = "shoes"

/obj/item/clothing/shoes/white/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "shoes"
	item_state = "shoes"
	_color = "shoes"

/obj/item/clothing/shoes/jackboots/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "shoes"
	item_state = "shoes"
	_color = "shoes"

/obj/item/clothing/shoes/workboots/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "shoes"
	item_state = "shoes"
	_color = "shoes"

/obj/item/clothing/shoes/laceup/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "shoes"
	item_state = "shoes"
	_color = "shoes"

/obj/item/clothing/shoes/leather/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "shoes"
	item_state = "shoes"
	_color = "shoes"

/obj/item/clothing/shoes/centcom/New()
	..()
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "shoes"
	item_state = "shoes"
	_color = "shoes"

// --- Outfit Hat Additions ---
// Add syndicate department hats to outfit loadouts via pre_equip hook.
// pre_equip runs before items_to_spawn is read in equip(), so modifying
// the "Default" list here correctly injects hats into the equip flow.
// Species-specific lists (plasmaman, vox) are unaffected and keep
// their own helmets.

/datum/outfit/pre_equip(var/mob/living/carbon/human/H)
	var/hat_type
	switch(associated_job)
		// Exploitation (Science)
		if(/datum/job/rd, /datum/job/scientist, /datum/job/xenoarchaeologist, /datum/job/xenobiologist, /datum/job/roboticist)
			hat_type = /obj/item/clothing/head/syndistation/sci
		// Compliance (Security)
		if(/datum/job/hos, /datum/job/warden, /datum/job/detective, /datum/job/officer)
			hat_type = /obj/item/clothing/head/syndistation/sec
		// Infrastructure (Engineering)
		if(/datum/job/chief_engineer, /datum/job/engineer, /datum/job/atmos, /datum/job/mechanic)
			hat_type = /obj/item/clothing/head/syndistation/eng
		// Logistics (Cargo)
		if(/datum/job/qm, /datum/job/cargo_tech, /datum/job/mining)
			hat_type = /obj/item/clothing/head/syndistation/cargo
		// Operations (Service)
		if(/datum/job/bartender, /datum/job/chef, /datum/job/hydro, /datum/job/janitor, /datum/job/chaplain, /datum/job/librarian, /datum/job/iaa)
			hat_type = /obj/item/clothing/head/syndistation/service
		// Base personnel
		else
			hat_type = /obj/item/clothing/head/syndistation
	if(hat_type)
		items_to_spawn["Default"][slot_head_str] = hat_type

/obj/item/clothing/head/syndistation
	icon = 'icons/obj/clothing/syndicate.dmi'
	icon_state = "hatbase"
	desc = "A standard issue Syndicate cap, issued to all personnel."

/obj/item/clothing/head/syndistation/sci
	icon_state = "hatsci"
	desc = "A beret worn by members of the exploitation department."

/obj/item/clothing/head/syndistation/sec
	icon_state = "hatsec"
	desc = "A cap worn by members of the compliance department."

/obj/item/clothing/head/syndistation/eng
	icon_state = "hateng"
	desc = "A hardhat worn by members of the infrastructure department."

/obj/item/clothing/head/syndistation/cargo
	icon_state = "hatcargo"
	desc = "A cap worn by members of the logistics department."

/obj/item/clothing/head/syndistation/service
	icon_state = "hatservice"
	desc = "A cap worn by members of the operations department."


// ===== NANOTRASEN INFILTRAITOR (formerly Syndicate Traitor) =====

/datum/dynamic_ruleset/roundstart/traitor/New()
	..()
	name = "Nanotrasen Infiltraitors"

/datum/role/traitor/Greet(var/greeting, var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', "nano-logo")
	switch(greeting)
		if(GREET_ROUNDSTART)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Nanotrasen agent, an Infiltraitor.</span>")
		if(GREET_AUTOTATOR)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are now a Nanotrasen Infiltraitor.<br>Your memory clears up as you remember your identity as a sleeper agent of Nanotrasen. It's time to undermine the Syndicate from within.</span>")
		if(GREET_LATEJOIN)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Nanotrasen Infiltraitor.<br>As a Nanotrasen agent, you are to infiltrate the Syndicate crew and accomplish your objectives at all cost.</span>")
		if(GREET_LATEJOINMADNESS)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Nanotrasen Infiltraitor, BUT...</span>")
			to_chat(antag.current, "<span class='danger'>Nanotrasen has baited Syndicate operatives aboard this station along with the system's worst examples of scum and villainy.</span>")
			to_chat(antag.current, "<span class='danger'>Find the heads of staff and make their life and un-life a living hell.</span>")
			to_chat(antag.current, "<span class='danger'>Beware of the station's other unruly occupants.</span>")
		if(GREET_SYNDBEACON)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You have joined the ranks of Nanotrasen and become a traitor to the Syndicate!</span>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Nanotrasen Infiltraitor.</span>")

	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")


// Populate the Syndicate store with items from /datum/storeitem/syndicate
/datum/store/New()
	for(var/itempath in subtypesof(/datum/storeitem/syndicate))
		var/datum/storeitem/instance = new itempath()
		if(!items[instance.category])
			items[instance.category] = list()
		items[instance.category] += instance
		CHECK_TICK

/datum/storeitem/syndicate

/////////////////////////////
// Syndicate Food
/////////////////////////////
/datum/storeitem/syndicate/syndie_lunch
	name = "Syndicate Packed Lunch"
	desc = "A hearty meal packed by the HQ service cyborg. Premium ingredients only."
	typepath = /obj/item/weapon/storage/lunchbox/metal/syndie/pre_filled
	cost = 50
	category = "Food"

/datum/storeitem/syndicate/discount_lunch
	name = "Discount Dan's Lunchbox"
	desc = "A pre-filled Discount Dan's lunchbox. Contents may or may not be edible."
	typepath = /obj/item/weapon/storage/lunchbox/discount/pre_filled
	cost = 15
	category = "Food"

/datum/storeitem/syndicate/syndicake
	name = "Syndi-Cake"
	desc = "A delicious red velvet cake baked with love by the Syndicate Snack Division."
	typepath = /obj/item/weapon/reagent_containers/food/snacks/syndicake
	cost = 20
	category = "Food"

/////////////////////////////
// Syndicate Tools
/////////////////////////////
/datum/storeitem/syndicate/toolbox
	name = "Syndicate Toolbox"
	desc = "A sinister black and red toolbox loaded with a full set of quality tools. Heavier than standard issue."
	typepath = /obj/item/weapon/storage/toolbox/syndicate
	cost = 40
	category = "Tools"

/datum/storeitem/syndicate/soap
	name = "Syndicate Soap"
	desc = "An untrustworthy bar of soap. Smells of fear. Removes blood stains and DNA evidence."
	typepath = /obj/item/weapon/soap/syndie
	cost = 15
	category = "Tools"

/////////////////////////////
// Syndicate Clothing
/////////////////////////////
/datum/storeitem/syndicate/chameleon_jumpsuit
	name = "Chameleon Jumpsuit"
	desc = "A jumpsuit capable of imitating any uniform on the crew roster. Standard issue for field agents."
	typepath = /obj/item/clothing/under/chameleon
	cost = 60
	category = "Clothing"

/datum/storeitem/syndicate/noslip_shoes
	name = "Chameleon No-Slip Shoes"
	desc = "Species-flexible shoes that prevent slipping and can mimic the appearance of any footwear."
	typepath = /obj/item/clothing/shoes/syndigaloshes
	cost = 60
	category = "Clothing"

/datum/storeitem/syndicate/voice_changer
	name = "Chameleon Voice Changer"
	desc = "A face mask that synthesizes a voice based on your equipped ID, or scrambles it if none is worn."
	typepath = /obj/item/clothing/mask/gas/voice
	cost = 100
	category = "Clothing"

/datum/storeitem/syndicate/raincoat
	name = "Raincoat"
	desc = "It's hip to be square! Fireaxe not included."
	typepath = /obj/item/clothing/suit/raincoat
	cost = 10
	category = "Clothing"

/datum/storeitem/syndicate/knuckles
	name = "Spiked Knuckles"
	desc = "A pair of spiked metal knuckles. For when diplomacy fails."
	typepath = /obj/item/clothing/gloves/knuckles/spiked
	cost = 80
	category = "Clothing"

/////////////////////////////
// Syndicate Gadgets
/////////////////////////////
/datum/storeitem/syndicate/agent_id
	name = "Agent ID Card"
	desc = "A programmable ID card. Modify your identity on the fly and scan other cards to copy their access."
	typepath = /obj/item/weapon/card/id/syndicate
	cost = 80
	category = "Gadgets"

/datum/storeitem/syndicate/smokebombs
	name = "Smoke Bombs"
	desc = "A package of 8 instant-action smoke bombs disguised as harmless snap-pops. Just throw!"
	typepath = /obj/item/weapon/storage/box/syndie_kit/smokebombs
	cost = 50
	category = "Gadgets"

/datum/storeitem/syndicate/emp_flashlight
	name = "EMP Flashlight"
	desc = "A functional flashlight that delivers weak EMP pulses. 4 charges, recharges in 30 seconds."
	typepath = /obj/item/device/flashlight/emp
	cost = 80
	category = "Gadgets"

/datum/storeitem/syndicate/decoy_balloon
	name = "Decoy Balloon"
	desc = "Inflating this balloon instantly creates a perfect visual copy of you. Fragile but convincing."
	typepath = /obj/item/toy/balloon/decoy
	cost = 20
	category = "Gadgets"

/datum/storeitem/syndicate/dna_scrambler
	name = "DNA Scrambler"
	desc = "A single-use syringe that permanently randomizes your appearance, name, fingerprints, and DNA."
	typepath = /obj/item/weapon/dnascrambler
	cost = 100
	category = "Gadgets"

/////////////////////////////
// Syndicate Implants
/////////////////////////////
/datum/storeitem/syndicate/compressed_matter_implant
	name = "Compressed Matter Implant"
	desc = "An implant that stores one item inside your body, retrievable with a gesture."
	typepath = /obj/item/weapon/storage/box/syndie_kit/imp_compress
	cost = 150
	category = "Implants"

/////////////////////////////
// Syndicate Luxury
/////////////////////////////
/datum/storeitem/syndicate/space_suit
	name = "Syndicate Space Suit"
	desc = "The iconic red Syndicate EVA suit. Less encumbering than NT variants. Fits in backpacks."
	typepath = /obj/item/weapon/storage/box/syndie_kit/space
	cost = 100
	category = "Luxury"

/datum/storeitem/syndicate/thermal_glasses
	name = "Thermal Imaging Glasses"
	desc = "Modified optical scanners with thermal vision. Spot organics through walls and in darkness."
	typepath = /obj/item/clothing/glasses/hud/thermal/syndi
	cost = 150
	category = "Luxury"

/datum/storeitem/syndicate/trophy_belt
	name = "Trophy Belt"
	desc = "A leather belt crafted to hold severed heads and limbs. For the ambitious go-getter."
	typepath = /obj/item/weapon/storage/belt/skull
	cost = 80
	category = "Luxury"

/datum/storeitem/syndicate/pickpocket_gloves
	name = "Pickpocket's Gloves"
	desc = "Sleek gloves for sneakily stripping items off people without alerting them."
	typepath = /obj/item/clothing/gloves/black/thief
	cost = 100
	category = "Luxury"

/datum/storeitem/syndicate/balloon
	name = "Syndicate Balloon"
	desc = "A useless red balloon with the Syndicate logo. A bold statement of factional pride."
	typepath = /obj/item/toy/syndicateballoon
	cost = 200
	category = "Luxury"

/datum/storeitem/syndicate/killbot
	name = "KILLbot"
	desc = "A phrase-spouting device perfectly suited for the loud operative's ego. Ages 550 and up."
	typepath = /obj/item/device/roganbot/killbot
	cost = 100
	stock = 1
	category = "Luxury"


// Evil fucknig turf overrides
/turf/simulated/wall
	icon = 'icons/turf/syndistation/walls.dmi'

/obj/structure/girder
	icon = 'icons/turf/syndistation/structures.dmi'


////////////////////////////////////////////////////////////////
#include "syndistation.dmm"
#endif
