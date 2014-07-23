/*
You know, when I woke up today, I didn't think
"I'm going to make shit inside of a BYOND game!"
No, I was thinking about butts and farts, as per usual.
But then I see people talking about how poo isn't funny.
I think that that is udder bullshit.
Let me list the reasons why poo is funny:
- Most poo is brown. Relatable.
- Most poo comes out your ass. Relatable.
- Most people poo. Relatable.
- Poo is not expected in a video game. Quirky.
- Poo can be thrown. Slapstick.
- Most creatures poo. Relatable.

I hope these reasons are enough to make you see the real humor in poo.
Honestly I think there is simply not ENOUGH poo in video games.
Poo is an everyday aspect of life, and should be incorporated into everything to do with life accordingly.
Here are some things I think would be better with more poo:
- Metal Gear Solid (The game takes themes from real life, may as well have a scene where snake takes a shit.)
- Super Mario Brothers (I highly doubt that as a plumber, mario does not run into large amounts of poo on a daily basis.)
- Any FPS game that gets a new entry every year. (They're already shit, may as well add it to the game.)
- Any physics engine. (We simply do not see enough real time poo physics simulations.)
- Grand Theft Auto (The adult nature of the game means that poo would fit nicly into the atmosphere of the games.)
- Any racing game. (Not enough mid-race pitstop shits.)
- Any D&D game. (Your campaign does NOT have enough shit in it. 0/10.)
- 4chan (>Implying 4chan has enough poo.)
- You (Doctors say that atleast two shits a day is healthy. Hit that bathroom.)
- Family Game Night (I always said that shit flinging was a family friendly sport. Can't imagine why I'm not allowed to visit. Or call.)
- Earth (Our atmosphere should be ATLEAST 10% poo. China is making progress, but they need our help.)
- The periodic table. (Hydrogen? Helium? More like Pooium.)
- The solar system. (Uranus is a good start though.)
- The universe. (If every quark of my being was shit, I would be happy.)
- Everything in general. (Poo is just fucking great, aint it?)

I hope these reasons are enough to convince you that poo is a great thing, and there should be more of it.
With shitty regards,
- Heredth
*/

/obj/effect/decal/cleanable/blood/poo
	name = "poo"
	desc = "Someone get the janitor."
	basecolor="#663300"

/obj/effect/decal/cleanable/blood/poo/dry()
	return

/obj/effect/decal/cleanable/blood/poo/streak
	random_icon_states = list("mgibbl1", "mgibbl2", "mgibbl3", "mgibbl4", "mgibbl5")
	amount = 2

/obj/item/weapon/reagent_containers/food/snacks/poo
	name = "poo"
	desc = "Looks like captain made a mess. Again."
	icon_state = "poo6"
	New()
		..()
		reagents.add_reagent("nutriment", 1)
		reagents.add_reagent("poo", 1)

	throw_impact(atom/hit_atom)
		..()
		new/obj/effect/decal/cleanable/blood/poo(src.loc)
		src.reagents.reaction(hit_atom, TOUCH)
		src.visible_message("\red [src.name] has been squashed.","\red You hear a smack.")
		del(src)

	New()
		..()
		icon_state = "poo[pick("1","2","3","4","5","6","7")]"




//Even that highly sarcastic starting note cannot hide the fact that I hate myself for making this.
//I hate my life.
