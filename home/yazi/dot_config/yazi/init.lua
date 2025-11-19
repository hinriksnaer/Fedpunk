-- Yazi initialization script for Fedpunk
-- https://yazi-rs.github.io/docs/configuration/overview

-- Image preview setup
function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		time = ""
	elseif os.date("%Y", time) == os.date("%Y") then
		time = os.date("%b %d %H:%M", time)
	else
		time = os.date("%b %d  %Y", time)
	end

	local size = self._file:size()
	return ui.Line(string.format("%s %s", size and ya.readable_size(size) or "-", time))
end

-- Smart enter: extract archives or enter directories
function ya.smart_enter()
	local h = cx.active.current.hovered
	if h and h.cha.is_dir then
		ya.manager_emit("enter", {})
	else
		ya.manager_emit("open", {})
	end
end

-- Enhanced tab support
function ya.tab_create_smart()
	local h = cx.active.current.hovered
	if h and h.cha.is_dir then
		ya.manager_emit("tab_create", { h.url })
	else
		ya.manager_emit("tab_create", { cx.active.current.cwd })
	end
end
