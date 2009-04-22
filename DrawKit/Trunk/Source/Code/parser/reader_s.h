#ifndef _READER_H_
#define _READER_H_

#include "reader_g.tab.h"

typedef struct _Scanner {
	/* Scanner state. */
    int cs;
    int act;
    int have;
    int curline;
    char *tokstart;
    char *tokend;
    char *p;
    char *pe;

	/* Token data */
	char *data;
	int len;
    int token;
	char *token_name;
	char *buf;
	
} Scanner;


#define TK_NO_TOKEN (-1)

#endif /* _READER_H_ */
