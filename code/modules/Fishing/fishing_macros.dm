//Put these in macros.dm

#define isBait(A) (isitem(A) && A.baitValue)
#define isFish(A) (istype(/mob/living/simple_animal/hostile/fishing))
