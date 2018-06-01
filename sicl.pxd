cdef extern from "sicl.h":
    ctypedef int INST
    cdef INST iopen(char *addr)
    cdef int itimeout(INST id,long tval)
    cdef int ipromptf(INST id,char *writefmt,char *readfmt,char *buf)
    cdef int iprintf(INST id,char *writefmt)
    cdef int iwrite(INST id,char *buf,unsigned long datalen,int endi,unsigned long *actual)
    cdef int iread(INST id,char *buf,unsigned long bufsize,int *reason,unsigned long *actual)
