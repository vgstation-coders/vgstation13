var/list/uplink_items = list()

/proc/get_uplink_items()
	// If not already initialized..
	if(!uplink_items.len)

		// Fill in the list	and order it like this:
		// A keyed list, acting as categories, which are lists to the datum.

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

	var/only_on_month	//two-digit month as string
	var/only_on_day		//two-digit day as string
	var/num_in_stock = 0	// Number of times this can be bought, globally. 0 is infinite
	var/times_bought = 0
	var/refundable = FALSE
	var/refund_path = null // Alternative path for refunds, in case the item purchased isn't what is actually refunded (Bombs and such).
	var/refund_amount // specified refund amount in case there needs to be a TC penalty for refunds.

/datum/uplink_item/proc/get_cost(var/user_job, var/cost_modifier = 1)
	if(gives_discount(user_job))
		. = discounted_cost
	else
		. = cost
	. = Ceiling(. * cost_modifier) //"." is our return variable, effectively the same as doing "var/X", working on X, then returning X

/datum/uplink_item/proc/gives_discount(var/user_job)
	return user_job && jobs_with_discount.len && jobs_with_discount.Find(user_job)

/datum/uplink_item/proc/available_for_job(var/user_job)
	return user_job && !(jobs_exclusive.len && !jobs_exclusive.Find(user_job)) && !(jobs_excluded.len && jobs_excluded.Find(user_job))

/datum/uplink_item/proc/spawn_item(var/turf/loc, var/obj/item/device/uplink/U, mob/user)
	if(!available_for_job(U.job))
		message_admins("[key_name(user)] tried to purchase \the [src.name] from their uplink despite not being available to their job! (Job: [U.job]) ([formatJumpTo(get_turf(U))])")
		return
	U.uses -= max(get_cost(U.job), 0)
	feedback_add_details("traitor_uplink_items_bought", name)
	return new item(loc,user)

/datum/uplink_item/proc/buy(var/obj/item/device/uplink/hidden/U, var/mob/user)
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
	if ((U.loc in user.contents || (in_range(U.loc, user) && istype(U.loc.loc, /turf))))
		user.set_machine(U)
		if(get_cost(U.job) > U.uses)
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

			U.purchase_log += {"[user] ([user.ckey]) bought <img src="logo_[tempstate].png"> [name] for [get_cost(U.job)]."}
			stat_collection.uplink_purchase(src, I, user)
			times_bought += 1

			if(user.mind)
				user.mind.spent_TC += get_cost(U.job)
				//First, try to add the uplink buys to any operative teams they're on. If none, add to a traitor role they have.
				var/datum/role/R = user.mind.GetRole(NUKE_OP)
				if(R)
					R.faction.faction_scoreboard_data += {"<img src="logo_[tempstate].png"> [bundlename] for [get_cost(U.job)] TC<BR>"}
				else
					R = user.mind.GetRole(TRAITOR)
					if(R)
						R.uplink_items_bought += {"<img src="logo_[tempstate].png"> [bundlename] for [get_cost(U.job)] TC<BR>"}
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

/datum/uplink_item/valentine
	category = "Valentine's Day Special!"
	only_on_month = "02"
	only_on_day = "14"

/datum/uplink_item/valentine/explosivechocolate
	name = "Explosive Chocolate Bar"
	desc = "A special Valentine's Day chocolate bar chock-full of Bicarodyne. For adding that little extra oompf to your hugs."
	item = /obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped/valentine/syndicate
	cost = 8

//Nuke Ops Prices
/datum/uplink_item/nukeprice
	jobs_exclusive = list("Nuclear Operative")

/datum/uplink_item/nukeprice/crossbow
	name = "Energy Crossbow"
	desc = "A miniature energy crossbow that is small enough both to fit into a pocket and to slip into a backpack unnoticed by observers. Fires bolts tipped with an organic, poisonous substance. Stuns enemies for a short period of time. Recharges on its own."
	category = "Highly Visible and Dangerous Weapons"
	item = /obj/item/weapon/gun/energy/crossbow
	cost = 10

/datum/uplink_item/nukeprice/voice_changer
	name = "Voice Changer"
	desc = "A conspicuous gas mask that mimics the voice named on your identification card. When no identification is worn, the mask will render your voice distinguishably unrecognizable."
	category = "Stealth and Camouflage Items"
	item = /obj/item/clothing/mask/gas/voice
	cost = 8

/datum/uplink_item/nukeprice/syndigaloshes
	name = "No-Slip Chameleon Shoes"
	desc = "A pair of species-flexible shoes that can look, and in some cases sound, like any other piece of footgear. Protects against slipping on water, but cannot protect against lubricated surfaces. They can attract suspicion while off your person, and are explicitly identifiable as illegal tech when closely examined."
	category = "Stealth and Camouflage Items"
	item = /obj/item/clothing/shoes/syndigaloshes
	cost = 4

/datum/uplink_item/nukeprice/chameleon_jumpsuit
	name = "Chameleon Jumpsuit"
	desc = "A jumpsuit used to imitate the uniforms of Nanotrasen crewmembers. When caught in an EMP blast, will become psychedelic and unchangeable. When interacted with by another jumpsuit, will scan and add its appearance."
	category = "Stealth and Camouflage Items"
	item = /obj/item/clothing/under/chameleon
	cost = 6

// DANGEROUS WEAPONS

/datum/uplink_item/dangerous
	category = "Highly Visible and Dangerous Weapons"

/datum/uplink_item/dangerous/revolver
	name = "Fully Loaded Revolver"
	desc = "A traditional handgun which fires .357 rounds. Has 7 chambers. Can down an unarmored target with two shots."
	item = /obj/item/weapon/gun/projectile
	cost = 12

