function table.copy(tbl)
	local ret = {}
	if not type(tbl) == "table" then return ret end
	for k, v in pairs(tbl) do
		ret[k] = v
	end
	return ret
end

function table.deepcopy(tbl)
	local ret = {}
	if not type(tbl) == "table" then return ret end
	for k, v in pairs(tbl) do
		ret[k] = type(v) == 'table' and table.deepcopy(v) or v
	end
	return ret
end

-- TODO combine two tables into MegaTable
function table.join(t1, t2)
	local ret = {}
	-- for i,v in ipairs(t1) 
end