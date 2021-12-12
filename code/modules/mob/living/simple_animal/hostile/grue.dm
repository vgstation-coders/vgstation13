/mob/living/simple_animal/hostile/grue
	name = "grue"
	desc = "A dangerous thing that lives in the dark."
	icon = 'icons/mob/grue.dmi'
	icon_state = "grue_living"
	icon_living = "grue_living"
	icon_dead = "grue_dead"
	health = 100
	melee_damage_lower = 10
	melee_damage_upper = 15
	melee_damage_type = BRUTE
	response_help  = "touches"
	response_disarm = "pushes"
	response_harm   = "punches"
	attacktext = list("gnashes","slashes")
	attack_sound = 'sound/weapons/cbar_hitbod1.ogg'
	speed = 1
	can_butcher = FALSE
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/grue
	held_items = list()

    //VARS
    var/shadowpower = 0                                             //shadow power absorbed
    var/maxshadowpower = 1000                                       //max shadowpower
	var/maxHealth = 100                                             //max health

    var/current_brightness = 0                                       //light level of current tile
    var/bright_limit_health_gain                                    //maximum brightness on tile for health regen
    var/bright_limit_health_drain                                   //maximum brightness on tile to not drain health
    var/bright_limit_power_gain                                     //maximum brightness on tile to absorb shadow power
    var/bright_limit_power_drain                                    //maximum brightness on tile to not drain shadow power

    var/dark_power_gain = 5                                         //power gained per tick when in dark tile
    var/light_power_drain = 10                                      //shadow power drained per tick on bright tile
    var/dark_health_gain = 5                                        //health gained per tick when on dark tile
    var/light_health_drain = 15                                     //health drained per tick on bright tile
    var/show_desc = FALSE                                           //For the ability menu

    var/lifestage=1                                                 //1=baby grue, 2=grueling, 3=(mature) grue
    var/eatencount=0                                                //number of sentient carbons eaten, makes the grue more powerful


/mob/living/simple_animal/hostile/grue/Life()
	if(timestopped)
		return 0 //under effects of time magick
	..()


    //process shadow power and health according to current tile brightness level  
      
	if(isturf(loc))
		var/turf/T = loc
        if (istype(loc, /turf/space))
            current_brightness=bright_limit_health_drain+1 //harmed by starlight
        else
            current_brightness=T.get_lumcount()
    else                                                //else, there's considered to be no light
        current_brightness=0;

    if(current_brightness<=bright_limit_health_gain)
        health = min(maxHealth,health+dark_health_gain)                     //heal in dark
    else if(current_brightness>bright_limit_health_drain)
        health -= light_health_drain                                        //lose health in light
    if(current_brightness<=bright_limit_power_gain)
        shadowpower = min(maxshadowpower,shadowpower+dark_power_gain)       //gain power in dark
    else if(current_brightness>bright_limit_power_drain)
        shadowpower = max(0,shadowpower-light_power_drain)                  //drain power in light

/obj/item/candle
	name = "red candle"
	desc = "A candle made out of wax, used for moody lighting and solar flares."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle"
	item_state = "candle1"
	w_class = W_CLASS_TINY
	heat_production = 1000
	source_temperature = TEMPERATURE_FLAME
	light_color = LIGHT_COLOR_FIRE

	var/wax = 200
	var/lit = 0
	var/flavor_text

//Cast darkness onto a tile that gradually dissipates
/mob/living/simple_animal/hostile/grue/proc/nullify_light()
	set name = "Nullify light"
	set desc = "Darken the surrounding space."
	set category = "Grue"
    var/turf/T = get_turf(src)
	if(stat == UNCONSCIOUS)
		to_chat(src, "<span class='warning'>You cannot do that while unconscious.</span>")
		return

	if(stat)
		to_chat(src, "You cannot do that in your current state.")
		return

    to_chat(src,"<span class='notice'>You darken the area.</span>")
    playsound(T, 'sound/effects/nulllight.ogg', 50, 1)
    var/obj/item/weapon/reagent_containers/food/snacks/borer_egg/E = new (T) //create invisible object that emits darkness





