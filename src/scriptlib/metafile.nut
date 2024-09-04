//-----------------------------------------------------------------------------
function	serializeArrayToMetatag(object, tag)
{
	foreach (n, value in object)
		serializeObjectToMetatag(value, MetatagAddChild(tag, "#__array__"))
}
function	serializeTableToMetatag(object, tag)
{
	foreach (name, value in object)
		serializeObjectToMetatag(value, MetatagAddChild(tag, name))
}
function	serializeObjectToMetatag(value, tag)
{
	local t = typeof(value)

	switch (t)
	{
		case	"instance":
			throw("Cannot serialize class instance")
			break

		case	"array":
			serializeArrayToMetatag(value, tag)
			break

		case	"table":
			serializeTableToMetatag(value, tag)
			break

		default:
			MetatagSetValue(tag, value)
			break
	}
}
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
function	deserializeObjectFromMetatag(tag)
{
	if	(MetatagGetType(tag) == TagTypeNone)
	{
		// Get the children tag list.
		local children = MetatagGetChildren(tag)

		// Assume an empty array, when no children are found.
		if	(children.len() == 0)
			return []

		// Check the first child name to detect a potential array (~hackish).
		if	(MetatagGetName(children[0]) == "#__array__")
		{
			local value = []
			foreach (child in children)
				value.append(deserializeObjectFromMetatag(child))
			return value
		}

		// Output children as table members.
		local value = {}
		foreach (child in children)
			value[MetatagGetName(child)] <- deserializeObjectFromMetatag(child)
		return value
	}
	return MetatagGetValue(tag)
}
//-----------------------------------------------------------------------------
