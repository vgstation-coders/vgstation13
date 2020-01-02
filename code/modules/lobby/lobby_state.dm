var/global/datum/lobby_controller/lobby = new

// The entire purpose of this thing is adminbus.
/datum/lobby_controller
	// Animation+Playlists are grouped into pools for various maps.
	// For example, there's the main pool for most maps, then snow for xmas-y stuff, then maybe eventually a lamprey one.
	var/pool = "main"

	// Overrides
	var/animation_id = null
	var/animation_url = null
	var/playlist = null
	var/song_url = null // URL.  Do not use the one from the media server, it's different for every user.
	var/song_id = null // MD5 of the song from the media server.

/datum/lobby_controller/New()
	..()

/datum/lobby_controller/proc/setAnimationID(var/url)
	src.animation_url = url
	for(var/client/C in clients)
		C.displayLobby() // Refresh

/datum/lobby_controller/proc/setAnimationURL(var/url)
	src.animation_url = url
	for(var/client/C in clients)
		C.setLobbyAnimationURL(url)

/datum/lobby_controller/proc/setSongURL(var/url)
	src.song_url = url
	for(var/client/C in clients)
		C.setLobbySongURL(url)

/datum/lobby_controller/proc/setPlaylist(var/id)
	src.playlist = id
	for(var/client/C in clients)
		C.setLobbyPlaylistID(id)

/datum/lobby_controller/proc/setPool(var/id)
	src.pool = id
	for(var/client/C in clients)
		C.displayLobby() // Refresh
