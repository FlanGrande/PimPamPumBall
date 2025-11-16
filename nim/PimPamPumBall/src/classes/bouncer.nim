#nim/nimmain/src/classes/bouncer.nim
import gdext
import gdext/classes/gdNode2D
import gdext/classes/gdStaticBody2D
import gdext/classes/gdRigidBody2D
import gdext/classes/gdArea2D
import gdext/classes/gdCollisionShape2D


type
  Side = enum LEFT, RIGHT

type Bouncer* {.gdsync.} = ptr object of StaticBody2D
  side* {.gdexport.}: Side
  bouncy_part_area_2d* {.gdexport.}: Area2D
  bounce_force* {.gdexport.}: float32


method ready(self: Bouncer) {.gdsync.} =
  discard self.bouncy_part_area_2d.connect("body_entered", self.callable("_on_body_entered"))
  
  if self.scale.x == -1.0:
    self.side = Side.RIGHT


method process(self: Bouncer; delta: float64) {.gdsync.} =
  discard


proc ball_collided(self: Bouncer, body: Node2D) {.gdsync, name: "_on_body_entered".} =
  if body.isInGroup("balls"):
    let ball: RigidBody2D = body as RigidBody2D

    if ball != nil:
      let collisionShape2d = self.bouncy_part_area_2d.getChildren()[0] as CollisionShape2D
      var impulse_direction = vector2(0.0, -1.0).rotated(collisionShape2d.rotation + PI/2)

      if self.side == Side.RIGHT:
        impulse_direction = impulse_direction.rotated(collisionShape2d.rotation - PI/2)

      print(impulse_direction)
      
      let impulse_vector = impulse_direction * self.bounce_force

      ball.linear_velocity = vector2(0.0, 0.0)
      ball.applyImpulse(impulse_vector)
