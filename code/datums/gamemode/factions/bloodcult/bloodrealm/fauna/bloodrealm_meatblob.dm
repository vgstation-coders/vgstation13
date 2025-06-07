
/*

/datum/meat_blob
/obj/meat_blob
/mob/living/simple_animal/meat_blob_chunk
/obj/item/weapon/reagent_containers/food/snacks/meat/animal/meatblob

*/

#define MEATBLOB_IDLE	0//blob expands as much as it can and just stays immobile
#define MEATBLOB_ROAM	1//blob tries to move towards a chosen target and goes idle once it reaches it
#define MEATBLOB_FLEE	2//blob tries to move away from harm
#define MEATBLOB_DEAD	3//blob datum is now undergoing deletion

//This creature moves around by spreading around similarly to how a space blob would, but it has a maximal size and must retract parts of itself to keep moving around
//Each of its tiles can be damaged. The damage moves around along with the tiles as they retract/expand. Once destroyed, a meatblob tile leaves a butcherable "corpse"
//After each movement it recomputes which tiles is at its "center". If that tile gets destroyed, the rest of the blob immediately goes inert.
//Its default behaviour is to alternate between staying idle (which allows it to slowly heal damage) and moving to a nearby visible location.
//When it gets hurt, it enters a fleeing state where it tries to move away from the source of damage.
//If it keeps getting hurt, it'll become able to move faster and faster. After a while without getting hurt it slows down until it re-enters its idle state.


//This datum serves at the "parent" that tracks all of the meatblob's components.
/datum/meat_blob
	var/list/blob_tiles = list()	//All the /obj/meat_blob that make up this creature
	var/obj/meat_blob/center_blob = null	//After each movement, which tile is the center gets recalculated
	var/obj/meat_blob/previous_center = null//Used to notice when we're stuck in a repetitive pattern
	var/initial_size = 10	//How many blob tiles are compacted inside the core. Will spread out given the chance.
	var/mass_to_move = 0	//Some buffer to move around by contracting/expanding
	var/average_x = 0	//The average X coordinate of all blob tiles, used to calculate both the center and each tile's direction from it
	var/average_y = 0	//The average Y coordinate
	var/turf/target_tile = null	//Always set. It's either the turf below the center when idle, the tile we want to roam to, or the tile we want to flee toward
	var/turf/target_dist = 0	//How far away we are from the target. Used in many ways such as noticing when we're stuck, or how close is each tile from the target
	var/turf/target_dir = 0		//Direction between the center and the target, used in the calculations to see which tiles are facing toward/away from the target
	var/blobZ = 1	//Which ZLevel is our meatblob currently on. May get updated if the center blob gets forceMove()'d

	//These modifiers affect the way the blob moves round. I pin-pointed down these values after much trial and error.
	var/target_modifier = 1	//Changes the score of tiles based on how close they are from the target turf
	var/group_modifier = 1.5//Changes the score of tiles based on how many cardinally adjacent tiles from the same meatblob there are (helps keeping the meatblob visually wide)
	var/block_modifier = -1	//Changes the score of tiles based on how many directions we cannot expand toward (not counting directions that already have parts of the same meatblob)
	var/side_modifier = 1	//Changes the score of tiles based on whether they are facing toward or away from the target turf

	var/list/high_scorers = list()	//We pick the tile that gets to expand from those
	var/list/low_scorers = list()	//We pick the tile that gets to retract from those
	var/list/low_scorers_necessary = list()	//In the rare cases where we might have accidentally "shackled" ourselves, we may retract a necessary tile as long as it doesn't split us
	var/necessary_count = 0	//How many tiles are "necessary" (aka, removing them might split the meatblob in two)

	var/update_speed = 5//How many ticks between movements. Automatically updated when fleeing based on recent damage instances.

	var/bleed_time_check = 0	//When did we last leave a blood drip (not counting movement based ones)
	var/bleed_delay = 3 SECONDS	//How much time between attempts at making our blob drip blood, or heal its parts.
	var/heal_rate = 5	//Each tile heals by this much every bleed_delay while the blob is idle

	var/stuck_count = 0			//Counts up every time we fail to make significant movement toward our target, used so we may attempt unshackling ourselves
	var/stuck_critical = 10		//After this many stuck counts, we will try to remove a necessary tile so long as it doesn't breaks the whole meatblob's integrity
	var/list/integrity_check = list()
	var/verify_integrity = FALSE	//set to TRUE after a tile gets forceMove()'d. Tiles that are no longer connected to the center go inert.

	var/state = MEATBLOB_IDLE
	var/time_spent = 0			//how long have we been in the current state (in terms of processing loops)
	var/rest_duration = 10		//how long should we stay idle before roaming somewhere else
	var/max_roam_duration = 15	//failsafe should we target a turf that we cannot actually get close to
	var/damage_stack = 0		//how many times did we get attacked since we last relaxed
	var/time_to_recover = 10	//how much time does it take after taking damage to return to relax
	var/turf/wrong_loc = null	//we just retracted from there, if trying to expand there again while roaming, increase time spent

	var/image/center_image = null	//Admins can replace that :)

