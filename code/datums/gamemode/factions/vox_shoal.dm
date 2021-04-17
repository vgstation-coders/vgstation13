var/list/low_score_items = list(
	/obj/item/stack,
	/obj/item/clothing,
	/obj/item/weapon/reagent_containers,
	/obj/item/trash,
	/obj/item/weapon/stock_parts/,
	/obj/item/weapon/cell,
	/obj/item/clothing/gloves/yellow,
)

var/list/medium_score_items = list(
	/obj/item/weapon/disk/,
	/obj/item/clothing/shoes/magboots,
	/obj/item/weapon/storage/belt/utility,
	/obj/item/weapon/circuitboard,
	/obj/item/stack/sheet/mineral/diamond,
	/obj/item/stack/sheet/mineral/gold,
	/obj/item/weapon/gun,
	/obj/item/weapon/melee,
	/obj/item/weapon/reagent_containers/glass/beaker/bluespace,
	/obj/item/weapon/switchtool,
	/obj/item/device/am_shielding_container,
	/obj/item/ammo_storage,
)

var/list/high_score_items = list(
	/obj/item/weapon/pinpointer,
	/obj/item/weapon/disk/nuclear,
	/obj/item/weapon/hand_tele,
	/obj/item/clothing/suit/space/rig/captain,
	/obj/item/clothing/shoes/magboots/elite,
	/obj/item/weapon/planning_frame,
	/obj/item/weapon/storage/belt/utility/chief,
	/obj/item/weapon/switchtool/holo,
	/obj/item/weapon/circuitboard/telesci_computer,
	/obj/item/weapon/card/emag,
	/obj/item/weapon/am_containment,
)

var/list/potential_bonus_items = list(
	/obj/item/weapon/pinpointer,
	/obj/item/weapon/bikehorn/rubberducky,
	/obj/item/weapon/circuitboard/borgupload,
	/obj/item/weapon/stock_parts/subspace/amplifier,
	/obj/item/clothing/mask/gas/clown_hat,
)

/datum/faction/vox_shoal
	name = "Vox Shoal"
	desc = "In short supply of money, organs, experts, and rubber duckies."
	ID = VOXSHOAL
	required_pref = VOXRAIDER
	initial_role = VOXRAIDER
	late_role = VOXRAIDER
	roletype = /datum/role/vox_raider
	initroletype = /datum/role/vox_raider
	logo_state = "vox-logo"
	hud_icons = list("vox-logo")

	var/time_left = (60 MINUTES)/10
	var/completed = FALSE
	var/results = "The Shoal didn't return yet."
	var/list/dept_objective = list()
	var/list/bonus_items_of_the_day = list()

	var/complete_failure = FALSE // Set to TRUE when a non-raider uses the shuttle to return home.

	var/got_personnel = 0
	var/got_items = 0

	var/total_points = 0
	var/list/our_bounty_lockers = list()

/datum/faction/vox_shoal/New()
	..()
	load_dungeon(/datum/map_element/dungeon/vox_shuttle)
	vox_shuttle.initialize() //As the area isn't loaded until the above call, its docking ports aren't populated until we call this

/datum/faction/vox_shoal/forgeObjectives()
	var/list/dept_of_choice = pick(
		engineering_positions,
		medical_positions,
		science_positions,
		civilian_positions,
		cargo_positions,
		security_positions,
	)
	var/dept = "None"
	// I wish I could use a switch here, but byond won't let me.
	if (dept_of_choice == engineering_positions)
		dept = "Engineering"
	else if (dept_of_choice == medical_positions)
		dept = "Medbay"
	else if (dept_of_choice == science_positions)
		dept = "Science"
	else if (dept_of_choice == civilian_positions)
		dept = "Service"
	else if (dept_of_choice == cargo_positions)
		dept = "Cargo"
	else if (dept_of_choice == security_positions)
		dept = "Security"

	var/datum/objective/abduct/A = new(dept)
	AppendObjective(A)
	dept_objective = dept_of_choice.Copy()

	var/list/potential_bonus_items_temp = potential_bonus_items.Copy()

	for (var/i = 1 to 4)
		var/chosen_one = pick(potential_bonus_items_temp)
		potential_bonus_items_temp -= chosen_one
		bonus_items_of_the_day += chosen_one

	var/datum/objective/steal_priority/SP = new(bonus_items_of_the_day)
	AppendObjective(SP)

