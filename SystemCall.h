//
//  SystemCall.h
//  IntXFace
//
//  Created by Paul Coelho on 8/29/23.
//

#ifndef SystemCall_h
#define SystemCall_h

#include <stdio.h>

int open_filter(const char *argv[], int argc);
void write_char(char val, int idx);
char read_char(int idx);
int wait_onset(void);
void clear_set(void);
void addto_set(int idx);
void delfrom_set(int idx);

#endif /* SystemCall_h */
