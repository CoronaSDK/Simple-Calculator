local class = {}

local operand1, operand2 = 0, 0;
local operator = "+";

--the next flag will be set to 'true' if the user tries to divide by 0
class.foundError = false;

--"setter" functions
function class.setOp1(value)
	operand1 = value;
end

function class.setOp2(value)
	operand2 = value;
end

function class.setOperator(str)
	--this function sets the operator ('+','-','/','*')
	if str ~= "=" then
		operator = str;
	end
end

--"getter" functions
function class.getOp1()
	return operand1;
end

function class.getOp2()
	return operand2;
end

function class.getOperator()
	return operator;
end

--math functions
function class.add()
	class.setOp1(operand1 + operand2);
end

function class.sub()
	class.setOp1(operand1 - operand2);
end

function class.mul()
	class.setOp1(operand1 * operand2);
end

function class.div()
	local result
	if tonumber(operand2) ~= 0 then
		result = operand1 / operand2;
	else
		result = 0;
		class.foundError = true;
	end
	class.setOp1(result);
end

function class.reset()
	class.setOp1(0);
	class.setOp2(0);
	class.setOperator("+");
	class.foundError = false;
end

function class.performOperation()
	local mathOp = class.getOperator();
	
	if mathOp == "-" then
		class.sub();
	elseif mathOp == "+" then
		class.add();
	elseif mathOp == "X" then
		class.mul();
	elseif mathOp == "/" then
		class.div();
	end

end
return class;
