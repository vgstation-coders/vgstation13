/mob/living/simple_animal/hostile/bear/panther
	name="Panther"
	desc="That's a big kitty!"
	icon_gib=null
	icon_living="panther"
	speak = list("HISS!","Hiss!","GRR!","Growl!")
	speak_emote = list("growls", "roars","hisses")
	emote_hear = list("rawrs","grumbles","grawls","hisses")
	icon_dead="panther_dead"
	icon_state="panther"
	faction = "jungle"
	default_icon_floor="panther"
	default_icon_space="panther"
	failed_geometry_class=TRUE
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/animal 
	hates_fast_food=TRUE // likes fish.

/mob/living/simple_animal/hostile/bear/panther/get_butchering_products()
	return list(/datum/butchering_product/teeth/lots)

/mob/living/simple_animal/hostile/bear/panther/isValidTarget(var/atom/A)
	if(istype(A,/mob/living/simple_animal/cat) && !istype(A,/mob/living/simple_animal/cat/snek)) //won't attack fellow cats (like salem or runtime).
		return FALSE