/datum/meat_blob/proc/instantiate(var/turf/spawnpoint)
	if (!spawnpoint)
		qdel(src)
		return
	spawn()
		custom_process()
	blobZ = spawnpoint.z
	center_image = image('icons/mob/meatblob.dmi',"center")
	var/obj/meat_blob/first_blob = new (spawnpoint)
	blob_tiles += first_blob
	first_blob.blob_datum = src
	average_x = first_blob.x
	average_y = first_blob.y
	mass_to_move = initial_size
	center_blob = first_blob
	set_target(spawnpoint)

/datum/meat_blob/proc/custom_process()
	set waitfor = FALSE//so the proc doesn't stop looping after a while

	//We're dying, no more processing ever again
	if (state == MEATBLOB_DEAD)
		return

	//Bleeding & Healing
	if (world.time > (bleed_time_check + bleed_delay))
		bleed_time_check = world.time
		for (var/blob in blob_tiles)
			var/obj/meat_blob/B = blob
			if (B.health < B.maxHealth)
				if (prob(100*(B.maxHealth - B.health)/B.maxHealth))
					blood_splatter(B.loc,null,FALSE)
				if (state == MEATBLOB_IDLE)
					B.healing(heal_rate)

	//Part(s) of us got forceMoved? we should probably verify if we're still in one piece
	if (verify_integrity)
		verify_integrity = FALSE
		integrity_check = list(center_blob)
		core_integrity(list(center_blob),null)
		if (integrity_check.len < blob_tiles.len )//looks like we're not, could be due to a shuttle moving or something else unexpected
			var/list/ripped_blobs = list()
			ripped_blobs = blob_tiles - integrity_check
			for (var/ripped_blob in ripped_blobs)
				var/obj/meat_blob/B = ripped_blob
				B.die_out()//the parts of us that are no longer connected to the center will die out
				B.blob_datum = null
				blob_tiles -= B
		//now let's recalculate the blob's vars so the thing can move properly again
		blobZ = center_blob.z
		var/total_x = 0
		var/total_y = 0
		for (var/bleb in blob_tiles)
			var/obj/meat_blob/B = bleb
			total_x += B.x
			total_y += B.y
		average_x = total_x / blob_tiles.len
		average_y = total_y / blob_tiles.len
		set_target(center_blob.loc)

	//Movement
	time_spent++
	switch(state)
		if (MEATBLOB_IDLE)
			update_speed = 5
			if (time_spent >= rest_duration)//we've rested enough, let's now move toward a random non-dense turf
				state = MEATBLOB_ROAM
				time_spent = 0
				var/turf/T = get_turf(pick(blob_tiles))
				var/list/potential_dests = list()
				for(var/turf/U in dview(world.view, T, INVISIBILITY_MAXIMUM))
					if (!U.density)
						potential_dests.Add(U)
				set_target(pick(potential_dests))
		if (MEATBLOB_ROAM)
			update_speed = 5
			if ((target_dist < 2) || (time_spent >= max_roam_duration))//we've reached or destination or won't be able to reach it, let's rest a moment
				state = MEATBLOB_IDLE
				time_spent = 0
				set_target(center_blob.loc)
		if (MEATBLOB_FLEE)
			var/actual_time_to_recover = time_to_recover * (5/update_speed)
			if (time_spent >= actual_time_to_recover)
				if (update_speed < 5)
					switch(update_speed)
						if (4)
							damage_stack = 0
						if (3)
							damage_stack = 3
						if (2)
							damage_stack = 10
						if (1)
							damage_stack = 20
					update_speed++
					time_spent = 0
				else
					state = MEATBLOB_IDLE
					time_spent = 0
					set_target(center_blob.loc)
			switch(damage_stack)
				if (0 to 2)
					update_speed = 5
				if (3 to 9)
					update_speed = 4
				if (10 to 19)
					update_speed = 3
				if (20 to 29)
					update_speed = 2
				if (30 to INFINITY)
					update_speed = 1

	if (target_tile)
		tally_scores()
		if (mass_to_move)//We have mass, lets expand
			if (high_scorers?.len)
				var/obj/meat_blob/expanding = pick(high_scorers)
				if (!expanding.timestopped && expanding.available_directions?.len)
					var/expansion = pick(expanding.available_directions)
					var/obj/meat_blob/new_blob = expand_blob(expanding, get_step(expanding.loc,expansion))
					if (new_blob)
						for (var/obj/meat_blob/B in range(new_blob.loc,1))
							B.is_necessary()//updating sprite
						mass_to_move--
						set_target(target_tile)//updating target distance and direction
		else if (state != MEATBLOB_IDLE)//We're out of mass and we want to move, let's retract parts of us that are away from where we want to go
			var/retracting_attempt = 0
			if ((stuck_count >= stuck_critical) && (necessary_count >= 7))//For there to be an actual shackle to cut there should be at least 7 "necessary" tiles
				var/obj/meat_blob/retracting = pick(low_scorers_necessary)
				if (!retracting.timestopped)
					integrity_check = list(center_blob)
					core_integrity(list(center_blob),retracting)
					if (integrity_check.len == (blob_tiles.len - 1))//making sure that we're not separating the blob in two
						if (retracting.connection_directions?.len)
							var/retraction = pick(retracting.connection_directions)
							if (retraction)
								var/turf/T = retracting.loc
								var/obj/meat_blob/merger = locate(/obj/meat_blob) in get_step(T,retraction)
								retracting.retracting = TRUE
								remove_blob(retracting,retraction)
								qdel(retracting)
								for (var/obj/meat_blob/B in range(T,1))
									if (B == merger)
										spawn(2)
											B.is_necessary()
									else
										B.is_necessary()//updating sprite
								mass_to_move++
								set_target(target_tile)//updating target distance and direction
								retracting_attempt = 1
			if (!retracting_attempt && low_scorers?.len)
				var/obj/meat_blob/retracting = pick(low_scorers)
				if (!retracting.timestopped && retracting.connection_directions?.len)
					var/retraction = pick(retracting.connection_directions)
					if (retraction)
						var/turf/T = retracting.loc
						var/obj/meat_blob/merger = locate(/obj/meat_blob) in get_step(T,retraction)
						retracting.retracting = TRUE
						remove_blob(retracting,retraction)
						qdel(retracting)
						for (var/obj/meat_blob/B in range(T,1))
							if (B == merger)
								spawn(2)
									B.is_necessary()
							else
								B.is_necessary()//updating sprite
						mass_to_move++
						set_target(target_tile)//updating target distance and direction
						retracting_attempt = 1
			if (!retracting_attempt)
				re_center()//building up stuck_count

	sleep(update_speed)
	custom_process()

