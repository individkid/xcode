//
//  SystemCall.h
//  IntXFace
//
//  Created by Paul Coelho on 8/29/23.
//

#ifndef SystemCall_h
#define SystemCall_h

#include <stdio.h>

void open_filter(char **argv);
void write_char(int val);
int read_char(void);
typedef void (*hgtype)(int);
void add_call(hgtype call);

#endif /* SystemCall_h */
