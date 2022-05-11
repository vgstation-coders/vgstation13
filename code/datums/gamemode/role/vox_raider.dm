/datum/role/vox_raider
	name = VOXRAIDER
	id = VOXRAIDER
	special_role = VOXRAIDER
	required_pref = VOXRAIDER
	disallow_job = TRUE
	logo_state = "vox-logo"
	default_admin_voice = "Vox Shoal"
	admin_voice_style = "vox"
	var/tradepost_shoal = FALSE

/datum/role/vox_raider/OnPostSetup()
	.=..()
	if(!.)
		return
	if(!tradepost_shoal)
		antag.current.forceMove(pick(voxstart))
		equip_raider(antag.current)
		equip_vox_raider(antag.current)

/datum/role/vox_raider/chief_vox
	logo_state = "vox-logo"

/datum/role/vox_raider/StatPanel()
	var/datum/faction/vox_shoal/vox = faction
	if (!istype(vox))
		return
	var/minutes = round(vox.time_left / (2*60), 1)
	var/seconds = add_zero("[vox.time_left / 2 % 60]", 2)
	return "Raid time left: [minutes]:[seconds] minutes."

/obj/item/vox_charter
	name = "vox pidgin pamphlet"
	desc = "A mysterious parchment written in vox pidgin."
	w_class = W_CLASS_TINY
	mech_flags = MECH_SCAN_FAIL
	icon = 'icons/obj/wizard.dmi'
	icon_state = "contract0"
	var/uses = 1

/obj/item/vox_charter/examine(mob/user, size, show_name)
	..()
	var/speaksvox = FALSE
	for(var/datum/language/L in user.languages)
		if(istype(L,/datum/language/vox))
			speaksvox = TRUE
			break
	to_chat(user, "<span class='vox'>[speaksvox ? "It is specifically call for cousins forming a shoal creed, to raid wares for credit and fortune." : "You can't make out the contents of the text, but from its general structure it seems alarmist and instructional in nature."]</span>")

/obj/item/vox_charter/attack_self(mob/user as mob)
	var/speaksvox = FALSE
	for(var/datum/language/L in user.languages)
		if(istype(L,/datum/language/vox))
			speaksvox = TRUE
			break
	if(!speaksvox)
		to_chat(user, "<span class='vox'>You try to make out the words on the parchment and stumble with the awkward, caw-like vocalisations.</span>")
	else if(!isvox(user))
		to_chat(user, "<span class='vox'>You seem to actually understand this call for a raid, but the vox do not accept non-vox into their ranks.</span>")
	else if(isantagbanned(user) || jobban_isbanned(user, VOXRAIDER))
		to_chat(user, "<span class='vox'>You seem eager to sign your name, but remember that the vox have specifically excluded you from raiding parties in the past.</span>")
	else if(!isvoxraider(user))
		to_chat(user, "<span class='vox'>You sign a name on the line at the end, it seems cousins accept new friend into plunder of many goods and wares. Bring coin, bring captive, all you can find! For glory of voxkind.</span>")
		var/datum/faction/vox_shoal/shoal = find_active_faction_by_type(/datum/faction/vox_shoal)
		if (!shoal)
			shoal = ticker.mode.CreateFaction(/datum/faction/vox_shoal, null, 1)
			shoal.OnPostSetup()
		shoal.tradepost_shoal = TRUE
		var/datum/role/vox_raider/newRaider = new /datum/role/vox_raider()
		newRaider.tradepost_shoal = TRUE
		newRaider.AssignToRole(user.mind,1)
		shoal.HandleRecruitedRole(newRaider)
		newRaider.OnPostSetup()
		newRaider.Greet(GREET_DEFAULT)
		uses--
	else
		to_chat(user, "<span class='vox'>You seem to already have pact active with raiding. Maybe ask again some other time?</span>")

	if(!uses)
		qdel(src)

/obj/item/vox_charter/acidable()
	return 0
