// PLISTS BY RPAUL
// basically a better version of lists mimicing php lists
// http://www.byond.com/docs/ref/info.html#/list/operators del this later
// http://www.byond.com/docs/ref/info.html#/operator/overload this too

plist
    var/list/_list = list()

plist/proc/operator[](var/idx)
    //return at idx, maybe sanitize. list["[var]" fix that somehow

plist/proc/operator[]=(idx, B)
    //check if list needs to be extended, so if idx is num and > then len. if idx is str we dont care
    //if idx is null, append

plist/proc/operator+=(B)
    //actually add list as an element, not add all elements

plist/proc/operator*=(B)
    //append all items when list, basically what += would do

plist/proc/operator-=(B)
    //doesn't need to be changed much, has good behaviour