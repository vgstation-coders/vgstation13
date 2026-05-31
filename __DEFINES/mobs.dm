#define EYECHECK_NO_PROTECTION 0
#define EYECHECK_PARTIAL_PROTECTION 1
#define EYECHECK_FULL_PROTECTION 2

//Values for the m_intent variable
#define M_INTENT_RUN "run"
#define M_INTENT_WALK "walk"

//Mob species flags (simple stuff mostly for simple_animals)
#define MOB_UNDEAD  1 //zombies, ghosts, skeletons
#define MOB_ROBOTIC 2 //robots
#define MOB_CONSTRUCT 4 //golems, animated armor, animated whatever (not mimics though)
#define MOB_SWARM 8 //swarm of mobs!
#define MOB_HOLOGRAPHIC 16 //holocarps
#define MOB_SUPERNATURAL 32
#define MOB_NO_PETRIFY 64 //can't get petrified
#define MOB_NO_LAZ 128 //Can not be revived via lazarus injector

#define NO_BACKPACK 1
#define BACKPACK 2
#define SATCHEL_NORM 3
#define SATCHEL_ALT 4
#define MESSENGER_BAG 5

#define NO_BACKPACK_STRING "1"
#define BACKPACK_STRING "2"
#define SATCHEL_NORM_STRING "3"
#define SATCHEL_ALT_STRING "4"
#define MESSENGER_BAG_STRING "5"

#define SHOW_HELD_ITEM_AND_POINTING_DELAY 0.7 SECONDS

#define VOXGREEN 1
#define VOXBROWN 2
#define VOXGRAY 3
#define VOXLGREEN 4
#define VOXAZURE 5
#define VOXEMERALD 6
#define VOXPLUCKED 7

#define GREYGRAY 1
#define GREYLIGHT 2
#define GREYGREEN 3
#define GREYBLUE 4

#define CATBEASTBROWN 1
#define CATBEASTBLACK 2

#define CONFUSED_MAGIC 1

#define SLIME_BABY 1
#define SLIME_ADULT 2

#define MONKEY_ANIM_TIME 22

//COMPLEX ANIMAL STUFF

#define ANIMAL_BEHAVIOR_PREDATORY	(1<<0)	//if we will attack other mobs
#define ANIMAL_BEHAVIOR_TERRITORIAL	(1<<1)	//if we attack when approached
#define ANIMAL_BEHAVIOR_PACK_DYNAMICS	(1<<2)	//if we stay by others of our kind
#define ANIMAL_BEHAVIOR_AVOID_PRED	(1<<3)	//avoid predatory animals, not counting our own kind, of course.
#define ANIMAL_BEHAVIOR_RETALIATE	(1<<4)	//if we are attacked, we fight back.
#define ANIMAL_BEHAVIOR_DESTRUCTIVE	(1<<5)	//destroy objects in the environment. you'll probably want big bad animals to have this flag (eg, bears)
#define ANIMAL_BEHAVIOR_AVOID_CAPTURE	(1<<6) //try to escape containment (lockers, chairs). also see above.
#define ANIMAL_BEHAVIOR_UNDESIRABLE	(1<<7) //if predators should avoid us for whatever reason. not a hard stance, but it'll tilt the scale. eg, a creature which is poisonous.

#define ANIMAL_HERBIVORE	(1<<0)	//we can eat plants
#define ANIMAL_CARNIVORE	(1<<1)	//we can eat meat. combine with ANIMAL_HERBIVORE for an omnivore. you also need ANIMAL_BEHAVIOR_PREDATORY if you want it to hunt, otherwise it's just an opportunistic carnivore.
#define ANIMAL_FRUGIVORE	(1<<2 ) //fruits (jungle berry bushes). implied with HERBIVORE, but can be used on its own.

#define ANIMAL_FLAG_NEVER_STARVE	(1<<0)
#define ANIMAL_FLAG_NEVER_AGE	(1<<1)
#define ANIMAL_FLAG_NEVER_ROT	(1<<2)
#define ANIMAL_FLAG_IMMORTAL	ANIMAL_FLAG_NEVER_STARVE | ANIMAL_FLAG_NEVER_AGE

#define ANIMAL_FOODPRIORITY_CANNIBAL -5	//she rips out my bones just like i'm an animal
#define ANIMAL_FOODPRIORITY_PRECOOKED 5	//why would you eat a plant when you could eat a tasty donut or burger?
#define ANIMAL_FOODPRIORITY_PLANTS 1	//omnivores prefer not picking a fight. mildly, because we still want some action
#define ANIMAL_FOODPRIORITY_CORPSES 3	//no need to beat a dead horse. we should be eating it instead.
#define ANIMAL_FOODPRIORITY_SIZEDIFF_LARGER -4	//bigger=more dangerous, right?
#define ANIMAL_FOODPRIORITY_SIZEDIFF_SMALLER -2	//prefer bigger meals
#define ANIMAL_FOODPRIORITY_FAMILY -5	//hi ma :)
#define ANIMAL_FOODPRIORITY_UNDESIRABLE -5	//poison... poison... tasty fish!

#define ANIMAL_STATE_IDLE 0	//hanging around.
#define ANIMAL_STATE_HUNTING 1	//when we hongry
#define ANIMAL_STATE_DEFENDING 2	//from territorial
#define ANIMAL_STATE_ATTACKING 3	//from retaliation
#define ANIMAL_STATE_FLEEING 4	//oh SHIT
#define ANIMAL_STATE_MATING 5	//the birds and the birds. why would they try it with a bee? you sicken me.
#define ANIMAL_STATE_SPECIAL 6 //for special behaviors for the mob to do
