-- Import
local composer = require("composer")
local relayout = require("libs.relayout")
local widget = require("widget")

-- Variables
local _W, _H, _CX, _CY = relayout._W, relayout._H, relayout._CX, relayout._CY
local _grpMain

--local functions

-- Function to read CSV file
local function readCSV(filename)
    local path = system.pathForFile(filename, system.ResourceDirectory)
    local file = io.open(path, "r")
    local data = {}

    if file then
        for line in file:lines() do
            local columns = {}
            for value in line:gmatch("[^,]+") do
                table.insert(columns, value)
            end
            table.insert(data, columns)
        end
        io.close(file)
    else
        print("Error: Could not open CSV file")
    end

    return data
end

--calculate Euclidean distance
local function euclideanDistance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- calculate Manhattan distance
local function manhattanDistance(x1, y1, x2, y2)
    return math.abs(x2 - x1) + math.abs(y2 - y1)
end

--calculate Harmonic mean
local function harmonicMean(distances)
    local sum = 0
    local count = 0
    for _, distance in ipairs(distances) do
        if distance ~= 0 then
            sum = sum + (1 / distance)
            count = count + 1
        end
    end
    if count == 0 then
        return 0
    else
        return count / sum
    end
end

-- implement k-Nearest Neighbors algorithm
local function knnAlgorithm(data, x_input, y_input, k_input, distanceType, weightingScheme)
    local distances = {}

    print("Distance Type:", distanceType)
    print("Weighting Scheme:", weightingScheme)

    for i, row in ipairs(data) do
        local x_train = tonumber(row[1])
        local y_train = tonumber(row[2])
        local label = row[3]

        local distance
        if distanceType == "Euclidean" then
            distance = euclideanDistance(x_train, y_train, x_input, y_input)
        elseif distanceType == "Manhattan" then
            distance = manhattanDistance(x_train, y_train, x_input, y_input)
        else
            error("Invalid distance type. Use 'Euclidean' or 'Manhattan'.")
        end

        table.insert(distances, {distance = distance, label = label})
    end

    -- Sort distances
    table.sort(distances, function(a, b) return a.distance < b.distance end)

    --k nearest neighbors
    local nearestNeighbors = {}
    for i = 1, k_input do
        table.insert(nearestNeighbors, distances[i].label)
    end

    -- Calculate weights
    local weights = {}
    if weightingScheme == "Harmonic" then
        local distancesForHarmonic = {}
        for i = 1, k_input do
            table.insert(distancesForHarmonic, distances[i].distance)
        end
        local harmonicWeight = harmonicMean(distancesForHarmonic)
        for i = 1, k_input do
            table.insert(weights, harmonicWeight)
        end
    else
        for i = 1, k_input do
            table.insert(weights, 1)
        end
    end

    -- Count the occurrences of each label
    local counts = {}
    for i, label in ipairs(nearestNeighbors) do
        if counts[label] then
            counts[label] = counts[label] + weights[i]
        else
            counts[label] = weights[i]
        end
    end

    -- Find the label with the highest count
    local maxCount = 0
    local predictedLabel
    for label, count in pairs(counts) do
        if count > maxCount then
            maxCount = count
            predictedLabel = label
        end
    end

    return predictedLabel
end

-- Create a scatter plot
local function createScatterPlot(data)
    local plotXStart = 60
    local plotYStart = 605
    local plotWidth = _W - 100
    local plotHeight = _H - 560
    local circleRadius = 4 

    local minX, maxX, minY, maxY = 0, 10, 0, 10

    local scaleX = plotWidth / (maxX - minX)
    local scaleY = plotHeight / (maxY - minY)

    -- Labels for dots
    local labelA = display.newText(_grpMain, "class a", _CX-75, 365, "assets/fonts/Galada.ttf", 16)
    labelA.fill = {0, 0, 0}
    local labelB = display.newText(_grpMain, "class b", _CX+20, 365, "assets/fonts/Galada.ttf", 16)
    labelB.fill = {0, 0, 0}
    local labelu = display.newText(_grpMain, "inputs", _CX+115, 365, "assets/fonts/Galada.ttf", 16)
    labelu.fill = {0, 0, 0}
       
    local circleA = display.newCircle(_grpMain, _CX - 110, 365, 8)
    circleA:setFillColor(0, 0, 1)
    
    local circleB = display.newCircle(_grpMain, _CX - 15, 365, 8)
    circleB:setFillColor(1, 0, 0)

    local circleU = display.newCircle(_grpMain, _CX + 80, 365, 8)
    circleU:setFillColor(0, 1, 0)

    -- Create axis
    local xAxis = display.newLine(_grpMain, plotXStart, plotYStart, plotXStart + plotWidth, plotYStart)
    local yAxis = display.newLine(_grpMain, plotXStart, plotYStart, plotXStart, plotYStart - plotHeight)
    xAxis.strokeWidth = 4
    yAxis.strokeWidth = 3
    xAxis:setStrokeColor(0, 0, 0) 
    yAxis:setStrokeColor(0, 0, 0)  

    -- Add labels for axis
    for i = 0, 10 do
        local xLabel = display.newText(_grpMain, i, plotXStart + i * (plotWidth / 10), plotYStart + 20, native.systemFont, 16)
        xLabel:setFillColor(0)
    end

    for i = 0, 10 do
        local yLabel = display.newText(_grpMain, i, plotXStart - 30, plotYStart - i * (plotHeight / 10), native.systemFont, 16)
        yLabel:setFillColor(0)
    end

    -- Create grid lines
    for i = 1, 10 do
        local xPos = plotXStart + i * (plotWidth / 10)
        local gridLine = display.newLine(_grpMain, xPos, plotYStart, xPos, plotYStart - plotHeight)
        gridLine.strokeWidth = 1
        gridLine:setStrokeColor(0.5, 0.5, 0.5, 0.5)
    end
    for i = 1, 10 do
        local yPos = plotYStart - i * (plotHeight / 10)
        local gridLine = display.newLine(_grpMain, plotXStart, yPos, plotXStart + plotWidth, yPos)
        gridLine.strokeWidth = 1
        gridLine:setStrokeColor(0.5, 0.5, 0.5, 0.5)
    end

    -- Create dots
    for _, row in ipairs(data) do
        local x = tonumber(row[1])
        local y = tonumber(row[2])
        local label = row[3]
        local plotX = plotXStart + (x - minX) * scaleX
        local plotY = plotYStart - (y - minY) * scaleY 
        local color
        if label == "a" then
            color = {0, 0, 1}
        else
            color = {1, 0, 0}
        end
        local circle = display.newCircle(_grpMain, plotX, plotY, circleRadius)
        circle:setFillColor(unpack(color)) 
    end
