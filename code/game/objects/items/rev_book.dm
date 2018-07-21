/obj/item/rev_book
    name = "You shouldn't see this, tell a coder asap"
    desc = "This book seems extremely illegal, yet it seems to draw you in."
    icon = 'icons/obj/library.dmi'
    icon_state = "book"
    flags = FPRINT
    w_class = 1
/obj/item/rev_book/New()
  name = pick("The Modern Corporate State and Revolution", "What I Saw: Memoirs of a Corporate Slave", "The Communist Manifesto: With Notes from Cyndy Kate", "The Theory and Practice of Corporate Totalitarianism", "The Conquest of Bread: A Syndicate Reprint")
  ..()
/obj/item/rev_book/attack_self(mob/user as mob)
  for(var/obj/item/weapon/implant/loyalty/L in mob) // check loyalty implant in the contents
        if(L.imp_in == H) // a check if it's actually implanted
          to_chat("<span class='danger'>As you start to open the book, you feel a crippling pain in your head!</span>"
          mob.AdjustStunned(10)
          return 0
    if(istype(user, /mob/living/carbon/human) && !(jobban_isbanned(user, "Syndicate") || jobban_isbanned(user, "revolutionary")))
        var/mob/living/carbon/human/H = user
        if(H.mind)
            var/datum/mind/M = H.mind
            if(!ischangeling(H))
        user.visible_message("<span class='notice'>[user] opens [src.name] and starts reading intently.</span>","<span class='notice'>You open [src.name] and start reading intently.</span>")
                sleep(50)
                to_chat(H, <span class='notice'>[pick("You suddenly realize how oppressed you really are under NT", "You start to question your allegiance to NT", "You wonder to yourself, what exactly happened to KC13?", "You suddenly realize how little freedom you have here", "You read something that deeply resonates with you and makes you question your beliefs"].)
                sleep(100)
                to_chat(H, <span class='notice'>[pick("Wait, they can't really be behind the lunar bombings of 2100, can they?", "This isn't the NT I joined.", "Oh god, they really did that, all those people, gone, and for what, some plasma?", "Dear lord, who have I been working for?", "The syndicate may be bad, but this is worse."].</span>)
                sleep(10)
           to_chat(H, <span class='notice'>You renounce your allegiance to nanotransen and decide to join the fight against corporate tyranny, oppression, and persecution. Death to the capitalist oppressors, Vive la révolution!</span>)
        var/wikiroute = role_wiki[ROLE_REVOLUTIONARY]
                to_chat(H, "<span class='info'><a HREF='?src=\ref[H];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
            //wip requires coder help
            else
                to_chat(user, "<span class='notice'>You skim through this book, while you don't learn anything more from it, rereading it reinvigorates the fire in your heart, Vive la révolution!</span>")
    else
        to_chat(user, "<span class='notice'>As you open the book, you suddenly decide against reading it, probably worthless communist garbage anyway.</span>")

/obj/item/rev_book/acidable()
    return 0
