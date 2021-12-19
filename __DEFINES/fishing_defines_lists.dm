

//Bait types//////

var/list/bait_Food = list()

var/list/bait_Mob = list(
	/obj/item/weapon/holder/diona,
	/obj/item/weapon/holder/animal,
	/obj/item/weapon/holder/animal/mouse,
	/obj/item/weapon/holder/animal/corgi,
	/obj/item/weapon/holder/animal/carp,
	/obj/item/weapon/holder/animal/cat,
	/obj/item/weapon/holder/animal/frog,
	/obj/item/weapon/holder/animal/snail,
	/obj/item/weapon/holder/animal/snek,
	/obj/item/weapon/holder/animal/slime,
	/obj/item/weapon/holder/animal/pillow
)

var/list/bait_Tech = list()

var/list/bait_Special = list()



//Z level catch lists//////
var/list/stationZFish = list(
	/mob/living/simple_animal/hostile/carp,
)

var/list/centcommZFish = list()

var/list/telecommZFish = list(
	/mob/living/simple_animal/hostile/carp,
)

var/list/derelictZFish = list(
	/mob/living/simple_animal/hostile/carp,
)

var/list/asteroidZFish = list(
	/mob/living/simple_animal/hostile/carp,
)

var/list/spacepirateZFish = list(
	/mob/living/simple_animal/hostile/carp,
)


//Bait catch lists//////
var/list/catchList_Meat = list(
	/mob/living/simple_animal/hostile/carp,
)

var/list/catchList_Magnet = list(
	/obj/item/weapon/disk/tech_disk/random,
	/obj/item/weapon/disk/shuttle_coords/vault/biodome,
	/obj/item/weapon/disk/shuttle_coords/vault/research,
	/obj/item/weapon/disk/shuttle_coords/vault/ironchef,

)

var/list/catchList_Mob = list(
	/mob/living/simple_animal/hostile/carp,
)

var/list/catchList_Special = list(

)


//Rarity catch lists//////
var/list/catchList_Common = list()

var/list/catchList_Uncommon = list()

var/list/catchList_Rare = list()

var/list/catchList_SuperRare = list()


//One time catch//////
var/list/oneTimeCatch = list()


//Lists for mob use///////////////////

//Rainbow trout//////
var/global/list/rainbowChems = chemical_reagents_list - list(
	/datum/reagent/adminordrazine,
	/datum/reagent/blockizine,
	/datum/reagent/nanites,
	/datum/reagent/nanites/autist,
	/datum/reagent/xenomicrobes,
	/datum/reagent/paismoke
	)

//Meel///////
var/global/list/meelMeats = existing_typesof(/obj/item/weapon/reagent_containers/food/snacks/meat) - list(/obj/item/weapon/reagent_containers/food/snacks/meat/wendigo, /obj/item/weapon/reagent_containers/food/snacks/meat/gingerbroodmother)


//Fermurtle//////
var/global/list/fermentableJuice = list(		//This one might actually be useful outside of fishing, too bad I have no idea what I'm talking about
	POTATO = list(VODKA),
	TOMATOJUICE = list(BLOODYMARY),
	GRAPEJUICE = list(WINE),
	GGRAPEJUICE = list(WWINE),
	BERRYJUICE = list(BWINE),
	APPLEJUICE  = list(FIREBALLCIDER),
	POISONBERRYJUICE = list(PWINE),
	PLUMPHJUICE	= list(PLUMPHWINE),
	SUGAR = list(RUM), //I guess?
	FLOUR = list(BEER),
	RICE = list(SAKE),
)
