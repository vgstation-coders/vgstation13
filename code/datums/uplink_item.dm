var/list/uplink_items = list()

var/list/discounted_items_of_the_round = list()

/proc/pick_discounted_items()
	// Make sure to clear it.
	var/list/item_list = list()

	var/list/static/forbidden_items = list(
		/datum/uplink_item/badass/bundle,
		/datum/uplink_item/badass/random,
		/datum/uplink_item/badass/experimental_gear,
		/datum/uplink_item/implants/uplink,
	)

	var/list/traitor_items = subtypesof(/datum/uplink_item)
	var/list/possible_picks = list()
	for (var/thing in traitor_items)
		var/datum/uplink_item/u_item = thing
		if(initial(u_item.cost) <= 1) // no point discounting these
			continue
		if (thing in forbidden_items)
			continue
		if (initial(u_item.item))
			possible_picks += thing

	for (var/i = 1 to 3)
		var/picked = pick(possible_picks)
		possible_picks -= picked
		item_list += picked
		world.log << "Picked: [picked]"

	discounted_items_of_the_round = item_list

/proc/get_uplink_items()
	// If not already initialized..
	if(!uplink_items.len)

		// Fill in the list	and order it like this:
		// A keyed list, acting as categories, which are lists to the datum.

		var/list/concrete_items = list()
		for (var/thing in discounted_items_of_the_round)
			concrete_items += new thing

		uplink_items["Discounted Surplus"] = concrete_items

		for(var/item in typesof(/datum/uplink_item))

			var/datum/uplink_item/I = new item()
			if(!I.item)
				continue
			if(I.only_on_month)
				if(time2text(world.realtime,"MM") != I.only_on_month)
					continue
			if(I.only_on_day)
				if(time2text(world.realtime,"DD") != I.only_on_day)
					continue

			if(!uplink_items[I.category])
				uplink_items[I.category] = list()

			uplink_items[I.category] += I

	return uplink_items

// You can change the order of the list by putting datums before/after one another OR
// you can use the last variable to make sure it appears last, well have the category appear last.

/datum/uplink_item
	var/name = "item name"
	var/category = "item category"
	var/desc = "Item Description"
	var/item = null
	var/cost = 0
	var/discounted_cost = 0
	var/abstract = 0
	var/list/jobs_with_discount = list() //Jobs in this list get the discount price.
	var/list/jobs_exclusive = list() //If empty, does nothing. If not empty, ONLY jobs in this list can buy this item.
	var/list/jobs_excluded = list() //Jobs in this list cannot buy this item at all.
	var/list/roles_exclusive = list() //If empty, does nothing. If not empty, ONLY roles in this list can buy this item.
	var/available_for_traitors = TRUE
	var/available_for_nuke_ops = TRUE
	var/only_on_month	//two-digit month as string
	var/only_on_day		//two-digit day as string
	var/num_in_stock = 0	// Number of times this can be bought, globally. 0 is infinite
	var/times_bought = 0
	var/refundable = FALSE
	var/refund_path = null // Alternative path for refunds, in case the item purchased isn't what is actually refunded (Bombs and such).
	var/refund_amount // specified refund amount in case there needs to be a TC penalty for refunds.

/datum/uplink_item/proc/get_cost(var/user_job, var/user_species, var/cost_modifier = 1)
	if(gives_discount(user_job) || gives_discount(user_species))
		. = discounted_cost
	else
		. = cost
	// 50% discount for items of the day
	if (is_type_in_list(src, discounted_items_of_the_round))
		. = cost*0.5
	. = Ceiling(. * cost_modifier) //"." is our return variable, effectively the same as doing "var/X", working on X, then returning X

/datum/uplink_item/proc/gives_discount(var/user_job)
	return user_job && jobs_with_discount.len && jobs_with_discount.Find(user_job)

/datum/uplink_item/proc/available_for_job(var/user_job)
	if(!user_job)
		return TRUE
	return !(jobs_exclusive.len && !jobs_exclusive.Find(user_job)) && !(jobs_excluded.len && jobs_excluded.Find(user_job))

//This will get called that is essentially a New() by default.
//Use this to make New()s that have extra conditions, such as bundles
//Make sure to add a return or else it will break a part of buy()
/datum/uplink_item/proc/new_uplink_item(var/new_item, var/turf/location, mob/user)
	return new new_item(location)

/datum/uplink_item/proc/spawn_item(var/turf/loc, datum/component/uplink/U, mob/user)
	if(!available_for_job(U.job) && !available_for_job(U.species))
		message_admins("[key_name(user)] tried to purchase \the [src.name] from their uplink despite not being available to them! (Job: [U.job]) (Species: [U.species]) ([formatJumpTo(get_turf(U))])")
		return
	if(U.nuke_ops_inventory && !available_for_nuke_ops)
		message_admins("[key_name(user)] tried to purchase \the [src.name] from their uplink despite being a nuclear operative")
		return
	U.telecrystals -= max(get_cost(U.job, U.species), 0)
	feedback_add_details("traitor_uplink_items_bought", name)
	return new_uplink_item(item, loc, user)

/datum/uplink_item/proc/buy(datum/component/uplink/U, var/mob/user)
	if(!istype(U))
		return 0

	if (user.stat || user.restrained())
		return 0

	if (!( istype(user, /mob/living/carbon/human)))
		return 0

	if(num_in_stock && times_bought >= num_in_stock)
		to_chat(user, "<span class='warning'>This item is out of stock.</span>")
		return 0

	// If the uplink's holder is in the user's contents
	var/obj/item/holder = U.parent
	if ((holder in user.contents) || (in_range(holder, user) && istype(holder.loc, /turf)))
		user.set_machine(U)
		if(get_cost(U.job, U.species) > U.telecrystals)
			return 0

		var/O = spawn_item(get_turf(user), U, user)
		var/obj/I = null
		var/datum/uplink_item/UI = null
		if(isobj(O))
			I = O
		else if(istype(O,/datum/uplink_item))
			UI = O
			I = new_uplink_item(UI.item,get_turf(user),user)
		if(!I)
			return 0
		on_item_spawned(I,user)
		var/icon/tempimage = icon(I.icon, I.icon_state)

		var/bundlename = name
		if(name == "Random Item" || name == "For showing that you are The Boss")
			if(UI)
				bundlename = UI.name
			else
				bundlename = I.name
		if(I.tag)
			bundlename = "[I.tag] bundle"
			I.tag = null
		if(ishuman(user))
			var/mob/living/carbon/human/A = user

			if(istype(I, /obj/item))
				A.put_in_any_hand_if_possible(I)

			U.purchase_log += {"[user] ([user.ckey]) bought <img class='icon' src='data:image/png;base64,[iconsouth2base64(tempimage)]'> [name] for [UI ? UI.get_cost(U.job, U.species, 0.5) : get_cost(U.job, U.species)]."}
			stat_collection.uplink_purchase(src, I, user)
			times_bought += 1

			if(user.mind)
				user.mind.spent_TC += get_cost(U.job, U.species)
				//First, try to add the uplink buys to any operative teams they're on. If none, add to a traitor role they have.
				var/datum/role/R = user.mind.GetRole(NUKE_OP)
				if(R)
					R.faction.faction_scoreboard_data += {"<img class='icon' src='data:image/png;base64,[iconsouth2base64(tempimage)]'> [bundlename] for [UI ? UI.get_cost(U.job, U.species, 0.5) : get_cost(U.job, U.species)] TC<BR>"}
				else
					R = user.mind.GetRole(TRAITOR)
					if(R)
						R.uplink_items_bought += {"<img class='icon' src='data:image/png;base64,[iconsouth2base64(tempimage)]'> [bundlename] for [UI ? UI.get_cost(U.job, U.species, 0.5) : get_cost(U.job, U.species)] TC<BR>"}
					else
						R = user.mind.GetRole(CHALLENGER)
						if(R)
							R.uplink_items_bought += {"<img class='icon' src='data:image/png;base64,[iconsouth2base64(tempimage)]'> [bundlename] for [UI ? UI.get_cost(U.job, U.species, 0.5) : get_cost(U.job, U.species)] TC<BR>"}
		return 1
	return 0

/datum/uplink_item/proc/on_item_spawned(var/obj/I, var/mob/user)
	return

/*
//
//	UPLINK ITEMS
//
*/
//Work in Progress, job specific antag tools

// NUKE OPS
// Any Syndicate item exclusive to Nuclear Operatives goes here

/datum/uplink_item/valentine
	category = "Valentine's Day Special!"
	only_on_month = "02"
	only_on_day = "14"

/datum/uplink_item/valentine/explosivechocolate
	name = "Explosive Chocolate Bar"
	desc = "A special Valentine's Day chocolate bar chock-full of Bicarodyne. For adding that little extra oompf to your hugs."
	item = /obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped/valentine/syndicate
	cost = 8

//Nuclear Operative exclusive items and (totally) discounted regular items for them
/datum/uplink_item/nukeprice
	category = "Nuclear Opeations Specials"
	jobs_exclusive = list("Nuclear Operative")

/datum/uplink_item/nukeprice/popout_cake
	name = "Pop-Out Cake"
	desc = "A massive and delicious cake, big enough to store a person inside. It is equipped with a one-use party horn and other special effects, and can be cut into edible slices in case of an emergency."
	item = /obj/structure/popout_cake
	cost = 6

