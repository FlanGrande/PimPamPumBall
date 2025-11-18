#nim/nimmain/src/classes/ball.nim
import gdext
import gdext/classes/gdNode2D
import gdext/classes/gdRigidBody2D
import pinballboard

type Ball* {.gdsync.} = ptr object of RigidBody2D
  speed* {.gdexport.}: float32 = 200


method ready(self: Ball) {.gdsync.} =
  let parent: PinballBoard = self.getParent() as PinballBoard
  discard parent.connect("ball_lost", self.callable("_on_ball_lost"))

method process(self: Ball; delta: float64) {.gdsync.} =
  discard


proc on_ball_lost(self: PinballBoard) {.gdsync, name: "_on_ball_lost".} =
  print("hi")
  discard