/datum/uplink_item/dangerous/ammo
	name = "Ammo-357"
	desc = "A speedloader and seven additional rounds for the revolver. Extra seven-piece boxes of .357 rounds can be made in a modified autolathe."
	item = /obj/item/weapon/storage/box/syndie_kit/ammo
	cost = 4

/datum/uplink_item/dangerous/crossbow
	name = "Energy Crossbow"
	desc = "A miniature energy crossbow that is small enough both to fit into a pocket and to slip into a backpack unnoticed by observers. Fires bolts tipped with an organic, poisonous substance. Stuns enemies for a short period of time. Recharges on its own."
	item = /obj/item/weapon/gun/energy/crossbow
	cost = 12
	jobs_excluded = list("Nuclear Operative")

/datum/uplink_item/dangerous/sword
	name = "Energy Sword"
	desc = "The esword is an edged weapon with a blade of pure energy. The sword is small enough to be pocketed when inactive. Activating it produces a loud, distinctive noise."
	item = /obj/item/weapon/melee/energy/sword
	cost = 8

/datum/uplink_item/dangerous/machete
	name = "High-Frequency Machete"
	desc = "A broad blade used either as an implement or in combat. When inactive can be used as an powerful throwing weapon and when activated its damage is comparable to an Energy Sword."
	item = /obj/item/weapon/melee/energy/hfmachete
	cost = 8

/datum/uplink_item/dangerous/emp
	name = "5 EMP Grenades"
	desc = "A box that contains 5 EMP grenades. Useful to disrupt communication and silicon lifeforms."
	item = /obj/item/weapon/storage/box/emps
	cost = 4

/datum/uplink_item/dangerous/viscerator
	name = "Viscerator Grenade"
	desc = "A single grenade containing a pair of incredibly destructive viscerators. Be aware that they will attack any nearby targets, including yourself. Emits a blinding flash upon detonation."
	item = /obj/item/weapon/grenade/spawnergrenade/manhacks/syndicate
	cost = 6

/datum/uplink_item/dangerous/butterfly
	name = "Butterfly Knife"
	desc = "A butterfly knife containing a deadly viscerator. It can be flipped to conceal the blade and deploy a stored viscerator. The viscerator will self destruct after 20 seconds but the knife will renew it's storage every 25 seconds automatically."
	item = /obj/item/weapon/butterflyknife/viscerator
	cost = 7

/datum/uplink_item/dangerous/gatling
	name = "Gatling Gun"
	desc = "A huge minigun. Makes up for its lack of mobility and discretion with sheer firepower. Has 200 bullets."
	item = /obj/structure/closet/crate/secure/weapon/experimental/gatling
	cost = 40
	jobs_exclusive = list("Nuclear Operative")

/datum/uplink_item/dangerous/nikita
	name = "Nikita RC Missile Launcher"
	desc = "A remote-controlled missile launcher, trades in raw explosive power for extreme steering precision, this one might actually not blow up in your face. Comes with four rockets"
	item = /obj/structure/closet/crate/secure/weapon/experimental/nikita
	cost = 40
	jobs_exclusive = list("Nuclear Operative")

/datum/uplink_item/dangerous/hecate
	name = "PMG Hecate II Anti-Material Rifle"
	desc = "A .50 BMG anti-material sniper rifle. Anything between the barrel and the next three solid walls should be tenderized in short order. Comes with eight individual rounds, thermals and earmuffs."
	item = /obj/structure/closet/crate/secure/weapon/experimental/hecate
	cost = 40
	jobs_exclusive = list("Nuclear Operative")

/datum/uplink_item/dangerous/dude_bombs_lmao
	name = "Modified Tank Transfer Valve"
	desc = "A small, expensive and powerful plasma-oxygen explosive. Handle very carefully."
	item = /obj/effect/spawner/newbomb
	cost = 25
	jobs_exclusive = list("Nuclear Operative")
	refundable = TRUE

/datum/uplink_item/dangerous/robot
	name = "Syndicate-modded Combat Robot Teleporter"
	desc = "A single-use teleporter used to deploy a syndicate robot that will help with your mission. Keep in mind that unlike NT silicons these don't have access to most of the station's machinery."
	item = /obj/item/weapon/robot_spawner/syndicate
	cost = 60
	jobs_exclusive = list("Nuclear Operative")
	refundable = TRUE

/datum/uplink_item/dangerous/mecha
	name = "Syndicate Mass-Produced Assault Mecha - 'Mauler'"
	desc = "A Heavy-duty combat unit. Not usually used by nuclear operatives, for its ridiculous pricetag and lack of stealth. Yet, against heavily-guarded stations, it might be just the thing." //Implying bombs aren't better.
	item = /obj/effect/spawner/mecha/mauler
	cost = 80
	jobs_exclusive = list("Nuclear Operative")

// STEALTHY WEAPONS

/datum/uplink_item/stealthy_weapons
	category = "Stealthy and Inconspicuous Weapons"

/datum/uplink_item/stealthy_weapons/para_pen
	name = "Paralysis Pen"
	desc = "A syringe disguised as a functional pen, filled with a neuromuscular-blocking drug that renders a target immobile on injection and makes them appear dead to observers and scanners. Side effects of the drug include increased toxicity in the victim. The pen holds one dose of paralyzing agent, and cannot be refilled."
	item = /obj/item/weapon/pen/paralysis
	cost = 8

/datum/uplink_item/stealthy_weapons/soap
	name = "Syndicate Soap"
	desc = "A sinister-looking surfactant used to clean blood stains to hide murders and prevent DNA analysis. You can also drop it underfoot to slip people."
	item = /obj/item/weapon/soap/syndie
	cost = 1