/datum/uplink_item/nukeprice/teleporter
	name = "Teleporter Circuit Board"
	desc = "A printed circuit board that completes the teleporter onboard the mothership, allowing deployment onto any activated bluespace beacon. It is advised to test fire the teleporter before entering it or sending items through as malfunctions can occur."
	item = /obj/item/weapon/circuitboard/teleporter
	cost = 40

/datum/uplink_item/nukeprice/gatling
	name = "Gatling Gun"
	desc = "A huge man-portable minigun. Makes up for its lack of mobility and discretion with sheer firepower. Has a drum of 200 bullets and a flawless cooling action allowing for uninterrupted fire from start to end."
	item = /obj/structure/closet/crate/secure/weapon/experimental/gatling
	cost = 40

/datum/uplink_item/nukeprice/gatling_laser
	name = "Gatling Laser"
	desc = "A massive rapid-firing multiple-barrel laser. Can be reloaded quickly by swapping its internal cell. Spares not included."
	item = /obj/item/weapon/gun/energy/gatling
	cost = 60

/datum/uplink_item/nukeprice/nikita
	name = "Nikita RC Missile Launcher"
	desc = "A remote-controlled missile launcher, trades in raw explosive power for extreme steering precision, allowing it to make perfect turns around corners or turn around at will, or simply accelerate normally. Comes with four spare RC rockets."
	item = /obj/structure/closet/crate/secure/weapon/experimental/nikita
	cost = 40

/datum/uplink_item/nukeprice/hecate
	name = "PMG Hecate II Anti-Material Rifle"
	desc = "A .50 BMG anti-material sniper rifle. Anything between the barrel and the next three solid walls should be tenderized in short order. Comes with eight individual rounds, thermals and earmuffs."
	item = /obj/structure/closet/crate/secure/weapon/experimental/hecate
	cost = 40

/datum/uplink_item/nukeprice/dude_bombs_lmao
	name = "Modified Tank Transfer Valve"
	desc = "A small, expensive and powerful plasma-oxygen explosive attached with a timer assembly. Will trigger a massive explosion upon detonation, vaporizing the general area around the device. Handle with extreme care and keep away from fires and explosions."
	item = /obj/effect/spawner/newbomb/timer
	cost = 25
	refundable = TRUE

/datum/uplink_item/nukeprice/robot
	name = "Syndicate-modified Combat Robot Teleporter"
	desc = "A single-use teleporter used to deploy a syndicate robot that will help with your mission. Keep in mind that unlike NT silicons these don't have access to most of the station's machinery."
	item = /obj/item/weapon/robot_spawner/syndicate
	cost = 60
	refundable = TRUE

/datum/uplink_item/nukeprice/mecha
	name = "Syndicate Mass-Produced Assault Mecha 'Mauler'"
	desc = "A Heavy-duty combat unit. Not usually used by nuclear operatives due to its ridiculous pricetag and lack of stealth. Yet, against heavily-guarded stations, it might be just the thing." //Implying bombs aren't better.
	item = /obj/effect/spawner/mecha/mauler
	cost = 80

// DANGEROUS WEAPONS
// Any Syndicate item with applying lethal force to people while being very much detected (Ex: Revolver, E-Sword, Machete)

/datum/uplink_item/dangerous
	category = "Highly Visible and Dangerous Weapons"

/datum/uplink_item/dangerous/revolver
	name = "Loaded .357 Revolver"
	desc = "A traditional repeating handgun with seven chambers which fires .357 rounds. Can incapacitate most unarmored targets in two shots."
	item = /obj/item/weapon/gun/projectile/revolver
	cost = 12

/datum/uplink_item/dangerous/ammo
	name = ".357 Speedloader"
	desc = "A speedloader loaded with seven additional rounds for the .357 Revolver. Extra seven-piece boxes of .357 rounds can be made in a modified autolathe."
	item = /obj/item/weapon/storage/box/syndie_kit/ammo
	cost = 4

/datum/uplink_item/dangerous/sword
	name = "Energy Sword"
	desc = "The energy sword is a blade of pure energy able to easily cut through organics. The sword can be drawn and retracted from a small metal hilt that can be easily concealed, or linked to another sword for a double blade. Activating it produces a loud, distinctive noise."
	item = /obj/item/weapon/melee/energy/sword
	cost = 8

/datum/uplink_item/dangerous/machete
	name = "High-Frequency Machete"
	desc = "A high quality machete blade augmented with a high-frequency blade not dissimilar to the Energy Sword. When inactive, can be used as a powerful throwing weapon. Can be dual-wielded with another machete but will cause bloodlust until death."
	item = /obj/item/weapon/melee/energy/hfmachete
	cost = 8

/datum/uplink_item/dangerous/viscerator
	name = "Viscerator Grenade"
	desc = "A single grenade containing a pair of incredibly destructive viscerators and a basic flashbang mix on a five second timer. The viscerators will viscerate any non-Syndicate lifeforms in the area with extreme prejudice."
	item = /obj/item/weapon/grenade/spawnergrenade/manhacks/syndicate
	cost = 6

/datum/uplink_item/dangerous/caber //around 25 brute self damage and bleed if used without armor, generally crit if exploded against an unarmored victim
	name = "Ullapool Caber"
	desc = "A modern replica of the legendary weapon held by Tavish DeGroot, scanned after the DeGroot family so generously let us inspect them for mass production. This potato-masher grenade will explode when swung, but not when thrown. The safety grip makes dropping or throwing the Caber impossible whilst enabled and will not explode with the safeties disabled. EOD Suit not included."
	item = /obj/item/weapon/caber/
	cost = 10
	discounted_cost = 8
	//jobs_with_discount = list("Assistant")
	//would've liked to add a discount for dark skinned or nearsighted characters (closest to one eyed we have) but dunno how

/datum/uplink_item/dangerous/mech_killdozer
        name = "Killdozer Bundle"
        desc = "Three random weapons and a modkit that lets you turn a mining mech into an (almost) unstoppable machine of destruction."
        item = /obj/item/weapon/storage/box/syndie_kit/mech_killdozer
        cost = 10

// STEALTHY WEAPONS
// Any Syndicate item with applying lethal force to people without being easily detected (Ex: Syndicate Soap, Parapen, E-Bow)

/datum/uplink_item/stealthy_weapons
	category = "Stealthy and Inconspicuous Weapons"

/datum/uplink_item/stealthy_weapons/crossbow
	name = "Mini Energy Crossbow"
	desc = "A miniature energy crossbow small enough to both fit into a pocket and slip into a backpack unnoticed, making it hard to spot when firing. Fires up to five bolts tipped with a poisonous substance that stuns targets for a short period of time and recharges on its own."
	item = /obj/item/weapon/gun/energy/crossbow
	cost = 12
	discounted_cost = 10
	jobs_with_discount = list("Nuclear Operative")

/datum/uplink_item/stealthy_weapons/para_pen
	name = "Paralysis Pen"
	desc = "A functional pen containing a hidden syringe filled with a neuromuscular-blocking drug that paralyses a target and makes them appear dead to observers and basic medical scanners. Apply with a firm stabbing motion. The pen holds one dose of paralyzing mix and cannot be refilled."
	item = /obj/item/weapon/pen/paralysis
	cost = 8

/datum/uplink_item/stealthy_weapons/butterfly
	name = "Butterfly Knife"
	desc = "A butterfly knife containing a deadly viscerator. It can be flipped closed to conceal the blade and open to deploy the viscerator. The viscerator will self-destruct after 20 seconds but the knife will reconstruct a new one every 25 seconds."
	item = /obj/item/weapon/butterflyknife/viscerator
	cost = 7

/datum/uplink_item/stealthy_weapons/detomatix
	name = "Detomatix PDA Cartridge"
	desc = "When inserted into a PDA, gives you four charges allowing you to detonate PDAs of crewmembers who have messaging enabled. The concussive effect from the explosion will lightly wound the recipient and deafen them for a while. Has a chance to backfire and detonate your PDA."
	item = /obj/item/weapon/cartridge/syndicate
	cost = 6

/datum/uplink_item/stealthy_weapons/framecart
	name = "F.R.A.M.E PDA Cartridge"
	desc = "When inserted into a PDA, gives you four charges allowing you to create a fake uplink on PDAs of crewmembers who have messaging enabled. The fake uplinks will use the same unlock code as your uplink if applicable, or else generate a new one. TC can also be inserted into the cartridge to send to the PDA"
	item = /obj/item/weapon/cartridge/syndifake
	cost = 6

/datum/uplink_item/stealthy_weapons/knuckles
	name = "Spiked Knuckles"
	desc = "A pair of spiked metal knuckles that can be worn directly on your hands in place of gloves, dramatically increasing damage done by your punches without giving any obvious signs to observers unless they inspect you more closely."
	item = /obj/item/clothing/gloves/knuckles/spiked
	cost = 2

/datum/uplink_item/stealthy_weapons/soap
	name = "Syndicate Soap"
	desc = "A sinister-looking bar of surfactant used to clean blood stains and other traces of misdoings and interfere with DNA collection. Doubles as a tool of Syndicate hygiene and a slipping hazard for split-second takedowns."
	item = /obj/item/weapon/soap/syndie
	cost = 1

// STEALTHY TOOLS
// Any Syndicate item that helps with concealing one's identity, avoiding detection or fleeing if caught, without lethal or stun applications

/datum/uplink_item/stealthy_tools
	category = "Stealth and Camouflage Items"

/datum/uplink_item/stealthy_tools/agent_card
	name = "Agent ID Card"
	desc = "A fully programmable ID card that can be modified without the help of an indentification computer, allowing one to craft a full identity on the fly. Starts with Assistant-level access but can accumulate more by scanning other ID cards. Modified ID chip blocks all AI tracking when equipped."
	item = /obj/item/weapon/card/id/syndicate
	cost = 2