//Re-calculating the meatblob's center tile
/datum/meat_blob/proc/re_center()
	if (!blob_tiles?.len)
		return
	var/obj/meat_blob/preprevious_center = previous_center
	previous_center = center_blob
	var/closest_total_diff = 100
	var/obj/meat_blob/most_centered = null
	for (var/blob in blob_tiles)
		var/obj/meat_blob/B = blob
		var/diff_x = abs(B.x - average_x)
		var/diff_y = abs(B.y - average_y)
		var/total_diff = diff_x + diff_y
		if ((total_diff < closest_total_diff) || ((total_diff == closest_total_diff) && prob(50)))
			closest_total_diff = total_diff
			most_centered = B
	if (center_blob)
		center_blob.overlays -= center_image
	center_blob = most_centered
	center_blob.overlays += center_image
	if (((previous_center == center_blob)||(preprevious_center == center_blob)) && (target_dist > 2))//if the center hasn't moved in a while and we're nowhere near the target, we might be shackled
		stuck_count++
	else
		stuck_count = 0

/datum/meat_blob/proc/set_target(var/turf/T)
	if (!T || (T.z != blobZ))
		return
	target_tile = T
	target_dist = abs(abs(center_blob.x - T.x) + abs(center_blob.y - T.y))
	target_dir = get_dir(center_blob,T)

