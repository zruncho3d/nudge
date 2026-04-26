; /macros/toolprobe_v3/state.g
; Runtime cache populated by LocateToolProbe.g and the leaf macros.
; Loads globals.g first so this file is safe to run standalone.

M98 P"/macros/toolprobe_v3/globals.g"

; --- Located probe (machine frame, T-1) ---
if !exists(global.tp3_located)
  global tp3_located = false
if !exists(global.tp3_probeX)
  global tp3_probeX = global.tp3_probeSeedX
if !exists(global.tp3_probeY)
  global tp3_probeY = global.tp3_probeSeedY
if !exists(global.tp3_probeZPlane)
  global tp3_probeZPlane = global.tp3_probeSeedZGuess

; Workspace Z offset that was active when probeZPlane was captured. Used by
; CalibrateActiveTool to detect "autoz happened since LocateToolProbe" and
; demand a RefreshProbeZPlane.g run. Sentinel value -9999 means never set.
if !exists(global.tp3_probeZPlaneFrame)
  global tp3_probeZPlaneFrame = -9999

; --- Last-touch scratch globals (written by leaf macros) ---
if !exists(global.tp3_lastEdge)
  global tp3_lastEdge = 0
if !exists(global.tp3_lastCenter)
  global tp3_lastCenter = 0
if !exists(global.tp3_lastSpan)
  global tp3_lastSpan = 0
if !exists(global.tp3_lastZ)
  global tp3_lastZ = 0
if !exists(global.tp3_discoveredEngageZ)
  global tp3_discoveredEngageZ = 0
if !exists(global.tp3_probeTriggered)
  global tp3_probeTriggered = false
