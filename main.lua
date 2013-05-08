--------------------------------------------------------------------------------------
--Simple math calculator
--by Amir Fleminger, 2012
--You may use this code as you wish
--credit is appreciated
--------------------------------------------------------------------------------------
-------------------------------------------
--Variables
-------------------------------------------
--our readout string
local displayStr = "0";

--limit the number of digits that can fit in the display
local maxDigits = 19;

--Type of last button pressed. 
--accepts "none", "equal", "num" or "math"
local lastInput = "none"; 


-------------------------------------------
--flags
-------------------------------------------
--should start capturing a new number
--when digit or decimal pressed?
local startNewNumber = true;

--was the last button pressed "-"?
local negPressedLast = false;

--was the decimal button tapped?
local decimalPressed = false;


-------------------------------------------
--require the calculator controller class
------------------------------------------
local cc = require "calcController";

-------------------------------------------
--utility functions
-------------------------------------------
local function cleanLeftZeros(str)
	--removes any '0's on the left side of a string
	--as long as the string length is longer then 1.
	--also leave the 0 if the num is between -1 and 1 (like "0.1234")
	
	--check is this a negative number?
	local isNegative = false;
	if string.sub(str, 1, 1) == "-" then
		--remember that the num was negative
		isNegative = true;
		--temporarily remove the '-' from the string
		str = string.sub(str,2);
	end
	
	--turn the string temporarily into a number
	str = tonumber(str);
	--if its smaller then 0, add the "0" to the left
	--because we want the format "0.4", not ".4"
	if str and str<0 then
		str = "0"..tostring(str);
	end
	
	--if it was negative, restore the '-' sign
	if isNegative then str = "-" .. str; end
	
	return str;
end

local function clear()
	cc.reset();
	decimalPressed = false;
	displayStr = "0";
	lastInput = "none"
	startNewNumber = true;
end

-------------------------------------------
--The calculator display screen
-------------------------------------------
--require the external 'class' we created
local calcScreen = require "calcScreen";

--create a new instance of the calc display screen
local calcScr = calcScreen.new();

--position the calculator screen
calcScr:setReferencePoint(display.CenterReferencePoint);
calcScr.x = display.contentWidth *.5;
calcScr.y = 50;

-------------------------------------------
--Button Handlers
-------------------------------------------
local function invertNegBtnTapped(event)
--handles the +/- event
	local num = tonumber(displayStr);
	--if num is not nil and is smaller then 0
	if num and num<0 then
		--remove the "-" (first char of the string)
		displayStr = string.sub(displayStr,2);
	--if num is not nil and is larger then 0
	elseif num and num>0 then
		--add a "-"
		displayStr = "-"..displayStr;
	end
	--show the modified num on screen
	if num then calcScr.setTxt(displayStr); end
	return true;
end