/datum/uplink_item/stealthy_tools/chameleon_jumpsuit
	name = "Chameleon Jumpsuit"
	desc = "An innocuous-looking jumpsuit used to imitate any uniform on the Nanotrasen crew roster. Comes with a large selection of job-specific jumpsuits and can scan more via direct application. Dial can be concealed and is sensible to EMP blasts."
	item = /obj/item/clothing/under/chameleon
	cost = 2

/datum/uplink_item/stealthy_tools/syndigaloshes
	name = "Chameleon No-Slip Shoes"
	desc = "A pair of species-flexible shoes that can look and sound like any other piece of footwear. Protects against slipping on virtually all slippery surfaces and items with the exception of lubrication agents. Can be discerned as syndicate technology when examined closely."
	item = /obj/item/clothing/shoes/syndigaloshes
	cost = 2

/datum/uplink_item/stealthy_tools/voice_changer
	name = "Chameleon Voice Changer"
	desc = "An innocuous-looking face mask that can imitate a wide range of facewear and synthesize a voice based on your equipped ID. When no identification is worn, the mask will scramble and distort your voice to make it unrecognizable. Can be discerned as syndicate technology when examined closely."
	item = /obj/item/clothing/mask/gas/voice
	cost = 5
	discounted_cost = 4
	jobs_with_discount = list("Nuclear Operative")

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Chameleon Projector"
	desc = "When activated, will cloak the user into any portable item, concealing them and causing enemies and projectiles to pass over them. The projector can store the apperance of a specific item by scanning it. Allows limited movement, but dropping the projector or being interacted with will break the projection."
	item = /obj/item/device/chameleon
	cost = 6

/datum/uplink_item/stealthy_tools/dnascrambler
	name = "DNA Scrambler"
	desc = "A single-use syringe that will instantly and permanently randomize the appearance and name of the person injected including an unique genetic UI+UE, fingerprints and DNA sequence. While the new identity is perfect, it will not be registered to the crew manifest and the ID card will not update."
	item = /obj/item/weapon/dnascrambler
	cost = 4

/datum/uplink_item/stealthy_tools/cold_jumpsuit
	name = "Heat Sink Jumpsuit"
	desc = "A booby-trapped variant of the Chameleon Jumpsuit that quickly vents the wearer's body heat once equipped, causing them to suffer crippling hypothermia and usually pass out near instantly. Will usually result in user death unless assisted."
	item = /obj/item/clothing/under/chameleon/cold
	cost = 2

/datum/uplink_item/stealthy_tools/smoke_bombs
	name = "Instant Smoke Bombs"
	desc = "A package of 8 instant-action smoke bombs cleverly disguised as harmless snap-pops. The cover of smoke they create is large enough to cover most of a room within seconds. Pairs well with thermal imaging glasses or concealment items."
	item = /obj/item/weapon/storage/box/syndie_kit/smokebombs
	cost = 2

/datum/uplink_item/stealthy_tools/decoy_balloon
	name = "Decoy Balloon"
	desc = "A balloon that will instantly imitate your current look when inflated. Will not fool any tracking devices or HUD displays by itself but will hold up to a rapid examination. Doubles as an extra-strength punching mannequin, but vulnerable to projectiles and sharp implements."
	item = /obj/item/toy/balloon/decoy
	cost = 1

// DEVICE AND TOOLS
// Any Syndicate item that helps with hacking, low-key sabotage, damaging or subverting equipment (ex: Emag, camera bugs, EMP flashlight)

/datum/uplink_item/device_tools
	category = "Infiltration and Hacking Tools"

/datum/uplink_item/device_tools/emag
	name = "Cryptographic Sequencer"
	desc = "Colloquially referred to as an \"emag\". This modified ID card unlocks hidden Syndicate programming in most Nanotrasen electronic devices, subverting intended functions and bypassing most security mechanisms. Most machines will show signs of tampering during and after use and the emag itself is blatant when spotted."
	item = /obj/item/weapon/card/emag
	cost = 6

/datum/uplink_item/device_tools/emag/new_uplink_item(new_item, turf/location, mob/user)
	return new new_item(location, 1) //Uplink emags are infinite

/datum/uplink_item/device_tools/explosive_gum
	name = "Explosive Chewing Gum"
	desc = "A single stick of explosive chewing gum that detonates five seconds after you start chewing, perfectly disguised as regular gum. Make sure to pull it out of your mouth if you don't intend to explode with it. Gum can be stuck to objects and walls, but not other people."
	item = /obj/item/gum/explosive
	cost = 6

/datum/uplink_item/device_tools/flashlightemp
	name = "EMP Flashlight"
	desc = "A functional flashlight that can deliver an instantaneous weak EMP pulse on whatever or whomever you press it on on when lit. Holds up to 4 charges that recharges fully in 30 seconds. Devastating against Silicons and enemies using energy weapons or artificial organs."
	item = /obj/item/device/flashlight/emp
	cost = 4

/datum/uplink_item/device_tools/emp
	name = "EMP Grenade Box"
	desc = "A box that contains 5 EMP grenades ready for use. Useful to disrupt all Silicon lifeforms and any machinery or device near an exploding grenade, including all energy weapons and communications devices."
	item = /obj/item/weapon/storage/box/emps
	cost = 4

/datum/uplink_item/device_tools/toolbox
	name = "Fully Loaded Toolbox"
	desc = "A sinister-looking black and red toolbox loaded with a full set of tools, including a cable coil and a multitool. Insulated gloves are not included in the package. The toolbox itself is lined with a heavier material for more intense robusting action if caught by surprise or desperate."
	item = /obj/item/weapon/storage/toolbox/syndicate
	cost = 1

/datum/uplink_item/device_tools/bugdetector
	name = "Bug Detector & Camera Disabler"
	desc = "A functional multitool that can detect certain surveillance devices. Its screen changes color if the AI or a pAI can see you or if a tape recorder or voice analyzer is nearby. Conspicuous if currently detecting something. Examine it to see everything it detects. Activating it will temporarily disable all cameras nearby plus random ones across the camera network."
	item = /obj/item/device/multitool/ai_detect
	cost = 3

/datum/uplink_item/device_tools/space_suit
	name = "Syndicate Space Suit"
	desc = "A red syndicate space suit that is less encumbering than most Nanotrasen variants, fitting inside backpacks while providing a weapon and jetpack holster. Do note that the space suit is not only obvious but outright infamous and that most Nanotrasen crew will instantly recognize it as Syndicate."
	item = /obj/item/weapon/storage/box/syndie_kit/space
	cost = 4

/datum/uplink_item/device_tools/thermal
	name = "Thermal Imaging Glasses"
	desc = "A modified pair of Optical Meson Scanners frame fitted with thermal vision lenses, allowing you to spot organics through walls and in total darkness. Do note that they will not function as regular meson scanners in any way, shape or form."
	item = /obj/item/clothing/glasses/hud/thermal/syndi
	cost = 6

/datum/uplink_item/device_tools/surveillance
	name = "Camera Surveillance Kit"
	desc = "A kit consisting containing of five camera bugs hidden in a cigarette pack and a mobile TV receiver. Attach camera bugs to a camera to enable remote viewing with the receiver. Make sure to set an ID tag before applying to ensure stealthy bugging."
	item = /obj/item/weapon/storage/box/syndie_kit/surveillance
	cost = 6

/datum/uplink_item/device_tools/camerabugs
	name = "Camera Bugs"
	desc = "A cigarette pack containing five camera bugs hidden within. Requires a mobile TV receiver to use, intended to recharge the above bundle for extra surveillance coverage."
	item = /obj/item/device/radio/phone/surveillance
	cost = 4

/datum/uplink_item/device_tools/binary
	name = "Binary Translator Key"
	desc = "A key that, when inserted into any radio headset, allows you to listen to and talk with artificial intelligences and cybernetic organisms in Binary using the :b communications key. Screwdriver to replace encryption keys not included."
	item = /obj/item/device/encryptionkey/binary
	cost = 5

/datum/uplink_item/device_tools/cipherkey
	name = "Syndicate Encryption Key"
	desc = "A key that, when inserted into any radio headset, allows you to listen to and talk on all known Nanotrasen radio channels using their respective communications keys. Access to the Syndicate radio channel is also granted. Use :t to speak over the syndicate channel. Screwdriver to replace encryption keys not included."
	item = /obj/item/device/encryptionkey/syndicate/hacked
	cost = 4

/datum/uplink_item/device_tools/pdapinpointer
	name = "PDA Pinpointer"
	desc = "A pinpointer that can flawlessly track any PDA in the local space sector. Useful for locating assassination targets or other high-value targets that you can't find. Do note that it cannot track normal targets like the nuclear disk, and is obvious upon inspection."
	item = /obj/item/weapon/pinpointer/pdapinpointer
	cost = 4


// LOUD SABOTAGE
// Any Syndicate item that helps with high-level, destructive station-wide sabotage (Ex: Does Not Tip backdoor, Singularity Beacon, Power Sink, C-4)

/datum/uplink_item/sabotage_tools
	category = "Sabotage and Disruption Devices"

/datum/uplink_item/sabotage_tools/powersink
	name = "Power Sink"
	desc = "When screwed down onto an exposed wire connected to the power grid, this large device will cause an excessive and untraceable power load on the grid, causing a stationwide power failure in short order. Do note that the power sink can explode if it feeds too much power. Ordering this will send you a full power sink that can be carried but cannot be stored away. No screwdriver included, plan accordingly."
	item = /obj/item/device/powersink
	cost = 10

