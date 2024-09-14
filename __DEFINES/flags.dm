//setter for KEEP_TOGETHER to allow for multiple sources to set and unset it
#define ADD_KEEP_TOGETHER(x, source)\
		LAZYADD(x.keep_together_sources, source);\
		x.update_keep_together()

#define REMOVE_KEEP_TOGETHER(x, source)\
		LAZYREMOVE(x.keep_together_sources, source);\
		x.update_keep_together()
