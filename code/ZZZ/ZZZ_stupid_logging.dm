/client/var/client_initialized = FALSE

/client/New()
	world.log << "/client/New(): [src] (\ref[src])"
	client_initialized = TRUE
	..()

/client/Del()
	world.log << "/client/Del(): [src] (\ref[src])[client_initialized ? "" : " UNINITIALIZED"]"
	..()

/mob/new_player/New()
	world.log << "/mob/new_player/New(): [src] (\ref[src]) client [client] (\ref[client])"
	..()

/mob/new_player/Del()
	world.log << "/mob/new_player/Del(): [src] (\ref[src]) client [client] (\ref[client])"
	..()

/mob/new_player/Login()
	world.log << "/mob/new_player/Login(): [src] (\ref[src]) client [client] (\ref[client])"
	..()
