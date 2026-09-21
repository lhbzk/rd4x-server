-- ==========================================================
-- RD4X LAUNCHER COM LOADING FLUENT E AUTO-DESTRUIÇÃO
-- ==========================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove instâncias antigas para evitar duplicados
if playerGui:FindFirstChild("RD4XLoading") then playerGui.RD4XLoading:Destroy() end
if playerGui:FindFirstChild("RD4XLauncher") then playerGui.RD4XLauncher:Destroy() end

-- Links dos scripts
local URL_BROOKHAVEN = "https://raw.githubusercontent.com/lhbzk/rd4x-server/main/rd4x_hub.lua"
local URL_PASS_EXPLODE = "https://raw.githubusercontent.com/lhbzk/rd4x-server/refs/heads/main/rd4x_bomb.lua"

-- Detecção do jogo atual
local idJogo = game.PlaceId
local nomeJogo = ""
pcall(function()
    local info = MarketplaceService:GetProductInfo(idJogo)
    if info and info.Name then nomeJogo = info.Name:lower() end
end)

local jogoDetectado = "Outros"
if nomeJogo:find("pass") or nomeJogo:find("explode") or nomeJogo:find("bomba") or nomeJogo:find("hot potato") then
    jogoDetectado = "Populares"
elseif idJogo == 4924922222 or nomeJogo:find("brookhaven") then
    jogoDetectado = "Brookhaven"
end

-- ==========================================================
-- 1. TELA DE CARREGAMENTO (ESTILO FLUENT)
-- ==========================================================
local loadGui = Instance.new("ScreenGui")
loadGui.Name = "RD4XLoading"
loadGui.IgnoreGuiInset = true
loadGui.Parent = playerGui

local bgLoad = Instance.new("Frame")
bgLoad.Size = UDim2.new(1, 0, 1, 0)
bgLoad.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
bgLoad.BackgroundTransparency = 1
bgLoad.Parent = loadGui

local containerLoad = Instance.new("Frame")
containerLoad.Size = UDim2.new(0, 420, 0, 220)
containerLoad.Position = UDim2.new(0.5, -210, 0.5, -110)
containerLoad.BackgroundTransparency = 1
containerLoad.Parent = bgLoad

local titleLoad = Instance.new("TextLabel")
titleLoad.Size = UDim2.new(1, 0, 0, 50)
titleLoad.Position = UDim2.new(0, 0, 0, 10)
titleLoad.BackgroundTransparency = 1
titleLoad.Text = "RD4X HUB"
titleLoad.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLoad.TextSize = 24
titleLoad.Font = Enum.Font.GothamBold
titleLoad.TextTransparency = 1
titleLoad.Parent = containerLoad

local statusLoad = Instance.new("TextLabel")
statusLoad.Size = UDim2.new(1, 0, 0, 30)
statusLoad.Position = UDim2.new(0, 0, 0, 75)
statusLoad.BackgroundTransparency = 1
statusLoad.Text = "Iniciando sistemas..."
statusLoad.TextColor3 = Color3.fromRGB(160, 165, 180)
statusLoad.TextSize = 14
statusLoad.Font = Enum.Font.GothamMedium
statusLoad.TextTransparency = 1
statusLoad.Parent = containerLoad

local barBackground = Instance.new("Frame")
barBackground.Size = UDim2.new(0.9, 0, 0, 10)
barBackground.Position = UDim2.new(0.05, 0, 0, 130)
barBackground.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
barBackground.BackgroundTransparency = 1
barBackground.BorderSizePixel = 0
barBackground.Parent = containerLoad

local bgCorner = Instance.new("UICorner")
bgCorner.CornerRadius = UDim.new(1, 0)
bgCorner.Parent = barBackground

local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
progressBar.BorderSizePixel = 0
progressBar.Parent = barBackground

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(1, 0)
barCorner.Parent = progressBar

local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 120, 220)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 200, 255))
})
uiGradient.Parent = progressBar

local glow = Instance.new("UIStroke")
glow.Transparency = 1
glow.Color = Color3.fromRGB(40, 120, 220)
glow.Thickness = 2
glow.Parent = barBackground

-- Animação de Entrada do Loading
local introTween = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenService:Create(bgLoad, introTween, {BackgroundTransparency = 0.15}):Play()
TweenService:Create(titleLoad, introTween, {TextTransparency = 0}):Play()
TweenService:Create(statusLoad, introTween, {TextTransparency = 0}):Play()
TweenService:Create(barBackground, introTween, {BackgroundTransparency = 0}):Play()
TweenService:Create(glow, introTween, {Transparency = 0.4}):Play()

