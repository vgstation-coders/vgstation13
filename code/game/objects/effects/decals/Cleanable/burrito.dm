/*
You know, when I woke up today, I didn't think
"I'm going to make BURRITO FILLING inside of a BYOND game!"
No, I was thinking about LOW PRICES and THE CUSTOMER, as per usual.
But then I see people talking about how BURRITO FILLING isn't funny.
I think that that is udder bullBURRITO FILLING.
Let me list the reasons why BURRITO FILLING is funny:
- Most BURRITO FILLING is brown. Relatable.
- Most BURRITOS comes out your LOCAL DISCOUNT DAN'S MACHINE. Relatable.
- Most people EAT BURRITOS. Relatable.
- BURRITO FILLING is not expected in a video game. Quirky.
- BURRITO FILLING can be thrown. Slapstick.
- Most creatures EAT BURRITOS. Relatable.

I hope these reasons are enough to make you see the real humor in BURRITO FILLING.
Honestly I think there is simply not ENOUGH BURRITO FILLING in video games.
BURRITO FILLING is an everyday aspect of life, and should be incorporated into everything to do with life accordingly.
Here are some things I think would be better with more BURRITO FILLING:
- Metal Gear Solid (The game takes themes from real life, may as well have a scene where snake EATS A DISCOUNT DAN'S BURRITO.)
- Super Mario Brothers (I highly doubt that as a DISCOUNT DAN MACHINE, mario does not run into large amounts of BURRITO on a daily basis.)
- Any FPS game that gets a new entry every year. (They're already HEALTHY AND FULL OF BURRITOS, may as well add it to the game.)
- Any physics engine. (We simply do not see enough real time BURRITO FILLING physics simulations.)
- Grand Theft Auto (The adult nature of the game means that BURRITO FILLING would fit nicly into the atmosphere of the games.)
- Any racing game. (Not enough mid-race pitstop QUICK EATS AT DISCOUNT DAN'S.)
- Any D&D game. (Your campaign does NOT have enough BURRITO FILLING in it. 0/10.)
- 4chan (>Implying 4chan has enough BURRITO FILLING.)
- You (Doctors say that atleast two BURRITOS a day is healthy. Hit that DISCOUNT DAN'S VENDING MACHINE.)
- Family Game Night (I always said that BURRITO flinging was a family friendly sport. Can't imagine why I'm not allowed to visit. Or call.)
- Earth (Our atmosphere should be ATLEAST 10% BURRITO FILLING. SPACE CHINA is making progress, but they need our help.)
- The periodic table. (Hydrogen? Helium? More like BURRITOium.)
- The solar system. (UrBURRITO is a good start though.)
- The universe. (If every quark of my being was BURRITO FILLING, I would be happy.)
- Everything in general. (BURRITO FILLING is just fucking great, aint it?)

I hope these reasons are enough to convince you that BURRITO FILLING is a great thing, and there should be more of it.
With TASTY regards,
- DISCOUNT DAN
*/

/obj/effect/decal/cleanable/blood/burrito
	name = "burrito filling"
	desc = "Someone get the janitor."
	basecolor="#663300"

/obj/effect/decal/cleanable/blood/burrito/dry()
	return

/obj/effect/decal/cleanable/blood/burrito/streak
	random_icon_states = list("mgibbl1", "mgibbl2", "mgibbl3", "mgibbl4", "mgibbl5")
	amount = 2

/obj/item/weapon/reagent_containers/food/snacks/burritofilling
	name = "burrito mush"
	desc = "This has a lot of corn in it..."
	icon_state = "burrito"
	New()
		..()
		reagents.add_reagent("nutriment", 1)

	throw_impact(atom/hit_atom)
		..()
		new/obj/effect/decal/cleanable/blood/poo(src.loc)
		src.reagents.reaction(hit_atom, TOUCH)
		src.visible_message("\red [src.name] has been squashed.","\red You hear a smack.")
		del(src)




//Even that highly MARKETED starting note cannot hide the fact that I ENJOY myself for making this.
//I ENJOY my life.