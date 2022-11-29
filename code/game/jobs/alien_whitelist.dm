// ckey = list("species", "species")
var/global/list/alien_whitelist[] = list()

/proc/load_alienwhitelist()
	alien_whitelist = list()
	var/text = file2text("config/alienwhitelist.txt")
	if (!text)
		diary << "Failed to load config/alienwhitelist.txt\n"
	else
		for(var/line in splittext(text, "\n"))
			if(dd_hasprefix(line,"#"))
				continue
			if(!findtext(line,"-"))
				continue
			var/list/parts=splittext(line,"-")
			var/ckey=trim(lowertext(parts[1]))
			var/specieslist=splittext(parts[2],",")
			for(var/species in specieslist)
				species = trim(species)
				alien_whitelist[ckey] += list(species)

/proc/get_player_whitelist(var/ckey)
	return alien_whitelist[ckey]

/proc/check_player_whitelist(var/ckey, var/chosen_species)
	if(!config.usealienwhitelist)
		return
	if(!(alien_whitelist && alien_whitelist[ckey]))
		return 0
	var/list/species = alien_whitelist[ckey]
	if(chosen_species in species)
		return 1 