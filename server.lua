function addBox(sourceElement, arg1, arg2)    
    if isElement(sourceElement) then
        triggerClientEvent(sourceElement, "addBox", sourceElement, arg1, arg2)
    end
end
addEvent("addBox", true)
addEventHandler("addBox", root, addBox)

function addBoxNightly(sourceElement, arg1, arg2)    
    if isElement(sourceElement) then
        triggerClientEvent(sourceElement, "addBox", sourceElement, arg1, arg2)
    end
end

function showinfobox(player, cmd, data)
    if isElement(player) then
        setElementData(player, "showinfobox", data)
    end
end
addCommandHandler("seainfodegistirla", showinfobox)