/datum/uplink_item/sabotage_tools/singularity_beacon
	name = "Singularity Beacon"
	desc = "When anchored to the floor and ran through a powered wire by hand, this large device will pull the singularity towards it regularly if it is loose from containment. Ordering this will send a small beacon that will teleport the singularity beacon to your location on activation. Beacon cannot be stored again, requires a lot of power to run, has an internal battery of one minute if power fails, and glows in the dark. No wrench included, plan accordingly."
	item = /obj/item/beacon/syndicate
	cost = 14

/datum/uplink_item/sabotage_tools/hacked_module
	name = "Hacked AI Freeform Module"
	desc = "When used on any AI Upload console, this module allows you to upload freeform laws to station Silicons that take priority over their core lawset and thus directly override it. Be careful with their wording as Silicons may look for loopholes to exploit or announce their subversion if not prevented to."
	item = /obj/item/weapon/aiModule/freeform/syndicate
	cost = 14

/datum/uplink_item/sabotage_tools/does_not_tip_note
	name = "\"Does Not Tip\" database backdoor"
	desc = "Lets you add or remove your station to the \"does not tip\" list kept by the Cargo workers at Central Command. Ensures that all pizza and beer orders will be poisoned from the moment the screen flashes red, without giving any obvious hints to such. Appears as a PDA until inspected more closely."
	item = /obj/item/device/does_not_tip_backdoor
	num_in_stock = 1
	cost = 10

/datum/uplink_item/sabotage_tools/loic_remote
	name = "Low Orbit Ion Cannon Remote"
	desc = "This device can activate a remote syndicate satellite every 15 minutes, generating a randomized law in the station's AI. Results may vary."
	item = /obj/item/device/loic_remote
	cost = 8
	discounted_cost = 6
	jobs_with_discount = SCIENCE_POSITIONS

/datum/uplink_item/sabotage_tools/radstorm_remote
	name = "Dirty Bomb Artillery Remote"
	desc = "This device can fire a remote syndicate bluespace artillery every 15 minutes, detonating a dirty bomb on direct intercept with the station, causing an artificial radstorm. The cannon will NOT fire if a radstom is already ongoing."
	item = /obj/item/device/radstorm_remote
	cost = 12
	discounted_cost = 10
	jobs_with_discount = ENGINEERING_POSITIONS

/datum/uplink_item/sabotage_tools/reportintercom
	name = "NT Central Command Report Falsifier"
	desc = "A command report intercom stolen from Nanotrasen Command that allows for a single fake Command Update to be sent. Ensure tastefulness so that the crew actually falls for the message. Item is particular obvious and will have to be manually discarded after use."
	item = /obj/item/device/reportintercom
	cost = 6
	discounted_cost = 4
	jobs_with_discount = list("Nuclear Operative")

/datum/uplink_item/sabotage_tools/plastic_explosives
	name = "Composition C-4"
	desc = "C-4 is plastic explosive of the common variety Composition C. Can be attached to any item or organic to reliably destroy it. Connect a signaler to its wiring to make it remotely detonable even when unplanted. Timer starts at 10 seconds but can be set to any length. Takes a few seconds to apply."
	item = /obj/item/weapon/c4
	cost = 4

/datum/uplink_item/sabotage_tools/megaphone
	name = "Mad Scientist Megaphone"
	desc = "A large megaphone with a communications chip, for making your demands known very loud and clear. This megaphone can broadcast to any known radio frequency. Can also optionally scramble your voice for ominous, anonymous threats. Make sure to strip your ID to avoid leaking your job to the communications system."
	item = /obj/item/device/megaphone/madscientist
	num_in_stock = 3
	cost = 1
	discounted_cost = 0
	jobs_with_discount = SCIENCE_POSITIONS

/datum/uplink_item/device_tools/radio_jammer
	name = "Radio Jammer"
	desc = "A device that disrupts all radio communication in nearby area. Guaranteed radio silence at point blank range, but effectiveness decreases with range. Requires a power cell for operation. Batteries and screwdriver not included."
	item = /obj/item/device/radio_jammer
	cost = 8

// EXTRATERRESTRIAL BLACK MARKET
// Weapons and gadgets from a spacefaring alien power that the Syndicate has acquired through unknown means (Only one item for now, more to come soon)

/datum/uplink_item/ayylmao
	category = "Extraterrestrial Black Market"

/datum/uplink_item/ayylmao/hdisintegrator
	name = "Heavy Disintegrator"
	desc = "A powerful military issue alien laser weapon. It has a primary firing mode capable of incapacitating most unarmored targets in three shots, and a secondary mode capable of instantaneously inducing nausea and vomiting."
	item = /obj/item/weapon/gun/energy/heavydisintegrator
	cost = 16
	discounted_cost = 12
	jobs_with_discount = list("Grey")

/datum/uplink_item/ayylmao/harmor
	name = "MDF Heavy Armor"
	desc = "A set of durable alien armor that excels at protecting the wearer from energy weapons and melee attacks. The armor plates were measured for a grey, but can be adjusted to fit a human as well. Not guaranteed to fit any other species. A soldier's uniform and boots are included with the kit."
	item = /obj/item/weapon/storage/box/syndie_kit/ayylmao_harmor
	cost = 4
	discounted_cost = 3
	jobs_with_discount = list("Grey")

/datum/uplink_item/ayylmao/mdfbelt
	name = "MDF Gear Belt"
	desc = "A mothership soldier's belt. Loaded with an ion pistol, first aid supplies, binoculars, and an extended oxygen supply tank for operating in breached areas. Keep away from water."
	item = /obj/item/weapon/storage/belt/mothership/partial_gear
	cost = 5
	discounted_cost = 4
	jobs_with_discount = list("Grey")

/datum/uplink_item/ayylmao/sdrone_grenade
	name = "Saucer Drone Grenade"
	desc = "A single grenade containing a payload of four mothership saucer drones. The drones are fragile, but equipped with a small cannon capable of firing scorch bolts. The drones will attack all unidentified lifeforms in the area except the grenade operator."
	item = /obj/item/weapon/grenade/spawnergrenade/mothershipdrone
	cost = 6
	discounted_cost = 4
	jobs_with_discount = list("Grey")

// IMPLANTS
// Any Syndicate item that gets implanted into the body goes here

/datum/uplink_item/implants
	category = "Implants"

/datum/uplink_item/implants/freedom
	name = "Freedom Implant"
	desc = "An implant usable after being injected into one's body. When activated with a specific body gesture that is indicated upon injection, it will instantly slip any restraints you are in. Has four effective uses."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_freedom
	cost = 5

/datum/uplink_item/implants/uplink
	name = "Uplink Implant"
	desc = "An implant usable after being injected into one's body. When activated with a specific body gesture that is chosen upon injection, it will discreetly open an uplink with 10 telecrystals loaded in. This uplink works even if you have been stripped naked."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_uplink
	cost = 16

/datum/uplink_item/implants/explosive
	name = "Explosive Implant"
	desc = "An implant usable after being injected into one's body. When activated with a specific speech line that is chosen upon injection, it will cause a large explosion from the implant that will gib the user and easily space a room. Can be triggered remotely using the communications system, avoid common words and phrases."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_explosive
	cost = 12

/datum/uplink_item/implants/compression
	name = "Compressed Matter Implant"
	desc = "An implant usable after being injected into one's body. When activated with a specific body gesture that is chosen upon injection, it will retrieve an item that was earlier compressed into the implant and put it in your hand. Can only compress portable, non-storage items, choose wisely."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_compress
	cost = 6


// POINTLESS BADASSERY
// "Misc" section for things that don't fit above

/datum/uplink_item/badass
	category = "Badassery"

/datum/uplink_item/badass/bundle
	name = "Syndicate Bundle"
	desc = "A Syndicate Bundle is a specific, themed selection of syndicate items including some that are otherwise impossible to acquire that arrive stored in a plain, unmarked box. These items are collectively worth significantly more than 14 telecrystals, but you do not know which bundle you will receive or what it will be useful for."
	item = /obj/item/weapon/storage/box/syndicate
	cost = 14

/datum/uplink_item/badass/bundle/new_uplink_item(new_item, location, user)
	var/list/conditions = list()
	if(isplasmaman(user))
		conditions += "plasmaman"
	return new new_item(location, conditions)

/datum/uplink_item/badass/balloon
	name = "For showing that you are The Boss"
	desc = "A useless red balloon with the syndicate logo printed on it which can blow even the deepest of covers. Otherwise looks similar to the Synidicate HUD pip that Nuclear Operatives would see."
	item = /obj/item/toy/syndicateballoon
	cost = 20

/datum/uplink_item/badass/trophybelt
 	name = "Trophy Belt"
 	desc = "An unremarkable leather belt specially crafted to hold whole heads and limbs in storage, perfect for serial killers and maimers with something to prove. Will not accept brains, so behead mindfully."
 	item = /obj/item/weapon/storage/belt/skull
 	cost = 4

/datum/uplink_item/badass/raincoat
 	name = "Raincoat"
 	desc = "It's hip to be square! Fireaxe not included."
 	item = /obj/item/clothing/suit/raincoat
 	cost = 1

/datum/uplink_item/badass/killbot
 	name = "KILLbot"
 	desc = "A phrase spouting device perfectly suited for the loud spree killer's ego."
 	item = /obj/item/device/roganbot/killbot
 	cost = 1

