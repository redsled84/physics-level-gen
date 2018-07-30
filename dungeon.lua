local Kruskals = require 'kruskals'
local inspect  = require 'inspect'
local Delaunay = require 'delaunay'
      Point    = Delaunay.Point
      Edge     = Delaunay.Edge

local compare = function(a, b) if a:length() < b:length() then return a end end
function getMST(rooms)
	local points = { }
	for i = 1, #rooms do
	  local x, y
	  x, y = math.floor(rooms[i].x + rooms[i].w / 2), math.floor(rooms[i].y + rooms[i].h / 2)
	  points[#points + 1] = Point(x, y)
	end
	local edges = { }
	local triangles = Delaunay.triangulate(unpack(points))
	for i = 1, #triangles do
	  local p1, p2, p3
	  p1, p2, p3 = triangles[i].p1, triangles[i].p2, triangles[i].p3
	  local e1, e2, e3
	  e1, e2, e3 = Edge(p1, p2), Edge(p2, p3), Edge(p1, p3)
	  if #edges > 1 then
	    if not edgeAdded(edges, e1) then
	      edges[#edges + 1] = e1
	    end
	    if not edgeAdded(edges, e2) then
	      edges[#edges + 1] = e2
	    end
	    if not edgeAdded(edges, e3) then
	      edges[#edges + 1] = e3
	    end
	  else
	    edges[#edges + 1] = e1
	    edges[#edges + 1] = e2
	    edges[#edges + 1] = e3
	  end
	end
	table.sort(edges, compare)
	return Kruskals(points, edges), edges
end

function distance(edge)
    return math.sqrt((edge.p2.x - edge.p1.x) ^ 2 + (edge.p2.y - edge.p1.y) ^ 2)
end

function addExtraEdges(tree, edges, n)
    local og = #tree
    repeat
        local i = math.random(1, #edges)
        if not edgeAdded(tree, edges[i]) and distance(edges[i]) < 250 then
            tree[#tree+1] = edges[i]
        end
    until #tree == og + n
end

function edgeAdded(edges, e)
    for i = #edges, 1, -1 do
        local temp = edges[i]
        if temp:same(e) then
            return true
        end
    end
    return false
end