/datum/faction/vox_shoal/GetScoreboard()
	. = ..()
	. += "<br/> Time left: <b>[num2text((time_left /(2*60)))]:[add_zero(num2text(time_left/2 % 60), 2)]</b> minutes"
	if (time_left < 0)
		. += "<br/> <span class='danger'>The raid took too long.</span>"
	. += "<br/> The raiders took <b>[got_personnel]</b> people to the Shoal."
	. += "<br/> The raiders secured <b>[got_items]</b> priority items."
	. += "<br/> Total points: <b>[total_points]</b>. <br/>"
	. += results

/datum/faction/vox_shoal/AdminPanelEntry()
	. = ..()
	. += "<br/> Time left: <b>[num2text((time_left /(2*60)))]:[add_zero(num2text(time_left/2 % 60), 2)]</b>"

/datum/faction/vox_shoal/OnPostSetup()
	..()
	var/list/turf/vox_spawn = list()

	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "voxstart")
			vox_spawn += get_turf(A)
			qdel(A)
			A = null
			continue
		if (A.name == "vox_locker")
			var/obj/structure/closet/loot/L = new(get_turf(A))
			our_bounty_lockers += L
			qdel(A)
			A = null
			continue

	var/spawn_count = 1

	for(var/datum/role/vox_raider/V in members)
		if(spawn_count > vox_spawn.len)
			spawn_count = 1
		var/datum/mind/synd_mind = V.antag
		synd_mind.current.forceMove(vox_spawn[spawn_count])
		spawn_count++
		equip_raider(synd_mind.current, spawn_count)

/datum/faction/vox_shoal/proc/equip_raider(var/mob/living/carbon/human/vox, var/index)
	vox.age = rand(12,20)
	if(vox.overeatduration) //We need to do this here and now, otherwise a lot of gear will fail to spawn
		vox.overeatduration = 0 //Fat-B-Gone
		if(vox.nutrition > 400) //We are also overeating nutriment-wise
			vox.nutrition = 400 //Fix that
		vox.mutations.Remove(M_FAT)
		vox.update_mutantrace(0)
		vox.update_mutations(0)
		vox.update_inv_w_uniform(0)
		vox.update_inv_wear_suit()

	vox.my_appearance.s_tone = random_skin_tone("Vox")
	vox.dna.mutantrace = "vox"
	vox.set_species("Vox")
	vox.fully_replace_character_name(vox.real_name, vox.generate_name())
	vox.mind.name = vox.name
	//vox.languages = HUMAN // Removing language from chargen.
	vox.default_language = all_languages[LANGUAGE_VOX]
	vox.flavor_text = ""
	vox.species.default_language = LANGUAGE_VOX
	vox.remove_language(LANGUAGE_GALACTIC_COMMON)
	vox.my_appearance.h_style = "Short Vox Quills"
	vox.my_appearance.f_style = "Shaved"
	for(var/datum/organ/external/limb in vox.organs)
		limb.status &= ~(ORGAN_DESTROYED | ORGAN_ROBOT | ORGAN_PEG)
	var/datum/outfit/striketeam/voxraider/concrete_outfit = new
	concrete_outfit.equip(vox)
	vox.regenerate_icons()
	vox.store_memory("The priority items for the day are: [english_list(bonus_items_of_the_day)]")

	/*
	spawn()
		var/chosen_loadout = input(vox, "The raid is about to begin. What kind of operations would you like to specialize into ?") in list("Raider", "Engineer", "Saboteur", "Medic")
		concrete_outfit.chosen_spec = chosen_loadout
		concrete_outfit.equip_special_items(vox)
	*/

