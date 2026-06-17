--dbgstr = ''

function convertFile2Obj(cont)
	startSection1Index,endSection1Index,startSection2Index,endSection2Index = 0,0,0,0
	startIndex = 0
	k = 0
	Obj = {}
	while true do
		startSection1Index, endSection1Index = string.find(cont, 'facet', startIndex)
		if startSection1Index == nil then
			break
		end
		k = k + 1
		startSection2Index, endSection2Index = string.find(cont, 'endfacet', startIndex)
		plane = {}
		sectionStr = string.sub(cont, endSection1Index, startSection2Index)
		endVIndex = 0
		while true do
			point = {}
			startVIndex,endVIndex = string.find(sectionStr, 'vertex', endVIndex)
			if startVIndex == nil then
				break
			end
			i = endVIndex
			for k=1,3,1 do
				i = i+1
				while true do
					tmpNum = string.sub(sectionStr, endVIndex+2, i)
					--dbgstr = dbgstr .. tmpNum
					hasEnd,a = string.find(tmpNum, string.char(32))
					if hasEnd ~= nil then
						i = i - 1
						break
					end
					hasEnd,a = string.find(tmpNum, string.char(10))
					if hasEnd ~= nil then
						i = i - 1
						break
					end
					
					i = i + 1
				end
				Num = string.sub(sectionStr, endVIndex+1, i)
				--dbgstr = dbgstr .. Num
				table.insert(point, tonumber(Num))
				endVIndex = i
			end
			table.insert(plane, point)
		end
		table.insert(Obj, plane)
		startIndex = endSection2Index
	end
	return Obj;
end

function love.load()
    planeO = {{{-6,-1,1},{6,-1,1},{6,-3,1},{-6,-3,1}}, {{-6,-1,10},{6,-1,10},{6,-3,10},{-6,-3,10}}}
    Mleg = {{{1,2,4},{3,2,4},{3,-1,4},{1,-1,4}}, {{1,2,5},{3,2,5},{3,-1,5},{1,-1,5}}}
    Mhat1 = {{{-1,3,2},{5,3,2},{5,2,2},{-1,2,2}}, {{-1,3,7},{5,3,7},{5,2,7},{-1,2,7}}}
    Mhat2 = {{{0,4,3},{4,4,3},{4,3,3},{0,3,3}}, {{0,4,6},{4,4,6},{4,3,6},{0,3,6}}}
    
    conePolygon = {{{-10,0,5},{-9,0,5},{-10,0,4},{-9,0,4}},{{-10,0,5},{-10,0,4},{-9.5,1,4.5}},{{-9,0,5},{-9,0,4},{-9.5,1,4.5}},{{-10,0,5},{-9,0,5},{-9.5,1,4.5}},{{-10,0,4},{-9,0,4},{-9.5,1,4.5}}}
	
	monkeFile,bytes = love.filesystem.read('Monke.stl')
	monke = convertFile2Obj(monkeFile)
    scrW, scrH = love.graphics.getWidth(), love.graphics.getHeight()
    scrWraw, scrHraw = scrW, scrH
    lightSrc = {{0,0,0},{{0.3,0.3,0.3},{0.9,0.9,0.9}},{0,0,1},{0,0,0}}
    Xoffset, Yoffset = 0,0
    
    if scrW < scrH then
        Yoffset = (scrH-scrW)/2
        scrH = scrW
    elseif scrH < scrW then
        Xoffset = (scrW-scrH)/2
        scrW = scrH
    end
    
    pressed = false
    
    scrWhl, scrHhl = scrW/2, scrH/2
    modZ, modX, modY, lightMod, glRotXZ, glRotXY, glRotYZ = 0, 0, 0, 0, 0, 0, 0
    flipZ, flipX, flipY = 1, 1, 1
    Vmove, Hmove, NPPmove, mvSpeed, Rmove, Umove = 0,0,0,10,0,0
	osSTR = love.system.getOS()
	if osSTR == "Android" or osSTR == "iOS" then
		mobile = true
	else
		mobile = false
		love.window.setMode(1280, 720, {resizable=true, vsync=0, minwidth=320, minheight=240})
	end
