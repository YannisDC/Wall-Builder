require "sketchup.rb"

module WallBuilder
    
  def self.draw_straight_wall
    mod = Sketchup.active_model # Open model
    ent = mod.entities # All entities in model
    sel = mod.selection # Current selection

    prompts = ["Height in m", "Length in m"]
    defaults = ["", ""]
    list = ["", ""]
    input = UI.inputbox(prompts, defaults, list, "Input your sizes please.")

    origin = [0,0,0]
    height = 400.mm
    width = 800.mm
    length = 1600.mm

    # Input in dot notation
    h_input = input[0].to_f.m
    l_input = input[1].to_f.m

    h_bricks = (h_input - h_input%height)/height
    l_bricks = (l_input - l_input%(length/2))/(length/2)
    
      
    cube = Sketchup.active_model.definitions.add("LongCubeAlongYAxis")
    points = Array.new
    points[0] = ORIGIN 
    points[1] = [0, length, 0] 
    points[2] = [width, length, 0] 
    points[3] = [width, 0, 0]
    newface = cube.entities.add_face(points)
    newface.reverse! if newface.normal.z < 0
    newface.pushpull(height)
    
    smallcube = Sketchup.active_model.definitions.add("SmallCube")
    points_small = Array.new
    points_small[0] = ORIGIN
    points_small[1] = [0, length/2, 0]
    points_small[2] = [width, length/2, 0]
    points_small[3] = [width, 0, 0]
    newface = smallcube.entities.add_face(points_small)
    newface.reverse! if newface.normal.z < 0
    newface.pushpull(height)
    
    @whole_blocks = 0
    @half_blocks = 0

    (0..h_bricks-1).each { |h_b|
        (0..l_bricks-3).step(2).each { |l_b|
            # Even rows
            if (h_b%2==0)
              vector = Geom::Vector3d.new 0,l_b*length/2,h_b*height
              t = Geom::Transformation.translation vector
              Sketchup.active_model.active_entities.add_instance(cube, t)
              @whole_blocks += 1
              # Half ending block
              if (l_bricks%2==1) && (l_b==l_bricks-3)
                vector = Geom::Vector3d.new 0,l_b*length/2+length,h_b*height
                t = Geom::Transformation.translation vector
                Sketchup.active_model.active_entities.add_instance(smallcube, t)
                @half_blocks += 1
              elsif (l_bricks%2==0) && (l_b==l_bricks-4)
                vector = Geom::Vector3d.new 0,l_b*length/2+length,h_b*height
                t = Geom::Transformation.translation vector
                Sketchup.active_model.active_entities.add_instance(cube, t)
                @whole_blocks += 1
              end

              # Odd rows
            elsif (h_b%2==1)
              vector = Geom::Vector3d.new 0,l_b*length/2+length/2,h_b*height
              t = Geom::Transformation.translation vector
              Sketchup.active_model.active_entities.add_instance(cube, t)
              @whole_blocks += 1
              # Half starting block
              if (l_bricks%2==0) && (l_b==l_bricks-4)
                  vector = Geom::Vector3d.new 0,l_b*length/2+length*1.5,h_b*height
                  t = Geom::Transformation.translation vector
                  Sketchup.active_model.active_entities.add_instance(smallcube, t)
                  @half_blocks += 1
              end
              # Half ending block
              if (l_b==0)
                vector = Geom::Vector3d.new 0,0,h_b*height
                t = Geom::Transformation.translation vector
                Sketchup.active_model.active_entities.add_instance(smallcube, t)
                @half_blocks += 1
              end

            else
              # pass
            end
        }
    }
  return @whole_blocks,@half_blocks
  end
  
  def self.calculate_blocks
    UI.messagebox("You have #{@whole_blocks} whole blocks and #{@half_blocks} half blocks")
  end
end

mymenu = UI.menu("Plugins").add_submenu("Brick Wall Drawing Tool")
mymenu.add_item("Draw Straight Wall"){WallBuilder::draw_straight_wall}
mymenu.add_item("Calculate Blocks"){WallBuilder::calculate_blocks}


  
    