//Checking if parts got disconnected after some of us gets forceMove()'d
/datum/meat_blob/proc/core_integrity(var/list/blobs_to_check,var/obj/meat_blob/blob_to_kill = null)
	var/list/next_blobs = list()
	for(var/blob in blobs_to_check)
		var/obj/meat_blob/B = blob
		for (var/direction in cardinal)
			var/turf/T = get_step(B.loc,direction)
			var/obj/meat_blob/O = locate(/obj/meat_blob) in T
			if (O && (O in blob_tiles) && (O != blob_to_kill))
				if (!(O in integrity_check))
					next_blobs += O
				integrity_check |= O
	if (next_blobs?.len)
		core_integrity(next_blobs,blob_to_kill)

/datum/meat_blob/proc/tally_scores()
	high_scorers = list()
	low_scorers = list()
	low_scorers_necessary = list()
	necessary_count = 0
	var/high_score = -100
	var/low_score = 100
	var/low_score_critical = 100
	for (var/blob in blob_tiles)
		var/obj/meat_blob/B = blob
		B.set_target_score()
		B.set_side_score()
		B.set_group_and_block_score()
		B.score = B.target_score * target_modifier + B.group_score * group_modifier + B.side_score * side_modifier
		//B.maptext = "[B.score]"
		if ((B.group_score + B.block_score) < 4)//we're not gonna try to expand off an inner tile or a blocked tile
			if (B.score > high_score)
				high_scorers = list(B)
				high_score = B.score
			else if (B.score == high_score)
				high_scorers += B
		if (!B.is_necessary())//we're not gonna cut off a tile that would separate the blob in two
			if (B.score < low_score)
				low_scorers = list(B)
				low_score = B.score
			else if (B.score == low_score)
				low_scorers += B
		else if (stuck_count > stuck_critical)//UNLESS we somehow shackled ourselves by accident
			necessary_count++
			if (B.score < low_score_critical)
				low_scorers_necessary = list(B)
				low_score_critical = B.score
			else if (B.score == low_score_critical)
				low_scorers_necessary += B

//Creating a new blob tile
/datum/meat_blob/proc/expand_blob(var/obj/meat_blob/source, var/turf/target)
	var/obj/meat_blob/new_blob = new (source.loc)
	//Attempt to move into the tile
	if(target.Enter(new_blob, source.loc, TRUE))
		new_blob.Move(target)
		var/movement_dir = get_dir(source.loc,target)
		new_blob.move_blob(movement_dir)
		if ((target == wrong_loc) && (state == MEATBLOB_ROAM))//if we're moving in place while roaming...stop it, that looks dumb
			time_spent += 10
		if (state == MEATBLOB_FLEE)//if we're running away from harm, let's try and bump doors open
			var/obj/machinery/door/airlock/D = locate(/obj/machinery/door/airlock) in get_step(new_blob.loc, movement_dir)
			if (D)
				D.set_up_access()
				if (can_access(list(),D.req_access,D.req_one_access))
					spawn()
						D.open()

		//updating the parent datum, moving the center around, etc
		new_blob.blob_datum = src
		var/total_x = average_x * blob_tiles.len
		var/total_y = average_y * blob_tiles.len
		blob_tiles += new_blob
		average_x = (total_x + new_blob.x) / blob_tiles.len
		average_y = (total_y + new_blob.y) / blob_tiles.len
		re_center()

		if (source.health < source.maxHealth)
			//moving the source's damage to the new blob
			new_blob.damage_overlay = image('icons/turf/bloodrealm.dmi',src,"blank")
			new_blob.damage_overlay.appearance_flags = RESET_COLOR
			new_blob.possible_wounds = source.possible_wounds.Copy()
			new_blob.acquired_wounds = source.acquired_wounds.Copy()
			for (var/wound in new_blob.acquired_wounds)
				new_blob.damage_overlay.overlays += wound
			new_blob.overlays += new_blob.damage_overlay
			new_blob.health = source.health

			//the source blob is now healed of all damage
			source.health = source.maxHealth
			source.overlays -= source.damage_overlay
			source.damage_overlay.overlays.len = 0
			source.possible_wounds = list("blood_1","blood_2","blood_3","blood_4","blood_5")
			source.acquired_wounds = list()

		return new_blob
	else
		qdel(new_blob)
		return null

