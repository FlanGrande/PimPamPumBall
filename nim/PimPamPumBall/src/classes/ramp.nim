#nim/nimmain/src/classes/ramp.nim
import gdext
import gdext/classes/gdNode2D
import gdext/classes/gdStaticBody2D
import gdext/classes/gdLine2D
import gdext/classes/gdCollisionShape2D
import gdext/classes/gdCollisionPolygon2D
import gdext/classes/gdCircleShape2D
import gdext/classes/gdGeometry2D
import gdext/classes/gdPolygon2D
import gdext/classes/gdArea2D

type Ramp* {.gdsync.} = ptr object of Node2D
  rampStaticBody2D* {.gdexport.}: StaticBody2D
  line2D* {.gdexport.}: Line2D
  entryTrigger1Area2D* {.gdexport.}: Area2D
  exitTrigger1Area2D* {.gdexport.}: Area2D
  entryTrigger2Area2D* {.gdexport.}: Area2D
  exitTrigger2Area2D* {.gdexport.}: Area2D
  line_width: float32
  line_points: PackedVector2Array
  ramp_collision_polygon: CollisionPolygon2D

proc createCollisionPolygons(self: Ramp)


method ready(self: Ramp) {.gdsync.} =
  self.line_width = self.line2D.width
  self.line_points = self.line2D.points

  self.createCollisionPolygons()

method process(self: Ramp, delta: float64) {.gdsync.} =
  discard


proc createCollisionPolygons(self: Ramp) =
  let wall_polygons: TypedArray[PackedVector2Array] = Geometry2D.offsetPolyline(self.line_points, self.line_width/2, Geometry2D_PolyJoinType.joinRound, Geometry2D_PolyEndType.endRound)
  # self.ramp_collision_polygon = instantiate(CollisionPolygon2D)
  
  # offsetPolyline returns an Array of PackedVector2Array (e.g. a list of polygons)
  for wall_polygon in wall_polygons:
    let new_collision_polygon_2d: CollisionPolygon2D = instantiate(CollisionPolygon2D)
    new_collision_polygon_2d.buildMode = CollisionPolygon2D_BuildMode.buildSegments
    new_collision_polygon_2d.setPolygon(wall_polygon)
    self.rampStaticBody2D.addChild(new_collision_polygon_2d)
    # discard full_polygon.appendArray(wall_polygon)
    # discard self.ramp_collision_polygon.setPolygon().appendArray(wall_polygon)

  if self.line_points.size() >= 4:
    self.entryTrigger1Area2D.position = self.line_points[1]
    self.exitTrigger1Area2D.position = self.line_points[0]
    self.entryTrigger2Area2D.position = self.line_points[self.line_points.size() - 2]
    self.exitTrigger2Area2D.position = self.line_points[self.line_points.size() - 1]
    
    let collision_shape_1: CollisionShape2D = self.entryTrigger1Area2D.getChildren()[0] as CollisionShape2D
    let collision_shape_2: CollisionShape2D = self.exitTrigger1Area2D.getChildren()[0] as CollisionShape2D
    let collision_shape_3: CollisionShape2D = self.entryTrigger2Area2D.getChildren()[0] as CollisionShape2D
    let collision_shape_4: CollisionShape2D = self.exitTrigger2Area2D.getChildren()[0] as CollisionShape2D
    
    let collision_circle_1: CircleShape2D = collision_shape_1.shape[] as CircleShape2D
    let collision_circle_2: CircleShape2D = collision_shape_2.shape[] as CircleShape2D
    let collision_circle_3: CircleShape2D = collision_shape_3.shape[] as CircleShape2D
    let collision_circle_4: CircleShape2D = collision_shape_4.shape[] as CircleShape2D
    
    collision_circle_1.radius = self.line_width
    collision_circle_2.radius = self.line_width
    collision_circle_3.radius = self.line_width
    collision_circle_4.radius = self.line_width

