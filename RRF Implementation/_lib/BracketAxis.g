; /macros/toolprobe_v3/_lib/BracketAxis.g
;
; Bracket the dome on one axis: scan from -R to find the minus-side edge,
; then scan from +R to find the plus-side edge. Returns center and span.
;
; Params:
;   A = axis (0 = X, 1 = Y)
;   C = center estimate (machine frame)
;   R = half-window: start scans this far from C
;   Z = engagement Z (machine frame)
;
; Outputs:
;   global.tp3_lastCenter
;   global.tp3_lastSpan

M98 P"/macros/toolprobe_v3/globals.g"
M98 P"/macros/toolprobe_v3/state.g"

if !exists(param.A) || !exists(param.C) || !exists(param.R) || !exists(param.Z)
  abort "BracketAxis: requires A, C, R, Z"

; Minus-side scan: start at C - R, scan in +1 direction
M98 P"/macros/toolprobe_v3/_lib/ScanEdgeNative.g" A{param.A} D1 S{param.C - param.R} Z{param.Z}
var minus = global.tp3_lastEdge

; Plus-side scan: start at C + R, scan in -1 direction
M98 P"/macros/toolprobe_v3/_lib/ScanEdgeNative.g" A{param.A} D-1 S{param.C + param.R} Z{param.Z}
var plus = global.tp3_lastEdge

set global.tp3_lastSpan = var.plus - var.minus
set global.tp3_lastCenter = (var.plus + var.minus) / 2

if global.tp3_lastSpan <= 0
  abort "BracketAxis: invalid span. minus=" ^ var.minus ^ " plus=" ^ var.plus

var axisName = (param.A == 0) ? "X" : "Y"
M98 P"/macros/toolprobe_v3/_lib/Status.g" S{"bracket " ^ var.axisName ^ ": center=" ^ global.tp3_lastCenter ^ ", span=" ^ global.tp3_lastSpan}
