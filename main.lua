local notify = { render = false, svgIcons = {} }
local notificationList = {}
local DISPLAY_TIME, ANIM_TIME, MAX_BOXES = 7000, 450, 5
local refW, refH = 1150, 650

local getTickCount = getTickCount
local interpolateBetween = interpolateBetween
local dxDrawImage = dxDrawImage
local dxDrawText = dxDrawText
local dxGetTextWidth = dxGetTextWidth
local dxGetFontHeight = dxGetFontHeight
local tocolor = tocolor
local mathMin = math.min
local mathMax = math.max
local mathFloor = math.floor
local tableInsert = table.insert
local tableRemove = table.remove

addEvent("addBox", true)

local function getNotificationSvg(typeKey)
    local icon = notify.svgIcons[typeKey]
    if not icon then
        local cData = configs.notification_types[typeKey] or configs.notification_types.info
        if cData and cData.iconSvg then
            icon = svgCreate(40, 40, cData.iconSvg)
            notify.svgIcons[typeKey] = icon
        end
    end
    return icon
end

function addBox(arg1, arg2)
    local typeKey, text = arg1, arg2
    if not isTypeKey(arg1) and isTypeKey(arg2) then
        typeKey, text = arg2, arg1
    end
    typeKey = getTypeKey(typeKey)
    text = tostring(text or "")

    if #notificationList >= MAX_BOXES then
        tableRemove(notificationList, 1)
    end

    local now = getTickCount()
    tableInsert(notificationList, {
        type = typeKey,
        text = text,
        lines = nil,
        state = "open",
        tick = now,
        currentY = -120,
        targetY = 0,
        moveTick = now
    })

    if not notify.render then
        notify.render = true
        addEventHandler("onClientRender", root, renderInfobox, false, "low-5")
    end

    if fileExists("public/ses.wav") then
        playSound("public/ses.wav", false)
    end
end
addEventHandler("addBox", root, addBox)

function addBoxNightly(a1, a2) addBox(a1, a2) end
function updateBoxDetails() return true end

