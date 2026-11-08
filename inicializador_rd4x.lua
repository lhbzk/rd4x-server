-- ==========================================================
-- RD4X LAUNCHER | PREMIUM CARMESIM
-- Loading + Launcher
-- ==========================================================

-- CONFIGURAÇÃO
local LOGO_IMAGE_ID = "109276734890323"
local LOGO_LETRA = "R"
local MENU_TRANSPARENCIA = 0.16

local MUSICA_ID = "116105996777798"
local MUSICA_VOLUME = 0.5
local TOQUE_ID = "84960553590734"
local TOQUE_VOLUME = 0.5

local ICONE_HOME = "rbxthumb://type=Asset&id=10709790875&w=150&h=150"
local ICONE_BOMB = "rbxthumb://type=Asset&id=10709793092&w=150&h=150"
local ICONE_CLOSE = "rbxthumb://type=Asset&id=96089977023576&w=150&h=150"

-- SERVIÇOS
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- PALETA
local COR_FUNDO = Color3.fromRGB(12, 12, 16)
local COR_CARD = Color3.fromRGB(23, 23, 30)
local COR_CARD2 = Color3.fromRGB(31, 29, 37)
local COR_BORDA = Color3.fromRGB(65, 35, 43)
local COR_TEXTO = Color3.fromRGB(245, 242, 245)
local COR_CINZA = Color3.fromRGB(145, 139, 150)
local COR_NEON = Color3.fromRGB(225, 25, 65)
local COR_ESCURO = Color3.fromRGB(105, 10, 30)
local COR_VERDE = Color3.fromRGB(70, 205, 125)

-- LINKS
local URL_BROOKHAVEN =
    "https://raw.githubusercontent.com/lhbzk/Loser/refs/heads/main/rd4x_hubScp.lua"

local URL_PASS_EXPLODE =
    "https://raw.githubusercontent.com/lhbzk/rd4x-server/refs/heads/main/rd4x_bomb.lua"

-- HELPERS
local function criar(class, props, parent)
    local obj = Instance.new(class)

    for k, v in pairs(props or {}) do
        obj[k] = v
    end

    obj.Parent = parent
    return obj
end

local function tween(obj, tempo, props, estilo)
    local info = TweenInfo.new(
        tempo,
        estilo or Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )

    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local function corner(obj, raio)
    return criar("UICorner", {
        CornerRadius = UDim.new(0, raio or 12)
    }, obj)
end

local function stroke(obj, cor, transparencia, espessura)
    return criar("UIStroke", {
        Color = cor or COR_BORDA,
        Transparency = transparencia or 0.3,
        Thickness = espessura or 1
    }, obj)
end

local function normalizarImagem(id)
    if not id then return nil end

    id = tostring(id):gsub("%s+", "")

    if id == "" then return nil end

    if id:find("rbxassetid://")
        or id:find("rbxthumb://")
        or id:find("http") then
        return id
    end

    local num = id:match("%d+")

    if num then
        return "rbxthumb://type=Asset&id=" .. num .. "&w=150&h=150"
    end

    return nil
end

local function normalizarSom(id)
    if not id then return nil end

    id = tostring(id):gsub("%s+", "")

    if id:find("rbxassetid://") then
        return id
    end

    local num = id:match("%d+")

    if num then
        return "rbxassetid://" .. num
    end

    return nil
end

local LOGO_IMAGEM = normalizarImagem(LOGO_IMAGE_ID)
local MUSICA_ASSET = normalizarSom(MUSICA_ID)
local TOQUE_ASSET = normalizarSom(TOQUE_ID)

local function tocarToque()
    if not TOQUE_ASSET then return end

    pcall(function()
        local s = criar("Sound", {
            SoundId = TOQUE_ASSET,
            Volume = TOQUE_VOLUME
        }, SoundService)

        s:Play()
        Debris:AddItem(s, 3)
    end)
end

local function criarLogo(parent, tamanho, zindex)
    if LOGO_IMAGEM then
        local img = criar("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Image = LOGO_IMAGEM,
            ScaleType = Enum.ScaleType.Crop,
            ZIndex = zindex
        }, parent)

        corner(img, 100)
    else
        criar("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = LOGO_LETRA,
            TextColor3 = COR_TEXTO,
            TextSize = tamanho,
            Font = Enum.Font.GothamBlack,
            ZIndex = zindex
        }, parent)
    end
