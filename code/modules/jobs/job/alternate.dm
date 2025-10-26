var/total_alt_positions

/datum/job/alternate/
	title = "Alternate"
	faction = "Station"
	total_positions = 3
	spawn_positions = 0
	supervisors = "the Head of Personnel"
	wage_payout = 10
	selection_color = "#dddddd"
	access = list(access_maint_tunnels)
	minimal_access = list(access_maint_tunnels)

	no_random_roll = 1
	outfit_datum = /datum/outfit/assistant

/datum/job/alternate/chiropractor
	title = "Chiropractor"
	outfit_datum = /datum/outfit/chiropractor

/datum/job/alternate/dogwalker
	title = "Dog Walker"
	outfit_datum = /datum/outfit/dogwalker

/datum/job/alternate/psychologist
	title = "Psychologist"
	outfit_datum = /datum/outfit/psychologist

/datum/job/alternate/scubadiver
	title = "Scuba Diver"
	outfit_datum = /datum/outfit/scubadiver

/datum/job/alternate/plumber
	title = "Plumber"
	outfit_datum = /datum/outfit/plumber

/datum/job/alternate/dentist
	title = "Dentist"
	outfit_datum = /datum/outfit/dentist

/datum/job/alternate/managementconsultant
	title = "Management Consultant"
	outfit_datum = /datum/outfit/managementconsultant

/datum/job/alternate/weddingplanner
	title = "Wedding Planner"
	outfit_datum = /datum/outfit/weddingplanner

/datum/job/alternate/lifeguard
	title = "Lifeguard"
	outfit_datum = /datum/outfit/lifeguard

/datum/job/alternate/insurancesalesman
	title = "Insurance Salesman"
	outfit_datum = /datum/outfit/insurancesalesman

/datum/job/alternate/cableguy
	title = "Cable Guy"
	outfit_datum = /datum/outfit/cableguy

/datum/job/alternate/woodidentifier
	title = "Wood Identifier"
	outfit_datum = /datum/outfit/woodidentifier

/datum/job/alternate/sommelier
	title = "Sommelier"
	outfit_datum = /datum/outfit/sommelier

/datum/job/alternate/interiordesigner
	title = "Interior Designer"
	outfit_datum = /datum/outfit/interiordesigner

/datum/job/alternate/bathroomattendant
	title = "Bathroom Attendant"
	outfit_datum = /datum/outfit/bathroomattendant

/datum/job/alternate/wftr
	title = "Welding Fuel Tank Refiller"
	outfit_datum = /datum/outfit/wftr

/datum/job/alternate/historicalreenactor
	title = "Historical Reenactor"
	outfit_datum = /datum/outfit/historicalreenactor
