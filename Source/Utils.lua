function map(value, min1, max1, min2, max2)

	return (value - min1) / (max1 - min1) * (max2 - min2) + min2

end