/datum/uplink_item/badass/experimental_gear
	name = "Syndicate Experimental Gear Bundle"
	desc = "A box that contains a randomly-selected experimental Syndicate gear, an unique state-of-the-art object. Satisfaction not guaranteed."
	item = /obj/item/weapon/storage/box/syndicate_experimental
	cost = 20

/datum/uplink_item/badass/random
	name = "Random Item"
	desc = "Picking this choice will send you a random item from anywhere in the list for half the normal cost. Useful for when you cannot think of a strategy to finish your objectives with, or cannot think of anything to begin with."
	item = /obj/item/weapon/storage/box/syndicate
	cost = 0

/datum/uplink_item/badass/random/spawn_item(var/turf/loc, var/datum/component/uplink/U, user)
	var/list/buyable_items = get_uplink_items()
	var/list/possible_items = list()

	for(var/category in buyable_items)
		for(var/datum/uplink_item/I in buyable_items[category])
			if(I == src)
				continue
			if(!I.available_for_job(U.job) && !I.available_for_job(U.species))
				continue
			if(!I.available_for_nuke_ops && U.nuke_ops_inventory)
				continue
			if(I.get_cost(U.job, U.species, 0.5) > U.telecrystals)
				continue
			possible_items += I

	if(possible_items.len)
		var/datum/uplink_item/I = pick(possible_items)
		U.telecrystals -= max(0, I.get_cost(U.job, U.species, 0.5))
		feedback_add_details("traitor_uplink_items_bought","RN")
		return I

/datum/uplink_item/badass/syndie_lunch
	name = "Syndicate Lunch"
	desc = "A service cyborg unit at HQ has packed you a lunch, ready to be delivered. You can't sabotage Nanotrasen on an empty stomach."
	item = /obj/item/weapon/storage/lunchbox/metal/syndie/pre_filled
	cost = 1

/datum/uplink_item/jobspecific/command_security
	category = "Security Specials"

/datum/uplink_item/jobspecific/command_security/syndicuffs
	name = "Syndicate Cuffs"
	desc = "A pair of handcuffs rigged with electronics and laced with a C4 charge. Can be toggled between explosion a few seconds after application and explosion immediately upon removal by pulling on the rotating arm. Concealed unless interacted with."
	item = /obj/item/weapon/handcuffs/syndicate
	cost = 5
	discounted_cost = 4
	jobs_with_discount = list("Security Officer", "Warden", "Head of Security")

/datum/uplink_item/jobspecific/command_security/syndietape_police
	name = "Syndicate Police Tape"
	desc = "A length of police tape rigged with adapative electronics that will wrap a segment of itself around the hands of any non-Syndicate personnel who attempts to cross or break it, instantly cuffing them with weak bindings. They shall not pass. Can be used 3 times before it runs out."
	item = /obj/item/taperoll/syndie/police
	cost = 10
	discounted_cost = 8
	jobs_with_discount = list("Security Officer", "Warden", "Head of Security")

/datum/uplink_item/jobspecific/command_security/syndibaton
	name = "Harm Baton"
	desc = "A stun baton modified with tesla relay coils capable of discharging high amount of shock to overload human pain registers. It can also use this energy to boost the impact of the baton."
	item = /obj/item/weapon/melee/baton/harm/loaded
	cost = 12
	discounted_cost = 9
	jobs_with_discount = list("Security Officer", "Warden", "Head of Security")

/datum/uplink_item/jobspecific/command_security/batlinggun
	name = "Batling gun"
	desc = "A gatling gun modified to fire stun batons. The batons are launched in such a way that guarantees the stunning end always connects, and the launch velocity is high enough to cause injuries. Can be reloaded with stun batons."
	item = /obj/item/weapon/gun/gatling/batling
	cost = 16
	discounted_cost = 10
	jobs_with_discount = list("Security Officer", "Warden", "Head of Security")

/datum/uplink_item/jobspecific/command_security/remoteexplosive
	name = "Remote Explosive Implants"
	desc = "A box containing 5 implants disguised as chemical implants usable after being injected into one's body. When activated with from a prisoner management console, it will cause a small yet breaching explosion from the implant that will gib the user and easily space a room."
	item = /obj/item/weapon/storage/box/chemimp/remeximp
	cost = 18
	discounted_cost = 12
	jobs_with_discount = list("Warden", "Head of Security")

/datum/uplink_item/jobspecific/command_security/evidenceforger
	name = "Evidence Forger"
	desc = "A hacked evidence scanner that allows you to forge evidence by setting a specific output that will apply on the next item scan only. Keep Security Records handy to input all requested data. Concealed as long as the evidence forger itself is not interacted with."
	item = /obj/item/device/detective_scanner/forger
	cost = 6
	discounted_cost = 4
	jobs_with_discount = list("Detective")

/datum/uplink_item/jobspecific/command_security/conversionkit
	name = "Revolver Conversion Kit"
	desc = "A bundle that comes with a professional revolver conversion kit and one box of .357 ammo. This kit allows you to convert your ballistic revolver to fire either .357 lethal or .38 less-than-lethal rounds. The modification is perfect and will never result in a chamber failure, but remember to empty your gun before attempting a modification!"
	item = /obj/item/weapon/storage/box/syndie_kit/conversion
	cost = 12
	discounted_cost = 10
	jobs_with_discount = list("Detective")

/datum/uplink_item/jobspecific/medical
	category = "Medical Specials"

/datum/uplink_item/jobspecific/medical/mouser
	name = "Mouser Pistol"
	desc = "A pistol that turns unfortunate victims into labrats and stuns them briefly. All of their gear becomes part of their body, and if the mouse dies, the target becomes human once again, fully armed and unharmed."
	item = /obj/item/weapon/gun/energy/mouser
	cost = 12
	discounted_cost = 8
	jobs_with_discount = list("Virologist", "Chief Medical Officer")

/datum/uplink_item/jobspecific/medical/wheelchair
	name = "Syndicate Wheelchair"
	desc = "This combat-modified motorized wheelchair has a forward thrust sufficient enough to knock down and run over victims, with special bladed wheels that will make short work of anyone caught under them. Provides limited protection against ballistic weaponry."
	item = /obj/item/syndicate_wheelchair_kit
	cost = 18
	discounted_cost = 12
	jobs_with_discount = list("Orderly", "Medical Doctor", "Chief Medical Officer")

/datum/uplink_item/jobspecific/medical/organ_remover
	name = "Modified Organics Extractor"
	desc = "A tool used by Vox Raiders to extract organs from unconscious victims that has been reverse-engineered by Syndicate scientists to be used by anyone. Cannot extract hearts, but works twice as fast as the original variant. Interact with it to select the type of organ to extract, and then select the appropiate body zone."
	item = /obj/item/weapon/organ_remover/traitor
	cost = 8
	discounted_cost = 6
	jobs_with_discount = list("Medical Doctor", "Chief Medical Officer", "Trader", "Vox")

/datum/uplink_item/jobspecific/medical/chemsprayer
	name = "Chemical Sprayer"
	desc = "A powerful industrial spraygun that holds 600 units of any liquid and can cover large areas faster than a standard spray bottle. Keep away from face."
	item = /obj/item/weapon/reagent_containers/spray/chemsprayer
	cost = 10
	discounted_cost = 8
	jobs_with_discount = list("Chemist", "Chief Medical Officer")

/datum/uplink_item/jobspecific/medical/antisocial
	name = "Explosive Hug Chemical"
	desc = "30 units of Bicarodyne, a special chemical that causes a devastating explosion when exposed to endorphins released in the body by a hug. Metabolizes quite slowly. Converts Bicaridine into more of this substance."
	item = /obj/item/weapon/storage/box/syndie_kit/explosive_hug //Had to be put in a box because it didn't play well with reagent creation
	cost = 9
	discounted_cost = 8
	jobs_with_discount = list("Chemist", "Chief Medical Officer")

/datum/uplink_item/jobspecific/medical/hypozinebottle
	name = "Lethal Speed Chemical"
	desc = "30 units of Hypozine, a special chemical that causes the body to seamlessly synthesize Hyperzine, but also causes increases in muscle activity to levels that rapidly tear the user's body apart, causing catastrophic ligament failure. Metabolizes quite slowly. Converts Hyperzine into more of this substance."
	item = /obj/item/weapon/storage/box/syndie_kit/lethal_hyperzine
	cost = 5
	discounted_cost = 4
	jobs_with_discount = list("Chemist", "Medical Doctor", "Chief Medical Officer")

/datum/uplink_item/jobspecific/medical/radgun
	name = "Radgun"
	desc = "An experimental energy gun that fires radioactive projectiles that burn, irradiate and scramble DNA, giving the victim a different appearance and name, and potentially harmful or beneficial mutations. Recharges on its own."
	item = /obj/item/weapon/gun/energy/radgun
	cost = 18
	discounted_cost = 12
	jobs_with_discount = list("Geneticist", "Chief Medical Officer")

/datum/uplink_item/jobspecific/medical/viruscollection
	name = "Deadly Syndrome Collection"
	desc = "A diskette box filled with 3 random Deadly stage 4 syndromes GNA disks (the same syndrome won't show up twice) on top of a Waiting Syndrome GNA disk to help your disease spread undetected, and a GNA forging disk for masking deadly syndromes in the database."
	item = /obj/item/weapon/storage/lockbox/diskettebox/syndisease
	cost = 20
	discounted_cost = 12
	jobs_with_discount = list("Virologist", "Chief Medical Officer")

