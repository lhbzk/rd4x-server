-- ==========================================================
-- 🚀 RD4X LAUNCHER - Premium Interface (v4.3 FINAL)
-- ==========================================================

-- ╔════════════════════════════════════════════════════════╗
-- ║  ⚙️ CONFIGURAÇÃO RÁPIDA                                ║
-- ╚════════════════════════════════════════════════════════╝
local LOGO_IMAGE_ID      = "109276734890323"     
local LOGO_LETRA         = "R"    
local LOGO_NO_MENU       = true   
local MENU_TRANSPARENCIA = 0.25   

-- 🎵 ÁUDIO
local MUSICA_ID          = "116105996777798"  
local MUSICA_VOLUME      = 0.5                
local TOQUE_ID           = "84960553590734"   
local TOQUE_VOLUME       = 0.5                

-- 🖼️ ÍCONES DOS BOTÕES
local ICONE_HOME = "rbxthumb://type=Asset&id=10709790875&w=150&h=150" 
local ICONE_BOMB = "rbxthumb://type=Asset&id=10709793092&w=150&h=150" 
local ICONE_CLOSE = "rbxthumb://type=Asset&id=96089977023576&w=150&h=150" 

local Players             = game:GetService("Players")
local TweenService        = game:GetService("TweenService")
local MarketplaceService  = game:GetService("MarketplaceService")
local SoundService        = game:GetService("SoundService")
local Lighting            = game:GetService("Lighting")

local player     = Players.LocalPlayer
local playerGui  = player:WaitForChild("PlayerGui")

-- ─────────────────────────────────────────────────────────
-- PALETA IDÊNTICA AO HUB PRINCIPAL
-- ─────────────────────────────────────────────────────────
local COR_FUNDO      = Color3.fromRGB(18, 18, 22)   
local COR_CARD       = Color3.fromRGB(28, 28, 34)   
local COR_BORDA      = Color3.fromRGB(40, 40, 48)   
local COR_TEXTO      = Color3.fromRGB(240, 240, 245) 
local COR_TEXTO_CINZA= Color3.fromRGB(140, 140, 150) 
local COR_NEON       = Color3.fromRGB(220, 20, 60)  
local COR_NEON_ESCURO= Color3.fromRGB(120, 10, 30)  
local COR_VERMELHO   = Color3.fromRGB(255, 60, 60)  

-- ─────────────────────────────────────────────────────────
-- HELPERS (CORRIGIDOS)
-- ─────────────────────────────────────────────────────────
-- Para Imagens
local function normalizarImagem(id)
    if id == nil then return nil end
    id = tostring(id):gsub("%s+", "")
    if id == "" then return nil end
    if id:find("rbxassetid://") or id:find("rbxthumb://") or id:find("http") then return id end
    local num = id:match("%d+")
    if num then return "rbxthumb://type=Asset&id=" .. num .. "&w=150&h=150" end
    return nil
end

-- Para Áudios
local function normalizarSom(id)
    if id == nil then return nil end
    id = tostring(id):gsub("%s+", "")
    if id == "" then return nil end
    if id:find("rbxassetid://") then return id end
    local num = id:match("%d+")
    if num then return "rbxassetid://" .. num end
    return nil
end

local LOGO_IMAGEM = normalizarImagem(LOGO_IMAGE_ID)
local MUSICA_ASSET = normalizarSom(MUSICA_ID)
local TOQUE_ASSET  = normalizarSom(TOQUE_ID)

local function tocarToque()
    if not TOQUE_ASSET then return end
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = TOQUE_ASSET
        s.Volume = TOQUE_VOLUME
        s.Parent = SoundService
        s:Play()
        game:GetService("Debris"):AddItem(s, 2)
    end)
end

local function criarLogoConteudo(parent, tamanhoLetra, corLetra, zindex)
    local letra = Instance.new("TextLabel")
    letra.Size = UDim2.new(1, 0, 1, 0)
    letra.BackgroundTransparency = 1
    letra.Text = LOGO_LETRA
    letra.TextColor3 = corLetra
    letra.TextSize = tamanhoLetra
    letra.Font = Enum.Font.GothamBlack
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
        Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)
        letra.Visible = false
    end
    return letra, img
