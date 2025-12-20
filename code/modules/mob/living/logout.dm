/mob/living/Logout()
	..()
	if (mind)
		if(!key)	//key and mind have become seperated.
			mind.active = 0	//This is to stop say, a mind.transfer_to call on a corpse causing a ghost to re-enter its body.

	unregister_event(/event/z_transition, src, nameof(src::OnMobZChanged()))
	// Notify SSmob to check if this z-level still has players
	SSmob.z_pause_check(src,null,z)
