/**
 * # Story Ruin
 *
 * A map element/ruin that supports story theming.
 * The 'theme' var is a bitfield of STORY_* flags indicating which themes
 * are compatible with this ruin.
 */
/datum/map_element/ruin/story
	var/theme = STORY_NT // Bitfield of compatible STORY_* theme flags
	var/datum/story_theme/assigned_theme // The assigned story theme datum (set when placed)
	var/story_year = 0
	var/list/loot_containers = list() // Types of containers to spawn loot in

/datum/map_element/ruin/story/bunker
	name = "bunker"
	file_path = "maps/ruins/story/bunker.dmm"
	theme = STORY_COMMANDO|STORY_SYNDICATE|STORY_NINJA|STORY_GREY|STORY_VOX
	loot_containers = list(
		/obj/structure/closet/crate,
		/obj/structure/closet/syndicate
	)

/datum/map_element/ruin/story/cabin
	name = "cabin"
	file_path = "maps/ruins/story/cabin.dmm"
	theme = STORY_NT|STORY_WIZARD|STORY_NINJA|STORY_CLOWN|STORY_GREY
	loot_containers = list(
		/obj/structure/closet/crate
	)

/datum/map_element/ruin/story/camp
	name = "camp"
	file_path = "maps/ruins/story/camp.dmm"
	theme = STORY_NT|STORY_WIZARD|STORY_NINJA|STORY_CLOWN|STORY_GREY|STORY_VOX|STORY_SYNDICATE
	loot_containers = list(
		/obj/structure/closet/crate
	)

/datum/map_element/ruin/story/hoarder
	name = "hoarder den"
	file_path = "maps/ruins/story/hoarder.dmm"
	theme = STORY_VOX
	loot_containers = list(
		/obj/structure/closet/crate
	)

/datum/map_element/ruin/story/listening_post
	name = "listening post"
	file_path = "maps/ruins/story/listening_post.dmm"
	theme = STORY_COMMANDO|STORY_SYNDICATE
	loot_containers = list(
		/obj/structure/closet/crate,
		/obj/structure/closet/syndicate
	)

/datum/map_element/ruin/story/ufo
	name = "ufo"
	file_path = "maps/ruins/story/ufo.dmm"
	theme = STORY_GREY
	loot_containers = list(
		/obj/structure/closet/ayy,
		/obj/structure/closet/ayy2,
		/obj/structure/closet/ayy3
	)

/datum/map_element/ruin/story/workshop
	name = "workshop"
	file_path = "maps/ruins/story/workshop.dmm"
	theme = STORY_NT|STORY_VOX|STORY_SYNDICATE
	loot_containers = list(
		/obj/structure/closet/crate
	)

/datum/map_element/ruin/story/shrine
	name = "shrine"
	file_path = "maps/ruins/story/shrine.dmm"
	theme = STORY_WIZARD|STORY_NINJA
	loot_containers = list(
		/obj/structure/closet/crate
	)

/datum/map_element/ruin/story/greenhouse
	name = "greenhouse"
	file_path = "maps/ruins/story/greenhouse.dmm"
	theme = STORY_NT|STORY_CLOWN|STORY_VOX
	loot_containers = list(
		/obj/structure/closet/crate
	)