function renderInfobox()
    local count = #notificationList
    if count == 0 then
        removeEventHandler("onClientRender", root, renderInfobox)
        notify.render = false
        return
    end

    local screenX, screenY = guiGetScreenSize()
    local scaleX, scaleY = screenX / refW, screenY / refH

    local titleFontSize = mathMax(7.5, mathFloor(7.5 * scaleY + 0.5))
    local bodyFontSize = mathMax(6, mathFloor(6 * scaleY + 0.5))
    local fontTitle = exports.creative_fonts:getFont("SanFranciscoMedium", titleFontSize)
    local fontBody = exports.creative_fonts:getFont("SanFranciscoLight", bodyFontSize)
    local fontIcon = exports.creative_fonts:getFont("FontAwesome", bodyFontSize)

    local mode = getElementData(localPlayer, "showinfobox")
    local vertical = (mode == "orta" or mode == "vertical" or mode == "2" or mode == 2)

    local now = getTickCount()
    local nextList = {}
    local stackOffset = 0
    local edgeTop, edgeLeft = 16 * scaleY, 16 * scaleX

    for i = 1, count do
        local v = notificationList[i]
        local elapsed = now - v.tick
        local alpha = 255
        local draw = true
        local radius = mathFloor(6 * scaleY + 0.5)

        local c = configs.notification_types[v.type] or configs.notification_types.info
        local tr, tg, tb = c.themeColor[1], c.themeColor[2], c.themeColor[3]

        if vertical then
            local boxW, iconSize, pad = 135 * scaleX, 24 * scaleY, 9 * scaleY
            local titleH, bodyH = dxGetFontHeight(1, fontTitle), dxGetFontHeight(1, fontBody)

            if not v.lines then
                local lines, line = {}, ""
                local maxW = boxW - 16 * scaleX
                for w in v.text:gmatch("%S+") do
                    local candidate = (line == "" and w or (line .. " " .. w))
                    if dxGetTextWidth(candidate, 1, fontBody) <= maxW then
                        line = candidate
                    else
                        if line ~= "" then tableInsert(lines, line) end
                        line = w
                    end
                end
                if line ~= "" then tableInsert(lines, line) end
                v.lines = (#lines == 0) and { "" } or lines
            end

            local boxH = pad + iconSize + 5 * scaleY + (titleH + 3 * scaleY + (#v.lines * bodyH)) + pad
            v.width, v.height = boxW, boxH

            local wantedY = edgeTop + stackOffset
            if v.targetY ~= wantedY then
                v.targetY, v.moveTick = wantedY, now
            end

            v.currentY = interpolateBetween(v.currentY, 0, 0, v.targetY, 0, 0, mathMin((now - v.moveTick) / 280, 1), "OutQuad")

            if v.state == "open" then
                alpha = interpolateBetween(0, 0, 0, 255, 0, 0, mathMin(elapsed / ANIM_TIME, 1), "OutQuad")
                if elapsed >= ANIM_TIME then v.state, v.tick = "show", now end
            elseif v.state == "show" then
                if elapsed >= DISPLAY_TIME then v.state, v.tick = "close", now end
            elseif v.state == "close" then
                alpha = interpolateBetween(255, 0, 0, 0, 0, 0, mathMin(elapsed / ANIM_TIME, 1), "InQuad")
                if elapsed >= ANIM_TIME then draw = false end
            end

            if draw then
                local bx, by = (screenX - boxW) * 0.5, v.currentY
                local colorTheme = tocolor(tr, tg, tb, alpha)

                roundedRectangle("ibox_v_bg_" .. v.type, bx, by, boxW, boxH, radius, colorTheme, false)
                roundedRectangle("ibox_v_line_" .. v.type, bx, by, boxW, boxH, radius, colorTheme, "line")

                local iconX, iconY = bx + (boxW - iconSize) * 0.5, by + pad
                local iconRadius = mathFloor(5 * scaleY + 0.5)
                roundedRectangle("ibox_v_icon_bg_" .. v.type, iconX, iconY, iconSize, iconSize, iconRadius, colorTheme, false)
                roundedRectangle("ibox_v_icon_line_" .. v.type, iconX, iconY, iconSize, iconSize, iconRadius, colorTheme, "line")

                local svgElem = getNotificationSvg(v.type)
                if isElement(svgElem) then
                    local iconPad = 2 * scaleY
                    dxDrawImage(iconX + iconPad, iconY + iconPad, iconSize - iconPad * 2, iconSize - iconPad * 2, svgElem, 0, 0, 0, tocolor(255, 255, 255, alpha))
                else
                    dxDrawText(c[4] or "!", iconX, iconY, iconX + iconSize, iconY + iconSize, tocolor(255, 255, 255, alpha), 1, fontIcon, "center", "center")
                end

                local titleY = iconY + iconSize + 4 * scaleY
                dxDrawText(c.title or "Bilgi", bx, titleY, bx + boxW, titleY + titleH, tocolor(235, 235, 235, alpha), 1, fontTitle, "center", "top")

                local bodyY = titleY + titleH + 3 * scaleY
                for li = 1, #v.lines do
                    local ly = bodyY + (li - 1) * bodyH
                    dxDrawText(v.lines[li], bx + 8 * scaleX, ly, bx + boxW - 8 * scaleX, ly + bodyH, tocolor(185, 185, 185, alpha), 1, fontBody, "center", "top")
                end

                tableInsert(nextList, v)
                stackOffset = stackOffset + boxH + 5 * scaleY
            end
        else
            local iconPanel = 28 * scaleY
            local padLeft, padRight, textGap = 7 * scaleX, 16 * scaleX, 9 * scaleX
            local textStart = padLeft + iconPanel + textGap
            local titleH, bodyH = dxGetFontHeight(1, fontTitle), dxGetFontHeight(1, fontBody)

            if not v.lines then
                local titleW = dxGetTextWidth(c.title or "Bilgi", 1, fontTitle)
                local lines = {}
                local maxTextW = 240 * scaleX

                for rawLine in v.text:gmatch("[^\r\n]+") do
                    local current = ""
                    for w in rawLine:gmatch("%S+") do
                        local test = (current == "" and w or (current .. " " .. w))
                        if dxGetTextWidth(test, 1, fontBody) <= maxTextW then
                            current = test
                        else
                            if current ~= "" then
                                tableInsert(lines, current)
                                current = ""
                            end
                            if dxGetTextWidth(w, 1, fontBody) <= maxTextW then
                                current = w
                            else
                                local piece = ""
                                for ch in w:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
                                    if dxGetTextWidth(piece .. ch, 1, fontBody) <= maxTextW then
                                        piece = piece .. ch
                                    else
                                        if piece ~= "" then tableInsert(lines, piece) end
                                        piece = ch
                                    end
                                end
                                current = piece
                            end
                        end
                    end
                    if current ~= "" then tableInsert(lines, current) end
                end

                v.lines = (#lines == 0) and { "" } or lines

                local maxLineW = 0
                for li = 1, #v.lines do
                    local wVal = dxGetTextWidth(v.lines[li], 1, fontBody)
                    if wVal > maxLineW then maxLineW = wVal end
                end

                v.width = textStart + mathMax(titleW, maxLineW) + padRight
                
                local textBlockH = titleH + 3 * scaleY + (#v.lines * bodyH)
                v.height = mathMax(44 * scaleY, 14 * scaleY + textBlockH)
            end

            local boxW = v.width
            local boxH = v.height
            local wantedY = edgeTop + stackOffset
            if v.targetY ~= wantedY then
                v.targetY, v.moveTick = wantedY, now
            end

            v.currentY = interpolateBetween(v.currentY, 0, 0, v.targetY, 0, 0, mathMin((now - v.moveTick) / 280, 1), "OutQuad")

            if v.state == "open" then
                alpha = interpolateBetween(0, 0, 0, 255, 0, 0, mathMin(elapsed / ANIM_TIME, 1), "OutQuad")
                if elapsed >= ANIM_TIME then v.state, v.tick = "show", now end
            elseif v.state == "show" then
                if elapsed >= DISPLAY_TIME then v.state, v.tick = "close", now end
            elseif v.state == "close" then
                alpha = interpolateBetween(255, 0, 0, 0, 0, 0, mathMin(elapsed / ANIM_TIME, 1), "InQuad")
                if elapsed >= ANIM_TIME then draw = false end
            end

            if draw then
                local bx, by = edgeLeft, v.currentY
                local colorTheme = tocolor(tr, tg, tb, alpha)

                roundedRectangle("ibox_h_bg_" .. v.type, bx, by, boxW, boxH, radius, colorTheme, false)
                roundedRectangle("ibox_h_line_" .. v.type, bx, by, boxW, boxH, radius, colorTheme, "line")

                local iconX, iconY = bx + padLeft, by + (boxH - iconPanel) * 0.5
                local iconRadius = mathFloor(5 * scaleY + 0.5)
                roundedRectangle("ibox_h_icon_bg_" .. v.type, iconX, iconY, iconPanel, iconPanel, iconRadius, colorTheme, false)
                roundedRectangle("ibox_h_icon_line_" .. v.type, iconX, iconY, iconPanel, iconPanel, iconRadius, colorTheme, "line")

                local svgElem = getNotificationSvg(v.type)
                if isElement(svgElem) then
                    local iconPad = 2 * scaleY
                    dxDrawImage(iconX + iconPad, iconY + iconPad, iconPanel - iconPad * 2, iconPanel - iconPad * 2, svgElem, 0, 0, 0, tocolor(255, 255, 255, alpha))
                else
                    dxDrawText(c[4] or "!", iconX, iconY, iconX + iconPanel, iconY + iconPanel, tocolor(255, 255, 255, alpha), 1, fontIcon, "center", "center")
                end

                local textX = bx + textStart
                local textBlockH = titleH + 3 * scaleY + (#v.lines * bodyH)
                local titleY = by + (boxH - textBlockH) * 0.5
                
                dxDrawText(c.title or "Bilgi", textX, titleY, bx + boxW - padRight, titleY + titleH, tocolor(235, 235, 235, alpha), 1, fontTitle, "left", "center")

                local bodyY = titleY + titleH + 3 * scaleY
                for li = 1, #v.lines do
                    local ly = bodyY + (li - 1) * bodyH
                    dxDrawText(v.lines[li], textX, ly, bx + boxW - padRight, ly + bodyH, tocolor(185, 185, 185, alpha), 1, fontBody, "left", "top")
                end

                tableInsert(nextList, v)
                stackOffset = stackOffset + boxH + 5 * scaleY
            end
        end
    end

    notificationList = nextList
end

addCommandHandler("infotest", function()
    addBox("info", "CreativeMTA & Script Dünyam ")
    addBox("success", "Başarılı bir şekilde /status durumunu etkinleştirdiniz.")
    addBox("warning", "Dikkat! Sistemde bir uyarı mevcut.")
    addBox("error", "Hata! İşlem gerçekleştirilemedi.")
end)

--