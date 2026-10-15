-- ==========================================================
-- 🇧🇷 RD4X HUB - BROOKHAVEN RP (INTERFACE PRÓPRIA + BOLHAS)
-- Creator: J. Epstein (Rd4X Team Oficial)
-- ==========================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------------------
-- WHITELIST API
--------------------------------------------------------------------------------
local MEU_ID_CREATOR = 4200878493
local API_URL = "https://rd4x-api.onrender.com"

local function VerificarWhitelist()
    if LocalPlayer.UserId == MEU_ID_CREATOR then return true end
    local sucesso, resposta = pcall(function()
        local urlReq = API_URL .. "/api/v2/whitelist?nick=" .. tostring(LocalPlayer.Name)
        local rawData = game:HttpGet(urlReq)
        return HttpService:JSONDecode(rawData)
    end)
    if sucesso and resposta and (resposta.success == true or resposta.whitelisted == true) then
        return true
    end
    return false
end

local UsuarioAutorizado = VerificarWhitelist()

--------------------------------------------------------------------------------
-- CORES E TRANSPARÊNCIA
--------------------------------------------------------------------------------
local COR_FUNDO      = Color3.fromRGB(18, 18, 22)
local COR_SIDEBAR    = Color3.fromRGB(22, 22, 26)
local COR_SECUNDARIA = Color3.fromRGB(28, 28, 34)
local COR_TEXTO      = Color3.fromRGB(240, 240, 245)
local COR_TEXTO_CINZA= Color3.fromRGB(140, 140, 150)
local COR_VERDE      = Color3.fromRGB(46, 204, 113)
local COR_BORDA      = Color3.fromRGB(40, 40, 48)
local COR_VERMELHO   = Color3.fromRGB(220, 20, 60)

local TRANSP_FUNDO       = 0.25
local TRANSP_SIDEBAR     = 0.35
local TRANSP_CARDS       = 0.45
local TRANSP_INPUT       = 0.55
local TRANSP_BOTAO_VERDE = 0.35

--------------------------------------------------------------------------------
-- CLEANUP
--------------------------------------------------------------------------------
local oldGui = CoreGui:FindFirstChild("Rd4XHubOficial")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Rd4XHubOficial"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = CoreGui

--------------------------------------------------------------------------------
-- BOTÃO FLUTUANTE (aparece quando hub está fechado)
--------------------------------------------------------------------------------
local BotaoFlutuante = Instance.new("ImageButton", ScreenGui)
BotaoFlutuante.Name = "BotaoFlutuanteRD4X"
BotaoFlutuante.Size = UDim2.new(0, 46, 0, 46)
BotaoFlutuante.Position = UDim2.new(0, 20, 0.5, -23)
BotaoFlutuante.BackgroundColor3 = COR_SECUNDARIA
BotaoFlutuante.BackgroundTransparency = 0.15
BotaoFlutuante.BorderSizePixel = 0
BotaoFlutuante.Image = "rbxassetid://109276734890323"
BotaoFlutuante.AutoButtonColor = false
BotaoFlutuante.Visible = false
BotaoFlutuante.ZIndex = 1000

local cBF = Instance.new("UICorner", BotaoFlutuante)
cBF.CornerRadius = UDim.new(1, 0)

local sBF = Instance.new("UIStroke", BotaoFlutuante)
sBF.Color = COR_VERMELHO
sBF.Thickness = 1.5
-- ==========================================================
-- ✨ PULSAR DO BOTÃO FLUTUANTE
-- ==========================================================
local pulsando = true
local tamanhoNormal = UDim2.new(0, 46, 0, 46)
local tamanhoPulsado = UDim2.new(0, 54, 0, 54)

task.spawn(function()
    while pulsando and BotaoFlutuante.Parent do
        -- Fase 1: cresce + brilha
        TweenService:Create(BotaoFlutuante, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Size = tamanhoPulsado,
            Position = BotaoFlutuante.Position - UDim2.new(0, 4, 0, 4)
        }):Play()
        TweenService:Create(sBF, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Transparency = 0,
            Thickness = 2.5
        }):Play()
        task.wait(0.6)

        -- Fase 2: volta ao normal
        TweenService:Create(BotaoFlutuante, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Size = tamanhoNormal,
            Position = BotaoFlutuante.Position + UDim2.new(0, 4, 0, 4)
        }):Play()
        TweenService:Create(sBF, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Transparency = 0.5,
            Thickness = 1.5
        }):Play()
        task.wait(0.6)
    end
end)

-- Pausa o pulso ao passar o mouse (fica parado pra clicar melhor)
BotaoFlutuante.MouseEnter:Connect(function()
    pulsando = false
end)

-- Arrastar botão flutuante
local bfDragging, bfDragStart, bfStartPos
BotaoFlutuante.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        bfDragging = true
        bfDragStart = input.Position
        bfStartPos = BotaoFlutuante.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then bfDragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if bfDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - bfDragStart
        BotaoFlutuante.Position = UDim2.new(bfStartPos.X.Scale, bfStartPos.X.Offset + delta.X, bfStartPos.Y.Scale, bfStartPos.Y.Offset + delta.Y)
    end
end)

BotaoFlutuante.MouseEnter:Connect(function()
    TweenService:Create(BotaoFlutuante, TweenInfo.new(0.15), {BackgroundTransparency = 0, Size = UDim2.new(0, 50, 0, 50), Position = BotaoFlutuante.Position - UDim2.new(0, 2, 0, 2)}):Play()
end)
BotaoFlutuante.MouseLeave:Connect(function()
    TweenService:Create(BotaoFlutuante, TweenInfo.new(0.15), {BackgroundTransparency = 0.15, Size = UDim2.new(0, 46, 0, 46)}):Play()
end)

--------------------------------------------------------------------------------
-- JANELA PRINCIPAL
--------------------------------------------------------------------------------
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 560, 0, 400)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -200)
MainFrame.BackgroundColor3 = COR_FUNDO
MainFrame.BackgroundTransparency = TRANSP_FUNDO
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 1
MainFrame.Visible = false

local cornerMain = Instance.new("UICorner", MainFrame)
cornerMain.CornerRadius = UDim.new(0, 10)

local strokeMain = Instance.new("UIStroke", MainFrame)
strokeMain.Color = COR_BORDA
strokeMain.Thickness = 1.2
strokeMain.Transparency = 0.3

-- Variáveis de estado
local isMinimized = false
local alturaNormal = 400
local alturaMinimizada = 38

-- Botão flutuante abre o hub
BotaoFlutuante.MouseButton1Click:Connect(function()
    BotaoFlutuante.Visible = false
    MainFrame.Visible = true
end)

-- Dragging MainFrame
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

--------------------------------------------------------------------------------
-- ✨ BOLHAS FLUTUANTES
--------------------------------------------------------------------------------
local BolhasContainer = Instance.new("Frame", MainFrame)
BolhasContainer.Name = "BolhasContainer"
BolhasContainer.Size = UDim2.new(1, 0, 1, 0)
BolhasContainer.BackgroundTransparency = 1
BolhasContainer.ClipsDescendants = true
BolhasContainer.ZIndex = 0
BolhasContainer.Active = false

local bolhasAtivas = true

local function criarBolha()
    if not bolhasAtivas or not BolhasContainer.Parent then return end
    local tam = math.random(6, 14)
    local bolha = Instance.new("Frame", BolhasContainer)
    bolha.Size = UDim2.new(0, tam, 0, tam)
    bolha.Position = UDim2.new(math.random() * 0.95, 0, 1, 10)
    local cores = {
    Color3.fromRGB(46, 204, 113),   -- verde
    Color3.fromRGB(52, 152, 219),   -- azul
    Color3.fromRGB(155, 89, 182),   -- roxo
    Color3.fromRGB(241, 196, 15),   -- amarelo
    Color3.fromRGB(231, 76, 60),    -- vermelho
}
bolha.BackgroundColor3 = cores[math.random(1, #cores)]
    bolha.BackgroundTransparency = math.random(15, 40) / 100
    bolha.BorderSizePixel = 0
    bolha.ZIndex = 0

    local c = Instance.new("UICorner", bolha)
    c.CornerRadius = UDim.new(1, 0)

    local stroke = Instance.new("UIStroke", bolha)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3

    local duracao = math.random(6, 12)
    local driftX = math.random(-60, 60)
    local posFinalX = bolha.Position.X.Scale * 560 + driftX

    local tween = TweenService:Create(bolha, TweenInfo.new(duracao, Enum.EasingStyle.Linear), {
        Position = UDim2.new(0, posFinalX, 0, -20),
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function() if bolha and bolha.Parent then bolha:Destroy() end end)
end

task.spawn(function()
    while bolhasAtivas and BolhasContainer.Parent do
        criarBolha()
        task.wait(math.random(8, 30) / 100)
    end
end)

--------------------------------------------------------------------------------
-- HEADER
--------------------------------------------------------------------------------
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 38)
Header.BackgroundTransparency = 1
Header.ZIndex = 5

local IconHeader = Instance.new("ImageLabel", Header)
IconHeader.Size = UDim2.new(0, 24, 0, 24)
IconHeader.Position = UDim2.new(0, 10, 0, 7)
IconHeader.BackgroundTransparency = 1
IconHeader.Image = "rbxassetid://109276734890323"
IconHeader.ScaleType = Enum.ScaleType.Crop
IconHeader.ZIndex = 6

local cIH = Instance.new("UICorner", IconHeader)
cIH.CornerRadius = UDim.new(1, 0)
IconHeader.ZIndex = 6

local TitleHeader = Instance.new("TextLabel", Header)
TitleHeader.Size = UDim2.new(0, 320, 0, 38)
TitleHeader.Position = UDim2.new(0, 34, 0, 0)
TitleHeader.BackgroundTransparency = 1
TitleHeader.Text = "Rd4X Hub Oficial $ 「 Brookhaven RP 🇧🇷 」"
TitleHeader.TextColor3 = COR_TEXTO
TitleHeader.TextSize = 11
TitleHeader.Font = Enum.Font.GothamBold
TitleHeader.TextXAlignment = Enum.TextXAlignment.Left
TitleHeader.ZIndex = 6

local UserCredit = Instance.new("TextLabel", Header)
UserCredit.Size = UDim2.new(0, 200, 0, 38)
UserCredit.Position = UDim2.new(1, -250, 0, 0)
UserCredit.BackgroundTransparency = 1
UserCredit.Text = "By Rd4X Team"
UserCredit.TextColor3 = COR_VERDE
UserCredit.TextSize = 9
UserCredit.Font = Enum.Font.Gotham
UserCredit.TextXAlignment = Enum.TextXAlignment.Right
UserCredit.ZIndex = 6

-- Botão Minimizar
local MinimizeBtn = Instance.new("TextButton", Header)
MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
MinimizeBtn.Position = UDim2.new(1, -48, 0, 9)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = COR_TEXTO_CINZA
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.ZIndex = 6
MinimizeBtn.AutoButtonColor = false

MinimizeBtn.MouseEnter:Connect(function()
    MinimizeBtn.TextColor3 = COR_TEXTO
end)
MinimizeBtn.MouseLeave:Connect(function()
    MinimizeBtn.TextColor3 = COR_TEXTO_CINZA
end)

-- Botão Fechar (X)
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -26, 0, 9)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = COR_TEXTO_CINZA
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 6
CloseBtn.AutoButtonColor = false

CloseBtn.MouseEnter:Connect(function()
    CloseBtn.TextColor3 = COR_VERMELHO
end)
CloseBtn.MouseLeave:Connect(function()
    CloseBtn.TextColor3 = COR_TEXTO_CINZA
end)

--------------------------------------------------------------------------------
-- SIDEBAR MÓVEL (arrastável)
--------------------------------------------------------------------------------
local Sidebar = Instance.new("ScrollingFrame", MainFrame)
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 150, 1, -38)
Sidebar.Position = UDim2.new(0, 0, 0, 38)
Sidebar.BackgroundColor3 = COR_SIDEBAR
Sidebar.BackgroundTransparency = TRANSP_SIDEBAR
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 2
Sidebar.ScrollBarImageColor3 = COR_BORDA
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
Sidebar.ZIndex = 5
Sidebar.Active = true

