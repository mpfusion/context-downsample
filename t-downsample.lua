if not modules then modules = { } end modules ['t-downsample'] = {
version   = 1.005,
comment   = "companion to grph-inc.mkiv",
author    = "Peter Münster, Marco Patzer",
copyright = "PRAGMA ADE / ConTeXt Development Team",
license   = "see context related readme files"
}

local myself = "downsample"
local format = string.format
local report = logs.report

local function sample_down(oldname, newname, resolution)
	local request = figures.current().request
	local width   = request.width
	local height  = request.height
	if resolution == "" or (not width and not height) then
		report(myself, format("Nothing to do: %s, %s, %s",
			oldname, newname, resolution))
		file.copy(oldname, newname)
		return
	end
	local inch  = 72.27 * 65536
	local image = img.scan{filename = oldname}
	local xy    = image.xsize / image.ysize
	if not width then
		width = height * xy
	end
	if not height then
		height = width / xy
	end
	local xsize = math.floor(resolution * width / inch)
	local ysize = math.floor(resolution * height / inch)
	if xsize < image.xsize or ysize < image.ysize then
		local s = format("gm convert -strip -resize '%dx%d>' %s %s",
			xsize, ysize, oldname, newname)
		report(myself, "Conversion: " .. s)
		os.execute(s)
	else
		report(myself, format("Nothing to do: %s, %s, %s",
			oldname, newname, resolution))
		report(myself, format("xsize = %d, ysize = %d", xsize, ysize))
		file.copy(oldname, newname)
	end
end

local formats = {"png", "jpg", "gif"}

for _, s in ipairs(formats) do
	figures.converters[s] = figures.converters[s] or {}
	figures.converters[s]["downsample.pdf"] = sample_down
end
