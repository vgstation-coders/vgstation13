/mob/living/carbon/alien/verb/ventcrawl() // -- TLE
	set name = "Crawl Through Vent (Alien)"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Alien"
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)
