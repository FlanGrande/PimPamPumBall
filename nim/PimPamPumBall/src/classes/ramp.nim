#nim/nimmain/src/classes/ramp.nim
import gdext
import gdext/classes/gdNode2D

type Ramp* {.gdsync.} = ptr object of Node2D


method ready(self: Ramp) {.gdsync.} =
  discard

method process(self: Ramp, delta: float64) {.gdsync.} =
  discard
