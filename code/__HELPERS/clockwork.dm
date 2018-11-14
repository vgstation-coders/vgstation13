#define CLOCKWORK_GENERIC_GLOW "clockwork_generic_glow"
#define CLOCKWORK_DOOR_GLOW "clockwork_door_glow"
#define BRASS_WINDOOR_GLOW "clockwork_windoor_glow"
#define BRASS_WINDOW_GLOW "clockwork_window_glow_s"
#define BRASS_FULL_WINDOW_GLOW "clockwork_window_glow"
#define REPLICANT_GRILLE_GLOW "clockwork_grille_glow"
#define BROKEN_REPLICANT_GRILLE_GLOW "clockwork_broken_grille_glow"


#define GENERIC_CLOCKWORK_CONVERSION(A, B, C)\
	if(A.invisibility != INVISIBILITY_MAXIMUM){\
		A.invisibility = INVISIBILITY_MAXIMUM;\
		var/atom/movable/D = new B(A.loc);\
		if(!A.gcDestroyed){\
			D.dir = A.dir;\
			qdel(A);\
        };\
		anim(target = D, a_icon = 'icons/effects/effects.dmi', a_icon_state = C, direction = D.dir, sleeptime = 1 SECONDS);\
	}