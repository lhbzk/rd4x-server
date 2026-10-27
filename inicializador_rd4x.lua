-- ==========================================================
-- 🚀 RD4X LAUNCHER PRO - Loading + Menu Moderno (v2)
-- ==========================================================

-- ╔════════════════════════════════════════════════════════╗
-- ║  ⚙️ CONFIGURAÇÃO RÁPIDA                                ║
-- ╚════════════════════════════════════════════════════════╝
local LOGO_IMAGE_ID      = "109276734890323"     -- Cole o ID da imagem aqui. Ex: "109276734890323" ou "rbxassetid://123456789"
                                  -- Se deixar vazio, aparece a letra "R"
local LOGO_LETRA         = "R"    -- Letra mostrada quando não há imagem
local LOGO_NO_MENU       = true   -- true = usa a mesma imagem no ícone do cabeçalho do menu
local MENU_TRANSPARENCIA = 0.35   -- 0 = sólido | 1 = invisível (0.35 = meio escuro/transparente)
local BOLHAS_NO_MENU     = true   -- bolhas subindo dentro do menu

-- 🎵 ÁUDIO
local MUSICA_ID          = "116105996777798"  -- Música da tela de carregamento (vazio = sem música)
local MUSICA_VOLUME      = 5.6                -- 0 a 1
local TOQUE_ID           = "84960553590734"   -- Som de toque/clique nos botões (vazio = sem som)
local TOQUE_VOLUME       = 3.8                -- 0 a 1

local Players             = game:GetService("Players")
local TweenService        = game:GetService("TweenService")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local MarketplaceService  = game:GetService("MarketplaceService")
local SoundService        = game:GetService("SoundService")

local player     = Players.LocalPlayer
local playerGui  = player:WaitForChild("PlayerGui")

-- ─────────────────────────────────────────────────────────
-- PALETA
-- ─────────────────────────────────────────────────────────
local COR_FUNDO      = Color3.fromRGB(8, 10, 16)
local COR_CARD       = Color3.fromRGB(18, 22, 34)
local COR_BORDA      = Color3.fromRGB(45, 85, 155)
local COR_TEXTO      = Color3.fromRGB(240, 245, 255)
local COR_TEXTO_CINZA= Color3.fromRGB(150, 165, 190)
local COR_AZUL       = Color3.fromRGB(60, 150, 255)
local COR_AZUL_ESCURO= Color3.fromRGB(20, 60, 130)

-- ─────────────────────────────────────────────────────────
-- HELPERS
-- ─────────────────────────────────────────────────────────
local function normalizarImagem(id)
    if id == nil then return nil end
    id = tostring(id):gsub("%s+", "")
    if id == "" then return nil end
    if id:find("rbxassetid://") or id:find("http") then return id end
    local num = id:match("%d+")
    if num then return "rbxassetid://" .. num end
    return nil
end

local LOGO_IMAGEM = normalizarImagem(LOGO_IMAGE_ID)

-- Áudio
local MUSICA_ASSET = normalizarImagem(MUSICA_ID)
local TOQUE_ASSET  = normalizarImagem(TOQUE_ID)

local function tocarToque()
    if not TOQUE_ASSET then return end
    pcall(function()
        local s = Instance.new("Sound")
        s.Name = "RD4XToque"
        s.SoundId = TOQUE_ASSET
        s.Volume = TOQUE_VOLUME
        s.Parent = SoundService
        s:Play()
        s.Ended:Connect(function() s:Destroy() end)
        game:GetService("Debris"):AddItem(s, 6)
    end)
end

-- Cria logo (imagem OU letra) dentro de um frame redondo
local function criarLogoConteudo(parent, tamanhoLetra, corLetra, zindex)
    local letra = Instance.new("TextLabel")
    letra.Size = UDim2.new(1, 0, 1, 0)
    letra.BackgroundTransparency = 1
    letra.Text = LOGO_LETRA
    letra.TextColor3 = corLetra
    letra.TextSize = tamanhoLetra
    letra.Font = Enum.Font.GothamBold
    letra.ZIndex = zindex
    letra.Parent = parent

    local img = nil
    if LOGO_IMAGEM then
        img = Instance.new("ImageLabel")
        img.Size = UDim2.new(1, 0, 1, 0)
        img.BackgroundTransparency = 1
        img.Image = LOGO_IMAGEM
        img.ScaleType = Enum.ScaleType.Crop
        img.ZIndex = zindex
        img.Parent = parent

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = img

        letra.Visible = false
    end
    return letra, img