end

-- LIMPEZA
for _, nome in ipairs({"RD4XLoading", "RD4XLauncher"}) do
    local antigo = playerGui:FindFirstChild(nome)
    if antigo then antigo:Destroy() end
end

local blur = Lighting:FindFirstChild("RD4XBlur")

if not blur then
    blur = criar("BlurEffect", {
        Name = "RD4XBlur",
        Size = 0
    }, Lighting)
end

-- DETECÇÃO DO JOGO
local idJogo = game.PlaceId
local nomeJogo = ""

pcall(function()
    local info = MarketplaceService:GetProductInfo(idJogo)
    if info and info.Name then
        nomeJogo = info.Name:lower()
    end
end)

local jogoDetectado = "Outros"

if nomeJogo:find("brookhaven") or idJogo == 4924922222 then
    jogoDetectado = "Brookhaven"
elseif nomeJogo:find("pass")
    or nomeJogo:find("explode")
    or nomeJogo:find("bomba") then
    jogoDetectado = "Populares"
else
    jogoDetectado = "Universal"
end

-- ==========================================================
-- LOADING SCREEN
-- ==========================================================

local loadGui = criar("ScreenGui", {
    Name = "RD4XLoading",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    DisplayOrder = 9999
}, playerGui)

local bgLoad = criar("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = COR_FUNDO,
    BorderSizePixel = 0
}, loadGui)

local musicaLoad

if MUSICA_ASSET then
    musicaLoad = criar("Sound", {
        SoundId = MUSICA_ASSET,
        Volume = 0,
        Looped = true
    }, SoundService)

    musicaLoad:Play()
    tween(musicaLoad, 1, {Volume = MUSICA_VOLUME})
end

-- BRILHO
local glow = criar("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.45),
    Size = UDim2.fromOffset(260, 260),
    BackgroundColor3 = COR_NEON,
    BackgroundTransparency = 0.72,
    BorderSizePixel = 0
}, bgLoad)

corner(glow, 200)

criar("UIGradient", {
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.5, 0.65),
        NumberSequenceKeypoint.new(1, 1)
    })
}, glow)

-- PARTÍCULAS
local bolhas = criar("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    ClipsDescendants = true
}, bgLoad)

local loadingAtivo = true

local function criarParticula(parent)
    local b = criar("Frame", {
        Size = UDim2.fromOffset(math.random(4, 11), math.random(4, 11)),
        Position = UDim2.new(math.random(), 0, 1, 10),
        BackgroundColor3 = COR_NEON,
        BackgroundTransparency = math.random(55, 85) / 100,
        BorderSizePixel = 0
    }, parent)

    corner(b, 100)

    local tw = tween(b, math.random(5, 9), {
        Position = UDim2.new(b.Position.X.Scale, 0, 0, -30),
        BackgroundTransparency = 1
    }, Enum.EasingStyle.Linear)

    tw.Completed:Connect(function()
        if b.Parent then b:Destroy() end
    end)
end

task.spawn(function()
    while loadingAtivo and loadGui.Parent do
        criarParticula(bolhas)
        task.wait(math.random(10, 25) / 100)
    end
end)

-- CONTEÚDO
local container = criar("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(380, 230),
    BackgroundTransparency = 1
}, bgLoad)

local logoFrame = criar("Frame", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 0),
    Size = UDim2.fromOffset(76, 76),
    BackgroundColor3 = COR_CARD,
    BorderSizePixel = 0
}, container)

corner(logoFrame, 100)
stroke(logoFrame, COR_NEON, 0.1, 2)
criarLogo(logoFrame, 36, 3)

local tituloLoad = criar("TextLabel", {
    Position = UDim2.new(0, 0, 0, 90),
    Size = UDim2.new(1, 0, 0, 35),
    BackgroundTransparency = 1,
    Text = "RD4X LAUNCHER",
    TextColor3 = COR_TEXTO,
    TextSize = 24,
    Font = Enum.Font.GothamBlack
}, container)

local subtituloLoad = criar("TextLabel", {
    Position = UDim2.new(0, 0, 0, 125),
    Size = UDim2.new(1, 0, 0, 22),
    BackgroundTransparency = 1,
    Text = "Preparando seus sistemas...",
    TextColor3 = COR_CINZA,
    TextSize = 11,
    Font = Enum.Font.GothamMedium
}, container)

