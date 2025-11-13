local NetworkGraph = {}

-- Phase 3 placeholder: maintain device nodes & cable edges for diagnostics/quests.

function NetworkGraph.new()
	local self = {
		nodes = {},
		edges = {},
	}
	return self
end

return NetworkGraph

