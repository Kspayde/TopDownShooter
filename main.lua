function love.load()
    math.randomseed(os.time())  --so the zombies start off in random places in each game because random now starts zombies in same spot each time game loads
                                  -- os.time() gets random numbers so the start of our game will be more unique  

    sprites = {}
    sprites.background = love.graphics.newImage('sprites/background.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.zombie = love.graphics.newImage('sprites/zombie.png')

    player = {}
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
    player.speed = 180

    myFont = love.graphics.newFont(30)

    zombies = {}

    bullets = {}

    gameState = 1 -- represents main menu and gamestate 2 represents game play. 
    score = 0
    maxTime = 2
    timer = maxTime

end

function love.update(dt)
    if gameState == 2 then
        if love.keyboard.isDown("d") and player.x < love.graphics.getWidth() then -- and player.x < love.graphics.getWidth() stops player from being able to remove
            player.x = player.x + player.speed*dt                                      -- walk off screen to the right 
        end

        if love.keyboard.isDown("a") and player.x > 0 then  --and player.x > 0 stops player from being able to walk of the screen. to the left
            player.x = player.x - player.speed*dt
        end

        if love.keyboard.isDown("w") and player.y > 0 then   -- player.y > 0  stops player being able to walk up past the game
            player.y = player.y - player.speed*dt
        end

        if love.keyboard.isDown("s") and player.y < love.graphics.getHeight() then -- and player.y > love.graphics.getWidth() from going down left and up have x, y cordinates and right and down do not so have to use .getwidth or .getheight
            player.y = player.y + player.speed*dt
        end
    end

    for i,z in ipairs(zombies) do 
        z.x = z.x + (math.cos( zombiePlayerAngle(z) ) * z.speed * dt)
        z.y = z.y + (math.sin( zombiePlayerAngle(z) ) * z.speed * dt)

        if distanceBetween (z.x, z.y, player.x, player.y) < 30 then  -- zombies hit player collsion detection 
            for i,z in ipairs(zombies) do 
                zombies[i] = nil
                gameState = 1
                player.x = love.graphics.getWidth()/2   -- puts player back in the middle after getting hit
                player.y = love.graphics.getHeight()/2   -- puts player back in the middle after getting hit
            end
        end
    end

    for i,b in ipairs(bullets) do 
        b.x = b.x + (math.cos( b.direction ) * b.speed * dt)
        b.y = b.y + (math.sin( b.direction ) * b.speed * dt)
    end 

    for i=#bullets, 1, -1 do 
        local b = bullets[i]
        if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then 
            table.remove(bullets, i)
        end

    end

    -- tests for collision with zombies and bullets and removes both if collision has been detected. 
    for i,z in ipairs(zombies) do 
        for j,b in ipairs(bullets) do
            --testing for collision between zombies and bullets
            if distanceBetween(z.x, z.y, b.x, b.y) < 20 then
                z.dead = true
                b.dead = true
                score = score + 1
            end
        end
    end

    for i=#zombies,1,-1 do 
        local z = zombies[i]
        if z.dead == true then 
            table.remove(zombies, i) -- removes zombies when it by bulles
        end
    end

    for i=#bullets,1,-1 do 
        local b = bullets[i]
        if b.dead == true then 
            table.remove(bullets, i) -- removes bullets when hits a zombie
        end
    end

    -- timer and maxTime for zombie spawning 
    if gameState == 2 then 
        timer = timer - dt
        if timer <= 0 then 
            spawnZombie()
            maxTime = 0.95 * maxTime
            timer = maxTime
        end
    end

end

function love.draw()
    love.graphics.draw(sprites.background, 0, 0)

    if gameState == 1 then 
        love.graphics.setFont(myFont)
        love.graphics.printf("Click anywhere to begin!", 0, 50, love.graphics.getWidth(), "center")
    end
    love.graphics.printf("Score: " .. score, 0, love.graphics.getHeight()-100, love.graphics.getWidth(), "center")

    love.graphics.draw(sprites.player, player.x, player.y, playerMouseAngle(), nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)

    for i,z in ipairs(zombies) do 
        love.graphics.draw(sprites.zombie, z.x, z.y, zombiePlayerAngle(z), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)

    end

    for i,b in ipairs(bullets) do 
        love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.5, nil, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
    end


end

function love.keypressed( key )
     if key == "space" then
        spawnZombie()
     end

end

function love.mousepressed(x, y, button)
    if button == 1 and gameState == 2 then -- will check to see if we are in game state and if so it will shoot a bullet 
        spawnBullet()
    elseif button == 1 and gameState == 1 then  -- if not then it will start the game and put it in gamestate 2 
        gameState = 2
        maxTime = 2
        timer = maxTime
        score = 0
         
    end 

end


function playerMouseAngle()
    return math.atan2( player.y - love.mouse.getY(), player.x - love.mouse.getX() ) + math.pi

end

function zombiePlayerAngle(enemy)
    return math.atan2( player.y - enemy.y, player.x - enemy.x )

end

function spawnZombie()
    local zombie = {}
    zombie.x = 0
    zombie.y = 0
    zombie.speed = 140 
    zombie.dead = false

    local side = math.random(1, 4)
    if side == 1 then 
        zombie.x = -30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 2 then 
        zombie.x = love.graphics.getWidth() + 30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 3 then 
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = -30
    elseif side == 4 then 
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = love.graphics.getHeight() + 30  
    end

    table.insert(zombies, zombie)

end

function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 500
    bullet.dead = false
    bullet.direction = playerMouseAngle()
    table.insert(bullets, bullet)
end

function distanceBetween (x1, y1, x2, y2)
    return math.sqrt( (x2 -x1)^2 + (y2 - y1)^2 )
end

