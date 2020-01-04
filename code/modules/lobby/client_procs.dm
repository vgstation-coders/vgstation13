#define LOBBY_CONTROL "lobby"

/client
	var/lobbyPlaying = TRUE

/client/proc/showLobbyControl(var/show)
	winset(src, LOBBY_CONTROL, "is-visible="+(show ? "true" : "false"))

/client/proc/closeLobby()
	src << output(list2params(list()), "[LOBBY_CONTROL]:stopPlaying")
	showLobbyControl(FALSE)
	lobbyPlaying = FALSE

/client/proc/setLobbyAnimationURL(var/url)
	src << output(list2params(list(url)), "[LOBBY_CONTROL]:setAnimationURL")

/client/proc/setLobbyPlaylistID(var/id)
	src << output(list2params(list(id)), "[LOBBY_CONTROL]:setPlaylistID")

/client/proc/setLobbySongMD5(var/id)
	src << output(list2params(list(id)), "[LOBBY_CONTROL]:setSongMD5")

/client/proc/setLobbySongURL(var/url)
	src << output(list2params(list(url)), "[LOBBY_CONTROL]:setMediaURL")

/client/proc/displayLobby()
	var/list/query = list()
	// Used in error reporting.
	query["src"] = "\ref[src]"
	// Used for admin shittery panel
	query["ckey"] = "[src.ckey]"
	// Also admin shittery panel
	if(src.holder)
		query["holder"] = "\ref[src.holder]"
	if(lobby.song_url != null)
		query["song_url"] = lobby.song_url
	if(lobby.song_md5 != null)
		query["song_md5"] = lobby.song_md5
	else if(lobby.playlist != null)
		query["playlist"] = lobby.playlist
	if(lobby.animation_id != null)
		query["anim"] = lobby.animation_id
	else if(lobby.animation_url != null)
		query["bg"] = lobby.animation_url
	if(lobby.pool != null)
		query["pool"] = lobby.pool
	var/url="[config.vgws_base_url]/index.php/lobby"
	url += buildurlquery(query)
	// Yes, we have to redirect, because browse(link()) throws a fucking error
	src << output("<html><head><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" /></head><body><script>window.location='[url]';</script>Redirecting <a href=\"[url]\">here</a> due to a BYOND bug.</body></html>", LOBBY_CONTROL)
	lobbyPlaying = TRUE
	showLobbyControl(TRUE)