/datum/meat_blob/proc/attacked(var/obj/meat_blob/victim,var/just_target_update = FALSE)
	if (state == MEATBLOB_DEAD)
		return
	if (state != MEATBLOB_FLEE)
		time_spent = 0
		damage_stack = 0
		state = MEATBLOB_FLEE

	if (just_target_update || ((time_spent > 0) || (damage_stack == 0)))
		var/dist_mod = 1
		var/damage_dist = abs(abs(center_blob.x - victim.x) + abs(center_blob.y - victim.y))
		if (damage_dist < 2)
			dist_mod = 3
		else if (damage_dist < 4)
			dist_mod = 2
		var/target_x = dist_mod * (center_blob.x - victim.x) + center_blob.x
		var/target_y = dist_mod * (center_blob.y - victim.y) + center_blob.y
		set_target(locate(target_x,target_y,blobZ))
	if (!just_target_update)
		damage_stack++
		time_spent = 0


/datum/meat_blob/proc/remove_blob(var/obj/meat_blob/blob,var/merge)
	if (blob == center_blob)//killing the center tile = sudden death
		state = MEATBLOB_DEAD
		for(var/bleb in blob_tiles)
			var/obj/meat_blob/B = bleb
			B.blob_datum = null
			B.die_out()
			blob_tiles -= bleb
		qdel(src)
		return
	blob.blob_datum = null
	var/total_x = average_x * blob_tiles.len
	var/total_y = average_y * blob_tiles.len
	blob_tiles -= blob
	average_x = (total_x - blob.x) / blob_tiles.len
	average_y = (total_y - blob.y) / blob_tiles.len
	re_center()
	if (merge)//the blob is merely retracting into the mass
		wrong_loc = blob.loc
		if (blob.health < blob.maxHealth)
			if (prob(100*(blob.maxHealth - blob.health)/blob.maxHealth))
				blood_splatter(blob.loc,null,FALSE)
		var/atom/movable/overlay/animation = new /atom/movable/overlay(blob.loc)
		animation.appearance = blob.appearance
		animation.layer -= 1
		switch(merge)
			if (NORTH)
				animate(animation,pixel_y = 32, time = 2, easing = SINE_EASING|EASE_IN)
			if (SOUTH)
				animate(animation,pixel_y = -32, time = 2, easing = SINE_EASING|EASE_IN)
			if (WEST)
				animate(animation,pixel_x = -32, time = 2, easing = SINE_EASING|EASE_IN)
			if (EAST)
				animate(animation,pixel_x = 32, time = 2, easing = SINE_EASING|EASE_IN)

		//if we have some damage, we gotta transfer it
		if (blob.health < blob.maxHealth)
			var/obj/meat_blob/merger = locate(/obj/meat_blob/) in get_step(blob.loc,merge)
			//if the blob we're merging into is more healthy, than the one retracting, we set its health to the retracting blob's
			if (merger.health > blob.health)
				merger.get_hit(merger.health - blob.health,null,"merge")
			//otherwise, the blob takes damage corresponding to the health lost by the retracting blob
			else if (merger.health < blob.health)
				var/blob_health_percent = blob.health * 100 / blob.maxHealth
				var/merger_new_health = max(merger.health * blob_health_percent / 100,1)
				merger.get_hit(merger.health - merger_new_health,null,"merge")
		spawn(2)
			qdel(animation)

	else//the blob got deleted by something, let's verify if we're still in one piece
		integrity_check = list(center_blob)
		core_integrity(list(center_blob),null)
		if (integrity_check.len < blob_tiles.len )
			var/list/ripped_blobs = list()
			ripped_blobs = blob_tiles - integrity_check
			for (var/ripped_blob in ripped_blobs)
				var/obj/meat_blob/B = ripped_blob
				B.die_out()
				B.blob_datum = null
				blob_tiles -= B


#undef MEATBLOB_IDLE
#undef MEATBLOB_ROAM
#undef MEATBLOB_FLEE
#undef MEATBLOB_DEAD


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//This is an individual "tile" of the meatblob
/obj/meat_blob
	name = "meat blob"
	desc = "It looks fairly harmless, maybe tasty even."
	icon = 'icons/mob/meatblob.dmi'
	icon_state = "blob"
	anchored = 1
	density = 1
	layer = BLOB_SHIELD_LAYER
	plane = BLOB_PLANE

	health = 100
	maxHealth = 100

	var/datum/meat_blob/blob_datum = null	//Parent datum

	var/target_score = 0	//Score based on how far we are from the parent's target
	var/group_score = 0		//Score based on how many cardinally adjacent /obj/meat_blob tiles from the same parents we have
	var/block_score = 0		//Score based on how many cardinal directions that don't have a fellow blob tile are blocked from expansion
	var/side_score = 0		//Score based on whether we face toward or away from the target
	var/score = 0	//Total Score, high scorers get to expand, low scorers get retracted

	var/list/available_directions = list()	//Which cardinal directions are free for expansion
	var/list/connection_directions = list()	//Which cardinal directions have tiles from the same parent (so we may visually retract into them)

	//Damage overlay stuff
	var/list/possible_wounds = list("blood_1","blood_2","blood_3","blood_4","blood_5")
	var/list/acquired_wounds = list()
	var/image/damage_overlay = null

	var/retracting = FALSE

