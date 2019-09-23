/*
 * All meteor random events are in here
 * Right now we have small and medium. Apocalyptic huge would be button mashing, at least for now
 */

//Meteor storms are much heavier
/datum/event/meteor_wave
	startWhen		= 0 //Note : Meteor waves have a delay before striking now
	endWhen			= 30

/datum/event/meteor_wave/can_start(var/list/active_with_role)
	if(active_with_role["Engineer"] > 1)
		return 15
	return 0


/datum/event/meteor_wave/setup()
	endWhen = rand(45, 90) //More drawn out than the shower, but not too powerful. Supposed to be a devastating event

/datum/event/meteor_wave/announce()
	command_alert(/datum/command_alert/meteor_wave)

//Two to three waves. So 40 to 120
/datum/event/meteor_wave/tick()
	meteor_wave(rand(20, 40), max_size = 2, offset_origin = 150, offset_dest = 230) //Large waves, panic is mandatory

/datum/event/meteor_wave/end()
	command_alert(/datum/command_alert/meteor_wave_end)

//One to two vawes
/datum/event/meteor_shower
	startWhen		= 0
	endWhen 		= 30

/datum/event/meteor_shower/can_start(var/list/active_with_role)
	if(active_with_role["Engineer"] > 1)
		return 40
	return 0

/datum/event/meteor_shower/setup()
	endWhen	= rand(45, 60) //From thirty seconds to one minute

/datum/event/meteor_shower/announce()
	command_alert(/datum/command_alert/meteor_storm)

//Meteor showers are lighter and more common
//Sometimes a single wave, most likely two, so anywhere from 10 to 30 small meteors
/datum/event/meteor_shower/tick()
	meteor_wave(rand(10, 15), max_size = 1, offset_origin = 150, offset_dest = 230) //Much more clement

/datum/event/meteor_shower/end()
	command_alert(/datum/command_alert/meteor_wave_end)

//Meteor wave that doesn't trigger an announcement. Perfect for adminbus involving extended meteor bombardments without spamming the crew with Meteor alerts.
/datum/event/meteor_shower/meteor_quiet
	startWhen       =0
	endWhen         =30

/datum/event/meteor_shower/meteor_quiet/announce()

/datum/event/meteor_shower/meteor_quiet/tick()
	meteor_wave(rand(7, 10), max_size = 2, offset_origin = 150, offset_dest = 230) //Good balance of sizes and abundance between shower and storm

/datum/event/meteor_shower/meteor_quiet/end()

var/global/list/thing_storm_types = list(
	"meaty gore storm" = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/human,
		/obj/item/organ/internal/eyes,
		/obj/item/organ/internal/kidneys,
		/obj/item/organ/internal/heart,
		/obj/item/organ/internal/liver,
		/obj/effect/decal/cleanable/blood/gibs,
		/obj/item/projectile/meteor/gib,
		/obj/item/organ/external/r_arm,
		/obj/item/organ/external/l_arm,
		/obj/item/organ/external/r_leg,
		/obj/item/organ/external/l_leg,
		/obj/item/organ/external/r_hand,
		/obj/item/organ/external/l_hand,
		/obj/item/organ/external/r_foot,
		/obj/item/organ/external/l_foot,
	),
	"sausage party" = list(
		/obj/item/weapon/reagent_containers/food/snacks/sausage,
		/obj/item/weapon/reagent_containers/food/snacks/faggot,
	),
	"blob shower" = list(
		/obj/item/projectile/meteor/blob,
		/obj/item/projectile/meteor/blob,
		/obj/item/projectile/meteor/blob,
		/obj/item/projectile/meteor/blob/node,
	),
	"blob storm" = list(
		/obj/item/projectile/meteor/blob,
		/obj/item/projectile/meteor/blob,
		/obj/item/projectile/meteor/blob,
		/obj/item/projectile/meteor/blob,
		/obj/item/projectile/meteor/blob,
		/obj/item/projectile/meteor/blob,
		/obj/item/projectile/meteor/blob,
		/obj/item/projectile/meteor/blob,
		/obj/item/projectile/meteor/blob,
		/obj/item/projectile/meteor/blob,
		/obj/item/projectile/meteor/blob,
		/obj/item/projectile/meteor/blob,
		/obj/item/projectile/meteor/blob,
		/obj/item/projectile/meteor/blob,
		/obj/item/projectile/meteor/blob,
		/obj/item/projectile/meteor/blob,
		/obj/item/projectile/meteor/blob/node,
		/obj/item/projectile/meteor/blob/node,
		/obj/item/projectile/meteor/blob/node,
		/obj/item/projectile/meteor/blob/node,
		/obj/item/projectile/meteor/blob/node,
		/obj/item/projectile/meteor/blob/node,
		/obj/item/projectile/meteor/blob/node,
		/obj/item/projectile/meteor/blob/node,
		/obj/item/projectile/meteor/blob/node,
		/obj/item/projectile/meteor/blob/node,
	),
	"fireworks" = list(
		/obj/item/projectile/meteor/firework,
		/obj/item/projectile/meteor/firework,
		/obj/item/projectile/meteor/firework,
		/obj/item/projectile/meteor/firework,
		/obj/item/projectile/meteor/firework,
		/obj/item/projectile/meteor/firework,
		/obj/item/projectile/meteor/firework,
		/obj/item/projectile/meteor/firework,
		/obj/item/projectile/meteor/firework,
		/obj/item/projectile/meteor/firework,
		/obj/item/projectile/meteor/firework,
		/obj/item/projectile/meteor/firework,
		/obj/item/projectile/meteor/firework,
		/obj/item/projectile/meteor/firework,
		/obj/item/projectile/meteor/firework,
		/obj/item/projectile/meteor/firework,
		/obj/item/projectile/meteor/firework,
		/obj/item/projectile/meteor/firework,
		/obj/item/projectile/meteor/firework,
	)
)