/datum/uplink_item/stealthy_weapons/detomatix
	name = "Detomatix PDA Cartridge"
	desc = "When inserted into a Personal Data Assistant, this cartridge gives you four opportunities to detonate PDAs of crewmembers who have their message feature enabled. The concussive effect from the explosion will knock the recipient out for a short period, and deafen them for longer. It has a chance to detonate your PDA."
	item = /obj/item/weapon/cartridge/syndicate
	cost = 6

/datum/uplink_item/stealthy_weapons/knuckles
	name = "Spiked Knuckles"
	desc = "A pair of spiked metal knuckles that can be worn on your hands, increasing damage done by your punches."
	item = /obj/item/clothing/gloves/knuckles/spiked
	cost = 2

// STEALTHY TOOLS

/datum/uplink_item/stealthy_tools
	category = "Stealth and Camouflage Items"

/datum/uplink_item/stealthy_tools/chameleon_jumpsuit
	name = "Chameleon Jumpsuit"
	desc = "A jumpsuit used to imitate the uniforms of Nanotrasen crewmembers. When caught in an EMP blast, will become psychedelic and unchangeable. When interacted with by another jumpsuit, will scan and add its appearance."
	item = /obj/item/clothing/under/chameleon
	cost = 2
	jobs_excluded = list("Nuclear Operative")

/datum/uplink_item/stealthy_tools/cold_jumpsuit
	name = "Quick Vent Jumpsuit"
	desc = "A variant of the Chameleon Jumpsuit that quickly vents the wearer's body heat, causing them to suffer latent hypothermia"
	item = /obj/item/clothing/under/chameleon/cold
	cost = 2

/datum/uplink_item/stealthy_tools/syndigaloshes
	name = "No-Slip Chameleon Shoes"
	desc = "A pair of species-flexible shoes that can look, and in some cases sound, like any other piece of footgear. Protects against slipping on water, but cannot protect against lubricated surfaces. They can attract suspicion while off your person, and are explicitly identifiable as illegal tech when closely examined."
	item = /obj/item/clothing/shoes/syndigaloshes
	cost = 2
	jobs_excluded = list("Nuclear Operative")

/datum/uplink_item/stealthy_tools/agent_card
	name = "Agent ID Card"
	desc = "Agent cards prevent artificial intelligences from tracking the wearer, and can copy access from other identification cards. The access is cumulative, so scanning one card does not erase the access gained from another."
	item = /obj/item/weapon/card/id/syndicate
	cost = 2

/datum/uplink_item/stealthy_tools/voice_changer
	name = "Voice Changer"
	desc = "A conspicuous gas mask that mimics the voice named on your identification card. When no identification is worn, the mask will render your voice distinguishably unrecognizable."
	item = /obj/item/clothing/mask/gas/voice
	cost = 5
	jobs_excluded = list("Nuclear Operative")

/datum/uplink_item/stealthy_tools/dnascrambler
	name = "DNA Scrambler"
	desc = "A syringe with one injection that randomizes appearance and name upon use. A cheaper but less versatile alternative to an agent card and voice changer. A crewmember with a copy of the crew manifest and/or a security HUD could question your identity."
	item = /obj/item/weapon/dnascrambler
	cost = 4

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Chameleon-Projector"
	desc = "Projects an image across a user, disguising them as an object scanned with it, as long as they don't move the projector from their hand. The disguised user cannot run and projectiles pass over them."
	item = /obj/item/device/chameleon
	cost = 6

/datum/uplink_item/stealthy_tools/smoke_bombs
	name = "Instant Smoke Bombs"
	desc = "A package of eight instant-action smoke bombs, cleverly disguised as harmless snap-pops. The cover of smoke they create is large enough to cover most of a room. Pair well with thermal imaging glasses."
	item = /obj/item/weapon/storage/box/syndie_kit/smokebombs
	cost = 2

/datum/uplink_item/stealthy_tools/decoy_balloon
	name = "Decoy Balloon"
	desc = "A balloon that looks just like you when inflated."
	item = /obj/item/toy/balloon/decoy
	cost = 1

/datum/uplink_item/stealthy_tools/flashlightemp
	name = "EMP Flashlight"
	desc = "A flashlight that blasts a weak EMP pulse on whatever or whoever you use it on. Up to 4 charges that recover every 30 seconds, as shown when examined. Devastating against energy weapons and silicons. Can use it to cheat at the Arcade machine."
	item = /obj/item/device/flashlight/emp
	cost = 4


// DEVICE AND TOOLS

/datum/uplink_item/device_tools
	category = "Devices and Tools"
	abstract = 1

/datum/uplink_item/device_tools/emag
	name = "Cryptographic Sequencer"
	desc = "Also referred to as the \"emag\", a small card that unlocks hidden functions in electronic devices, subverts intended functions and characteristically breaks security mechanisms. Many machines will show signs of tampering if used."
	item = /obj/item/weapon/card/emag
	cost = 6

/datum/uplink_item/device_tools/toolbox
	name = "Fully Loaded Toolbox"
	desc = "A suspicious black and red toolbox with a cable coil and multitool. Insulated gloves are not included."
	item = /obj/item/weapon/storage/toolbox/syndicate
	cost = 1

/datum/uplink_item/device_tools/bugdetector
	name = "Bug Detector & Camera Disabler"
	desc = "A functional multitool that can detect certain surveillance devices. Its screen changes color if the AI or a pAI can see you, or if a tape recorder or voice analyzer is nearby. Conspicuous if currently detecting something. Examine it to see everything it detects. Activating it will disable cameras nearby, plus the ones far away randomly, causing massive disruptions to the AI and anyone using them."
	item = /obj/item/device/multitool/ai_detect
	cost = 3