-- Handle de arrastar (barra fina na lateral direita da sidebar)
local SidebarHandle = Instance.new("TextButton", MainFrame)
SidebarHandle.Name = "SidebarHandle"
SidebarHandle.Size = UDim2.new(0, 5, 1, -38)
SidebarHandle.Position = UDim2.new(0, 150, 0, 38)
SidebarHandle.BackgroundColor3 = COR_BORDA
SidebarHandle.BackgroundTransparency = 0.5
SidebarHandle.BorderSizePixel = 0
SidebarHandle.Text = ""
SidebarHandle.AutoButtonColor = false
SidebarHandle.ZIndex = 20

SidebarHandle.MouseEnter:Connect(function()
    TweenService:Create(SidebarHandle, TweenInfo.new(0.15), {BackgroundColor3 = COR_VERDE, BackgroundTransparency = 0.2}):Play()
end)
SidebarHandle.MouseLeave:Connect(function()
    if not sidebarDragging then
        TweenService:Create(SidebarHandle, TweenInfo.new(0.15), {BackgroundColor3 = COR_BORDA, BackgroundTransparency = 0.5}):Play()
    end
end)

local sidebarDragging = false
local sidebarDragStartX = 0
local sidebarStartWidth = 150
local LARGURA_MIN = 100
local LARGURA_MAX = 320

SidebarHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sidebarDragging = true
        sidebarDragStartX = input.Position.X
        sidebarStartWidth = Sidebar.AbsoluteSize.X

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                sidebarDragging = false
                TweenService:Create(SidebarHandle, TweenInfo.new(0.15), {BackgroundColor3 = COR_BORDA, BackgroundTransparency = 0.5}):Play()
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sidebarDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local deltaX = input.Position.X - sidebarDragStartX
        local nova = math.clamp(sidebarStartWidth + deltaX, LARGURA_MIN, LARGURA_MAX)
        Sidebar.Size = UDim2.new(0, nova, 1, -38)
        SidebarHandle.Position = UDim2.new(0, nova, 0, 38)
        -- Ajusta as abas também
        for _, conteudo in pairs(TabFrames) do
            conteudo.Position = UDim2.new(0, nova + 6, 0, 44)
            conteudo.Size = UDim2.new(1, -(nova + 12), 1, -50)
        end
    end
end)

local sideLayout = Instance.new("UIListLayout", Sidebar)
sideLayout.Padding = UDim.new(0, 3)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder

local sidePadding = Instance.new("UIPadding", Sidebar)
sidePadding.PaddingTop = UDim.new(0, 6)
sidePadding.PaddingBottom = UDim.new(0, 6)
sidePadding.PaddingLeft = UDim.new(0, 6)
sidePadding.PaddingRight = UDim.new(0, 6)

--------------------------------------------------------------------------------
-- NOTIFICAÇÕES
--------------------------------------------------------------------------------
local NotifHolder = Instance.new("Frame", ScreenGui)
NotifHolder.Size = UDim2.new(0, 280, 1, -20)
NotifHolder.Position = UDim2.new(1, -290, 0, 10)
NotifHolder.BackgroundTransparency = 1

local notifLayout = Instance.new("UIListLayout", NotifHolder)
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Padding = UDim.new(0, 6)

local function Notify(title, content, duration)
    duration = duration or 3
    local frame = Instance.new("Frame", NotifHolder)
    frame.Size = UDim2.new(1, 0, 0, 56)
    frame.BackgroundColor3 = COR_SECUNDARIA
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0

    local c = Instance.new("UICorner", frame)
    c.CornerRadius = UDim.new(0, 6)

    local s = Instance.new("UIStroke", frame)
    s.Color = COR_VERDE
    s.Thickness = 1

    local titleLbl = Instance.new("TextLabel", frame)
    titleLbl.Size = UDim2.new(1, -20, 0, 18)
    titleLbl.Position = UDim2.new(0, 10, 0, 6)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "RD4X | " .. tostring(title)
    titleLbl.TextColor3 = COR_VERDE
    titleLbl.TextSize = 11
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local contentLbl = Instance.new("TextLabel", frame)
    contentLbl.Size = UDim2.new(1, -20, 0, 30)
    contentLbl.Position = UDim2.new(0, 10, 0, 22)
    contentLbl.BackgroundTransparency = 1
    contentLbl.Text = tostring(content)
    contentLbl.TextColor3 = COR_TEXTO
    contentLbl.TextSize = 10
    contentLbl.Font = Enum.Font.Gotham
    contentLbl.TextXAlignment = Enum.TextXAlignment.Left
    contentLbl.TextWrapped = true

    task.delay(duration, function()
        pcall(function()
            TweenService:Create(frame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
            TweenService:Create(titleLbl, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
            TweenService:Create(contentLbl, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
            task.wait(0.45)
            frame:Destroy()
        end)
    end)
end

--------------------------------------------------------------------------------
-- FUNÇÕES MINIMIZAR / FECHAR
--------------------------------------------------------------------------------
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 560, 0, alturaMinimizada)
        }):Play()
        Sidebar.Visible = false
        SidebarHandle.Visible = false
        for _, c in pairs(TabFrames) do c.Visible = false end
        MinimizeBtn.Text = "▢"
        MinimizeBtn.TextColor3 = COR_VERDE
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 560, 0, alturaNormal)
        }):Play()
        task.wait(0.35)
        Sidebar.Visible = true
        SidebarHandle.Visible = true
        -- Mostra a aba ativa
        for n, c in pairs(TabFrames) do
            if TabButtons[n].TextColor3 == COR_TEXTO then
                c.Visible = true
            end
        end
        MinimizeBtn.Text = "—"
        MinimizeBtn.TextColor3 = COR_TEXTO_CINZA
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    BotaoFlutuante.Visible = true
end)

--------------------------------------------------------------------------------
-- UI TOOLKIT
--------------------------------------------------------------------------------
local UI = {}

function UI.Paragraph(parent, opts)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, -4, 0, opts.Height or 44)
    lbl.BackgroundColor3 = COR_SECUNDARIA
    lbl.BackgroundTransparency = TRANSP_CARDS
    lbl.BorderSizePixel = 0
    lbl.Text = (opts.Title and (opts.Title .. "\n") or "") .. (opts.Content or "")
    lbl.TextColor3 = COR_TEXTO_CINZA
    lbl.TextSize = 10
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Top
    lbl.TextWrapped = true
    lbl.ZIndex = 6

    local c = Instance.new("UICorner", lbl)
    c.CornerRadius = UDim.new(0, 6)
    local p = Instance.new("UIPadding", lbl)
    p.PaddingTop = UDim.new(0, 6)
    p.PaddingLeft = UDim.new(0, 8)
    p.PaddingRight = UDim.new(0, 8)
    return lbl
end

function UI.Button(parent, opts)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -4, 0, 28)
    btn.BackgroundColor3 = COR_SECUNDARIA
    btn.BackgroundTransparency = TRANSP_CARDS
    btn.BorderSizePixel = 0
    btn.Text = opts.Name or "Botão"
    btn.TextColor3 = COR_TEXTO
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamMedium
    btn.AutoButtonColor = false
    btn.ZIndex = 6

    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 50, 62), BackgroundTransparency = 0.25}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = COR_SECUNDARIA, BackgroundTransparency = TRANSP_CARDS}):Play()
    end)
    -- Dentro do UI.Button, antes do Callback:
btn.MouseButton1Click:Connect(function()
    pcall(function()
        local som = Instance.new("Sound", SoundService)
        som.SoundId = "rbxassetid://116105996777798"
        som.Volume = 0.3
        som:Play()
        task.delay(2, function() som:Destroy() end)
    end)
    if opts.Callback then pcall(opts.Callback) end
end)
    return btn
end

function UI.Input(parent, opts)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -4, 0, 32)
    container.BackgroundColor3 = COR_SECUNDARIA
    container.BackgroundTransparency = TRANSP_CARDS
    container.BorderSizePixel = 0
    container.ZIndex = 6

    local c = Instance.new("UICorner", container)
    c.CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0.55, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = opts.Name or "Input"
    label.TextColor3 = COR_TEXTO_CINZA
    label.TextSize = 10
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 7

    local tb = Instance.new("TextBox", container)
    tb.Size = UDim2.new(0.45, -10, 1, -8)
    tb.Position = UDim2.new(0.55, 0, 0, 4)
    tb.BackgroundColor3 = COR_FUNDO
    tb.BackgroundTransparency = TRANSP_INPUT
    tb.BorderSizePixel = 0
    tb.Text = opts.CurrentValue or ""
    tb.PlaceholderText = opts.PlaceholderText or "..."
    tb.PlaceholderColor3 = COR_TEXTO_CINZA
    tb.TextColor3 = COR_TEXTO
    tb.TextSize = 10
    tb.Font = Enum.Font.Gotham
    tb.ClearTextOnFocus = false
    tb.ZIndex = 7

    local cc = Instance.new("UICorner", tb)
    cc.CornerRadius = UDim.new(0, 4)
    local p = Instance.new("UIPadding", tb)
    p.PaddingLeft = UDim.new(0, 6)

    tb.FocusLost:Connect(function()
        if opts.Callback then pcall(opts.Callback, tb.Text) end
    end)
    return tb
end

function UI.Toggle(parent, opts)
    local container = Instance.new("TextButton", parent)
    container.Size = UDim2.new(1, -4, 0, 28)
    container.BackgroundColor3 = COR_SECUNDARIA
    container.BackgroundTransparency = TRANSP_CARDS
    container.BorderSizePixel = 0
    container.Text = ""
    container.AutoButtonColor = false
    container.ZIndex = 6

    local c = Instance.new("UICorner", container)
    c.CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = opts.Name or "Toggle"
    label.TextColor3 = COR_TEXTO
    label.TextSize = 10
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 7

    local switchBg = Instance.new("Frame", container)
    switchBg.Size = UDim2.new(0, 34, 0, 18)
    switchBg.Position = UDim2.new(1, -44, 0.5, -9)
    switchBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    switchBg.BorderSizePixel = 0
    switchBg.ZIndex = 7
    local cc = Instance.new("UICorner", switchBg)
    cc.CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", switchBg)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = COR_TEXTO
    knob.BorderSizePixel = 0
    knob.ZIndex = 8
    local ck = Instance.new("UICorner", knob)
    ck.CornerRadius = UDim.new(1, 0)

    local state = opts.CurrentValue or false

    local function update()
        TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = state and COR_VERDE or Color3.fromRGB(60, 60, 70)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
    end
    update()

    container.MouseButton1Click:Connect(function()
        state = not state
        update()
        if opts.Callback then pcall(opts.Callback, state) end
    end)
    return { Set = function(v) state = v update() if opts.Callback then pcall(opts.Callback, v) end end }