/datum/faction/vox_shoal/process()
	if (completed)
		return
	. = ..()
	time_left -= 2
	if (vox_shuttle.returned_home)
		completed =  TRUE
		var/area/end_area = locate(/area/shuttle/vox/station)
		// -- First, are we late ? -100 points for every minute over the clock.
		if (time_left < 0)
			for (var/datum/role/R in members)
				to_chat(R.antag.current, "<span class='warning'>The raid took too long. This will draw Nanotrasen attention on us.</span>")
			total_points -= RULE_OF_THREE(-60, 100, time_left)

		// -- Secondly, add points if everyone is alive and well, and send back our prisonners to the mainstation in a shelter.
		for (var/mob/living/H in end_area)
			if (isvoxraider(H))
				if (H.stat)
					to_chat(H, "<span class='notice'>The raid has been concluded, but you were critically injured. The shoal will remember you.</span>")
					total_points += 250
				else
					to_chat(H, "<span class='notice'>The raid has been concluded, and you returned safe. This will greatly helps us.</span>")
					total_points += 500
			else
				count_score(H)
				H.send_back_to_main_station(complete_failure)

		for (var/obj/structure/closet/loot/L in our_bounty_lockers)
			for (var/obj/O in L)
				count_score(O)

		// -- Thirdly, let's compare the score.
		var/vox_raider_data = SSpersistence_misc.read_data(/datum/persistence_task/vox_raiders)
		var/score_to_beat = text2num(vox_raider_data["best_score"])

		if (total_points > score_to_beat)
			for (var/datum/role/R in members)
				to_chat(R.antag.current, "<span class='notice'><b>You have beaten the /vg/station heist record.</b> Congratulations!</span>")
				results = "The vox raiders were <b>better</b> than the previous record of [score_to_beat], which was on [vox_raider_data["MM"]]/[vox_raider_data["DD"]]/[vox_raider_data["YY"]]."
		else
			results = "The vox raiders didn't beat the previous record of [score_to_beat]."

		for (var/datum/role/R in members)
			to_chat(R.antag.current, "<span class='notice'>The raid is over. You'll go back to the shoal in a few minutes...</span>")
			spawn (1 MINUTES)
				qdel(R.antag.current)

/datum/faction/vox_shoal/proc/count_score(var/atom/O)
	if (ishuman(O))
		count_human_score(O)
		return
	// Items
	if (is_type_in_list(O, high_score_items))
		total_points += 400
	else if (is_type_in_list(O, medium_score_items))
		total_points += 200
	else if (is_type_in_list(O, low_score_items))
		total_points += 50
	if (is_type_in_list(O, bonus_items_of_the_day))
		total_points += 500
		got_items++


/datum/faction/vox_shoal/proc/count_human_score(var/mob/living/carbon/human/H)
	if (!H.mind)
		if (H.old_assigned_role in command_positions)
			total_points += 300
		if (H.old_assigned_role in dept_objective)
			total_points += 200
			got_personnel++
		return

	if (H.mind.assigned_role in command_positions)
		total_points += 300
	if (H.mind.assigned_role in dept_objective)
		total_points += 200
		got_personnel++

/datum/faction/vox_shoal/proc/generate_string()
	var/list/our_stars = list()
	for (var/datum/role/lad in members)
		our_stars += "[lad.antag.key] as [lad.antag.name]"
	return english_list(our_stars)

// -- Mobs procs --

/mob/living/proc/send_back_to_main_station(var/complete_failure = FALSE)
	if (complete_failure) // Non-vox somehow used the vox shuttle.
		to_chat(src, "<span class='danger'>After hours of aimlessly wandering through space in hostile Vox territory, the shuttle quickly ran out of fuel. You and your companions decided to abandon the ship and throw escape shelters in the general direction of the station.</span>")
		var/obj/structure/inflatable/shelter/S = new(get_turf(src))
		forceMove(S)
		S.ThrowAtStation()
		return
	to_chat(src, "<span class='warning'>You can't really remember the details, but somehow, you managed to escape. Your situation is still far from ideal, however.</span>")
	delete_all_equipped_items()
	if (ishuman(src))
		var/obj/item/clothing/under/color/grey/G = new(src)
		equip_to_appropriate_slot(G)
		var/obj/item/clothing/shoes/black/B = new(src)
		equip_to_appropriate_slot(B)
		var/obj/item/device/radio/R = new(src)
		put_in_hands(R)
	var/obj/structure/inflatable/shelter/S = new(get_turf(src))
	forceMove(S)
	S.ThrowAtStation()

