screen = Vector2(guiGetScreenSize())
local rounded = {}

function roundedRectangle(id, x, y, w, h, radius, color, isLine, lineColor)
    if id == "clear" then
        for _, widths in pairs(rounded) do
            for _, heights in pairs(widths) do
                for _, elem in pairs(heights) do
                    if isElement(elem.bg) then destroyElement(elem.bg) end
                    if isElement(elem.line) then destroyElement(elem.line) end
                end
            end
        end
        rounded = {}
        return
    end

    local idGroup = rounded[id]
    if not idGroup then
        idGroup = {}
        rounded[id] = idGroup
    end

    local wGroup = idGroup[w]
    if not wGroup then
        wGroup = {}
        idGroup[w] = wGroup
    end

    local item = wGroup[h]
    if not item then
        local bgPath = string.format(
            '<svg width="%s" height="%s" viewBox="0 0 %s %s" fill="none" xmlns="http://www.w3.org/2000/svg">'
            ..'<mask id="mask_%s" style="mask-type:alpha" maskUnits="userSpaceOnUse" x="0" y="0" width="%s" height="%s">'
            ..'<rect width="%s" height="%s" rx="%s" fill="#D9D9D9" fill-opacity="0.55"/>'
            ..'</mask>'
            ..'<g mask="url(#mask_%s)">'
            ..'<defs>'
            ..'<radialGradient id="rg_%s" cx="24%%" cy="95%%" r="45%%" gradientUnits="objectBoundingBox">'
            ..'<stop offset="0%%" stop-color="#D9D9D9" stop-opacity="0.9"/>'
            ..'<stop offset="40%%" stop-color="#D9D9D9" stop-opacity="0.5"/>'
            ..'<stop offset="100%%" stop-color="#D9D9D9" stop-opacity="0.05"/>'
            ..'</radialGradient>'
            ..'</defs>'
            ..'<rect width="%s" height="%s" fill="url(#rg_%s)"/>'
            ..'</g>'
            ..'</svg>',
            w, h, w, h,
            id, w, h,
            w, h, radius,
            id,
            id,
            w, h, id
        )

        local linePath = string.format(
            '<svg width="%s" height="%s" viewBox="0 0 %s %s" fill="none" xmlns="http://www.w3.org/2000/svg">'
            ..'<rect width="%s" height="%s" rx="%s" fill="#D9D9D9" fill-opacity="0.2"/>'
            ..'<rect x="0.5" y="0.5" width="%s" height="%s" rx="%s" stroke="url(#paint0_linear_%s)" stroke-opacity="0.45"/>'
            ..'<defs>'
            ..'<linearGradient id="paint0_linear_%s" x1="0" y1="%s" x2="0" y2="0" gradientUnits="userSpaceOnUse">'
            ..'<stop stop-color="white" stop-opacity="0.05"/>'
            ..'<stop offset="1" stop-color="white"/>'
            ..'</linearGradient>'
            ..'</defs>'
            ..'</svg>',
            w, h, w, h,
            w, h, radius,
            w - 1, h - 1, math.max(0, radius - 0.5), id,
            id, h
        )

        item = {
            bg = svgCreate(w, h, bgPath),
            line = svgCreate(w, h, linePath)
        }
        wGroup[h] = item
    end

    if isLine == "line" or isLine == true then
        if isElement(item.line) then
            dxDrawImage(x, y, w, h, item.line, 0, 0, 0, lineColor or color or tocolor(217, 217, 217, 255))
        end
    else
        if isElement(item.bg) then
            dxDrawImage(x, y, w, h, item.bg, 0, 0, 0, color or tocolor(217, 217, 217, 255))
        end
    end
end

addEventHandler("onClientRestore", root, function()
    roundedRectangle("clear")
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    roundedRectangle("clear")
end)
