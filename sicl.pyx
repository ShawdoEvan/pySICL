cimport sicl

error_code = {
        23:"A SICL call was aborted by external means.",
        3:"The device/interface address passed to iopen does not exist. Verify that the interface name is the one assigned with Connection Expert.",
        24:"An invalid configuration was identified when calling iopen.",
        13:"Invalid format string specified for iprintf or iscanf.",
        4:"The specified INST id does not have a corresponding iopen.",
        19:"The imap call has an invalid map request. ",
        28:"The specified interface is busy.",
        14:"The use of CRC, Checksum, and so forth imply invalid data.",
        128:"SICL internal error.",
        129:"A process interrupt (signal) has occurred in your application.",
        21:"The address specified in iopen is not a valid address (for example, “hpib,57”).",
        17:"An I/O error has occurred for this communication session.",
        11: "Resource is locked by another session (see isetlockwait).",
        27:"Attempt to call another SICL function when current SICL function has not completed (WIN16). More than one I/O operation is prohibited.",
        25:"Tried to specify a commander session when it is not active, available, or does not exist.",
        6:"Communication session has never been established, or connection to remote has been dropped.",
        20:"Tried to specify a device session when it is not active, available, or does not exist.",
        10:"Tried to specify an interface session when it is not active, available, or does not exist.",
        12:"An iunlock was specified when device was not locked.",
        7:"Access rights violated.",
        9:"No more system resources available.",
        22:"Call not supported on this implementation. The request is valid, but not supported on this implementation.",
        8:"Operation not supported on this implementation.",
        18:"SICL encountered an operating system error.",
        16:"Arithmetic overflow. The space allocated for data may be smaller than the data read.",
        5:"The constant or parameter passed is not valid for this call.",
        2:"Symbolic name passed to iopen not recognized.",
        1:"Syntax error occurred parsing address passed to iopen. Make sure you have formatted the string properly. White space is not allowed.",
        15:"A timeout occurred on the read/write operation. The device may be busy, in a bad state, or you may need a longer timeout value for that device. Check also that you passed the correct address to iopen.",
        26:"The iopen call has encountered a SICL library that is newer than the drivers. Need to update drivers.",
    }
error_string={
    23:"Externally aborted",
    3:"Bad address",
    24:"Invalid configuration",
    13:"Invalid format",
    4:"Invalid INST",
    19:"Invalid map request",
    28:"Interface is in use by non-SICL process",
    14:"Data integrity violation",
    128:"Internal error occurred",
    129:"Process interrupt occurred",
    21:"Invalid address",
    17:"Generic I/O error",
    11:"Locked by another user",
    27:"Nested I/O",
    25:"Commander session is not active or availablee",
    6 :"No connection",
    20:"Device is not active or available",
    10:"Interface is not active",
    12:"Interface not locked",
    7:"Permission denied",
    9:"Out of resources",
    22:"Operation not implemented",
    8:"Operation not supported",
    18:"Generic O.S. error",
    16:"Arithmetic overflow",
    5:"Invalid parameter",
    2:"Invalid symbolic name",
    1:"Syntax error",
    15:"Timeout occurred",
    26:"Version incompatibility"
}

class SICLException(Exception):
    def __init__(self, message, errors):

        # Call the base class constructor with the parameters it needs
        super().__init__(message+"  Root cause : "+error_string.get(errors) +" / Detail message:"+error_code.get(errors))

        # Now for your custom code...
        self.errors = errors