end

function love.update(dt)
	
	

    function setLight(origin,color,direction,distance)
        lightSrc[1][1] = origin[1]
        lightSrc[1][2] = origin[2]
        lightSrc[1][3] = origin[3]
        
        lightSrc[2][1][1] = color[1][1]
        lightSrc[2][1][2] = color[1][2]
        lightSrc[2][1][3] = color[1][3]
        lightSrc[2][2][1] = color[2][1]
        lightSrc[2][2][2] = color[2][2]
        lightSrc[2][2][3] = color[2][3]
        
        lightSrc[3][1] = direction[1]
        lightSrc[3][2] = direction[2]
        lightSrc[3][3] = direction[3]
        
        lightSrc[4][1] = distance[1]
        lightSrc[4][2] = distance[2]
        lightSrc[4][3] = distance[3]
    end
    
    function useLightSource(pX,pY,pZ)
        lgtNums = {}
        sum,div = 0,0
        if lightSrc[3][1] ~= 0 then
            dist = math.abs(pX-lightSrc[1][1])/lightSrc[4][1]
            table.insert(lgtNums, dist)
        end
        if lightSrc[3][2] ~= 0 then
            dist = math.abs(pY-lightSrc[1][2])/lightSrc[4][2]
            table.insert(lgtNums, dist)
        end
        if lightSrc[3][3] ~= 0 then
            dist = math.abs(pY-lightSrc[1][3])/lightSrc[4][3]
            table.insert(lgtNums, dist)
        end
        for i,v in ipairs(lgtNums) do
            div = i
            sum = sum + v
        end
        if div == 0 then
			love.graphics.setColor(lightSrc[2][1][1],lightSrc[2][1][2],lightSrc[2][1][3])
		else
			midl = 1 - (sum/div)
		end
        clrR = lightSrc[2][2][1]+(lightSrc[2][1][1] - lightSrc[2][2][1])*midl
        clrG = lightSrc[2][2][2]+(lightSrc[2][1][2] - lightSrc[2][2][2])*midl
        clrB = lightSrc[2][2][3]+(lightSrc[2][1][3] - lightSrc[2][2][3])*midl
        love.graphics.setColor(clrR,clrG,clrB)
    end
    
    function projectPoint (p3d)
		jp={0,0,0}
		jp[1], jp[2], jp[3] = rotatePointXZ(p3d[1], p3d[2], p3d[3])
		jp[1], jp[2], jp[3] = rotatePointXY(jp[1], jp[2], jp[3])
		jp[1], jp[2], jp[3] = rotatePointYZ(jp[1], jp[2], jp[3])
        if jp[3]+modZ < 0 then
            Z = 0.000001
        else
            Z = jp[3]+modZ
        end
            pj2d = {(jp[1]+modX)/Z, (jp[2]+modY)/Z}
            return pj2d
    end
    
    function convertProjection(pj2d)
        scrP = {(pj2d[1]+1)*scrWhl+Xoffset, (pj2d[2]-1)*(-scrHhl)+Yoffset}
        return scrP
    end
    
	function presses_register_mobile()
		touches = love.touch.getTouches()
		if touches[1] == nil then
			Vmove, Hmove, NPPmove = 0,0,0
			pressed = false
		end
		
		for i,v in ipairs(touches) do
			tchX, tchY = love.touch.getPosition(v)
			if tchX > 50 and tchX < 70 and tchY > 258 and tchY < 278 then
				Vmove = -1
			elseif tchX > 50 and tchX < 70 and tchY > 318 and tchY < 338 then
				Vmove = 1
			else
				Vmove = 0
			end
			
			if tchX > 758 and tchX < 778 and tchY > 258 and tchY < 278 then
				NPPmove = -1
			elseif tchX > 758 and tchX < 778 and tchY > 318 and tchY < 338 then
				NPPmove = 1
			else
				NPPmove = 0
			end
			
			if tchX > 20 and tchX < 40 and tchY > 288 and tchY < 308 then
				Hmove = 1
			elseif tchX > 80 and tchX < 100 and tchY > 288 and tchY < 308 then
				Hmove = -1
			else
				Hmove = 0
			end
			
			if tchX > 708 and tchX < 728 and tchY > 20 and tchY < 40 and pressed ~= true then
				mvSpeed = mvSpeed - 1
				pressed = true
			elseif tchX > 808 and tchX < 828 and tchY > 20 and tchY < 40 and pressed ~= true then
				mvSpeed = mvSpeed + 1
				pressed = true
			end
			
			if tchX > 788 and tchX < 808 and tchY > 138 and tchY < 158 then
				Rmove = -1
			elseif tchX > 728 and tchX < 748 and tchY > 138 and tchY < 158 then
				Rmove = 1
			else
				Rmove = 0
			end
			
			if tchX > 758 and tchX < 778 and tchY > 168 and tchY < 188 then
				Umove = 1
			elseif tchX > 758 and tchX < 778 and tchY > 108 and tchY < 128 then
				Umove = -1
			else
				Umove = 0
			end
		end
	end
	
	function presses_register_pc()
		function love.keypressed(key)
			if key == 'kp+' then
				mvSpeed = mvSpeed + 1
			elseif key == 'kp-' then
				mvSpeed = mvSpeed - 1
			end
		end
		
		if love.keyboard.isDown('w') then
			Vmove = -1
		elseif love.keyboard.isDown('s') then
			Vmove = 1
		else
			Vmove = 0
		end
		
		if love.keyboard.isDown('a') then
			Hmove = 1
		elseif love.keyboard.isDown('d') then
			Hmove = -1
		else
			Hmove = 0
		end
		
		if love.keyboard.isDown('space') then
			NPPmove = -1
		elseif love.keyboard.isDown('lshift') then
			NPPmove = 1
		else
			NPPmove = 0
		end
		
		if love.keyboard.isDown('left') then
			Rmove = 1
		elseif love.keyboard.isDown('right') then
			Rmove = -1
		else
			Rmove = 0
		end
		
		if love.keyboard.isDown('up') then
			Umove = -1
		elseif love.keyboard.isDown('down') then
			Umove = 1
		else
			Umove = 0
		end
	end
	
	if mobile then
		presses_register_mobile()
	else
		presses_register_pc()
	end
	
	glRotXZ = glRotXZ+dt*Rmove
	glRotYZ = glRotYZ+dt*Umove
	
    modZ = modZ + Vmove*dt*mvSpeed
    modX = modX + Hmove*dt*mvSpeed
    modY = modY + NPPmove*dt*mvSpeed
	lightMod = lightMod + 0.5*dt
	
	function rotatePointXZ(ptX, ptY, ptZ)
		tmpSin,tmpCos = math.sin(glRotXZ),math.cos(glRotXZ)
		ptX = ptX*tmpCos-ptZ*tmpSin
		ptZ = ptX*tmpSin+ptZ*tmpCos
		return ptX, ptY, ptZ
	end
	
	function rotatePointXY(ptX, ptY, ptZ)
		tmpSin,tmpCos = math.sin(glRotXY),math.cos(glRotXY)
		ptX = ptX*tmpCos-ptY*tmpSin
		ptY = ptY*tmpSin+ptY*tmpCos
		return ptX, ptY, ptZ
	end
	
	function rotatePointYZ(ptX, ptY, ptZ)
		tmpSin,tmpCos = math.sin(glRotYZ),math.cos(glRotYZ)
		ptY = ptY*tmpCos-ptZ*tmpSin
		ptZ = ptY*tmpSin+ptZ*tmpCos
		return ptX, ptY, ptZ
	end
    
