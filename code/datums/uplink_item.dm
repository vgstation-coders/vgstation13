var/list/uplink_items = list()

/proc/get_uplink_items(var/job = null)
	// If not already initialized..
	if(!uplink_items.len)

		// Fill in the list	and order it like this:
		// A keyed list, acting as categories, which are lists to the datum.

		var/list/last = list()
		for(var/item in typesof(/datum/uplink_item))

			var/datum/uplink_item/I = new item()
			if(!I.item)
				continue
			if(I.gamemodes.len && ticker && !(ticker.mode.name in I.gamemodes))
				continue
			if(I.last)
				last += I
				continue

			if(!uplink_items[I.category])
				uplink_items[I.category] = list()

			uplink_items[I.category] += I

		for(var/datum/uplink_item/I in last)
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
	var/last = 0 // Appear last
	var/abstract = 0
	var/list/gamemodes = list() // Empty list means it is in all the gamemodes. Otherwise place the gamemode name here.
	var/list/job = null

/datum/uplink_item/proc/spawn_item(var/turf/loc, var/obj/item/device/uplink/U, mob/user)
	U.uses -= max(cost, 0)
	feedback_add_details("traitor_uplink_items_bought", name)
	return new item(loc,user)

/datum/uplink_item/proc/buy(var/obj/item/device/uplink/hidden/U, var/mob/user)


	..()
	if(!istype(U))
		return 0

	if (user.stat || user.restrained())
		return 0

	if (!( istype(user, /mob/living/carbon/human)))
		return 0

	// If the uplink's holder is in the user's contents
	if ((U.loc in user.contents || (in_range(U.loc, user) && istype(U.loc.loc, /turf))))
		user.set_machine(U)
		if(cost > U.uses)
			return 0

		var/obj/I = spawn_item(get_turf(user), U, user)
		if(!I)
			return 0
		on_item_spawned(I,user)
		var/icon/tempimage = icon(I.icon, I.icon_state)
		end_icons += tempimage
		var/tempstate = end_icons.len

		var/bundlename = name
		if(name == "Random Item" || name == "For showing that you are The Boss")
			bundlename = I.name
		if(I.tag)
			bundlename = "[I.tag] bundle"
			I.tag = null
		if(ishuman(user))
			var/mob/living/carbon/human/A = user

			if(istype(I, /obj/item))
				A.put_in_any_hand_if_possible(I)

			U.purchase_log += {"[user] ([user.ckey]) bought <img src="logo_[tempstate].png"> [name] for [cost]."}
			stat_collection.uplink_purchase(src, I, user)
			if(user.mind)
				user.mind.uplink_items_bought += {"<img src="logo_[tempstate].png"> [bundlename]"}
				user.mind.spent_TC += cost
		U.interact(user)

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

/datum/uplink_item/jobspecific
	category = "Job Specific Tools"

//Librarian
/datum/uplink_item/jobspecific/etwenty
	name = "The E20"
	desc = "A seemingly innocent die, those who are not afraid to roll for attack will find it's effects quite explosive. Has a four second timer."
	item = /obj/item/weapon/dice/d20/e20
	cost = 3
	job = list("Librarian")

//Cargo Technician
/datum/uplink_item/jobspecific/syndiepaper
	name = "Extra Adhesive Wrapping Paper"
	desc = "This extra-strong wrapping paper is perfect for concealing bodies or trapping a victim with no escape. Simply apply directly to the victim and wrap them up into a regular-looking delivery package. Takes about three seconds to wrap."
	item = /obj/item/stack/package_wrap/syndie
	cost = 2
	job = list("Cargo Technician", "Quartermaster")

/datum/uplink_item/jobspecific/syndiepaper/spawn_item(var/turf/loc, var/obj/item/device/uplink/U, mob/user)
	U.uses -= max(cost, 0)
	feedback_add_details("traitor_uplink_items_bought", name)
	return new item(loc) //Fix for amount ref

