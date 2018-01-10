/* THIS FILE IS IN UTF-8. EDIT WITH NOTEPAD++ OR ATOM OR YOU WILL FUCK THE ENCODING. */
 /mob/living/silicon/robot/mommi/soviet
  prefix="Remont Robot" // Ремонт робот - Repair Robot
  desc = "This thing looks so Russian that you get the urge to wrestle bears and chug vodka."
  damage_control_network="Usherp" // ущерб - Contextual translation of "Damage Control"
  namepick_uses = 0 // Fuck individualism

// Ditto
/mob/living/silicon/robot/mommi/soviet/updatename()
  name = "[prefix] [num2text(ident)]"

// I SAID FUCK INDIVIDUALISM
/mob/living/silicon/robot/mommi/soviet/New(cell_type = "/obj/item/weapon/cell/potato")
  ..()
  pick_module("Soviet")
  add_static_overlays()
  UnlinkSelf()