/datum/event/thing_storm
	startWhen		= 10
	endWhen 		= 30

	var/storm_name = null

/datum/event/thing_storm/setup()
	endWhen	= rand(30, 60) + 10 //From 30 seconds to one minute
	var/list/possible_names=list()
	for(var/storm_id in thing_storm_types)
		possible_names += storm_id
	storm_name=pick(possible_names)

/datum/event/thing_storm/announce()
	command_alert(/datum/command_alert/meteor_storm)

//Meteor showers are lighter and more common
//Since this isn't rocks of pure pain and explosion, we have more, anywhere from 10 to 40 items
/datum/event/thing_storm/tick()
	meteor_wave(rand(10, 20), types = thing_storm_types[storm_name], offset_origin = 150, offset_dest = 230) //Much more clement

/datum/event/thing_storm/end()
	command_alert("The station has cleared the [storm_name].", "Meteor Alert")

/datum/event/thing_storm/meaty_gore

/datum/event/thing_storm/meaty_gore/can_start()
	return 25

/datum/event/thing_storm/meaty_gore/setup()
	endWhen = rand(30, 60) + 10
	storm_name="meaty gore storm"

/datum/event/thing_storm/meaty_gore/tick()
	meteor_wave(rand(45, 60), types = thing_storm_types[storm_name], offset_origin = 150, offset_dest = 230)

/datum/event/thing_storm/meaty_gore/announce()
	command_alert("The station is about to pass through an unknown organic debris field. No hull breaches are likely.", "Organic Debris Field")

/datum/event/thing_storm/meaty_gore/end()
	command_alert("The station has cleared the organic debris field.", "Organic Debris Field")

/datum/event/thing_storm/blob_shower

/datum/event/thing_storm/blob_shower/can_start(var/list/active_with_role)
	if(active_with_role["Engineer"] > 1)
		return 15
	return 0

/datum/event/thing_storm/blob_shower/setup()
	endWhen = rand(45, 60) + 10
	storm_name="blob shower"

/datum/event/thing_storm/blob_shower/tick()
	meteor_wave(rand(12, 24), types = thing_storm_types[storm_name], offset_origin = 150, offset_dest = 230)

/datum/event/thing_storm/blob_shower/announce()
	command_alert(/datum/command_alert/blob_storm)

/datum/event/thing_storm/blob_shower/end()
	command_alert(/datum/command_alert/blob_storm/end)

/datum/event/thing_storm/blob_storm
	var/cores_spawned = 0
	var/list/candidates = list()
	var/started = FALSE

/datum/event/thing_storm/blob_storm/setup()
	endWhen = rand(60, 90) + 10
	storm_name="blob storm"

/datum/event/thing_storm/blob_storm/tick()
	var/chosen_dir = meteor_wave(rand(20, 40), types = thing_storm_types[storm_name], offset_origin = 150, offset_dest = 230)
	if(!cores_spawned)
		var/living = 0
		for(var/mob/living/M in player_list)
			if(M.stat == CONSCIOUS)
				living++
		cores_spawned = round(living/BLOB_CORE_PROPORTION) //Cores spawned depends on living players


	if (!(candidates.len) && !started)
		candidates = get_candidates(BLOBOVERMIND)

	for(var/i = 0 to cores_spawned)
		if (!candidates.len)
			return
		var/obj/item/projectile/meteor/blob/core/C = spawn_meteor(chosen_dir, /obj/item/projectile/meteor/blob/core)
		var/client/candidate = pick(candidates)
		candidates =- candidate
		C.AssignMob(candidate.mob)

/datum/event/thing_storm/blob_storm/announce()
	command_alert(/datum/command_alert/blob_storm/overminds)

/datum/event/thing_storm/blob_storm/end()
	command_alert(/datum/command_alert/blob_storm/overminds/end)

/datum/event/thing_storm/fireworks/setup()
	endWhen = rand(60, 90) + 10
	storm_name="fireworks"

/datum/event/thing_storm/fireworks/tick()
	meteor_wave(rand(45, 60), types = thing_storm_types[storm_name], offset_origin = 150, offset_dest = 230)

/datum/event/thing_storm/fireworks/announce()
	command_alert("The station is about to be bombarded by light-based distraction projectiles. Source unknown. No hull breaches are likely.", "Firework Fiasco")
