-- Yazi initialization script for Fedpunk
-- https://yazi-rs.github.io/docs/configuration/overview

-- Minimal custom linemode showing only size
function Linemode:size_only()
	local size = self._file:size()
	return ui.Line(size and ya.readable_size(size) or "-")
end
