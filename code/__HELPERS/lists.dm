/*
 * Holds procs to help with list operations
 * Contains groups:
 *			Misc
 *			Sorting
 */

/*
 * Misc
 */

//Returns a list in plain english as a string
/proc/english_list(var/list/input, nothing_text = "nothing", and_text = " and ", comma_text = ", ", final_comma_text = "" )
	var/total = input.len
	if (!total)
		return "[nothing_text]"
	else if (total == 1)
		return "[input[1]]"
	else if (total == 2)
		return "[input[1]][and_text][input[2]]"
	else
		var/output = ""
		var/index = 1
		while (index < total)
			if (index == total - 1)
				comma_text = final_comma_text

			output += "[input[index]][comma_text]"
			index++

		return "[output][and_text][input[index]]"

//Returns list element or null. Should prevent "index out of bounds" error.
/proc/listgetindex(list/L, index)
	if(istype(L))
		if(isnum(index))
			if(IsInRange(index,1,L.len))
				return L[index]
		else if(index in L)
			return L[index]
	return

//Return either pick(list) or null if list is not of type /list or is empty
/proc/safepick(list/L)
	if(istype(L) && L.len)
		return pick(L)

//Checks if the list is empty
/proc/isemptylist(list/L)
	if(!L.len)
		return 1
	return 0

//Checks for specific types in a list
/proc/is_type_in_list(datum/A, list/L)
	if(!L || !L.len || !A)
		return 0

	if(L[L[1]] != MAX_VALUE) //Is this already a generated typecache
		if(isnull(L[L[1]])) //It's not a typecache, so now we'll check if its an associative list or not
			generate_type_list_cache(L) //Convert it to an associative list format for speed in access
		else //Else this is meant to be an associative list, we can't reformat it
			for(var/type in L)
				if(istype(A, type))
					return 1
			return 0

	if(istype(A))
		A = A.type //Convert everything to a type

	return L[A]

/proc/generate_type_list_cache(L)
	for(var/type in L)
		for(var/T in typesof(type)) //Gather all possible typepaths into an associative list
			L[T] = MAX_VALUE //Set them equal to the max value which is unlikely to collide with any other pregenerated value

//Removes returns a new list which only contains elements from the original list of a certain type
/proc/prune_list_to_type(list/L, datum/A)
	if(!L || !L.len || !A)
		return 0
	if(!ispath(A))
		A = A.type
	var/list/nu = L.Copy()
	for(var/element in nu)
		if(!istype(element,A))
			nu -= element
	return nu

//Empties the list by setting the length to 0. Hopefully the elements get garbage collected
/proc/clearlist(list/list)
	if(istype(list))
		list.len = 0
	return

//Removes any null entries from the list
/proc/listclearnulls(list/L)
	if(istype(L))
		var/i=1
		for(var/thing in L)
			if(thing != null)
				++i
				continue
			L.Cut(i,i+1)

/*
 * Returns list containing all the entries from first list that are not present in second.
 * If skiprep = 1, repeated elements are treated as one.
 * If either of arguments is not a list, returns null
 */
/proc/difflist(var/list/first, var/list/second, var/skiprep=0)
	if(!islist(first) || !islist(second))
		return
	var/list/result = new
	if(skiprep)
		for(var/e in first)
			if(!(e in result) && !(e in second))
				result += e
	else
		result = first - second
	return result

/*
 * Returns list containing entries that are in either list but not both.
 * If skipref = 1, repeated elements are treated as one.
 * If either of arguments is not a list, returns null
 */
/proc/uniquemergelist(var/list/first, var/list/second, var/skiprep=0)
	if(!islist(first) || !islist(second))
		return
	var/list/result = new
	if(skiprep)
		result = difflist(first, second, skiprep)+difflist(second, first, skiprep)
	else
		result = first ^ second
	return result

//Picks an element based on its weight
/proc/pickweight(list/L)
	if(!L || !L.len)
		return
	var/total = 0
	var/item
	for (item in L)
		if (isnull(L[item]))
			L[item] = 1
		total += L[item]

	total = rand()*total
	for (item in L)
		total -=L [item]
		if (total <= 0)
			return item

	return L[L.len]