/datum/uplink_item/device_tools/space_suit
	name = "Space Suit"
	desc = "The red syndicate space suit is less encumbering than Nanotrasen variants, fits inside bags, and has a weapon slot. Nanotrasen crewmembers are trained to report red space suit sightings."
	item = /obj/item/weapon/storage/box/syndie_kit/space
	cost = 4

/datum/uplink_item/device_tools/thermal
	name = "Thermal Imaging Glasses"
	desc = "These glasses are thermals disguised as engineers' optical meson scanners. Allows you to see organisms through walls and regardless of light."
	item = /obj/item/clothing/glasses/thermal/syndi
	cost = 6

/datum/uplink_item/device_tools/surveillance
	name = "Camera Surveillance Kit"
	desc = "A kit containing five camera bugs and one mobile receiver. Attach camera bugs to a camera to enable remote viewing."
	item = /obj/item/weapon/storage/box/syndie_kit/surveillance
	cost = 6

/datum/uplink_item/device_tools/camerabugs
	name = "Camera Bugs"
	desc = "A box of five camera bugs. Does not come with a receiver."
	item = /obj/item/weapon/storage/box/surveillance
	cost = 4

/datum/uplink_item/device_tools/binary
	name = "Binary Translator Key"
	desc = "A key that, when inserted into a radio headset, allows you to listen to and talk with artificial intelligences and cybernetic organisms in binary."
	item = /obj/item/device/encryptionkey/binary
	cost = 5

/datum/uplink_item/device_tools/cipherkey
	name = "Centcomm Encryption Key"
	desc = "A key that, when inserted into a radio headset, allows you to listen to and talk on all known radio channels."
	item = /obj/item/device/encryptionkey/syndicate/hacked
	cost = 4

/datum/uplink_item/device_tools/hacked_module
	name = "Hacked AI Upload Module"
	desc = "When used with an upload console, this module allows you to upload priority laws to an artificial intelligence. Be careful with their wording, as artificial intelligences may look for loopholes to exploit. The laws uploaded surpass core laws and have priority in the order they are uploaded."
	item = /obj/item/weapon/aiModule/freeform/syndicate
	cost = 14

/datum/uplink_item/device_tools/plastic_explosives
	name = "Composition C-4"
	desc = "C-4 is plastic explosive of the common variety Composition C. You can use it to breach walls, attach it to organisms to destroy them, or connect a signaler to its wiring to make it remotely detonable. It has a modifiable timer with a minimum setting of 10 seconds."
	item = /obj/item/weapon/plastique
	cost = 4

/datum/uplink_item/device_tools/explosive_gum
	name = "Explosive Chewing Gum"
	desc = "A single stick of explosive chewing gum, detonates five seconds after you start chewing. Can be stuck to walls and objects."
	item = /obj/item/gum/explosive
	cost = 6

/datum/uplink_item/device_tools/powersink
	name = "Power Sink"
	desc = "When screwed to wiring attached to an electric grid, then activated, this large device places excessive load on the grid, causing a stationwide blackout. The sink cannot be carried because of its massive size. Ordering this sends you a small beacon that will teleport the power sink to your location on activation."
	item = /obj/item/device/powersink
	cost = 10

/datum/uplink_item/device_tools/singularity_beacon
	name = "Singularity Beacon"
	desc = "When screwed to wiring attached to an electric grid, then activated, this large device pulls the singularity towards it. Does not work when the singularity is still in containment. A singularity beacon can cause catastrophic damage to a space station, leading to an emergency evacuation. Because of its size, it cannot be carried. Ordering this sends you a small beacon that will teleport the larger beacon to your location on activation."
	item = /obj/item/beacon/syndicate
	cost = 14

/datum/uplink_item/device_tools/pdapinpointer
	name = "PDA Pinpointer"
	desc = "A pinpointer that tracks any PDA on the station. Useful for locating assassination targets or other high-value targets that you can't find. WARNING: Can only set once."
	item = /obj/item/weapon/pinpointer/pdapinpointer
	cost = 4

/datum/uplink_item/device_tools/teleporter
	name = "Teleporter Circuit Board"
	desc = "A printed circuit board that completes the teleporter onboard the mothership. It is advised to test fire the teleporter before entering it, as malfunctions can occur."
	item = /obj/item/weapon/circuitboard/teleporter
	cost = 40
	jobs_exclusive = list("Nuclear Operative")

/datum/uplink_item/device_tools/popout_cake
	name = "Pop-Out Cake"
	desc = "A massive and delicious cake, big enough to store a person inside. It's equipped with a one-use party horn and special effects, and can be cut into edible slices in case of an emergency."
	item = /obj/structure/popout_cake
	cost = 6
	jobs_exclusive = list("Nuclear Operative")

/datum/uplink_item/device_tools/megaphone
	name = "Mad Scientist Megaphone"
	desc = "For making your demands known. On top of making your speech loud, it can broadcast into (but not receive from) station radio frequencies, including Security and Command. Can also optionally scramble your voice, for ominous-anonymous threats."
	item = /obj/item/device/megaphone/madscientist
	num_in_stock = 3
	cost = 1
	discounted_cost = 0
	jobs_with_discount = SCIENCE_POSITIONS

/datum/uplink_item/device_tools/reportintercom
	name = "NTT Report Falsifier"
	desc = "An intercom stolen from Nanotrasen Command that allows a single fake Galactic Update to be sent. Single-Use only. Let the crew know about the upcoming disk inspection."
	item = /obj/item/device/reportintercom
	cost = 6
	discounted_cost = 4
	jobs_with_discount = list("Nuclear Operative")

