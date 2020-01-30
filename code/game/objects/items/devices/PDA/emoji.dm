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

/proc/parse_emoji(input_text)
	var/parsed = input_text
	for(var/emoji in emoji_list)
		parsed = replacetext(parsed, ":" + emoji + ":", "<img src='emoji-[emoji].png'>")
	return parsed