end

-- ─────────────────────────────────────────────────────────
-- LIMPEZA E EFEITOS GLOBAIS
-- ─────────────────────────────────────────────────────────
for _, nome in ipairs({"RD4XLoading", "RD4XLauncher"}) do
    local antigo = playerGui:FindFirstChild(nome)
    if antigo then antigo:Destroy() end
end

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

-- ─────────────────────────────────────────────────────────
-- LINKS + DETECÇÃO
-- ─────────────────────────────────────────────────────────
local URL_BROOKHAVEN  = "https://raw.githubusercontent.com/lhbzk/Loser/refs/heads/main/rd4x_hubScp.lua"
local URL_PASS_EXPLODE= "https://raw.githubusercontent.com/lhbzk/rd4x-server/refs/heads/main/rd4x_bomb.lua"

local idJogo, nomeJogo = game.PlaceId, ""
pcall(function()
    local info = MarketplaceService:GetProductInfo(idJogo)
    if info and info.Name then nomeJogo = info.Name:lower() end
end)

local jogoDetectado = "Outros"
if nomeJogo:find("brookhaven") or idJogo == 4924922222 then
    jogoDetectado = "Brookhaven"
elseif nomeJogo:find("pass") or nomeJogo:find("explode") or nomeJogo:find("bomba") then
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

local bgLoad = Instance.new("Frame", loadGui)
bgLoad.Size = UDim2.new(1, 0, 1, 0)
bgLoad.BackgroundColor3 = COR_FUNDO
bgLoad.BorderSizePixel = 0

local musicaLoad = nil
if MUSICA_ASSET then
    musicaLoad = Instance.new("Sound", SoundService)
    musicaLoad.SoundId = MUSICA_ASSET
    musicaLoad.Volume = 0
    musicaLoad.Looped = true
    musicaLoad:Play()
    TweenService:Create(musicaLoad, TweenInfo.new(1), {Volume = MUSICA_VOLUME}):Play()
end

local bolhasLoad = Instance.new("Frame", bgLoad)
bolhasLoad.Size = UDim2.new(1, 0, 1, 0)
bolhasLoad.BackgroundTransparency = 1
bolhasLoad.ClipsDescendants = true

local loadingAtivo = true
task.spawn(function()
    while loadingAtivo do
        local b = Instance.new("Frame", bolhasLoad)
        local t = math.random(4, 12)
        b.Size = UDim2.new(0, t, 0, t)
        b.Position = UDim2.new(math.random(), 0, 1, 10)
        b.BackgroundColor3 = COR_NEON
        b.BackgroundTransparency = math.random(60, 90) / 100
        b.BorderSizePixel = 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
        
        local tw = TweenService:Create(b, TweenInfo.new(math.random(4, 8), Enum.EasingStyle.Linear), {
            Position = UDim2.new(b.Position.X.Scale, 0, 0, -20),
            BackgroundTransparency = 1
        })
        tw:Play()
        tw.Completed:Connect(function() if b then b:Destroy() end end)
        task.wait(math.random(5, 20) / 100)
    end
end)

local containerLoad = Instance.new("Frame", bgLoad)
containerLoad.Size = UDim2.new(0, 400, 0, 200)
containerLoad.Position = UDim2.new(0.5, -200, 0.5, -100)
containerLoad.BackgroundTransparency = 1

local glowLogo = Instance.new("ImageLabel", containerLoad)
glowLogo.Size = UDim2.new(0, 160, 0, 160)
glowLogo.Position = UDim2.new(0.5, -80, 0, -40)
glowLogo.BackgroundTransparency = 1
glowLogo.Image = "rbxassetid://1316045217" 
glowLogo.ImageColor3 = COR_NEON
glowLogo.ImageTransparency = 0.5
glowLogo.ZIndex = 1

