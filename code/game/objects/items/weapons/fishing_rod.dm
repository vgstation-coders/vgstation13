#define TIME_TO_CATCH = 80

// -----------------------------
//         Bait Datums
// -----------------------------

// Base datum for bait_type
// bait: The object to be used as bait
// fish: list of fish you can catch and their probability
//       uses the format list(list(<fish>, <absolute probability>), ...)
//       NOTE: The fishing rod checks the fish in order.  Don't put a probability 100 fish before the last entry.
/datum/bait_type
  var/bait = null
  var/list/fish = list()

/datum/bait_type/standard_bait
  bait = /obj/item/weapon/reagent_containers/food/snacks/bait
  fish = list(
      list(/obj/item/weapon/reagent_containers/food/snacks/fish, 100)
      )

/datum/bait_type/clown
  bait = /obj/item/clothing/mask/gas/clown_hat
  fish = list(
    list(/obj/item/weapon/reagent_containers/food/snacks/fish/clown, 100)
    )

// -----------------------------
//         Fishing Rod
// -----------------------------

/obj/item/weapon/fishingrod
  name = "fishing rod"
  desc = "Go catch the big one!"
  icon = 'icons/obj/items.dmi'
  icon_state = "crowbar" //placeholder
  item_state = "crowbar" //placeholder
  hitsound = "sound/weapons/toolhit.ogg" //placeholder
  flags = FPRINT
  siemens_coefficient = 1
  slot_flags = SLOT_BELT
  force = 3.0
  throwforce = 3.0
  throw_speed = 1
  throw_range = 5
  w_class = W_CLASS_MEDIUM
  starting_materials = list(MAT_GLASS = 100)
  w_type = RECYK_GLASS
  melt_temperature = MELTPOINT_GLASS
  origin_tech = Tc_ENGINEERING + "=1"
  attack_verb = list("smacks", "whacks", "whips", "belts", "lashes")
  var/busy = 0 //check if in use to stop bait scumming
  var/obj/item/weapon/hookeditem
  var/list/fishables = list( //list of atoms that can be fished
      /obj/machinery/bluespace_pond,
      /turf/unsimulated/beach/water/deep,
      )
  var/list/bait_types = list( // The types of bait this rod is able to use
      /datum/bait_type/standard_bait,
      /datum/bait_type/clown,
      )

/obj/item/weapon/fishingrod/suicide_act(mob/user)
  to_chat(viewers(user), "<span class='danger'>[user] is whipping \his head open with the [src.name]! It looks like \he took the bait!</span>")
  return(BRUTELOSS)

/obj/item/weapon/fishingrod/afterattack(var/atom/A, var/mob/user)
  if(!hookeditem || busy)
    return 1
  var/turf/turf_test = get_turf(A)
  if(!turf_test)
    return 1 // item is in nullspace
  var/can_fish = FALSE
  for(var/F in fishables)
    if(istype(A, F))
      can_fish = TRUE
      break
  if(!can_fish)
    return 1
  var/datum/bait_type/bait_fish = find_bait(hookeditem)
  if(bait_fish)
    busy = 1
    to_chat(user, "<span class='notice'>You cast a line into the water.</span>")
    if(do_after(user, A, 160, 10, FALSE)) // must be able to drink beer while fishing
      qdel(hookeditem)
      var/obj/fish_caught = 0
      for(var/list/fish_type in bait_fish.fish)
        if(prob(fish_type[2]))
          fish_caught = fish_type[1]
          hookeditem = new fish_caught()
          to_chat(user, "<span class='notice'>You caught a [hookeditem.name]!</span>")
      if(!fish_caught)
        to_chat(user, "<span class='notice'>The fish took your bait!</span>")
    busy = 0
  else
    to_chat(user, "<span class='notice'>You cannot use [hookeditem.name] as bait.</span>")

/obj/item/weapon/fishingrod/attackby(obj/item/W, mob/user)
  ..()
  var/datum/bait_type/bait_fish = find_bait(W)
  if(bait_fish)
    if(hookeditem)
      if(user.drop_item(W, src))
        var/obj/item/weapon/oldbait = hookeditem
        hookeditem = W
        to_chat(user, "<span class='notice'>You swap the bait on the [src.name].</span>")
        user.put_in_hands(oldbait)
        return
    else
      if(user.drop_item(W, src))
        hookeditem = W
        to_chat(user, "<span class='notice'>You bait the [src.name] with the [W.name].</span>")
        return
  to_chat(user, "<span class='notice'>You cannot bait the [src.name] with the [W.name].</span>")

// checks if object B is a valid type of bait and returns a list with the bait-fish link or 0 if invalid bait
/obj/item/weapon/fishingrod/proc/find_bait(var/obj/item/weapon/B)
  var/list/bait_link
  for(var/typepath in bait_types)
    var/datum/bait_type/BT = new typepath()
    if(istype(B, BT.bait))
      bait_link = BT
      return bait_link
  return 0

/obj/item/weapon/fishingrod/attack_self(var/mob/user)
  if(hookeditem && !busy)
    to_chat(user, "<span class='notice'>You remove the [hookeditem.name] from the [src.name].</span>")
    hookeditem.forceMove(user.loc)
    hookeditem = null
/*
/obj/item/weapon/fishingrod/attack_hand(mob/user as mob)
  if(hookeditem && !busy && user.get_active_hand() == null)
    to_chat(user, "<span class='notice'>You remove the [hookeditem.name] from the [src.name].</span>")
    hookeditem.forceMove(user)
    hookeditem = null
  else
    ..()
*/