//Shaft Miner
/datum/uplink_item/jobspecific/mastertrainer
	name = "Master Trainer's Belt"
	desc = "A Trainer's belt containing 6 random hostile mobs loyal to you alone."
	item = /obj/item/weapon/storage/belt/lazarus/antag
	cost = 4
	job = list("Shaft Miner")

//Clown
/datum/uplink_item/jobspecific/clowngrenade
	name = "1 Banana Grenade"
	desc = "A grenade that explodes into HONK! brand banana peels that are genetically modified to be extra slippery and extrude caustic acid when stepped on"
	item = /obj/item/weapon/grenade/clown_grenade
	cost = 4
	job = list("Clown")

/datum/uplink_item/jobspecific/bsword
	name = "Energized Bananium Sword"
	desc = "When concealed a simple banana, when active a deadly means of executing swift justice.  Highly regarded for their utility on away missions from the Clown Planet"
	item = /obj/item/weapon/melee/energy/sword/bsword
	cost = 4
	job = list("Clown")

/datum/uplink_item/jobspecific/superglue
	name = "1 Bottle of Superglue"
	desc = "Considered illegal everywhere except for the Clown Planet, this water-resistant superglue can instantly bind human flesh to ANY material, permanently. One-time use."
	item = /obj/item/weapon/glue
	cost = 3
	job = list("Clown", "Mime")

//Security
/datum/uplink_item/jobspecific/syndicuffs
	name = "Syndicate Cuffs"
	desc = "A pair of cuffs rigged with electronics and laced with a C4 charge. Can be toggled between explosion on application and explosion on removal."
	item = /obj/item/weapon/handcuffs/syndicate
	cost = 2
	job = list("Security Officer", "Warden", "Head of Security")

//Detective
/datum/uplink_item/jobspecific/evidenceforger
	name = "Evidence Forger"
	desc = "An evidence scanner that allows you forge evidence by setting the output before scanning the item."
	item = /obj/item/device/detective_scanner/forger
	cost = 3
	job = list("Detective")

/datum/uplink_item/jobspecific/conversionkit
	name = "Conversion Kit Bundle"
	desc = "A bundle that comes with a professional revolver conversion kit and 1 box of .357 ammo. The kit allows you to convert your revolver to fire lethal rounds or vice versa, modification is nearly perfect and will not result in catastrophic failure."
	item = /obj/item/weapon/storage/box/syndie_kit/conversion
	cost = 6
	job = list("Detective")

//Botanist
/datum/uplink_item/jobspecific/ambrosiacruciatus
	name = "Ambrosia Cruciatus Seeds"
	desc = "Part of the notorious Ambrosia family, this species is nearly indistinguishable from Ambrosia Vulgaris- but its' branches contain a revolting toxin. Eight units are enough to drive victims insane after a three-minute delay."
	item = /obj/item/seeds/ambrosiacruciatusseed
	cost = 2
	job = list("Botanist")

//Chef
/datum/uplink_item/jobspecific/specialsauce
	name = "Chef Excellence's Special Sauce"
	desc = "A custom made sauce made from the toxin glands of 1000 space carp, if somebody ingests enough they'll be dead in 3 minutes or less guaranteed."
	item = /obj/item/weapon/reagent_containers/food/condiment/syndisauce
	cost = 2
	job = list("Chef")

/datum/uplink_item/jobspecific/meatcleaver
	name = "Meat Cleaver"
	desc = "A mean looking meat cleaver that does damage comparable to an Energy Sword but with the added benefit of chopping your victim into hunks of meat after they've died and the chance to stun when thrown."
	item = /obj/item/weapon/kitchen/utensil/knife/large/butch/meatcleaver
	cost = 5
	job = list("Chef")

//Janitor
/datum/uplink_item/jobspecific/cautionsign
	name = "Proximity Mine"
	desc = "An Anti-Personnel proximity mine cleverly disguised as a wet floor caution sign that is triggered by running past it, activate it to start the 15 second timer and activate again to disarm."
	item = /obj/item/weapon/caution/proximity_sign
	cost = 2
	job = list("Janitor")


