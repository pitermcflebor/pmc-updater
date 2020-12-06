
--
-- PURE LUA UTILS
--
function string:split(pat)
	pat = pat or '%s+'
	local st, g = 1, self:gmatch("()("..pat..")")
	local function getter(segs, seps, sep, cap1, ...)
	st = sep and seps + #sep
	return self:sub(segs, (seps or 0) - 1), cap1 or sep, ...
	end
	return function() if st then return getter(st, g()) end end
end

function string:ensure()
	return self:gsub('(['..("%^$().[]*+-?"):gsub("(.)", "%%%1")..'])', "%%%1")
end

function string:startsWith(start)
	return self:sub(1, #start) == start
end

function string:endsWith(ending)
	return ending == "" or self:sub(-#ending) == ending
end

function string:trim()
	local n = self:find"%S"
	return n and self:match(".*%S", n) or ""
end

function table.build(iter)
	if type(iter) ~= 'function' then return nil end
	local t = {}
	for i in iter do table.insert(t, i) end
	return t
end

function table.fill(input, i)
	local t = {}
	for x=1, i, 1 do table.insert(t,input) end
	return t
end

function table.dump(t, nb)
	if type(t) == 'table' then
		local s = '{\n'
		for key, value in pairs(t) do
			s = s .. table.concat(table.fill('\t', nb or 1)) .. ('[%s] = %s,\n'):format((type(key) == 'string' and ("'%s'"):format(tostring(key)) or key), table.dump(value, (nb or 1)+1))
		end
		return s .. table.concat(table.fill('\t', ((nb or 1)-1 > 0 and nb-1 or 0))) .. '}'
	else
		return (type(t) == 'string' and ("'%s'"):format(tostring(t)) or t)
	end
end

function printWarning(...)
	local raw_params = {...}
	local params = {}
	for k,v in pairs(raw_params) do params[k] = tostring(v) end
	local text = table.concat(params, ' ')
	print('^1'..text..'^7')
end
function printLog(...)
	local params = {...}
	for k,v in pairs(params) do params[k] = tostring(v) end
	local text = table.concat(params, ' ')
	print('^2'..text..'^7')
end

--
-- HTTP I/O
--
_G.requests = {
	debugEnabled = false,
	auth = LoadResourceFile(GetCurrentResourceName(), '.authkey') or "",
}
function requests.get(url, payload, headers)
	assert(type(url) == 'string', 'Invalid Lua type at #1 argument!')
	if payload ~= nil then assert(type(payload) == 'table', 'Invalid Lua type at #2 argument') end
	if headers ~= nil then assert(type(headers) == 'table', 'Invalid Lua type at #3 argument') end
	local p = promise:new()
	PerformHttpRequest(url, function(_rc, _b, _h)
		if requests.debugEnabled then print('[REQUESTS]: Performed GET to', url) end
		if _rc == 200 then
			p:resolve(_b)
		else
			printWarning('Error performing GET request to:', url, '\n\t'.._rc, '\n\t'..(_b or 'empty body'), '\n\t'..table.dump(_h))
			p:resolve(false, _rc, _b, _h)
		end
	end, 'GET', json.encode(payload or {}), headers or {['Content-Type']='text/html;charset=UTF-8', ['User-Agent']='request', ['Authorization']=(requests.auth ~= "" and 'token '..requests.auth or nil)})
	return Citizen.Await(p)
end

--
-- READER/WRITER FUNCTIONS
--
function GetFile(url)
	local fileText, rc, b, h = requests.get(url)
	if fileText then
		return fileText
	else
		printWarning('Error getting file from', url)
		printWarning('\tCode:', rc)
		printWarning('\tResponse:', b)
		printWarning('\tHeaders:', json.encode(h))
		return false
	end
end

function CreateDirectory(destination)
	local _r, _e, _c = os.execute("mkdir " .. destination)
	if _c ~= 1 and _c ~= 0 then
		printWarning('\tError creating directory:', destination)
		printWarning('\t\t', _r, _e, _c)
		return false
	end
	return true
end

function WriteFile(destination, rawString, failNext)
	local file, err, errorCode = io.open(destination, "wb")
	if err then
		if errorCode == 2 then
			if not failNext then
				local directories = table.build(destination:split('/'))
				table.remove(directories, #directories)
				if CreateDirectory(table.concat(directories, '\\')) then
					WriteFile(destination, rawString, true)
				end
			else
				printWarning('\tCannot create directory for', destination)
			end
		else
			printWarning('Error writing file', destination, '\n\t', err,'\n\tError code:', errorCode)
		end
	else
		file:write(rawString)
		file:close()
	end
end
