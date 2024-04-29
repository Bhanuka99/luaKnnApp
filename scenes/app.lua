-- Import
local composer = require("composer")
local relayout = require("libs.relayout")
local widget = require("widget")

-- Variables
local x_input, y_input, k = 0, 0, 1
local distanceType
local weightingScheme

-- Layout
local _W, _H, _CX, _CY = relayout._W, relayout._H, relayout._CX, relayout._CY

--scene
local scene = composer.newScene()

-- Group
local _grpMain

--local functions

-- Function update input values
local function updateTextFields()
    xText.text = "Choose X input: " .. string.format("%2d", x_input / 10)
    yText.text = "Choose Y input: " .. string.format("%2d", y_input / 10)
    kText.text = "Choose value of K: " .. string.format("%2d", k / 10)
end

-- Function handle slider values
local function onSliderChange(event)
    if event.target == xSlider then
        x_input = event.value
    elseif event.target == ySlider then
        y_input = event.value
    elseif event.target == kSlider then
        k = event.value
    end
    updateTextFields()
end

-- Function handle radio buttons
local function onDistanceTypeSelect(event)
    local selectedRadioButton = event.target
    if selectedRadioButton.id == "Euclidean" then
        manhattanRadioButton:setState({ isOn = false })
    elseif selectedRadioButton.id == "Manhattan" then
        euclideanRadioButton:setState({ isOn = false })
    end
    distanceType = selectedRadioButton.id
end

local function onWeightingSchemeSelect(event)
    local selectedRadioButton = event.target
    if selectedRadioButton.id == "Equal" then
        harmonicRadioButton:setState({ isOn = false })
    elseif selectedRadioButton.id == "Harmonic" then
        equalRadioButton:setState({ isOn = false })
    end

    weightingScheme = selectedRadioButton.id
end


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
            local rowData = table.concat(columns, "  |  ")
            table.insert(data, rowData)
        end
        io.close(file)
    else
        print("Error: Could not open CSV file")
    end

    return data
end

-- Function to create a scatter plot
local function createScatterPlot(data)
    local plotXStart = 70
    local plotYStart = _CY+325
    local plotWidth = _W - 100
    local plotHeight = _H - 560
    local circleRadius = 4 

    local minX, maxX, minY, maxY = 0, 10, 0, 10

    local scaleX = plotWidth / (maxX - minX)
    local scaleY = plotHeight / (maxY - minY)

    -- Create axis
    local xAxis = display.newLine(_grpMain, plotXStart, plotYStart, plotXStart + plotWidth, plotYStart)
    local yAxis = display.newLine(_grpMain, plotXStart, plotYStart, plotXStart, plotYStart - plotHeight)
    xAxis.strokeWidth = 4
    yAxis.strokeWidth = 3
    xAxis:setStrokeColor(0, 0, 0) 
    yAxis:setStrokeColor(0, 0, 0)  

    -- Labels for dots
    local labelA = display.newText(_grpMain, "class a", _CX-15, 475, "assets/fonts/Galada.ttf", 16)
    labelA.fill = {0, 0, 0}
    local labelB = display.newText(_grpMain, "class b", _CX+85, 475, "assets/fonts/Galada.ttf", 16)
    labelB.fill = {0, 0, 0}

    local circleA = display.newCircle(_grpMain, _CX - 50, 475, 8)
    circleA:setFillColor(0, 0, 1)

    local circleB = display.newCircle(_grpMain, _CX + 50, 475, 8)
    circleB:setFillColor(1, 0, 0)

    -- the x-axis and y-axis and label values
    for i = 0, 10 do
        local x = plotXStart + i * (plotWidth / 10)
        local gridLineX = display.newLine(_grpMain, x, plotYStart, x, plotYStart - plotHeight)
        gridLineX:setStrokeColor(0.5) 
        gridLineX.strokeWidth = 1

        local xValue = minX + i
        local xAxisValueLabel = display.newText(_grpMain, tostring(xValue), x, plotYStart + 20, "assets/fonts/Galada.ttf", 16)
        xAxisValueLabel.fill = {0, 0, 0}
    end
    for i = 0, 10 do
        local y = plotYStart - i * (plotHeight / 10)
        local gridLineY = display.newLine(_grpMain, plotXStart, y, plotXStart + plotWidth, y)
        gridLineY:setStrokeColor(0.5) 
        gridLineY.strokeWidth = 1

        local yValue = minY + i
        local yAxisValueLabel = display.newText(_grpMain, tostring(yValue), plotXStart - 25, y, "assets/fonts/Galada.ttf", 16)
        yAxisValueLabel.fill = {0, 0, 0}
    end

    -- Create dots
    for _, rowData in ipairs(data) do
        local x, y, label = rowData:match("([^|]+)%s*|%s*([^|]+)%s*|%s*([^|]+)")
        x, y = tonumber(x), tonumber(y)
        local color
        if label == "a" then
            color = {0, 0, 1}
        else
            color = {1, 0, 0}
        end
        local plotX = plotXStart + (x - minX) * scaleX
        local plotY = plotYStart - (y - minY) * scaleY 
        local circle = display.newCircle(_grpMain, plotX, plotY, circleRadius)
        circle:setFillColor(unpack(color)) 
    end
end

