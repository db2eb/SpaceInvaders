require "math"
love.graphics.setDefaultFilter('nearest','nearest')
enemy = {}
enemies_controller = {}
enemies_controller.enemies = {}
enemies_controller.image = love.graphics.newImage('meteor.png')

--initial load
function love.load()
	local music = love.audio.newSource('bgm.mp3','static')
	music:setLooping(true)
	love.audio.play(music)
	game_over = false
	game_win = false
	background = love.graphics.newImage('bg.png')
	player = {}
	player.x = 0
	player.y = 550
	player.bullets={}
	player.cooldown = 20
	player.speed = 7
	player.image = love.graphics.newImage('spaceship.png')
	player.fire_sound = love.audio.newSource('Laser_Shoot1.wav','static')
	player.fire_sound:setVolume(0.5)

	--shooting with cooldown mechanic
	player.fire = function()
		if player.cooldown <= 0 then
			love.audio.play(player.fire_sound)
			player.cooldown = 20
			bullet = {}
			bullet.x = player.x + 18
			bullet.y = player.y
			table.insert(player.bullets, bullet)
		end
	end
	--initial enemies
	for i=0, 5 do
		enemies_controller:spawnEnemy(i*140,0)
	end
end

--constantly running
function love.update(dt)
	player.cooldown = player.cooldown - 1
	--controls
	if love.keyboard.isDown("right") then
		player.x = player.x + player.speed
	elseif love.keyboard.isDown("left") then
		player.x = player.x - player.speed
	end
	if love.keyboard.isDown("up") then
		player.y = player.y - player.speed
	elseif love.keyboard.isDown("down") then
		player.y = player.y + player.speed
	end
	if love.keyboard.isDown("space") then
		player.fire()
	end
	if #enemies_controller.enemies == 0 then --# checks length
		game_win = true
	end

	for _,e in pairs(enemies_controller.enemies) do
		if e.y >= love.graphics.getHeight() then
			game_over = true
		end
		e.y = e.y + 1 * e.speed
	end

	for i,b in ipairs(player.bullets) do
		if b.y < 20 then 
			table.remove(player.bullets,i)
		end 
		b.y = b.y - 10
	end
	checkCollisions(enemies_controller.enemies,player.bullets)
end

function love.draw()
	love.graphics.draw(background)
	if game_over then
		love.graphics.print("Game Over!",100,100)
		return
	elseif game_win then
		love.graphics.print("You Win!",500,500)
	end
	--draw player
	love.graphics.setColor(255,255,255)
	love.graphics.draw(player.image, player.x , player.y ,0,.10)
	--draw enemies
	for _,e in pairs(enemies_controller.enemies) do
		love.graphics.draw(enemies_controller.image,e.x,e.y,0,.10)
	end
	--draw bullets
	love.graphics.setColor(255,255,255)
	for _,b in pairs(player.bullets) do
		love.graphics.rectangle("fill",b.x,b.y,10,10)
	end
end

--hash table for enemies
function enemies_controller:spawnEnemy(x,y)
	enemy = {}
	enemy.x = x
	enemy.y = y
	enemy.width = 40
	enemy.height = 40
	enemy.bullets={}
	enemy.cooldown = 20
	enemy.speed = 1
	table.insert(self.enemies, enemy)
end

--collision detector
function checkCollisions(enemies, bullets)
	for i,e in ipairs(enemies) do
		for _,b in pairs(bullets) do
			if b.y <= e.y + e.height and b.x > e.x and b.x <e.x + e.width then
				table.remove(enemies,i)
				table.remove(bullets,i)
				--spawn new enemy if killed
				enemies_controller:spawnEnemy(math.random(1,love.graphics.getWidth()-50),0)
			end
		end
	end
end