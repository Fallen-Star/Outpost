local utils = {}


-- Outpost collection of random functions and associated calls


function utils.sendToDiscordWebhook(discord_username, avatarurl, endpoint,  message)
  local httpdone = registerAnonymousEventHandler('sysPostHttpDone', 
    function(event, rurl, response)
      if rurl == url then display(r) else return true end
    end, true)

  local httperror = registerAnonymousEventHandler('sysPostHttpError', 
    function(event, response, rurl)
      if rurl == url then display(r) else return true end
    end, true)

  local url = endpoint
  local data = {
    username = discord_username, 
    avatar_url = avatarurl,
    content = message
  }
  local header = {
    ["Content-Type"] = "application/json",
  }
  
  postHTTP(yajl.to_string(data), url, header)
  
  killAnonymousEventHandler(httpdone)
  killAnonymousEventHandler(httperror)
end


function utils.timeStamp()
  local h, m, s, ms = getTime().hour,
    getTime().min,
    getTime().sec,
    getTime().msec
  
  local time = h..":"..m..":"..s..":"..ms

  return cecho(" <burlywood>[<sienna>"..time.."<burlywood>]")
end


function utils.newlineSendCheck()
	if bals:has() then
		deleteLine()
		send("\n")
	end
end


function utils.round(num, idp)
    local mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end


function utils.copyitable(tbl)
	local target = {}
	if type(tbl) ~= "table" then return end
	for i, v in ipairs(tbl) do
		target[i] = v
	end
	return target
end


function utils.randomString(length, pattern)
    local f = ""
    for loop = 0, 255 do
        f = f .. string.char(loop)
    end

    local pattern, random = pattern or '.', ''
    local str = string.gsub(f, '[^' .. pattern .. ']', '')
    for loop = 1, length do
        random = random .. string.char(string.byte(str, math.random(1, string.len(str))))
    end

    return random
end


function utils.copyTable(orig)
	local target = {}
	if type(orig) ~= "table" then return end
	for k, v in pairs(orig) do
		target[k] = v
	end
	return target
end

function utils.shallowCopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[orig_key] = orig_value
		end
	else
		copy = orig
	end
	return copy
end

function utils.deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[utils.deepCopy(orig_key)] = utils.deepCopy(orig_value)
        end
        setmetatable(copy, utils.deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end


function utils.mergeTable(table1, table2)
	local results = utils.copyTable(table1)
	for k, v in pairs(table2) do
		table.insert(results, v)
	end

	return results
end


function utils.countTable(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end

    return count
end


function utils.dirTree(dir)
    assert(dir and dir ~= "", "directory parameter is missing or empty")
    if string.sub(dir, -1) == "/" then
        dir = string.sub(dir, 1, -2)
    end
 
    local function yieldtree(dir)
        for entry in lfs.dir(dir) do
            if entry ~= "." and entry ~= ".." and not entry:find("lua") then
                entry = dir..entry
                local attr = lfs.attributes(entry)
                coroutine.yield(entry,attr)
                if attr.mode == "directory" then
                    yieldtree(entry)
                end
            end
        end
    end
 
    return coroutine.wrap(function() yieldtree(dir) end)
end


function utils.gaglp()
    if op.debugmode then return false end
    selectString(line, 1)
    replace("")
    resetFormat()
    tempLineTrigger(1, 1, [[
        if isPrompt() then deleteLine() end
        ]])
end


function utils.dehex(h)
    local i
    local s = ""
    for i = 1, #h, 2 do
        high = ascii_to_num(string.byte(h,i))
        low = ascii_to_num(string.byte(h,i+1))
        s = s .. string.char((high*16)+low)
    end
    return s
end


function utils.asciiToNum(c)
    if (c >= string.byte("0") and c <= string.byte("9")) then
        return c - string.byte("0")
    elseif (c >= string.byte("A") and c <= string.byte("F")) then
        return (c - string.byte("A"))+10
    elseif (c >= string.byte("a") and c <= string.byte("f")) then
        return (c - string.byte("a"))+10
    else
        echo("Wrong input for ascii to num convertion.")
    end
end


function utils.concatAnd(t)
	assert(type(t) == "table", "utils.concatAnd(): argument must be a table")

	if #t == 0 then
		return ""
	elseif #t == 1 then
		return t[1]
	else
		return table.concat(t, ", ", 1, #t-1) .. " and "..t[#t]
	end
end


function utils.truncateString(txt, length)
	if not type(txt) == "string" or #txt <= length then return txt end

	return string.sub(txt, 1, length-3) .. "..."
end


function utils.pairsByKeys(t, f)
	local a = {}
	for n in pairs(t) do 
		table.insert (a, n) 
	end

	table.sort (a, f)

	local i = 0
	return function ()
		i = i + 1
		return a[i], t[a[i]]
	end
end


function utils.loadTable(t, dFunc)
	if not op.config[t] then
		local file_loc = getMudletHomeDir().. "/op.config."..t..".lua"

		op.config[t] = {}

		if io.exists(file_loc) then 	
			table.load(file_loc, op.config[t])
		end

	end	

	if dFunc then
		dFunc()
	end
end

function utils.saveTable(t)
	local file_loc = getMudletHomeDir().."/op.config." .. t .. ".lua"

	table.save(file_loc, op.config[t])
end

function utils.milliToHuman(milliseconds)
  local totalseconds = math.floor(milliseconds / 1000)
  milliseconds = milliseconds % 1000
  local seconds = totalseconds % 60
  local minutes = math.floor(totalseconds / 60)
  local hours = math.floor(minutes / 60)
  minutes = minutes % 60
  return string.format("%02d:%02d:%02d:%03d", hours, minutes, seconds, milliseconds)  
end



return utils