end

function UI.Dropdown(parent, opts)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -4, 0, 32)
    container.BackgroundColor3 = COR_SECUNDARIA
    container.BackgroundTransparency = TRANSP_CARDS
    container.BorderSizePixel = 0
    container.ClipsDescendants = false
    container.ZIndex = 8

    local c = Instance.new("UICorner", container)
    c.CornerRadius = UDim.new(0, 6)

    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 9

    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(0.6, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = opts.Name or "Dropdown"
    label.TextColor3 = COR_TEXTO_CINZA
    label.TextSize = 10
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 9

    local currentLabel = Instance.new("TextLabel", btn)
    currentLabel.Size = UDim2.new(0.4, -20, 1, 0)
    currentLabel.Position = UDim2.new(0.6, 0, 0, 0)
    currentLabel.BackgroundTransparency = 1
    currentLabel.Text = (opts.CurrentOption and opts.CurrentOption[1]) or "..."
    currentLabel.TextColor3 = COR_TEXTO
    currentLabel.TextSize = 10
    currentLabel.Font = Enum.Font.GothamMedium
    currentLabel.TextXAlignment = Enum.TextXAlignment.Right
    currentLabel.ZIndex = 9

    local arrow = Instance.new("TextLabel", btn)
    arrow.Size = UDim2.new(0, 14, 0, 14)
    arrow.Position = UDim2.new(1, -20, 0.5, -7)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = COR_TEXTO_CINZA
    arrow.TextSize = 8
    arrow.Font = Enum.Font.GothamBold
    arrow.ZIndex = 9

    local listFrame = Instance.new("ScrollingFrame", container)
    listFrame.Size = UDim2.new(1, 0, 0, 100)
    listFrame.Position = UDim2.new(0, 0, 1, 4)
    listFrame.BackgroundColor3 = COR_SIDEBAR
    listFrame.BackgroundTransparency = 0.1
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.ZIndex = 15
    listFrame.ScrollBarThickness = 2
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listFrame.ScrollingDirection = Enum.ScrollingDirection.Y

    local cc = Instance.new("UICorner", listFrame)
    cc.CornerRadius = UDim.new(0, 6)
    local sl = Instance.new("UIStroke", listFrame)
    sl.Color = COR_BORDA
    sl.Thickness = 1

    local listLayout = Instance.new("UIListLayout", listFrame)
    listLayout.Padding = UDim.new(0, 2)

    local listPad = Instance.new("UIPadding", listFrame)
    listPad.PaddingTop = UDim.new(0, 4)
    listPad.PaddingBottom = UDim.new(0, 4)
    listPad.PaddingLeft = UDim.new(0, 4)
    listPad.PaddingRight = UDim.new(0, 4)

    local isOpen = false
    local options = opts.Options or {}
    local selected = (opts.CurrentOption and opts.CurrentOption[1]) or options[1]

    local function refreshOptions(newOptions)
        options = newOptions or {}
        for _, ch in ipairs(listFrame:GetChildren()) do
            if ch:IsA("TextButton") then ch:Destroy() end
        end
        for _, opt in ipairs(options) do
            local ob = Instance.new("TextButton", listFrame)
            ob.Size = UDim2.new(1, -4, 0, 24)
            ob.BackgroundColor3 = COR_SECUNDARIA
            ob.BackgroundTransparency = 1
            ob.BorderSizePixel = 0
            ob.Text = tostring(opt)
            ob.TextColor3 = COR_TEXTO
            ob.TextSize = 10
            ob.Font = Enum.Font.Gotham
            ob.TextXAlignment = Enum.TextXAlignment.Left
            ob.AutoButtonColor = false
            ob.ZIndex = 16

            local pp = Instance.new("UIPadding", ob)
            pp.PaddingLeft = UDim.new(0, 8)

            ob.MouseEnter:Connect(function() ob.BackgroundTransparency = 0.4 end)
            ob.MouseLeave:Connect(function() ob.BackgroundTransparency = 1 end)
            ob.MouseButton1Click:Connect(function()
                selected = opt
                currentLabel.Text = tostring(opt)
                listFrame.Visible = false
                isOpen = false
                if opts.Callback then pcall(opts.Callback, {opt}) end
            end)
        end
        local h = math.clamp(#options * 26 + 8, 30, 140)
        listFrame.Size = UDim2.new(1, 0, 0, h)
    end

    refreshOptions(options)

    btn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        listFrame.Visible = isOpen
    end)

    return {
        Refresh = function(newList) refreshOptions(newList) end,
        Set = function(v) selected = v currentLabel.Text = tostring(v) end
    }
end

--------------------------------------------------------------------------------
-- SISTEMA DE ABAS
--------------------------------------------------------------------------------
TabFrames = {}
TabButtons = {}

local function ShowTab(name)
    for n, f in pairs(TabFrames) do f.Visible = (n == name) end
    for n, b in pairs(TabButtons) do
        if n == name then
            b.BackgroundTransparency = TRANSP_CARDS
            b.TextColor3 = COR_TEXTO
        else
            b.BackgroundTransparency = 1
            b.TextColor3 = COR_TEXTO_CINZA
        end
    end
end

local function CreateTab(name)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.BackgroundColor3 = COR_SECUNDARIA
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = "   " .. name
    btn.TextColor3 = COR_TEXTO_CINZA
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.ZIndex = 6

    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)

    local content = Instance.new("ScrollingFrame", MainFrame)
    content.Size = UDim2.new(1, -162, 1, -50)
    content.Position = UDim2.new(0, 156, 0, 44)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = COR_BORDA
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Visible = false
    content.ZIndex = 5

    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    TabFrames[name] = content
    TabButtons[name] = btn

    btn.MouseButton1Click:Connect(function() ShowTab(name) end)
    return content
end

--------------------------------------------------------------------------------
-- CRIAÇÃO DAS ABAS
--------------------------------------------------------------------------------
local Tabs = {
    Principal = CreateTab("Informações"),
    Admin     = CreateTab("Admin"),
    Vip       = CreateTab("VIP"),
    Player    = CreateTab("Jogador"),
    Servidor  = CreateTab("Servidor"),
    Carros    = CreateTab("Veículo"),
    Casas     = CreateTab("Casa"),
    Musicas   = CreateTab("Música"),
    Troll     = CreateTab("Troll"),
    Outros    = CreateTab("Outros"),
    Protecao  = CreateTab("Proteção"),
    Scripts   = CreateTab("Scripts"),
}

ShowTab("Informações")

--------------------------------------------------------------------------------
-- ABA INFORMAÇÕES
--------------------------------------------------------------------------------
local infoContent = Tabs.Principal

local LinkText = Instance.new("TextLabel", infoContent)
LinkText.Size = UDim2.new(1, -4, 0, 14)
LinkText.BackgroundTransparency = 1
LinkText.Text = "https://discord.gg/Eh8ga7z55"
LinkText.TextColor3 = COR_TEXTO_CINZA
LinkText.TextSize = 10
LinkText.Font = Enum.Font.Gotham
LinkText.TextXAlignment = Enum.TextXAlignment.Left

local CardComunidade = Instance.new("Frame", infoContent)
CardComunidade.Size = UDim2.new(1, -4, 0, 56)
CardComunidade.BackgroundColor3 = COR_SECUNDARIA
CardComunidade.BackgroundTransparency = TRANSP_CARDS
CardComunidade.BorderSizePixel = 0
CardComunidade.ZIndex = 6

local cCC = Instance.new("UICorner", CardComunidade)
cCC.CornerRadius = UDim.new(0, 6)

local IconeComunidade = Instance.new("ImageLabel", CardComunidade)
IconeComunidade.Size = UDim2.new(0, 40, 0, 40)
IconeComunidade.Position = UDim2.new(0, 8, 0.5, -20)
IconeComunidade.BackgroundTransparency = 1
IconeComunidade.Image = "rbxassetid://109276734890323"
IconeComunidade.ScaleType = Enum.ScaleType.Crop
IconeComunidade.ZIndex = 7

local ccIC = Instance.new("UICorner", IconeComunidade)
ccIC.CornerRadius = UDim.new(1, 0)

local TituloComunidade = Instance.new("TextLabel", CardComunidade)
TituloComunidade.Size = UDim2.new(1, -70, 0, 18)
TituloComunidade.Position = UDim2.new(0, 56, 0, 10)
TituloComunidade.BackgroundTransparency = 1
TituloComunidade.Text = "Comunidade Rd4X"
TituloComunidade.TextColor3 = COR_TEXTO
TituloComunidade.TextSize = 12
TituloComunidade.Font = Enum.Font.GothamBold
TituloComunidade.TextXAlignment = Enum.TextXAlignment.Left
TituloComunidade.ZIndex = 7

local SubComunidade = Instance.new("TextLabel", CardComunidade)
SubComunidade.Size = UDim2.new(1, -70, 0, 16)
SubComunidade.Position = UDim2.new(0, 56, 0, 28)
SubComunidade.BackgroundTransparency = 1
SubComunidade.Text = "Entre no Discord oficial"
SubComunidade.TextColor3 = COR_TEXTO_CINZA
SubComunidade.TextSize = 10
SubComunidade.Font = Enum.Font.Gotham
SubComunidade.TextXAlignment = Enum.TextXAlignment.Left
SubComunidade.ZIndex = 7

local BotaoCopyLink = Instance.new("TextButton", infoContent)
BotaoCopyLink.Size = UDim2.new(1, -4, 0, 34)
BotaoCopyLink.BackgroundColor3 = COR_VERDE
BotaoCopyLink.BackgroundTransparency = TRANSP_BOTAO_VERDE
BotaoCopyLink.BorderSizePixel = 0
BotaoCopyLink.Text = "Copy Link"
BotaoCopyLink.TextColor3 = Color3.fromRGB(255, 255, 255)
BotaoCopyLink.TextSize = 12
BotaoCopyLink.Font = Enum.Font.GothamBold
BotaoCopyLink.AutoButtonColor = false
BotaoCopyLink.ZIndex = 6

local cBCL = Instance.new("UICorner", BotaoCopyLink)
cBCL.CornerRadius = UDim.new(0, 6)

BotaoCopyLink.MouseEnter:Connect(function()
    TweenService:Create(BotaoCopyLink, TweenInfo.new(0.15), {BackgroundTransparency = 0.15}):Play()
end)
BotaoCopyLink.MouseLeave:Connect(function()
    TweenService:Create(BotaoCopyLink, TweenInfo.new(0.15), {BackgroundTransparency = TRANSP_BOTAO_VERDE}):Play()
end)
BotaoCopyLink.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://discord.gg/Eh8ga7z55") end)
    Notify("RD4X", "Link do Discord copiado!", 3)
end)

local TituloInfo = Instance.new("TextLabel", infoContent)
TituloInfo.Size = UDim2.new(1, -4, 0, 20)
TituloInfo.BackgroundTransparency = 1
TituloInfo.Text = "ⓘ  Informações"
TituloInfo.TextColor3 = COR_TEXTO
TituloInfo.TextSize = 13
TituloInfo.Font = Enum.Font.GothamBold
TituloInfo.TextXAlignment = Enum.TextXAlignment.Left

local CardHexagon = Instance.new("Frame", infoContent)
CardHexagon.Size = UDim2.new(1, -4, 0, 58)
CardHexagon.BackgroundColor3 = COR_SECUNDARIA
CardHexagon.BackgroundTransparency = TRANSP_CARDS
CardHexagon.BorderSizePixel = 0
CardHexagon.ZIndex = 6

