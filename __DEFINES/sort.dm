#define SIFT_DOWN(L, comparison, n, i) do { \
var/SIFT_DOWN_largest = i; \
var/SIFT_DOWN_i; \
do { \
	SIFT_DOWN_i = SIFT_DOWN_largest; \
	var/SIFT_DOWN_l = 2 * SIFT_DOWN_largest; \
	var/SIFT_DOWN_r = SIFT_DOWN_l + 1; \
	if(SIFT_DOWN_l <= n) { \
		if(comparison(L[SIFT_DOWN_l], L[SIFT_DOWN_largest])) { \
			SIFT_DOWN_largest = SIFT_DOWN_l; \
		} \
		if((SIFT_DOWN_r <= n) && comparison(L[SIFT_DOWN_r], L[SIFT_DOWN_largest])) { \
			SIFT_DOWN_largest = SIFT_DOWN_r; \
		} \
	} \
	L.Swap(SIFT_DOWN_i, SIFT_DOWN_largest); \
} while(SIFT_DOWN_largest != SIFT_DOWN_i);} while(FALSE)

#define SORT(L, comparison) do { \
var/SORT_N = L.len; \
for(var/SORT_i in round(SORT_N / 2) to 1 step -1) { \
	SIFT_DOWN(L, comparison, SORT_N, SORT_i); \
} \
for(var/SORT_i in SORT_N to 2 step -1) { \
	L.Swap(1, SORT_i); \
	SIFT_DOWN(L, comparison, SORT_i - 1, 1); \
}} while(FALSE)

#define GREATER(a, b) (a > b)
#define LESS(a, b) (a < b)

#define SORT_ASC(L) SORT(L, GREATER)
#define SORT_DSC(L) SORT(L, LESS)
