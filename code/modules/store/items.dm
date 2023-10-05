/////////////////////////////
// Store Item
/////////////////////////////
/datum/storeitem
	var/name="Thing"
	var/desc="It's a thing."
	var/typepath=/obj/item/weapon/storage/box
	var/cost=0
	var/stock = -1 //-1 = unlimited stock. Any other value means the item will become unavailable at 0.
	var/category = "Misc"

/datum/storeitem/proc/deliver(var/mob/user,var/obj/machinery/computer/merch/merchcomp)
	var/thing = new typepath(merchcomp.loc)
	if(istype(typepath,/obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = thing
		user.put_in_hands(S)
		if(station_does_not_tip)
			var/list/additional_types = list(
				IRRADIATEDBEANS,
				MUTATEDBEANS,
				CHEESYGLOOP,
				DIABEETUSOL,
				HORSEMEAT,
				BEFF,
				TOXICWASTE,
				MOONROCKS,
			)
			if(istype(S,/obj/item/weapon/storage/bag/zam_food/))
				additional_types.Add(WATER) //Bad for greys
			for(var/obj/item/weapon/reagent_containers/food/snacks/F in S)
				F.make_poisonous(additional_types)

//If this returns FALSE, then the button simply will not appear for the user in question.
/datum/storeitem/proc/available_to_user(mob/user)
	return TRUE

/////////////////////////////
// Food
/////////////////////////////
/datum/storeitem/menu1
	name = "Fast-Food Menu"
	desc = "The normal sized average american meal. Courtesy of Nanotrasen."
	typepath = /obj/item/weapon/storage/bag/food/menu1
	cost = 40
	category = "Food"

/datum/storeitem/menu2
	name = "Fast-Food Menu (XL)"
	desc = "For when you're 100% starved and want to become fat in 1 easy step."
	typepath = /obj/item/weapon/storage/bag/food/menu2
	cost = 75
	category = "Food"

/datum/storeitem/lunchbox
	name = "Prepackaged NT Lunch"
	desc = "A lunchbox with an entree, side, sweet, condiment, and drink. Courtesy of Nanotrasen."
	typepath = /obj/item/weapon/storage/lunchbox/plastic/nt/pre_filled
	cost = 60
	category = "Food"

/datum/storeitem/lunchbox_collectible
	name = "Collectible Lunchbox"
	desc = "A lunchbox with unique exterior art! Collect them all! Lunch is not included."
	typepath = /obj/item/weapon/storage/lunchbox/plastic/nt/random
	cost = 10
	category = "Food"

/datum/storeitem/diy_soda
	name = "Dr. Pecker's DIY Soda"
	desc = "A fun and tasty chemical experiment for the curious child! Vials and beakers included."
	typepath = /obj/item/weapon/storage/box/diy_soda
	cost = 45
	category = "Food"

/datum/storeitem/canned_bread
	name = "Canned Bread"
	desc = "Best thing since sliced."
	typepath = /obj/item/weapon/reagent_containers/food/drinks/soda_cans/canned_bread
	cost = 15
	category = "Food"

/datum/storeitem/canned_bread/available_to_user(mob/user)
	return(isskrell(user) || Holiday == APRIL_FOOLS_DAY)

/////////////////////////////
// Tools
/////////////////////////////
/datum/storeitem/pen
	name = "Pen"
	desc = "Just a simple pen."
	typepath = /obj/item/weapon/pen
	cost = 2
	category = "Tools"

/datum/storeitem/wrapping_paper
	name = "Wrapping Paper"
	desc = "Makes gifts 200% more touching."
	typepath = /obj/item/stack/package_wrap/gift
	cost = 5
	category = "Tools"

/datum/storeitem/cheap_soap
	name = "Soap"
	desc = "Guarranted for at least 20 scrubbings."
	typepath = /obj/item/weapon/soap/nanotrasen/planned_obsolescence
	cost = 30
	category = "Tools"

/datum/storeitem/swiss_army_knife
	name = "Swiss Army Knife"
	desc = "A multitool for everyday tasks."
	typepath = /obj/item/weapon/switchtool/swiss_army_knife
	cost = 50
	category = "Tools"


/////////////////////////////
// Electronics
/////////////////////////////
/datum/storeitem/boombox
	name = "Boombox"
	desc = "I ask you a question: is a man not entitled to the beats of his own smooth jazz?"
	typepath = /obj/machinery/media/receiver/boombox
	cost = 40
	category = "Electronics"

/datum/storeitem/diskettebox
	name = "Diskette Box"
	desc = "A lockable box for storing data disks. Comes with a few useless blank disks."
	typepath = /obj/item/weapon/storage/lockbox/diskettebox/open/blanks
	cost = 20
	category = "Electronics"

/datum/storeitem/diskettebox_large
	name = "Large Diskette Box"
	desc = "A larger lockable box for storing data disks. Comes with a few useless blank disks."
	typepath = /obj/item/weapon/storage/lockbox/diskettebox/large/open/blanks
	cost = 50
	category = "Electronics"

/datum/storeitem/camcart
	name = "PDA Camera Cartridge"
	desc = "All the fun of an old camera, now on a tiny cartridge inside your microcomputer! Printer not included."
	typepath = /obj/item/weapon/cartridge/camera
	cost = 60
	category = "Electronics"

/////////////////////////////
// Toys
/////////////////////////////
/datum/storeitem/snap_pops
	name = "Snap-Pops"
	desc = "Ten-thousand-year-old chinese fireworks: IN SPACE"
	typepath = /obj/item/weapon/storage/box/snappops
	cost = 10
	category = "Toys"

/datum/storeitem/crayons
	name = "Crayons"
	desc = "Let security know how they're doing by scrawling lovenotes all over their hallways."
	typepath = /obj/item/weapon/storage/fancy/crayons
	cost = 15
	category = "Toys"

/datum/storeitem/beachball
	name = "Beach Ball"
	desc = "Summer up your office with this cheap vinyl beachball made by prisoners!"
	typepath = /obj/item/weapon/beach_ball
	cost = 5
	category = "Toys"

/datum/storeitem/dorkcube
	name = "Loot Box"
	desc = "A single month subscription to Loot Box!"
	typepath = /obj/item/weapon/winter_gift/dorkcube
	cost = 30
	category = "Toys"

/datum/storeitem/unecards
	name = "Deck of Une Cards"
	desc = "A deck of une playing cards."
	typepath = /obj/item/toy/cards/une
	cost = 15
	category = "Toys"
/datum/storeitem/roganbot
	name = "ROGANbot"
	desc = "Your own personalized assistant to speed up your workplace communication skills! Ages 550 and up."
	typepath = /obj/item/device/roganbot
	cost = 100
	stock = 1
	category = "Toys"

/////////////////////////////
// Clothing
/////////////////////////////
/datum/storeitem/sterilemask
	name = "Face Mask"
	desc = "Protects you from both contracting or spreading airborne diseases, at the cost of looking like a virologist."
	typepath = /obj/item/clothing/mask/surgical
	cost = 5
	category = "Clothing"

/datum/storeitem/sterilemask_black
	name = "Black Face Mask"
	desc = "A more sober face mask. Offers the same protection as a regular face mask."
	typepath = /obj/item/clothing/mask/surgical/black
	cost = 20
	category = "Clothing"

/datum/storeitem/sterilemask_colorful
	name = "Colorful Face Mask"
	desc = "A fancier face mask. Offers the same protection as a regular face mask."
	typepath = /obj/item/clothing/mask/surgical/colorful
	cost = 20
	category = "Clothing"

/datum/storeitem/wristwatch
	name = "Wristwatch"
	desc = "A wristwatch with a red leather strap. Can be fit on your uniform."
	typepath = /obj/item/clothing/accessory/wristwatch
	cost = 50
	category = "Clothing"

/datum/storeitem/robotnik_labcoat
	name = "Robotnik's Research Labcoat"
	desc = "Join the empire and display your hatred for woodland animals."
	typepath = /obj/item/clothing/suit/storage/labcoat/custom/N3X15/robotics
	cost = 20
	category = "Clothing"

/datum/storeitem/robotnik_jumpsuit
	name = "Robotics Interface Suit"
	desc = "A modern black and red design with reinforced seams and brass neural interface fittings."
	typepath = /obj/item/clothing/under/custom/N3X15/robotics
	cost = 20
	category = "Clothing"

/////////////////////////////
// Luxury
/////////////////////////////
/datum/storeitem/wallet
	name = "Wallet"
	desc = "A convenient way to carry IDs, credits, coins, papers, and a bunch of other small items."
	typepath = /obj/item/weapon/storage/wallet
	cost = 30
	category = "Luxury"

/datum/storeitem/photo_album
	name = "Photo Album"
	desc = "Clearly all your photos of the clown's shenanigans deserve this investment."
	typepath = /obj/item/weapon/storage/photo_album
	cost = 30
	category = "Luxury"

/datum/storeitem/poster
	name = "Poster"
	desc = "A random poster from Centcom's prints division. For those with bad taste in art."
	typepath = /obj/item/mounted/poster
	cost = 20
	category = "Luxury"

/datum/storeitem/painting
	name = "Painting"
	desc = "A random painting from Centcom's museum. For those with good taste in art."
	typepath = /obj/item/mounted/frame/painting
	cost = 50
	category = "Luxury"

/datum/storeitem/critter_cage
	name = "small cage"
	desc = "A cage where to keep tiny animals safe. Fit with a drinking bottle that can be refilled.."
	typepath = /obj/item/critter_cage
	cost = 60
	category = "Luxury"

/////////////////////////////
// ZAM! (Grey Food)
/////////////////////////////
/datum/storeitem/zambiscuits
	name = "Zam Biscuits"
	desc = "All biscuits are fresh from mothership labs."
	typepath = /obj/item/weapon/zambiscuit_package
	cost = 40
	category = "ZAM!"

/datum/storeitem/zamdinner3
	name = "Zam Spider Slider Delight"
	desc = "The elimination of an infestation has created a surplus of spider meat."
	typepath = /obj/item/weapon/storage/bag/zam_food/zam_menu3
	cost = 55
	category = "ZAM!"

/datum/storeitem/zamdinner2
	name = "Zam Mothership Stew"
	desc = "This old stew from mothership vats is very nutritious to slurp and burp!"
	typepath = /obj/item/weapon/storage/bag/zam_food/zam_menu2
	cost = 65
	category = "ZAM!"

/datum/storeitem/zamdinner1
	name = "Zam Steak and Nettles"
	desc = "This imitation of human steak has received good marks from test subjects."
	typepath = /obj/item/weapon/storage/bag/zam_food/zam_menu1
	cost = 75
	category = "ZAM!"

/datum/storeitem/zamlunchbox
	name = "Prepackaged Zam Lunch"
	desc = "A lunchbox with an entree, side, sweet, condiment, and drink. Courtesy of Zam!"
	typepath = /obj/item/weapon/storage/lunchbox/metal/zam/pre_filled
	cost = 70
	category = "ZAM!"

/////////////////////////////
// Holiday Special Items!
/////////////////////////////
/datum/storeitem/valentinechocolatebar
	name = "Valentine's Day chocolate bar"
	desc = "Show your loved ones how you feel on this special occasion!"
	typepath = /obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped/valentine
	cost = 80
	category = "Holiday Special"

/datum/storeitem/valentinechocolatebar/available_to_user(mob/user)
	return Holiday == VALENTINES_DAY