cdef class SICL:
    cdef INST inst
    cdef str startchar
    cdef str endchar
    cdef str SICL_ADDRESS

    def __cinit__(self,SICL_ADDRESS, endchar, startchar=''):
        self.SICL_ADDRESS = SICL_ADDRESS
        self.inst = self.iopen(SICL_ADDRESS)
        self.startchar = startchar
        self.endchar = endchar

    def ionerror(self,exitCode):
        sicl.ionerror(exitCode)

    def ireadstb(self,timeout=1):
        cdef unsigned char statusbyte
        sicl.ireadstb(self.inst,&statusbyte)
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("ireadstd fail.",errno)
        return statusbyte

    def iopen(self,address):
        status = sicl.iopen(str.encode(address))
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("iopen fail.",errno)
        return status

    def iscanf(self):
        cdef char message[1024]
        status = sicl.iscanf(self.inst, "%t", message)
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("iscanf fail.",errno)
        return message.lstrip(self.startchar.encode('utf-8')).rstrip(self.endchar.encode('utf-8')).decode("utf-8")


    def ipromptf(self, command):
        if not command.endswith(self.endchar):
            command = command + self.endchar
        if not command.startswith(self.startchar):
            command = self.startchar + command
        cdef char message[1024]
        status = sicl.ipromptf(self.inst,str.encode(command),b"%t", message)
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("ipromptf fail.",errno)
        return message.lstrip(self.startchar.encode('utf-8')).rstrip(self.endchar.encode('utf-8')).decode("utf-8")

    def ipromptf_largebuff(self, command):
        if not command.endswith(self.endchar):
            command = command + self.endchar
        if not command.startswith(self.startchar):
            command = self.startchar + command
        cdef char message[102400]
        sicl.ipromptf(self.inst,str.encode(command),b"%t", message)
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("ipromptf_largebuff fail.",errno)
        return message.lstrip(self.startchar.encode('utf-8')).rstrip(self.endchar.encode('utf-8')).decode("utf-8")

    def itimeout(self,tval):
        status = sicl.itimeout(self.inst,tval)
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("itimeout fail.",errno)
        return status

    def iprintf(self,command):
        if not command.endswith(self.endchar):
            command = command + self.endchar
        if not command.startswith(self.startchar):
            command = self.startchar + command
        status = sicl.iprintf(self.inst,str.encode(command))
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("iprintf fail.",errno)
        return status

    def iwrite(self,command):
        if not command.endswith(self.endchar):
            command = command + self.endchar
        status = sicl.iwrite(self.inst,str.encode(command),len(command),1,NULL)
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("iwrite fail.",errno)
        return status

    def ifwrite(self,command):
        if not command.endswith(self.endchar):
            command = command + self.endchar
        status = sicl.ifwrite(self.inst,str.encode(command),len(command),1,NULL)
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("ifwrite fail.",errno)
        return status

    def iread(self):
        """
        20180705測試是否依定要轉成encode=UTF8
        :return:
        """
        cdef char readbuf[1024]
        cdef unsigned long *actual_cnt
        cdef int *reason = NULL
        sicl.iread(self.inst, readbuf , 1024, reason, actual_cnt)
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("iread fail.",errno)
        return  readbuf.lstrip(self.startchar.encode('utf-8')).split(self.endchar.encode('utf-8'))[0].decode("utf-8")

    def ifread(self):
        """
        20180705測試是否依定要轉成encode=UTF8
        :return:
        """
        cdef char readbuf[1024]
        cdef unsigned long *actual_cnt
        cdef int *reason = NULL
        sicl.ifread(self.inst,readbuf , 1024, reason, actual_cnt)
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("ifread fail.",errno)
        return  readbuf.lstrip(self.startchar.encode('utf-8')).split(self.endchar.encode('utf-8'))[0].decode("utf-8")

    def iread_byte(self):
        cdef char readbuf[1024]
        cdef unsigned long *actual_cnt
        cdef int *reason = NULL
        sicl.iread(self.inst,readbuf , 1024, reason, actual_cnt)
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("iread_byte fail.",errno)
        return readbuf

    def iwaithdlr(self, timeout):
        sicl.iwaithdlr(timeout)
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("iwaithdlr fail.",errno)

    def iintroff(self):
        sicl.iintroff()
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("iintroff fail.",errno)

    def iintron(self):
        sicl.iintron()
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("iintron fail.",errno)

    def iclose(self):
        status = sicl.iclose(self.inst)
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("iclose fail.",errno)
        return status

    def itermchr(self, int tchr):
        sicl.itermchr(self.inst, tchr)
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("itermchr fail.",errno)

    def itrigger(self):
        sicl.itrigger(self.inst)
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("itrigger fail.",errno)

    def igpibsendcmd(self, buf):
        if not buf.endswith(self.endchar):
            buf = buf + self.endchar
        status = sicl.igpibsendcmd(self.inst, str.encode(buf), len(buf))
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("igpibsendcmd fail.",errno)
        return status

    def igetintfsess(self):
        sicl.igetintfsess(self.inst)
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("igetintfsess fail.",errno)

    def igpibatnctl(self, atnval):
        sicl.igpibatnctl(self.inst, atnval)
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("igpibatnctl fail.",errno)

    def igpibbusstatus(self, request):
        cdef int *result
        sicl.igpibbusstatus(self.inst, request, result)
        errno = sicl.igeterrno()
        if error_code.get(errno) is not None:
            raise SICLException("igpibbusstatus fail.",errno)
        return <int>result

    #inside the class definition
    def __reduce__(self):
        return (rebuild, (self.SICL_ADDRESS, self.endchar, self.startchar))

#standalone function
def rebuild( SICL_ADDRESS, endchar, startchar=''):
    s = SICL(SICL_ADDRESS, endchar, startchar)
    return s