-- RD4X LAUNCHER | Minimal Edition
-- Interface reconstruida; logica, identificacao e URLs originais preservadas.

local Players            = game:GetService("Players")
local TweenService       = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService       = game:GetService("SoundService")
local Debris             = game:GetService("Debris")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local LOGO_ID    = "109276734890323"
local MUSICA     = "rbxassetid://116105996777798"
local SOM_CLICK  = "rbxassetid://84960553590734"
local TEMPO_LOAD = 3.5

-- Paleta neutra com vinho discreto
local FUNDO       = Color3.fromRGB(15, 15, 18)
local SUPERFICIE  = Color3.fromRGB(24, 24, 29)
local SUPERFICIE2 = Color3.fromRGB(31, 31, 37)
local BORDA       = Color3.fromRGB(48, 47, 54)
local TEXTO       = Color3.fromRGB(235, 233, 236)
local CINZA       = Color3.fromRGB(145, 143, 151)
local DESTAQUE    = Color3.fromRGB(126, 43, 62)
local DESTAQUE2   = Color3.fromRGB(91, 31, 45)
local VERDE       = Color3.fromRGB(91, 166, 119)

local URL_BROOKHAVEN    = "https://raw.githubusercontent.com/lhbzk/Loser/refs/heads/main/rd4x_hubScp.lua"
local URL_BROOKHAVEN_EN = "https://raw.githubusercontent.com/lhbzk/testes_hub/refs/heads/main/English/Rd4X_2026"
local URL_PASS_EXPLODE  = "https://raw.githubusercontent.com/lhbzk/rd4x-server/refs/heads/main/rd4x_bomb.lua"

local IC_HOME  = "rbxthumb://type=Asset&id=16886346348&w=150&h=150"
local IC_BOMB  = "rbxthumb://type=Asset&id=10709793092&w=150&h=150"
local IC_CLOSE = "rbxthumb://type=Asset&id=96089977023576&w=150&h=150"

local function criar(classe, propriedades, pai)
    local objeto = Instance.new(classe)
    for propriedade, valor in pairs(propriedades or {}) do
        objeto[propriedade] = valor
    end
    objeto.Parent = pai
    return objeto
end

local function tw(objeto, duracao, propriedades, estilo)
    local animacao = TweenService:Create(
        objeto,
        TweenInfo.new(duracao, estilo or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        propriedades
    )
    animacao:Play()
    return animacao
end

local function round(objeto, raio)
    return criar("UICorner", {CornerRadius = UDim.new(0, raio or 10)}, objeto)
end

local function line(objeto, cor, transparencia, espessura)
    return criar("UIStroke", {
        Color = cor or BORDA,
        Transparency = transparencia == nil and 0 or transparencia,
        Thickness = espessura or 1
    }, objeto)
end

local function tocarClick()
    pcall(function()
        local som = criar("Sound", {
            SoundId = SOM_CLICK,
            Volume = 0.35
        }, SoundService)
        som:Play()
        Debris:AddItem(som, 3)
    end)
end

for _, nome in ipairs({"RD4XLoading", "RD4XLauncher"}) do
    local existente = playerGui:FindFirstChild(nome)
    if existente then existente:Destroy() end
end

local nomeJogo = ""
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    if info and info.Name then
        nomeJogo = info.Name:lower()
    end
end)

local jogo = "Universal"
if nomeJogo:find("brookhaven") or game.PlaceId == 4924922222 then
    jogo = "Brookhaven"
elseif nomeJogo:find("pass") or nomeJogo:find("explode") or nomeJogo:find("bomba") then
    jogo = "Populares"
end

-- ============================================================
-- LOADING
-- ============================================================
local loadGui = criar("ScreenGui", {
    Name = "RD4XLoading",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    DisplayOrder = 9999
}, playerGui)

local bgLoad = criar("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = FUNDO,
    BorderSizePixel = 0
}, loadGui)

local musicaLoad = criar("Sound", {
    SoundId = MUSICA,
    Volume = 0,
    Looped = true
}, SoundService)
musicaLoad:Play()
tw(musicaLoad, 0.8, {Volume = 0.18})

local wrap = criar("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(340, 220),
    BackgroundTransparency = 1
}, bgLoad)

