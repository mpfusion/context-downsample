if not modules then modules = { } end modules ['t-downsample'] = {
version   = 1.004,
comment   = "companion to grph-inc.mkiv",
author    = "Peter Münster, Marco Patzer",
copyright = "PRAGMA ADE / ConTeXt Development Team",
license   = "see context related readme files"
}

local format = string.format

local function sample_down(oldname, newname, resolution)
	local request = figures.current().request
	local width = request.width
	local height = request.height
	if resolution == "" or (not width and not height) then
		-- can work only if width and/or height ist set
		logs.report(string.format("Nothing to do: %s, %s, %s", oldname, newname, resolution))
		return
	end
	local inch = 72.27
	local image = img.scan{filename = oldname}
	local xy = image.xsize / image.ysize
	if not width then
		width = height * xy / 65536
	end
	if not height then
		height = width / xy / 65536
	end
	local xsize = math.floor(resolution * width / inch)
	local ysize = math.floor(resolution * height / inch)
	if xsize < image.xsize or ysize < image.ysize then
		local suffix = oldname:match("[^.]+$")
		local s
		if suffix == "jpg" then
			s = format("gm convert -strip -resize '%dx%d>' %s jpg:%s",
				xsize, ysize, oldname, newname)
		else if suffix == "png" then
			s = format("gm convert -strip -resize '%dx%d>' %s png:%s",
				xsize, ysize, oldname, newname)
		else if suffix == "gif" then
			s = format("gm convert -strip -resize '%dx%d>' %s gif:%s",
				xsize, ysize, oldname, newname)
		end end end
		logs.report("Conversion: " .. s)
		os.execute(s)
	else
		logs.report(print.format("Nothing to do: %s, %s, %s", oldname, newname, resolution))
		logs.report(print.format("xsize = %d, ysize = %d", xsize, ysize))
	end
end

local formats = {"png", "jpg", "gif"}

for _, s in ipairs(formats) do
	figures.converters[s] = figures.converters[s] or {}
	figures.converters[s]["downsample.pdf"] = sample_down
end
