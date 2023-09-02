//
//  SystemCall.h
//  IntXFace
//
//  Created by Paul Coelho on 8/29/23.
//

#ifndef SystemCall_h
#define SystemCall_h

#include <stdio.h>

void open_filter(int idx, char **argv);
void write_char(int idx, int val);
typedef void (*rqtype)(int idx, int fd, int chr);
void read_call(rqtype val);

#endif /* SystemCall_h */
