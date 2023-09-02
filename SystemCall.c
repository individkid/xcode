//
//  SystemCall.c
//  IntXFace
//
//  Created by Paul Coelho on 8/29/23.
//

#include "SystemCall.h"
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdlib.h>

struct Process {
    int idx;
    int vld;
    pid_t pid;
    int ifd[2];
    int ofd[2];
    int efd[2];
} *process = 0;
int nproc = 0;
rqtype call = 0;

void sig_handler(int sig)
{
    if (!call) return;
    for (int i = 0; i < nproc; i++) {
        pid_t pid = 0; int ret = 0;
        int fd[2] = {0};
        int vld[2] = {0};
        struct Process *ptr = process+i;
        if (ptr->pid == 0) continue;
        fd[0] = ptr->ofd[0]; fd[1] = ptr->efd[0];
        vld[0] = ptr->vld; vld[1] = 1;
        for (int j = 0; j < 2; j++) {
            ssize_t val = 0; int chr = 0;
            if (!vld[j]) continue;
            val = read(fd[j],&chr,1);
            if (val < 0 && errno == EAGAIN) break;
            if (val < 0) {call(ptr->idx,j+1,-2); break;}
            if (val == 0) {call(ptr->idx,j+1,-1); break;}
            call(i,j+1,chr);
        }
        pid = waitpid(ptr->pid,&ret,WNOHANG);
        if (pid == ptr->pid) {ptr->pid = 0; call(ptr->idx,0,ret);}
    }
}
void open_filter(int idx, char **argv)
{
    struct Process *ptr = 0;
    struct sigaction {
        union __sigaction_u __sigaction_u;  /* signal handler */
        sigset_t sa_mask;               /* signal mask to apply */
        int     sa_flags;               /* see signal options below */
    } act = {0};
    int mask = sigblock(sigmask(SIGIO)|sigmask(SIGCHLD));
    act.sa_flags = SA_NOCLDSTOP;
    act.__sigaction_u.__sa_handler = sig_handler;
    process = realloc(process,(nproc+1)*sizeof(struct Process));
    ptr = process + nproc++;
    ptr->idx = idx;
    pipe(ptr->ifd); pipe(ptr->ofd); pipe(ptr->efd); // TODO make filter with last of same idx
    fcntl(ptr->efd[0],F_SETFL,O_ASYNC|O_NONBLOCK);
    fcntl(ptr->ofd[0],F_SETFL,O_ASYNC|O_NONBLOCK);
    sigaction(SIGIO,(void*)&act,0);
    sigaction(SIGCHLD,(void*)&act,0);
    ptr->pid = fork();
    if (!ptr->pid) {
        sigaction(SIGIO,(void*)SIG_IGN,0);
        sigaction(SIGCHLD,(void*)SIG_IGN,0);
        close(ptr->ifd[1]); close(ptr->ofd[0]); close(ptr->efd[0]);
        dup2(ptr->ifd[0],STDIN_FILENO);
        dup2(ptr->ofd[1],STDOUT_FILENO);
        dup2(ptr->efd[1],STDERR_FILENO);
        execvp(argv[0],argv+1);
    }
    close(ptr->ifd[0]); close(ptr->ofd[1]); close(ptr->efd[1]);
    for (int i = 0; argv[i]; i++) printf("open %s\n",argv[i]);
    sigblock(mask);
}
void write_char(int idx, int val)
{
    // TODO search through process for first with idx
}
void read_call(rqtype val)
{
    call = val;
}