local barBG = criar("Frame", {
    Position = UDim2.new(0.08, 0, 0, 170),
    Size = UDim2.new(0.84, 0, 0, 5),
    BackgroundColor3 = COR_BORDA,
    BorderSizePixel = 0
}, container)

corner(barBG, 100)

local bar = criar("Frame", {
    Size = UDim2.fromScale(0, 1),
    BackgroundColor3 = COR_NEON,
    BorderSizePixel = 0
}, barBG)

corner(bar, 100)

criar("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COR_ESCURO),
        ColorSequenceKeypoint.new(0.5, COR_NEON),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 110, 130))
    })
}, bar)

local porcentagem = criar("TextLabel", {
    Position = UDim2.new(0, 0, 0, 185),
    Size = UDim2.new(1, 0, 0, 22),
    BackgroundTransparency = 1,
    Text = "0%",
    TextColor3 = COR_NEON,
    TextSize = 12,
    Font = Enum.Font.GothamBold
}, container)

-- ANIMAÇÃO DO BRILHO
task.spawn(function()
    while loadingAtivo and loadGui.Parent do
        tween(glow, 1.2, {
            Size = UDim2.fromOffset(290, 290),
            BackgroundTransparency = 0.8
        })

        task.wait(1.2)

        tween(glow, 1.2, {
            Size = UDim2.fromOffset(260, 260),
            BackgroundTransparency = 0.72
        })

        task.wait(1.2)
    end
end)