/datum/uplink_item/device_tools/does_not_tip_note
	name = "\"Does Not Tip\" database backdoor"
	desc = "Lets you add or remove your station to the \"does not tip\" list kept by the cargo workers at Central Command. You can be sure all pizza orders will be poisoned from the moment the screen flashes red."
	item = /obj/item/device/does_not_tip_backdoor
	num_in_stock = 1
	cost = 10

// IMPLANTS

/datum/uplink_item/implants
	category = "Implants"

/datum/uplink_item/implants/freedom
	name = "Freedom Implant"
	desc = "An implant usable after injection into the body. Activated using a bodily gesture to slip restraints. Has four uses."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_freedom
	cost = 5

/datum/uplink_item/implants/uplink
	name = "Uplink Implant"
	desc = "An implant usable after injection into the body. Activated using a bodily gesture to open an uplink with 10 telecrystals. The ability for an agent to open an uplink after their posessions have been stripped from them makes this implant excellent for escaping confinement."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_uplink
	cost = 16

/datum/uplink_item/implants/explosive
	name = "Explosive Implant"
	desc = "An implant usable after injection into the body. Activated using a vocal command to cause a large explosion from the implant."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_explosive
	cost = 12

/datum/uplink_item/implants/compression
	name = "Compressed Matter Implant"
	desc = "An implant usable after injection into the body. Activated using a bodily gesture to retrieve an item that was earlier compressed."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_compress
	cost = 6


// POINTLESS BADASSERY

/datum/uplink_item/badass
	category = "Badassery"

/datum/uplink_item/badass/bundle
	name = "Syndicate Bundle"
	desc = "Syndicate Bundles are specialised bundles of Syndicate items that arrive in a plain box. These items are collectively worth significantly more than 14 telecrystals, but you do not know which bundle you will receive."
	item = /obj/item/weapon/storage/box/syndicate
	cost = 14

/datum/uplink_item/badass/balloon
	name = "For showing that you are The Boss"
	desc = "A useless red balloon with the syndicate logo on it, which can blow the deepest of covers."
	item = /obj/item/toy/syndicateballoon
	cost = 20

/datum/uplink_item/badass/trophybelt
 	name = "Trophy Belt"
 	desc = "A belt for holding the heads you've collected."
 	item = /obj/item/weapon/storage/belt/skull
 	cost = 4

/datum/uplink_item/badass/raincoat
 	name = "Raincoat"
 	desc = "It's hip to be square!"
 	item = /obj/item/clothing/suit/raincoat
 	cost = 1

/datum/uplink_item/badass/random
	name = "Random Item"
	desc = "Picking this choice will send you a random item from the list for half the cost. Useful for when you cannot think of a strategy to finish your objectives with."
	item = /obj/item/weapon/storage/box/syndicate
	cost = 0

/datum/uplink_item/badass/random/spawn_item(var/turf/loc, var/obj/item/device/uplink/U)

	var/list/buyable_items = get_uplink_items()
	var/list/possible_items = list()

	for(var/category in buyable_items)
		for(var/datum/uplink_item/I in buyable_items[category])
			if(I == src)
				continue
			if(!I.available_for_job(U.job))
				continue
			if(I.get_cost(U.job, 0.5) > U.uses)
				continue
			possible_items += I

	if(possible_items.len)
		var/datum/uplink_item/I = pick(possible_items)
		U.uses -= max(0, I.get_cost(U.job, 0.5))
		feedback_add_details("traitor_uplink_items_bought","RN")
		return new I.item(loc)




/datum/uplink_item/jobspecific
	category = "Job Specials"

/datum/uplink_item/jobspecific/syndicuffs
	name = "Syndicate Cuffs"
	desc = "A pair of cuffs rigged with electronics and laced with a C4 charge. Can be toggled between explosion on application and explosion on removal."
	item = /obj/item/weapon/handcuffs/syndicate
	cost = 5
	discounted_cost = 4
	jobs_with_discount = list("Security Officer", "Warden", "Head of Security")

/datum/uplink_item/jobspecific/syndietape_police
	name = "Syndicate Police Tape"
	desc = "A length of police tape rigged with adapative electronics that will wraps itself around the hands unathorised personnel who crosses it, cuffing them.  Do not (let them) cross. Can be used 3 times."
	item = /obj/item/taperoll/syndie/police
	cost = 10
	discounted_cost = 8
	jobs_with_discount = list("Security Officer", "Warden", "Head of Security")

/datum/uplink_item/jobspecific/evidenceforger
	name = "Evidence Forger"
	desc = "An evidence scanner that allows you to forge evidence by setting the output before scanning the item."
	item = /obj/item/device/detective_scanner/forger
	cost = 6
	discounted_cost = 4
	jobs_with_discount = list("Detective")

/datum/uplink_item/jobspecific/conversionkit
	name = "Revolver Conversion Kit"
	desc = "A bundle that comes with a professional revolver conversion kit and 1 box of .357 ammo. The kit allows you to convert your revolver to fire lethal rounds or vice versa. The modification is perfect and will not result in catastrophic failure, but remember to empty your gun first!"
	item = /obj/item/weapon/storage/box/syndie_kit/conversion
	cost = 12
	discounted_cost = 10
	jobs_with_discount = list("Detective")

/datum/uplink_item/jobspecific/briefcase_smg
	name = "Concealed SMG"
	desc = "A modified briefcase capable of storing and firing a gun under a false bottom. Starts with an internal SMG and 18 rounds. Use a screwdriver to pry away the false bottom and make modifications. Distinguishable upon close examination due to the added weight."
	item = /obj/item/weapon/storage/briefcase/false_bottomed/smg
	cost = 14
	discounted_cost = 10
	jobs_with_discount = list("Internal Affairs Agent")

