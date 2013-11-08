# -----------------------------------------------------------------------------
#
# Copyright (C) 2013 by John Watkinson
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# -----------------------------------------------------------------------------

class TileMapView extends SceneView
  constructor : (@canvas, @tileMap) ->
    super(@canvas)
    @$el = $ @canvas
    @camera = new Rect(0,0,9,9)
    @cameraScale = 1.0
    # DEBUG CODE REMOVE TODO
    $(window).on 'keydown', (e) =>
      return @camera.point.x -= 1 if e.keyCode is 37 # Left
      return @camera.point.y -= 1 if e.keyCode is 38 # Up
      return @camera.point.x += 1 if e.keyCode is 39 # Right
      return @camera.point.y += 1 if e.keyCode is 40 # Down

  drawTile : (icon, x, y) =>
    coords = Data.sprites[icon];
    throw new Error "Missing sprite data for: #{icon}" if not coords
    image = Screen.TEXTURES[coords.source]
    throw new Error "Missing image: #{icon}" if not coords
    srcX = coords.x
    srcY = coords.y
    srcW = srcH = Screen.UNIT
    dstX = x * Screen.UNIT * @cameraScale
    dstY = y * Screen.UNIT * @cameraScale
    dstW = dstH = Screen.UNIT  * @cameraScale
    @context.drawImage(image,srcX, srcY, srcW, srcH, dstX, dstY, dstW, dstH)

  render: () ->
    # Pin camera zoom to match canvas size
    @cameraScale = @screenToWorld(@$el.width()) / @camera.extent.x
    @context.save();
    @context.fillStyle = "rgb(0,0,0)"
    @context.fillRect(0, 0, @canvas.width, @canvas.height)

    clipRect = new Rect(@camera).clip @tileMap.bounds
    # Adjust render position for camera.
    worldTilePos = @worldToScreen(@tileMap.bounds.point,@cameraScale)
    worldCameraPos = @worldToScreen(@camera.point,@cameraScale)
    @context.translate(worldTilePos.x - worldCameraPos.x,worldTilePos.y - worldCameraPos.y)

    xStride = clipRect.point.x + clipRect.extent.x
    yStride = clipRect.point.y + clipRect.extent.y
    for y in [clipRect.point.y ... yStride]
      for x in [clipRect.point.x ... xStride]
        tile = @tileMap.getTerrainIcon x, y
        @drawTile(tile, x, y) if tile
    for feature in @tileMap.map.features
      continue if not clipRect.pointInRect feature.x, feature.y
      @drawTile(feature.icon, feature.x, feature.y) if feature.icon

    @context.restore()
