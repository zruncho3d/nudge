; /macros/toolprobe_v3/CalibrateToolRange.g
;
; Iterate a range of tools and calibrate each via CalibrateActiveTool.g.
;
; Params:
;   start = first tool index (default 0)
;   end   = last tool index  (default 0)
;
; Preconditions:
;   - LocateToolProbe.g has run (tp3_located == true)
;
; Endstops are restored after each tool and at the end (and CalibrateActiveTool
; itself restores on every exit, so a failure on one tool does not leave the
; machine in a bad state).

M98 P"/macros/toolprobe_v3/globals.g"
M98 P"/macros/toolprobe_v3/state.g"
M98 P"/macros/toolprobe_v3/_lib/RestoreEndstops.g"

if !global.tp3_located
  abort "CalibrateToolRange: run LocateToolProbe.g first."

var start = exists(param.start) ? floor(param.start) : 0
var end   = exists(param.end)   ? floor(param.end)   : 0

if var.start > var.end
  abort "CalibrateToolRange: start (" ^ var.start ^ ") > end (" ^ var.end ^ ")"

M98 P"/macros/toolprobe_v3/_lib/Status.g" S{"toolprobe_v3: calibrating tools T" ^ var.start ^ ".." ^ var.end}

while var.start <= var.end
  if var.start >= #tools
    M98 P"/macros/toolprobe_v3/_lib/Status.g" S{"T" ^ var.start ^ " not defined, skipping"}
  else
    T{var.start}
    if state.currentTool != var.start
      M98 P"/macros/toolprobe_v3/_lib/Status.g" S{"T" ^ var.start ^ " select failed, skipping"}
    else
      M98 P"/macros/toolprobe_v3/CalibrateActiveTool.g"

  set var.start = var.start + 1

T-1
M98 P"/macros/toolprobe_v3/_lib/RestoreEndstops.g"
M98 P"/macros/toolprobe_v3/_lib/Status.g" S"toolprobe_v3: tool range calibration complete"
