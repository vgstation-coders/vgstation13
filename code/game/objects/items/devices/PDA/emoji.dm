/var/list/emoji_list = list(
	"happy",
	"sad",
	"angry",
	"confused",
	"pensive",
	"rolling_eyes",
	"noface",
	"joy",
	"gun",
	"ok_hand",
	"middle_finger",
	"thinking",
	"thumbs_up",
	"thumbs_down",
	"rocket_ship",
	"tada",
	"heart",
	"carp",
	"clown",
	"prohibited",
	"sunglasses"
)

/proc/parse_emoji(input_text, var/ooc_mode = FALSE)
	var/parsed = input_text
	for(var/emoji in emoji_list)
		parsed = replacetext(parsed, ":" + emoji + ":", "<img src='emoji-[emoji].png'>")

	if(ooc_mode)
		//entering cursed regex zone
		var/regex/emoji_path_regex = new(@"(:(/[^:]*):)")
		while(emoji_path_regex.Find(parsed))
			parsed = emoji_path_regex.Replace(parsed, /proc/validate_emoji_path)

	return parsed

/proc/validate_emoji_path(match, group1, group2)
	var/emoji_path = text2path(group2)
	if(ispath(emoji_path, /atom))
		var/atom/emoji_atom = emoji_path
		return bicon(icon(initial(emoji_atom.icon), initial(emoji_atom.icon_state)))