-- PROGRESSO SINCRONIZADO
task.spawn(function()
    local duracao = 8.2
    local inicio = os.clock()

    while loadingAtivo and loadGui.Parent do
        local p = math.clamp((os.clock() - inicio) / duracao, 0, 1)

        bar.Size = UDim2.fromScale(p, 1)
        porcentagem.Text = math.floor(p * 100) .. "%"

        if p >= 1 then break end
        task.wait(0.03)
    end

    porcentagem.Text = "100%"
    subtituloLoad.Text = "Sistemas prontos!"

    task.wait(0.6)

    local saida = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    for _, obj in ipairs({bgLoad, tituloLoad, subtituloLoad, porcentagem, logoFrame, barBG, glow}) do
        if obj:IsA("TextLabel") then
            TweenService:Create(obj, saida, {TextTransparency = 1}):Play()
        elseif obj:IsA("Frame") then
            TweenService:Create(obj, saida, {BackgroundTransparency = 1}):Play()
        end
    end

    loadingAtivo = false

    if musicaLoad then
        tween(musicaLoad, 0.5, {Volume = 0})
        task.wait(0.5)
        musicaLoad:Destroy()
    end

    task.wait(0.15)
    loadGui:Destroy()

    -- ======================================================
    -- LAUNCHER PRINCIPAL
    -- ======================================================

    local screenGui = criar("ScreenGui", {
        Name = "RD4XLauncher",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        DisplayOrder = 9998
    }, playerGui)

    local launcherAtivo = true
    local executando = false

    local fundo = criar("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    }, screenGui)

    local main = criar("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.92, 0.78),
        BackgroundColor3 = COR_FUNDO,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, fundo)

    criar("UISizeConstraint", {
        MinSize = Vector2.new(300, 300),
        MaxSize = Vector2.new(540, 440)
    }, main)

    corner(main, 20)

    local bordaMain = stroke(main, COR_NEON, 1, 1.3)

    -- FUNDO COM GRADIENTE
    criar("UIGradient", {
        Rotation = 135,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(29, 16, 24)),
            ColorSequenceKeypoint.new(0.5, COR_FUNDO),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 12, 19))
        })
    }, main)

    -- BRILHO SUPERIOR
    local brilho = criar("Frame", {
        Position = UDim2.new(0.5, -150, 0, -130),
        Size = UDim2.fromOffset(300, 230),
        BackgroundColor3 = COR_NEON,
        BackgroundTransparency = 0.88,
        BorderSizePixel = 0,
        ZIndex = 1
    }, main)

    corner(brilho, 200)

    criar("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.1),
            NumberSequenceKeypoint.new(1, 1)
        })
    }, brilho)

    -- PARTÍCULAS DO MENU
    local particulas = criar("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 1
    }, main)

    task.spawn(function()
        while launcherAtivo and screenGui.Parent do
            criarParticula(particulas)
            task.wait(math.random(20, 45) / 100)
        end
    end)

    -- HEADER
    local header = criar("Frame", {
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 76),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, main)

    local logo = criar("Frame", {
        Position = UDim2.fromOffset(17, 15),
        Size = UDim2.fromOffset(44, 44),
        BackgroundColor3 = COR_CARD,
        BorderSizePixel = 0,
        ZIndex = 4
    }, header)

    corner(logo, 100)
    stroke(logo, COR_NEON, 0.15, 1.5)
    criarLogo(logo, 22, 5)

    local titulo = criar("TextLabel", {
        Position = UDim2.fromOffset(72, 17),
        Size = UDim2.new(1, -135, 0, 22),
        BackgroundTransparency = 1,
        Text = "RD4X LAUNCHER",
        TextColor3 = COR_TEXTO,
        TextSize = 16,
        Font = Enum.Font.GothamBlack,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4
    }, header)

    local subtitulo = criar("TextLabel", {
        Position = UDim2.fromOffset(73, 40),
        Size = UDim2.new(1, -140, 0, 17),
        BackgroundTransparency = 1,
        Text = "Selecione seu próximo destino",
        TextColor3 = COR_CINZA,
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4
    }, header)

    local close = criar("ImageButton", {
        Position = UDim2.new(1, -43, 0, 24),
        Size = UDim2.fromOffset(24, 24),
        BackgroundTransparency = 1,
        Image = ICONE_CLOSE,
        ImageColor3 = COR_CINZA,
        AutoButtonColor = false,
        ZIndex = 5
    }, header)

    close.MouseEnter:Connect(function()
        tween(close, 0.15, {ImageColor3 = COR_NEON})
    end)

    close.MouseLeave:Connect(function()
        tween(close, 0.15, {ImageColor3 = COR_CINZA})
    end)

    -- LINHA DO HEADER
    local linha = criar("Frame", {
        Position = UDim2.new(0, 18, 0, 76),
        Size = UDim2.new(1, -36, 0, 1),
        BackgroundColor3 = COR_BORDA,
        BorderSizePixel = 0,
        ZIndex = 3
    }, main)

    -- INDICADOR DE JOGO
    local statusJogo = criar("Frame", {
        Position = UDim2.new(0, 18, 0, 88),
        Size = UDim2.new(1, -36, 0, 36),
        BackgroundColor3 = COR_CARD,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ZIndex = 3
    }, main)

    corner(statusJogo, 10)
    stroke(statusJogo, COR_BORDA, 0.5, 1)

    local bolinhaStatus = criar("Frame", {
        Position = UDim2.fromOffset(12, 13),
        Size = UDim2.fromOffset(10, 10),
        BackgroundColor3 = COR_VERDE,
        BorderSizePixel = 0,
        ZIndex = 4
    }, statusJogo)

    corner(bolinhaStatus, 100)

    criar("TextLabel", {
        Position = UDim2.fromOffset(31, 0),
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Text = "Jogo detectado: " .. jogoDetectado,
        TextColor3 = COR_TEXTO,
        TextSize = 11,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4
    }, statusJogo)

    -- ABAS
    local abaBar = criar("Frame", {
        Position = UDim2.new(0, 18, 0, 136),
        Size = UDim2.new(1, -36, 0, 42),
        BackgroundColor3 = COR_CARD,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 3
    }, main)

    corner(abaBar, 10)

    local abaLayout = criar("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, abaBar)

    local content = criar("Frame", {
        Position = UDim2.new(0, 18, 0, 190),
        Size = UDim2.new(1, -36, 1, -207),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, main)

    local paineis = {}
    local botoesAbas = {}

    local function selecionarAba(nome)
        for n, painel in pairs(paineis) do
            painel.Visible = n == nome
        end

        for n, dados in pairs(botoesAbas) do
            local ativo = n == nome

            tween(dados.btn, 0.2, {
                BackgroundColor3 = ativo and COR_ESCURO or COR_CARD,
                BackgroundTransparency = ativo and 0.05 or 0.5,
                TextColor3 = ativo and COR_TEXTO or COR_CINZA
            })

            tween(dados.borda, 0.2, {
                Transparency = ativo and 0.1 or 1
            })
        end
    end

    local function criarAba(nome, ordem)
        local btn = criar("TextButton", {
            Size = UDim2.new(0.23, -3, 1, -8),
            BackgroundColor3 = COR_CARD,
            BackgroundTransparency = 0.5,
            Text = nome,
            TextColor3 = COR_CINZA,
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
            LayoutOrder = ordem,
            ZIndex = 4
        }, abaBar)

        corner(btn, 8)

        local borda = stroke(btn, COR_NEON, 1, 1)

        local painel = criar("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = COR_NEON,
            Visible = false,
            ZIndex = 3
        }, content)

        criar("UIListLayout", {
            Padding = UDim.new(0, 10),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder
        }, painel)

        criar("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 3),
            PaddingRight = UDim.new(0, 3)
        }, painel)

        paineis[nome] = painel
        botoesAbas[nome] = {
            btn = btn,
            borda = borda
        }

        btn.MouseButton1Click:Connect(function()
            tocarToque()
            selecionarAba(nome)
        end)

        return painel
    end

    local abaBrookhaven = criarAba("Brookhaven", 1)
    local abaUniversal = criarAba("Universal", 2)
    local abaPopulares = criarAba("Populares", 3)
    local abaOutros = criarAba("Outros", 4)

    -- BOTÕES DE SCRIPTS
    local function adicionarBotao(painel, iconeId, texto, callback, cor)
        local btn = criar("TextButton", {
            Size = UDim2.new(1, -6, 0, 62),
            BackgroundColor3 = COR_CARD,
            BackgroundTransparency = 0.12,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 4
        }, painel)

        corner(btn, 12)

        local borda = stroke(btn, cor or COR_NEON, 0.65, 1)

        local destaque = criar("Frame", {
            Position = UDim2.new(0, 0, 0.2, 0),
            Size = UDim2.new(0, 3, 0.6, 0),
            BackgroundColor3 = cor or COR_NEON,
            BorderSizePixel = 0,
            ZIndex = 5
        }, btn)

        corner(destaque, 10)

        local iconeFundo = criar("Frame", {
            Position = UDim2.new(0, 12, 0.5, -19),
            Size = UDim2.fromOffset(38, 38),
            BackgroundColor3 = COR_FUNDO,
            BorderSizePixel = 0,
            ZIndex = 5
        }, btn)

        corner(iconeFundo, 11)

        criar("ImageLabel", {
            Position = UDim2.fromOffset(5, 5),
            Size = UDim2.new(1, -10, 1, -10),
            BackgroundTransparency = 1,
            Image = iconeId,
            ScaleType = Enum.ScaleType.Fit,
            ZIndex = 6
        }, iconeFundo)

        criar("TextLabel", {
            Position = UDim2.fromOffset(60, 0),
            Size = UDim2.new(1, -100, 1, 0),
            BackgroundTransparency = 1,
            Text = texto,
            TextColor3 = COR_TEXTO,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5
        }, btn)

        local seta = criar("TextLabel", {
            Position = UDim2.new(1, -35, 0, 0),
            Size = UDim2.fromOffset(24, 62),
            BackgroundTransparency = 1,
            Text = "›",
            TextColor3 = COR_CINZA,
            TextSize = 25,
            Font = Enum.Font.GothamBold,
            ZIndex = 5
        }, btn)

        btn.MouseEnter:Connect(function()
            tween(btn, 0.18, {
                BackgroundColor3 = COR_CARD2,
                BackgroundTransparency = 0
            })

            tween(borda, 0.18, {
                Transparency = 0.1
            })

            tween(seta, 0.18, {
                TextColor3 = COR_NEON,
                Position = UDim2.new(1, -29, 0, 0)
            })
        end)

        btn.MouseLeave:Connect(function()
            tween(btn, 0.18, {
                BackgroundColor3 = COR_CARD,
                BackgroundTransparency = 0.12
            })

            tween(borda, 0.18, {
                Transparency = 0.65
            })

            tween(seta, 0.18, {
                TextColor3 = COR_CINZA,
                Position = UDim2.new(1, -35, 0, 0)
            })
        end)

        btn.MouseButton1Click:Connect(function()
            if executando then return end
            executando = true

            tocarToque()

            tween(fundo, 0.3, {
                BackgroundTransparency = 1
            })

            tween(main, 0.3, {
                Size = UDim2.fromScale(0.82, 0.68),
                BackgroundTransparency = 1
            })

            tween(blur, 0.3, {Size = 0})

            task.wait(0.32)

            launcherAtivo = false
            screenGui:Destroy()

            if callback then
                task.spawn(function()
                    local sucesso, erro = pcall(callback)
                    if not sucesso then
                        warn("[RD4X Launcher] Erro ao executar:", erro)
                    end
                end)
            end
        end)
    end

    adicionarBotao(
        abaBrookhaven,
        ICONE_HOME,
        "Carregar RD4X Hub (Brookhaven)",
        function()
            loadstring(game:HttpGet(URL_BROOKHAVEN))()
        end
    )

    adicionarBotao(
        abaPopulares,
        ICONE_BOMB,
        "Pass or Explode Hub",
        function()
            loadstring(game:HttpGet(URL_PASS_EXPLODE))()
        end
    )

    -- MENSAGEM PARA ABAS SEM SCRIPT
    local function mensagemVazia(painel, titulo, descricao)
        local card = criar("Frame", {
            Size = UDim2.new(1, -6, 0, 115),
            BackgroundColor3 = COR_CARD,
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0
        }, painel)

        corner(card, 12)
        stroke(card, COR_BORDA, 0.5, 1)

        criar("TextLabel", {
            Position = UDim2.new(0, 10, 0, 20),
            Size = UDim2.new(1, -20, 0, 25),
            BackgroundTransparency = 1,
            Text = titulo,
            TextColor3 = COR_TEXTO,
            TextSize = 13,
            Font = Enum.Font.GothamBold
        }, card)

        criar("TextLabel", {
            Position = UDim2.new(0, 15, 0, 48),
            Size = UDim2.new(1, -30, 0, 40),
            BackgroundTransparency = 1,
            Text = descricao,
            TextColor3 = COR_CINZA,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextWrapped = true
        }, card)
    end

    mensagemVazia(
        abaUniversal,
        "RD4X Universal",
        "Novos scripts universais serão adicionados em breve."
    )

    mensagemVazia(
        abaOutros,
        "Outros jogos",
        "Estamos preparando novas experiências para o RD4X."
    )

    -- RODAPÉ
    local footer = criar("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -5),
        Size = UDim2.new(1, -36, 0, 17),
        BackgroundTransparency = 1,
        Text = "RD4X TEAM  •  PREMIUM EXPERIENCE",
        TextColor3 = COR_CINZA,
        TextSize = 8,
        Font = Enum.Font.GothamMedium,
        ZIndex = 4
    }, main)

    -- SELEÇÃO AUTOMÁTICA
    local abaAuto = jogoDetectado

    if not paineis[abaAuto] then
        abaAuto = "Universal"
    end

    selecionarAba(abaAuto)

    -- FECHAR
    local function fecharLauncher()
        if not launcherAtivo then return end

        tocarToque()
        launcherAtivo = false

        tween(fundo, 0.3, {
            BackgroundTransparency = 1
        })

        tween(main, 0.3, {
            Size = UDim2.fromScale(0.82, 0.68),
            BackgroundTransparency = 1
        })

        tween(blur, 0.3, {Size = 0})

        task.wait(0.32)

        if screenGui.Parent then
            screenGui:Destroy()
        end
    end

    close.MouseButton1Click:Connect(fecharLauncher)

    -- ANIMAÇÃO DE ENTRADA
    main.Size = UDim2.fromScale(0.78, 0.65)
    fundo.BackgroundTransparency = 1

    tween(fundo, 0.45, {
        BackgroundTransparency = 0.38
    })

    tween(blur, 0.5, {
        Size = 18
    })

    tween(main, 0.55, {
        Size = UDim2.fromScale(0.92, 0.78),
        BackgroundTransparency = MENU_TRANSPARENCIA
    }, Enum.EasingStyle.Back)

    tween(bordaMain, 0.55, {
        Transparency = 0.15
    })

    -- BRILHO ANIMADO
    task.spawn(function()
        while launcherAtivo and screenGui.Parent do
            tween(brilho, 1.5, {
                BackgroundTransparency = 0.93
            })

            task.wait(1.5)

            tween(brilho, 1.5, {
                BackgroundTransparency = 0.84
            })

            task.wait(1.5)
        end
    end)
end) 
