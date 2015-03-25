/obj/machinery/vending/autodrobe
	name = "\improper AutoDrobe"
	desc = "A vending machine for costumes."
	icon_state = "theater"
	icon_deny = "theater-deny"
	req_access = list(access_theatre)
	product_slogans = "Dress for success!;Suited and booted!;It's show time!;Why leave style up to fate? Use AutoDrobe!"
	vend_delay = 15
	vend_reply = "Thank you for using AutoDrobe!"
	products = list(/obj/item/clothing/suit/chickensuit = 3,/obj/item/clothing/head/chicken = 3,/obj/item/clothing/suit/monkeysuit = 3,/obj/item/clothing/mask/gas/monkeymask = 3,/obj/item/clothing/suit/xenos = 3,/obj/item/clothing/head/xenos = 3,/obj/item/clothing/under/gladiator = 3,
					/obj/item/clothing/head/helmet/gladiator = 3,/obj/item/clothing/under/gimmick/rank/captain/suit = 3,/obj/item/clothing/head/flatcap = 3,/obj/item/clothing/glasses/gglasses = 3,/obj/item/clothing/shoes/jackboots = 3,
					/obj/item/clothing/under/schoolgirl = 3,/obj/item/clothing/shoes/kneesocks = 3,/obj/item/clothing/head/kitty = 3,/obj/item/clothing/under/blackskirt = 3,/obj/item/clothing/head/beret = 3,/obj/item/clothing/suit/hastur = 3,/obj/item/clothing/head/hasturhood = 3,
					/obj/item/clothing/suit/wcoat = 3,/obj/item/clothing/under/suit_jacket = 3,/obj/item/clothing/head/that = 3,/obj/item/clothing/head/cueball = 3,
					/obj/item/clothing/under/scratch = 3,/obj/item/clothing/under/kilt = 3,/obj/item/clothing/head/beret = 3,/obj/item/clothing/suit/wcoat = 3,
					/obj/item/clothing/glasses/monocle =3,/obj/item/clothing/head/bowlerhat = 3,/obj/item/weapon/cane = 3,/obj/item/clothing/under/sl_suit = 3,
					/obj/item/clothing/mask/fakemoustache = 3,/obj/item/clothing/suit/bio_suit/plaguedoctorsuit = 3,/obj/item/clothing/head/plaguedoctorhat = 3,/obj/item/clothing/mask/gas/plaguedoctor = 3,
					/obj/item/clothing/under/owl = 3,/obj/item/clothing/mask/gas/owl_mask = 3,/obj/item/clothing/suit/apron = 3,/obj/item/clothing/under/waiter = 3,
					/obj/item/clothing/under/pirate = 3,/obj/item/clothing/suit/pirate = 3,/obj/item/clothing/head/pirate = 3,/obj/item/clothing/head/bandana = 3,
					/obj/item/clothing/head/bandana = 3,/obj/item/clothing/under/soviet = 3,/obj/item/clothing/head/ushanka = 3,/obj/item/clothing/suit/imperium_monk = 3,
					/obj/item/clothing/mask/gas/cyborg = 3,/obj/item/clothing/suit/holidaypriest = 3,/obj/item/clothing/head/wizard/marisa/fake = 3,
					/obj/item/clothing/suit/wizrobe/marisa/fake = 3,/obj/item/clothing/under/sundress = 3,/obj/item/clothing/head/witchwig = 3,/obj/item/weapon/staff/broom = 3,
					/obj/item/clothing/suit/wizrobe/fake = 3,/obj/item/clothing/head/wizard/fake = 3,/obj/item/weapon/staff = 3,/obj/item/clothing/mask/gas/sexyclown = 3,
					/obj/item/clothing/under/sexyclown = 3,/obj/item/clothing/mask/gas/sexymime = 3,/obj/item/clothing/under/sexymime = 3,/obj/item/clothing/suit/apron/overalls = 3,
					/obj/item/clothing/head/rabbitears = 3,/obj/item/clothing/head/lordadmiralhat = 3,/obj/item/clothing/suit/lordadmiral = 3,/obj/item/clothing/suit/doshjacket = 3,/obj/item/clothing/under/jester = 3, /obj/item/clothing/head/jesterhat = 3,/obj/item/clothing/shoes/jestershoes = 3, /obj/item/clothing/suit/kefkarobe = 3,
					/obj/item/clothing/head/helmet/aviatorhelmet = 3,/obj/item/clothing/shoes/aviatorboots = 3, /obj/item/clothing/under/aviatoruniform = 3,/obj/item/clothing/head/libertyhat = 3,/obj/item/clothing/suit/libertycoat = 3, /obj/item/clothing/under/libertyshirt = 3, /obj/item/clothing/shoes/libertyshoes = 3) //Pretty much everything that had a chance to spawn.
	contraband = list(/obj/item/clothing/suit/cardborg = 3,/obj/item/clothing/head/cardborg = 3,/obj/item/clothing/suit/judgerobe = 3,/obj/item/clothing/head/powdered_wig = 3)
	premium = list(/obj/item/clothing/suit/hgpirate = 3, /obj/item/clothing/head/hgpiratecap = 3, /obj/item/clothing/head/helmet/roman = 3, /obj/item/clothing/head/helmet/roman/legionaire = 3, /obj/item/clothing/under/roman = 3, /obj/item/clothing/shoes/roman = 3, /obj/item/weapon/shield/riot/roman = 3,/obj/item/clothing/under/stilsuit = 3)

	pack = /obj/structure/vendomatpack/autodrobe