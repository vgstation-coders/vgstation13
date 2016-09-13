#define ROD_RANGE = 1
#define TIME_TO_CATCH = 80

/obj/item/weapon/fishingrod
  name = "fishing rod"
  desc = "Go catch the big one!"
  icon = 'icons/obj/items.dmi'
  icon_state = "crowbar" //placeholder
  hitsound = "sound/weapons/toolhit.ogg" //placeholder
  flags = FPRINT
  siemens_coefficient = 1
  slot_flags = SLOT_BELT
  force = 3.0
  throwforce = 3.0
  throw_speed = 1
  throw_range = 5
  item_state = "crowbar"
  w_class = W_CLASS_MEDIUM
  starting_materials = list(MAT_GLASS = 100)
  w_type = RECYK_GLASS
  melt_temperature = MELTPOINT_GLASS
  origin_tech = Tc_ENGINEERING + "=1"
  attack_verb = list("smacks", "whacks", "whips", "belts", "lashes")
  var/busy = 0 //check if in use to stop bait scumming
  var/obj/item/weapon/hookeditem
  var/list/bait_types = list( // links types of bait to types of fish.  format is list(<bait>, <fish caught by bait>)
      list(/obj/item/weapon/reagent_containers/food/snacks/bait, /obj/item/weapon/reagent_containers/food/snacks/fish),
      )

/obj/item/weapon/fishingrod/suicide_act(mob/user)
  to_chat(viewers(user), "<span class='danger'>[user] is whipping \his head open with the [src.name]! It looks like \he took the bait!</span>")
  return(BRUTELOSS)

/obj/item/weapon/fishingrod/afterattack(var/atom/A, var/mob/user)
  if(!hookeditem || busy)
    return 1
  A = get_turf(A) //TODO: using water turf for now, will make bluespace pond that won't require turf check
  if(!A)
    return //clicked location is in nullspace
  if(!istype(A, /turf/simulated/floor/beach/water))
    return 1 //can't fish this turf
  //check bait type and roll fish caught
  if(istype(hookeditem, /obj/item/weapon/reagent_containers/food/snacks/bait))
    busy = 1
    to_chat(user, "<span class='notice'>You cast a line into the water.</span>")
    if(do_after(user, A, 160, 10, FALSE))
      var/list/bait_fish = find_bait(hookeditem)
      if(bait_fish) // if this is null, some cunt managed to get a non-bait item on the hook
        qdel(hookeditem)
        var/obj/fish_caught = bait_fish[2]
        hookeditem = new fish_caught()
        to_chat(user, "<span class='notice'>You caught a [hookeditem]!</span>")
    busy = 0
  return

/obj/item/weapon/fishingrod/attackby(obj/item/weapon/W, mob/user)
  ..()
  var/list/bait_fish = find_bait(W)
  if(bait_fish && hookeditem)
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
  for(var/BT in bait_types)
    if(istype(B, BT[1]))
      bait_link = BT
      return bait_link
  return 0

/obj/item/weapon/fishingrod/attack_self(var/mob/user)
  if(hookeditem && !busy)
    to_chat(user, "<span class='notice'>You remove the [hookeditem.name] from the [src.name].</span>")
    hookeditem.forceMove(user.loc)
    hookeditem = null

/obj/item/weapon/fishingrod/attack_hand(mob/user as mob)
  ..()
  if(hookeditem && !busy && user.get_active_hand() == null)
    to_chat(user, "<span class='notice'>You remove the [hookeditem.name] from the [src.name].</span>")
    hookeditem.forceMove(user.get_active_hand())
    hookeditem = null
