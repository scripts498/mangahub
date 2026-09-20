--// ============================================================
--//                      MANGA HUB LOADER
--// ============================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer


--// ============================================================
--// CONFIG
--// ============================================================

local BASE_URL =
    "https://raw.githubusercontent.com/scripts498/mangahub/refs/heads/main/"


--// ============================================================
--// JOGOS SUPORTADOS
--// ============================================================

local Scripts = {}

local function register(gameId, fileName)
    Scripts[gameId] = BASE_URL .. fileName
end


register(66654135, "murdermystery2")

register(498792494, "BBB%20brasil")

register(1686885941, "manga%20hub%20brookhaven")

register(372226183, "fleethefacility")

register(10148749921, "hospital%20de%20animais")

register(4948814458, "fortline%20manga%20hub")

register(6325043396, "flex%20you%20fps")

register(2668101271, "FTAP.lua")


--// ============================================================
--// LOADER
--// ============================================================

local function loadMangaHub()
    local url = Scripts[game.GameId]

    if not url then
        LocalPlayer:Kick(
            "Esse jogo não é suportado pelo Manga Hub.\n\n"
            .. "GameId: "
            .. tostring(game.GameId)
        )

        return
    end

    local success, result = pcall(function()
        local source = game:HttpGet(url, true)

        local compiled, compileError = loadstring(source)

        if not compiled then
            error(
                "Erro ao compilar o script:\n"
                .. tostring(compileError)
            )
        end

        return compiled()
    end)

    if not success then
        warn("[MANGA HUB] Erro ao carregar:")
        warn(result)

        LocalPlayer:Kick(
            "O Manga Hub encontrou um erro ao carregar.\n"
            .. "Tente novamente mais tarde."
        )
    end
end


--// ============================================================
--// START
--// ============================================================

loadMangaHub()