//Assistant
/datum/uplink_item/jobspecific/pickpocketgloves
	name = "Pickpocket's Gloves"
	desc = "A pair of sleek gloves to aid in pickpocketing, while wearing these you can sneakily empty pockets and strip clothing with nobody seeing you. Pickpocketed items will also be put into your hand rather than fall to the ground."
	item = /obj/item/clothing/gloves/black/thief
	cost = 3
	job = list("Assistant")

/datum/uplink_item/jobspecific/greytide
	name = "Greytide Implant"
	desc = "A box containing an implanter filled with a greytide implant when injected into another person makes them loyal to the greytide and your cause, unless of course they're already implanted by someone else. Loyalty ends if the implant is no longer in their system."
	item = /obj/item/weapon/storage/box/syndie_kit/greytide
	cost = 7
	job = list("Assistant")

//Bartender
/datum/uplink_item/jobspecific/drunkbullets
	name = "Boozey Shotgun Shells"
	desc = "A box containing 6 shotgun shells that simulate the effects of extreme drunkeness on the target, more effective for each type of alcohol in the target's system."
	item = /obj/item/weapon/storage/box/syndie_kit/boolets
	cost = 3
	job = list("Bartender")

//Chemist
/datum/uplink_item/jobspecific/chemsprayer
	name = "Chemical Sprayer"
	desc = "A powerful industrial spraygun that holds 600 units of any liquid, and can cover area faster than a standard spray bottle."
	item = /obj/item/weapon/reagent_containers/spray/chemsprayer
	cost = 4
	job = list("Chemist", "Chief Medical Officer")

/datum/uplink_item/jobspecific/antisocial
	name = "Explosive Hug Chemical"
	desc = "30 units of Bicarodyne, a chemical that causes a devastating explosion when exposed to endorphins released in the body by a hug. Metabolizes quite slowly."
	item = /obj/item/weapon/storage/box/syndie_kit/explosive_hug //Had to be put in a box because it didn't play well with reagent creation
	cost = 4
	job = list("Chemist", "Chief Medical Officer")

//Medical Doctor
/datum/uplink_item/jobspecific/wheelchair
	name = "Syndicate Wheelchair"
	desc = "A combat-modified motorized wheelchair. Forward thrust is sufficient to knock down and run over victims."
	item = /obj/item/syndicate_wheelchair_kit
	cost = 6
	job = list("Medical Doctor", "Chief Medical Officer")

//Engineer
/datum/uplink_item/jobspecific/powergloves
	name = "Power Gloves"
	desc = "Insulated gloves that can utilize the power of the station to deliver a short arc of electricity at a target. Must be standing on a powered cable to use."
	item = /obj/item/clothing/gloves/yellow/power
	cost = 7
	job = list("Station Engineer", "Chief Engineer")

//Atmos Tech
/datum/uplink_item/jobspecific/contortionist
	name = "Contortionist's Jumpsuit"
	desc = "A highly flexible jumpsuit that will help you navigate the ventilation loops of the station internally. Comes with pockets and ID slot, but can't be used without stripping off most gear, including backpack, belt, helmet, and exosuit. Free hands are also necessary to crawl around inside."
	item = /obj/item/clothing/under/contortionist
	cost = 4
	job = list("Atmospheric Technician", "Chief Engineer")

//Geneticist
/datum/uplink_item/jobspecific/radgun
	name = "Radgun"
	desc = "An experimental energy gun that fires radioactive projectiles that burn, irradiate, and scramble DNA, giving the victim a different appearance and name, and potentially harmful or beneficial mutations. Recharges automatically."
	item = /obj/item/weapon/gun/energy/radgun
	cost = 6
	job = list("Geneticist", "Chief Medical Officer")

