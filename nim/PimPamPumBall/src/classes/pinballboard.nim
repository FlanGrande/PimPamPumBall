#nim/nimmain/src/classes/pinballboard.nim
import gdext
import gdext/classes/gdNode2D
import gdext/classes/gdRigidBody2D
import gdext/classes/gdArea2D
import gdext/classes/gdInputEvent
import gdext/classes/gdPhysicsServer2D
import classes/Ball

type PinballBoard* {.gdsync.} = ptr object of Node2D
  lose_area* {.gdexport.}: Area2D
  ball_spawn* {.gdexport.}: Node2D

# proc ball_lost(self: PinballBoard): Error {.gdsync, signal.}

method ready(self: PinballBoard) {.gdsync.} =
  discard self.lose_area.connect("body_entered", self.callable("_on_body_entered"))

method process(self: PinballBoard; delta: float64) {.gdsync.} =
  discard

method input(self: PinballBoard; event: GdRef[InputEvent]) {.gdsync.} =
  discard

proc ball_lost(self: PinballBoard, body: Node2D) {.gdsync, name: "_on_body_entered".} =
  if body.isInGroup("balls"):
    let ball: RigidBody2D = body as RigidBody2D

    if ball != nil:
      print("hi")
      ball.position = self.ball_spawn.position
      ball.linear_velocity = vector2(0.0, 0.0)
      ball.angular_velocity = 0.0
      ball.globalTransform = self.ball_spawn.globalTransform
      PhysicsServer2D.bodySetState(ball.getRid(), PhysicsServer2D_BodyState.bodyStateTransform, variant(self.ball_spawn.globalTransform))
      ball.resetPhysicsInterpolation()