local logoFrame = Instance.new("Frame", containerLoad)
logoFrame.Size = UDim2.new(0, 70, 0, 70)
logoFrame.Position = UDim2.new(0.5, -35, 0, 0)
logoFrame.BackgroundColor3 = COR_CARD
logoFrame.BackgroundTransparency = 0.1
logoFrame.BorderSizePixel = 0
logoFrame.ZIndex = 2
Instance.new("UICorner", logoFrame).CornerRadius = UDim.new(1, 0)

-- 🔥 CORRIGIDO AQUI (sLogo em vez de s)
local sLogo = Instance.new("UIStroke", logoFrame)
sLogo.Color = COR_NEON
sLogo.Thickness = 2
sLogo.Transparency = 0.2

criarLogoConteudo(logoFrame, 36, COR_TEXTO, 3)

local titleLoad = Instance.new("TextLabel", containerLoad)
titleLoad.Size = UDim2.new(1, 0, 0, 36)
titleLoad.Position = UDim2.new(0, 0, 0, 85)
titleLoad.BackgroundTransparency = 1
titleLoad.Text = "RD4X LAUNCHER"
titleLoad.TextColor3 = COR_TEXTO
titleLoad.TextSize = 24
titleLoad.Font = Enum.Font.GothamBlack
titleLoad.TextTransparency = 1
titleLoad.ZIndex = 3

local subTitleLoad = Instance.new("TextLabel", containerLoad)
subTitleLoad.Size = UDim2.new(1, 0, 0, 20)
subTitleLoad.Position = UDim2.new(0, 0, 0, 120)
subTitleLoad.BackgroundTransparency = 1
subTitleLoad.Text = "Iniciando sistemas"
subTitleLoad.TextColor3 = COR_TEXTO_CINZA
subTitleLoad.TextSize = 11
subTitleLoad.Font = Enum.Font.GothamSemibold
subTitleLoad.TextTransparency = 1
subTitleLoad.ZIndex = 3

local barBackground = Instance.new("Frame", containerLoad)
barBackground.Size = UDim2.new(0.85, 0, 0, 4)
barBackground.Position = UDim2.new(0.075, 0, 0, 160)
barBackground.BackgroundColor3 = COR_BORDA
barBackground.BackgroundTransparency = 1
barBackground.BorderSizePixel = 0
Instance.new("UICorner", barBackground).CornerRadius = UDim.new(1, 0)

local progressBar = Instance.new("Frame", barBackground)
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = COR_NEON
progressBar.BorderSizePixel = 0
Instance.new("UICorner", progressBar).CornerRadius = UDim.new(1, 0)

local uiGradient = Instance.new("UIGradient", progressBar)
uiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, COR_NEON_ESCURO),
    ColorSequenceKeypoint.new(0.5, COR_NEON),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 100))
})

local statusLoad = Instance.new("TextLabel", containerLoad)
statusLoad.Size = UDim2.new(1, 0, 0, 20)
statusLoad.Position = UDim2.new(0, 0, 0, 175)
statusLoad.BackgroundTransparency = 1
statusLoad.Text = "0%"
statusLoad.TextColor3 = COR_NEON
statusLoad.TextSize = 11
statusLoad.Font = Enum.Font.GothamBold
statusLoad.TextTransparency = 1
statusLoad.ZIndex = 3

local introTween = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenService:Create(titleLoad,     introTween, {TextTransparency = 0}):Play()
TweenService:Create(subTitleLoad,  introTween, {TextTransparency = 0}):Play()
TweenService:Create(statusLoad,    introTween, {TextTransparency = 0}):Play()
TweenService:Create(barBackground, introTween, {BackgroundTransparency = 0}):Play()

task.spawn(function()
    while loadingAtivo do
        TweenService:Create(glowLogo, TweenInfo.new(1.2), {ImageTransparency = 0.2, Size = UDim2.new(0, 170, 0, 170), Position = UDim2.new(0.5, -85, 0, -45)}):Play()
        task.wait(1.2)
        TweenService:Create(glowLogo, TweenInfo.new(1.2), {ImageTransparency = 0.6, Size = UDim2.new(0, 160, 0, 160), Position = UDim2.new(0.5, -80, 0, -40)}):Play()
        task.wait(1.2)
    end
end)

