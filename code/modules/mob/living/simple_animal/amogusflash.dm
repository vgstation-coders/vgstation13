/mob/living/simple_animal/amogusflash
	name = "flash"
	desc = "Recent advances in Nanotrasen robotics technology have allowed command's favourite toy to walk among us."
	icon_state = "amogusflash"
	health = 30
	maxHealth = 30
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	size = SIZE_TINY
	speak_emote = list("chimes", "states")
	pass_flags = PASSTABLE | PASSMOB

/mob/living/simple_animal/amogusflash/New()
	..()
	add_spell(new /spell/targeted/amogus_piercer)
	add_spell(new /spell/targeted/amogus_flasher)

/mob/living/simple_animal/amogusflash/can_ventcrawl()
	return TRUE

/mob/living/simple_animal/amogusflash/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Object"
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)


/mob/living/simple_animal/amogusflash/death()
	visible_message("<span class = 'warning'>\The [src] breaks apart.</span>")
	spark(src)
	new /obj/effect/decal/cleanable/blood/oil(src.loc)
	qdel(src)
	..(TRUE)