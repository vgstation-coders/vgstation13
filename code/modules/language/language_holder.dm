/datum/language_holder
	var/list/languages = list(/datum/language/common)
	var/list/shadow_languages = list()
	var/only_speaks_language = null
	var/selected_default_language = null
	var/datum/language_menu/language_menu

	var/omnitongue = FALSE
	var/owner

/datum/language_holder/New(owner)
	src.owner = owner

	languages = typecacheof(languages)
	shadow_languages = typecacheof(shadow_languages)

/datum/language_holder/Destroy()
	owner = null
	QDEL_NULL(language_menu)
	languages.Cut()
	shadow_languages.Cut()
	return ..()

/datum/language_holder/proc/copy(newowner)
	var/datum/language_holder/copy = new(newowner)
	copy.languages = src.languages.Copy()
	// shadow languages are not copied.
	copy.only_speaks_language = src.only_speaks_language
	copy.selected_default_language = src.selected_default_language
	// language menu is not copied, that's tied to the holder.
	copy.omnitongue = src.omnitongue
	return copy

/datum/language_holder/proc/grant_language(datum/language/dt, shadow = FALSE)
	if(shadow)
		shadow_languages[dt] = TRUE
	else
		languages[dt] = TRUE

/datum/language_holder/proc/grant_all_languages(omnitongue=FALSE)
	for(var/la in GLOB.all_languages)
		grant_language(la)

	if(omnitongue)
		src.omnitongue = TRUE

/datum/language_holder/proc/get_random_understood_language()
	var/list/possible = list()
	for(var/dt in languages)
		possible += dt
	. = safepick(possible)

/datum/language_holder/proc/remove_language(datum/language/dt, shadow = FALSE)
	if(shadow)
		shadow_languages -= dt
	else
		languages -= dt

/datum/language_holder/proc/remove_all_languages()
	languages.Cut()

/datum/language_holder/proc/has_language(datum/language/dt)
	if(is_type_in_typecache(dt, languages))
		return LANGUAGE_KNOWN
	else
		var/atom/movable/AM = get_atom()
		var/datum/language_holder/L = AM.get_language_holder(shadow=FALSE)
		if(L != src)
			if(is_type_in_typecache(dt, L.shadow_languages))
				return LANGUAGE_SHADOWED
	return FALSE

/datum/language_holder/proc/copy_known_languages_from(thing, replace=FALSE)
	var/datum/language_holder/other
	if(istype(thing, /datum/language_holder))
		other = thing
	else if(ismovableatom(thing))
		var/atom/movable/AM = thing
		other = AM.get_language_holder()
	else if(istype(thing, /datum/mind))
		var/datum/mind/M = thing
		other = M.get_language_holder()

	if(replace)
		src.remove_all_languages()

	for(var/l in other.languages)
		src.grant_language(l)


/datum/language_holder/proc/open_language_menu(mob/user)
	if(!language_menu)
		language_menu = new(src)
	language_menu.ui_interact(user)

/datum/language_holder/proc/get_atom()
	if(ismovableatom(owner))
		. = owner
	else if(istype(owner, /datum/mind))
		var/datum/mind/M = owner
		if(M.current)
			. = M.current

/datum/language_holder/alien
	languages = list(/datum/language/xenocommon)

/datum/language_holder/monkey
	languages = list(/datum/language/monkey)

/datum/language_holder/swarmer
	languages = list(/datum/language/swarmer)

/datum/language_holder/clockmob
	languages = list(/datum/language/common, /datum/language/ratvar)
	only_speaks_language = /datum/language/ratvar

/datum/language_holder/construct
	languages = list(/datum/language/common, /datum/language/narsie)

/datum/language_holder/drone
	languages = list(/datum/language/common, /datum/language/drone, /datum/language/machine)
	only_speaks_language = /datum/language/drone

/datum/language_holder/drone/syndicate
	only_speaks_language = null

/datum/language_holder/slime
	languages = list(/datum/language/common, /datum/language/slime)
	only_speaks_language = /datum/language/slime

/datum/language_holder/lightbringer
	// TODO change to a lightbringer specific sign language
	languages = list(/datum/language/slime)

/datum/language_holder/synthetic
	languages = list(/datum/language/common)
	shadow_languages = list(/datum/language/common, /datum/language/machine, /datum/language/draconic)

/datum/language_holder/empty
	languages = list()
	shadow_languages = list()

/datum/language_holder/universal/New()
	..()
	grant_all_languages(omnitongue=TRUE)
