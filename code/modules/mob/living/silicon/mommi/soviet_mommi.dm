/* THIS FILE IS IN UTF-8. EDIT WITH NOTEPAD++ OR ATOM OR YOU WILL FUCK THE ENCODING. */
 /mob/living/silicon/robot/mommi/soviet
  prefix="Remont Robot" // Ремонт робот - Repair Robot
  damage_control_network="Usherp" // ущерб - Contextual translation of "Damage Control"
  desc = "This thing looks so Russian that you get the urge to wrestle bears and chug vodka."

// Fuck individualism
/mob/living/silicon/robot/mommi/soviet/updatename(var/oldprefix as text)
  real_name = "[prefix] [num2text(ident)]"
  name = real_name

// Ditto
/mob/living/silicon/robot/mommi/soviet/Namepick()
  return FALSE

// I SAID FUCK INDIVIDUALISM
/mob/living/silicon/robot/mommi/soviet/New(cell_type="/obj/item/weapon/cell/potato")
  ..()
  pick_module("Soviet")
  add_static_overlays()
  UnlinkSelf()