/obj/meat_blob/Destroy()
	if (blob_datum)
		blob_datum.remove_blob(src)
	blob_datum = null

	if (!retracting)
		rip_connections()
		for (var/obj/meat_blob/B in range(loc,1))
			B.is_necessary()//updating surrounding blob sprites
	..()

/obj/meat_blob/proc/set_target_score()
	var/dist = abs(abs(x - blob_datum.target_tile.x) + abs(y - blob_datum.target_tile.y))
	target_score = blob_datum.target_dist - dist

/obj/meat_blob/proc/set_side_score()
	side_score = 0
	if (src != blob_datum.center_blob)
		var/current_dir = get_dir(blob_datum.center_blob,src)
		if (blob_datum.target_dir & current_dir)
			side_score = 1
		else
			side_score = -1

/obj/meat_blob/proc/set_group_and_block_score()
	group_score = 0
	block_score = 0
	available_directions = list()
	connection_directions = list()
	for (var/direction in cardinal)
		var/turf/T = get_step(loc,direction)
		var/adjacent_blob = locate(/obj/meat_blob) in T
		if (adjacent_blob && (adjacent_blob in blob_datum.blob_tiles))
			group_score++
			connection_directions += direction
		else if (!T.Enter(src, loc, TRUE))
			block_score++
		else
			available_directions += direction

//This proc loops through all 8 surrounding turfs in a clockwise fashion to check if it contains a meatblob tile from the same parent datum
/*
		1  2  3

		8 src 4

	    7  6  5
*/
//If it alternates between finding/not-finding 3 or more times, that means this blob would split the group of blob tiles in two, so the blob shouldn't try to retract those
//We also take this opportunity to note down which of those tiles have connected blobs so we can update our icon_state. There are 256 possible combinations from XXXXXXXX to OOOOOOOO
/obj/meat_blob/proc/is_necessary()
	if (!blob_datum)
		return
	var/connections = ""
	var/static/list/clockwise_coords = list(
		list(-1,1),
		list(0,1),
		list(1,1),
		list(1,0),
		list(1,-1),
		list(0,-1),
		list(-1,-1),
		list(-1,0),
		)
	var/toggle_count = -1
	var/toggle_status = -1
	for (var/list/coord in clockwise_coords)
		var/nearby_blob = locate(/obj/meat_blob) in locate(x+coord[1],y+coord[2],z)
		if (nearby_blob && (nearby_blob in blob_datum.blob_tiles))
			connections += "O"
			if (toggle_status == 1)
				continue
			else
				toggle_status = 1
				toggle_count++
		else
			connections += "X"
			if (toggle_status == 0)
				continue
			else
				toggle_status = 0
				toggle_count++
	icon_state = connections
	return (toggle_count >= 3)

/obj/meat_blob/blocks_doors()
	return TRUE

/obj/meat_blob/forceMove(atom/destination, step_x = 0, step_y = 0, no_tp = FALSE, harderforce = FALSE, glide_size_override = 0)
	..()
	if (blob_datum)
		blob_datum.verify_integrity = TRUE

//Visually animates the blob expanding from the mass
/obj/meat_blob/proc/move_blob(var/direction)
	layer = BLOB_BASE_LAYER
	switch(direction)
		if (NORTH)
			pixel_y = -32
		if (SOUTH)
			pixel_y = 32
		if (EAST)
			pixel_x = -32
		if (WEST)
			pixel_x = 32
	animate(src,pixel_x = 0, pixel_y = 0, time = 2, easing = SINE_EASING|EASE_OUT)
	spawn(1)
		layer = BLOB_SHIELD_LAYER

/obj/meat_blob/proc/die_out()
	animate(src, color = list(0.6,0.2,0.2,0,0.2,0.6,0.2,0,0.2,0.2,0.6,0,0,0,0,1,0,0,0,0), time = 50)