-- Execução da Barra de Progresso
task.spawn(function()
    local tempoTotal = 1.8
    local passos = 100
    task.wait(0.3)
    
    for i = 1, passos do
        progressBar.Size = UDim2.new(i / passos, 0, 1, 0)
        if i < 40 then
            statusLoad.Text = "Carregando módulos... " .. i .. "%"
        elseif i < 80 then
            statusLoad.Text = "Sincronizando interface... " .. i .. "%"
        else
            statusLoad.Text = "Tudo pronto! " .. i .. "%"
        end
        task.wait(tempoTotal / passos)
    end
    
    task.wait(0.2)
    
    -- Fade Out da Tela de Loading
    local outroTween = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(bgLoad, outroTween, {BackgroundTransparency = 1}):Play()
    TweenService:Create(titleLoad, outroTween, {TextTransparency = 1}):Play()
    TweenService:Create(statusLoad, outroTween, {TextTransparency = 1}):Play()
    TweenService:Create(barBackground, outroTween, {BackgroundTransparency = 1}):Play()
    TweenService:Create(glow, outroTween, {Transparency = 1}):Play()
    
    task.wait(0.3)
    loadGui:Destroy()
    
    -- ==========================================================
    -- 2. ABRIR O LAUNCHER AZUL COM 4 ABAS
    -- ==========================================================
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RD4XLauncher"
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui

    local mainBackground = Instance.new("Frame")
    mainBackground.Size = UDim2.new(1, 0, 1, 0)
    mainBackground.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
    mainBackground.BackgroundTransparency = 1
    mainBackground.Parent = screenGui

    local launcherFrame = Instance.new("Frame")
    launcherFrame.Size = UDim2.new(0, 520, 0, 360)
    launcherFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
    local COR_AZUL_BONITO = Color3.fromRGB(20, 24, 36)
    launcherFrame.BackgroundColor3 = COR_AZUL_BONITO
    launcherFrame.BackgroundTransparency = 1
    launcherFrame.Parent = mainBackground

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 12)
    frameCorner.Parent = launcherFrame

    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Color3.fromRGB(45, 85, 155)
    frameStroke.Transparency = 1
    frameStroke.Thickness = 1.5
    frameStroke.Parent = launcherFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "⚡ RD4X LAUNCHER ⚡"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextTransparency = 1
    titleLabel.Parent = launcherFrame

    -- Sistema de Abas
    local abaBar = Instance.new("Frame")
    abaBar.Size = UDim2.new(0.92, 0, 0, 36)
    abaBar.Position = UDim2.new(0.04, 0, 0, 60)
    abaBar.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
    abaBar.BackgroundTransparency = 1
    abaBar.Parent = launcherFrame

    local abaBarCorner = Instance.new("UICorner")
    abaBarCorner.CornerRadius = UDim.new(0, 8)
    abaBarCorner.Parent = abaBar

    local abaLayout = Instance.new("UIListLayout")
    abaLayout.FillDirection = Enum.FillDirection.Horizontal
    abaLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    abaLayout.SortOrder = Enum.SortOrder.LayoutOrder
    abaLayout.Padding = UDim.new(0, 6)
    abaLayout.Parent = abaBar

    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(0.92, 0, 0, 220)
    contentContainer.Position = UDim2.new(0.04, 0, 0, 110)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = launcherFrame

    local abasPaineis = {}
    local botoesAba = {}

    local COR_BOTAO_PADRAO = Color3.fromRGB(24, 30, 48)
    local COR_BOTAO_DESTAQUE = Color3.fromRGB(12, 45, 95) -- Azul escuro para destaque

    local function criarAba(nomeAba, ordem)
        local btnAba = Instance.new("TextButton")
        btnAba.Size = UDim2.new(0.23, 0, 1, 0)
        btnAba.BackgroundColor3 = COR_BOTAO_PADRAO
        btnAba.Text = nomeAba
        btnAba.TextColor3 = Color3.fromRGB(150, 175, 215)
        btnAba.TextSize = 12
        btnAba.Font = Enum.Font.GothamSemibold
        btnAba.AutoButtonColor = false
        btnAba.LayoutOrder = ordem
        btnAba.Parent = abaBar
        
        local cBtn = Instance.new("UICorner")
        cBtn.CornerRadius = UDim.new(0, 6)
        cBtn.Parent = btnAba

        local painel = Instance.new("ScrollingFrame")
        painel.Size = UDim2.new(1, 0, 1, 0)
        painel.BackgroundTransparency = 1
        painel.BorderSizePixel = 0
        painel.Visible = false
        painel.CanvasSize = UDim2.new(0, 0, 0, 0)
        painel.ScrollBarThickness = 3
        painel.Parent = contentContainer

        local pLayout = Instance.new("UIListLayout")
        pLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        pLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pLayout.Padding = UDim.new(0, 10)
        pLayout.Parent = painel

        abasPaineis[nomeAba] = painel
        botoesAba[nomeAba] = btnAba

        btnAba.MouseButton1Click:Connect(function()
            for k, p in pairs(abasPaineis) do p.Visible = false end
            for k, b in pairs(botoesAba) do 
                b.TextColor3 = Color3.fromRGB(150, 175, 215)
                TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = COR_BOTAO_PADRAO}):Play()
            end
            painel.Visible = true
            btnAba.TextColor3 = Color3.fromRGB(255, 255, 255)
            TweenService:Create(btnAba, TweenInfo.new(0.2), {BackgroundColor3 = COR_BOTAO_DESTAQUE}):Play()
        end)

        return painel
    end

    local abaBrookhaven = criarAba("Brookhaven", 1)
    local abaUniversal = criarAba("Universal", 2)
    local abaPopulares = criarAba("Populares", 3)
    local abaOutros = criarAba("Outros", 4)

    local function adicionarBotaoNaAba(painelAba, texto, corBorda, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 44)
        btn.BackgroundColor3 = Color3.fromRGB(18, 24, 40)
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.Parent = painelAba
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = corBorda
        stroke.Thickness = 1.5
        stroke.Parent = btn
        
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = texto
        txt.TextColor3 = Color3.fromRGB(255, 255, 255)
        txt.TextSize = 13
        txt.Font = Enum.Font.GothamSemibold
        txt.Parent = btn
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 35, 58)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(18, 24, 40)}):Play()
        end)
        
        btn.MouseButton1Click:Connect(function()
            -- Auto-destruição imediata do Launcher ao executar qualquer Hub
            local destroyTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(mainBackground, destroyTween, {BackgroundTransparency = 1}):Play()
            TweenService:Create(launcherFrame, destroyTween, {BackgroundTransparency = 1}):Play()
            task.wait(0.2)
            screenGui:Destroy()
            
            if callback then callback() end
        end)
    end

    -- Preenchimento (Universal e Outros vazios)
    adicionarBotaoNaAba(abaBrookhaven, "🏠  Carregar RD4X Hub (Brookhaven)", Color3.fromRGB(40, 120, 220), function()
        pcall(function() loadstring(game:HttpGet(URL_BROOKHAVEN))() end)
    end)

    adicionarBotaoNaAba(abaPopulares, "💣  Pass or Explode Hub", Color3.fromRGB(40, 120, 220), function()
        pcall(function() loadstring(game:HttpGet(URL_PASS_EXPLODE))() end)
    end)

    -- Abrir na aba detetada automaticamente
    local abaParaAbrir = abaOutros
    if jogoDetectado == "Brookhaven" then
        abaParaAbrir = abaBrookhaven
    elseif jogoDetectado == "Populares" then
        abaParaAbrir = abaPopulares
    end

    task.spawn(function()
        task.wait(0.1)
        for k, p in pairs(abasPaineis) do p.Visible = false end
        for k, b in pairs(botoesAba) do 
            b.TextColor3 = Color3.fromRGB(150, 175, 215)
            b.BackgroundColor3 = COR_BOTAO_PADRAO
        end
        
        for nome, painel in pairs(abasPaineis) do
            if painel == abaParaAbrir then
                painel.Visible = true
                local btn = botoesAba[nome]
                if btn then
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.BackgroundColor3 = COR_BOTAO_DESTAQUE
                end
            end
        end
    end)

    -- Animação de Entrada do Launcher
    local launcherIntro = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(mainBackground, launcherIntro, {BackgroundTransparency = 0.4}):Play()
    TweenService:Create(launcherFrame, launcherIntro, {BackgroundTransparency = 0}):Play()
    TweenService:Create(frameStroke, launcherIntro, {Transparency = 0.3}):Play()
    TweenService:Create(titleLabel, launcherIntro, {TextTransparency = 0}):Play()
    TweenService:Create(abaBar, launcherIntro, {BackgroundTransparency = 0}):Play()
end)
