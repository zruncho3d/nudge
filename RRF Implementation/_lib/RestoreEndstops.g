; /macros/toolprobe_v3/_lib/RestoreEndstops.g
; Defensive full restore of XYZ endstop configuration. Called at the start of
; top-level macros (in case a previous run aborted with endstops swapped) and
; at the end of every top-level macro.

M98 P"/macros/toolprobe_v3/_lib/UseProbeAsEndstop.g" A0 R1
M98 P"/macros/toolprobe_v3/_lib/UseProbeAsEndstop.g" A1 R1
M98 P"/macros/toolprobe_v3/_lib/UseProbeAsEndstop.g" A2 R1
