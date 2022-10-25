-- map(value, min1, max1, min2, max2)
--
function map(value, min1, max1, min2, max2)
	return (value - min1) / (max1 - min1) * (max2 - min2) + min2
end

-- split(s, delimiter)
--
function split(s, delimiter)
    result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result

-- log2(n)
--
function log2(n)
	return math.floor(math.log10(n) / math.log10(2) + 0.5)
end