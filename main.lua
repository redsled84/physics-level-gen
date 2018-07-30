require "dungeon"
local inspect = require "inspect"
local bump = require "bump"
local world = love.physics.newWorld(0, 0, true)

local bodies = {}

function lehmer(state, max)
    return (state * max) % (math.pow(2, 32) - 5)
end
function roundm(n, m) return math.floor((n + m - 1)/m)*m end
function newBox(x, y, w, h)
    local o = {x=x, y=y, w=w, h=h} 
    o.body = love.physics.newBody(world, x + w/2, y + h/2, "dynamic")
    o.shape = love.physics.newRectangleShape(w, h)
    o.fixture = love.physics.newFixture(o.body, o.shape)
    o.fixture:setDensity(2000)
    o.body:setFixedRotation(true)
    return o
end

function drawBodies()
    for i = 1, #bodies do
        local pbody = bodies[i]
        if pbody.body:isAwake() then
            love.graphics.setColor(0, 0, .3, .3)
        else
            love.graphics.setColor(.3, .3, 0)
            if pbody.w >= 70 or pbody.h >= 50 then
                love.graphics.setColor(.6, .1, .1)
            end
        end
        love.graphics.polygon("fill", pbody.body:getWorldPoints(pbody.shape:getPoints()))
        love.graphics.rectangle("fill", pbody.x, pbody.y, pbody.w, pbody.h)
        love.graphics.setColor(.2, .2, .8, .9)
        love.graphics.polygon("line", pbody.body:getWorldPoints(pbody.shape:getPoints()))
        love.graphics.rectangle("line", pbody.x, pbody.y, pbody.w, pbody.h)

    end
end

function drawTree(canDraw, tree)
    if not canDraw then return end
    love.graphics.setColor(0, .9, .2)
    for i = 1, #tree do
        local edge = tree[i]
        love.graphics.line(edge.p1.x, edge.p1.y, edge.p2.x, edge.p2.y)
        love.graphics.circle("line", edge.p1.x, edge.p1.y, 5)
        love.graphics.circle("line", edge.p2.x, edge.p2.y, 5)
    end
end

function getRandomPoint(xOffset, yOffset, maxRadius)
    local radius = math.random(0, maxRadius)
    local theta = math.random(0, 2 * math.pi * 100)
    return xOffset + radius * 2 * math.cos(theta), yOffset + radius * 0.5 * math.sin(theta)
end

function love.load()
    love.graphics.setBackgroundColor(.1, .1, .1)
    love.window.setMode(1280, 720)
    math.randomseed(os.time())
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    for i = 1, math.random(5, 9) do
        local x, y = getRandomPoint(screenWidth / 2, screenHeight / 2, 245)
        local w = math.random(6, 9) * 10
        local h = math.random(4, 7) * 10
        table.insert(bodies, newBox(x, y, w, h))
    end
    for i = 1, 45 do
        local x, y = getRandomPoint(screenWidth / 2, screenHeight / 2, 200)
        local w = math.random(4, 7) * 10
        local h = math.random(3, 5) * 10
        table.insert(bodies, newBox(x, y, w, h))
    end
    for i = 1, 45 do
        local x, y = getRandomPoint(screenWidth / 2, screenHeight / 2, 300)
        local w = math.random(2, 5) * 10
        local h = math.random(2, 4) * 10
        table.insert(bodies, newBox(x, y, w, h))
    end
 
    
end

local tree
local allSleep, sleepCount = false, 0
local createdMST = false
local state = math.random(1, 200)
function love.update(dt)
    world:update(dt)

    local m = 4
    sleepCount = 0
    for i = 1, #bodies do
        local pbody = bodies[i]
        local x, y = pbody.body:getWorldCenter()
        x, y = roundm(x, m), roundm(y, m)
        pbody.x, pbody.y = x - pbody.w/2, y - pbody.h/2

        if not pbody.body:isAwake() then
            sleepCount = sleepCount + 1
        end
        if sleepCount >= #bodies then
            allSleep = true
        end
    end

    if not createdMST and allSleep then
        local edges
        createdMST = true
        tree, edges = getMST(bodies)
        addExtraEdges(tree, edges, math.floor(#edges * .15))
    end
end

function love.draw()
    drawBodies()
    drawTree(allSleep, tree)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if key == "r" then
        love.event.quit("restart")
    end
end
