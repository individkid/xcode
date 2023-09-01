//
//  SystemCall.c
//  IntXFace
//
//  Created by Paul Coelho on 8/29/23.
//

#include "SystemCall.h"
#include <stdio.h>

void open_filter(char **argv)
{
    for (int i = 0; argv[i]; i++) printf("open %s\n",argv[i]);
}
void write_char(int val);
int read_char(void);
void add_call(zftype call);
