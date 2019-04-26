// PLISTS BY RPAUL
// basically a better version of lists mimicing php lists
// http://www.byond.com/docs/ref/info.html#/list/operators del this later
// http://www.byond.com/docs/ref/info.html#/operator/overload this too

plist
    var/list/_list = list()

/*
=================
    OPERATORS
=================
*/
//return at idx TODO maybe sanitize. list["[var]" fix that somehow
plist/proc/operator[](var/idx)
    return _list[idx]

//check if list needs to be extended, so if idx is num and > then len. if idx is str we dont care
//if idx is null, append
plist/proc/operator[]=(idx, B)
    if(!idx)
        src += B //append

    if(isnum(idx))
        if(idx > _list.len)
            list.len = idx
        _list[idx] = B
    else if(istext(idx))
        _list[idx] = B
    else
        _list["[idx]"] = B // \ref ????

//actually add list as an element, not add all elements, also add everything else properly
plist/proc/operator+(B)
    return "TODO"

plist/proc/operator+=(B)
    return "TODO"

//append all items when list, basically what += would do, so people can still use it, but its not default
plist/proc/operator*(B)
    return _list + B

plist/proc/operator*=(B)
    _list += B

//behaviour is fine
plist/proc/operator-(B)
    return _list - B

plist/proc/operator-=(B)
    _list -= B

//behaviour is fine
plist/proc/operator|(B)
    return _list | B

plist/proc/operator|=(B)
    _list |= B

//behaviour is fine
plist/proc/operator&(B)
    return _list & B

plist/proc/operator&=(B)
    _list &= B

//behaviour is fine
plist/proc/operator^(B)
    return _list ^ B

plist/proc/operator^=(B)
    _list ^= B

/*
=================
   LIST PROCS
=================
*/
plist/proc/Add(B)
    _list += B

plist/proc/Copy(start = 1, end = 0)
    if(!end) end = _list.len
    if(start > end) return FALSE
    return _list.Copy(start, end)

plist/proc/Cut(start = 1, end = 0)
    if(!end) end = _list.len
    if(start > end) return FALSE
    return _list.Cut(start, end)

plist/proc/Find(B)
    //TODO

plist/proc/Insert(B)
    //TODO

plist/proc/Join(B)
    //TODO

plist/proc/Remove(B)
    //TODO

plist/proc/Swap(B)
    //TODO

/*
=================
   HELPER PROCS
=================
*/
//replaces old add
plist/proc/Append(B)
    _list.Add(B)

//needs testing
plist/proc/hasIndex(I)
    if(I > _list.len) return FALSE //catch runtimes
    if(_list[I]) //this will handle both strings and nums
        return TRUE
    return FALSE