//Atmospheric Technician
/datum/uplink_item/jobspecific/flaregun
	name = "Modified Flaregun"
	desc = "A modified flaregun, identical in most appearances to the regular kind, as well as 7 rounds of flare ammunition. Capable of firing flares at lethal velocity, as well as firing shotgun ammunition."
	item = /obj/item/weapon/storage/box/syndie_kit/flaregun
	cost = 4
	job = list("Atmospheric Technician", "Chief Engineer")

//Mechanic
/datum/uplink_item/jobspecific/dev_analyser
	name = "Modified Device Analyser"
	desc = "A device analyser with the safety features disabled. Allows the user to replicate any kind of Syndicate equipment."
	item = /obj/item/device/device_analyser/syndicate
	cost = 4
	job = list("Mechanic")

//IAA - Internal Affairs Agent
/datum/uplink_item/jobspecific/briefcase_smg
	name = "Concealed SMG"
	desc = "A modified briefcase capable of storing and firing a gun under a false bottom. Starts with an internal SMG and 18 rounds. Use a screwdriver to pry away the false bottom and make modifications."
	item = /obj/item/weapon/storage/briefcase/false_bottomed/smg
	cost = 6
	job = list("Internal Affairs Agent")

// DANGEROUS WEAPONS

/datum/uplink_item/dangerous
	category = "Highly Visible and Dangerous Weapons"

/datum/uplink_item/dangerous/revolver
	name = "Fully Loaded Revolver"
	desc = "A traditional handgun which fires .357 rounds. Has 7 chambers. Can down an unarmoured target with two shots."
	item = /obj/item/weapon/gun/projectile
	cost = 6

/datum/uplink_item/dangerous/ammo
	name = "Ammo-357"
	desc = "A speedloader and seven additional rounds for the revolver. Reports indicate the presence of machinery aboard Nanotrasen space stations suitable for producing extra .357 cartridges."
	item = /obj/item/weapon/storage/box/syndie_kit/ammo
	cost = 2

/datum/uplink_item/dangerous/crossbow
	name = "Energy Crossbow"
	desc = "A miniature energy crossbow that is small enough both to fit into a pocket and to slip into a backpack unnoticed by observers. Fires bolts tipped with toxin, a poisonous substance that is the product of a living organism. Stuns enemies for a short period of time. Recharges automatically."
	item = /obj/item/weapon/gun/energy/crossbow
	cost = 5

/datum/uplink_item/dangerous/sword
	name = "Energy Sword"
	desc = "The esword is an edged weapon with a blade of pure energy. The sword is small enough to be pocketed when inactive. Activating it produces a loud, distinctive noise."
	item = /obj/item/weapon/melee/energy/sword
	cost = 4

/datum/uplink_item/dangerous/emp
	name = "5 EMP Grenades"
	desc = "A box that contains 5 EMP grenades. Useful to disrupt communication and silicon lifeforms."
	item = /obj/item/weapon/storage/box/emps
	cost = 3

/datum/uplink_item/dangerous/viscerator
	name = "Viscerator Grenade"
	desc = "A single grenade containing a pair of incredibly destructive viscerators. Be aware that they will attack any nearby targets, including yourself. Emits a blinding flash upon detonation."
	item = /obj/item/weapon/grenade/spawnergrenade/manhacks/syndicate
	cost = 3

/datum/uplink_item/dangerous/gatling
	name = "Gatling Gun"
	desc = "A huge minigun. Makes up for its lack of mobility and discretion with sheer firepower. Has 200 bullets."
	item = /obj/item/weapon/gun/gatling
	cost = 20
	gamemodes = list("nuclear emergency")

// STEALTHY WEAPONS

/datum/uplink_item/stealthy_weapons
	category = "Stealthy and Inconspicuous Weapons"

