-- Settings
local default_count = 8
local default_time	= 0.25

-- Extra
--	For other numbers of frames use the following. x is the paintings number. a is the frames count. b the time per frame.
local frames = {
--	{x, a, b},
	{1, 16, 0.125}, -- 16 frames for the first animated painting
}



-- Count the number of pictures.
local function get_picture(number)
	local filename	= minetest.get_modpath("gemalde").."/textures/gemalde_animated_"..number..".png"
	local file		= io.open(filename, "r")
	if file ~= nil then io.close(file) return true else return false end
end

local N = 1
while get_picture(N) == true do
	N = N + 1
end
N = N - 1

-- functions
local construct= function(pos)
	pos.x = math.floor(pos.x+0.5)
	pos.y = math.floor(pos.y+0.5)
	pos.z = math.floor(pos.z+0.5)
    local node = minetest.env:get_node(pos)

	local length = string.len (node.name)
	local number = string.sub (node.name, 23, length)

	local param2 = node.param2
	local entity_name = "gemalde:animated_"..number..""
		-- check in what direction the node is placed; spawn the entitiy.
		local offset = 0.45+(math.random()/40)
		if param2 == 0 then
			pos.z = pos.z + offset
			local gemalde = minetest.env:add_entity(pos, entity_name)
			gemalde:setyaw(0)
		elseif param2 == 1 then
			pos.x = pos.x + offset
			local gemalde = minetest.env:add_entity(pos, entity_name)
			gemalde:setyaw(math.pi*1.5)
		elseif param2 == 2 then
			pos.z = pos.z - offset
			local gemalde = minetest.env:add_entity(pos, entity_name)
			gemalde:setyaw(math.pi)
		elseif param2 == 3 then
			pos.x = pos.x - offset
			local gemalde = minetest.env:add_entity(pos, entity_name)
			gemalde:setyaw(math.pi/2)
		end
end

local destruct = function(pos)
	local node = minetest.env:get_node(pos)
	
	local length = string.len (node.name)
	local number = string.sub (node.name, 23, length)
	
    local objects = minetest.env:get_objects_inside_radius(pos, 0.5)
    for _, v in ipairs(objects) do
        if v:get_entity_name() == "gemalde:animated_"..number.."" then
            v:remove()
        end
    end
end

-- register for each picture
for n=1, N do

local groups = {choppy=2, dig_immediate=2, animated_picture=1, not_in_creative_inventory=1}
if n == 1 then
	groups = {choppy=2, dig_immediate=2, animated_picture=1}
end

-- inivisible node
minetest.register_node("gemalde:node_animated_"..n.."", {
    description = "Animation #"..n.."",
    inventory_image = "gemalde_animated_node.png",
    wield_image = "gemalde_animated_node.png",
    paramtype = "light",
	sunlight_propagates = true,
    paramtype2 = "facedir",
    drawtype = "airlike",
	walkable = false,
    selection_box = {type = "fixed", fixed = {-0.5, -0.5, 0.4, 0.5, 0.5, 0.5}},
	tiles = {"gemalde_animated_"..n..".png"},
    groups = groups,
	
	on_rightclick = function(pos, node, clicker)
	
		local length = string.len (node.name)
		local number = string.sub (node.name, 23, length)
		
		if number == tostring(N) then
			number = 1
		else
			number = number +1
		end
--		print("[gemalde] number is "..number.."")
		node.name = "gemalde:node_animated_"..number..""
		minetest.env:set_node(pos, node)
	end,

    on_construct = function(pos)
        construct(pos)
    end,
    on_destruct = function(pos)
        destruct(pos)
    end,
})

local frames_count = default_count
local frames_time = default_time
for _,frames in ipairs(frames) do
	if frames[1] == n then
		frames_count = frames[2]
		frames_time = frames[3]
	end
end

-- visible picture
minetest.register_entity("gemalde:animated_"..n.."", {
    collisionbox = { 0, 0, 0, 0, 0, 0 },
    visual = "upright_sprite",
	visual_size = {x=3, y=3},
    textures = {"gemalde_animated_texture.png"},
	number = n,
	timer = 0,
	anim_step = 0,
	frames_count = frames_count,
	frames_time = frames_time,
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer < frames_time then 
			return
		end
		self.timer = 0
		self.anim_step = (self.anim_step+1)%self.frames_count
		self.object:set_properties({
			textures = {
				"gemalde_animated_"..self.number..".png^[verticalframe:"..self.frames_count..":"..self.anim_step.."]"
			},
		})
	end,
})

-- crafts
if n < N then
minetest.register_craft({
	output = 'gemalde:node_animated_'..n..'',
	recipe = {
		{'gemalde:node_animated_'..(n+1)..''},
	}
})
end

n = n + 1

end

-- close the craft loop
minetest.register_craft({
	output = 'gemalde:node_animated_'..N..'',
	recipe = {
		{'gemalde:node_animated_1'},
	}
})

-- initial craft
minetest.register_craft({
	output = 'gemalde:node_animated_1',
	recipe = {
		{'default:book', 'default:book'},
		{'default:book', 'default:book'},
		{'default:book', 'default:book'},
	}
})

-- reset several pictures to #1
minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_animated_1 2',
	recipe = {'group:animated_picture', 'group:animated_picture'},
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_animated_1 3',
	recipe = {'group:animated_picture', 'group:animated_picture', 'group:animated_picture'},
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_animated_1 4',
	recipe = {
		'group:animated_picture', 'group:animated_picture', 'group:animated_picture', 
		'group:animated_picture'
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_animated_1 5',
	recipe = {
		'group:animated_picture', 'group:animated_picture', 'group:animated_picture', 
		'group:animated_picture', 'group:animated_picture'
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_animated_1 6',
	recipe = {
		'group:animated_picture', 'group:animated_picture', 'group:animated_picture', 
		'group:animated_picture', 'group:animated_picture', 'group:animated_picture'
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_animated_1 7',
	recipe = {
		'group:animated_picture', 'group:animated_picture', 'group:animated_picture', 
		'group:animated_picture', 'group:animated_picture', 'group:animated_picture', 
		'group:animated_picture'
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_animated_1 8',
	recipe = {
		'group:animated_picture', 'group:animated_picture', 'group:animated_picture', 
		'group:animated_picture', 'group:animated_picture', 'group:animated_picture', 
		'group:animated_picture', 'group:animated_picture'
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_animated_1 9',
	recipe = {
			'group:animated_picture', 'group:animated_picture', 'group:animated_picture', 
			'group:animated_picture', 'group:animated_picture', 'group:animated_picture', 
			'group:animated_picture', 'group:animated_picture', 'group:animated_picture'
		}
})

--[[
minetest.register_abm({
    nodenames = {"group:animated_picture"},
	interval = 5,
	chance = 1,
	action = function(pos, node)
		local length = string.len (node.name)
		local number = string.sub (node.name, 23, length)
	
		local objects = minetest.env:get_objects_inside_radius(pos, 0.5)
		for _, v in ipairs(objects) do
			if v:get_entity_name() == "gemalde:animated_"..number.."" then
				local yaw = v:getyaw()
				local yaw = math.ceil(yaw/(math.pi/2))
				if yaw == 3 then yaw = 1 elseif yaw == 1 then yaw = 3 end
				if node.param2 ~= yaw then
					destruct(pos)
					construct(pos)
					print("[gemalde] yaw="..yaw.." param2="..node.param2.."")
				end
			end
		end
	end,
})
--]]
