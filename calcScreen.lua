local class = {};
--this class creates the calc. display

	function class.new()
	--constructor class to create a new calc display
		--define a few variables
		local width, height, textSize;
		width = display.contentWidth-20;
		height = 40;
		textSize = 20;
		
		--a display group to hold our calc display
		local screenGroup = display.newGroup();
		
		--draw the background
		local bg = display.newRect(0, 0, width, height);
		bg:setFillColor(20,20,20);
		bg:setStrokeColor(255,255,255);
		bg.strokeWidth = 1;
		--position it
		bg:setReferencePoint(display.CenterReferencePoint);
		bg.x, bg.y = 0, 0;
		
		--create the text object
		local txt = display.newText("0", 0, 0, native.systemFont, textSize)
		txt:setTextColor(0,255,0);
		
		--position the label (we define it in a function 
		--since we have to reposition the text every time
		--it's changed)
		local function positionLabel()
			local padding = 5;
			txt:setReferencePoint(display.CenterReferencePoint);
			txt.x = (bg.contentWidth - txt.contentWidth) *.5 - padding;
			txt.y = 0;
		end
		positionLabel();
	
		--insert the components into the main display group
		screenGroup:insert(bg);
		screenGroup:insert(txt);
		
		
		--public class functions
		function screenGroup.setTxt(str)
			txt.text = str;
			positionLabel();
		end
		
		--return a handle to our display object
		return screenGroup;
	end
return class;
