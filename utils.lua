configs = {
    notification_types = {
        info = {
            title = "Bilgi",
            themeColor = {217, 217, 217},
            iconSvg = [[<svg width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="20" cy="20" r="13" fill="#D9D9D9" fill-opacity="0.6"/><rect x="18.5" y="11" width="3" height="10" rx="1.5" fill="#1C1E22"/><circle cx="20" cy="25" r="1.6" fill="#1C1E22"/></svg>]]
        },
        success = {
            title = "Başarılı",
            themeColor = {76, 175, 80},
            iconSvg = [[<svg width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="20" cy="20" r="13" fill="#4CAF50" fill-opacity="0.9"/><path d="M14 20.5L18 24.5L26 16.5" stroke="#0E2E14" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"/></svg>]]
        },
        error = {
            title = "Hata",
            themeColor = {229, 57, 53},
            iconSvg = [[<svg width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="20" cy="20" r="13" fill="#E53935" fill-opacity="0.9"/><path d="M15 15L25 25M25 15L15 25" stroke="#330D0D" stroke-width="2.6" stroke-linecap="round"/></svg>]]
        },
        warning = {
            title = "Uyarı",
            themeColor = {251, 140, 0},
            iconSvg = [[<svg width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="20" cy="20" r="13" fill="#FB8C00" fill-opacity="0.9"/><rect x="18.5" y="11" width="3" height="10" rx="1.5" fill="#2E1700"/><circle cx="20" cy="25" r="1.6" fill="#2E1700"/></svg>]]
        },
        hello = {
            title = "Merhaba",
            themeColor = {142, 36, 170},
            iconSvg = [[<svg width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="20" cy="20" r="13" fill="#8E24AA" fill-opacity="0.9"/><polygon points="20 12 22 16.5 27 17.2 23.5 20.6 24.3 25.5 20 23.2 15.7 25.5 16.5 20.6 13 17.2 18 16.5" fill="#22052C"/></svg>]]
        }
    },
    aliases = {
        ["başarılı"] = "success",
        ["basarili"] = "success",
        ["succes"] = "success",
        ["hata"] = "error",
        ["danger"] = "error",
        ["err"] = "error",
        ["uyarı"] = "warning",
        ["uyari"] = "warning",
        ["warn"] = "warning",
        ["bilgi"] = "info",
        ["merhaba"] = "hello"
    }
}

function isTypeKey(key)
    if not key then return false end
    local k = tostring(key):lower()
    return (configs.notification_types[k] ~= nil) or (configs.aliases[k] ~= nil)
end

function getTypeKey(key)
    if not key then return "info" end
    local k = tostring(key):lower()
    if configs.notification_types[k] then return k end
    if configs.aliases[k] then return configs.aliases[k] end
    return "info"
end