//Pick a random element from the list and remove it from the list.
/proc/pick_n_take(list/L)
	if(L.len)
		var/picked = rand(1,L.len)
		. = L[picked]
		L.Cut(picked,picked+1)			//Cut is far more efficient that Remove()

//Returns the top(last) element from the list and removes it from the list (typical stack function)
/proc/pop(list/L)
	if(L.len)
		. = L[L.len]
		L.len--

//Puts an item on the end of a list
/proc/push(list/L, thing)
	L += thing

//Shift/Unshift works on a FIFO system unlike pop/push working on FILO
//Returns the bottom(first) element from the list and removes it from the list
/proc/shift(list/L)
	if(L.len)
		. = L[1]
		L.Cut(1,2)

//Puts an item at the beginning of the list
/proc/unshift(list/L, thing)
	L.Insert(1,thing)

/proc/sorted_insert(list/L, thing, comparator)
	var/pos = L.len
	while(pos > 0 && call(comparator)(thing, L[pos]) > 0)
		pos--
	L.Insert(pos+1, thing)

// Returns the next item in a list
/proc/next_list_item(var/item, var/list/L)
	var/i
	i = L.Find(item)
	if(i == L.len)
		i = 1
	else
		i++
	if(i < 1 || i > L.len)
		warning("[__FILE__]L[__LINE__]: [i] is outside of bounds for list, ([L.len])")
		return
	return L[i]

// Returns the previous item in a list
/proc/previous_list_item(var/item, var/list/L)
	var/i
	i = L.Find(item)
	if(i == 1)
		i = L.len
	else
		i--
	if(i < 1 || i > L.len)
		warning("[__FILE__]L[__LINE__]: [i] is outside of bounds for list, ([L.len])")
		return
	return L[i]

/*
 * Sorting
 */
/*
//Reverses the order of items in the list
/proc/reverselist(var/list/input)
	var/list/output = list()
	for(var/i = input.len; i >= 1; i--)
		output += input[i]
	return output
*/

//Randomize: Return the list in a random order
/proc/shuffle(var/list/L)
	if(!L)
		return
	L = L.Copy()

	for(var/i=1, i<=L.len, ++i)
		L.Swap(i,rand(1,L.len))

	return L

//Return a list with no duplicate entries
/proc/uniquelist(var/list/L)
	var/list/K = list()
	for(var/item in L)
		if(!(item in K))
			K += item
	return K

//for sorting clients or mobs by ckey
/proc/sortKey(list/L, order=1)
	return sortTim(L, order >= 0 ? /proc/cmp_ckey_asc : /proc/cmp_ckey_dsc)

//Specifically for record datums in a list.
/proc/sortRecord(list/L, field = "name", order = 1)
	cmp_field = field
	return sortTim(L, order >= 0 ? /proc/cmp_records_asc : /proc/cmp_records_dsc)

//any value in a list
/proc/sortList(var/list/L, cmp=/proc/cmp_text_asc)
	return sortTim(L.Copy(), cmp)

//uses sortList() but uses the var's name specifically. This should probably be using mergeAtom() instead
/proc/sortNames(var/list/L, order=1)
	return sortTim(L, order >= 0 ? /proc/cmp_name_asc : /proc/cmp_name_dsc)


//Converts a bitfield to a list of numbers (or words if a wordlist is provided)
/proc/bitfield2list(bitfield = 0, list/wordlist)
	var/list/r = list()
	if(istype(wordlist,/list))
		var/max = min(wordlist.len,16)
		var/bit = 1
		for(var/i=1, i<=max, i++)
			if(bitfield & bit)
				r += wordlist[i]
			bit = bit << 1
	else
		for(var/bit=1, bit<=65535, bit = bit << 1)
			if(bitfield & bit)
				r += bit

	return r

// Returns the key based on the index
/proc/get_key_by_index(var/list/L, var/index)
	var/i = 1
	for(var/key in L)
		if(index == i)
			return key
		i++
	return null

// Returns the first key to match the specified element. This is intended for lists which are injective functions.
// Which is to say, two keys will not map to the same element.
/proc/get_key_by_element(var/list/L, var/element)
	for(var/key in L)
		if(L[key] == element)
			return key
	return null

//In an associative list, get only the elements and not the keys.
/proc/get_list_of_elements(var/list/L)
	var/list/elements = list()
	for(var/key in L)
		elements += L[key]
	return elements

