; /macros/toolprobe_v3/_lib/Status.g
; Push a status line to all DWC clients AND the firmware console.
;
; Usage:
;   M98 P"/macros/toolprobe_v3/_lib/Status.g" S"toolprobe_v3: locating fixed probe"

if !exists(param.S)
  abort "Status.g: requires S<message>"

M118 P0 S{param.S}
echo {param.S}