local cCH = Instance.new("UICorner", CardHexagon)
cCH.CornerRadius = UDim.new(0, 6)

local padCH = Instance.new("UIPadding", CardHexagon)
padCH.PaddingTop = UDim.new(0, 6)
padCH.PaddingLeft = UDim.new(0, 8)
padCH.PaddingRight = UDim.new(0, 8)

local TitleHex = Instance.new("TextLabel", CardHexagon)
TitleHex.Size = UDim2.new(1, -10, 0, 16)
TitleHex.BackgroundTransparency = 1
TitleHex.Text = "Rd4X Hub for Brookhaven 🏡RP"
TitleHex.TextColor3 = COR_TEXTO
TitleHex.TextSize = 11
TitleHex.Font = Enum.Font.GothamBold
TitleHex.TextXAlignment = Enum.TextXAlignment.Left
TitleHex.ZIndex = 7

local DescHex = Instance.new("TextLabel", CardHexagon)
DescHex.Size = UDim2.new(1, -10, 0, 32)
DescHex.Position = UDim2.new(0, 0, 0, 18)
DescHex.BackgroundTransparency = 1
DescHex.Text = "Rd4X, Multilingual and multifunctional Client, offering a variety of options for you ^<^1>^."
DescHex.TextColor3 = COR_TEXTO_CINZA
DescHex.TextSize = 9
DescHex.Font = Enum.Font.Gotham
DescHex.TextXAlignment = Enum.TextXAlignment.Left
DescHex.TextYAlignment = Enum.TextYAlignment.Top
DescHex.TextWrapped = true
DescHex.ZIndex = 7

local CardRelease = Instance.new("Frame", infoContent)
CardRelease.Size = UDim2.new(1, -4, 0, 118)
CardRelease.BackgroundColor3 = COR_SECUNDARIA
CardRelease.BackgroundTransparency = TRANSP_CARDS
CardRelease.BorderSizePixel = 0
CardRelease.ZIndex = 6

local cCR = Instance.new("UICorner", CardRelease)
cCR.CornerRadius = UDim.new(0, 6)

local padCR = Instance.new("UIPadding", CardRelease)
padCR.PaddingTop = UDim.new(0, 6)
padCR.PaddingLeft = UDim.new(0, 8)
padCR.PaddingRight = UDim.new(0, 8)

local TitleRelease = Instance.new("TextLabel", CardRelease)
TitleRelease.Size = UDim2.new(1, -10, 0, 16)
TitleRelease.BackgroundTransparency = 1
TitleRelease.Text = "New Release (🔥 Mistake Upd. V):"
TitleRelease.TextColor3 = COR_TEXTO
TitleRelease.TextSize = 11
TitleRelease.Font = Enum.Font.GothamBold
TitleRelease.TextXAlignment = Enum.TextXAlignment.Left
TitleRelease.ZIndex = 7

local DescRelease = Instance.new("TextLabel", CardRelease)
DescRelease.Size = UDim2.new(1, -10, 0, 94)
DescRelease.Position = UDim2.new(0, 0, 0, 20)
DescRelease.BackgroundTransparency = 1
DescRelease.Text = "News: Improved performance, Anti-Fling aprimorado, Fly gui, Fly car, Ban & Kick System, Cam Player, Backrooms, Ragdoll, Sentar na cabeça, Troll Giro, Anti-Lag, Noclip, ESP, Proteções e muito mais."
DescRelease.TextColor3 = COR_TEXTO_CINZA
DescRelease.TextSize = 9
DescRelease.Font = Enum.Font.Gotham
DescRelease.TextXAlignment = Enum.TextXAlignment.Left
DescRelease.TextYAlignment = Enum.TextYAlignment.Top
DescRelease.TextWrapped = true
DescRelease.ZIndex = 7

local CardInfo2 = Instance.new("Frame", infoContent)
CardInfo2.Size = UDim2.new(1, -4, 0, 58)
CardInfo2.BackgroundColor3 = COR_SECUNDARIA
CardInfo2.BackgroundTransparency = TRANSP_CARDS
CardInfo2.BorderSizePixel = 0
CardInfo2.ZIndex = 6

local cCI2 = Instance.new("UICorner", CardInfo2)
cCI2.CornerRadius = UDim.new(0, 6)

local padCI2 = Instance.new("UIPadding", CardInfo2)
padCI2.PaddingTop = UDim.new(0, 6)
padCI2.PaddingLeft = UDim.new(0, 8)
padCI2.PaddingRight = UDim.new(0, 8)

local TitleCI2 = Instance.new("TextLabel", CardInfo2)
TitleCI2.Size = UDim2.new(1, -10, 0, 16)
TitleCI2.BackgroundTransparency = 1
TitleCI2.Text = "Informações:"
TitleCI2.TextColor3 = COR_TEXTO
TitleCI2.TextSize = 11
TitleCI2.Font = Enum.Font.GothamBold
TitleCI2.TextXAlignment = Enum.TextXAlignment.Left
TitleCI2.ZIndex = 7

local DescCI2 = Instance.new("TextLabel", CardInfo2)
DescCI2.Size = UDim2.new(1, -10, 0, 32)
DescCI2.Position = UDim2.new(0, 0, 0, 18)
DescCI2.BackgroundTransparency = 1
DescCI2.Text = "Owner/Dev: J. Epstein\nColabs: Rd4X Team Oficial"
DescCI2.TextColor3 = COR_TEXTO_CINZA
DescCI2.TextSize = 9
DescCI2.Font = Enum.Font.Gotham
DescCI2.TextXAlignment = Enum.TextXAlignment.Left
DescCI2.TextYAlignment = Enum.TextYAlignment.Top
DescCI2.TextWrapped = true
DescCI2.ZIndex = 7

local BotaoReconectar = Instance.new("TextButton", infoContent)
BotaoReconectar.Size = UDim2.new(1, -4, 0, 34)
BotaoReconectar.BackgroundColor3 = COR_SECUNDARIA
BotaoReconectar.BackgroundTransparency = TRANSP_CARDS
BotaoReconectar.BorderSizePixel = 0
BotaoReconectar.Text = "                        Reconectar                          ›"
BotaoReconectar.TextColor3 = COR_TEXTO
BotaoReconectar.TextSize = 11
BotaoReconectar.Font = Enum.Font.GothamBold
BotaoReconectar.TextXAlignment = Enum.TextXAlignment.Left
BotaoReconectar.AutoButtonColor = false
BotaoReconectar.ZIndex = 6

local cBR = Instance.new("UICorner", BotaoReconectar)
cBR.CornerRadius = UDim.new(0, 6)

BotaoReconectar.MouseEnter:Connect(function()
    TweenService:Create(BotaoReconectar, TweenInfo.new(0.15), {BackgroundTransparency = 0.25}):Play()
end)
BotaoReconectar.MouseLeave:Connect(function()
    TweenService:Create(BotaoReconectar, TweenInfo.new(0.15), {BackgroundTransparency = TRANSP_CARDS}):Play()
end)
BotaoReconectar.MouseButton1Click:Connect(function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

--------------------------------------------------------------------------------
-- ABA ADMIN
--------------------------------------------------------------------------------
if not UsuarioAutorizado then
    UI.Paragraph(Tabs.Admin, { Title = "⚠️ Acesso Negado", Content = "Você não está na Whitelist desta API! As funções de Admin estão bloqueadas.", Height = 48 })
else
    local AlvoSelecionado = LocalPlayer.Name
    local JaulaModelo = nil
    local conexaoSpam = nil
    local chatPlayerTextoInput = ""

    local function obterUsuariosDoHub()
        local lista = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p.UserId == MEU_ID_CREATOR then
                table.insert(lista, p.Name)
            else
                local ok, res = pcall(function()
                    local r = game:HttpGet(API_URL .. "/api/v2/whitelist?nick=" .. tostring(p.Name))
                    return HttpService:JSONDecode(r)
                end)
                if ok and res and (res.success == true or res.whitelisted == true) then
                    table.insert(lista, p.Name)
                end
            end
        end
        if #lista == 0 then table.insert(lista, LocalPlayer.Name) end
        return lista
    end

    local DropdownAdmin = UI.Dropdown(Tabs.Admin, {
        Name = "Lista de Usuários do Hub",
        Options = obterUsuariosDoHub(),
        CurrentOption = {LocalPlayer.Name},
        Callback = function(Option) AlvoSelecionado = Option[1] end,
    })

    UI.Button(Tabs.Admin, { Name = "🔄 Atualizar Hub (Lista)", Callback = function()
        DropdownAdmin:Refresh(obterUsuariosDoHub())
        Notify("Admin", "Lista atualizada!", 3)
    end})

    local cameraOriginalCFrame = nil

    UI.Button(Tabs.Admin, { Name = "Cam (ver câmera)", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("Head") then
            cameraOriginalCFrame = Camera.CFrame
            Camera.CameraSubject = alvo.Character.Humanoid
            Notify("Admin", "Assistindo " .. alvo.Name, 2)
        end
    end})

    UI.Button(Tabs.Admin, { Name = "Voltar Cam", Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
            if cameraOriginalCFrame then Camera.CFrame = cameraOriginalCFrame end
            Notify("Admin", "Câmera restaurada.", 2)
        end
    end})

    UI.Button(Tabs.Admin, { Name = "Kick", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo == LocalPlayer then LocalPlayer:Kick("Kickado") end
        Notify("Admin", "Kick enviado.", 2)
    end})

    UI.Button(Tabs.Admin, { Name = "Desconectar", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo then
            pcall(function()
                if alvo == LocalPlayer then
                    LocalPlayer:Kick("Desconectado pelo RD4X Hub")
                else
                    for i = 1, 100 do
                        task.spawn(function()
                            local s = Instance.new("RemoteEvent", ReplicatedStorage)
                            s:FireServer(string.rep("a", 999999))
                        end)
                    end
                end
            end)
            Notify("Admin", "Desconectado.", 2)
        end
    end})

    UI.Button(Tabs.Admin, { Name = "Kick Personalizado", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo and alvo == LocalPlayer then
            LocalPlayer:Kick("Você foi banido permanentemente por um Administrador.\nTempo : 34 dias")
        end
        Notify("Admin", "Kick personalizado acionado.", 3)
    end})

    UI.Button(Tabs.Admin, { Name = "Crash", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo == LocalPlayer then while true do end end
        Notify("Admin", "Crash acionado.", 2)
    end})

    UI.Button(Tabs.Admin, { Name = "Kill", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("Humanoid") then
            alvo.Character.Humanoid.Health = 0
            Notify("Admin", "Kill executado.", 2)
        end
    end})

    UI.Button(Tabs.Admin, { Name = "Kill plus", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = alvo.Character.HumanoidRootPart
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 150, 0)
            task.wait(0.2)
            alvo.Character.Humanoid.Health = 0
            Notify("Admin", "Kill Plus executado!", 2)
        end
    end})

    UI.Button(Tabs.Admin, { Name = "Explode", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") then
            local p = Instance.new("Explosion", Workspace)
            p.Position = alvo.Character.HumanoidRootPart.Position
            Notify("Admin", "Explosão enviada!", 2)
        end
    end})

    UI.Button(Tabs.Admin, { Name = "Freeze", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") then
            alvo.Character.HumanoidRootPart.Anchored = true
            Notify("Admin", "Congelado.", 2)
        end
    end})

    UI.Button(Tabs.Admin, { Name = "Unfreeze", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") then
            alvo.Character.HumanoidRootPart.Anchored = false
            Notify("Admin", "Descongelado.", 2)
        end
    end})

    UI.Button(Tabs.Admin, { Name = "Jail", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") then
            if JaulaModelo then JaulaModelo:Destroy() end
            JaulaModelo = Instance.new("Model", Workspace)
            JaulaModelo.Name = "RD4X_JailBox"
            local pos = alvo.Character.HumanoidRootPart.Position
            local function criarParede(tam, pst)
                local p = Instance.new("Part", JaulaModelo)
                p.Size = tam; p.Position = pst; p.Anchored = true
                p.CanCollide = true; p.Transparency = 0.4; p.Color = COR_VERMELHO
            end
            criarParede(Vector3.new(8, 1, 8), pos + Vector3.new(0, -4, 0))
            criarParede(Vector3.new(8, 1, 8), pos + Vector3.new(0, 4, 0))
            criarParede(Vector3.new(8, 8, 1), pos + Vector3.new(0, 0, -4))
            criarParede(Vector3.new(8, 8, 1), pos + Vector3.new(0, 0, 4))
            criarParede(Vector3.new(1, 8, 8), pos + Vector3.new(-4, 0, 0))
            criarParede(Vector3.new(1, 8, 8), pos + Vector3.new(4, 0, 0))
            Notify("Admin", "Jaula aplicada!", 2)
        end
    end})

    UI.Button(Tabs.Admin, { Name = "UnJail", Callback = function()
        if JaulaModelo then JaulaModelo:Destroy(); JaulaModelo = nil end
        Notify("Admin", "Jaula removida!", 2)
    end})

    UI.Button(Tabs.Admin, { Name = "Teleport", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = alvo.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            Notify("Admin", "Teleportado.", 2)
        end
    end})

    UI.Button(Tabs.Admin, { Name = "Bring", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            alvo.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            Notify("Admin", "Jogador trazido.", 2)
        end
    end})

    UI.Button(Tabs.Admin, { Name = "Fling", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") then
            alvo.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999)
            Notify("Admin", "Fling aplicado!", 2)
        end
    end})

    UI.Button(Tabs.Admin, { Name = "Spam", Callback = function()
        if conexaoSpam then task.cancel(conexaoSpam) end
        conexaoSpam = task.spawn(function()
            while true do
                pcall(function()
                    local targs = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                    if targs then
                        local say = targs:FindFirstChild("SayMessageRequest")
                        if say then say:FireServer("RD4X HAHAHA", "All") end
                    end
                end)
                task.wait(1)
            end
        end)
        Notify("Admin", "Spam ativado!", 2)
    end})

    UI.Button(Tabs.Admin, { Name = "UnSpam", Callback = function()
        if conexaoSpam then task.cancel(conexaoSpam); conexaoSpam = nil end
        Notify("Admin", "Spam desativado.", 2)
    end})

    UI.Input(Tabs.Admin, {
        Name = "Chat player (Texto)",
        CurrentValue = "",
        PlaceholderText = "Escreva...",
        Callback = function(txt) chatPlayerTextoInput = txt end,
    })

    UI.Button(Tabs.Admin, { Name = "Enviar Chat no Alvo", Callback = function()
        pcall(function()
            local targs = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if targs and chatPlayerTextoInput ~= "" then
                local say = targs:FindFirstChild("SayMessageRequest")
                if say then say:FireServer(chatPlayerTextoInput, "All") end
            end
        end)
        Notify("Admin", "Mensagem enviada!", 2)
    end})
