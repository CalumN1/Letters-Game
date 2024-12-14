io.stdout:setvbuf('no')

function love.load()

	arenaWidth = 1440
	arenaHeight = 1080

	print("INITIALISING!!")

	tiles = {{x=100,y=700,r=50,l="A",power="none",used=false,pos=0},{x=300,y=700,r=50,l="C",power="none",used=false,pos=0},
	{x=500,y=700,r=50,l="T",power="none",used=false,pos=0}}
	words = {}

	error = {message = "", timerMax=5, timer=0}
	score = 0

	for line in love.filesystem.lines("words.txt") do
		print(line)
		table.insert(words, string.upper(line)) 
	end


	fontSizeBig = 44
	fontSizeSmall = 24

	fontBig = love.graphics.newFont(fontSizeBig)
	fontSmall = love.graphics.newFont(fontSizeSmall)
	love.graphics.setFont(fontSmall)

	dragging = false
	draggedTile = 0 
	inputText = ""

	love.keyboard.setTextInput( true )

end

function love.update(dt)


	if dragging then
		tiles[draggedTile].x = love.mouse.getX()
		tiles[draggedTile].y = love.mouse.getY()	
	end

	if error.timer > 0 then
		error.timer = error.timer - dt
	end
end


function love.draw(mouseX, mouseY)

	love.graphics.setBackgroundColor(0.2,0,0.1)


	drawTiles()

	drawInputArea()

	love.graphics.printf("Score: "..score, 0 ,arenaHeight/4, arenaWidth/2, 'center')

	if error.timer > 0 then
		love.graphics.setFont(fontBig)
		love.graphics.printf(error.message, 0 ,arenaHeight/3, arenaWidth, 'center')

	end
	
end

function drawInputArea()

	love.graphics.setFont(fontBig)

	love.graphics.printf(inputText, 0 ,arenaHeight/2, arenaWidth, 'center')

end

function drawTiles()

	love.graphics.setFont(fontSmall)

	for tileIndex, tile in ipairs(tiles) do
		if tile.used then
			love.graphics.setColor(0.1,0.3,0.3)
		else
			love.graphics.setColor(0,0.5,0.5)
		end
		love.graphics.circle('fill',tile.x,tile.y,tile.r)
		love.graphics.setColor(0,0,0)
		love.graphics.printf(tile.l, tile.x-tile.r,tile.y-(fontSizeSmall/2),2*tile.r,'center')
	end
end


function distancebetween(x1,y1,x2,y2)

	return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)

end

function isMouseInTile()
	
	for tileIndex, tile in ipairs(tiles) do
		--print( node.x, node.y)
		if distancebetween(love.mouse.getX(), love.mouse.getY(), tile.x, tile.y) < tile.r+10 then
			return tileIndex
		end
	end
	return 0
end


function manualSplit(aGivenString)


end


function love.mousepressed(mouseX, mouseY)
	draggedTile = isMouseInTile()
	if isMouseInTile() ~= 0 then
		dragging = true
	end
end


function love.mousereleased(mouseX, mouseY)
	dragging = false
	draggedTile = 0
end

function love.keypressed(key)
	print(key)
    if key == "backspace" and inputText ~= "" then
    	inputText = string.sub(inputText, 1, #inputText-1)
    	for tileIndex, tile in ipairs(tiles) do
    		if tile.pos == #inputText then
    			tile.pos = 0
    			tile.used = false
    		end
    	end
    elseif key == "return" and inputText ~= "" then
    	checkSubmission()
    else
    	--inputText = inputText .. tiles[1].l
		for tileIndex, tile in ipairs(tiles) do -- sanitizes the input
	        if tile.l == string.upper(key) and tile.pos == 0 and #inputText < 100 then-- if char is allowed 
	            inputText = inputText .. tile.l -- append what was typed
	            tile.used=true
	            tile.pos = #inputText-1
	            break
	        end
	    end

    end
end

function checkSubmission()
	print(inputText)
	local valid = false

	for wordIndex, word in ipairs(words) do
		if inputText == word then
			print("ACCEPTED WORD!")
			valid = true
			scoreSubmission()
			break		
		end
	end
	if valid ~= true then
		error.message = "Invalid Word"
		error.timer = error.timerMax
	end

end

function scoreSubmission()
	score = score+ #inputText 
	for tileIndex, tile in ipairs(tiles) do
		if tile.used == true then
			tile.pos = -1
		end
	end
end