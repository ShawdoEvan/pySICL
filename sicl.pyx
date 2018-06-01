cimport sicl

cdef class SICL:
    cdef INST inst
    def __cinit__(self,SICL_ADDRESS):
        self.inst = self.iopen(SICL_ADDRESS)

    def iopen(self,address):
        return sicl.iopen(str.encode(address))

    def ipromptf(self, command):
        if not command.endswith("\n"):
            command = command + "\n"
        cdef char messages[100]
        sicl.ipromptf(self.inst,str.encode(command),b"%t",messages)
        return messages.decode("utf-8")

    def itimeout(self,tval):
        return sicl.itimeout(self.inst,tval)

    #def ionerror(self,int errorproc_t):
    #    return sicl.ionerror(errorproc_t)

    def iprintf(self,command):
        if not command.endswith("\n"):
            command = command + "\n"
        return sicl.iprintf(self.inst,str.encode(command))

    def iwrite(self,command):
        if not command.endswith("\n"):
            command = command + "\n"
        return sicl.iwrite(self.inst,str.encode(command),len(command),1,NULL)

    def iread(self):
        cdef char readbuf[20]
        cdef unsigned long *actual_cnt
        cdef int *reason = NULL
        sicl.iread(self.inst,readbuf , 20, reason, actual_cnt)
        #if actual_cnt:
        #    readbuf[actual_cnt-1] = 0
        return readbuf.decode("utf-8")