-- Function to remove sliders and radio buttons and destroy the scene
local function destroyScene()
    if xSlider then
        xSlider:removeSelf()
        xSlider = nil
    end
    if ySlider then
        ySlider:removeSelf()
        ySlider = nil
    end
    if kSlider then
        kSlider:removeSelf()
        kSlider = nil
    end
    if euclideanRadioButton then
        euclideanRadioButton:removeSelf()
        euclideanRadioButton = nil
    end
    if manhattanRadioButton then
        manhattanRadioButton:removeSelf()
        manhattanRadioButton = nil
    end
    if equalRadioButton then
        equalRadioButton:removeSelf()
        equalRadioButton = nil
    end
    if harmonicRadioButton then
        harmonicRadioButton:removeSelf()
        harmonicRadioButton = nil
    end

    composer.removeScene("scenes.app")
end

-- Function to next scene
local function gotoApp()
    destroyScene()
    local options = {
        effect = "fade",
        time = 500,
        params = {
            x_input = x_input,
            y_input = y_input,
            k = k,
            distanceType = distanceType,
            weightingScheme = weightingScheme
        }
    }
    composer.gotoScene("scenes.cal", options)
end

-- Function to recreate the scene
local function recreateScene()
    composer.gotoScene("scenes.app", { effect = "fade", time = 500 })
end

-- Scene creation function
function scene:create(event)
    _grpMain = display.newGroup()
    self.view:insert(_grpMain)

    -- Background
    local background = display.newImageRect(_grpMain, "assets/images/background.png", _W, _H)
    background.x = _CX
    background.y = _CY

    -- Title
    local lblTitle = display.newText(_grpMain, "KNNVIZ", _CX, 50, "assets/fonts/Galada.ttf", 30)
    lblTitle.fill = {0, 0, 0}

    -- predict button
    local btnCal = display.newRoundedRect(_grpMain, _CX, _CY + 18,120,50,20)
    btnCal.fill = { 0, 0 ,0}
    btnCal.alpha = 0.4;

    local lableCal = display.newText("Predict", _CX, _CY + 22, "assets/fonts/Galada.ttf", 30)
    lableCal.fill = { 1, 1, 1}
    _grpMain:insert(lableCal)

    btnCal:addEventListener("tap", gotoApp)

    -- Sliders
    xSlider = widget.newSlider {
        left = 40,
        top = 100,
        width = 300,
        value = x_input,
        minValue = 0,
        maxValue = 10,
        listener = onSliderChange
    }

    ySlider = widget.newSlider {
        left = 40,
        top = 180,
        width = 300,
        value = y_input,
        minValue = 0,
        maxValue = 10,
        listener = onSliderChange
    }

    kSlider = widget.newSlider {
        left = 40,
        top = 260,
        width = 300,
        value = k,
        minValue = 1,
        maxValue = 10,
        listener = onSliderChange
    }

    -- Text fields
    xText = display.newText(_grpMain, "Choose X input: " .. x_input, _CX, 90, "assets/fonts/Galada.ttf", 20)
    xText.fill = {0, 0, 0}

    yText = display.newText(_grpMain, "Choose Y input: " .. y_input, _CX, 170, "assets/fonts/Galada.ttf", 20)
    yText.fill = {0, 0, 0}

    kText = display.newText(_grpMain, "Choose value of K: " .. k, _CX, 250, "assets/fonts/Galada.ttf", 20)
    kText.fill = {0, 0, 0}

    -- Rradio buttons
    local radioButtonGroup = display.newGroup()
    _grpMain:insert(radioButtonGroup)

    -- Euclidean
    euclideanRadioButton = widget.newSwitch {
        x = _CX - 128,
        y = 320,
        id = "Euclidean",
        onPress = onDistanceTypeSelect
    }

    local euclideanText = display.newText(_grpMain, "Euclidean", _CX -48, 325, "assets/fonts/Galada.ttf", 20)
    euclideanText.fill = {0, 0, 0}

    -- Manhattan
    manhattanRadioButton = widget.newSwitch {
        x = _CX + 30,
        y = 320,
        id = "Manhattan",
        onPress = onDistanceTypeSelect
    }

    local manhattanText = display.newText(_grpMain, "Manhattan", _CX + 110, 325, "assets/fonts/Galada.ttf", 20)
    manhattanText.fill = {0, 0, 0}

    equalRadioButton = widget.newSwitch {
        x = _CX - 128,
        y = 360,
        id = "Equal",
        onPress = onWeightingSchemeSelect
    }

    local equalText = display.newText(_grpMain, "Equal", _CX -64, 365, "assets/fonts/Galada.ttf", 20)
    equalText.fill = {0, 0, 0}

    harmonicRadioButton = widget.newSwitch {
        x = _CX + 30,
        y = 360,
        id = "Harmonic",
        onPress = onWeightingSchemeSelect
    }

    local harmonicText = display.newText(_grpMain, "Harmonic", _CX + 110, 365, "assets/fonts/Galada.ttf", 20)
    harmonicText.fill = {0, 0, 0}

    -- Scatter plot
    local data = readCSV("knn.csv")
    createScatterPlot(data)

    local csvLable = display.newText(_grpMain, "CSV data on plot Table", _CX, _CY+65, "assets/fonts/Galada.ttf", 20)
    csvLable.fill = {0, 0, 0}
end


function scene:hide(event)
    local phase = event.phase
    if phase == "will" then
        destroyScene()
    elseif phase == "did" then
    end
end
-- Scene event listeners
scene:addEventListener("create", scene)
scene:addEventListener("hide", scene)

return scene
