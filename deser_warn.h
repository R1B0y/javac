#ifndef DESER_WARN_H
#define DESER_WARN_H

#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
  int line;
  char info[128];
} DeserWarn;

#define MAX_DESER 1024

extern DeserWarn deser_warns[MAX_DESER];

/* объявляем, чтобы parser.y мог вызвать, если захочет */
void add_deser_warn(const char *info, int line);

#ifdef __cplusplus
}
#endif
#endif /* DESER_WARN_H */
