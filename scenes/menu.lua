--import

local composer = require("composer")
local relayout = require("libs.relayout")

--variables

--layout
local _W, _H, _CX, _CY = relayout._W,relayout._H,relayout._CX,relayout._CY

--scene
local scene = composer.newScene()

--group
local _grpMain

--local functions
local function gotoApp()

    composer.gotoScene("scenes.app")

end

--scene event functions

function scene:create( event )
    print("scene:create - menu")
    _grpMain = display.newGroup()
    self.view:insert(_grpMain)

    local background = display.newImageRect(_grpMain, "assets/images/background.png",_W,_H)
    background.x = _CX
    background.y = _CY

    local lableTitle = display.newText("KNNVIZ", _CX, 200, "assets/fonts/Galada.ttf", 76)
    lableTitle.fill = { 0, 0, 0}
    _grpMain:insert(lableTitle)

    local btnCal = display.newRoundedRect(_grpMain, _CX, _CY,220,80,20)
    btnCal.fill = { 0, 0 ,0}
    btnCal.alpha = 0.4;

    local lableCal = display.newText("click to predict", _CX, _CY + 4, "assets/fonts/Galada.ttf", 30)
    lableCal.fill = { 1, 1, 1}
    _grpMain:insert(lableCal)

    btnCal:addEventListener("tap", gotoApp)
end


--scene event listeners
scene:addEventListener( "create", scene)

return scene