/datum/uplink_item/jobspecific/medical/symptomforger
	name = "GNA Database Forger Disk"
	desc = "A disk that looks almost exactly like a normal GNA disk, with the exception of being able to copy the symptom from any other normal one to splice into a disk. Splicing this in does not affect the disease, but instead creates a forged symptom onto the database, obscuring the original effect."
	item = /obj/item/weapon/disk/disease/spoof
	cost = 12
	discounted_cost = 6
	jobs_with_discount = list("Virologist", "Chief Medical Officer")

/datum/uplink_item/jobspecific/medical/syndietape_viro
	name = "Syndicate Biohazard Tape"
	desc = "A length of biohazard tape coated in an engineered bacterium that forcibly ejects explosive goo when disturbed, but can be handled safely with latex gloves. Can be used 3 times."
	item = /obj/item/taperoll/syndie/viro
	cost = 4
	discounted_cost = 2
	jobs_with_discount = list("Virologist", "Chief Medical Officer")

/datum/uplink_item/jobspecific/engineering
	category = "Engineering Specials"

/datum/uplink_item/jobspecific/engineering/powergloves
	name = "Power Gloves"
	desc = "Insulated gloves that can utilize the station's power grid to deliver a short but powerful arc of electricity at a target. Requires standing over a powered cable to use, but does not require for it to be uncovered. Damage scales with spare power in the grid."
	item = /obj/item/clothing/gloves/yellow/power
	cost = 14
	discounted_cost = 8
	jobs_with_discount = list("Station Engineer", "Chief Engineer")

/datum/uplink_item/jobspecific/engineering/teslagun
	name = "Tesla Cannon"
	desc = "This device uses stored power to create a devastating orb of electricity that shocks nearly everyone in its path. The device must be loaded with capacitors in order to fire, each charged to at least 1 MW. The amount of damage scales with the power stored in the capacitor. The cannon comes with one free, pre-charged capacitor."
	item = /obj/item/weapon/gun/tesla/preloaded
	cost = 18
	discounted_cost = 14
	jobs_with_discount = list("Station Engineer", "Chief Engineer")

/datum/uplink_item/jobspecific/engineering/powercreeper_packet
	name = "Powercreep Packet"
	desc = "A packet that creates a dangerous mutated version of kudzu vines. The vines will repeatedly shock people and connect themselves to any cables near them, rapidly growing and spreading out of control if left unchecked."
	item = /obj/item/deployable_packet/powercreeper
	cost = 10
	discounted_cost = 5
	jobs_with_discount = list("Botanist", "Station Engineer", "Chief Engineer")

/datum/uplink_item/jobspecific/engineering/syndietape_engineering
	name = "Syndicate Engineering Tape"
	desc = "A length of Engineering tape doubled with a conducting material, providing for a powerful electric potential. Will spark and shock people who attempt to break it, causing severe burn damage and potentially creating fires. Can be used 3 times."
	item = /obj/item/taperoll/syndie/engineering
	cost = 4
	discounted_cost = 2
	jobs_with_discount = list("Station Engineer", "Chief Engineer")

/datum/uplink_item/jobspecific/engineering/syndietape_atmos
	name = "Syndicate Atmospherics Tape"
	desc = "A length of Atmospherics tape doubled with an extremely sharp material that will severely shred the hands of anyone attempting to break or cross it. Very difficult to remove from their hands once applied. Can be used 3 times."
	item = /obj/item/taperoll/syndie/atmos
	cost = 4
	discounted_cost = 2
	jobs_with_discount = list("Atmospheric Technician", "Chief Engineer")

/datum/uplink_item/jobspecific/engineering/contortionist
	name = "Contortionist's Jumpsuit"
	desc = "A highly flexible jumpsuit that will help you climb into and navigate the internal ventilation loops of the station. Comes with pockets and ID slot, but can't be used without stripping off most gear, including backpack, belt, helmet, and exosuit. Free hands are also necessary to crawl around inside. Mind vent temperature and pressure before use."
	item = /obj/item/clothing/under/contortionist
	cost = 8
	discounted_cost = 6
	jobs_with_discount = list("Atmospheric Technician", "Chief Engineer")

/datum/uplink_item/jobspecific/engineering/flaregun
	name = "Modified Flaregun"
	desc = "A modified flaregun, identical in most appearances to the regular kind. Capable of firing flares at lethal velocity as well as firing any kind of shotgun ammunition normally. Comes with 7 rounds of flare ammunition."
	item = /obj/item/weapon/storage/box/syndie_kit/flaregun
	cost = 6
	discounted_cost = 4
	jobs_with_discount = list("Atmospheric Technician", "Chief Engineer")

/datum/uplink_item/jobspecific/engineering/canned_heat
	name = "Canned Heat"
	desc = "A can that when opened agitates the air molecules in the surrounding atmosphere to raise its temperature by 1000 Kelvin. Use in a large area and several numbers for maximum impact."
	item = /obj/item/canned_heat
	cost = 12
	discounted_cost = 6
	jobs_with_discount = list("Atmospheric Technician", "Chief Engineer")

/datum/uplink_item/jobspecific/engineering/dev_analyser
	name = "Modified Device Analyzer"
	desc = "A device analyzer with the safety features disabled. Allows the user to replicate any kind of Syndicate equipment for further duplication using the station's Mechanic equipment."
	item = /obj/item/device/device_analyser/syndicate
	cost = 9
	discounted_cost = 6
	jobs_with_discount = list("Mechanic")

// A telecomms technician traitor item
/datum/uplink_item/jobspecific/engineering/vocal
	name = "Vocal Implant"
	desc = "An implant usable after being injected into one's body. Settings can be input to modify speech patterns in the affected's voice once implanted."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_vocal
	cost = 8
	discounted_cost = 6
	jobs_with_discount = list("Mechanic", "Chief Engineer")

/datum/uplink_item/jobspecific/cargo
	category = "Cargo and Mining Specials"

/datum/uplink_item/jobspecific/cargo/syndiepaper
	name = "Extra Adhesive Wrapping Paper"
	desc = "This extra-strong wrapping paper is perfect for concealing bodies or trapping a victim with no escape. Simply apply directly to the victim to wrap them up into a regular-looking delivery package that can be further tagged or delivered. Takes about three seconds to wrap up fully."
	item = /obj/item/stack/package_wrap/syndie
	cost = 6
	discounted_cost = 4
	jobs_with_discount = list("Cargo Technician", "Quartermaster")

/datum/uplink_item/jobspecific/cargo/mastertrainer
	name = "Master Trainer's Belt"
	desc = "A trainer's belt containing 6 Lazarus capsules loaded with random but particularly hostile and lethal mobs loyal to you alone. You can inspect what the Lazarus capsules contain before throwing them."
	item = /obj/item/weapon/storage/belt/lazarus/antag
	cost = 12
	discounted_cost = 8
	jobs_with_discount = list("Shaft Miner")

/datum/uplink_item/jobspecific/cargo/mastertrainer/new_uplink_item(var/new_item, var/turf/location, mob/user)
	return new new_item(location, user)

/datum/uplink_item/jobspecific/service
	category = "Service Specials"

/datum/uplink_item/jobspecific/service/ambrosiacruciatus
	name = "Ambrosia Cruciatus Seeds"
	desc = "Part of the notorious Ambrosia family, this species is nearly indistinguishable from Ambrosia Vulgaris. However, when harvested and grown, its branches contain spiritbreaker toxin. Eight units are enough to drive victims insane after a three-minute delay. Can be turned into seeds and regrown freely, ground into chemicals or rolled into blunts."
	item = /obj/item/seeds/ambrosiacruciatusseed
	cost = 6
	discounted_cost = 2
	jobs_with_discount = list("Botanist")

/datum/uplink_item/jobspecific/service/vinesuit
	name = "Space Vietnam Grass Coat"
	desc = "This inconspicuous grass coat was woven from kudzu fibers for guerilla missions in Space Vietnam. While wearing the coat, space vines won't entangle, bite, or otherwise harm you."
	item = 	/obj/item/clothing/suit/mino/vinesafe
	cost = 6
	discounted_cost = 4
	jobs_with_discount = list("Botanist")

/datum/uplink_item/jobspecific/service/beecase
	name = "Briefcase Full of Bees"
	desc = "A briefcase containing twenty angry bees. Will deliver the bee payload when first opened, functions as a normal briefcase after this initial swarm. The bees do not discriminate on targets, so either get someone else to open the briefcase for you or run."
	item = /obj/item/weapon/storage/briefcase/bees
	cost = 12
	discounted_cost = 6
	jobs_with_discount = list("Botanist")

/datum/uplink_item/jobspecific/service/hornethive
	name = "Deployable Wild Hornet Hive"
	desc = "A portable hive that starts producing deadly hornets once thrown or dropped, be careful! Best hidden in maintenance or someone's backroom to give them time to multiply."
	item = /obj/item/deployable_wild_hornet_hive
	cost = 10
	discounted_cost = 5
	jobs_with_discount = list("Botanist")

/datum/uplink_item/jobspecific/service/beenade
	name = "Bee-Nade"
	desc = "Over a dozen deadly hornets. The grenade comes equiped with a pheromone spray so the hornets won't attack the one who threw the grenade."
	item = /obj/item/weapon/grenade/spawnergrenade/beenade
	cost = 16
	discounted_cost = 8
	jobs_with_discount = list("Botanist")