local logoL = criar("ImageLabel", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 5),
    Size = UDim2.fromOffset(62, 62),
    BackgroundColor3 = SUPERFICIE,
    BackgroundTransparency = 0,
    Image = "rbxthumb://type=Asset&id=" .. LOGO_ID .. "&w=150&h=150",
    ScaleType = Enum.ScaleType.Crop
}, wrap)
round(logoL, 31)
line(logoL, BORDA, 0, 1)

criar("TextLabel", {
    Position = UDim2.new(0, 0, 0, 82),
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    Text = "RD4X LAUNCHER",
    TextColor3 = TEXTO,
    TextSize = 21,
    Font = Enum.Font.GothamBold
}, wrap)

local statusL = criar("TextLabel", {
    Position = UDim2.new(0, 0, 0, 115),
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = "inicializando",
    TextColor3 = CINZA,
    TextSize = 11,
    Font = Enum.Font.Gotham
}, wrap)

local barraBg = criar("Frame", {
    Position = UDim2.new(0.08, 0, 0, 158),
    Size = UDim2.new(0.84, 0, 0, 4),
    BackgroundColor3 = BORDA,
    BorderSizePixel = 0
}, wrap)
round(barraBg, 4)

local barra = criar("Frame", {
    Size = UDim2.fromScale(0, 1),
    BackgroundColor3 = DESTAQUE,
    BorderSizePixel = 0
}, barraBg)
round(barra, 4)

local pct = criar("TextLabel", {
    Position = UDim2.new(0, 0, 0, 170),
    Size = UDim2.new(1, 0, 0, 18),
    BackgroundTransparency = 1,
    Text = "0%",
    TextColor3 = CINZA,
    TextSize = 10,
    Font = Enum.Font.GothamMedium
}, wrap)