/datum/uplink_item/stealthy_weapons/para_pen
	name = "Paralysis Pen"
	desc = "A syringe disguised as a functional pen, filled with a neuromuscular-blocking drug that renders a target immobile on injection and makes them seem dead to observers. Side effects of the drug include noticeable drooling. The pen holds one dose of paralyzing agent, and cannot be refilled."
	item = /obj/item/weapon/pen/paralysis
	cost = 3

/datum/uplink_item/stealthy_weapons/soap
	name = "Syndicate Soap"
	desc = "A sinister-looking surfactant used to clean blood stains to hide murders and prevent DNA analysis. You can also drop it underfoot to slip people."
	item = /obj/item/weapon/soap/syndie
	cost = 1

/datum/uplink_item/stealthy_weapons/detomatix
	name = "Detomatix PDA Cartridge"
	desc = "When inserted into a personal digital assistant, this cartridge gives you five opportunities to detonate PDAs of crewmembers who have their message feature enabled. The concussive effect from the explosion will knock the recipient out for a short period, and deafen them for longer. It has a chance to detonate your PDA."
	item = /obj/item/weapon/cartridge/syndicate
	cost = 3

/datum/uplink_item/stealthy_weapons/knuckles
	name = "Brass Knuckles"
	desc = "A pair of metal knuckles that can be worn on your hands, increasing damage done by your punches."
	item = /obj/item/clothing/gloves/knuckles
	cost = 1

// STEALTHY TOOLS

/datum/uplink_item/stealthy_tools
	category = "Stealth and Camouflage Items"

/datum/uplink_item/stealthy_tools/chameleon_jumpsuit
	name = "Chameleon Jumpsuit"
	desc = "A jumpsuit used to imitate the uniforms of Nanotrasen crewmembers."
	item = /obj/item/clothing/under/chameleon
	cost = 3

/datum/uplink_item/stealthy_tools/syndigolashes
	name = "No-Slip Syndicate Shoes"
	desc = "These allow you to run on wet floors. They do not work on lubricated surfaces."
	item = /obj/item/clothing/shoes/syndigaloshes
	cost = 2

/datum/uplink_item/stealthy_tools/agent_card
	name = "Agent ID Card"
	desc = "Agent cards prevent artificial intelligences from tracking the wearer, and can copy access from other identification cards. The access is cumulative, so scanning one card does not erase the access gained from another."
	item = /obj/item/weapon/card/id/syndicate
	cost = 2

/datum/uplink_item/stealthy_tools/voice_changer
	name = "Voice Changer"
	desc = "A conspicuous gas mask that mimics the voice named on your identification card. When no identification is worn, the mask will render your voice unrecognizable."
	item = /obj/item/clothing/mask/gas/voice
	cost = 4

/datum/uplink_item/stealthy_tools/dnascrambler
	name = "DNA Scrambler"
	desc = "A syringe with one injection that randomizes appearance and name upon use. A cheaper but less versatile alternative to an agent card and voice changer."
	item = /obj/item/weapon/dnascrambler
	cost = 2

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Chameleon-Projector"
	desc = "Projects an image across a user, disguising them as an object scanned with it, as long as they don't move the projector from their hand. The disguised user cannot run and projectiles pass over them."
	item = /obj/item/device/chameleon
	cost = 3


// DEVICE AND TOOLS

/datum/uplink_item/device_tools
	category = "Devices and Tools"
	abstract = 1

/datum/uplink_item/device_tools/emag
	name = "Cryptographic Sequencer"
	desc = "The emag is a small card that unlocks hidden functions in electronic devices, subverts intended functions and characteristically breaks security mechanisms."
	item = /obj/item/weapon/card/emag
	cost = 3

/datum/uplink_item/device_tools/toolbox
	name = "Fully Loaded Toolbox"
	desc = "The syndicate toolbox is a suspicious black and red. Aside from tools, it comes with cable and a multitool. Insulated gloves are not included."
	item = /obj/item/weapon/storage/toolbox/syndicate
	cost = 1

