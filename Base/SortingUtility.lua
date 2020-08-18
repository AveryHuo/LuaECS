local SortingUtility = {}
ECS.SortingUtility = SortingUtility

function SortingUtility.InsertSorted( data, length, newValue )
	 while (length > 1 and newValue < data[length - 1]) do
        data[length] = data[length - 1]
        length = length - 1
    end
    data[length] = newValue
end

return SortingUtility