local function mathBtnTapped(event)
--handles the math buttons ("/","*","+,"-" etc)
	local targetID = event.target.id;
	
	if targetID == "-" and startNewNumber then
		negPressedLast = true;
	else
		negPressedLast = false;
	end
	
	
	--if this is not the first time in a row the '='
	--button was pressed, dont change op2
	--Example: the user enters "3+5 = = =" result is 18
	if lastInput ~= "equal" then
		cc.setOp2(tonumber(displayStr));
	end
	
	if targetID ~= "=" and lastInput=="equal" then
		--treat the last result as it was a num entered by user
		cc.setOp1(tonumber(displayStr));
		cc.setOp2(0);
	else  
		cc.performOperation();
	end
	
	
	displayStr = cc.getOp1();
	
    if targetID == "=" then
    	lastInput = "equal"
    else
    	lastInput = "math"
    end
    
    --set the typed math function (X, /, -, +) as the last operator
    cc.setOperator(targetID);
    
    --check for errors found by the calculator controller
    --such as a divide by zero
    if cc.foundError then displayStr = "ERROR"; end
    
    --deal with the clear button
    if targetID =="Clear" then
		clear();
	end
	
    --show operand1 on the readout screen
    calcScr.setTxt(displayStr);
	return true
end

local function numBtnTapped(event)
--handles the number buttons ('0'-'9')
	local targetID = event.target.id;
	print("You pressed "..targetID);
	
	--reset the readout string, if this is a new digit sequence to enter
	--if lastinput was "equal" we are starting a completely new
	--sequence of calculations, so we call clear()
	if lastInput == "equal" then
		clear();
	elseif lastInput ~= "num" then 
		displayStr = "0"; 
		decimalPressed = false; 
	end
	
	--don't allow display longer then 'maxDigits'
	if (string.len(displayStr) < maxDigits) then
		displayStr = displayStr .. targetID;
	end
	
	--check if the "-" button was pressed before this number
	if negPressedLast then
		displayStr = "-"..displayStr;
		negPressedLast = false;
	end
	
	--flag that the last button was a number button
	lastInput = "num";
	
	--clean '0' on left side of the readout string
	displayStr = cleanLeftZeros(displayStr);
	
	calcScr.setTxt(displayStr);
	startNewNumber = false;
	return true
end

local function decimalBtnTapped(event)
--handles the decimal button ('.')
	local targetID = event.target.id;
	print("You pressed "..targetID);
	
	--reset the readout string, if this is a new digit sequence to enter
	--if lastinput was "equal" we are starting a completely new
	--sequence of calculations, so we call clear()
	if lastInput == "equal" then
		clear();
	elseif lastInput ~= "num" then 
		displayStr = "0"; 
		decimalPressed = false; 
	end
	
	if not decimalPressed and (string.len(displayStr) < maxDigits) then
		displayStr = displayStr..".";
		decimalPressed = true;
		lastInput = "num";
	end
	calcScr.setTxt(displayStr);
	return true;
end



-------------------------------------------
--the buttons panel
-------------------------------------------
--require the button constructor class
local btnClass = require "buttons";

--create the button panel
local buttonPanel = display.newGroup();
local bg = display.newRect(0,0,display.contentWidth-20,display.contentHeight - 100);
bg:setFillColor(50,50,50);
bg:setStrokeColor(255,255,255);
bg.strokeWidth = 1;
bg.x , bg.y = 0,0;
buttonPanel:insert(bg);

--position the button panel at the bottom center of the screen
buttonPanel:setReferencePoint(display.BottomCenterReferencePoint);
buttonPanel.x , buttonPanel.y = display.contentWidth * 0.5 , display.contentHeight - 2;

--array to hold all the buttons
local btns = {};
-------------------------------------------
--the number buttons
-------------------------------------------
--positioning variables
local padding = 5;
local rowSpacing = 50;
local colSpacing = 60;
local cols = 3; -- specify number of columns
local currentRow , currentCol = 0 , 4; --help us positioning the num buttons

for i=0 , 10 do
	local btnParams = {};
	if i==10 then
		btnParams.labelTxt = ".";
	else
		btnParams.labelTxt = i;
	end
	
	if i==0 then
	--make the '0' num button bigger then the rest of them
		btnParams.width = 110;
	end
	
	--create the button and put it in the array
	btns[#btns + 1] = btnClass.newNumBtn(btnParams);
	
	
	--we need to identify each button later, so we'll create a unique id for each one;
	if i==10 then
		--if '.' button
		btns[#btns].id = ".";
		btns[#btns]:addEventListener("tap",decimalBtnTapped);
	else
		btns[#btns].id = i;
		--add listener to button
		btns[#btns]:addEventListener("tap",numBtnTapped);
	end
	
	
	--position the buttons
	if i==0 then --'0' num button
		btns[#btns].x, btns[#btns].y = - 60 , 150;
	elseif i==10 then --decimal num button
		btns[#btns].x, btns[#btns].y = (cols-1) * colSpacing - 90 , 150;
	else --any other num button (1-9);
		btns[#btns].x, btns[#btns].y =  currentCol * colSpacing - 90, currentRow * rowSpacing + 150;
	end

	--insert the new button into the panel
	buttonPanel:insert(btns[#btns]);
	
	currentCol = currentCol + 1;
	if currentCol>= cols then currentCol = 0; end
	
	if (currentCol % 3 == 0) then currentRow = currentRow - 1; end
end

-------------------------------------------
--the math function buttons
-------------------------------------------

for i = 1, 7 do
	--create the button and put it in the array
	local btnParams = {};
	local id;
	local col , row , x , y;
	
	--configure button parameters and position
	if i==1 then
		btnParams.labelTxt = "/";
		id = "/";
		col , row = 2 , 4;	
	elseif i==2 then
		btnParams.labelTxt = "X";
		id = "X";
		col , row = 3 , 4;
	elseif i==3 then
		btnParams.labelTxt = "+";
		id = "+";
		col , row = 3 , 2;
	elseif i==4 then
		btnParams.labelTxt = "-";
		id = "-";
		col , row = 3 , 3;
	elseif i==5 then
		btnParams.labelTxt = "C";
		id = "Clear";
		col , row = 0 , 4;
	elseif i==6 then
		btnParams.labelTxt = "+/-";
		id = "invertNegative";
		col , row = 1 , 4;
	else
		btnParams.labelTxt = "=";
		id = "=";
		btnParams.bgColor = {255,100,50};
		--the '=' button is twice the height of the other buttons
		btnParams.height = 85;
	end
	if id == "=" then
		x , y = 3 * colSpacing - 90, -rowSpacing + 175;
	else --any other math function button
		x , y = col * colSpacing - 90, -row * rowSpacing + 150;
	end
	--create the current math button
	btns[#btns + 1] = btnClass.newMathFuncBtn(btnParams);
	
	--add the event listener to the button
	if id=="invertNegative" then
		btns[#btns]:addEventListener("tap",invertNegBtnTapped);
	else
		btns[#btns]:addEventListener("tap",mathBtnTapped);
	end
	
	--insert the new button into the panel
	buttonPanel:insert(btns[#btns]);
	
	--position the button
	btns[#btns].x, btns[#btns].y  = x , y;
	
	--attach an id to the new button
	btns[#btns].id = id;
end



