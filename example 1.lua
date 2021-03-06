---------------------
--- VarsExt BEGIN ---
---------------------

VarsExt = {
	MAXSPACE = 9
}
VarsExt["Vars"] = {
		VarsExt.MAXSPACE,VarsExt.MAXSPACE,VarsExt.MAXSPACE,

		VarsExt.MAXSPACE,VarsExt.MAXSPACE,VarsExt.MAXSPACE,

		VarsExt.MAXSPACE,VarsExt.MAXSPACE,VarsExt.MAXSPACE
}

-- if str is not at least minSize characters, fill char from the left until size is reached
-- e.g. str_fill_left("123","0",9) becomes "000000123"
function str_fill_left(str,char,minSize)
	local its = (minSize - strlen(str)) / strlen(char)
	local endStr = ""
	while its > 0 do
		endStr = endStr .. char
		its = its - 1
  end
	endStr = endStr .. str
	return endStr;
end


VarsExt.saveVar = function(save,offset,size,value)
	local currentSaveVal = Vars["Save"..save];
	local saveValStr = str_fill_left(format("%.0f",currentSaveVal),"0",VarsExt.MAXSPACE)
	--print(saveValStr .. " = saveVar(): current value ");
	local leftsize = offset
	local leftStr = strsub(saveValStr,1,leftsize);
	local rightStr = strsub(saveValStr,offset+1+size)
	local newstr = leftStr .. str_fill_left(tostring(value),"0",size) .. rightStr;
	--print(newstr .. " = saveVar(): after safe value ");
	Vars["Save"..save] = tonumber(newstr);
end
VarsExt.getVar = function(save,offset,size)

		local currentSaveVal = Vars["Save"..save];

		local saveValStr = str_fill_left(format("%.0f",currentSaveVal),"0",VarsExt.MAXSPACE)

		local myVal = tonumber(strsub(saveValStr,offset+1,offset+size))

		return myVal;
end
VarsExt.save = function(this,value)
	if value > this.maxnum or value < 0 then
		return;
	end
	VarsExt.saveVar(this.i,this.off,this.size,value);
end
VarsExt.get = function(this)
	return VarsExt.getVar(this.i,this.off,this.size);
end

-- util foreach
function foreach_ext (t, f, ...)
	local i, v = next(t, nil)
	while i do
	  -- we could maybe optimise this, but its really not a big deal
	  local args = arg
	  tinsert(args,1,v)
	  tinsert(args,1,i)
	  local res = call(f,args)

	  tremove(args,1); -- it is the same object hence remove it again
	  tremove(args,1);

	  if res then return res end
	  i, v = next(t, i)
	end
end

--
-- find index with size on any vars, returns first save with enough size
--
VarsExt.findIndexWithSize = function(size)
		if size < 1 then return nil; end

		return foreach_ext(VarsExt.Vars,function(i,var,s)
											if var >= s then
												return i
											end
										end,size);
end
--
-- reserve size on save.expects size to be fitting
-- returns offset from 0 on SaveX
VarsExt.reserve = function(save,size)
	local currentSize = VarsExt.Vars[save]
	VarsExt.Vars[save] = currentSize - size
	return VarsExt.MAXSPACE - currentSize;
end

-- main function to occupy part of a save variable, starting from 1 up to 9, ignores occupied save variables.
--
-- return: save "class"-object with save(x) and get() member function, if space is left
--				 nil, if no space is left
VarsExt.create = function(size)
	local index = VarsExt.findIndexWithSize(size);
	if index == nil or size < 1 then return nil; end
	-- init
	if Vars["Save" .. index] == nil then
		print("[DEBUG] " .. index .. " is a NIL val (not initalised). set to 0");
		Vars["Save" .. index] = 0
	end
	local offset = VarsExt.reserve(index,size);


	-- highest number of 10^size -1
	local maxnum = 1;
	do
		local i = size;
		while i > 0 do
			maxnum = maxnum * 10;
			i = i - 1
		end
		maxnum = maxnum - 1;
	end

	-- create "class" object
	local myVar = {
		i = index,
		off = offset,
		size = size,
		maxnum = maxnum
	};
	myVar.save = VarsExt.save;
	myVar.get = VarsExt.get;
	--print("myVar","i="..index,"off="..offset,"size="..size,"maxnum="..maxnum);
	return myVar;
end

-- in case you are using a Vars.Save on your own, you can state here that it will not be used. THIS ACTION CANNOT BE REVERSED (since scripts are hard coded.);
VarsExt.occupy = function(save)
	if VarsExt.Vars[save] > 0 then -- 0 or -1 or -0 ?
		VarsExt.Vars[save] = -1;
	end
end
------------------------------
------ VarsExt END -----------
------------------------------


--- Example 1: keep track, if a ferry has reached coordinate once

sFerryReachedGoal = VarsExt.create(1) -- only 1 decimal place needed (0 = no, 1 = yes, 2-9 = redundant)

ferryGoalPos = { x = 128, y = 128}

-- check if ferry reached pos every tick
function tick_check_ferry_reached_goal()
	if Vehicles.AmountInArea(1,Vehicles.FERRY,ferryGoalPos.x, ferryGoalPos.y, 10) > 0 then
		sFerryReachedGoal:save(1)
		dbg.stm("Das Schiff ist angekommen. Segel das Schiff aus dem Bereich raus, und lade das Spiel erneut")
		unrequest_event(tick_check_ferry_reached_goal,Events.TICK)
	end
end

function new_loaded_game()
	if sFerryReachedGoal:get() == 0 then
		dbg.stm("Seit dem Spielstart ist das Schiff noch nicht an der Koordinate angekommen (Wert:".. sFerryReachedGoal:get() ..")")
	else
		dbg.stm("Das Schiff ist angekommen (Wert:".. sFerryReachedGoal:get() ..")")
	end
end

function new_game()
	request_event(new_loaded_game,Events.FIRST_TICK_OF_NEW_OR_LOADED_GAME)
	request_event(tick_check_ferry_reached_goal,Events.TICK)
end
function register_functions()
	reg_func(new_loaded_game)
	reg_func(tick_check_ferry_reached_goal)
end