end

-- ─────────────────────────────────────────────────────────
-- LIMPEZA
-- ─────────────────────────────────────────────────────────
for _, nome in ipairs({"RD4XLoading", "RD4XLauncher"}) do
    local antigo = playerGui:FindFirstChild(nome)
    if antigo then antigo:Destroy() end
end

-- ─────────────────────────────────────────────────────────
-- LINKS + DETECÇÃO DE JOGO
-- ─────────────────────────────────────────────────────────
local URL_BROOKHAVEN  = "loadstring(game:HttpGet("https://raw.githubusercontent.com/lhbzk/Loser/refs/heads/main/rd4x_hubScp.lua"))()"
local URL_PASS_EXPLODE= "https://raw.githubusercontent.com/lhbzk/rd4x-server/refs/heads/main/rd4x_bomb.lua"

local idJogo, nomeJogo = game.PlaceId, ""
pcall(function()
    local info = MarketplaceService:GetProductInfo(idJogo)
    if info and info.Name then nomeJogo = info.Name:lower() end
end)

local jogoDetectado = "Outros"
if nomeJogo:find("brookhaven") or idJogo == 4924922222 then
    jogoDetectado = "Brookhaven"
elseif nomeJogo:find("pass") or nomeJogo:find("explode")
    or nomeJogo:find("bomba") or nomeJogo:find("hot potato") then
    jogoDetectado = "Populares"
end

-- ═════════════════════════════════════════════════════════
-- 🎬 1. TELA DE LOADING
-- ═════════════════════════════════════════════════════════
local loadGui = Instance.new("ScreenGui")
loadGui.Name = "RD4XLoading"
loadGui.IgnoreGuiInset = true
loadGui.ResetOnSpawn = false
loadGui.DisplayOrder = 9999
loadGui.Parent = playerGui

-- 🎵 Música do carregamento (toca enquanto a tela estiver aberta)
local musicaLoad = nil
do
    local antiga = SoundService:FindFirstChild("RD4XMusica")
    if antiga then antiga:Destroy() end

    if MUSICA_ASSET then
        pcall(function()
            musicaLoad = Instance.new("Sound")
            musicaLoad.Name = "RD4XMusica"
            musicaLoad.SoundId = MUSICA_ASSET
            musicaLoad.Volume = 0
            musicaLoad.Looped = true
            musicaLoad.Parent = SoundService
            musicaLoad:Play()
            TweenService:Create(musicaLoad, TweenInfo.new(0.8), {Volume = MUSICA_VOLUME}):Play()
        end)
    end
end

local bgLoad = Instance.new("Frame")
bgLoad.Size = UDim2.new(1, 0, 1, 0)
bgLoad.BackgroundColor3 = COR_FUNDO
bgLoad.BackgroundTransparency = 1
bgLoad.BorderSizePixel = 0
bgLoad.Parent = loadGui

-- Bolhas de fundo
local bolhasLoad = Instance.new("Frame", bgLoad)
bolhasLoad.Size = UDim2.new(1, 0, 1, 0)
bolhasLoad.BackgroundTransparency = 1
bolhasLoad.ClipsDescendants = true

local loadingAtivo = true
task.spawn(function()
    while loadingAtivo do
        local b = Instance.new("Frame", bolhasLoad)
        local t = math.random(8, 20)
        local x = math.random()
        b.Size = UDim2.new(0, t, 0, t)
        b.Position = UDim2.new(x, 0, 1, 10)
        b.BackgroundColor3 = COR_AZUL
        b.BackgroundTransparency = math.random(30, 60) / 100
        b.BorderSizePixel = 0

        local c = Instance.new("UICorner", b)
        c.CornerRadius = UDim.new(1, 0)

        local st = Instance.new("UIStroke", b)
        st.Color = COR_AZUL
        st.Transparency = 0.5
        st.Thickness = 1

        local dur = math.random(4, 8)
        local tw = TweenService:Create(b, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
            Position = UDim2.new(x, 0, 0, -20),
            BackgroundTransparency = 1
        })
        tw:Play()
        tw.Completed:Connect(function() if b and b.Parent then b:Destroy() end end)
        task.wait(math.random(10, 30) / 100)
    end
