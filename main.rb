require 'ruby2d'

# consts
HEIGH = 480
WIDTH = HEIGH * 2

MAP_SIZE = 8
TILE_SIZE = (WIDTH / 2) / MAP_SIZE
RAYS_DENSITY = 120
SCALE = (WIDTH / 2) / RAYS_DENSITY
 
set width:   WIDTH
set heigh:   HEIGH
set fps_cap: 30
set title:   'raycasting'

class Player
  attr_accessor :x, :y, :forward
  attr_reader :player_angle

  def initialize(map)
    @x = HEIGH / 2
    @y = WIDTH / 4
    @player_angle = Math::PI
    @fow = Math::PI / 3
    @half_fow = @fow / 2
    @step_angle = @fow / RAYS_DENSITY 
    @forward = true
    @map = map
  end 

  def draw
    Circle.new(x: @x, y: @y, color: 'red', radius: 10)
  end 

  def move_up
    @x += -Math.sin(@player_angle) * 5
    @y += Math.cos(@player_angle) * 5
  end

  def move_down
    @x -= -Math.sin(@player_angle) * 5
    @y -= Math.cos(@player_angle) * 5
  end

  def move_left
    @player_angle -= 0.1
  end

  def move_right
    @player_angle += 0.1
  end

  def draw_fow
    # define left most angle of FOV
    start_angle = @player_angle - @half_fow

    for ray in (0...RAYS_DENSITY) do
      for depth in (0...480) do
          # get ray target coordinates
          target_x = @x - Math.sin(start_angle) * depth
          target_y = @y + Math.cos(start_angle) * depth

          # convert target X, Y coordinates to map col, row
          col = (target_x / TILE_SIZE).to_i
          row = (target_y / TILE_SIZE).to_i
          
          # ray hits the condition
          if @map[row][col] == 1
            Square.new(x: col * TILE_SIZE, y: row * TILE_SIZE, size: TILE_SIZE - 1, color: 'green')

            # draw casted ray
            Line.new(x1: @x, 
              y1: @y, 
              x2: target_x, 
              y2: target_y, 
              size: 1, 
              color: 'yellow')
            
            # wall shading
            color = 255 / (1 + depth * depth * 0.0001)
            rgb_to_hex(color)

            # fix fish eye effect
            depth *= Math.cos(@player_angle - start_angle)

            # calculate wall height
            wall_height = 21000 / (depth + 0.0001)

            # fix stuck at the wall
            wall_height = HEIGH if wall_height > HEIGH
            
            # draw a wall 
            Rectangle.new(x: HEIGH + ray * SCALE, 
            y: (HEIGH / 2) - wall_height / 2, 
            width: SCALE, 
            height: wall_height, color: rgb_to_hex(color) )
            break
          end
      end
      start_angle += @step_angle
    end
  end

  private 
  def rgb_to_hex(rgb)
   '#' + %i[red green blue].map { |c| rgb.to_i.to_s(16).rjust(2, '0') }.join
  end
end 


def draw_map(map)
  map.each_with_index do |row, i|
    row.each_with_index do |_, j|
      if map[i][j] == 1 
        Square.new(x: j * TILE_SIZE, y: i * TILE_SIZE, size: TILE_SIZE - 1, color: 'gray')
      else
        Square.new(x: j * TILE_SIZE, y: i * TILE_SIZE, size: TILE_SIZE - 1, color: 'white')
      end 
    end
  end 
end

def draw_3d_background
  Image.new('sky.jpg', x: 480 , y: 0 , width: 480 , height: HEIGH / 2)
  Rectangle.new(x: 480 , y: HEIGH / 2 , width: 480 , height: HEIGH / 2, color: '#646464')
end

# 0 - empty  space, 1 - wall 
map = [
  [1,1,1,1,1,1,1,1],
  [1,0,1,0,0,0,0,1],
  [1,0,1,0,0,1,1,1],
  [1,0,1,0,0,0,0,1],
  [1,0,0,0,0,0,0,1],
  [1,0,0,0,0,0,0,1],
  [1,0,0,1,1,0,0,1],
  [1,1,1,1,1,1,1,1]
  ]

player = Player.new(map)

update do
  clear
  draw_map(map)
  draw_3d_background
  player.draw
  player.draw_fow

  col = (player.x / TILE_SIZE).to_i
  row = (player.y / TILE_SIZE).to_i

  if map[row][col] == 1
    if player.forward
      player.x -= -Math.sin(player.player_angle) * 5
      player.y -= Math.cos(player.player_angle) * 5
    else
      player.x += -Math.sin(player.player_angle) * 5
      player.y += Math.cos(player.player_angle) * 5
    end
  end
end 

on :key_held do |event|
  if event.key == 'up'
    player.forward = true
    player.move_up
  elsif event.key == 'down'
    player.move_down
    player.forward = false
  elsif event.key == 'left'
    player.move_left
  elsif event.key == 'right'
    player.move_right
  end
end

show 