task.spawn(function()
    local passos = 100
    local duracao = 3
    task.wait(0.3)
    for i = 1, passos do
        progressBar.Size = UDim2.new(i / passos, 0, 1, 0)
        statusLoad.Text = i .. "%"
        if i == 30 then subTitleLoad.Text = "Carregando módulos..."
        elseif i == 60 then subTitleLoad.Text = "Sincronizando..."
        elseif i == 90 then subTitleLoad.Text = "Quase pronto..."
        end
        task.wait(duracao / passos)
    end

    subTitleLoad.Text = "✅ Pronto!"
    task.wait(0.5)

    local out = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(bgLoad,        out, {BackgroundTransparency = 1}):Play()
    TweenService:Create(titleLoad,     out, {TextTransparency = 1}):Play()
    TweenService:Create(subTitleLoad,  out, {TextTransparency = 1}):Play()
    TweenService:Create(statusLoad,    out, {TextTransparency = 1}):Play()
    TweenService:Create(barBackground, out, {BackgroundTransparency = 1}):Play()
    TweenService:Create(logoFrame,     out, {BackgroundTransparency = 1}):Play()
    TweenService:Create(sLogo,         out, {Transparency = 1}):Play()
    TweenService:Create(glowLogo,      out, {ImageTransparency = 1}):Play()

    loadingAtivo = false
    if musicaLoad then
        TweenService:Create(musicaLoad, TweenInfo.new(0.5), {Volume = 0}):Play()
        task.delay(0.5, function() musicaLoad:Destroy() end)
    end

    task.wait(0.5)
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

    local launcherAtivo = true

    local mainBackground = Instance.new("Frame", screenGui)
    mainBackground.Size = UDim2.new(1, 0, 1, 0)
    mainBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainBackground.BackgroundTransparency = 0.5
    mainBackground.BorderSizePixel = 0

    TweenService:Create(blur, TweenInfo.new(0.6), {Size = 20}):Play()

    local launcherFrame = Instance.new("Frame", mainBackground)
    launcherFrame.Size = UDim2.new(0, 520, 0, 380)
    launcherFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
    launcherFrame.BackgroundColor3 = COR_FUNDO
    launcherFrame.BackgroundTransparency = 1
    launcherFrame.BorderSizePixel = 0
    launcherFrame.ClipsDescendants = true
    Instance.new("UICorner", launcherFrame).CornerRadius = UDim.new(0, 14)

    local frameStroke = Instance.new("UIStroke", launcherFrame)
    frameStroke.Color = COR_BORDA
    frameStroke.Thickness = 1.5
    frameStroke.Transparency = 1

    local bolhasMenu = Instance.new("Frame", launcherFrame)
    bolhasMenu.Size = UDim2.new(1, 0, 1, 0)
    bolhasMenu.BackgroundTransparency = 1
    bolhasMenu.ClipsDescendants = true
    bolhasMenu.ZIndex = 1

    task.spawn(function()
        while launcherAtivo do
            local b = Instance.new("Frame", bolhasMenu)
            local t = math.random(5, 15)
            local x = math.random(5, 95) / 100
            b.Size = UDim2.new(0, t, 0, t)
            b.Position = UDim2.new(x, 0, 1, 10)
            b.BackgroundColor3 = COR_NEON
            b.BackgroundTransparency = math.random(70, 90) / 100
            b.BorderSizePixel = 0
            Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

            local tw = TweenService:Create(b, TweenInfo.new(math.random(4, 8), Enum.EasingStyle.Linear), {
                Position = UDim2.new(x, math.random(-30, 30), 0, -20),
                BackgroundTransparency = 1
            })
            tw:Play()
            tw.Completed:Connect(function() if b then b:Destroy() end)
            task.wait(math.random(15, 40) / 100)
        end
    end)

    -- ───── HEADER ─────
    local header = Instance.new("Frame", launcherFrame)
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundTransparency = 1
    header.ZIndex = 2

    local headerIcone = Instance.new("Frame", header)
    headerIcone.Size = UDim2.new(0, 36, 0, 36)
    headerIcone.Position = UDim2.new(0, 15, 0.5, -18)
    headerIcone.BackgroundColor3 = COR_CARD
    headerIcone.BorderSizePixel = 0
    headerIcone.ZIndex = 3
    Instance.new("UICorner", headerIcone).CornerRadius = UDim.new(1, 0)
    
    local strokeIcone = Instance.new("UIStroke", headerIcone)
    strokeIcone.Color = COR_NEON
    strokeIcone.Thickness = 1.5
    
    criarLogoConteudo(headerIcone, 18, COR_NEON, 4)

    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = UDim2.new(1, -120, 0, 22)
    titleLabel.Position = UDim2.new(0, 62, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "RD4X LAUNCHER"
    titleLabel.TextColor3 = COR_TEXTO
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTransparency = 1
    titleLabel.ZIndex = 3

    local subTitle = Instance.new("TextLabel", header)
    subTitle.Size = UDim2.new(1, -120, 0, 14)
    subTitle.Position = UDim2.new(0, 62, 0, 32)
    subTitle.BackgroundTransparency = 1
    subTitle.Text = "Selecione um script para iniciar"
    subTitle.TextColor3 = COR_TEXTO_CINZA
    subTitle.TextSize = 11
    subTitle.Font = Enum.Font.GothamMedium
    subTitle.TextXAlignment = Enum.TextXAlignment.Left
    subTitle.TextTransparency = 1
    subTitle.ZIndex = 3

    local closeBtn = Instance.new("ImageButton", header)
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -10)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = ICONE_CLOSE
    closeBtn.ImageColor3 = COR_TEXTO_CINZA
    closeBtn.ZIndex = 3
    closeBtn.AutoButtonColor = false

    closeBtn.MouseEnter:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.15), {ImageColor3 = COR_VERMELHO}):Play() end)
    closeBtn.MouseLeave:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.15), {ImageColor3 = COR_TEXTO_CINZA}):Play() end)

    local headerLine = Instance.new("Frame", launcherFrame)
    headerLine.Size = UDim2.new(1, -30, 0, 1)
    headerLine.Position = UDim2.new(0, 15, 0, 60)
    headerLine.BackgroundColor3 = COR_BORDA
    headerLine.BorderSizePixel = 0
    headerLine.ZIndex = 2

    -- ───── SISTEMA DE ABAS ─────
    local abaBar = Instance.new("Frame", launcherFrame)
    abaBar.Size = UDim2.new(1, -30, 0, 42)
    abaBar.Position = UDim2.new(0, 15, 0, 75)
    abaBar.BackgroundColor3 = COR_CARD 
    abaBar.BackgroundTransparency = 0.3
    abaBar.BorderSizePixel = 0
    abaBar.ZIndex = 2
    Instance.new("UICorner", abaBar).CornerRadius = UDim.new(0, 8)

    local abaLayout = Instance.new("UIListLayout", abaBar)
    abaLayout.FillDirection = Enum.FillDirection.Horizontal
    abaLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    abaLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    abaLayout.SortOrder = Enum.SortOrder.LayoutOrder
    abaLayout.Padding = UDim.new(0, 5)

    local contentContainer = Instance.new("Frame", launcherFrame)
    contentContainer.Size = UDim2.new(1, -30, 1, -140)
    contentContainer.Position = UDim2.new(0, 15, 0, 125)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ZIndex = 2

    local abasPaineis, botoesAba = {}, {}
    local COR_BTN_INATIVO = COR_FUNDO
    local COR_BTN_ATIVO   = COR_NEON_ESCURO

    local function criarAba(nomeAba, ordem)
        local btnAba = Instance.new("TextButton", abaBar)
        btnAba.Size = UDim2.new(0.23, 0, 1, -10)
        btnAba.BackgroundColor3 = COR_BTN_INATIVO
        btnAba.BackgroundTransparency = 0.5
        btnAba.Text = nomeAba
        btnAba.TextColor3 = COR_TEXTO_CINZA
        btnAba.TextSize = 11
        btnAba.Font = Enum.Font.GothamBold
        btnAba.AutoButtonColor = false
        btnAba.LayoutOrder = ordem
        btnAba.ZIndex = 3
        Instance.new("UICorner", btnAba).CornerRadius = UDim.new(0, 6)

        local bordaAba = Instance.new("UIStroke", btnAba)
        bordaAba.Color = COR_NEON
        bordaAba.Thickness = 1
        bordaAba.Transparency = 1

        local painel = Instance.new("ScrollingFrame", contentContainer)
        painel.Size = UDim2.new(1, 0, 1, 0)
        painel.BackgroundTransparency = 1
        painel.BorderSizePixel = 0
        painel.Visible = false
        painel.CanvasSize = UDim2.new(0, 0, 0, 0)
        painel.AutomaticCanvasSize = Enum.AutomaticSize.Y
        painel.ScrollBarThickness = 2
        painel.ScrollBarImageColor3 = COR_NEON
        painel.ZIndex = 2

        local pLayout = Instance.new("UIListLayout", painel)
        pLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        pLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pLayout.Padding = UDim.new(0, 8)

        abasPaineis[nomeAba] = painel
        botoesAba[nomeAba] = {btn = btnAba, stroke = bordaAba}

        btnAba.MouseButton1Click:Connect(function()
            tocarToque()
            for _, p in pairs(abasPaineis) do p.Visible = false end
            for _, b in pairs(botoesAba) do
                TweenService:Create(b.btn, TweenInfo.new(0.2), {TextColor3 = COR_TEXTO_CINZA, BackgroundColor3 = COR_BTN_INATIVO, BackgroundTransparency = 0.5}):Play()
                TweenService:Create(b.stroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
            end
            painel.Visible = true
            TweenService:Create(btnAba, TweenInfo.new(0.2), {TextColor3 = COR_TEXTO, BackgroundColor3 = COR_BTN_ATIVO, BackgroundTransparency = 0.2}):Play()
            TweenService:Create(bordaAba, TweenInfo.new(0.2), {Transparency = 0}):Play()
        end)

        return painel
    end

    local abaBrookhaven = criarAba("Brookhaven", 1)
    local abaUniversal  = criarAba("Universal", 2)
    local abaPopulares  = criarAba("Populares", 3)
    local abaOutros     = criarAba("Outros", 4)

    -- ───── BOTÕES DE SCRIPT ─────
    local function adicionarBotao(painelAba, iconeId, texto, corBorda, callback)
        local btn = Instance.new("TextButton", painelAba)
        btn.Size = UDim2.new(1, -10, 0, 48)
        btn.BackgroundColor3 = COR_CARD
        btn.BackgroundTransparency = 0.2
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.ZIndex = 3
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local uiScale = Instance.new("UIScale", btn)
        uiScale.Scale = 1

        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = corBorda or COR_NEON
        stroke.Thickness = 1
        stroke.Transparency = 0.7

        local iconeLbl = Instance.new("ImageLabel", btn)
        iconeLbl.Size = UDim2.new(0, 30, 0, 30)
        iconeLbl.Position = UDim2.new(0, 8, 0.5, -15)
        iconeLbl.BackgroundColor3 = COR_FUNDO
        iconeLbl.BackgroundTransparency = 0.4
        iconeLbl.Image = iconeId
        iconeLbl.ImageColor3 = COR_TEXTO
        iconeLbl.ZIndex = 4
        Instance.new("UICorner", iconeLbl).CornerRadius = UDim.new(1, 0)

        local txt = Instance.new("TextLabel", btn)
        txt.Size = UDim2.new(1, -70, 1, 0)
        txt.Position = UDim2.new(0, 48, 0, 0)
        txt.BackgroundTransparency = 1
        txt.Text = texto
        txt.TextColor3 = COR_TEXTO
        txt.TextSize = 12
        txt.Font = Enum.Font.GothamBold
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.ZIndex = 4

        local seta = Instance.new("TextLabel", btn)
        seta.Size = UDim2.new(0, 20, 1, 0)
        seta.Position = UDim2.new(1, -30, 0, 0)
        seta.BackgroundTransparency = 1
        seta.Text = "›"
        seta.TextColor3 = COR_TEXTO_CINZA
        seta.TextSize = 20
        seta.Font = Enum.Font.GothamBold
        seta.ZIndex = 4

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COR_BTN_ATIVO, BackgroundTransparency = 0.1}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
            TweenService:Create(seta, TweenInfo.new(0.2), {TextColor3 = COR_NEON, Position = UDim2.new(1, -25, 0, 0)}):Play()
            TweenService:Create(uiScale, TweenInfo.new(0.2), {Scale = 1.03}):Play() 
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COR_CARD, BackgroundTransparency = 0.2}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.7}):Play()
            TweenService:Create(seta, TweenInfo.new(0.2), {TextColor3 = COR_TEXTO_CINZA, Position = UDim2.new(1, -30, 0, 0)}):Play()
            TweenService:Create(uiScale, TweenInfo.new(0.2), {Scale = 1}):Play() 
        end)

        btn.MouseButton1Click:Connect(function()
            tocarToque()
            local out = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(mainBackground, out, {BackgroundTransparency = 1}):Play()
            TweenService:Create(launcherFrame,  out, {BackgroundTransparency = 1, Size = UDim2.new(0, 400, 0, 200), Position = UDim2.new(0.5, -200, 0.5, -100)}):Play()
            TweenService:Create(blur, out, {Size = 0}):Play()
            task.wait(0.25)
            launcherAtivo = false
            screenGui:Destroy()
            if callback then callback() end
        end)
    end

    adicionarBotao(abaBrookhaven, ICONE_HOME, "Carregar RD4X Hub (Brookhaven)", COR_NEON, function()
        pcall(function() loadstring(game:HttpGet(URL_BROOKHAVEN))() end)
    end)

    adicionarBotao(abaPopulares, ICONE_BOMB, "Pass or Explode Hub", COR_NEON, function()
        pcall(function() loadstring(game:HttpGet(URL_PASS_EXPLODE))() end)
    end)

    -- Auto-selecionar aba
    local abaAuto = abaBrookhaven
    if jogoDetectado == "Populares" then abaAuto = abaPopulares
    elseif jogoDetectado == "Outros" then abaAuto = abaUniversal end

    task.spawn(function()
        task.wait(0.15)
        for _, p in pairs(abasPaineis) do p.Visible = false end
        for _, b in pairs(botoesAba) do
            b.btn.TextColor3 = COR_TEXTO_CINZA
            b.btn.BackgroundColor3 = COR_BTN_INATIVO
            b.stroke.Transparency = 1
        end
        for nome, painel in pairs(abasPaineis) do
            if painel == abaAuto then
                painel.Visible = true
                local btnData = botoesAba[nome]
                if btnData then
                    btnData.btn.TextColor3 = COR_TEXTO
                    btnData.btn.BackgroundColor3 = COR_BTN_ATIVO
                    btnData.btn.BackgroundTransparency = 0.2
                    btnData.stroke.Transparency = 0
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
        TweenService:Create(launcherFrame,  out, {BackgroundTransparency = 1, Size = UDim2.new(0, 400, 0, 200), Position = UDim2.new(0.5, -200, 0.5, -100)}):Play()
        TweenService:Create(blur, out, {Size = 0}):Play()
        task.wait(0.3)
        screenGui:Destroy()
    end)

    -- Animação de Entrada
    local intro2 = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    launcherFrame.Size = UDim2.new(0, 400, 0, 200)
    launcherFrame.Position = UDim2.new(0.5, -200, 0.5, -100)

    TweenService:Create(mainBackground, intro2, {BackgroundTransparency = 0.4}):Play()
    TweenService:Create(launcherFrame, intro2, {
        BackgroundTransparency = MENU_TRANSPARENCIA,
        Size = UDim2.new(0, 520, 0, 380),
        Position = UDim2.new(0.5, -260, 0.5, -190)
    }):Play()
    TweenService:Create(frameStroke, intro2, {Transparency = 0.2}):Play()
    TweenService:Create(titleLabel, intro2, {TextTransparency = 0}):Play()
    TweenService:Create(subTitle,    intro2, {TextTransparency = 0}):Play()
end)