end)

local containerLoad = Instance.new("Frame", bgLoad)
containerLoad.Size = UDim2.new(0, 420, 0, 240)
containerLoad.Position = UDim2.new(0.5, -210, 0.5, -120)
containerLoad.BackgroundTransparency = 1

-- Logo RD4X (círculo com imagem ou letra)
local logoFrame = Instance.new("Frame", containerLoad)
logoFrame.Size = UDim2.new(0, 70, 0, 70)
logoFrame.Position = UDim2.new(0.5, -35, 0, 0)
logoFrame.BackgroundColor3 = COR_CARD
logoFrame.BackgroundTransparency = 0.1
logoFrame.BorderSizePixel = 0
logoFrame.ZIndex = 2

local cLogo = Instance.new("UICorner", logoFrame)
cLogo.CornerRadius = UDim.new(1, 0)

local sLogo = Instance.new("UIStroke", logoFrame)
sLogo.Color = COR_AZUL
sLogo.Thickness = 2
sLogo.Transparency = 0.2

local logoText, logoImg = criarLogoConteudo(logoFrame, 36, COR_TEXTO, 3)

-- Título
local titleLoad = Instance.new("TextLabel", containerLoad)
titleLoad.Size = UDim2.new(1, 0, 0, 36)
titleLoad.Position = UDim2.new(0, 0, 0, 82)
titleLoad.BackgroundTransparency = 1
titleLoad.Text = "RD4X HUB"
titleLoad.TextColor3 = COR_TEXTO
titleLoad.TextSize = 22
titleLoad.Font = Enum.Font.GothamBold
titleLoad.TextTransparency = 1

local subTitleLoad = Instance.new("TextLabel", containerLoad)
subTitleLoad.Size = UDim2.new(1, 0, 0, 20)
subTitleLoad.Position = UDim2.new(0, 0, 0, 118)
subTitleLoad.BackgroundTransparency = 1
subTitleLoad.Text = "Iniciando sistemas"
subTitleLoad.TextColor3 = COR_TEXTO_CINZA
subTitleLoad.TextSize = 11
subTitleLoad.Font = Enum.Font.Gotham
subTitleLoad.TextTransparency = 1

-- Barra de progresso
local barBackground = Instance.new("Frame", containerLoad)
barBackground.Size = UDim2.new(0.85, 0, 0, 8)
barBackground.Position = UDim2.new(0.075, 0, 0, 155)
barBackground.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
barBackground.BackgroundTransparency = 1
barBackground.BorderSizePixel = 0

local bgCorner = Instance.new("UICorner", barBackground)
bgCorner.CornerRadius = UDim.new(1, 0)

local progressBar = Instance.new("Frame", barBackground)
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = COR_AZUL
progressBar.BorderSizePixel = 0

local barCorner = Instance.new("UICorner", progressBar)
barCorner.CornerRadius = UDim.new(1, 0)

local uiGradient = Instance.new("UIGradient", progressBar)
uiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 120, 220)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 170, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 210, 255))
})

local glow = Instance.new("UIStroke", barBackground)
glow.Transparency = 1
glow.Color = COR_AZUL
glow.Thickness = 2

-- Status (porcentagem)
local statusLoad = Instance.new("TextLabel", containerLoad)
statusLoad.Size = UDim2.new(1, 0, 0, 20)
statusLoad.Position = UDim2.new(0, 0, 0, 172)
statusLoad.BackgroundTransparency = 1
statusLoad.Text = "0%"
statusLoad.TextColor3 = COR_TEXTO_CINZA
statusLoad.TextSize = 11
statusLoad.Font = Enum.Font.GothamBold
statusLoad.TextTransparency = 1

-- Animação de entrada
local introTween = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenService:Create(bgLoad,        introTween, {BackgroundTransparency = 0.05}):Play()
TweenService:Create(titleLoad,     introTween, {TextTransparency = 0}):Play()
TweenService:Create(subTitleLoad,  introTween, {TextTransparency = 0}):Play()
TweenService:Create(statusLoad,    introTween, {TextTransparency = 0}):Play()
TweenService:Create(barBackground, introTween, {BackgroundTransparency = 0}):Play()
TweenService:Create(glow,          introTween, {Transparency = 0.4}):Play()