//In an associative list, get only the keys and not the elements.
/proc/get_list_of_keys(var/list/L)
	var/list/keys = list()
	for(var/key in L)
		keys += key
	return keys

/proc/count_by_type(var/list/L, type)
	var/i = 0
	for(var/T in L)
		if(istype(T, type))
			i++
	return i

/proc/find_record(field, value, list/L)
	for(var/datum/data/record/R in L)
		if(R.fields[field] == value)
			return R

//get total of nums in a list, ignores non-num values
//great with get_list_of_elements!
/proc/total_list(var/list/L)
	var/total = 0
	for(var/element in L)
		if(!isnum(element))
			continue
		total += element
	return total

//Move a single element from position fromIndex within a list, to position toIndex
//All elements in the range [1,toIndex) before the move will be before the pivot afterwards
//All elements in the range [toIndex, L.len+1) before the move will be after the pivot afterwards
//In other words, it's as if the range [fromIndex,toIndex) have been rotated using a <<< operation common to other languages.
//fromIndex and toIndex must be in the range [1,L.len+1]
//This will preserve associations ~Carnie
/proc/moveElement(list/L, fromIndex, toIndex)
	if(fromIndex == toIndex || fromIndex+1 == toIndex)	//no need to move
		return
	if(fromIndex > toIndex)
		++fromIndex	//since a null will be inserted before fromIndex, the index needs to be nudged right by one

	L.Insert(toIndex, null)
	L.Swap(fromIndex, toIndex)
	L.Cut(fromIndex, fromIndex+1)


//Move elements [fromIndex,fromIndex+len) to [toIndex-len, toIndex)
//Same as moveElement but for ranges of elements
//This will preserve associations ~Carnie
/proc/moveRange(list/L, fromIndex, toIndex, len=1)
	var/distance = abs(toIndex - fromIndex)
	if(len >= distance)	//there are more elements to be moved than the distance to be moved. Therefore the same result can be achieved (with fewer operations) by moving elements between where we are and where we are going. The result being, our range we are moving is shifted left or right by dist elements
		if(fromIndex <= toIndex)
			return	//no need to move
		fromIndex += len	//we want to shift left instead of right

		for(var/i=0, i<distance, ++i)
			L.Insert(fromIndex, null)
			L.Swap(fromIndex, toIndex)
			L.Cut(toIndex, toIndex+1)
	else
		if(fromIndex > toIndex)
			fromIndex += len

		for(var/i=0, i<len, ++i)
			L.Insert(toIndex, null)
			L.Swap(fromIndex, toIndex)
			L.Cut(fromIndex, fromIndex+1)

//Move elements from [fromIndex, fromIndex+len) to [toIndex, toIndex+len)
//Move any elements being overwritten by the move to the now-empty elements, preserving order
//Note: if the two ranges overlap, only the destination order will be preserved fully, since some elements will be within both ranges ~Carnie
/proc/swapRange(list/L, fromIndex, toIndex, len=1)
	var/distance = abs(toIndex - fromIndex)
	if(len > distance)	//there is an overlap, therefore swapping each element will require more swaps than inserting new elements
		if(fromIndex < toIndex)
			toIndex += len
		else
			fromIndex += len

		for(var/i=0, i<distance, ++i)
			L.Insert(fromIndex, null)
			L.Swap(fromIndex, toIndex)
			L.Cut(toIndex, toIndex+1)
	else
		if(toIndex > fromIndex)
			var/a = toIndex
			toIndex = fromIndex
			fromIndex = a

		for(var/i=0, i<len, ++i)
			L.Swap(fromIndex++, toIndex++)

//replaces reverseList ~Carnie
/proc/reverseRange(list/L, start=1, end=0)
	if(L.len)
		start = start % L.len
		end = end % (L.len+1)
		if(start <= 0)
			start += L.len
		if(end <= 0)
			end += L.len + 1

		--end
		while(start < end)
			L.Swap(start++,end--)

	return L


//creates every subtype of prototype (excluding prototype) and adds it to list L.
//if no list/L is provided, one is created.
/proc/init_subtypes(prototype, list/L)
	if(!istype(L))
		L = list()
	for(var/path in subtypesof(prototype))
		L += new path()
	return L
