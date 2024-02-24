//bounce between walls. penetrate. deal 1 damage. POP! like a balloon when projectile dies. die after 10 hits or 20 seconds. whichever comes first.

/obj/item/projectile/bullet/midbullet/bouncebullet/bouncy_ball
	name = "bouncy ball shot"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "ball_pixel"
	damage = 0
	stun = 0
	weaken = 0
	bounces = -1
	agony = 1
	penetration = 0
	bounce_type = PROJREACT_WALLS|PROJREACT_WINDOWS