end
-- Function to next scene
local function gotoApp()
    composer.removeScene("scenes.cal") 
    composer.gotoScene("scenes.app")
end

-- Scene
local scene = composer.newScene()

function scene:create(event)
    print("scene:create - cal")
    _grpMain = display.newGroup()
    self.view:insert(_grpMain)

    -- Background
    local background = display.newImageRect(_grpMain, "assets/images/background.png", _W, _H)
    background.x = _CX
    background.y = _CY

    local sceneGroup = self.view
    local params = event.params

    if params then
        local x_input = math.floor(params.x_input / 10)
        local y_input = math.floor(params.y_input / 10)
        local k_input = math.floor(params.k / 10)
        local distanceType = params.distanceType
        local weightingScheme = params.weightingScheme

        local inpTitle = display.newText("User inputs :", _CX-80, 60, "assets/fonts/Galada.ttf", 25)
        inpTitle.fill = { 0, 0, 0}
         _grpMain:insert(inpTitle)

        --display input params
        xText = display.newText(_grpMain, "X input: " .. x_input, _CX-90, 90, "assets/fonts/Galada.ttf", 20)
        xText.fill = {0, 0, 0}
    
        yText = display.newText(_grpMain, "Y input: " .. y_input, _CX-90, 120, "assets/fonts/Galada.ttf", 20)
        yText.fill = {0, 0, 0}
    
        kText = display.newText(_grpMain, "K: " .. k_input, _CX-110, 150, "assets/fonts/Galada.ttf", 20)
        kText.fill = {0, 0, 0}

        disText = display.newText(_grpMain, "Distance Type: " .. distanceType, _CX-27, 180, "assets/fonts/Galada.ttf", 20)
        disText.fill = {0, 0, 0}

        --display prediction summury

        prdTitle = display.newText("Prediction summery :", _CX-40, 225, "assets/fonts/Galada.ttf", 25)
        prdTitle.fill = {0, 0, 0}
        

        -- Read data from CSV file
        local data = readCSV("knn.csv")

        -- Predict using KNN algorithm
        local predictedLabel = knnAlgorithm(data, x_input, y_input, k_input, distanceType, weightingScheme)
        print("Predicted Class:", predictedLabel)
        prdText = display.newText(_grpMain, "Predicted class: " .. predictedLabel, _CX, 265, "assets/fonts/Galada.ttf", 20)
        prddis = display.newText(_grpMain, "user input values belongs to class :" .. predictedLabel, _CX, 285, "assets/fonts/Galada.ttf", 18)
        prddis.fill = {0, 0, 0}
        
        if predictedLabel == 'a' then
            prdText:setFillColor(0, 0, 1)
        elseif predictedLabel == 'b' then
            prdText:setFillColor(1, 0, 0)
        end

        _grpMain:insert(prdTitle)


        -- Create scatter plot
        createScatterPlot(data)

        -- Plot user input
        local circleRadius = 4 
        local minX, maxX, minY, maxY = 0, 10, 0, 10
        local plotXStart = 60
        local plotYStart = 605
        local plotWidth = _W - 100
        local plotHeight = _H - 560
        local scaleX = plotWidth / (maxX - minX)
        local scaleY = plotHeight / (maxY - minY)
        local plotX = plotXStart + (x_input - minX) * scaleX
        local plotY = plotYStart - (y_input - minY) * scaleY 
        local circle = display.newCircle(_grpMain, plotX, plotY, circleRadius)
        circle:setFillColor(0, 1, 0)
    end
    local btnCal = display.newRoundedRect(_grpMain, _CX, _CY+300,120,50,20)
    btnCal.fill = { 0, 0 ,0}
    btnCal.alpha = 0.4;

    local lableCal = display.newText("Back", _CX, _CY+300, "assets/fonts/Galada.ttf", 30)
    lableCal.fill = { 1, 1, 1}
    _grpMain:insert(lableCal)

    btnCal:addEventListener("tap", gotoApp)
end

-- Scene event listeners
scene:addEventListener("create", scene)

return scene
