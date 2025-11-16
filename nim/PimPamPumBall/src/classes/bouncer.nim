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
  
  if self.side == Side.RIGHT:
    self.setScale(vector2(-1.0, 1.0))


method process(self: Bouncer; delta: float64) {.gdsync.} =
  discard

# Not terribly flexible for RIGHT side, but if I used it in LEFT mode with a symmetrical sprite, I think it can be on any position
# Which begs the question: do I really need the Side feature? XD
proc ball_collided(self: Bouncer, body: Node2D) {.gdsync, name: "_on_body_entered".} =
  if body.isInGroup("balls"):
    let ball: RigidBody2D = body as RigidBody2D

    if ball != nil:
      let collisionShape2d = self.bouncy_part_area_2d.getChildren()[0] as CollisionShape2D
      var impulse_direction: Vector2 = vector2(0.0, -1.0).rotated(self.globalRotation + collisionShape2d.rotation + PI/2)

      if self.side == Side.RIGHT:
        impulse_direction = impulse_direction.reflect(vector2(1.0, 0.0))

      print(impulse_direction)
      
      let impulse_vector = impulse_direction * self.bounce_force

      ball.linear_velocity = vector2(0.0, 0.0)
      ball.applyImpulse(impulse_vector)