/datum/uplink_item/device_tools/bugdetector
	name = "Bug Detector"
	desc = "A functional multitool that can detect certain surveillance devices. Its screen changes color if the AI or a pAI can see you, or if a tape recorder or voice analyzer is nearby. Examine it to see everything it detects."
	item = /obj/item/device/multitool/ai_detect
	cost = 2

/datum/uplink_item/device_tools/space_suit
	name = "Space Suit"
	desc = "The red syndicate space suit is less encumbering than Nanotrasen variants, fits inside bags, and has a weapon slot. Nanotrasen crewmembers are trained to report red space suit sightings."
	item = /obj/item/weapon/storage/box/syndie_kit/space
	cost = 3

/datum/uplink_item/device_tools/thermal
	name = "Thermal Imaging Glasses"
	desc = "These glasses are thermals disguised as engineers' optical meson scanners. They allow you to see organisms through walls by capturing the upper portion of the infrared light spectrum, emitted as heat and light by objects. Hotter objects, such as warm bodies, cybernetic organisms and artificial intelligence cores emit more of this light than cooler objects like walls and airlocks."
	item = /obj/item/clothing/glasses/thermal/syndi
	cost = 3

/datum/uplink_item/device_tools/surveillance
	name = "Camera Surveillance Kit"
	desc = "This kit contains 5 Camera bugs and one mobile receiver. Attach camera bugs to a camera to enable remote viewing."
	item = /obj/item/weapon/storage/box/syndie_kit/surveillance
	cost = 3

/datum/uplink_item/device_tools/camerabugs
	name = "Camera Bugs"
	desc = "This is a Camera bug resupply giving you 5 more camera bugs."
	item = /obj/item/weapon/storage/box/surveillance
	cost = 2

/datum/uplink_item/device_tools/binary
	name = "Binary Translator Key"
	desc = "A key, that when inserted into a radio headset, allows you to listen to and talk with artificial intelligences and cybernetic organisms in binary."
	item = /obj/item/device/encryptionkey/binary
	cost = 3

/datum/uplink_item/device_tools/cipherkey
	name = "Centcomm Encryption Key"
	desc = "A key, that when inserted into a radio headset, allows you to listen to and talk on all known radio channels."
	item = /obj/item/device/encryptionkey/syndicate/hacked
	cost = 2

/datum/uplink_item/device_tools/hacked_module
	name = "Hacked AI Upload Module"
	desc = "When used with an upload console, this module allows you to upload priority laws to an artificial intelligence. Be careful with their wording, as artificial intelligences may look for loopholes to exploit."
	item = /obj/item/weapon/aiModule/freeform/syndicate
	cost = 7

/datum/uplink_item/device_tools/plastic_explosives
	name = "Composition C-4"
	desc = "C-4 is plastic explosive of the common variety Composition C. You can use it to breach walls, attach it to organisms to destroy them, or connect a signaler to its wiring to make it remotely detonable. It has a modifiable timer with a minimum setting of 10 seconds."
	item = /obj/item/weapon/plastique
	cost = 2

/datum/uplink_item/device_tools/powersink
	name = "Power sink"
	desc = "When screwed to wiring attached to an electric grid, then activated, this large device places excessive load on the grid, causing a stationwide blackout. The sink cannot be carried because of its excessive size. Ordering this sends you a small beacon that will teleport the power sink to your location on activation."
	item = /obj/item/device/powersink
	cost = 5

/datum/uplink_item/device_tools/singularity_beacon
	name = "Singularity Beacon"
	desc = "When screwed to wiring attached to an electric grid, then activated, this large device pulls the singularity towards it. Does not work when the singularity is still in containment. A singularity beacon can cause catastrophic damage to a space station, leading to an emergency evacuation. Because of its size, it cannot be carried. Ordering this sends you a small beacon that will teleport the larger beacon to your location on activation."
	item = /obj/item/beacon/syndicate
	cost = 7