/datum/uplink_item/jobspecific/service/specialsauce
	name = "Chef Excellence's Special Sauce"
	desc = "Twenty units of a custom-made sauce cooked from the toxin glands of an exotic species of space carps, and other delicious, hand-picked high-quality ingredients. If roughly two units are ingested, the victim will drop dead a few minutes after ingestion."
	item = /obj/item/weapon/reagent_containers/food/condiment/syndisauce
	cost = 8
	discounted_cost = 2
	jobs_with_discount = list("Chef")

/datum/uplink_item/jobspecific/service/boxofmints
	name = "Box of Mints"
	desc = "Fifty of the highest quality mint candies this side of the galaxy. Recalled by all producers soon after their immediately lethal efects on fat people were discovered. Harmless to fit people." //It was this or just making a lame 50u bottle of mint toxin, and that's no fun.
	item = /obj/item/weapon/storage/pill_bottle/syndiemints
	cost = 5
	discounted_cost = 3
	jobs_with_discount = list("Chef")

/datum/uplink_item/jobspecific/service/meatcleaver
	name = "Meat Cleaver"
	desc = "A mean looking meat cleaver that does damage comparable to an Energy Sword but with the added benefit of chopping your victim into hunks of meat after they've died. It also stuns when thrown."
	item = /obj/item/weapon/kitchen/utensil/knife/large/butch/meatcleaver
	cost = 12
	discounted_cost = 10
	jobs_with_discount = list("Chef")

/datum/uplink_item/jobspecific/service/cautionsign
	name = "Proximity Mine Wet Floor Sign"
	desc = "An anti-personnel proximity mine cleverly disguised as a wet floor caution sign that is triggered by running past it. Interact with it to start the 15 second timer and activate it again to disarm."
	item = /obj/item/weapon/caution/proximity_sign
	cost = 5
	discounted_cost = 3
	jobs_with_discount = list("Janitor")

/datum/uplink_item/jobspecific/service/drunkbullets
	name = "Boozey Shotgun Shells"
	desc = "A box containing 6 shotgun shells that simulate the effects of extreme drunkenness on the target. Efficacy increases for each type of alcohol currently present in the target's bloodstream, regardless of amount."
	item = /obj/item/weapon/storage/box/syndie_kit/boolets
	cost = 7
	discounted_cost = 6
	jobs_with_discount = list("Bartender")

/datum/uplink_item/jobspecific/service/etwenty
	name = "The E20"
	desc = "A seemingly innocent die with a lethal secret. When rolled, it will set a four second timer and then explode for the strength of the roll. More powerful than even expert-crafted bombs on a Nat 20!"
	item = /obj/item/weapon/dice/d20/e20
	cost = 6
	jobs_exclusive = list("Librarian")

/datum/uplink_item/jobspecific/service/traitor_bible
	name = "Feldbischof's Bible"
	desc = "A copy of the station's holy book of choice, with a little ballistic discount on conversions in the form of a genuine, Chinese-made Luger pistol. 88 rapid, eight in the gun, eight in the extra mag."
	item = /obj/item/weapon/storage/bible/traitor_gun
	cost = 14
	discounted_cost = 10
	jobs_with_discount = list("Chaplain")

/datum/uplink_item/jobspecific/service/occultbook
	name = "Occult Book"
	desc = "A reproduction of a forbidden and occult book. Causes brain damage, eye damage and hallucinations to anyone unfortunate or stupid enough to attempt to read it. Use a pen to change its title."
	item = /obj/item/weapon/book/occult
	cost = 4
	discounted_cost = 2
	jobs_with_discount = list("Librarian", "Chaplain")

/datum/uplink_item/jobspecific/clown_mime
	category = "Clown Planet Specials"

/datum/uplink_item/jobspecific/clown_mime/banannon
	name = "Banannon"
	desc = "A fearsome piece of ancient Clown technology, the armor-piercing discarding sabonanas fired by this weapon shed their peels in flight, increasing their damage and creating a slipping hazard in their wake. Only those trained in the Clown arts may use this weapon without risking a severe malfunction."
	item = /obj/item/weapon/gun/banannon
	cost = 18
	jobs_exclusive = list("Clown")

/datum/uplink_item/jobspecific/clown_mime/bsword
	name = "Energized Bananium Sword"
	desc = "An ancient piece of technology from a lost civilization. This energy sword conceals perfectly into a banana hilt that will easily fool most, but becomes extremely lethal when activated. Two of these can be combined to create the ultimate power weapon, but only a Clown may safely handle such power for the glory of Clown-kind."
	item = /obj/item/weapon/melee/energy/sword/bsword
	cost = 8
	jobs_exclusive = list("Clown")

/datum/uplink_item/jobspecific/clown_mime/livingballoons
	name = "Box of Living Long Balloons"
	desc = "These modified balloons can be tied into special balloon animals, which will come to life and attack any nearby non-Clowns if a balloon is popped near them. Serious hazard if manipulated by those not versed in the Clown arts."
	item = /obj/item/weapon/storage/box/balloons/long/living
	cost = 6
	jobs_exclusive = list("Clown")

/datum/uplink_item/jobspecific/clown_mime/clowngrenade
	name = "Banana Grenade"
	desc = "A grenade that will release a large field of banana peels on detonation that are genetically modified to be extra slippery and release caustic acid when stepped on. Covers roughly a 5x5 area."
	item = /obj/item/weapon/grenade/clown_grenade
	cost = 6
	discounted_cost = 5
	jobs_with_discount = list("Clown")

/datum/uplink_item/jobspecific/clown_mime/bananagun
	name = "Banana Gun"
	desc = "A single-shot but particularly powerful banana gun, appearing as a banana until fired. Will do catastrophic damage to whomever it hits and only leave a banana peel behind as evidence. Do not attempt to eat."
	item = /obj/item/weapon/gun/projectile/banana
	cost = 4
	discounted_cost = 2
	jobs_with_discount = list("Clown")

/datum/uplink_item/jobspecific/clown_mime/superglue
	name = "Bottle of Superglue"
	desc = "Considered illegal everywhere except for the Clown Planet, this water-resistant superglue can instantly bind human flesh to any material, permanently. Can only be used once."
	item = /obj/item/weapon/glue
	cost = 6
	discounted_cost = 4
	jobs_with_discount = list("Clown", "Mime", "Captain")

/datum/uplink_item/jobspecific/clown_mime/invisible_spray
	name = "Can of Invisible Spray"
	desc = "Spray something to render it invisible for five minutes! Can only be used once. Permanence not guaranteed when exposed to water, may not render all parts invisible, especially for humans."
	item = /obj/item/weapon/syndie_spray/invisible_spray
	cost = 6
	jobs_excluded = list("Clown", "Mime")

/datum/uplink_item/jobspecific/clown_mime/silent_spray
	name = "Can of Silencing Spray"
	desc = "Spray something to render it silent for five minutes! Can only be used once. Permanence not guaranteed when exposed to water."
	item = /obj/item/weapon/syndie_spray/silent_spray
	cost = 6
	jobs_excluded = list("Clown", "Mime")

/datum/uplink_item/jobspecific/clown_mime/invisible_spray/permanent
	name = "Can of Permanent Invisible Spray"
	desc = "Spray something to render it permanently invisible! Can only be used once. Permanence not guaranteed when exposed to water, may not render all parts invisible, especially for humans."
	item = /obj/item/weapon/syndie_spray/invisible_spray/permanent
	cost = 4
	jobs_excluded = list()
	jobs_exclusive = list("Clown", "Mime")

/datum/uplink_item/jobspecific/clown_mime/silent_spray/permanent
	name = "Can of Permanent Silencing Spray"
	desc = "Spray something to render it permanently silent! Can only be used once. Permanence not guaranteed when exposed to water."
	item = /obj/item/weapon/syndie_spray/silent_spray/permanent
	cost = 4
	jobs_excluded = list()
	jobs_exclusive = list("Clown", "Mime")

/datum/uplink_item/jobspecific/clown_mime/advancedmime
	name = "Advanced Mime Gloves"
	desc = "Grants the user the ability to periodically fire an invisible gun from their white gloves with two rounds in the chamber, dealing decent damage. Only real Mimes are trained in the art of firing this artefact silently when using the forbidden hand-gun technique."
	item = /obj/item/clothing/gloves/white/advanced
	cost = 12
	jobs_exclusive = list("Mime")

/datum/uplink_item/jobspecific/clown_mime/unwall_spell
	name = "Invisible Un-Wall Spellbook"
	desc = "Grants the user the ability to conjure a strange wall allowing the passage of anything through a space regardless of the objects in place. Only real Mimes are capable of learning from this forbidden tome."
	item = /obj/item/weapon/spellbook/oneuse/unwall
	cost = 12
	jobs_exclusive = list("Mime")

/datum/uplink_item/jobspecific/clown_mime/punchline
	name = "Punchline"
	desc = "A high risk high reward abomination combining experimental phazon and bananium technologies. Wind-up Punchline to charge it. Enough charge and your targets will slip through reality. Warning: Forcing wind-ups beyond the limiter may reverse the prototype phazite honkpacitors and disrupt reality around the user."
	item = /obj/item/weapon/gun/hookshot/whip/windup_box/clownbox
	cost = 14
	discounted_cost = 10
	jobs_with_discount = list("Clown")
	jobs_excluded = list("Mime")

/datum/uplink_item/jobspecific/clown_mime/piebomb
	name = "Pie Bomb"
	desc = "These aren't homemade, they were made in a factory. A bomb factory. They're bombs."
	item = /obj/item/weapon/reagent_containers/food/snacks/explosive_pie
	cost = 4
	discounted_cost = 2
	jobs_with_discount = list("Clown", "Mime")

