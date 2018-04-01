// CAMERA NET
//
// The datum containing all the chunks.

#define CHUNK_SIZE 16 // Only chunk sizes that are to the power of 2. E.g: 2, 4, 8, 16, etc..

GLOBAL_DATUM_INIT(cameranet, /datum/cameranet, new)

/datum/cameranet
	var/name = "Camera Net" // Name to show for VV and stat()

	// The cameras on the map, no matter if they work or not. Updated in obj/machinery/camera.dm by New() and Del().
	var/list/cameras = list()
	// The chunks of the map, mapping the areas that the cameras can see.
	var/list/chunks = list()
	var/ready = 0

	// The object used for the clickable stat() button.
	var/obj/effect/statclick/statclick

// Checks if a chunk has been Generated in x, y, z.
/datum/cameranet/proc/chunkGenerated(x, y, z)
	x &= ~(CHUNK_SIZE - 1)
	y &= ~(CHUNK_SIZE - 1)
	var/key = "[x],[y],[z]"
	return (chunks[key])

// Returns the chunk in the x, y, z.
// If there is no chunk, it creates a new chunk and returns that.
/datum/cameranet/proc/getCameraChunk(x, y, z)
	x &= ~(CHUNK_SIZE - 1)
	y &= ~(CHUNK_SIZE - 1)
	var/key = "[x],[y],[z]"
	if(!chunks[key])
		chunks[key] = new /datum/camerachunk(null, x, y, z)

	return chunks[key]

// Updates what the aiEye can see. It is recommended you use this when the aiEye moves or it's location is set.

/datum/cameranet/proc/visibility(mob/camera/aiEye/ai)
	// 0xf = 15
	var/x1 = max(0, ai.x - 16) & ~(CHUNK_SIZE - 1)
	var/y1 = max(0, ai.y - 16) & ~(CHUNK_SIZE - 1)
	var/x2 = min(world.maxx, ai.x + 16) & ~(CHUNK_SIZE - 1)
	var/y2 = min(world.maxy, ai.y + 16) & ~(CHUNK_SIZE - 1)

	var/list/visibleChunks = list()

	for(var/x = x1; x <= x2; x += CHUNK_SIZE)
		for(var/y = y1; y <= y2; y += CHUNK_SIZE)
			visibleChunks |= getCameraChunk(x, y, ai.z)

	var/list/remove = ai.visibleCameraChunks - visibleChunks
	var/list/add = visibleChunks - ai.visibleCameraChunks

	for(var/chunk in remove)
		var/datum/camerachunk/c = chunk
		c.remove(ai)

	for(var/chunk in add)
		var/datum/camerachunk/c = chunk
		c.add(ai)

// Updates the chunks that the turf is located in. Use this when obstacles are destroyed or	when doors open.

/datum/cameranet/proc/updateVisibility(atom/A, opacity_check = 1)

	if(!SSticker || (opacity_check && !A.opacity))
		return
	majorChunkChange(A, 2)

/datum/cameranet/proc/updateChunk(x, y, z)
	// 0xf = 15
	if(!chunkGenerated(x, y, z))
		return
	var/datum/camerachunk/chunk = getCameraChunk(x, y, z)
	chunk.hasChanged()

// Removes a camera from a chunk.

/datum/cameranet/proc/removeCamera(obj/machinery/camera/c)
	majorChunkChange(c, 0)

// Add a camera to a chunk.

/datum/cameranet/proc/addCamera(obj/machinery/camera/c)
	if(c.can_use())
		majorChunkChange(c, 1)

// Used for Cyborg cameras. Since portable cameras can be in ANY chunk.

/datum/cameranet/proc/updatePortableCamera(obj/machinery/camera/c)
	if(c.can_use())
		majorChunkChange(c, 1)

// Never access this proc directly!!!!
// This will update the chunk and all the surrounding chunks.
// It will also add the atom to the cameras list if you set the choice to 1.
// Setting the choice to 0 will remove the camera from the chunks.
// If you want to update the chunks around an object, without adding/removing a camera, use choice 2.

/datum/cameranet/proc/majorChunkChange(atom/c, choice)
	// 0xf = 15
	if(!c)
		return

	var/turf/T = get_turf(c)
	if(T)
		var/x1 = max(0, T.x - (CHUNK_SIZE / 2)) & ~(CHUNK_SIZE - 1)
		var/y1 = max(0, T.y - (CHUNK_SIZE / 2)) & ~(CHUNK_SIZE - 1)
		var/x2 = min(world.maxx, T.x + (CHUNK_SIZE / 2)) & ~(CHUNK_SIZE - 1)
		var/y2 = min(world.maxy, T.y + (CHUNK_SIZE / 2)) & ~(CHUNK_SIZE - 1)
		for(var/x = x1; x <= x2; x += CHUNK_SIZE)
			for(var/y = y1; y <= y2; y += CHUNK_SIZE)
				if(chunkGenerated(x, y, T.z))
					var/datum/camerachunk/chunk = getCameraChunk(x, y, T.z)
					if(choice == 0)
						// Remove the camera.
						chunk.cameras -= c
					else if(choice == 1)
						// You can't have the same camera in the list twice.
						chunk.cameras |= c
					chunk.hasChanged()

// Will check if a mob is on a viewable turf. Returns 1 if it is, otherwise returns 0.

/datum/cameranet/proc/checkCameraVis(mob/living/target)

	// 0xf = 15
	var/turf/position = get_turf(target)
	return checkTurfVis(position)


/datum/cameranet/proc/checkTurfVis(turf/position)
	var/datum/camerachunk/chunk = getCameraChunk(position.x, position.y, position.z)
	if(chunk)
		if(chunk.changed)
			chunk.hasChanged(1) // Update now, no matter if it's visible or not.
		if(chunk.visibleTurfs[position])
			return 1
	return 0

/datum/cameranet/proc/stat_entry()
	if(!statclick)
		statclick = new/obj/effect/statclick/debug(null, "Initializing...", src)

	stat(name, statclick.update("Cameras: [GLOB.cameranet.cameras.len] | Chunks: [GLOB.cameranet.chunks.len]"))
