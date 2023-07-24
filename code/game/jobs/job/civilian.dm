//Food
/datum/job/bartender
	title = "Bartender"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	wage_payout = 20
	selection_color = "#dddddd"
	access = list(access_hydroponics, access_bar, access_kitchen, access_morgue, access_weapons)
	minimal_access = list(access_bar,access_weapons)
	outfit_datum = /datum/outfit/bartender
	additional_information = "You can juggle most bottles and empty glasses by picking them up while on GRAB intent, so long as you remain unusually sober."

/datum/job/bartender/post_init(var/mob/living/carbon/human/H)
	genemutcheck(H, SOBERBLOCK)

/datum/job/chef
	title = "Chef"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	wage_payout = 20
	selection_color = "#dddddd"
	access = list(access_hydroponics, access_bar, access_kitchen, access_morgue)
	minimal_access = list(access_kitchen, access_morgue, access_bar)
	alt_titles = list("Cook")
	outfit_datum = /datum/outfit/chef

/datum/job/hydro
	title = "Botanist"
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the head of personnel"
	wage_payout = 20
	selection_color = "#dddddd"
	access = list(access_hydroponics, access_bar, access_kitchen, access_morgue) // Removed tox and chem access because STOP PISSING OFF THE CHEMIST GUYS // //Removed medical access because WHAT THE FUCK YOU AREN'T A DOCTOR YOU GROW WHEAT //Given Morgue access because they have a viable means of cloning.
	minimal_access = list(access_hydroponics, access_morgue) // Removed tox and chem access because STOP PISSING OFF THE CHEMIST GUYS // //Removed medical access because WHAT THE FUCK YOU AREN'T A DOCTOR YOU GROW WHEAT //Given Morgue access because they have a viable means of cloning.
	alt_titles = list("Hydroponicist", "Beekeeper", "Gardener")
	outfit_datum = /datum/outfit/hydro
	species_blacklist = list()

//Cargo
/datum/job/qm
	title = "Quartermaster"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	wage_payout = 65
	selection_color = "#E9D9BC"
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station)
	minimal_access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station)
	outfit_datum = /datum/outfit/qm

/datum/job/cargo_tech
	title = "Cargo Technician"
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the quartermaster and the head of personnel"
	wage_payout = 20
	selection_color = "#F9EAD5"
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_mint, access_mining, access_mining_station)
	minimal_access = list(access_maint_tunnels, access_cargo, access_cargo_bot, access_mailsorting)
	alt_titles = list("Mailman")
	outfit_datum = /datum/outfit/cargo_tech

/datum/job/mining
	title = "Shaft Miner"
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the quartermaster and the head of personnel"
	wage_payout = 30
	selection_color = "#F9EAD5"
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_mint, access_mining, access_mining_station)
	minimal_access = list(access_mining, access_mint, access_mining_station, access_mailsorting)
	outfit_datum = /datum/outfit/mining

/datum/job/clown
	title = "Clown"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	wage_payout = 15
	selection_color = "#dddddd"
	access = list(access_clown, access_theatre, access_maint_tunnels)
	minimal_access = list(access_clown, access_theatre)
	alt_titles = list("Jester")
	outfit_datum = /datum/outfit/clown

/datum/job/clown/reject_new_slots()
	if(Holiday == APRIL_FOOLS_DAY)
		return FALSE
	if(!xtra_positions)
		return FALSE
	if(security_level == SEC_LEVEL_RAINBOW)
		return FALSE
	else
		return "Rainbow Alert"

/datum/job/clown/get_total_positions()
	if(Holiday == APRIL_FOOLS_DAY)
		spawn_positions = -1
		return 99
	else
		return ..()

/datum/job/mime
	title = "Mime"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	wage_payout = 15
	selection_color = "#dddddd"
	access = list(access_mime, access_theatre, access_maint_tunnels)
	minimal_access = list(access_mime, access_theatre)
	outfit_datum = /datum/outfit/mime

/datum/job/mime/reject_new_slots()
	if(!xtra_positions)
		return FALSE
	if(security_level == SEC_LEVEL_RAINBOW)
		return FALSE
	else
		return "Rainbow Alert"

//Mime's break vow spell, couldn't think of anywhere else to put this

/spell/targeted/oathbreak
	name = "Break Oath of Silence"
	desc = "Break your oath of silence."
	school = "mime"
	panel = "Mime"
	charge_max = 10
	spell_flags = INCLUDEUSER
	range = 0
	max_targets = 1

	hud_state = "mime_oath"
	override_base = "const"

/spell/targeted/oathbreak/cast(list/targets)
	for(var/mob/living/carbon/human/M in targets)
		var/response = alert(M, "Are you -sure- you want to break your oath of silence?\n(This removes your ability to create invisible walls and cannot be undone!)","Are you sure you want to break your oath?","Yes","No")
		if(response != "Yes")
			return
		M.mind.miming=0
		for(var/spell/aoe_turf/conjure/forcewall/mime/spell in M.spell_list)
			M.remove_spell(spell)
		for(var/spell/targeted/oathbreak/spell in M.spell_list)
			M.remove_spell(spell)
		message_admins("[M.name] ([M.ckey]) has broken their oath of silence. (<A HREF='?_src_=holder;adminplayerobservejump=\ref[M]'>JMP</a>)")
		//Curse the mime with bad luck.
		var/datum/blesscurse/mimevowbreak/mimecurse = new /datum/blesscurse/mimevowbreak
		M.add_blesscurse(mimecurse)
		to_chat(M, "<span class = 'notice'>An unsettling feeling surrounds you...</span>")
		return

/datum/job/janitor
	title = "Janitor"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	wage_payout = 20
	selection_color = "#dddddd"
	access = list(access_janitor, access_maint_tunnels)
	minimal_access = list(access_janitor, access_maint_tunnels)
	outfit_datum = /datum/outfit/janitor
	species_blacklist = list()//Mop it up, shroomie.

/datum/job/janitor/get_wage()
	if(Holiday == APRIL_FOOLS_DAY)
		return 0 //They do it for free
	return ..()

//More or less assistants
/datum/job/librarian
	title = "Librarian"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	wage_payout = 25
	selection_color = "#dddddd"
	access = list(access_library, access_maint_tunnels)
	minimal_access = list(access_library)
	alt_titles = list("Journalist", "Game Master", "Curator")
	outfit_datum = /datum/outfit/librarian

/datum/job/iaa
	title = "Internal Affairs Agent"
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "Nanotrasen Law, CentComm Officals, and the station's captain."
	wage_payout = 55
	selection_color = "#dddddd"
	access = list(access_lawyer, access_court, access_heads, access_RC_announce, access_sec_doors, access_mailsorting, access_medical, access_bar, access_kitchen, access_hydroponics)
	minimal_access = list(access_lawyer, access_court, access_heads, access_RC_announce, access_sec_doors, access_mailsorting,  access_bar, access_kitchen)
	alt_titles = list("Lawyer", "Bridge Officer")
	outfit_datum = /datum/outfit/iaa

/datum/job/chaplain
	title = "Chaplain"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "The God(s), the Head of Personnel too"
	wage_payout = 35
	selection_color = "#dddddd"
	access = list(access_morgue, access_chapel_office, access_crematorium, access_maint_tunnels)
	minimal_access = list(access_morgue, access_chapel_office, access_crematorium)
	outfit_datum = /datum/outfit/chaplain
	var/datum/religion/chap_religion