/obj/meat_blob/proc/get_hit(var/damage = 0,var/mob/user,var/hitsound = get_sfx("machete_hit"))
	if (!damage)
		return

	if (blob_datum)
		blob_datum.attacked(src,(hitsound == "merge"))

	if (!damage_overlay)
		damage_overlay = image('icons/turf/bloodrealm.dmi',src,"blank")
		damage_overlay.appearance_flags = RESET_COLOR

	if(loc && hitsound && (hitsound != "merge"))
		playsound(loc, hitsound, 20, 1)

	var/next_threshold = maxHealth
	while (next_threshold > health)
		next_threshold -= maxHealth/5

	overlays -= damage_overlay

	health -= damage

	if (health <= 0)
		new /mob/living/simple_animal/meat_blob_chunk(loc)
		blood_splatter(loc,null,TRUE)
		qdel(src)
	else
		while (health < next_threshold && possible_wounds.len)
			var/new_wound = pick(possible_wounds)
			possible_wounds -= new_wound
			acquired_wounds += new_wound
			damage_overlay.overlays += new_wound
			next_threshold -= maxHealth/5
		overlays += damage_overlay

/obj/meat_blob/proc/rip_connections()
	if (loc)
		playsound(loc, "sound/effects/blobsplat.ogg", 50, 1)
	for(var/direction in connection_directions)
		var/obj/meat_blob/connected = locate(/obj/meat_blob/) in get_step(loc,direction)
		if (connected)
			var/opposite = GetOppositeDir(direction)
			if (connected.connection_directions & opposite)
				connected.connection_directions -= opposite
				if (!connected.blob_datum)
					var/image/I = image('icons/turf/bloodrealm.dmi',connected,"blood_border_[opposite]")
					connected.overlays += I
		var/offset_x = 0
		var/offset_y = 0
		switch(direction)
			if (NORTH)
				offset_y = 16
			if (SOUTH)
				offset_y = -16
			if (EAST)
				offset_x = 16
			if (WEST)
				offset_x = -16
		anim(target = loc, a_icon = 'icons/turf/bloodrealm.dmi', flick_anim = "blob_rip", lay = layer+1, offX = offset_x, offY = offset_y, plane = src.plane)

/obj/meat_blob/proc/healing(var/rate)
	if (health == maxHealth)
		return

	var/next_threshold = 0
	while (next_threshold < health)
		next_threshold += maxHealth/5

	if (!damage_overlay)
		damage_overlay = image('icons/turf/bloodrealm.dmi',src,"blank")
		damage_overlay.appearance_flags = RESET_COLOR

	overlays -= damage_overlay

	health += rate

	while (health > next_threshold && acquired_wounds.len)
		var/new_wound = pick(acquired_wounds)
		acquired_wounds -= new_wound
		possible_wounds += new_wound
		damage_overlay.overlays -= new_wound
		next_threshold += maxHealth/5

	if (health >= maxHealth)
		health = maxHealth
		return

	overlays += damage_overlay


//hit by held items
/obj/meat_blob/attackby(var/obj/item/weapon/W, var/mob/living/user)
	user.delayNextAttack(8)
	var/dam = W.force
	if(W.sharpness_flags & SHARP_BLADE)
		dam *= 1.2
	if(dam)
		user.do_attack_animation(src, W)
		user.visible_message("<span class='danger'>\The [user] [pick(W.attack_verb)] \the [src] with \the [W].</span>")
	get_hit(dam,user)
	..()

//explosions
/obj/meat_blob/ex_act(severity)
	switch(severity)
		if(1)
			get_hit(rand(200, 300),null, 0)
		if(2)
			get_hit(rand(50, 150),null, 0)
		if(3)
			get_hit(rand(5, 50),null, 0)

//singularity
/obj/meat_blob/singularity_act()
	playsound(loc, "sound/effects/blobsplat.ogg", 50, 1)
	new /mob/living/simple_animal/meat_blob_chunk(loc)//feeding the singulo some more straight away
	qdel(src)
	return(20)

/obj/meat_blob/singularity_pull(var/obj/machinery/singularity/S, var/singulo_size, var/repels = FALSE)
	if (!repels)
		get_hit(singulo_size, null, 0)
		if(singulo_size >= STAGE_FIVE)
			step_towards(src, S)

//hit by bullets
/obj/meat_blob/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)
		return
	get_hit(Proj.damage, Proj.firer)
	return ..()

//hit by .... blob?
/obj/meat_blob/blob_act()
	get_hit(30,40,null, 0)
	playsound(loc, 'sound/effects/blobattack.ogg',50,1)

