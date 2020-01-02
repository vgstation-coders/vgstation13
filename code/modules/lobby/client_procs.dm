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

/client/proc/setLobbySongID(var/id)
	src << output(list2params(list(id)), "[LOBBY_CONTROL]:setSongMD5")

/client/proc/setLobbySongURL(var/url)
	src << output(list2params(list(url)), "[LOBBY_CONTROL]:setMediaURL")

/client/proc/displayLobby()
	var/list/query = list()
	if(lobby.song_url != null)
		query["song_url"] = lobby.song_url
	if(lobby.song_id != null)
		query["song_id"] = lobby.song_id
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
	/*url = {"
	<html>
		<body>
			<iframe width='100%' height='100%' src="[url]"></iframe>
		</body>
	</html>
	"}*/
	src << output("<html><head><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" /></head><body><script>window.location='[url]';</script>Redirecting <a href=\"[url]\">here</a> due to a BYOND bug.</body></html>", LOBBY_CONTROL)
	lobbyPlaying = TRUE
	showLobbyControl(TRUE)
