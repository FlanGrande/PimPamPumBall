#nim/nimmain/src/classes/ball.nim
import gdext
import gdext/classes/gdRigidBody2D

type Ball* {.gdsync.} = ptr object of RigidBody2D
  speed* {.gdexport.}: float32 = 200

method ready(self: Ball) {.gdsync.} =
  discard

method process(self: Ball; delta: float64) {.gdsync.} =
  discard
