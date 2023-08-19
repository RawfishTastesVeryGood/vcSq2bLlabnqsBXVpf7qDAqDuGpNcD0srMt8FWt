local initiated = false

local MazeSize = nil
local CellSize = nil
local CellModel = nil

local CellContainer = Instance.new("Folder", workspace)
CellContainer.Name = "Cells"

local Maze = {}
local Cell = {}

local function updateWalls(cell)
	local walls = {
		cell.W,
		cell.A,
		cell.S,
		cell.D
	}

	for index, wall in pairs(walls) do
		if not cell.Walls[index] then
			wall.Transparency = 1
			wall.CanCollide = false
			for _, obj in pairs(wall:GetChildren()) do
				obj.Transparency = 1
			end
		end
	end
end

local function RemoveWalls(a, b)
	local aPos = a.Position
	local bPos = b.Position
	
	local x = aPos.X - bPos.X
	if x == 1 then
		a.Walls[2] = false
		b.Walls[4] = false
	elseif x == -1 then
		a.Walls[4] = false
		b.Walls[2] = false
	end
	
	local y = aPos.Y - bPos.Y
	if y == 1 then
		a.Walls[1] = false
		b.Walls[3] = false
	elseif y == -1 then
		a.Walls[3] = false
		b.Walls[1] = false
	end
	
	updateWalls(a)
	updateWalls(b)
end

function Maze.init(config)
	MazeSize = config.MazeSize
	CellSize = config.CellSize
	CellModel = config.CellModel
	
	initiated = true
end

function Maze.new(x, y)
	if not initiated then
		error("Please use .init before using any functions", 2)
	end
	
	local new = {}
	setmetatable(new, {__index = Cell})
	
	local newCell = CellModel:Clone()
	
	new.Model = newCell
	new.Position = Vector2.new(x, y)
	
	new.Walls = {true, true, true, true}
	new.Visited = false
	
	new.Base = newCell.Base
	new.W = newCell.W
	new.A = newCell.A
	new.S = newCell.S
	new.D = newCell.D
	
	return new
end

function Cell:Create()
	if not initiated then
		error("Please use .init before using any functions", 2)
	end

	if self == nil or typeof(self) ~= "table" then
		error("Expected ':' not '.' calling member function Create", 2)
	end
	
	local model = self.Model
	local position = self.Position
	
	model.Parent = CellContainer
	model:SetPrimaryPartCFrame(CFrame.new(position.X * CellSize.width, 0, position.Y * CellSize.height))
end

function Maze.draw(grid)
	if not initiated then
		error("Please use .init before using any functions", 2)
	end

	local current = grid[1][1]
	local unvisitedCells = MazeSize.width * MazeSize.height
	local stack = {}
	
	while unvisitedCells > 1 do
		current.Visited = true
		
		local nextCell = current:GetRandomNeighbor(grid)
		if nextCell then
			nextCell.Visited = true
			unvisitedCells -= 1
			table.insert(stack, current)
			RemoveWalls(current, nextCell)
			current = nextCell
		elseif #stack > 0 then
			current = table.remove(stack, #stack)
		end
	end
end

function Cell:GetRandomNeighbor(grid)
	if not initiated then
		error("Please use .init before using any functions", 2)
	end

	if self == nil or typeof(self) ~= "table" then
		error("Expected ':' not '.' calling member function Create", 2)
	end
	
	local neighbors = {}
	
	local Position = self.Position
	local X = Position.X
	local Y = Position.Y
	
	local currentColum = grid[X]
	
	assert(currentColum ~= nil, `Colum {X} does not exist.`)
	
	-- up and down
	for i = -1, 1, 2 do
		local neighbor = currentColum[Y + i]
		if neighbor and not neighbor.Visited then
			table.insert(neighbors, neighbor)
		end
	end
	
	-- left and right
	for i = X - 1, X + 1, 2 do
		local columData = grid[i]
		if columData and columData[Y] and not columData[Y].Visited then
			table.insert(neighbors, columData[Y])
		end
	end
	
	if #neighbors > 0 then
		return neighbors[math.random(1, #neighbors)]
	else
		return nil
	end
end

return Maze
