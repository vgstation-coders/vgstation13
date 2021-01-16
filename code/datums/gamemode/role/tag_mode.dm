// -- Civvie landmarks.
var/list/valid_landmark_lists = list("Mime", "Clown", "Bartender", "Chef", "Botanist", "Assistant", "Librarian", "Chaplain")
var/list/turf/tag_mode_spawns = list()
var/list/tag_mode_non_used_spawns = list()

/proc/init_tag_mode_spawns()
	if (tag_mode_spawns.len == 0)
		CRASH("tag mode spawn list not initialised")
	for (var/i = 1 to tag_mode_spawns.len)
		tag_mode_non_used_spawns.Add(i)

// -- Clown ling

/datum/role/changeling/changeling_clown
	name = "Changeling Clown"
	disallow_job = TRUE
	id = CLOWN_LING

/datum/role/changeling/changeling_clown/OnPostSetup(var/laterole = FALSE)
	// Spawn them
	if (!laterole)

		var/index = pick(tag_mode_non_used_spawns)
		antag.current.forceMove(tag_mode_spawns[index])
		tag_mode_non_used_spawns -= index

		// Give them the outfit
		var/datum/outfit/mime/clown_ling/concrete_outfit = new
		concrete_outfit.items_to_collect[/obj/item/weapon/card/id/captains_spare] = SURVIVAL_BOX // Everyone gets a spare in tagmode.
		concrete_outfit.equip(antag.current)

	// Give them the changeling powers
	. = ..()
	// Objective
	ForgeObjectives()

	// Make their mask special and liked to them
	var/list/gas_mask = recursive_type_check(antag.current, /obj/item/clothing/mask/gas/clown_hat/ling_mask) // (a bit ugly but I don't see how else to do it)
	for (var/obj/item/clothing/mask/gas/clown_hat/ling_mask/LM in gas_mask)
		LM.our_ling = src

/datum/role/changeling/changeling_clown/ForgeObjectives()
	AppendObjective(/datum/objective/freeform/changeling_clown)

/datum/role/changeling/changeling_clown/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)

	switch (greeting)
		if (GREET_ROUNDSTART)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Changeling Clown.</span>")
			to_chat(antag.current, "<span class='danger'>You are inflitrated among the Mimes of the station. Your objective is to take them out. Be careful, as you are alone and with no backup.</span>")
			to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")

		if (GREET_LATEJOIN)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You have become Changeling Clown.</span>")
			to_chat(antag.current, "<span class='danger'>By equipping the mask of the clown, you have lost your Mime-minity and you must now continue their work. Wipe out the remaning mimes from the station.</span>")
			to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")

	AnnounceObjectives()
	antag.current << sound('sound/effects/ling_intro.ogg')

// -- Clown cursed mask item

/obj/item/clothing/mask/gas/clown_hat/ling_mask
	var/datum/role/changeling/changeling_clown/our_ling

/obj/item/clothing/mask/gas/clown_hat/ling_mask/equipped(var/mob/user, var/slot, hand_index = 0)
	. = ..()
	if (slot == slot_head)
		if (!our_ling.antag.current.stat && istagmime(user)) // Our ling is dead...
			var/datum/role/tag_mode_mime = user.mind.GetRole(TAG_MIME)
			tag_mode_mime.Drop()

			// Long live the new ling
			var/datum/role/changeling/changeling_clown/CC = new
			CC.AssignToRole(user.mind, 1)
			CC.OnPostSetup(FALSE)
			CC.Greet(GREET_LATEJOIN)

// -- Mimes

var/spawned_mimes_tag_mode = 1

/datum/role/tag_mode_mime
	name = "Mime"
	disallow_job = TRUE
	id = TAG_MIME

/datum/role/tag_mode_mime/OnPostSetup(var/laterole = FALSE)
	// Spawn them
	if (tag_mode_non_used_spawns.len == 0)
		init_tag_mode_spawns()

	var/index = pick(tag_mode_non_used_spawns)
	antag.current.forceMove(tag_mode_spawns[index])
	tag_mode_non_used_spawns -= index

	antag.current.forceMove()

	// Give them the outfit
	var/datum/outfit/mime/concrete_outfit = new
	concrete_outfit.items_to_collect[/obj/item/weapon/card/id/captains_spare] = SURVIVAL_BOX // Everyone gets a spare in tagmode.
	concrete_outfit.equip(antag.current)

	// Objective
	ForgeObjectives()

/datum/role/tag_mode_mime/ForgeObjectives()
	AppendObjective(/datum/objective/survive/tag_mode_mime)

/datum/role/ctag_mode_mime/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	switch (greeting)
		if (GREET_ROUNDSTART)
			to_chat(antag.current, "<span class='notice'><big>You are a Mime.</big></span>")
			to_chat(antag.current, "<span class='notice'>You are an ordinary mime. Your objective is to find the clown infiltred among the crew and steal his mask to gain his power - or to simply survive.</span>")