/datum/uplink_item/jobspecific/knifeboot
	name = "Concealed knife shoes"
	desc = "Shoes with a knife concealed in the toecap. Tap your heels together to reveal the knife. Kick the target to stab them."
	item = /obj/item/clothing/shoes/knifeboot
	cost = 4
	discounted_cost = 2
	jobs_with_discount = list("Internal Affairs Agent")

/datum/uplink_item/jobspecific/ambrosiacruciatus
	name = "Ambrosia Cruciatus Seeds"
	desc = "Part of the notorious Ambrosia family, this species is nearly indistinguishable from Ambrosia Vulgaris. However, its branches contain a revolting toxin. Eight units are enough to drive victims insane after a three-minute delay."
	item = /obj/item/seeds/ambrosiacruciatusseed
	cost = 6
	discounted_cost = 2
	jobs_with_discount = list("Botanist")

/datum/uplink_item/jobspecific/beecase
	name = "Briefcase Full of Bees"
	desc = "A briefcase containing twenty angry bees."
	item = /obj/item/weapon/storage/briefcase/bees
	cost = 5
	discounted_cost = 4
	jobs_with_discount = list("Botanist")

/datum/uplink_item/jobspecific/hornetqueen
	name = "Hornet Queen Packet"
	desc = "Place her into an apiary tray, add a few packs of BeezEez, then lay it inside your nemesis' office. Surprise guaranteed. Protective gear won't be enough to shield you reliably from these."
	item = /obj/item/queen_bee/hornet
	cost = 3
	discounted_cost = 2
	jobs_with_discount = list("Botanist")

/datum/uplink_item/jobspecific/syndiepaper
	name = "Extra Adhesive Wrapping Paper"
	desc = "This extra-strong wrapping paper is perfect for concealing bodies or trapping a victim with no escape. Simply apply directly to the victim and wrap them up into a regular-looking delivery package. Takes about three seconds to wrap."
	item = /obj/item/stack/package_wrap/syndie
	cost = 6
	discounted_cost = 4
	jobs_with_discount = list("Cargo Technician", "Quartermaster")

/datum/uplink_item/jobspecific/syndiepaper/spawn_item(var/turf/loc, var/obj/item/device/uplink/U, mob/user)
	U.uses -= max(cost, 0)
	feedback_add_details("traitor_uplink_items_bought", name)
	return new item(loc) //Fix for amount ref

/datum/uplink_item/jobspecific/mastertrainer
	name = "Master Trainer's Belt"
	desc = "A trainer's belt containing 6 random hostile mobs loyal to you alone."
	item = /obj/item/weapon/storage/belt/lazarus/antag
	cost = 12
	discounted_cost = 8
	jobs_with_discount = list("Shaft Miner")

/datum/uplink_item/jobspecific/clowngrenade
	name = "1 Banana Grenade"
	desc = "A grenade that, when exploded, releases banana peels that are genetically modified to be extra slippery and release caustic acid when stepped on."
	item = /obj/item/weapon/grenade/clown_grenade
	cost = 6
	discounted_cost = 5
	jobs_with_discount = list("Clown")

/datum/uplink_item/jobspecific/bsword
	name = "Energized Bananium Sword"
	desc = "When concealed a simple banana, when active a deadly means of executing swift justice. Highly regarded for their utility on away missions from the Clown Planet. WARNING: Extremely dangerous if two Bananium Swords are combined! Only those trained in the clownish arts should attempt!"
	item = /obj/item/weapon/melee/energy/sword/bsword
	cost = 8
	jobs_exclusive = list("Clown")

/datum/uplink_item/jobspecific/banannon
	name = "Banannon"
	desc = "A fearsome example of clown technology, the armor-piercing discarding sabonanas fired by this weapon shed their peels in flight, increasing their damage and creating a slipping hazard. WARNING: Only those trained in the clownish arts can use this weapon effectively!"
	item = /obj/item/weapon/gun/banannon
	cost = 18
	jobs_exclusive = list("Clown")

/datum/uplink_item/jobspecific/livingballoons
	name = "Box of Living Long Balloons"
	desc = "Can be tied into living balloon animals, which will come to life and attack non-clowns if a balloon is popped near them. Needless to say, using these is a bad idea for those not trained in the clownish arts."
	item = /obj/item/weapon/storage/box/balloons/long/living
	cost = 6
	jobs_exclusive = list("Clown")

/datum/uplink_item/jobspecific/bananagun
	name = "Banana Gun"
	desc = "One shot only, appears to be a banana until fired. Do not attempt to eat."
	item = /obj/item/weapon/gun/projectile/banana
	cost = 4
	discounted_cost = 2
	jobs_with_discount = list("Clown")

/datum/uplink_item/jobspecific/superglue
	name = "1 Bottle of Superglue"
	desc = "Considered illegal everywhere except for the Clown Planet, this water-resistant superglue can instantly bind human flesh to ANY material, permanently. One-time use."
	item = /obj/item/weapon/glue
	cost = 6
	discounted_cost = 4
	jobs_with_discount = list("Clown", "Mime")

/datum/uplink_item/jobspecific/invisible_spray
	name = "Can of Invisible Spray"
	desc = "Spray something to render it invisible for five minutes! One-time use. Permanence not guaranteed when exposed to water."
	item = /obj/item/weapon/invisible_spray
	cost = 6
	jobs_excluded = list("Clown", "Mime")