-- Pulso do logo
task.spawn(function()
    while loadingAtivo do
        TweenService:Create(sLogo, TweenInfo.new(1), {Transparency = 0.7, Thickness = 1}):Play()
        task.wait(1)
        TweenService:Create(sLogo, TweenInfo.new(1), {Transparency = 0.2, Thickness = 2}):Play()
        task.wait(1)
    end
end)

-- Progresso
task.spawn(function()
    local mensagens = {
        "Carregando módulos",
        "Sincronizando interface",
        "Verificando atualizações",
        "Preparando funções",
        "Tudo pronto!"
    }
    local passos = 100
    local duracao = 2.5
    task.wait(0.4)

    for i = 1, passos do
        progressBar.Size = UDim2.new(i / passos, 0, 1, 0)
        statusLoad.Text = i .. "%"
        local idx = math.clamp(math.floor(i / (passos / #mensagens)) + 1, 1, #mensagens)
        subTitleLoad.Text = mensagens[idx] .. "..."
        task.wait(duracao / passos)
    end

    subTitleLoad.Text = "✅ Pronto!"
    task.wait(0.4)

    -- Fade out
    local out = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(bgLoad,        out, {BackgroundTransparency = 1}):Play()
    TweenService:Create(titleLoad,     out, {TextTransparency = 1}):Play()
    TweenService:Create(subTitleLoad,  out, {TextTransparency = 1}):Play()
    TweenService:Create(statusLoad,    out, {TextTransparency = 1}):Play()
    TweenService:Create(barBackground, out, {BackgroundTransparency = 1}):Play()
    TweenService:Create(logoFrame,     out, {BackgroundTransparency = 1}):Play()
    TweenService:Create(logoText,      out, {TextTransparency = 1}):Play()
    if logoImg then
        TweenService:Create(logoImg,   out, {ImageTransparency = 1}):Play()
    end
    TweenService:Create(sLogo,         out, {Transparency = 1}):Play()
    TweenService:Create(glow,          out, {Transparency = 1}):Play()

    loadingAtivo = false

    -- Música some junto com a tela de carregamento
    if musicaLoad then
        local m = musicaLoad
        TweenService:Create(m, TweenInfo.new(0.45), {Volume = 0}):Play()
        task.delay(0.5, function()
            if m then m:Stop() m:Destroy() end
        end)
    end

    task.wait(0.45)
    loadGui:Destroy()

    -- ═════════════════════════════════════════════════════
    -- 🚀 2. LAUNCHER PRINCIPAL
    -- ═════════════════════════════════════════════════════
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RD4XLauncher"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 9998
    screenGui.Parent = playerGui

    local mainBackground = Instance.new("Frame", screenGui)
    mainBackground.Size = UDim2.new(1, 0, 1, 0)
    mainBackground.BackgroundColor3 = COR_FUNDO
    mainBackground.BackgroundTransparency = 1
    mainBackground.BorderSizePixel = 0

    local launcherAtivo = true

    -- Menu principal (meio transparente / meio escuro)
    local launcherFrame = Instance.new("Frame", mainBackground)
    launcherFrame.Size = UDim2.new(0, 540, 0, 400)
    launcherFrame.Position = UDim2.new(0.5, -270, 0.5, -200)
    launcherFrame.BackgroundColor3 = COR_FUNDO
    launcherFrame.BackgroundTransparency = 1
    launcherFrame.BorderSizePixel = 0
    launcherFrame.ClipsDescendants = true

    local frameCorner = Instance.new("UICorner", launcherFrame)
    frameCorner.CornerRadius = UDim.new(0, 14)

    local frameStroke = Instance.new("UIStroke", launcherFrame)
    frameStroke.Color = COR_BORDA
    frameStroke.Transparency = 1
    frameStroke.Thickness = 1.5

    -- 🫧 Camada de bolhas DENTRO do menu (criada primeiro = fica atrás do conteúdo)
    local bolhasMenu = Instance.new("Frame", launcherFrame)
    bolhasMenu.Name = "Bolhas"
    bolhasMenu.Size = UDim2.new(1, 0, 1, 0)
    bolhasMenu.BackgroundTransparency = 1
    bolhasMenu.ClipsDescendants = true
    bolhasMenu.ZIndex = 1

    if BOLHAS_NO_MENU then
        task.spawn(function()
            while launcherAtivo do
                local b = Instance.new("Frame", bolhasMenu)
                local t = math.random(6, 20)
                local x = math.random(3, 97) / 100
                local drift = math.random(-40, 40)
                b.Size = UDim2.new(0, t, 0, t)
                b.Position = UDim2.new(x, 0, 1, 10)
                b.BackgroundColor3 = COR_AZUL
                b.BackgroundTransparency = math.random(45, 75) / 100
                b.BorderSizePixel = 0
                b.ZIndex = 1

                local c = Instance.new("UICorner", b)
                c.CornerRadius = UDim.new(1, 0)

                local st = Instance.new("UIStroke", b)
                st.Color = Color3.fromRGB(150, 210, 255)
                st.Thickness = 1
                st.Transparency = 0.45

                local dur = math.random(4, 9)
                local info = TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                local tw = TweenService:Create(b, info, {
                    Position = UDim2.new(x, drift, 0, -30),
                    BackgroundTransparency = 1
                })
                TweenService:Create(st, info, {Transparency = 1}):Play()
                tw:Play()
                tw.Completed:Connect(function() if b and b.Parent then b:Destroy() end end)
                task.wait(math.random(12, 40) / 100)
            end
        end)
    end

    -- ───── HEADER ─────
    local header = Instance.new("Frame", launcherFrame)
    header.Size = UDim2.new(1, 0, 0, 55)
    header.BackgroundColor3 = COR_CARD
    header.BackgroundTransparency = 0.6
    header.BorderSizePixel = 0
    header.ZIndex = 2

    local headerIcone = Instance.new("Frame", header)
    headerIcone.Size = UDim2.new(0, 34, 0, 34)
    headerIcone.Position = UDim2.new(0, 15, 0.5, -17)
    headerIcone.BackgroundColor3 = COR_AZUL_ESCURO
    headerIcone.BorderSizePixel = 0
    headerIcone.ZIndex = 3

    local cHI = Instance.new("UICorner", headerIcone)
    cHI.CornerRadius = UDim.new(1, 0)

    if LOGO_NO_MENU and LOGO_IMAGEM then
        criarLogoConteudo(headerIcone, 18, COR_AZUL, 4)
    else
        local hIText = Instance.new("TextLabel", headerIcone)
        hIText.Size = UDim2.new(1, 0, 1, 0)
        hIText.BackgroundTransparency = 1
        hIText.Text = LOGO_LETRA
        hIText.TextColor3 = COR_AZUL
        hIText.TextSize = 18
        hIText.Font = Enum.Font.GothamBold
        hIText.ZIndex = 4
    end

    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = UDim2.new(1, -120, 0, 22)
    titleLabel.Position = UDim2.new(0, 60, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "RD4X LAUNCHER"
    titleLabel.TextColor3 = COR_TEXTO
    titleLabel.TextSize = 15
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTransparency = 1
    titleLabel.ZIndex = 3

    local subTitle = Instance.new("TextLabel", header)
    subTitle.Size = UDim2.new(1, -120, 0, 14)
    subTitle.Position = UDim2.new(0, 60, 0, 30)
    subTitle.BackgroundTransparency = 1
    subTitle.Text = "Selecione um script para iniciar"
    subTitle.TextColor3 = COR_TEXTO_CINZA
    subTitle.TextSize = 10
    subTitle.Font = Enum.Font.Gotham
    subTitle.TextXAlignment = Enum.TextXAlignment.Left
    subTitle.TextTransparency = 1
    subTitle.ZIndex = 3

    -- Botão fechar
    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -38, 0.5, -14)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = COR_TEXTO_CINZA
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 3

    closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = Color3.fromRGB(231, 76, 60) end)
    closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = COR_TEXTO_CINZA end)

    -- ───── SISTEMA DE ABAS ─────
    local abaBar = Instance.new("Frame", launcherFrame)
    abaBar.Size = UDim2.new(1, -30, 0, 40)
    abaBar.Position = UDim2.new(0, 15, 0, 65)
    abaBar.BackgroundColor3 = COR_CARD
    abaBar.BackgroundTransparency = 0.6
    abaBar.BorderSizePixel = 0
    abaBar.ZIndex = 2

    local abaBarCorner = Instance.new("UICorner", abaBar)
    abaBarCorner.CornerRadius = UDim.new(0, 10)

    local abaPadding = Instance.new("UIPadding", abaBar)
    abaPadding.PaddingTop = UDim.new(0, 4)
    abaPadding.PaddingBottom = UDim.new(0, 4)
    abaPadding.PaddingLeft = UDim.new(0, 4)
    abaPadding.PaddingRight = UDim.new(0, 4)

    local abaLayout = Instance.new("UIListLayout", abaBar)
    abaLayout.FillDirection = Enum.FillDirection.Horizontal
    abaLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    abaLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    abaLayout.SortOrder = Enum.SortOrder.LayoutOrder
    abaLayout.Padding = UDim.new(0, 4)

    local contentContainer = Instance.new("Frame", launcherFrame)
    contentContainer.Size = UDim2.new(1, -30, 1, -190)
    contentContainer.Position = UDim2.new(0, 15, 0, 115)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ZIndex = 2

    local abasPaineis, botoesAba = {}, {}
    local COR_BOTAO_PADRAO   = Color3.fromRGB(24, 30, 48)
    local COR_BOTAO_DESTAQUE = COR_AZUL_ESCURO

    local function criarAba(nomeAba, ordem)
        local btnAba = Instance.new("TextButton", abaBar)
        btnAba.Size = UDim2.new(0.24, 0, 1, 0)
        btnAba.BackgroundColor3 = COR_BOTAO_PADRAO
        btnAba.BackgroundTransparency = 0.5
        btnAba.Text = nomeAba
        btnAba.TextColor3 = COR_TEXTO_CINZA
        btnAba.TextSize = 11
        btnAba.Font = Enum.Font.GothamSemibold
        btnAba.AutoButtonColor = false
        btnAba.LayoutOrder = ordem
        btnAba.ZIndex = 3

        local cBtn = Instance.new("UICorner", btnAba)
        cBtn.CornerRadius = UDim.new(0, 8)

        local painel = Instance.new("ScrollingFrame", contentContainer)
        painel.Size = UDim2.new(1, 0, 1, 0)
        painel.BackgroundTransparency = 1
        painel.BorderSizePixel = 0
        painel.Visible = false
        painel.CanvasSize = UDim2.new(0, 0, 0, 0)
        painel.AutomaticCanvasSize = Enum.AutomaticSize.Y
        painel.ScrollBarThickness = 3
        painel.ScrollBarImageColor3 = COR_AZUL
        painel.ZIndex = 2

        local pLayout = Instance.new("UIListLayout", painel)
        pLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        pLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pLayout.Padding = UDim.new(0, 8)

        abasPaineis[nomeAba] = painel
        botoesAba[nomeAba] = btnAba

        btnAba.MouseButton1Click:Connect(function()
            tocarToque()
            for _, p in pairs(abasPaineis) do p.Visible = false end
            for _, b in pairs(botoesAba) do
                b.TextColor3 = COR_TEXTO_CINZA
                TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = COR_BOTAO_PADRAO}):Play()
            end
            painel.Visible = true
            btnAba.TextColor3 = Color3.fromRGB(255, 255, 255)
            TweenService:Create(btnAba, TweenInfo.new(0.2), {BackgroundColor3 = COR_BOTAO_DESTAQUE}):Play()
        end)

        return painel
    end

    local abaBrookhaven = criarAba("Brookhaven", 1)
    local abaUniversal  = criarAba("Universal", 2)
    local abaPopulares  = criarAba("Populares", 3)
    local abaOutros     = criarAba("Outros", 4)

    -- Função pra adicionar botões com ícone
    local function adicionarBotao(painelAba, icone, texto, corBorda, callback)
        local btn = Instance.new("TextButton", painelAba)
        btn.Size = UDim2.new(1, -10, 0, 48)
        btn.BackgroundColor3 = COR_CARD
        btn.BackgroundTransparency = 0.45
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.ZIndex = 3

        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 10)

        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = corBorda or COR_AZUL
        stroke.Thickness = 1.2
        stroke.Transparency = 0.5

        -- Ícone
        local iconeLbl = Instance.new("TextLabel", btn)
        iconeLbl.Size = UDim2.new(0, 34, 0, 34)
        iconeLbl.Position = UDim2.new(0, 8, 0.5, -17)
        iconeLbl.BackgroundColor3 = COR_BOTAO_PADRAO
        iconeLbl.BackgroundTransparency = 0.4
        iconeLbl.Text = icone
        iconeLbl.TextColor3 = COR_TEXTO
        iconeLbl.TextSize = 16
        iconeLbl.Font = Enum.Font.GothamBold
        iconeLbl.ZIndex = 4

        local cI = Instance.new("UICorner", iconeLbl)
        cI.CornerRadius = UDim.new(1, 0)

        -- Texto
        local txt = Instance.new("TextLabel", btn)
        txt.Size = UDim2.new(1, -70, 1, 0)
        txt.Position = UDim2.new(0, 55, 0, 0)
        txt.BackgroundTransparency = 1
        txt.Text = texto
        txt.TextColor3 = COR_TEXTO
        txt.TextSize = 12
        txt.Font = Enum.Font.GothamSemibold
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.ZIndex = 4

        -- Seta
        local seta = Instance.new("TextLabel", btn)
        seta.Size = UDim2.new(0, 20, 1, 0)
        seta.Position = UDim2.new(1, -30, 0, 0)
        seta.BackgroundTransparency = 1
        seta.Text = "›"
        seta.TextColor3 = COR_TEXTO_CINZA
        seta.TextSize = 18
        seta.Font = Enum.Font.GothamBold
        seta.ZIndex = 4

        -- Hover
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.25}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0, Thickness = 1.8}):Play()
            TweenService:Create(seta, TweenInfo.new(0.2), {TextColor3 = COR_AZUL, TextSize = 22}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.45}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.5, Thickness = 1.2}):Play()
            TweenService:Create(seta, TweenInfo.new(0.2), {TextColor3 = COR_TEXTO_CINZA, TextSize = 18}):Play()
        end)

        btn.MouseButton1Click:Connect(function()
            tocarToque()
            -- Animação de saída
            local out = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(mainBackground, out, {BackgroundTransparency = 1}):Play()
            TweenService:Create(launcherFrame,  out, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
            task.wait(0.25)
            launcherAtivo = false
            screenGui:Destroy()
            if callback then callback() end
        end)
    end

    -- Botões
    adicionarBotao(abaBrookhaven, "🏠", "Carregar RD4X Hub (Brookhaven)", COR_AZUL, function()
        pcall(function() loadstring(game:HttpGet(URL_BROOKHAVEN))() end)
    end)

    adicionarBotao(abaPopulares, "💣", "Pass or Explode Hub", COR_AZUL, function()
        pcall(function() loadstring(game:HttpGet(URL_PASS_EXPLODE))() end)
    end)

    -- Abre aba auto-detectada
    local abaAuto = abaBrookhaven
    if jogoDetectado == "Populares" then abaAuto = abaPopulares
    elseif jogoDetectado == "Outros" then abaAuto = abaUniversal end

    task.spawn(function()
        task.wait(0.15)
        for _, p in pairs(abasPaineis) do p.Visible = false end
        for _, b in pairs(botoesAba) do
            b.TextColor3 = COR_TEXTO_CINZA
            b.BackgroundColor3 = COR_BOTAO_PADRAO
        end
        for nome, painel in pairs(abasPaineis) do
            if painel == abaAuto then
                painel.Visible = true
                local btn = botoesAba[nome]
                if btn then
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.BackgroundColor3 = COR_BOTAO_DESTAQUE
                end
            end
        end
    end)

    -- Fechar
    closeBtn.MouseButton1Click:Connect(function()
        tocarToque()
        launcherAtivo = false
        local out = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(mainBackground, out, {BackgroundTransparency = 1}):Play()
        TweenService:Create(launcherFrame,  out, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        task.wait(0.3)
        screenGui:Destroy()
    end)

    -- Animação de entrada do launcher
    local intro2 = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    launcherFrame.Size = UDim2.new(0, 0, 0, 0)
    launcherFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

    TweenService:Create(mainBackground, intro2, {BackgroundTransparency = 0.5}):Play()
    TweenService:Create(launcherFrame, intro2, {
        BackgroundTransparency = MENU_TRANSPARENCIA,
        Size = UDim2.new(0, 540, 0, 400),
        Position = UDim2.new(0.5, -270, 0.5, -200)
    }):Play()
    TweenService:Create(frameStroke, intro2, {Transparency = 0.2}):Play()
    TweenService:Create(titleLabel, intro2, {TextTransparency = 0}):Play()
    TweenService:Create(subTitle,    intro2, {TextTransparency = 0}):Play()
end)
