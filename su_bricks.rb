require "sketchup.rb"

module My_module
    
  def self.draw_straight_wall
    mod = Sketchup.active_model # Open model
    ent = mod.entities # All entities in model
    sel = mod.selection # Current selection

    prompts = ["Hoogte in meter", "Lengte in meter"]
    defaults = ["", ""]
    list = ["", ""]
    input = UI.inputbox(prompts, defaults, list, "Input your sizes please.")

    oorsprong = [0,0,0]
    hoogte = 400.mm
    breedte = 800.mm
    lengte = 1600.mm

    # Input in puntnotatie
    h_input = input[0].to_f.m
    l_input = input[1].to_f.m

    h_bricks = (h_input - h_input%hoogte)/hoogte
    l_bricks = (l_input - l_input%(lengte/2))/(lengte/2)
    
      
    cube = Sketchup.active_model.definitions.add("LongCubeAlongYAxis")
    points = Array.new
    points[0] = ORIGIN 
    points[1] = [0, lengte, 0] 
    points[2] = [breedte, lengte, 0] 
    points[3] = [breedte, 0, 0]
    newface = cube.entities.add_face(points)
    newface.reverse! if newface.normal.z < 0
    newface.pushpull(hoogte)
    
    smallcube = Sketchup.active_model.definitions.add("SmallCube")
    points_small = Array.new
    points_small[0] = ORIGIN
    points_small[1] = [0, lengte/2, 0]
    points_small[2] = [breedte, lengte/2, 0]
    points_small[3] = [breedte, 0, 0]
    newface = smallcube.entities.add_face(points_small)
    newface.reverse! if newface.normal.z < 0
    newface.pushpull(hoogte)
    
    @whole_blocks = 0
    @half_blocks = 0

    (0..h_bricks-1).each { |h_b|
        (0..l_bricks-3).step(2).each { |l_b|
            # Even rijen
            if (h_b%2==0)
              vector = Geom::Vector3d.new 0,l_b*lengte/2,h_b*hoogte
              t = Geom::Transformation.translation vector
              Sketchup.active_model.active_entities.add_instance(cube, t)
              @whole_blocks += 1
              # Halve eindblok
              if (l_bricks%2==1) && (l_b==l_bricks-3)
                vector = Geom::Vector3d.new 0,l_b*lengte/2+lengte,h_b*hoogte
                t = Geom::Transformation.translation vector
                Sketchup.active_model.active_entities.add_instance(smallcube, t)
                @half_blocks += 1
              elsif (l_bricks%2==0) && (l_b==l_bricks-4)
                vector = Geom::Vector3d.new 0,l_b*lengte/2+lengte,h_b*hoogte
                t = Geom::Transformation.translation vector
                Sketchup.active_model.active_entities.add_instance(cube, t)
                @whole_blocks += 1
              end

            # Oneven rijen
            elsif (h_b%2==1)
              vector = Geom::Vector3d.new 0,l_b*lengte/2+lengte/2,h_b*hoogte
              t = Geom::Transformation.translation vector
              Sketchup.active_model.active_entities.add_instance(cube, t)
              @whole_blocks += 1
              # Halve eindblok
              if (l_bricks%2==0) && (l_b==l_bricks-4)
                  vector = Geom::Vector3d.new 0,l_b*lengte/2+lengte*1.5,h_b*hoogte
                  t = Geom::Transformation.translation vector
                  Sketchup.active_model.active_entities.add_instance(smallcube, t)
                  @half_blocks += 1
              end
              # Halve beginblok
              if (l_b==0)
                vector = Geom::Vector3d.new 0,0,h_b*hoogte
                t = Geom::Transformation.translation vector
                Sketchup.active_model.active_entities.add_instance(smallcube, t)
                @half_blocks += 1
              end

            else
              # do nothing
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
mymenu.add_item("Draw Straight Wall"){My_module::draw_straight_wall}
mymenu.add_item("Calculate Blocks"){My_module::calculate_blocks}


  
    



