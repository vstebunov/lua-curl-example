require 'config'
local url = "https://leprosorium.ru/ajax/favourites/list/";
local curl = require 'luacurl'
local json = require 'dkjson'
print(url);

local offset = 0
local global_output = ''
for i = 1, 10000 do
	local lepra_curl = curl:new();
	lepra_curl:setopt(curl.OPT_URL, url)
	lepra_curl:setopt(curl.OPT_SSL_VERIFYPEER, false)
	lepra_curl:setopt(curl.OPT_SSL_VERIFYHOST, 0)
	lepra_curl:setopt(curl.OPT_COOKIE, cookie)
	lepra_curl:setopt(curl.OPT_POST, true) 
	local postfield = 'csrf_token=' .. curl.escape(csrf_token) .. '&offset=' .. offset  
	lepra_curl:setopt(curl.OPT_POSTFIELDS, postfield )
	local output = ''

	lepra_curl:setopt(curl.OPT_WRITEFUNCTION, function(u, b)
		output = output .. b
		return #b
	end)

	lepra_curl:perform()
	lepra_curl:close()
	local obj, pos, err = json.decode(output, 1, nil)

	if err then
		print ("Error:", err)
		return
	else
		if (obj.offset == nil) then
			break
		end
		offset = obj.offset
		global_output = global_output .. obj.template
	end
end

local post_id = {}
for id in string.gmatch(global_output, '//leprosorium.ru/comments/(%d+)/') do
	post_id[id] = 'OK'
end

local post_url = "https://leprosorium.ru/comments/"

for id, v in pairs(post_id) do

	local lepra_curl = curl:new();
	lepra_curl:setopt(curl.OPT_URL, post_url .. id)
	lepra_curl:setopt(curl.OPT_SSL_VERIFYPEER, false)
	lepra_curl:setopt(curl.OPT_SSL_VERIFYHOST, 0)
	lepra_curl:setopt(curl.OPT_COOKIE, cookie)

	local output = ''

	lepra_curl:setopt(curl.OPT_WRITEFUNCTION, function(u, b)
		output = output .. b
		return #b
	end)

	lepra_curl:perform()
	lepra_curl:close()

	local outputfile = io.open(id .. '.html', 'w+')
	outputfile:write(output)
	io.close(outputfile)	

	print(id,v)
end

