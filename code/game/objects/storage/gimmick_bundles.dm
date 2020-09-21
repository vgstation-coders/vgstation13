//THIS IS A SAFE AND INCLUSIVE SPACE FOR HONKERS.
//I AM SENSITIVE AND SUPPORTIVE OF HONKERS AND THEIR ALLIES.

/obj/item/storage/box/nt_disguise_kit
   name = "\improper Nanotrasen disguise kit"
   desc = "This box contains the tools required to go undercover. Fully studied, tested and approved by Nanotrasen."
   icon = 'icons/obj/storage/smallboxes.dmi'
   icon_state = "nt"

/obj/item/storage/box/nt_disguise_kit/New()
   ..()
   new /obj/item/card/id/nt_disguise(src)
   new /obj/item/clothing/mask/gas/voice/detective(src)
   new /obj/item/pocket_mirror/comb(src)