/datum/uplink_item/jobspecific/invisible_spray/permanent
	desc = "Spray something to render it permanently invisible! One-time use. Permanence not guaranteed when exposed to water."
	item = /obj/item/weapon/invisible_spray/permanent
	cost = 4
	jobs_excluded = list()
	jobs_exclusive = list("Clown", "Mime")

/datum/uplink_item/jobspecific/advancedmime
	name = "Advanced Mime Gloves"
	desc = "Grants the user the ability to periodically fire an invisible gun from their white gloves. Only real Mimes are trained in the art of firing this artefact silently."
	item = /obj/item/clothing/gloves/white/advanced
	cost = 12
	jobs_exclusive = list("Mime")

/datum/uplink_item/jobspecific/specialsauce
	name = "Chef Excellence's Special Sauce"
	desc = "A custom made sauce made from the toxin glands of many space carp. If one ingests enough, he or she will be dead in 3 minutes or less."
	item = /obj/item/weapon/reagent_containers/food/condiment/syndisauce
	cost = 8
	discounted_cost = 2
	jobs_with_discount = list("Chef")

/datum/uplink_item/jobspecific/meatcleaver
	name = "Meat Cleaver"
	desc = "A mean looking meat cleaver that does damage comparable to an Energy Sword but with the added benefit of chopping your victim into hunks of meat after they've died and the chance to stun when thrown."
	item = /obj/item/weapon/kitchen/utensil/knife/large/butch/meatcleaver
	cost = 12
	discounted_cost = 10
	jobs_with_discount = list("Chef")

/datum/uplink_item/jobspecific/cautionsign
	name = "Proximity Mine Wet Floor Sign"
	desc = "An Anti-Personnel proximity mine cleverly disguised as a wet floor caution sign that is triggered by running past it. Interact with it to start the 15 second timer and activate again to disarm."
	item = /obj/item/weapon/caution/proximity_sign
	cost = 5
	discounted_cost = 3
	jobs_with_discount = list("Janitor")

/datum/uplink_item/jobspecific/pickpocketgloves
	name = "Pickpocket's Gloves"
	desc = "A pair of sleek gloves to aid in pickpocketing, while wearing these you can sneakily strip any item without the other person being alerted. Pickpocketed items will also be put into your hand rather than fall to the ground."
	item = /obj/item/clothing/gloves/black/thief
	cost = 8
	discounted_cost = 6
	jobs_with_discount = list("Assistant")

/datum/uplink_item/jobspecific/greytide
	name = "Greytide Implants"
	desc = "A box containing two greytide implanters that when injected into another person makes them loyal to the greytide and your cause, unless they're already implanted by someone else. Loyalty ends if he or she no longer has the implant. CAUTION: WILL NOT WORK ON SUBJECTS WITH NT LOYALTY IMPLANTS. Now with disguised sechud sunglasses. These will have limited access until you can get your hands on some containing security codes."
	item = /obj/item/weapon/storage/box/syndie_kit/greytide
	cost = 20
	discounted_cost = 14
	jobs_with_discount = list("Assistant")

/datum/uplink_item/jobspecific/cheaptide
	name = "Cheaptide Implant"
	desc = "A box containing one greytide implanter that when injected into another person makes them loyal to the greytide and your cause, unless they're already implanted by someone else. Loyalty ends if he or she no longer has the implant. CAUTION: WILL NOT WORK ON SUBJECTS WITH NT LOYALTY IMPLANTS. Now with disguised sechud sunglasses. These will have limited access until you can get your hands on some containing security codes."
	item = /obj/item/weapon/storage/box/syndie_kit/cheaptide
	cost = 12
	discounted_cost = 8
	jobs_with_discount = list("Assistant")

/datum/uplink_item/jobspecific/drunkbullets
	name = "Boozey Shotgun Shells"
	desc = "A box containing 6 shotgun shells that simulate the effects of extreme drunkenness on the target. Efficacy increases for each type of alcohol in the target's bloodstream."
	item = /obj/item/weapon/storage/box/syndie_kit/boolets
	cost = 7
	discounted_cost = 6
	jobs_with_discount = list("Bartender")

/datum/uplink_item/jobspecific/chemsprayer
	name = "Chemical Sprayer"
	desc = "A powerful industrial spraygun that holds 600 units of any liquid and can cover large areas faster than a standard spray bottle."
	item = /obj/item/weapon/reagent_containers/spray/chemsprayer
	cost = 10
	discounted_cost = 8
	jobs_with_discount = list("Chemist", "Chief Medical Officer")

/datum/uplink_item/jobspecific/antisocial
	name = "Explosive Hug Chemical"
	desc = "30 units of Bicarodyne, a chemical that causes a devastating explosion when exposed to endorphins released in the body by a hug. Metabolizes quite slowly."
	item = /obj/item/weapon/storage/box/syndie_kit/explosive_hug //Had to be put in a box because it didn't play well with reagent creation
	cost = 9
	discounted_cost = 8
	jobs_with_discount = list("Chemist", "Chief Medical Officer")

/datum/uplink_item/jobspecific/wheelchair
	name = "Syndicate Wheelchair"
	desc = "A combat-modified motorized wheelchair. Forward thrust is sufficient to knock down and run over victims."
	item = /obj/item/syndicate_wheelchair_kit
	cost = 18
	discounted_cost = 12
	jobs_with_discount = list("Medical Doctor", "Chief Medical Officer")

/datum/uplink_item/jobspecific/hypozinebottle
	name = "Lethal Speed Chemical"
	desc = "30 units of Hypozine, a chemical that causes the body to synthesize hyperzine, but also causes increases in muscle speed at levels that tear the body apart. Metabolizes quite slowly."
	item = /obj/item/weapon/storage/box/syndie_kit/lethal_hyperzine
	cost = 5
	discounted_cost = 4
	jobs_with_discount = list("Chemist", "Medical Doctor", "Chief Medical Officer")

