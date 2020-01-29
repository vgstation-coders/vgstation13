/proc/emoji_parse(text)
	. = text
	var/parsed = ""
	var/pos = 1
	var/search = 0
	var/emoji = ""
	var/tag = ""
	while(1)
		search = findtext(text, ":", pos)
		parsed += copytext(text, pos, search)
		if(search)
			pos = search
			search = findtext(text, ":", pos+1)
			if(search)
				emoji = "emoji-" + lowertext(copytext(text, pos+1, search)) + ".png"
				if(global.asset_cache.Find(emoji))
					tag = "<img src='[emoji]'>"
				if(tag)
					parsed += tag
					pos = search + 1
				else
					parsed += copytext(text, pos, search)
					pos = search
				emoji = ""
				continue
			else
				parsed += copytext(text, pos, search)
		break
	return parsed