/obj/item/weapon/paper/vox_paper
	name = "Shoal objectives"

/obj/item/weapon/paper/vox_paper/initialize()
	var/vox_raider_data = SSpersistence_misc.read_data(/datum/persistence_task/vox_raiders)
	var/score_to_beat = vox_raider_data["best_score"]
	var/best_team = vox_raider_data["winning_team"]
	info = {"<h4>The shoal needs us to gather ressources. </h4>
	<br/>
	Our best agents of all time were able to gather an estimate of [score_to_beat] voxcoins in assets, on [vox_raider_data["MM"]]/[vox_raider_data["DD"]]/[vox_raider_data["YY"]]. <br/>
	Their names are as follows: [best_team]."}

/obj/item/weapon/coin/raider
	name = "raider coin"
	icon_state = "coin_gold"

/datum/map_element/dungeon/vox_shuttle
	file_path = "maps/misc/voxshuttle.dmm"
	unique = TRUE

/obj/item/weapon/storage/box/large/vox_equipment
	name = "Vox equipment box"
	desc = "A Vox Box for short."

/obj/item/weapon/storage/box/large/vox_equipment/raider/New()
	..()
	new /obj/item/clothing/suit/space/vox/carapace(src)
	new /obj/item/clothing/head/helmet/space/vox/carapace(src)
	new /obj/item/weapon/melee/telebaton(src)
	new /obj/item/clothing/glasses/thermal/monocle(src)
	new /obj/item/device/chameleon(src)
	var/obj/item/weapon/crossbow/W = new(src)
	W.cell = new /obj/item/weapon/cell/crap(W)
	W.cell.charge = 500
	var/obj/item/stack/rods/A = new(src)
	A.amount = 20

/obj/item/weapon/storage/box/large/vox_equipment/engineer/New()
	..()
	new /obj/item/clothing/suit/space/vox/pressure(src)
	new /obj/item/clothing/head/helmet/space/vox/pressure(src)
	new /obj/item/weapon/storage/belt/utility/full(src)
	new /obj/item/clothing/glasses/scanner/meson(src)
	new /obj/item/weapon/storage/box/emps(src)
	new /obj/item/device/multitool(src)
	var/obj/item/weapon/paper/vox_paper/VP = new(src)
	VP.initialize()

/obj/item/weapon/storage/box/large/vox_equipment/saboteur/New()
	..()
	new /obj/item/clothing/suit/space/vox/carapace(src)
	new /obj/item/clothing/head/helmet/space/vox/carapace(src)
	new /obj/item/weapon/storage/belt/utility/full(src)
	new /obj/item/clothing/glasses/thermal/monocle(src)
	new /obj/item/weapon/card/emag(src)
	new /obj/item/weapon/gun/dartgun/vox/raider(src)
	new /obj/item/device/multitool(src)

/obj/item/weapon/storage/box/large/vox_equipment/medic/New()
	..()
	new /obj/item/clothing/suit/space/vox/pressure(src)
	new /obj/item/clothing/head/helmet/space/vox/pressure(src)
	new /obj/item/weapon/storage/belt/utility/full(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/weapon/circular_saw(src)
	new /obj/item/weapon/gun/dartgun/vox/medical(src)

/obj/machinery/vending/raider
	name = "\improper Raider Surplus"
	icon_state = "voxseed"
	vend_reply = "Happy hunting!"
	unhackable = TRUE
	accepted_coins = list(/obj/item/weapon/coin/raider)
	premium = list(
		/obj/item/weapon/storage/box/large/vox_equipment/medic = 2,
		/obj/item/weapon/storage/box/large/vox_equipment/saboteur = 2,
		/obj/item/weapon/storage/box/large/vox_equipment/engineer = 2,
		/obj/item/weapon/storage/box/large/vox_equipment/raider = 2
	)