/datum/uplink_item/device_tools/pdapinpointer
	name = "PDA Pinpointer"
	desc = "A pinpointer that tracks any PDA on the station. Useful for locating assassination targets or other high-value targets that you can't find. WARNING: Can only set once."
	item = /obj/item/weapon/pinpointer/pdapinpointer
	cost = 2

/datum/uplink_item/device_tools/teleporter
	name = "Teleporter Circuit Board"
	desc = "A printed circuit board that completes the teleporter onboard the mothership. Advise you test fire the teleporter before entering it, as malfunctions can occur."
	item = /obj/item/weapon/circuitboard/teleporter
	cost = 20
	gamemodes = list("nuclear emergency")

/datum/uplink_item/device_tools/popout_cake
	name = "Pop-Out Cake"
	desc = "A massive and delicious cake, big enough to store a person inside. It's equipped with a one-use party horn and special effects, and can be cut into edible slices in case of an emergency."
	item = /obj/structure/popout_cake
	cost = 3
	gamemodes = list("nuclear emergency")

// IMPLANTS

/datum/uplink_item/implants
	category = "Implants"

/datum/uplink_item/implants/freedom
	name = "Freedom Implant"
	desc = "An implant injected into the body and later activated using a bodily gesture to attempt to slip restraints."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_freedom
	cost = 3

/datum/uplink_item/implants/uplink
	name = "Uplink Implant"
	desc = "An implant injected into the body, and later activated using a bodily gesture to open an uplink with 5 telecrystals. The ability for an agent to open an uplink after their posessions have been stripped from them makes this implant excellent for escaping confinement."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_uplink
	cost = 10

/datum/uplink_item/implants/explosive
	name = "Explosive Implant"
	desc = "An implant injected into the body, and later activated using a vocal command to cause a large explosion from the implant."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_explosive
	cost = 6

/datum/uplink_item/implants/compression
	name = "Compressed Matter Implant"
	desc = "An implant injected into the body, and later activated using a bodily gesture to retrieve an item that was earlier compressed."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_compress
	cost = 4


// POINTLESS BADASSERY

/datum/uplink_item/badass
	category = "Badassery"

/datum/uplink_item/badass/bundle
	name = "Syndicate Bundle"
	desc = "Syndicate Bundles are specialised groups of items that arrive in a plain box. These items are collectively worth more than 10 telecrystals, but you do not know which specialisation you will receive."
	item = /obj/item/weapon/storage/box/syndicate
	cost = 10

/datum/uplink_item/badass/balloon
	name = "For showing that you are The Boss"
	desc = "A useless red balloon with the syndicate logo on it, which can blow the deepest of covers."
	item = /obj/item/toy/syndicateballoon
	cost = 10

/datum/uplink_item/badass/trophybelt
 	name = "Trophy Belt"
 	desc = "A belt for holding the heads you've collected."
 	item = /obj/item/weapon/storage/belt/skull
 	cost = 2

/datum/uplink_item/badass/raincoat
 	name = "Raincoat"
 	desc = "It's hip to be square!"
 	item = /obj/item/clothing/suit/raincoat
 	cost = 1

/datum/uplink_item/badass/random
	name = "Random Item"
	desc = "Picking this choice will send you a random item from the list. Useful for when you cannot think of a strategy to finish your objectives with."
	item = /obj/item/weapon/storage/box/syndicate
	cost = 0

/datum/uplink_item/badass/random/spawn_item(var/turf/loc, var/obj/item/device/uplink/U)

	var/list/buyable_items = get_uplink_items()
	var/list/possible_items = list()

	for(var/category in buyable_items)
		for(var/datum/uplink_item/I in buyable_items[category])
			if(I == src)
				continue
			if(I.cost > U.uses)
				continue
			possible_items += I

	if(possible_items.len)
		var/datum/uplink_item/I = pick(possible_items)
		U.uses -= max(0, I.cost)
		feedback_add_details("traitor_uplink_items_bought","RN")
		return new I.item(loc)
