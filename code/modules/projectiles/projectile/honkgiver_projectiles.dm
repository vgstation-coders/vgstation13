/obj/item/projectile/ricochet/bouncy_ball
	name = "bouncy ball shot"
	damage_type = HALLOSS
	flag = "laser"
	kill_count = 100//?
	layer = PROJECTILE_LAYER
	damage = 1
	//icon = 'icons/obj/projectiles_experimental.dmi'
	//icon_state = "ricochet_head"
	//animate_movement = 0
	//linear_movement = 0
	custom_impact = 1
	pos_from = EAST	//which side of the turf is the shot coming from
	pos_to = SOUTH	//which side of the turf is the shot heading to
	bouncin = 0
	var/countdown_to_delete = //10?20?


	//list of objects that'll stop the shot, and apply bullet_act
		ricochet_bump = list(
		/obj/effect/blob,
		/obj/machinery/turret,
		/obj/machinery/turretcover,
		/obj/mecha,
		/obj/structure/reagent_dispensers,
		/obj/structure/bed/chair/vehicle,
		)
