#include <dlfcn.h>

#ifdef __cplusplus
extern "C" {
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"

void *       dlopen  (const char *filename, int flag)   { return 0; }
const char * dlerror (void)                             { return 0; }
void *       dlsym   (void *handle, const char *symbol) { return 0; }
int          dlclose (void *handle)                     { return 0; }
void *       dl_unwind_find_exidx(void* pc, int* pcnt)  { return 0; }

#pragma clang diagnostic pop

#ifdef __cplusplus
}
#endif