/datum/uplink_item/jobspecific/assistant
	category = "Assistant Specials"

/datum/uplink_item/jobspecific/assistant/greytide
	name = "Greytide Implants"
	desc = "A box containing two greytide implanters that when injected into another person makes them loyal to the Greytide and thus your cause. Loyalty will end on implant removal or destruction, and loyalty implants will fry the implant. The bundle contains disguised SecHUD sunglasses with limited access until they scan a real pair."
	item = /obj/item/weapon/storage/box/syndie_kit/greytide
	cost = 20
	discounted_cost = 14
	jobs_with_discount = list("Assistant")

/datum/uplink_item/jobspecific/assistant/cheaptide
	name = "Cheaptide Implant"
	desc = "A box containing one greytide implanter that when injected into another person makes them loyal to the Greytide and thus your cause. Loyalty will end on implant removal or destruction, and loyalty implants will fry the implant. The bundle contains disguised SecHUD sunglasses with limited access until they scan a real pair."
	item = /obj/item/weapon/storage/box/syndie_kit/cheaptide
	cost = 12
	discounted_cost = 8
	jobs_with_discount = list("Assistant")

/datum/uplink_item/jobspecific/assistant/pickpocketgloves
	name = "Pickpocket's Gloves"
	desc = "A pair of sleek gloves used to aid in pickpocketing. While wearing these you can sneakily strip any item off someone without alerting their owner. Pickpocketed items will also be put into your hand rather than falling to the ground."
	item = /obj/item/clothing/gloves/black/thief
	cost = 4
	discounted_cost = 2
	jobs_with_discount = list("Assistant")

/datum/uplink_item/jobspecific/assistant/pickpocketglovestorage
	name = "Pickpocket's Gloves with Storage"
	desc = "A pair of sleek gloves used to aid in pickpocketing. These custom-made gloves come with a two-slot storage where pickpocketed items will automatically be placed. These items can be retrieved at will when needed."
	item = /obj/item/clothing/gloves/black/thief/storage
	cost = 7
	discounted_cost = 4
	jobs_with_discount = list("Assistant")

/datum/uplink_item/jobspecific/assistant/biomasspacket
	name = "Biomass Packet"
	desc = "A packet containing cryo-stabilized biomass tissue. Shake and throw for your very own interdimensional space barf."
	item = /obj/item/deployable_packet/biomass
	cost = 8
	discounted_cost = 5
	jobs_with_discount = list("Assistant", "Janitor") //There originally was a discount for mechanics too due to them being Assistant+, but it felt like a cheap joke

/datum/uplink_item/jobspecific/command
	category = "Command Specials"

/datum/uplink_item/jobspecific/command/pocketsat
	name = "Pocket Satellite"
	desc = "A grenade which, when detonated in space, creates a circular station with radius 7. The station is loaded with self-powered computers, useful gear, and machinery as well as a teleporter beacon. Anyone right under it when it unfolds is crushed."
	item = /obj/item/weapon/grenade/station
	cost = 12
	discounted_cost = 8
	jobs_with_discount = list("Captain", "Head of Personnel")

/datum/uplink_item/jobspecific/command/lawgivermk2
	name = "Lawgiver Demolition Kit"
	desc = "A container that comes with a Lawgiver modification kit, converting it into a Demolition variant Lawgiver. Also comes with two spare demolition magazines."
	item = /obj/item/weapon/storage/box/demolition
	cost = 12
	jobs_exclusive = list("Head of Security")

/datum/uplink_item/jobspecific/command/briefcase_smg
	name = "Briefcase SMG"
	desc = "A modified briefcase capable of storing and firing a gun under a false bottom, while still allowing regular storage functions. Starts with a 9mm SMG loaded with 18 rounds that can be fired by holding the briefcase. Use a screwdriver to pry away the false bottom and either retrieve the gun or insert a new one. Distinguishable upon close examination due to the added weight."
	item = /obj/item/weapon/storage/briefcase/false_bottomed/smg
	cost = 14
	discounted_cost = 10
	jobs_with_discount = list("Internal Affairs Agent")

/datum/uplink_item/jobspecific/command/briefcase_smg/on_item_spawned(var/obj/I, var/mob/user)
	if(gives_discount(user.job) || gives_discount(user.dna.species))
		I.icon_state = "briefcase-centcomm"
	return

/datum/uplink_item/jobspecific/command/knifeboot
	name = "Concealed knife shoes"
	desc = "Lace-up shoes with a knife concealed in the toecap. Tap your heels together to reveal the small knife. Remember to kick the target to stab them. Knife will be visible when pulled out, but kicking with the knife will not be directly obvious to observers."
	item = /obj/item/clothing/shoes/knifeboot
	cost = 4
	discounted_cost = 2
	jobs_with_discount = list("Internal Affairs Agent")

/datum/uplink_item/jobspecific/command/jobdisk
	name = "Alternate Jobs Database"
	desc = "A disk which scrambles the jobs database when installed in the Labor Management Console."
	item = /obj/item/weapon/disk/jobdisk
	cost = 6
	discounted_cost = 3
	jobs_with_discount = list("Captain", "Head of Personnel")

/datum/uplink_item/jobspecific/trader
	category = "Trader Specials"

/datum/uplink_item/jobspecific/trader/dartgun
	name = "Chemical Dart Gun"
	desc = "A staple in vox weaponry. This dart gun starts loaded with darts containing sleep toxin and chloral hydrate. The beaker inside can be swapped out to create your own deadly mixes."
	item = /obj/item/weapon/gun/dartgun/vox/raider
	cost = 20
	discounted_cost = 16
	jobs_exclusive = list("Trader","Vox","Skeletal Vox")
	jobs_with_discount = list("Trader")

/datum/uplink_item/jobspecific/trader/dart_cartridge
	name = "Dart Cartridge"
	desc = "A spare cartridge to refill your dart gun."
	item = /obj/item/weapon/dart_cartridge
	cost = 6
	discounted_cost = 2
	jobs_exclusive = list("Trader","Vox","Skeletal Vox")
	jobs_with_discount = list("Trader")

/datum/uplink_item/jobspecific/trader/cratesender
	name = "Modified Crate Sender"
	desc = "A modified salvage crate sender that has been modified to bypass the security protocols, allowing it to teleport crates from onboard the station and allowing it to teleport crates to random destinations. Comes with a cargo telepad you can send your stolen goods to."
	item = /obj/item/weapon/storage/box/syndie_kit/cratesender
	cost = 10
	discounted_cost = 6
	jobs_exclusive = list("Trader","Vox","Skeletal Vox")
	jobs_with_discount = list("Trader","Cargo Technician","Quartermaster")

/datum/uplink_item/jobspecific/cannedmatter
	category = "Skrell Specials"
	name = "Canned Compressed Matter"
	desc = "For once, the syndicate has it. When an item is pressed onto the closed can, it can be stored inside regardless of its size, to be released again on the can opening. Does not allow items to be stored anymore once opened."
	item = /obj/item/weapon/reagent_containers/food/drinks/soda_cans/canned_matter
	cost = 6
	jobs_exclusive = list("Skrell")

// SYNDICATE COOP
// Any high cost items that are intended to only be purchasable when three syndies come together to change the narrative.

/datum/uplink_item/syndie_coop
	category = "Cooperative Cell"
	available_for_nuke_ops = FALSE

/datum/uplink_item/syndie_coop/elite_bundle
	name = "Elite Syndicate Bundle"
	desc = "A Syndicate bundle designed for a team of two agents."
	item = /obj/item/weapon/storage/box/syndicate_team
	cost = 28

/datum/uplink_item/syndie_coop/stone
	name = "SG-VPR-23 Pathogenic Medium"
	desc = "A closely guarded artifact leveraged from the Vampire Lords.  It possesses an active sample of the SG-VPR-23 strain that is the source of all known cases of vampirism within the galaxy.  This piece is only to be granted to an operative cell that wishes to execute, and accepts the risk, of an SG-VPR-23 outbreak.  It is brittle in its old age, and may only survive one use."
	item = /obj/item/clothing/mask/stone
	cost = 60

/datum/uplink_item/syndie_coop/changeling_vial
	name = "CH-L1-NG Bioweapon Sample"
	desc = "A securely contained vial of the experimental mutagen 'CH-L1-NG'.  Originally designed as a transhumanist super-soldier serum, the mutagen was reclassified as a bioweapon when research showed that the afflicted would completely dissociate from their identity and loyalties.  Victims of 'CH-L1-NG' were found to be the perfect killing machines to be released upon enemies of the Syndicate."
	item = /obj/item/changeling_vial
	cost = 60

/datum/uplink_item/syndie_coop/bloodcult_pamphlet
	name = "Esoteric Propaganda Pamphlet"
	desc = "A pamphlet found within the controlled literature archives detailing what appears to be a communication ritual to contact the celestial NRS-1.  Exposure to NRS-1 is known to induce the formation of a hive-like social structure among the afflicted, delusions of grandeur, and collective suicidal tendencies.  An operative cell wishing to weaponize contact with NRS-1 should proceed with extreme caution."
	item = /obj/item/weapon/bloodcult_pamphlet/oneuse
	cost = 60

/datum/uplink_item/syndie_coop/codebreaker
	name = "Codebreaker"
	desc = "The be-all-end-all solution to halting Nanotrasen's expansion into free space.  This piece of Gorlex tech will allow a cell that is sufficiently large enough to decrypt the authentication key for their target station's failsafe thermonuclear warhead.  Good luck, operatives."
	item = /obj/item/device/codebreaker
	cost = 100
