var/list/wizard_apprentice_setups_nanoui = list()
var/list/wizard_apprentice_setups_by_name = list()

/datum/wizard_apprentice_setup
	var/name
	var/list/spells

/datum/wizard_apprentice_setup/proc/generate_description()
	var/list/output = list()
	for(var/entry in spells)
		var/spell/spell_type = entry
		output += initial(spell_type.name)
	return jointext(output, ", ")

/datum/wizard_apprentice_setup/proc/give_spells(mob/target)
	for(var/spell_path in spells)
		target.add_spell(spell_path)

/datum/wizard_apprentice_setup/destruction
	name = "Destruction"
	spells = list(
		/spell/targeted/projectile/magic_missile,
		/spell/targeted/projectile/dumbfire/fireball,
	)

/datum/wizard_apprentice_setup/bluespace_manipulation
	name = "Bluespace manipulation"
	spells = list(
		/spell/targeted/ethereal_jaunt,
		/spell/area_teleport,
	)

/datum/wizard_apprentice_setup/clown_magic
	name = "Clown magic"
	spells = list(
		/spell/targeted/equip_item/clowncurse,
		/spell/targeted/shoesnatch,
	)

/datum/wizard_apprentice_setup/muscle_magic
	name = "Muscle magic"
	spells = list(
		/spell/targeted/genetic/mutate,
		/spell/targeted/genetic/blind,
	)

/datum/wizard_apprentice_setup/technology
	name = "Technology"
	spells = list(
		/spell/lightning,
		/spell/aoe_turf/disable_tech,
	)

/obj/item/wizard_apprentice_contract
	name = "contract of apprenticeship"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "contract0"
	autoignition_temperature = AUTOIGNITION_PAPER
	fire_fuel = 1
	throwforce = 0
	w_class = W_CLASS_TINY
	w_type = RECYK_WOOD
	throw_range = 1
	throw_speed = 1
	var/consumed = FALSE
	var/polling_ghosts = FALSE
	var/datum/mind/owner // The mind of the user, to be used by the recruiter
	var/datum/recruiter/recruiter
	var/datum/wizard_apprentice_setup/chosen_setup
	var/forced_apprentice_name
	var/forced_apprentice_gender

/obj/item/wizard_apprentice_contract/update_icon()
	icon_state = "contract[consumed]"

/obj/item/wizard_apprentice_contract/Destroy()
	owner = null
	qdel(recruiter)
	recruiter = null
	..()

/obj/item/wizard_apprentice_contract/attack_self(mob/user)
	if(consumed)
		to_chat(user, "<span class='warning'>\The [src] has already been consumed.</span>")
		return
	ui_interact(user)

/obj/item/wizard_apprentice_contract/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = NANOUI_FOCUS)
	var/list/data = list()
	data["setups"] = wizard_apprentice_setups_nanoui
	data["summoning"] = chosen_setup?.name
	data["forced_name"] = forced_apprentice_name
	data["forced_gender"] = forced_apprentice_gender
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "apprentice_contract.tmpl", name, 530, 280)
		ui.set_initial_data(data)
		ui.open()

/obj/item/wizard_apprentice_contract/proc/force_gender(gender)
	if(gender != MALE && gender != FEMALE)
		CRASH("Unknown value: [gender]")
	forced_apprentice_gender = gender

/obj/item/wizard_apprentice_contract/proc/force_name(mob/user = usr)
	var/new_name = stripped_input(user, "Choose the name of your apprentice. Leave empty or cancel to let them pick.", "Apprentice name", forced_apprentice_name, MAX_NAME_LEN)
	if(user.incapacitated() || !user.is_holding_item(src) || gcDestroyed || polling_ghosts)
		return
	forced_apprentice_name = new_name

/obj/item/wizard_apprentice_contract/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(consumed)
		nanomanager.close_uis(src)
		return FALSE
	if(polling_ghosts)
		return TRUE
	if(href_list["unset_gender"])
		forced_apprentice_gender = null
		return TRUE
	var/set_gender = href_list["set_gender"]
	if(set_gender)
		force_gender(set_gender)
		return TRUE
	if(href_list["set_name"])
		force_name(usr)
		return TRUE
	var/setup_name = href_list["summon"]
	if(!setup_name)
		return FALSE
	var/setup_datum = wizard_apprentice_setups_by_name[setup_name]
	ASSERT(setup_datum)
	chosen_setup = setup_datum
	activate(usr)
	return TRUE

/obj/item/wizard_apprentice_contract/proc/activate(mob/user)
	if(polling_ghosts)
		return
	owner = user.mind
	polling_ghosts = TRUE
	set_light(1, 2, LIGHT_COLOR_ORANGE)
	visible_message("\The [src] starts glowing.")
	if(!recruiter)
		recruiter = new(src)
		recruiter.display_name = name
		recruiter.jobban_roles = list("Syndicate")
		recruiter.recruitment_timeout = 30 SECONDS
	// Role set to Yes or Always
	recruiter.player_volunteering = new /callback(src, .proc/recruiter_recruiting)
	// Role set to No or Never
	recruiter.player_not_volunteering = new /callback(src, .proc/recruiter_not_recruiting)

	recruiter.recruited = new /callback(src, .proc/recruiter_recruited)

	recruiter.request_player()

/obj/item/wizard_apprentice_contract/proc/recruiter_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class='recruit'>\A [src] is looking for candidates. You have been added to the list of potential ghosts. ([controls])</span>")

/obj/item/wizard_apprentice_contract/proc/recruiter_not_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class='recruit'>\A [src] is looking for candidates. ([controls])</span>")

/obj/item/wizard_apprentice_contract/proc/recruiter_recruited(mob/dead/observer/player)
	if(!player)
		chosen_setup = null
		polling_ghosts = FALSE
		kill_light()
		visible_message("<span class='notice'>\The [src] stops glowing.</span>")
		nanomanager.update_uis(src)
		return
	var/turf/this_turf = get_turf(src)
	var/mob/living/carbon/human/apprentice = new(this_turf)
	apprentice.setGender(forced_apprentice_gender || pick(MALE,FEMALE))
	apprentice.randomise_appearance_for(apprentice.gender)
	apprentice.ckey = player.ckey

	chosen_setup.give_spells(apprentice)

	var/datum/faction/wizard_contract/contract_faction = find_active_faction_by_typeandmember(/datum/faction/wizard_contract, null, owner)
	if(!contract_faction)
		contract_faction = ticker.mode.CreateFaction(/datum/faction/wizard_contract, override = TRUE)
		contract_faction.HandleNewMind(owner)
		contract_faction.forgeObjectives()

	var/datum/role/wizard_apprentice/apprentice_role = contract_faction.HandleRecruitedMind(apprentice.mind, override = TRUE)
	apprentice_role.Greet(GREET_DEFAULT)
	apprentice_role.AnnounceObjectives()
	if(forced_apprentice_name)
		apprentice.fully_replace_character_name(apprentice.real_name, forced_apprentice_name)
	else
		name_wizard(apprentice, "Wizard's Apprentice")
	update_faction_icons()
	visible_message("<span class='notice'>\The [src] folds back on itself as the apprentice appears!</span>")
	kill_light()
	consumed = TRUE
	nanomanager.close_uis(src)
	update_icon()