end

function love.draw()
    function drawCube(cube)
        for i=1,4,1 do
            p1aRAW = projectPoint(cube[1][i])
            p1a = convertProjection(p1aRAW)
            p1bRAW = projectPoint(cube[2][i])
            p1b = convertProjection(p1bRAW)
            if i == 4 then
                rond = 1
            else
                rond = i + 1
            end
            p2aRAW = projectPoint(cube[1][rond])
            p2a = convertProjection(p2aRAW)
            p2bRAW = projectPoint(cube[2][rond])
            p2b = convertProjection(p2bRAW)
            
            love.graphics.setColor(0, 1, 0)
            if tchX ~= nil and tchY ~= nil then
                love.graphics.print(tchX,0,0)
                love.graphics.print(tchY,0,20)
            end
            if p1a[1] ~= false and p2a[1] ~= false then
                love.graphics.line(p1a[1], p1a[2], p2a[1], p2a[2])
            end
            if p1b[1] ~= false and p2b[1] ~= false then
                love.graphics.line(p1b[1], p1b[2], p2b[1], p2b[2])
            end
            
            if p1a[1] ~= false and p1b[1] ~= false then
                love.graphics.line(p1b[1], p1b[2], p1a[1], p1a[2])
            end
        end
    end
    
    function drawPolyModel(model)
        for i,poly in ipairs(model) do
            polygon = {}
            pntCordsX,pntCordsY,pntCordsZ = {},{},{}
            isBehind = true
            for j,jpoint in ipairs(poly) do
                if jpoint[3]+modZ > 0 then
                    isBehind = false
                    break
                end
            end
            
            if isBehind == false then
            
                for j,jpoint in ipairs(poly) do
                    table.insert(pntCordsZ, jp[3])
                    table.insert(pntCordsY, jp[2])
                    table.insert(pntCordsX, jp[1])
                    proj2d = projectPoint(jpoint)
                    scrPoint = convertProjection(proj2d)
                    table.insert(polygon,scrPoint[1])
                    table.insert(polygon,scrPoint[2])
                end
                MAX = pntCordsX[1]
                for i,v in ipairs(pntCordsX) do
                    if v > MAX then
                        MAX = v
                    end
                end
                PCX = MAX
                MAX = pntCordsY[1]
                for i,v in ipairs(pntCordsY) do
                    if v > MAX then
                        MAX = v
                    end
                end
                PCY = MAX
                MAX = pntCordsZ[1]
                for i,v in ipairs(pntCordsZ) do
                    if v > MAX then
                        MAX = v
                    end
                end
                PCZ = MAX
                useLightSource(PCX,PCY,PCZ)
                love.graphics.polygon('fill', polygon)
            end
        end
    end
    drawCube(planeO)
    drawCube(Mleg)
    drawCube(Mhat1)
    drawCube(Mhat2)
    
    drawPolyModel(conePolygon)
	setLight({-2,0.5,1},{{0.8,0.8,0.8},{0.1,0.1,0.1}},{1,1,1},{4,4,4})
    drawPolyModel(monke)
	
	if mobile then
		love.graphics.setColor(0.74, 0.74, 0.74)
		love.graphics.rectangle('fill',50,258,20,20)
		love.graphics.rectangle('fill',50,318,20,20)
		love.graphics.rectangle('fill',20,288,20,20)
		love.graphics.rectangle('fill',80,288,20,20)
		love.graphics.rectangle('fill',708,20,20,20)
		love.graphics.rectangle('fill',808,20,20,20)
		love.graphics.rectangle('fill',758,258,20,20)
		love.graphics.rectangle('fill',758,318,20,20)
		love.graphics.rectangle('fill',788,138,20,20)
		love.graphics.rectangle('fill',728,138,20,20)
		love.graphics.rectangle('fill',758,168,20,20)
		love.graphics.rectangle('fill',758,108,20,20)
		love.graphics.setColor(1,1,1)
		love.graphics.print('Speed:', 738, 0)
		love.graphics.print(mvSpeed, 748, 20)
	else
		love.graphics.setColor(1,1,1)
		love.graphics.print('Speed:', 0, 20)
		love.graphics.print(mvSpeed, 0, 40)
	end
	love.graphics.print('R3E rotational mess v0.forgor.2', 0, 0)
end