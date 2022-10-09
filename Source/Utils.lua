function map(value, min1, max1, min2, max2)

	return (value - min1) / (max1 - min1) * (max2 - min2) + min2

end

function split(s, delimiter)
    result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end