/datum/uplink_item/jobspecific/zombievirus
	name = "Zombie Virus Syndrome"
	desc = "This syndrome will cause people to turn into zombies when the virus hits Stage 4. Comes in a disk."
	item = /obj/item/weapon/disk/disease/zombie
	cost = 20
	discounted_cost = 12
	jobs_with_discount = list("Virologist", "Chief Medical Officer")

/datum/uplink_item/jobspecific/organ_remover
	name = "Modified Organics Extractor"
	desc = "A tool used by vox raiders to extract organs from unconscious victims has been reverse-engineered by syndicate scientists to be used by anyone, but it cannot extract hearts. It works twice as fast as the vox-only variant. Click on it to select the type of organ to extract, and then select the appropiate body zone."
	item = /obj/item/weapon/organ_remover/traitor
	cost = 8
	discounted_cost = 6
	jobs_with_discount = list("Medical Doctor", "Chief Medical Officer")

/datum/uplink_item/jobspecific/powergloves
	name = "Power Gloves"
	desc = "Insulated gloves that can utilize the power of the station to deliver a short arc of electricity at a target. Must be standing on a powered cable to use."
	item = /obj/item/clothing/gloves/yellow/power
	cost = 14
	discounted_cost = 8
	jobs_with_discount = list("Station Engineer", "Chief Engineer")

/datum/uplink_item/jobspecific/syndietape_engineering
	name = "Syndicate Engineering Tape"
	desc = "A length of engineering tape charged with a powerful electric potential. Will spark and shock people who attempt to remove it, creating fires. Can be used 3 times."
	item = /obj/item/taperoll/syndie/engineering
	cost = 4
	discounted_cost = 2
	jobs_with_discount = list("Station Engineer", "Chief Engineer")

/datum/uplink_item/jobspecific/contortionist
	name = "Contortionist's Jumpsuit"
	desc = "A highly flexible jumpsuit that will help you navigate the ventilation loops of the station internally. Comes with pockets and ID slot, but can't be used without stripping off most gear, including backpack, belt, helmet, and exosuit. Free hands are also necessary to crawl around inside."
	item = /obj/item/clothing/under/contortionist
	cost = 8
	discounted_cost = 6
	jobs_with_discount = list("Atmospheric Technician", "Chief Engineer")

/datum/uplink_item/jobspecific/syndietape_atmos
	name = "Syndicate Atmospherics Tape"
	desc = "A length of atmospherics tape made of an extremely sharp material that will cuts the hands of trespassers. Very difficult to remove. Can be used 3 times."
	item = /obj/item/taperoll/syndie/atmos
	cost = 4
	discounted_cost = 2
	jobs_with_discount = list("Atmospheric Technician", "Chief Engineer")

/datum/uplink_item/jobspecific/radgun
	name = "Radgun"
	desc = "An experimental energy gun that fires radioactive projectiles that burn, irradiate, and scramble DNA, giving the victim a different appearance and name, and potentially harmful or beneficial mutations. Recharges on its own."
	item = /obj/item/weapon/gun/energy/radgun
	cost = 18
	discounted_cost = 12
	jobs_with_discount = list("Geneticist", "Chief Medical Officer")

/datum/uplink_item/jobspecific/flaregun
	name = "Modified Flaregun"
	desc = "A modified flaregun, identical in most appearances to the regular kind, as well as 7 rounds of flare ammunition. Capable of firing flares at lethal velocity, as well as firing shotgun ammunition."
	item = /obj/item/weapon/storage/box/syndie_kit/flaregun
	cost = 6
	discounted_cost = 4
	jobs_with_discount = list("Atmospheric Technician", "Chief Engineer")

/datum/uplink_item/jobspecific/dev_analyser
	name = "Modified Device Analyser"
	desc = "A device analyser with the safety features disabled. Allows the user to replicate any kind of Syndicate equipment."
	item = /obj/item/device/device_analyser/syndicate
	cost = 9
	discounted_cost = 6
	jobs_with_discount = list("Mechanic")

/datum/uplink_item/jobspecific/etwenty
	name = "The E20"
	desc = "A seemingly innocent die. Those who are not afraid to roll for attack will find its effects quite explosive. Has a four second timer."
	item = /obj/item/weapon/dice/d20/e20
	cost = 6
	jobs_exclusive = list("Librarian")

/datum/uplink_item/jobspecific/traitor_bible
	name = "Feldbischof's Bible"
	desc = "A copy of the station's holy book of choice, with a little ballistic discount on conversions. 88 rapid, eight in the gun, eight in the extra mag."
	item = /obj/item/weapon/storage/bible/traitor_gun
	cost = 14
	discounted_cost = 10
	jobs_with_discount = list("Chaplain")

/datum/uplink_item/jobspecific/occultbook
	name = "Occult Book"
	desc = "A reproduction of a forbidden and occult book. Causes brain damage, eye damage and hallucinations to anyone unfortunate enough to attempt to read it. Use a pen to change its title."
	item = /obj/item/weapon/book/occult
	cost = 4
	discounted_cost = 2
	jobs_with_discount = list("Librarian", "Chaplain")

/datum/uplink_item/jobspecific/powercreeper_packet
	name = "Powercreep Packet"
	desc = "A packet that creates a dangerous mutated version of kudzu. The vines shock people and connect themselves to any cables near them."
	item = /obj/item/powercreeper_packet
	cost = 16
	discounted_cost = 10
	jobs_with_discount = list("Botanist", "Station Engineer", "Chief Engineer")
