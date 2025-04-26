//Passive spells
//Cannot be normally cast, instead they rely on process() except for the no_clothes.dm spell

/spell/passive
    charge_type = SP_PASSIVE
    level_max = list(SP_TOTAL = 0) //Passive spells have no use. For the love of God, do NOT give it SP_SPEED, it will do nothing
    charge_cooldown_max = 0 //Redundancy

/spell/passive/process()
    return //Does nothing, add processes to children instead