//hit by thrown items
/obj/meat_blob/hitby(var/atom/movable/AM,var/speed = 5)
	if(isitem(AM))
		var/obj/item/I = AM
		get_hit(I.throwforce*speed/5)

//slashed by simple_animals
/obj/meat_blob/attack_animal(var/mob/living/simple_animal/user)
	user.delayNextAttack(8)
	user.do_attack_animation(src, user)
	get_hit(user.get_unarmed_damage(src),user, user.get_unarmed_hit_sound())

//slashed (touched?) by humans
/obj/meat_blob/attack_hand(var/mob/living/carbon/human/user)
	if (user.a_intent == I_HURT)
		user.delayNextAttack(8)
		user.do_attack_animation(src, user)
		var/datum/species/S = user.get_organ_species(user.get_active_hand_organ())
		user.visible_message("<span class='danger'>\The [user] [S.attack_verb] \the [src].</span>")
		get_hit(user.get_unarmed_damage(src),user, user.get_unarmed_hit_sound())

//slashed (touched?) by monkeys
/obj/meat_blob/attack_paw(var/mob/living/carbon/monkey/user)
	if (user.a_intent == I_HURT)
		if(user.wear_mask?.is_muzzle)
			to_chat(user, "<span class='notice'>You can't do this with \the [user.wear_mask] on!</span>")
			return
		user.delayNextAttack(8)
		user.do_attack_animation(src, user)
		get_hit(user.get_unarmed_damage(src),user, user.get_unarmed_hit_sound())

//slashed by aliums
/obj/meat_blob/attack_alien(var/mob/living/carbon/alien/humanoid/user)
	if(istype(user, /mob/living/carbon/alien/larva))
		return
	user.delayNextAttack(8)
	user.do_attack_animation(src, user)
	var/alienverb = pick(list("slam", "rip", "claw"))
	user.visible_message("<span class='warning'>[user] [alienverb]s \the [src].</span>", \
						 "<span class='warning'>You [alienverb] \the [src].</span>", \
						 "You hear ripping flesh.")
	get_hit(rand(15,30),user)

//beams (mostly copied from theblob.dm)
/obj/meat_blob/beam_connect(var/obj/effect/beam/B)
	..()
	last_beamchecks["\ref[B]"]=world.time+1
	//we don't deal damage right away because the blob might not be fully initalized
	if(!(src in processing_objects))
		processing_objects.Add(src)

/obj/meat_blob/beam_disconnect(var/obj/effect/beam/B)
	..()
	last_beamchecks.Remove("\ref[B]")
	if(beams.len == 0)
		processing_objects.Remove(src)

/obj/meat_blob/apply_beam_damage(var/obj/effect/beam/B)
	var/lastcheck=last_beamchecks["\ref[B]"]

	// Standard damage formula / 2
	var/damage = ((world.time - lastcheck)/10)  * (B.get_damage() / 2)

	// Actually apply damage
	get_hit(damage, null, "merge")

	// Update check time.
	last_beamchecks["\ref[B]"]=world.time

/obj/meat_blob/handle_beams()
	for(var/obj/effect/beam/B in beams)
		apply_beam_damage(B)

/obj/meat_blob/process()
	handle_beams()

/obj/meat_blob/can_mech_drill()
	return TRUE

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//"Corpse" that spawns when a meatblob tile gets destroyed, meant to be butchered
/mob/living/simple_animal/meat_blob_chunk
	name = "meat blob chunk"
	desc = "The remains of a meat blob, waiting to be butchered"
	icon = 'icons/mob/meatblob.dmi'
	icon_state = "blob_corpse"
	icon_living = "blob_corpse"
	icon_dead = "blob_corpse"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/animal/meatblob
	size = SIZE_BIG
	plane = OBJ_PLANE
	layer = BELOW_OBJ_LAYER
	stop_automated_movement = TRUE//not like it should matter but anyway
	iscorpse = 1//no stat tracking

/mob/living/simple_animal/meat_blob_chunk/New(turf/loc)
	..()
	death()//you're already dead meat

/mob/living/simple_animal/meat_blob_chunk/Life()
	death()//don't bother, Lazarus

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Nice and edible meat from the realm of Nar-Sie
/obj/item/weapon/reagent_containers/food/snacks/meat/animal/meatblob
	name = "meat blob meat"
	desc = "Yep, that's meat."
	icon_state = "meatblob"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
