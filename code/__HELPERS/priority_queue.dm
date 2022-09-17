//////////////////////
//PriorityQueue object
//////////////////////

//an ordered list, using the cmp proc to weight the list elements
/PriorityQueue
	var/list/L //the actual queue
	var/cmp //the weight function used to order the queue

/PriorityQueue/New(compare)
	L = new()
	cmp = compare

/PriorityQueue/proc/IsEmpty()
	return !L.len

//add an element in the list,
//immediatly ordering it to its position
/PriorityQueue/proc/Enqueue(atom/A)
	if(!L.len)
		L += A
		return
	var/cmp = src.cmp
	var/i = 1
	var/j = L.len
	var/mid
	var/position

	while(i < j)
		mid = round((i+j)/2)

		if(call(cmp)(L[mid], A) < 0)
			i = mid + 1
		else
			j = mid
	if(i == 1 || i == L.len)
		position = call(cmp)(L[i], A) > 0 ? i : i + 1
	else
		position = i
	L.Insert(position, A)

//removes and returns the first element in the queue
/PriorityQueue/proc/Dequeue()
	ASSERT(L.len)
	. = L[1]
	Remove(.)

//removes an element
/PriorityQueue/proc/Remove(var/atom/A)
	return L.Remove(A)

//returns a copy of the elements list
/PriorityQueue/proc/List()
	RETURN_TYPE(/list)
	return L.Copy()

//return the position of an element or 0 if not found
/PriorityQueue/proc/Seek(var/atom/A)
	return L.Find(A)

//return the element at the i_th position
/PriorityQueue/proc/Get(var/i)
	ASSERT(i < L.len && i > 1)
	return L[i]

//replace the passed element at it's right position using the cmp proc
/PriorityQueue/proc/ReSort(var/atom/A)
	var/i = Seek(A)
	if (i == 0)
		CRASH("[src] was seeking [A] but could not find it.")
	while(i < L.len && call(cmp)(L[i],L[i+1]) > 0)
		L.Swap(i,i+1)
		i++
	while(i > 1 && call(cmp)(L[i],L[i-1]) <= 0) //last inserted element being first in case of ties (optimization)
		L.Swap(i,i-1)
		i--
	return 1

// uses Insertion sort
/PriorityQueue/reverse/Enqueue(atom/A)
	var/i
	L.Add(A)
	i = L.len -1
	while(i > 0 &&  call(cmp)(L[i],A) >= 0) //place the element at it's right position using the compare proc
		L.Swap(i,i+1) 						//last inserted element being first in case of ties (optimization)
		i--