local vivo = true
task.spawn(function()
    local inicio = os.clock()
    while vivo and loadGui.Parent do
        local progresso = math.clamp((os.clock() - inicio) / TEMPO_LOAD, 0, 1)
        barra.Size = UDim2.fromScale(progresso, 1)
        pct.Text = math.floor(progresso * 100) .. "%"
        if progresso >= 1 then break end
        task.wait(0.03)
    end

    if not loadGui.Parent then return end
    pct.Text = "100%"
    statusL.Text = "pronto"
    task.wait(0.2)
    vivo = false

    tw(bgLoad, 0.3, {BackgroundTransparency = 1})
    tw(musicaLoad, 0.3, {Volume = 0})
    task.wait(0.35)
    if musicaLoad then musicaLoad:Destroy() end
    if loadGui.Parent then loadGui:Destroy() end

    -- ========================================================
    -- MENU PRINCIPAL
    -- ========================================================
    local sg = criar("ScreenGui", {
        Name = "RD4XLauncher",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        DisplayOrder = 9998
    }, playerGui)

    local ativo = true
    local rodando = false

    local fundo = criar("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    }, sg)

    local main = criar("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.88, 0.76),
        BackgroundColor3 = FUNDO,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, fundo)
    criar("UISizeConstraint", {
        MinSize = Vector2.new(300, 300),
        MaxSize = Vector2.new(560, 460)
    }, main)
    round(main, 14)
    line(main, BORDA, 0, 1)

    -- Cabeçalho
    local header = criar("Frame", {
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundTransparency = 1
    }, main)

    local logoM = criar("ImageLabel", {
        Position = UDim2.fromOffset(18, 14),
        Size = UDim2.fromOffset(42, 42),
        BackgroundColor3 = SUPERFICIE,
        Image = "rbxthumb://type=Asset&id=" .. LOGO_ID .. "&w=150&h=150",
        ScaleType = Enum.ScaleType.Crop
    }, header)
    round(logoM, 21)
    line(logoM, BORDA, 0, 1)

    criar("TextLabel", {
        Position = UDim2.fromOffset(72, 15),
        Size = UDim2.new(1, -130, 0, 22),
        BackgroundTransparency = 1,
        Text = "RD4X LAUNCHER",
        TextColor3 = TEXTO,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, header)

    criar("TextLabel", {
        Position = UDim2.fromOffset(73, 38),
        Size = UDim2.new(1, -135, 0, 16),
        BackgroundTransparency = 1,
        Text = "Biblioteca de scripts",
        TextColor3 = CINZA,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, header)

    local close = criar("ImageButton", {
        Position = UDim2.new(1, -43, 0, 23),
        Size = UDim2.fromOffset(22, 22),
        BackgroundTransparency = 1,
        Image = IC_CLOSE,
        ImageColor3 = CINZA,
        AutoButtonColor = false
    }, header)
    close.MouseEnter:Connect(function()
        tw(close, 0.12, {ImageColor3 = TEXTO})
    end)
    close.MouseLeave:Connect(function()
        tw(close, 0.12, {ImageColor3 = CINZA})
    end)

    criar("Frame", {
        Position = UDim2.new(0, 18, 0, 70),
        Size = UDim2.new(1, -36, 0, 1),
        BackgroundColor3 = BORDA,
        BorderSizePixel = 0
    }, main)

    -- Identificação do jogo
    local statusJogo = criar("Frame", {
        Position = UDim2.new(0, 18, 0, 82),
        Size = UDim2.new(1, -36, 0, 34),
        BackgroundColor3 = SUPERFICIE,
        BorderSizePixel = 0
    }, main)
    round(statusJogo, 8)

    local dot = criar("Frame", {
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.fromOffset(9, 9),
        BackgroundColor3 = VERDE,
        BorderSizePixel = 0
    }, statusJogo)
    round(dot, 9)

    criar("TextLabel", {
        Position = UDim2.fromOffset(30, 0),
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Text = "Jogo detectado  /  " .. jogo,
        TextColor3 = TEXTO,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left
    }, statusJogo)

    -- Abas
    local abaBar = criar("Frame", {
        Position = UDim2.new(0, 18, 0, 128),
        Size = UDim2.new(1, -36, 0, 39),
        BackgroundColor3 = SUPERFICIE,
        BorderSizePixel = 0
    }, main)
    round(abaBar, 8)

    criar("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, abaBar)
    criar("UIPadding", {
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4)
    }, abaBar)

    local content = criar("Frame", {
        Position = UDim2.new(0, 18, 0, 181),
        Size = UDim2.new(1, -36, 1, -211),
        BackgroundTransparency = 1
    }, main)

    local paineis, abas = {}, {}

    local function selecionar(nome)
        for n, painel in pairs(paineis) do
            painel.Visible = (n == nome)
        end
        for n, dados in pairs(abas) do
            local selecionada = (n == nome)
            tw(dados.btn, 0.14, {
                BackgroundColor3 = selecionada and DESTAQUE2 or SUPERFICIE,
                TextColor3 = selecionada and TEXTO or CINZA
            })
            tw(dados.indicador, 0.14, {
                BackgroundTransparency = selecionada and 0 or 1
            })
        end
    end

    local function novaAba(nome, ordem)
        local btn = criar("TextButton", {
            Size = UDim2.new(0.25, -5, 1, 0),
            BackgroundColor3 = SUPERFICIE,
            Text = nome,
            TextColor3 = CINZA,
            TextSize = 10,
            Font = Enum.Font.GothamSemibold,
            AutoButtonColor = false,
            LayoutOrder = ordem
        }, abaBar)
        round(btn, 6)

        local indicador = criar("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, -2),
            Size = UDim2.new(0.32, 0, 0, 2),
            BackgroundColor3 = Color3.fromRGB(190, 105, 122),
            BackgroundTransparency = 1,
            BorderSizePixel = 0
        }, btn)
        round(indicador, 2)

        local painel = criar("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = CINZA,
            ScrollBarImageTransparency = 0.35,
            Visible = false
        }, content)
        criar("UIListLayout", {
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder
        }, painel)
        criar("UIPadding", {
            PaddingTop = UDim.new(0, 3),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2)
        }, painel)

        paineis[nome] = painel
        abas[nome] = {btn = btn, indicador = indicador}
        btn.MouseButton1Click:Connect(function()
            tocarClick()
            selecionar(nome)
        end)
        return painel
    end

    local pBrook = novaAba("Brookhaven", 1)
    local pUniv  = novaAba("Universal", 2)
    local pPop   = novaAba("Populares", 3)
    local pOut   = novaAba("Outros", 4)

    -- Avisos discretos
    local function toast(mensagem)
        local aviso = criar("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, -16),
            Size = UDim2.fromOffset(290, 36),
            BackgroundColor3 = SUPERFICIE2,
            BorderSizePixel = 0,
            ZIndex = 50
        }, sg)
        round(aviso, 8)
        line(aviso, BORDA, 0, 1)
        criar("TextLabel", {
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.new(1, -24, 1, 0),
            BackgroundTransparency = 1,
            Text = mensagem,
            TextColor3 = TEXTO,
            TextSize = 10,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 51
        }, aviso)
        task.delay(2.8, function()
            if aviso and aviso.Parent then
                tw(aviso, 0.2, {BackgroundTransparency = 1})
                task.wait(0.22)
                if aviso.Parent then aviso:Destroy() end
            end
        end)
    end

    -- Item da biblioteca
    local function addScript(painel, icone, texto, url, bloquearComCountdown)
        local btn = criar("TextButton", {
            Size = UDim2.new(1, -4, 0, 60),
            BackgroundColor3 = SUPERFICIE,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false
        }, painel)
        round(btn, 9)
        local borda = line(btn, BORDA, 0, 1)

        local icBg = criar("Frame", {
            Position = UDim2.new(0, 11, 0.5, -18),
            Size = UDim2.fromOffset(36, 36),
            BackgroundColor3 = SUPERFICIE2,
            BorderSizePixel = 0
        }, btn)
        round(icBg, 8)

        criar("ImageLabel", {
            Position = UDim2.fromOffset(6, 6),
            Size = UDim2.new(1, -12, 1, -12),
            BackgroundTransparency = 1,
            Image = icone,
            ScaleType = Enum.ScaleType.Fit
        }, icBg)

        local label = criar("TextLabel", {
            Position = UDim2.fromOffset(59, 0),
            Size = UDim2.new(1, -100, 1, 0),
            BackgroundTransparency = 1,
            Text = texto,
            TextColor3 = TEXTO,
            TextSize = 11,
            Font = Enum.Font.GothamSemibold,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd
        }, btn)

        local seta = criar("TextLabel", {
            Position = UDim2.new(1, -30, 0, 0),
            Size = UDim2.fromOffset(18, 60),
            BackgroundTransparency = 1,
            Text = "›",
            TextColor3 = CINZA,
            TextSize = 21,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Center
        }, btn)

        -- Barreira escura com contagem e aviso por cima do botão
        local barreira = criar("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.fromRGB(8, 8, 11),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 10
        }, btn)
        round(barreira, 9)

        local contadorBarreira = criar("TextLabel", {
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.fromOffset(8, 0),
            BackgroundTransparency = 1,
            Text = "",
            TextColor3 = TEXTO,
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextWrapped = true,
            ZIndex = 11
        }, barreira)

        local bloqueado = false

        local function atualizarEstadoBloqueio()
            if not bloquearComCountdown then
                bloqueado = false
                barreira.Visible = false
                return
            end

            local ate = tonumber(_G.RD4X_BloqueioBrookhavenAte) or 0
            local restante = math.ceil(ate - os.clock())

            if restante > 0 then
                if not bloqueado then
                    bloqueado = true
                    barreira.Visible = true
                    barreira.BackgroundTransparency = 1
                    contadorBarreira.TextTransparency = 1
                    tw(barreira, 0.15, {BackgroundTransparency = 0.28})
                    tw(contadorBarreira, 0.15, {TextTransparency = 0})
                    tw(borda, 0.15, {Color = DESTAQUE2})
                end
                contadorBarreira.Text = "Aguarde update do script... (" .. tostring(restante) .. "s)"
            elseif bloqueado then
                bloqueado = false
                tw(barreira, 0.22, {BackgroundTransparency = 1})
                tw(contadorBarreira, 0.22, {TextTransparency = 1})
                tw(borda, 0.22, {Color = BORDA})
                task.delay(0.24, function()
                    if not bloqueado and barreira and barreira.Parent then
                        barreira.Visible = false
                    end
                end)
            end
        end

        if bloquearComCountdown then
            task.spawn(function()
                while ativo and sg.Parent and btn.Parent do
                    atualizarEstadoBloqueio()
                    task.wait(0.2)
                end
            end)
        end

        btn.MouseEnter:Connect(function()
            if rodando or bloqueado then return end
            tw(btn, 0.12, {BackgroundColor3 = SUPERFICIE2})
            tw(borda, 0.12, {Color = Color3.fromRGB(75, 72, 80)})
            tw(seta, 0.12, {TextColor3 = TEXTO})
        end)
        btn.MouseLeave:Connect(function()
            if rodando or bloqueado then return end
            tw(btn, 0.12, {BackgroundColor3 = SUPERFICIE})
            tw(borda, 0.12, {Color = BORDA})
            tw(seta, 0.12, {TextColor3 = CINZA})
        end)

        btn.MouseButton1Click:Connect(function()
            if rodando then return end
            if bloqueado then
                local rest = math.max(1, math.ceil((tonumber(_G.RD4X_BloqueioBrookhavenAte) or os.clock()) - os.clock()))
                toast("Aguarde update do script... (" .. tostring(rest) .. "s)")
                return
            end

            rodando = true
            tocarClick()
            label.Text = "Carregando script..."
            seta.Text = ""

            local ok, erro = pcall(function()
                local codigo = game:HttpGet(url)
                local fn = loadstring(codigo)
                if not fn then error("loadstring retornou nil") end
                fn()
            end)

            if not ok then
                rodando = false
                label.Text = texto
                seta.Text = "›"
                toast("Falha ao carregar: " .. tostring(erro):sub(1, 75))
                return
            end

            tw(fundo, 0.22, {BackgroundTransparency = 1})
            tw(main, 0.22, {BackgroundTransparency = 1})
            task.wait(0.24)
            ativo = false
            if sg.Parent then sg:Destroy() end
        end)
    end

    addScript(pBrook, IC_HOME, "Brookhaven 🏡 RP < Português 🇧🇷 >", URL_BROOKHAVEN, true)
    addScript(pBrook, IC_HOME, "Brookhaven 🏡 RP < English  >", URL_BROOKHAVEN_EN, true)
    addScript(pPop, IC_BOMB, "Pass or Explode Hub", URL_PASS_EXPLODE, false)

    local function vazio(painel, titulo, descricao)
        local card = criar("Frame", {
            Size = UDim2.new(1, -4, 0, 104),
            BackgroundColor3 = SUPERFICIE,
            BorderSizePixel = 0
        }, painel)
        round(card, 9)
        line(card, BORDA, 0, 1)

        criar("TextLabel", {
            Position = UDim2.new(0, 14, 0, 19),
            Size = UDim2.new(1, -28, 0, 22),
            BackgroundTransparency = 1,
            Text = titulo,
            TextColor3 = TEXTO,
            TextSize = 12,
            Font = Enum.Font.GothamSemibold,
            TextXAlignment = Enum.TextXAlignment.Left
        }, card)

        criar("TextLabel", {
            Position = UDim2.new(0, 14, 0, 44),
            Size = UDim2.new(1, -28, 0, 42),
            BackgroundTransparency = 1,
            Text = descricao,
            TextColor3 = CINZA,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        }, card)
    end

    vazio(pUniv, "RD4X Universal", "Novos scripts universais serão adicionados aqui")
    vazio(pOut, "Outros jogos", "No momento há scripts para Brookhaven e Pass or Explode")

    -- Rodape
    criar("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -7),
        Size = UDim2.new(1, -36, 0, 14),
        BackgroundTransparency = 1,
        Text = "RD4X Team  ·  v1.0",
        TextColor3 = CINZA,
        TextSize = 8,
        Font = Enum.Font.Gotham
    }, main)

    local alvo = jogo
    if not paineis[alvo] then alvo = "Universal" end
    selecionar(alvo)

    local function fechar()
        if not ativo then return end
        tocarClick()
        ativo = false
        tw(fundo, 0.2, {BackgroundTransparency = 1})
        tw(main, 0.2, {BackgroundTransparency = 1})
        task.wait(0.22)
        if sg.Parent then sg:Destroy() end
    end
    close.MouseButton1Click:Connect(fechar)

    -- Entrada curta e sem efeitos de impacto
    main.Size = UDim2.fromScale(0.85, 0.73)
    fundo.BackgroundTransparency = 1
    tw(fundo, 0.22, {BackgroundTransparency = 0.38})
    tw(main, 0.24, {Size = UDim2.fromScale(0.88, 0.76)})
end)