end

--------------------------------------------------------------------------------
-- ABA VIP
--------------------------------------------------------------------------------
if not UsuarioAutorizado then
    UI.Paragraph(Tabs.Vip, { Title = "⚠️ Acesso Negado", Content = "Você não está na Whitelist desta API! As funções VIP estão bloqueadas.", Height = 48 })
else
    local function obterUsuariosDoHubVip()
        local lista = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p.UserId == MEU_ID_CREATOR then
                table.insert(lista, p.Name)
            else
                local ok, res = pcall(function()
                    local r = game:HttpGet(API_URL .. "/api/v2/whitelist?nick=" .. tostring(p.Name))
                    return HttpService:JSONDecode(r)
                end)
                if ok and res and (res.success == true or res.whitelisted == true) then
                    table.insert(lista, p.Name)
                end
            end
        end
        if #lista == 0 then table.insert(lista, LocalPlayer.Name) end
        return lista
    end

    local alvoVipSelecionado = LocalPlayer.Name
    local backroomsModelo = nil
    local cameraOriginalCFrame = nil
    local avisoInputTexto = ""

    local function alternarMenuAlvo(alvoPlr, esconder)
        if alvoPlr.UserId == MEU_ID_CREATOR then return end
        pcall(function()
            local pGui = alvoPlr:FindFirstChild("PlayerGui")
            if pGui then
                for _, gui in ipairs(pGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Name ~= "RD4X_Backrooms_Safe" then
                        gui.Enabled = not esconder
                    end
                end
            end
        end)
    end

    local dropdownVip = UI.Dropdown(Tabs.Vip, {
        Name = "Lista de Usuários do Hub",
        Options = obterUsuariosDoHubVip(),
        CurrentOption = {LocalPlayer.Name},
        Callback = function(Option) alvoVipSelecionado = Option[1] end,
    })

    UI.Button(Tabs.Vip, { Name = "🔄 Atualizar lista", Callback = function()
        dropdownVip:Refresh(obterUsuariosDoHubVip())
        Notify("VIP", "Lista atualizada!", 2)
    end})

    UI.Button(Tabs.Vip, { Name = "Cam (ver câmera)", Callback = function()
        local alvo = Players:FindFirstChild(alvoVipSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("Head") then
            cameraOriginalCFrame = Camera.CFrame
            Camera.CameraSubject = alvo.Character.Humanoid
            Notify("VIP", "Assistindo " .. alvo.Name, 2)
        end
    end})

    UI.Button(Tabs.Vip, { Name = "Voltar Cam", Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
            if cameraOriginalCFrame then Camera.CFrame = cameraOriginalCFrame end
            Notify("VIP", "Câmera restaurada.", 2)
        end
    end})

    UI.Button(Tabs.Vip, { Name = "Backrooms", Callback = function()
        local alvo = Players:FindFirstChild(alvoVipSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") then
            if not backroomsModelo or not backroomsModelo.Parent then
                backroomsModelo = Instance.new("Model", Workspace)
                backroomsModelo.Name = "RD4X_Backrooms_Safe"
                local piso = Instance.new("Part", backroomsModelo)
                piso.Size = Vector3.new(200, 1, 200)
                piso.Position = Vector3.new(50000, -500, 50000)
                piso.Anchored = true
            end
            alvo.Character.HumanoidRootPart.CFrame = CFrame.new(50000, -490, 50000)
            alternarMenuAlvo(alvo, true)
            Notify("Backrooms", "Jogador enviado!", 2)
        end
    end})

    UI.Button(Tabs.Vip, { Name = "Tirar Backrooms", Callback = function()
        local alvo = Players:FindFirstChild(alvoVipSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") then
            alvo.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
            alternarMenuAlvo(alvo, false)
            Notify("Backrooms", "Jogador retirado!", 2)
        end
    end})

    UI.Button(Tabs.Vip, { Name = "Ragdoll", Callback = function()
        local alvo = Players:FindFirstChild(alvoVipSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("Humanoid") then
            pcall(function() alvo.Character.Humanoid.PlatformStand = true end)
            Notify("VIP", "Ragdoll aplicado.", 2)
        end
    end})

    UI.Button(Tabs.Vip, { Name = "UnRagdoll", Callback = function()
        local alvo = Players:FindFirstChild(alvoVipSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("Humanoid") then
            pcall(function() alvo.Character.Humanoid.PlatformStand = false end)
            Notify("VIP", "UnRagdoll aplicado.", 2)
        end
    end})

    UI.Button(Tabs.Vip, { Name = "Sniper", Callback = function()
        local alvo = Players:FindFirstChild(alvoVipSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("Head") then
            pcall(function()
                local som = Instance.new("Sound", SoundService)
                som.SoundId = "rbxassetid://130113146"
                som.Volume = 2
                som:Play()
            end)
            task.delay(3, function()
                pcall(function()
                    if alvo and alvo.Character and alvo.Character:FindFirstChild("Humanoid") then
                        alvo.Character.Humanoid.Health = 0
                    end
                end)
            end)
            Notify("Sniper", "Alvo morre em 3s!", 3)
        end
    end})

    UI.Button(Tabs.Vip, { Name = "Truck", Callback = function()
        local alvo = Players:FindFirstChild(alvoVipSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local hrp = alvo.Character.HumanoidRootPart
                local truck = Instance.new("Part", Workspace)
                truck.Size = Vector3.new(10, 12, 30)
                truck.CFrame = hrp.CFrame + Vector3.new(0, 5, 25)
                truck.Anchored = false
                truck.CanCollide = true
                local mesh = Instance.new("SpecialMesh", truck)
                mesh.MeshId = "rbxassetid://4761406859"
                mesh.TextureId = "rbxassetid://4761406981"
                local somBuzina = Instance.new("Sound", truck)
                somBuzina.SoundId = "rbxassetid://9061413813"
                somBuzina.Volume = 3
                local somGrito = Instance.new("Sound", truck)
                somGrito.SoundId = "rbxassetid://9069609268"
                somGrito.Volume = 3
                somBuzina:Play()
                task.wait(0.5)
                somGrito:Play()
                truck.Velocity = (hrp.Position - truck.Position).Unit * 60
                task.wait(1.5)
                if alvo.Character and alvo.Character:FindFirstChild("Humanoid") then
                    alvo.Character.Humanoid.Health = 0
                end
                truck:Destroy()
            end)
            Notify("Truck", "Caminhão ativado!", 3)
        end
    end})

    UI.Input(Tabs.Vip, {
        Name = "Texto do Aviso",
        CurrentValue = "",
        PlaceholderText = "Digite...",
        Callback = function(t) avisoInputTexto = t end,
    })

    UI.Button(Tabs.Vip, { Name = "Aviso (Enviar na tela do player)", Callback = function()
        local alvo = Players:FindFirstChild(alvoVipSelecionado)
        if alvo and avisoInputTexto ~= "" then
            pcall(function()
                local sg = Instance.new("ScreenGui", alvo:FindFirstChild("PlayerGui"))
                sg.Name = "RD4X_WarningPopup"
                local fr = Instance.new("Frame", sg)
                fr.Size = UDim2.new(0, 400, 0, 150)
                fr.Position = UDim2.new(0.5, -200, 0.5, -75)
                fr.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                local tx = Instance.new("TextLabel", fr)
                tx.Size = UDim2.new(1, 0, 1, 0)
                tx.BackgroundTransparency = 1
                tx.TextColor3 = Color3.fromRGB(255, 50, 50)
                tx.TextSize = 20
                tx.TextWrapped = true
                tx.Text = "AVISO DO ADMIN:\n\n" .. avisoInputTexto
            end)
            Notify("VIP", "Aviso enviado!", 2)
        end
    end})
end

--------------------------------------------------------------------------------
-- ABA PLAYER
--------------------------------------------------------------------------------
local valorSpeedInput, valorJumpInput = 16, 50

UI.Input(Tabs.Player, { Name = "Selecione Speed", CurrentValue = "16", PlaceholderText = "Velocidade...", Callback = function(v) valorSpeedInput = tonumber(v) or 16 end })
UI.Button(Tabs.Player, { Name = "Definir Speed", Callback = function()
    pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = valorSpeedInput end)
    Notify("Player", "Speed: " .. valorSpeedInput, 2)
end})

UI.Input(Tabs.Player, { Name = "Selecione Jump", CurrentValue = "50", PlaceholderText = "Pulo...", Callback = function(v) valorJumpInput = tonumber(v) or 50 end })
UI.Button(Tabs.Player, { Name = "Definir Jump", Callback = function()
    pcall(function() LocalPlayer.Character.Humanoid.JumpPower = valorJumpInput end)
    Notify("Player", "Jump: " .. valorJumpInput, 2)
end})

UI.Button(Tabs.Player, { Name = "Reset Personagem", Callback = function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end})

--------------------------------------------------------------------------------
-- ABA SERVIDOR
--------------------------------------------------------------------------------
local listaJogadoresServidor = {LocalPlayer.Name}
for _, p in ipairs(Players:GetPlayers()) do
    if p.Name ~= LocalPlayer.Name then table.insert(listaJogadoresServidor, p.Name) end
end
local alvoServidorSelecionado = LocalPlayer.Name
local conexaoSentarCabeca = nil
local camOriginalServidor = nil

local dropdownServidorList = UI.Dropdown(Tabs.Servidor, {
    Name = "Lista de Jogadores",
    Options = listaJogadoresServidor,
    CurrentOption = {LocalPlayer.Name},
    Callback = function(Option) alvoServidorSelecionado = Option[1] end,
})

UI.Button(Tabs.Servidor, { Name = "🔄 Atualizar Lista", Callback = function()
    local novaLista = {}
    for _, p in ipairs(Players:GetPlayers()) do table.insert(novaLista, p.Name) end
    listaJogadoresServidor = novaLista
    dropdownServidorList:Refresh(listaJogadoresServidor)
    Notify("Servidor", "Lista atualizada!", 2)
end})

UI.Button(Tabs.Servidor, { Name = "👁️ Ver Câmera", Callback = function()
    local alvo = Players:FindFirstChild(alvoServidorSelecionado)
    if alvo and alvo.Character and alvo.Character:FindFirstChild("Head") then
        camOriginalServidor = Camera.CFrame
        Camera.CameraSubject = alvo.Character.Humanoid
        Notify("Servidor", "Assistindo " .. alvo.Name, 2)
    end
end})

UI.Button(Tabs.Servidor, { Name = "↩️ Voltar Câmera", Callback = function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        Camera.CameraSubject = LocalPlayer.Character.Humanoid
        if camOriginalServidor then Camera.CFrame = camOriginalServidor end
        Notify("Servidor", "Restaurada.", 2)
    end
end})

UI.Button(Tabs.Servidor, { Name = "📍 Teleportar para Jogador", Callback = function()
    local alvo = Players:FindFirstChild(alvoServidorSelecionado)
    if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = alvo.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        Notify("Servidor", "Teleportado!", 2)
    end
end})

UI.Button(Tabs.Servidor, { Name = "Sentar na cabeça", Callback = function()
    local alvo = Players:FindFirstChild(alvoServidorSelecionado)
    if alvo and alvo.Character and alvo.Character:FindFirstChild("Head") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if conexaoSentarCabeca then conexaoSentarCabeca:Disconnect() end
        conexaoSentarCabeca = RunService.Stepped:Connect(function()
            pcall(function()
                if alvo and alvo.Character and alvo.Character:FindFirstChild("Head") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = alvo.Character.Head.CFrame + Vector3.new(0, 1.5, 0)
                    LocalPlayer.Character.Humanoid.Sit = true
                end
            end)
        end)
        Notify("Servidor", "Sentado na cabeça!", 2)
    end
end})

UI.Button(Tabs.Servidor, { Name = "Sair da cabeça", Callback = function()
    if conexaoSentarCabeca then conexaoSentarCabeca:Disconnect(); conexaoSentarCabeca = nil end
    pcall(function() LocalPlayer.Character.Humanoid.Sit = false end)
    Notify("Servidor", "Saiu da cabeça.", 2)
end})

UI.Button(Tabs.Servidor, { Name = "🚪 Sair do Servidor", Callback = function()
    LocalPlayer:Kick("Você saiu do servidor usando o RD4X Hub.")
end})
UI.Button(Tabs.Servidor, {
    Name = "🎯 Menu rápido TP",
    Callback = function()
        local menu = Instance.new("Frame", ScreenGui)
        menu.Size = UDim2.new(0, 220, 0, 300)
        menu.Position = UDim2.new(0.5, -110, 0.5, -150)
        menu.BackgroundColor3 = COR_SECUNDARIA
        menu.BackgroundTransparency = 0.1
        menu.BorderSizePixel = 0
        menu.ZIndex = 2000

        local cM = Instance.new("UICorner", menu)
        cM.CornerRadius = UDim.new(0, 8)

        local titulo = Instance.new("TextLabel", menu)
        titulo.Size = UDim2.new(1, 0, 0, 30)
        titulo.BackgroundTransparency = 1
        titulo.Text = "🎯 Teleportar para..."
        titulo.TextColor3 = COR_TEXTO
        titulo.TextSize = 12
        titulo.Font = Enum.Font.GothamBold
        titulo.ZIndex = 2001

        local scroll = Instance.new("ScrollingFrame", menu)
        scroll.Size = UDim2.new(1, -10, 1, -40)
        scroll.Position = UDim2.new(0, 5, 0, 35)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 2
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.ZIndex = 2001

        local layout = Instance.new("UIListLayout", scroll)
        layout.Padding = UDim.new(0, 4)

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local b = Instance.new("TextButton", scroll)
                b.Size = UDim2.new(1, -4, 0, 26)
                b.BackgroundColor3 = COR_FUNDO
                b.BackgroundTransparency = 0.3
                b.BorderSizePixel = 0
                b.Text = p.Name
                b.TextColor3 = COR_TEXTO
                b.TextSize = 10
                b.Font = Enum.Font.Gotham
                b.ZIndex = 2002

                local cB = Instance.new("UICorner", b)
                cB.CornerRadius = UDim.new(0, 6)

                b.MouseButton1Click:Connect(function()
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                    end
                    menu:Destroy()
                end)
            end
        end

        local x = Instance.new("TextButton", menu)
        x.Size = UDim2.new(0, 20, 0, 20)
        x.Position = UDim2.new(1, -24, 0, 5)
        x.BackgroundTransparency = 1
        x.Text = "✕"
        x.TextColor3 = COR_VERMELHO
        x.TextSize = 12
        x.Font = Enum.Font.GothamBold
        x.ZIndex = 2002
        x.MouseButton1Click:Connect(function() menu:Destroy() end)
    end
})
local waypoints = {}

UI.Button(Tabs.Servidor, {
    Name = "📍 Salvar local atual",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = LocalPlayer.Character.HumanoidRootPart.CFrame
            table.insert(waypoints, {nome = "Local " .. #waypoints + 1, pos = pos})
            Notify("Waypoint", "Salvo local " .. #waypoints, 2)
        end
    end
})

UI.Button(Tabs.Servidor, {
    Name = "📍 Voltar ao último waypoint",
    Callback = function()
        if #waypoints > 0 then
            local wp = waypoints[#waypoints]
            LocalPlayer.Character.HumanoidRootPart.CFrame = wp.pos
            Notify("Waypoint", "Voltou: " .. wp.nome, 2)
        end
    end
})

UI.Button(Tabs.Servidor, {
    Name = "📍 Limpar waypoints",
    Callback = function()
        waypoints = {}
        Notify("Waypoint", "Limpos!", 2)
    end
})
--------------------------------------------------------------------------------
-- ABA CARROS
--------------------------------------------------------------------------------
local velocidadeCarroInput, forcaArrancadaInput = 50, 100

UI.Input(Tabs.Carros, { Name = "Velocidade do Carro", CurrentValue = "50", PlaceholderText = "Velocidade...", Callback = function(v) velocidadeCarroInput = tonumber(v) or 50 end })
UI.Button(Tabs.Carros, { Name = "Inserir Velocidade", Callback = function()
    pcall(function() LocalPlayer.Character.Humanoid.SeatPart.MaxSpeed = velocidadeCarroInput end)
    Notify("Carros", "Velocidade aplicada!", 3)
end})

UI.Input(Tabs.Carros, { Name = "Força de Arrancada", CurrentValue = "100", PlaceholderText = "Força...", Callback = function(v) forcaArrancadaInput = tonumber(v) or 100 end })
UI.Button(Tabs.Carros, { Name = "Definir Arrancada", Callback = function()
    pcall(function() LocalPlayer.Character.Humanoid.SeatPart.Torque = forcaArrancadaInput end)
    Notify("Carros", "Arrancada aplicada!", 3)
end})

UI.Button(Tabs.Carros, { Name = "Carros Bloqueados (Dirigir qualquer)", Callback = function()
    pcall(function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("VehicleSeat") then v.Disabled = false; v.Locked = false end
        end
    end)
    Notify("Carros", "Desbloqueados!", 3)
end})

UI.Button(Tabs.Carros, { Name = "Fly Car", Callback = function()
    Notify("Carros", "Carregando Fly Car...", 2)
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/willthingVN/script-lua/refs/heads/main/Vehicle%20Fly%20Gui.lua"))()
        end)
    end)
end})

--------------------------------------------------------------------------------
-- ABA CASAS
--------------------------------------------------------------------------------
local listaCasasServidor = {}
for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj.Name:lower():find("house") or obj.Name:lower():find("casa") then
        table.insert(listaCasasServidor, obj.Name)
    end
end
if #listaCasasServidor == 0 then table.insert(listaCasasServidor, "Nenhuma casa encontrada") end
local casaSelecionadaInput = listaCasasServidor[1]

UI.Button(Tabs.Casas, { Name = "Tp cofre mais próximo", Callback = function()
    pcall(function()
        local raiz = LocalPlayer.Character.HumanoidRootPart
        local menorDistancia = math.huge
        local cofreAlvo = nil
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if (obj.Name:lower():find("safe") or obj.Name:lower():find("cofre")) and (obj:IsA("BasePart") or obj:IsA("Model")) then
                local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                local dist = (raiz.Position - pos).Magnitude
                if dist < menorDistancia then menorDistancia = dist; cofreAlvo = obj end
            end
        end
        if cofreAlvo then
            raiz.CFrame = (cofreAlvo:IsA("Model") and cofreAlvo:GetPivot() or cofreAlvo.CFrame) + Vector3.new(0, 3, 0)
            Notify("Casas", "TP para o cofre!", 3)
        else
            Notify("Casas", "Nenhum cofre perto.", 3)
        end
    end)
end})

UI.Dropdown(Tabs.Casas, { Name = "Lista de casas", Options = listaCasasServidor, CurrentOption = {listaCasasServidor[1]}, Callback = function(Opt) casaSelecionadaInput = Opt[1] end })

UI.Button(Tabs.Casas, { Name = "Tp casa selecionada", Callback = function()
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == casaSelecionadaInput then
                local pos = obj:IsA("Model") and obj:GetPivot() or obj.CFrame
                LocalPlayer.Character.HumanoidRootPart.CFrame = pos + Vector3.new(0, 3, 0)
                Notify("Casas", "Teleportado!", 2)
                return
            end
        end
    end)
end})

UI.Button(Tabs.Casas, { Name = "Anti-Ban", Callback = function()
    pcall(function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name:lower():find("ban") or v.Name:lower():find("kickhouse") then v:Destroy() end
        end
    end)
    Notify("Casas", "Anti-Ban ativado!", 2)
end})

UI.Button(Tabs.Casas, { Name = "Desbanir auto", Callback = function()
    pcall(function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name:lower():find("ban") or v.Name:lower():find("kickhouse") or v.Name:lower():find("owner") then v:Destroy() end
        end
    end)
    Notify("Casas", "Desbanido de todas as casas!", 2)
end})

--------------------------------------------------------------------------------
-- ABA MÚSICAS
--------------------------------------------------------------------------------
local idMusicaDigitado = ""

local function tocarMusicaNaBoombox(id)
    pcall(function()
        local character = LocalPlayer.Character
        local backpack = LocalPlayer.Backpack
        local boombox = nil
        if character then boombox = character:FindFirstChild("Boombox") or character:FindFirstChildOfClass("Tool") end
        if not boombox and backpack then boombox = backpack:FindFirstChild("Boombox") or backpack:FindFirstChildOfClass("Tool") end
        if boombox then
            if boombox.Parent == backpack then boombox.Parent = character task.wait(0.1) end
            local RE = ReplicatedStorage:FindFirstChild("RE")
            local boomboxRemote = RE and (RE:FindFirstChild("1Boombox1") or RE:FindFirstChild("Boombox"))
            if boomboxRemote then
                boomboxRemote:FireServer(tonumber(id) or id)
                Notify("Músicas", "Tocando ID: " .. tostring(id), 2)
            end
        else
            Notify("Atenção", "Equipe a boombox!", 3)
        end
    end)
end

UI.Input(Tabs.Musicas, { Name = "Digite o ID", CurrentValue = "", PlaceholderText = "Cole o ID...", Callback = function(id) idMusicaDigitado = id end })
UI.Button(Tabs.Musicas, { Name = "Tocar música", Callback = function()
    if idMusicaDigitado ~= "" then tocarMusicaNaBoombox(idMusicaDigitado) end
end})

local listaMusicasPadrao = {
    {Name = "🎵 Phonk 1", ID = "1849767232"},
    {Name = "🎵 Phonk 2", ID = "1424177890"},
    {Name = "🎵 Funk 1", ID = "9047119231"},
    {Name = "🎵 Funk 2", ID = "1423760458"},
    {Name = "🎵 Hit Viral", ID = "1838927190"}
}

for _, mus in ipairs(listaMusicasPadrao) do
    UI.Button(Tabs.Musicas, { Name = mus.Name, Callback = function() tocarMusicaNaBoombox(mus.ID) end })
end

UI.Button(Tabs.Musicas, { Name = "Parar música", Callback = function()
    pcall(function()
        local RE = ReplicatedStorage:FindFirstChild("RE")
        local boomboxRemote = RE and (RE:FindFirstChild("1Boombox1") or RE:FindFirstChild("Boombox"))
        if boomboxRemote then boomboxRemote:FireServer(0) end
    end)
    Notify("Músicas", "Música parada!", 2)
end})

--------------------------------------------------------------------------------
-- ABA TROLL
--------------------------------------------------------------------------------
local listaNomesTroll = {LocalPlayer.Name}
for _, p in ipairs(Players:GetPlayers()) do
    if p.Name ~= LocalPlayer.Name then table.insert(listaNomesTroll, p.Name) end
end
local alvoTrollSelecionado = LocalPlayer.Name
local velocidadeGiroInput = 50
local giroAtivoAlvo = false
local conexaoGiro = nil

local dropdownTrollList = UI.Dropdown(Tabs.Troll, { Name = "Lista de Alvos", Options = listaNomesTroll, CurrentOption = {LocalPlayer.Name}, Callback = function(Option) alvoTrollSelecionado = Option[1] end })

UI.Button(Tabs.Troll, { Name = "🔄 Atualizar Lista de Alvos", Callback = function()
    local lista = {}
    for _, p in ipairs(Players:GetPlayers()) do table.insert(lista, p.Name) end
    dropdownTrollList:Refresh(lista)
    Notify("Troll", "Lista atualizada!", 2)
end})

UI.Input(Tabs.Troll, { Name = "Velocidade do Giro", CurrentValue = "50", PlaceholderText = "Ex: 50, 100...", Callback = function(val) velocidadeGiroInput = tonumber(val) or 50 end })

UI.Button(Tabs.Troll, { Name = "🌀 Ativar Giro Infinito", Callback = function()
    local alvo = Players:FindFirstChild(alvoTrollSelecionado)
    if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") then
        giroAtivoAlvo = true
        if conexaoGiro then conexaoGiro:Disconnect() end
        conexaoGiro = RunService.RenderStepped:Connect(function()
            if not giroAtivoAlvo or not alvo.Character or not alvo.Character:FindFirstChild("HumanoidRootPart") then
                if conexaoGiro then conexaoGiro:Disconnect() end
                return
            end
            local hrp = alvo.Character.HumanoidRootPart
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(velocidadeGiroInput), 0)
        end)
        Notify("Troll", "Giro infinito ativado!", 2)
    end
end})

UI.Button(Tabs.Troll, { Name = "⏹️ Desativar Giro", Callback = function()
    giroAtivoAlvo = false
    if conexaoGiro then conexaoGiro:Disconnect() end
    Notify("Troll", "Giro desativado.", 2)
end})

--------------------------------------------------------------------------------
-- ABA OUTROS
--------------------------------------------------------------------------------
UI.Button(Tabs.Outros, { Name = "⚡ Otimizar Hub (Irreversível)", Callback = function()
    pcall(function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.CastShadow = false; v.Material = Enum.Material.SmoothPlastic end
        end
    end)
    Notify("Outros", "Hub otimizado!", 2)
end})

UI.Button(Tabs.Outros, { Name = "📉 Reduzir Lag (Irreversível)", Callback = function()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") then v:Destroy() end
        end
    end)
    Notify("Outros", "Lag reduzido!", 2)
end})

UI.Button(Tabs.Outros, { Name = "💡 Desativar Brilho (Irreversível)", Callback = function()
    pcall(function()
        Lighting.Brightness = 0
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then v:Destroy() end
        end
    end)
    Notify("Outros", "Brilho desativado!", 2)
end})

UI.Button(Tabs.Outros, { Name = "🌑 Desativar Sombras (Irreversível)", Callback = function()
    Lighting.GlobalShadows = false
    Notify("Outros", "Sombras desativadas!", 2)
end})

UI.Button(Tabs.Outros, { Name = "🌳 Excluir Árvores (Irreversível)", Callback = function()
    pcall(function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and (v.Name:lower():find("tree") or v.Name:lower():find("arvore") or v.Name:lower():find("plant")) then
                v:Destroy()
            elseif v:IsA("BasePart") and (v.Name:lower():find("tree") or v.Name:lower():find("arvore")) then
                v:Destroy()
            end
        end
    end)
    Notify("Outros", "Árvores excluídas!", 2)
end})

UI.Button(Tabs.Outros, { Name = "🎨 Simplificar Gráficos (Irreversível)", Callback = function()
    pcall(function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Color = Color3.fromRGB(150, 150, 150)
            end
        end
    end)
    Notify("Outros", "Gráficos simplificados!", 2)
end})

--------------------------------------------------------------------------------
-- ABA PROTEÇÃO
--------------------------------------------------------------------------------
local antiSitAtivo, antiLagAtivo, antiFlingAtivo, noclipAtivo, espAtivo = false, false, false, false, false

UI.Toggle(Tabs.Protecao, { Name = "Anti-Sit (Impede de sentar)", CurrentValue = false, Callback = function(v) antiSitAtivo = v end })
RunService.Stepped:Connect(function()
    if antiSitAtivo and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Sit = false
    end
end)

UI.Toggle(Tabs.Protecao, { Name = "Anti-Lag (Desativa texturas pesadas)", CurrentValue = false, Callback = function(v)
    antiLagAtivo = v
    if antiLagAtivo then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic end
        end
    end
end})

UI.Toggle(Tabs.Protecao, { Name = "Anti-Fling", CurrentValue = false, Callback = function(v) antiFlingAtivo = v end })
RunService.Stepped:Connect(function()
    if antiFlingAtivo and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end)

UI.Toggle(Tabs.Protecao, { Name = "Noclip (Atravessar paredes)", CurrentValue = false, Callback = function(v) noclipAtivo = v end })
RunService.Stepped:Connect(function()
    if noclipAtivo and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

UI.Toggle(Tabs.Protecao, { Name = "ESP (Ver jogadores)", CurrentValue = false, Callback = function(state)
    espAtivo = state
    if espAtivo then
        task.spawn(function()
            while espAtivo do
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and not p.Character.Head:FindFirstChild("RD4X_ESP") then
                        local bg = Instance.new("BillboardGui", p.Character.Head)
                        bg.Name = "RD4X_ESP"
                        bg.Size = UDim2.new(0, 100, 0, 40)
                        bg.StudsOffset = Vector3.new(0, 3, 0)
                        bg.AlwaysOnTop = true
                        local tl = Instance.new("TextLabel", bg)
                        tl.Size = UDim2.new(1, 0, 1, 0)
                        tl.BackgroundTransparency = 1
                        tl.TextColor3 = COR_VERMELHO
                        tl.TextStrokeTransparency = 0
                        tl.TextSize = 14
                        tl.Text = p.Name
                    end
                end
                task.wait(1)
            end
        end)
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Head") then
                local esp = p.Character.Head:FindFirstChild("RD4X_ESP")
                if esp then esp:Destroy() end
            end
        end
    end
end})

--------------------------------------------------------------------------------
-- ABA SCRIPTS
--------------------------------------------------------------------------------
UI.Button(Tabs.Scripts, { Name = "Rd4X EMOTES", Callback = function() Notify("Scripts", "Aguarde loadstring...", 2) end })
UI.Button(Tabs.Scripts, { Name = "Rd4X Chat", Callback = function() Notify("Scripts", "Aguarde loadstring...", 2) end })
UI.Button(Tabs.Scripts, { Name = "Rd4X Universal", Callback = function() Notify("Scripts", "Aguarde loadstring...", 2) end })

UI.Button(Tabs.Scripts, { Name = "Fly gui", Callback = function()
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
        end)
    end)
    Notify("Scripts", "Fly GUI carregado!", 2)
end})

UI.Button(Tabs.Scripts, { Name = "Fly car", Callback = function()
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/willthingVN/script-lua/refs/heads/main/Vehicle%20Fly%20Gui.lua"))()
        end)
    end)
    Notify("Scripts", "Fly Car carregado!", 2)
end})

--------------------------------------------------------------------------------
-- ATIVAÇÃO DE NOME E COR NA API
--------------------------------------------------------------------------------
task.spawn(function()
    pcall(function()
        local RE = ReplicatedStorage:WaitForChild("RE", 10)
        if RE then
            local remoteColor = RE:FindFirstChild("1RPNam1eColo1r") or RE:FindFirstChild("RPNameColor")
            local remoteName = RE:FindFirstChild("1RPNam1eTex1t") or RE:FindFirstChild("RPNameText")
            if remoteColor then remoteColor:FireServer("PickingRPNameColor", COR_VERMELHO) end
            task.wait(0.3)
            if LocalPlayer.UserId == MEU_ID_CREATOR then
                if remoteName then remoteName:FireServer("RolePlayName", "👑 Rd4X Hub Creator 👑") end
            else
                if remoteName then remoteName:FireServer("RolePlayName", "🇧🇷 Rd4X Hub User 🇧🇷") end
            end
        end
    end)
end)

Notify("RD4X Hub", "Interface carregada com sucesso!", 4)
-- ==========================================================
-- 🎵 MÚSICA DE FUNDO
-- ==========================================================
local musicaFundo = Instance.new("Sound", SoundService)
musicaFundo.SoundId = "rbxassetid://15400635549"  -- troque pelo ID
musicaFundo.Volume = 0.15
musicaFundo.Looped = true
musicaFundo:Play()

UI.Button(Tabs.Outros, {
    Name = "🎵 Play/Pause Música",
    Callback = function()
        if musicaFundo.IsPlaying then
            musicaFundo:Pause()
            Notify("Música", "Música pausada", 2)
        else
            musicaFundo:Resume()
            Notify("Música", "Música tocando", 2)
        end
    end
})
-- ==========================================================
-- 🎉 EFEITO DE CONFETE
-- ==========================================================
local function soltarConfete()
    local cores = {
        Color3.fromRGB(46, 204, 113),
        Color3.fromRGB(52, 152, 219),
        Color3.fromRGB(241, 196, 15),
        Color3.fromRGB(231, 76, 60),
        Color3.fromRGB(155, 89, 182),
    }
    for i = 1, 30 do
        task.spawn(function()
            local p = Instance.new("Frame", ScreenGui)
            p.Size = UDim2.new(0, 8, 0, 8)
            p.Position = UDim2.new(math.random(), 0, 0, -20)
            p.BackgroundColor3 = cores[math.random(1, #cores)]
            p.BorderSizePixel = 0
            p.ZIndex = 9998

            local c = Instance.new("UICorner", p)
            c.CornerRadius = UDim.new(1, 0)

            local duracao = math.random(15, 25) / 10
            TweenService:Create(p, TweenInfo.new(duracao, Enum.EasingStyle.Linear), {
                Position = UDim2.new(p.Position.X.Scale, 0, 1.2, 0),
                Rotation = math.random(-360, 360)
            }):Play()

            task.delay(duracao, function() p:Destroy() end)
        end)
        task.wait(0.03)
    end
end
-- ==========================================================
-- 🔔 POPUP DE ATUALIZAÇÃO (com bolhas + cor do hub)
-- ==========================================================
-- ==========================================================
-- 🔔 POPUP DE ATUALIZAÇÃO (DESIGN REFINADO E LIMPO)
-- ==========================================================
task.spawn(function()
    task.wait(1)

    -- Container principal
    local popup = Instance.new("Frame", ScreenGui)
    popup.Name = "Rd4X_PopupAtualizacao"
    popup.Size = UDim2.new(0, 360, 0, 240)
    popup.Position = UDim2.new(0.5, -180, 0.5, -120)
    popup.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    popup.BackgroundTransparency = 0.1
    popup.BorderSizePixel = 0
    popup.ClipsDescendants = true
    popup.ZIndex = 10000

    local cPopup = Instance.new("UICorner", popup)
    cPopup.CornerRadius = UDim.new(0, 12)

    local sPopup = Instance.new("UIStroke", popup)
    sPopup.Color = COR_VERMELHO
    sPopup.Thickness = 1.5
    sPopup.Transparency = 0.2

    -- 🫧 BOLHAS SUBINDO DENTRO DO POPUP
    local bolhasPopup = Instance.new("Frame", popup)
    bolhasPopup.Name = "BolhasPopup"
    bolhasPopup.Size = UDim2.new(1, 0, 1, 0)
    bolhasPopup.BackgroundTransparency = 1
    bolhasPopup.ClipsDescendants = true
    bolhasPopup.ZIndex = 1
    bolhasPopup.Active = false

    local popupAberto = true

    local function criarBolhaPopup()
        if not popupAberto or not bolhasPopup.Parent then return end

        local tam = math.random(5, 10)
        local bolha = Instance.new("Frame", bolhasPopup)
        bolha.Size = UDim2.new(0, tam, 0, tam)
        bolha.Position = UDim2.new(math.random() * 0.95, 0, 1, 10)
        bolha.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        bolha.BackgroundTransparency = math.random(60, 80) / 100
        bolha.BorderSizePixel = 0
        bolha.ZIndex = 1

        local c = Instance.new("UICorner", bolha)
        c.CornerRadius = UDim.new(1, 0)

        local duracao = math.random(5, 8)
        local driftX = math.random(-30, 30)

        local tween = TweenService:Create(bolha, TweenInfo.new(duracao, Enum.EasingStyle.Linear), {
            Position = UDim2.new(bolha.Position.X.Scale, driftX, 0, -20),
            BackgroundTransparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function()
            if bolha and bolha.Parent then bolha:Destroy() end
        end)
    end

    task.spawn(function()
        while popupAberto and bolhasPopup.Parent do
            criarBolhaPopup()
            task.wait(math.random(15, 35) / 100)
        end
    end)

    -- ───── Header ─────
    local header = Instance.new("Frame", popup)
    header.Size = UDim2.new(1, 0, 0, 42)
    header.BackgroundTransparency = 1
    header.ZIndex = 5

    local icone = Instance.new("TextLabel", header)
    icone.Size = UDim2.new(0, 24, 0, 24)
    icone.Position = UDim2.new(0, 14, 0, 9)
    icone.BackgroundTransparency = 1
    icone.Text = "🔔"
    icone.TextSize = 16
    icone.ZIndex = 6

    local titulo = Instance.new("TextLabel", header)
    titulo.Size = UDim2.new(1, -80, 1, 0)
    titulo.Position = UDim2.new(0, 44, 0, 0)
    titulo.BackgroundTransparency = 1
    titulo.Text = "Novidades & Update!"
    titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
    titulo.TextSize = 13
    titulo.Font = Enum.Font.GothamBold
    titulo.TextXAlignment = Enum.TextXAlignment.Left
    titulo.ZIndex = 6

    -- Botão fechar (X)
    local fechar = Instance.new("TextButton", header)
    fechar.Size = UDim2.new(0, 24, 0, 24)
    fechar.Position = UDim2.new(1, -34, 0, 9)
    fechar.BackgroundTransparency = 1
    fechar.Text = "✕"
    fechar.TextColor3 = COR_TEXTO_CINZA
    fechar.TextSize = 14
    fechar.Font = Enum.Font.GothamBold
    fechar.ZIndex = 6
    fechar.AutoButtonColor = false

    fechar.MouseEnter:Connect(function() fechar.TextColor3 = COR_VERMELHO end)
    fechar.MouseLeave:Connect(function() fechar.TextColor3 = COR_TEXTO_CINZA end)

    -- Linha separadora
    local separador = Instance.new("Frame", popup)
    separador.Size = UDim2.new(1, -28, 0, 1)
    separador.Position = UDim2.new(0, 14, 0, 42)
    separador.BackgroundColor3 = COR_BORDA
    separador.BorderSizePixel = 0
    separador.ZIndex = 5

    -- Área do conteúdo (Lista de novidades)
    local conteudo = Instance.new("ScrollingFrame", popup)
    conteudo.Size = UDim2.new(1, -28, 1, -100)
    conteudo.Position = UDim2.new(0, 14, 0, 50)
    conteudo.BackgroundTransparency = 1
    conteudo.BorderSizePixel = 0
    conteudo.ScrollBarThickness = 2
    conteudo.ScrollBarImageColor3 = COR_VERDE
    conteudo.CanvasSize = UDim2.new(0, 0, 0, 0)
    conteudo.AutomaticCanvasSize = Enum.AutomaticSize.Y
    conteudo.ZIndex = 5

    local layoutConteudo = Instance.new("UIListLayout", conteudo)
    layoutConteudo.Padding = UDim.new(0, 8)
    layoutConteudo.SortOrder = Enum.SortOrder.LayoutOrder

    local function addItem(texto)
        local item = Instance.new("TextLabel", conteudo)
        item.Size = UDim2.new(1, 0, 0, 0)
        item.AutomaticSize = Enum.AutomaticSize.Y
        item.BackgroundTransparency = 1
        item.Text = "•  " .. texto
        item.TextColor3 = Color3.fromRGB(255, 255, 255)
        item.TextSize = 11
        item.Font = Enum.Font.GothamMedium
        item.TextXAlignment = Enum.TextXAlignment.Left
        item.TextWrapped = true
        item.ZIndex = 6
    end

    -- Novidades
    addItem("Muito obrigado por usar nosso Hub!")
    addItem("Em breve adicionaremos mais coisas!")
    addItem("Entre no nosso Discord para ficar por dentro de tudo!")

    -- Botão "Entendi!" destacado
    local botaoOk = Instance.new("TextButton", popup)
    botaoOk.Size = UDim2.new(1, -28, 0, 32)
    botaoOk.Position = UDim2.new(0, 14, 1, -42)
    botaoOk.BackgroundColor3 = COR_VERDE
    botaoOk.BackgroundTransparency = 0
    botaoOk.BorderSizePixel = 0
    botaoOk.Text = "Entendi!"
    botaoOk.TextColor3 = Color3.fromRGB(255, 255, 255)
    botaoOk.TextSize = 11
    botaoOk.Font = Enum.Font.GothamBold
    botaoOk.AutoButtonColor = false
    botaoOk.ZIndex = 6

    local cBtn = Instance.new("UICorner", botaoOk)
    cBtn.CornerRadius = UDim.new(0, 6)

    botaoOk.MouseEnter:Connect(function()
        TweenService:Create(botaoOk, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    end)
    botaoOk.MouseLeave:Connect(function()
        TweenService:Create(botaoOk, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
    end)

    -- Função de fechar e abrir o Hub principal
    local function fecharPopup()
        popupAberto = false
        TweenService:Create(popup, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        }):Play()

        for _, obj in ipairs(popup:GetDescendants()) do
            pcall(function()
                if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    TweenService:Create(obj, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
                elseif obj:IsA("Frame") then
                    TweenService:Create(obj, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                elseif obj:IsA("UIStroke") then
                    TweenService:Create(obj, TweenInfo.new(0.3), {Transparency = 1}):Play()
                end
            end)
        end

        task.wait(0.35)
        popup:Destroy()

        -- Abre o Hub Principal após fechar
        MainFrame.Visible = true
        local tamanhoFinal = UDim2.new(0, 560, 0, 400)
        local posFinal = UDim2.new(0.5, -280, 0.5, -200)

        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = tamanhoFinal,
            Position = posFinal
        }):Play()
    end

    fechar.MouseButton1Click:Connect(fecharPopup)
    botaoOk.MouseButton1Click:Connect(fecharPopup)

    -- Animação de Entrada
    popup.Size = UDim2.new(0, 0, 0, 0)
    popup.Position = UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(popup, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 360, 0, 240),
        Position = UDim2.new(0.5, -180, 0.5, -120)
    }):Play()
end)

-- ==========================================================
-- 📝 ALTERAR BIO (Welcome, NomeDoJogador)
-- ==========================================================
UI.Button(Tabs.Player, {
    Name = "📝 Aplicar Bio (Welcome)",
    Callback = function()
        local textoBio = "Welcome, " .. LocalPlayer.Name
        pcall(function()
            local remote = game:GetService("ReplicatedStorage").RE["1RPNam1eTex1t"]
            if remote then
                remote:FireServer("RolePlayBio", textoBio)
                Notify("Bio", "Alterada: " .. textoBio, 3)
            end
        end)
    end
})
