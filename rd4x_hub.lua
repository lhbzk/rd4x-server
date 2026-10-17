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
-- ==========================================================
-- 🎬 TELA DE CARREGAMENTO
-- ==========================================================
if CoreGui:FindFirstChild("RD4X_Loading") then
    CoreGui.RD4X_Loading:Destroy()
end

local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "RD4X_Loading"
loadingGui.ResetOnSpawn = false
loadingGui.DisplayOrder = 99999
loadingGui.IgnoreGuiInset = true
loadingGui.Parent = CoreGui

local bgLoad = Instance.new("Frame", loadingGui)
bgLoad.Size = UDim2.new(1, 0, 1, 0)
bgLoad.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
bgLoad.BorderSizePixel = 0

local container = Instance.new("Frame", bgLoad)
container.Size = UDim2.new(0, 300, 0, 100)
container.Position = UDim2.new(0.5, -150, 0.5, -50)
container.BackgroundTransparency = 1

local icone = Instance.new("ImageLabel", container)
icone.Size = UDim2.new(0, 60, 0, 60)
icone.Position = UDim2.new(0.5, -30, 0, 0)
icone.BackgroundTransparency = 1
icone.Image = "rbxassetid://109276734890323"
icone.ScaleType = Enum.ScaleType.Fit

local titulo = Instance.new("TextLabel", container)
titulo.Size = UDim2.new(1, 0, 0, 20)
titulo.Position = UDim2.new(0, 0, 0, 65)
titulo.BackgroundTransparency = 1
titulo.Text = "Rd4X Hub"
titulo.TextColor3 = COR_TEXTO
titulo.TextSize = 14
titulo.Font = Enum.Font.GothamBold

local status = Instance.new("TextLabel", container)
status.Size = UDim2.new(1, 0, 0, 16)
status.Position = UDim2.new(0, 0, 0, 85)
status.BackgroundTransparency = 1
status.Text = "Carregando..."
status.TextColor3 = COR_TEXTO_CINZA
status.TextSize = 10
status.Font = Enum.Font.Gotham

local barBg = Instance.new("Frame", bgLoad)
barBg.Size = UDim2.new(0, 240, 0, 6)
barBg.Position = UDim2.new(0.5, -120, 0.5, 80)
barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
barBg.BorderSizePixel = 0

local cBg = Instance.new("UICorner", barBg)
cBg.CornerRadius = UDim.new(1, 0)

local barra = Instance.new("Frame", barBg)
barra.Size = UDim2.new(0, 0, 1, 0)
barra.BackgroundColor3 = COR_VERDE
barra.BorderSizePixel = 0

local cB = Instance.new("UICorner", barra)
cB.CornerRadius = UDim.new(1, 0)

task.spawn(function()
    while bgLoad.Parent do
        TweenService:Create(icone, TweenInfo.new(0.8), {Size = UDim2.new(0, 70, 0, 70), Position = UDim2.new(0.5, -35, 0, -5)}):Play()
        task.wait(0.8)
        TweenService:Create(icone, TweenInfo.new(0.8), {Size = UDim2.new(0, 60, 0, 60), Position = UDim2.new(0.5, -30, 0, 0)}):Play()
        task.wait(0.8)
    end
end)

TweenService:Create(barra, TweenInfo.new(8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Size = UDim2.new(1, 0, 1, 0)
}):Play()

task.spawn(function()
    local mensagens = {
        "Carregando módulos...",
        "Verificando atualizações...",
        "Preparando interface...",
        "Quase pronto...",
    }
    for i, msg in ipairs(mensagens) do
        status.Text = msg
        task.wait(2)
    end
end)

task.delay(8.2, function()
        _G.RD4X_Loading_Completo = true
    TweenService:Create(bgLoad, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    TweenService:Create(container, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    TweenService:Create(titulo, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(status, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(barBg, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    TweenService:Create(barra, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    TweenService:Create(icone, TweenInfo.new(0.4), {ImageTransparency = 1}):Play()
    
    task.wait(0.4)
    loadingGui:Destroy()
    
    -- ✅ MOSTRA O HUB COM ANIMAÇÃO
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundTransparency = 1
    
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 560, 0, 400),
        Position = UDim2.new(0.5, -280, 0.5, -200),
        BackgroundTransparency = TRANSP_FUNDO
    }):Play()
end)
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
TitleHeader.Text = "Rd4X Hub Oficial $ > Brookhaven RP 🇧🇷 < "
TitleHeader.TextColor3 = COR_TEXTO
TitleHeader.TextSize = 11
TitleHeader.Font = Enum.Font.GothamBold
TitleHeader.TextXAlignment = Enum.TextXAlignment.Left
TitleHeader.ZIndex = 6

local UserCredit = Instance.new("TextLabel", Header)
UserCredit.Size = UDim2.new(0, 200, 0, 38)
UserCredit.Position = UDim2.new(1, -250, 0, 0)
UserCredit.BackgroundTransparency = 1
UserCredit.Text = "By Rd4X Team and J. Epstein"
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
    if _G.RD4X_NotifAtivas == false then return end
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
            if _G.RD4X_SomAtivo ~= false then
    pcall(function()
        local som = Instance.new("Sound", SoundService)
        som.SoundId = "rbxassetid://3665143844"
        som.Volume = 0.3
        som:Play()
        task.delay(2, function() som:Destroy() end)
    end)
end
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
    Player    = CreateTab("Jogador"),
    Skins = CreateTab("Skins"),
    Servidor  = CreateTab("Servidor"),
    Carros    = CreateTab("Veículo"),
    Casas     = CreateTab("Casa"),
    SomAll = CreateTab("SomAll"),
    Musicas   = CreateTab("Música"),
    Troll     = CreateTab("Troll"),
    Outros    = CreateTab("Outros"),
    Protecao  = CreateTab("Proteção"),
    Scripts   = CreateTab("Scripts"),
    Teleportes = CreateTab("Teleportes"),
    Config = CreateTab("Config")
}
ShowTab("Informações")
UI.Paragraph(Tabs.SomAll, {
    Title = "⚠️ Aviso do RD4X!",
    Content = "Aguarde atualizações, em breve estará disponível!",
    Height = 55
})
UI.Paragraph(Tabs.Skins, {
    Title = "⚠️ Aviso do RD4X!",
    Content = "Aguarde atualizações, em breve estará disponível!",
    Height = 55
})
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
    pcall(function() setclipboard("https://discord.gg/SsPh5Eyr9Q") end)
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
TitleHex.Text = "Rd4X Hub ._"
TitleHex.TextColor3 = COR_TEXTO
TitleHex.TextSize = 11
TitleHex.Font = Enum.Font.GothamBold
TitleHex.TextXAlignment = Enum.TextXAlignment.Left
TitleHex.ZIndex = 7

local DescHex = Instance.new("TextLabel", CardHexagon)
DescHex.Size = UDim2.new(1, -10, 0, 32)
DescHex.Position = UDim2.new(0, 0, 0, 18)
DescHex.BackgroundTransparency = 1
DescHex.Text = "Está versão é a 1.0. Você pode encontrar falhas."
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
TitleRelease.Text = "[Lançamento]🔥 Versão: 1.0:"
TitleRelease.TextColor3 = COR_TEXTO
TitleRelease.TextSize = 11
TitleRelease.Font = Enum.Font.GothamBold
TitleRelease.TextXAlignment = Enum.TextXAlignment.Left
TitleRelease.ZIndex = 7

local DescRelease = Instance.new("TextLabel", CardRelease)
DescRelease.Size = UDim2.new(1, -10, 0, 94)
DescRelease.Position = UDim2.new(0, 0, 0, 20)
DescRelease.BackgroundTransparency = 1
DescRelease.Text = "Acessando o Discord você pode obter mais informações, mas a compra do Admin só serão liberadas ao atingir 1K de Execuções.."
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
DescCI2.Text = "Dev / Owner = J. Epstein\nEquipe = Rd4X Team oficial"
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
-- ==========================================================
-- 🌍 ABA TELEPORTES
-- ==========================================================
local function teleportar(x, y, z, nomeLocal)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
        Notify("🌍 Teleporte", "Você foi para: " .. nomeLocal, 2)
    else
        Notify("⚠️ Aviso", "Personagem não carregado", 2)
    end
end

UI.Button(Tabs.Teleportes, {
    Name = "🏛️ Praça",
    Callback = function()
        teleportar(-26, 7, 1, "Praça")
    end
})

UI.Button(Tabs.Teleportes, {
    Name = "🏥 Hospital",
    Callback = function()
        teleportar(-317, 5, 21, "Hospital")
    end
})

UI.Button(Tabs.Teleportes, {
    Name = "⛰️ Morro",
    Callback = function()
        teleportar(-349, 66, -458, "Morro")
    end
})
UI.Button(Tabs.Teleportes, {
    Name = "🌲 Floresta",
    Callback = function()
        teleportar(-254, 7, 1089, "Floresta")
    end
})
UI.Button(Tabs.Teleportes, {
    Name = "🩳 Praia",
    Callback = function()
        teleportar(-231, 0, 742, "Praia")
    end
})
UI.Button(Tabs.Teleportes, {
    Name = "🩳 Praia",
    Callback = function()
        teleportar(63, 4, 1477, "Praia2")
    end
})
UI.Button(Tabs.Teleportes, {
    Name = "🐥 Fazenda",
    Callback = function()
        teleportar(-852, 3, -84, "Fazenda")
    end
})
UI.Button(Tabs.Teleportes, {
    Name = "🐴 Celeiro",
    Callback = function()
        teleportar(-831, 3, -287, "Celeiro")
    end
})
UI.Button(Tabs.Teleportes, {
    Name = "🛏️ Hotel",
    Callback = function() 
        teleportar(168, 4, 161, "Hotel")
    end
})
UI.Button(Tabs.Teleportes, {
    Name = "⛽ Posto",
    Callback = function()
        teleportar(157, 4, -301, "Posto")
    end
})
UI.Button(Tabs.Teleportes, {
    Name = "🚁 Heli + Drone",
    Callback = function()
        teleportar(-695, 260, 790, "Drone")
    end
})
UI.Button(Tabs.Teleportes, {
    Name = "🏠 Casa Abandonada",
    Callback = function()
        teleportar(1036, 6, 54, "Casa Abandonada")
    end
})
UI.Button(Tabs.Teleportes, {
    Name = "⛵ Iate ",
    Callback = function()
        teleportar(-128, 32, 850, "Iate")
    end
})
UI.Button(Tabs.Teleportes, {
    Name = "🔌 Energia",
    Callback = function()
        teleportar(228, 4, 813, "Energia")
    end
})
UI.Button(Tabs.Teleportes, {
    Name = "⛰️ Morro",
    Callback = function()
        teleportar(-349, 66, -458, "Morro")
    end
})

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
UI.Button(Tabs.Outros, {
    Name = "🎥 Camera Noclip",
    Callback = function()
        pcall(function() LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam end)
    end
})

-- ==========================================================
-- 📝 ROLEPLAY BIO
-- ==========================================================
local RPNameText = nil

local function atualizarBioRemote()
    local RE = ReplicatedStorage:FindFirstChild("RE")
    RPNameText = RE and RE:FindFirstChild("1RPNam1eTex1t")
end

atualizarBioRemote()

UI.Button(Tabs.Player, {
    Name = "✨ Setar Bio: Welcome, " .. LocalPlayer.Name,
    Callback = function()
        atualizarBioRemote()
        if RPNameText then
            local texto = "Welcome, " .. LocalPlayer.Name
            RPNameText:FireServer("RolePlayBio", texto)
        end
    end
})

local bioCustom = ""

UI.Input(Tabs.Player, {
    Name = "Bio Personalizada",
    CurrentValue = "",
    PlaceholderText = "Digite seu texto...",
    Callback = function(t) bioCustom = t end,
})

UI.Button(Tabs.Player, {
    Name = "📝 Aplicar Bio Personalizada",
    Callback = function()
        atualizarBioRemote()
        if RPNameText and bioCustom ~= "" then
            RPNameText:FireServer("RolePlayBio", bioCustom)
        end
    end
})

UI.Button(Tabs.Player, {
    Name = "👻 Limpar Bio",
    Callback = function()
        atualizarBioRemote()
        if RPNameText then
            RPNameText:FireServer("RolePlayBio", "")
            Notify("Bio", "Bio removida", 2)
        end
    end
})
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
end})

UI.Button(Tabs.Servidor, { Name = "👁️ Ver Câmera", Callback = function()
    local alvo = Players:FindFirstChild(alvoServidorSelecionado)
    if alvo and alvo.Character and alvo.Character:FindFirstChild("Head") then
        camOriginalServidor = Camera.CFrame
        Camera.CameraSubject = alvo.Character.Humanoid
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
    end
end})

UI.Button(Tabs.Servidor, { Name = "Sair da cabeça", Callback = function()
    if conexaoSentarCabeca then conexaoSentarCabeca:Disconnect(); conexaoSentarCabeca = nil end
    pcall(function() LocalPlayer.Character.Humanoid.Sit = false end)
end})

UI.Button(Tabs.Servidor, { Name = "🚪 Sair do Servidor", Callback = function()
    LocalPlayer:Kick("Disconnected by Rd4X.")
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
end})

UI.Input(Tabs.Carros, { Name = "Força de Arrancada", CurrentValue = "100", PlaceholderText = "Força...", Callback = function(v) forcaArrancadaInput = tonumber(v) or 100 end })
UI.Button(Tabs.Carros, { Name = "Definir Arrancada", Callback = function()
    pcall(function() LocalPlayer.Character.Humanoid.SeatPart.Torque = forcaArrancadaInput end)
end})

UI.Button(Tabs.Carros, { Name = "Carros Bloqueados (Dirigir qualquer)", Callback = function()
    pcall(function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("VehicleSeat") then v.Disabled = false; v.Locked = false end
        end
    end)
end})

UI.Button(Tabs.Carros, { Name = "Fly Car", Callback = function()
    Notify("Carros", "Carregando Fly Car...", 2)
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/willthingVN/script-lua/refs/heads/main/Vehicle%20Fly%20Gui.lua"))()
        end)
    end)
end})
-- ==========================================================
-- 🌈 RAINBOW CAR
-- ==========================================================
local rainbowCarAtivo = false

UI.Toggle(Tabs.Carros, {
    Name = "🌈 Carro Arco-Íris (Rainbow Car)",
    CurrentValue = false,
    Callback = function(state)
        rainbowCarAtivo = state
        
        if rainbowCarAtivo then
            task.spawn(function()
                local RE = ReplicatedStorage:FindFirstChild("RE")
                local carColorRemote = RE and RE:FindFirstChild("1Ca1rColo1r")
                local hue = 0

                while rainbowCarAtivo do
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    
                    -- Verifica se está sentado em um veículo
                    if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
                        hue = (hue + 0.01) % 1
                        local corRGB = Color3.fromHSV(hue, 1, 1)
                        
                        -- Tenta aplicar pelo Remote do Brookhaven
                        if carColorRemote then
                            pcall(function()
                                carColorRemote:FireServer("PickingCarColor", corRGB)
                            end)
                        end
                        
                        -- Tenta aplicar na textura/cor do modelo local/servidor
                        local veiculo = hum.SeatPart:FindFirstAncestorOfClass("Model")
                        if veiculo then
                            for _, part in ipairs(veiculo:GetDescendants()) do
                                if part:IsA("BasePart") and part.Name ~= "Seat" then
                                    pcall(function() part.Color = corRGB end)
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})
-- ==========================================================
-- 🤖 PILOTO AUTOMÁTICO (JOGADOR OU LOCAL FIXO)
-- ==========================================================
local autoDriveAtivo = false
local destinoSelecionado = "🏛️ Praça"

-- 📍 Tabela de locais fixos do Brookhaven
local LOCAIS_BROOKHAVEN = {
    ["🏛️ Praça"]            = Vector3.new(-26, 7, 1),
    ["🏥 Hospital"]         = Vector3.new(-317, 5, 21),
    ["⛰️ Morro"]            = Vector3.new(-349, 66, -458),
    ["🌲 Floresta"]         = Vector3.new(-254, 7, 1089),
    ["🩳 Praia"]            = Vector3.new(-231, 0, 742),
    ["🐥 Fazenda"]          = Vector3.new(-852, 3, -84),
    ["🐴 Celeiro"]          = Vector3.new(-831, 3, -287),
    ["🛏️ Hotel"]            = Vector3.new(168, 4, 161),
    ["⛽ Posto de Gasolina"] = Vector3.new(157, 4, -301),
    ["🚁 Heli + Drone"]     = Vector3.new(-695, 260, 790),
    ["🏠 Casa Abandonada"]  = Vector3.new(1036, 6, 54),
    ["⛵ Iate"]             = Vector3.new(-128, 32, 850),
    ["🔌 Usina de Energia"]  = Vector3.new(228, 4, 813),
}

-- Função para gerar a lista combinada (Locais + Jogadores)
local function obterListaPiloto()
    local lista = {}

    -- Add os Locais Fictícios/Pontos do Mapa primeiro
    for nomeLocal, _ in pairs(LOCAIS_BROOKHAVEN) do
        table.insert(lista, nomeLocal)
    end

    -- Add os Jogadores do Servidor
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(lista, "👤 " .. p.Name)
    end

    return lista
end

-- Dropdown
local dropdownPiloto = UI.Dropdown(Tabs.Carros, {
    Name = "🎯 Selecione o Destino (Local ou Player)",
    Options = obterListaPiloto(),
    CurrentOption = {"🏛️ Praça"},
    Callback = function(opt)
        if opt and opt[1] then 
            destinoSelecionado = opt[1] 
        end
    end
})

UI.Button(Tabs.Carros, {
    Name = "🔄 Atualizar Lista de Destinos",
    Callback = function()
        dropdownPiloto:Refresh(obterListaPiloto())
        Notify("Carros", "Lista de destinos atualizada!", 2)
    end
})

-- Toggle para Iniciar o Piloto Automático
UI.Toggle(Tabs.Carros, {
    Name = "🤖 Iniciar Piloto Automático",
    CurrentValue = false,
    Callback = function(state)
        autoDriveAtivo = state

        if autoDriveAtivo then
            Notify("Carros", "Piloto Automático ligado! Destino: " .. destinoSelecionado, 3)

            task.spawn(function()
                while autoDriveAtivo do
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    local seat = hum and hum.SeatPart

                    if seat and seat:IsA("VehicleSeat") then
                        local veiculo = seat:FindFirstAncestorOfClass("Model") or seat.Parent
                        local posAlvo = nil

                        -- 1. Verifica se o destino é um Local Fixo
                        if LOCAIS_BROOKHAVEN[destinoSelecionado] then
                            posAlvo = LOCAIS_BROOKHAVEN[destinoSelecionado]

                        -- 2. Se for um Jogador (começa com "👤 ")
                        else
                            local nomeLimpo = destinoSelecionado:gsub("👤 ", "")
                            local alvo = Players:FindFirstChild(nomeLimpo)
                            if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") then
                                posAlvo = alvo.Character.HumanoidRootPart.Position
                            end
                        end

                        -- Move o veículo se encontrou a posição
                        if veiculo and posAlvo then
                            local posCarro = seat.Position
                            local direcao = (Vector3.new(posAlvo.X, posCarro.Y, posAlvo.Z) - posCarro).Unit

                            if (Vector3.new(posAlvo.X, posCarro.Y, posAlvo.Z) - posCarro).Magnitude > 8 then
                                pcall(function()
                                    seat.AssemblyLinearVelocity = direcao * 50
                                    veiculo:PivotTo(CFrame.new(posCarro, Vector3.new(posAlvo.X, posCarro.Y, posAlvo.Z)))
                                end)
                            else
                                pcall(function()
                                    seat.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                end)
                                Notify("Carros", "🏁 Você chegou ao destino!", 2)
                                autoDriveAtivo = false
                                break
                            end
                        end
                    else
                        Notify("Carros", "Entre no banco do motorista!", 3)
                        autoDriveAtivo = false
                        break
                    end
                    task.wait(0.05)
                end
            end)
        else
            Notify("Carros", "Piloto Automático Desativado", 2)
        end
    end
})
-- ==========================================================
-- 🚜 PUXAR TODOS OS CARROS DESOCUPADOS ATÉ VOCÊ
-- ==========================================================
UI.Button(Tabs.Carros, {
    Name = "🧲 Bring All Vehicles (Puxar Carros Sem Motorista)",
    Callback = function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            Notify("Carros", "Seu personagem não foi encontrado!", 2)
            return
        end

        local posicaoFrente = hrp.CFrame + (hrp.CFrame.LookVector * 10)
        local quantidadePuxada = 0

        pcall(function()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("VehicleSeat") then
                    -- Verifica se o assento do motorista está sem ninguém sentado
                    if not obj.Occupant then
                        local veiculo = obj:FindFirstAncestorOfClass("Model") or obj.Parent
                        if veiculo and veiculo:IsA("Model") then
                            -- Teleporta o modelo do veículo para a sua frente
                            veiculo:PivotTo(posicaoFrente + Vector3.new(0, quantidadePuxada * 3, 0))
                            quantidadePuxada = quantidadePuxada + 1
                        end
                    end
                end
            end
        end)

        if quantidadePuxada > 0 then
            Notify("Carros", "🧲 " .. quantidadePuxada .. " carros puxados até você!", 3)
        else
            Notify("Carros", "Nenhum carro desocupado encontrado.", 2)
        end
    end
})

--------------------------------------------------------------------------------
-- ABA CASAS
--------------------------------------------------------------------------------
-- ==========================================================
-- 🔍 RASTREADOR / ESP DE COFRES
-- ==========================================================
UI.Paragraph(Tabs.Casas, {
    Title = "⚠️ Aviso do RD4X!",
    Content = "Aguarde atualizações, em breve estará disponível!",
    Height = 55
})
--[[
local espCofresAtivo = false

UI.Toggle(Tabs.Casas, {
    Name = "🔍 ESP / Marker em Todos os Cofres",
    CurrentValue = false,
    Callback = function(state)
        espCofresAtivo = state

        if espCofresAtivo then
            Notify("Casas", "Escaneando cofres no mapa...", 2)
            task.spawn(function()
                while espCofresAtivo do
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if (obj.Name:lower():find("safe") or obj.Name:lower():find("cofre")) and (obj:IsA("BasePart") or obj:IsA("Model")) then
                            local parteAlvo = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")) or obj
                            if parteAlvo and not parteAlvo:FindFirstChild("RD4X_SafeESP") then
                                local bg = Instance.new("BillboardGui", parteAlvo)
                                bg.Name = "RD4X_SafeESP"
                                bg.Size = UDim2.new(0, 120, 0, 30)
                                bg.AlwaysOnTop = true

                                local lbl = Instance.new("TextLabel", bg)
                                lbl.Size = UDim2.new(1, 0, 1, 0)
                                lbl.BackgroundTransparency = 1
                                lbl.Text = "🔒 COFRE"
                                lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
                                lbl.TextSize = 12
                                lbl.Font = Enum.Font.GothamBold
                            end
                        end
                    end
                    task.wait(3)
                end
            end)
        else
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:FindFirstChild("RD4X_SafeESP") then
                    obj.RD4X_SafeESP:Destroy()
                end
            end
            Notify("Casas", "ESP de cofres desativado", 2)
        end
    end
})

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
--]]

-- ==========================================================
-- 🎵 SONS VIA PlayerToolEvent (ToolMusicText)
-- ==========================================================
-- ==========================================================
-- 🎵 MÚSICAS ORGANIZADAS (FUNK, FORRÓ E PHONK)
-- ==========================================================
local PlayerToolEvent = nil

local function atualizarToolRemote()
    local RE = ReplicatedStorage:FindFirstChild("RE")
    PlayerToolEvent = RE and RE:FindFirstChild("PlayerToolEvent")
end

atualizarToolRemote()

local idMusicaCustom = ""

UI.Input(Tabs.Musicas, {
    Name = "Outro Audio ID",
    CurrentValue = "",
    PlaceholderText = "Ex: 9048375035",
    Callback = function(t) idMusicaCustom = t end,
})

UI.Button(Tabs.Musicas, {
    Name = "▶️ Tocar Audio ID Personalizado",
    Callback = function()
        atualizarToolRemote()
        if PlayerToolEvent and idMusicaCustom ~= "" then
            PlayerToolEvent:FireServer("ToolMusicText", idMusicaCustom)
            Notify("Música", "ID " .. idMusicaCustom .. " tocando!", 3)
        else
            Notify("Aviso", "Digite um ID primeiro", 2)
        end
    end
}) 
-- ==========================================================
-- 📋 DROPDOWNS DE MÚSICA POR CATEGORIA (sem notificações)
-- ==========================================================

-- ─── LISTAS DE MÚSICAS ───
local LISTA_FUNK = {
    ["🔥 piranha"]               = "103811087853875",
    ["🔥 os menor"]              = "126719632721905",
    ["🔥 vai caindo com a bct"]  = "74967642581893",
    ["🔥 facada"]                = "81730477878065",
    ["🔥 Tipo nino"]             = "140336018782383",
    ["🔥 lacs"]                  = "121544291272731",
    ["🔥 Funk"]                  = "74206017407052",
    ["🔥 onda do birimbau"]      = "90728144562197",
    ["🔥 piseiro bahiano"]       = "111425053457342",
    ["🔥 cheiro"]                = "102430799050444",
    ["🔥 afrozada"]              = "116257708415048",
    ["🔥 sequência de papapey"]  = "127060465281063",
}

local LISTA_FORRO = {
    ["🪗 uma botadinha"]         = "84624301411909",
    ["🪗 eu me apaixonei"]       = "139414982330352",
    ["🪗 Pisada xl"]             = "70508008395270",
    ["🪗 notificação preferida"] = "90137280531474",
    ["🪗 só fé"]                 = "139128878060651",
    ["🪗 desça daí seu corno"]   = "1197388789221996",
}

local LISTA_PHONK = {
    ["🏎️ Phonk 1"]              = "COLE_O_ID_AQUI",
    ["🏎️ Phonk 2"]              = "COLE_O_ID_AQUI",
}

-- ─── FUNÇÃO QUE TOCA PELO ID ───
local function tocarMusicaPorNome(lista, nome)
    atualizarToolRemote()
    local id = lista[nome]
    if PlayerToolEvent and id and id ~= "COLE_O_ID_AQUI" then
        PlayerToolEvent:FireServer("ToolMusicText", id)
    end
end

-- ─── FUNÇÃO QUE PEGA AS CHAVES DA LISTA ───
local function obterNomes(lista)
    local nomes = {}
    for nome, _ in pairs(lista) do
        table.insert(nomes, nome)
    end
    table.sort(nomes)
    return nomes
end

-- ─── DROPDOWN 1: FUNK ───
UI.Dropdown(Tabs.Musicas, {
    Name = "🔥 Tocar Funk",
    Options = obterNomes(LISTA_FUNK),
    CurrentOption = {"Selecione um Funk..."},
    Callback = function(opt)
        if opt and opt[1] then
            tocarMusicaPorNome(LISTA_FUNK, opt[1])
        end
    end,
})

-- ─── DROPDOWN 2: FORRÓ ───
UI.Dropdown(Tabs.Musicas, {
    Name = "🪗 Tocar Forró",
    Options = obterNomes(LISTA_FORRO),
    CurrentOption = {"Selecione um Forró..."},
    Callback = function(opt)
        if opt and opt[1] then
            tocarMusicaPorNome(LISTA_FORRO, opt[1])
        end
    end,
})

-- ─── DROPDOWN 3: PHONK ───
UI.Dropdown(Tabs.Musicas, {
    Name = "🏎️ Tocar Phonk",
    Options = obterNomes(LISTA_PHONK),
    CurrentOption = {"Selecione um Phonk..."},
    Callback = function(opt)
        if opt and opt[1] then
            tocarMusicaPorNome(LISTA_PHONK, opt[1])
        end
    end,
})
-- ==========================================================
-- 🚌 ÔNIBUS ESCOLAR — Spawn, Perseguição e Void
-- ==========================================================
-- ==========================================================
-- 🤡 ABA TROLL COMPLETA (RD4X HUB)
-- ==========================================================

-- ----------------------------------------------------------
-- 1. SELEÇÃO DE ALVO E LISTA DE JOGADORES
-- ----------------------------------------------------------
local alvoTrollSelecionado = LocalPlayer.Name

local function obterListaJogadoresTroll()
    local lista = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(lista, p.Name)
        end
    end
    if #lista == 0 then table.insert(lista, LocalPlayer.Name) end
    return lista
end

UI.Paragraph(Tabs.Troll, {
    Title = "🎯 Seleção de Alvo",
    Content = "Escolha um jogador do servidor para aplicar as funções abaixo.",
    Height = 42
})

local dropdownAlvoTroll = UI.Dropdown(Tabs.Troll, {
    Name = "👤 Selecionar Vítima",
    Options = obterListaJogadoresTroll(),
    CurrentOption = {obterListaJogadoresTroll()[1]},
    Callback = function(opt)
        if opt and opt[1] then
            alvoTrollSelecionado = opt[1]
            Notify("Troll", "Alvo selecionado: " .. alvoTrollSelecionado, 2)
        end
    end,
})

UI.Button(Tabs.Troll, {
    Name = "🔄 Atualizar Lista de Vítimas",
    Callback = function()
        dropdownAlvoTroll:Refresh(obterListaJogadoresTroll())
        Notify("Troll", "Lista de jogadores atualizada!", 2)
    end,
})

-- ----------------------------------------------------------
-- 2. BUS FLING & TRACKING 3D (VOID KILL)
-- ----------------------------------------------------------
UI.Paragraph(Tabs.Troll, {
    Title = "🚌 Bus Void Kill",
    Content = "Mata o Alvo Usando um Ônibus. Após matar o player, você será teleportado para a praça.",
    Height = 42
})

local busAtivo = false

local function encontrarOnibusDoJogador()
    local tempoInicio = tick()
    while tick() - tempoInicio < 4 do
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local nomeUpper = obj.Name:upper()
                local playerUpper = LocalPlayer.Name:upper()
                
                if nomeUpper:find("BUS") or nomeUpper:find("SCHOOL") or nomeUpper:find(playerUpper) then
                    local seat = obj:FindFirstChildOfClass("VehicleSeat") or obj:FindFirstChild("VehicleSeat", true)
                    if seat then
                        return obj, seat
                    end
                end
            end
        end
        task.wait(0.2)
    end
    return nil, nil
end
UI.Button(Tabs.Troll, {
    Name = "🌪️ Iniciar Bus Kill (Void Kill)",
    Callback = function()
        if busAtivo then
            Notify("Troll", "Já tem um ônibus em perseguição!", 2)
            return
        end

        local RE = ReplicatedStorage:FindFirstChild("RE")
        local CarRemote = RE and RE:FindFirstChild("1Ca1r")

        if not CarRemote then
            Notify("Erro", "Tente Novamente!", 3)
            return
        end

        local alvo = Players:FindFirstChild(alvoTrollSelecionado)
        if not alvo or not alvo.Character then
            Notify("Troll", "Selecione uma vítima válida na lista!", 3)
            return
        end

        local rootAlvo = alvo.Character:FindFirstChild("HumanoidRootPart")
        local humanoidAlvo = alvo.Character:FindFirstChildOfClass("Humanoid")
        if not rootAlvo or not humanoidAlvo then
            Notify("Troll", "...!", 3)
            return
        end

        busAtivo = true

        -- 🚌 FORÇA O SPAWN DE UM NOVO ÔNIBUS ESCOLAR
        CarRemote:FireServer("PickingCar", "SchoolBus")
        Notify("Bus Kill", "Gerando novo ônibus no servidor...", 3)

        task.spawn(function()
            -- 🔍 Função que busca SEMPRE o ônibus gerado mais recentemente na superfície
            local function encontrarNovoOnibus()
                local tInicio = tick()
                local ultimoOnibus = nil
                local ultimoSeat = nil

                while tick() - tInicio < 4 do
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("Model") then
                            local nomeUpper = obj.Name:upper()
                            local playerUpper = LocalPlayer.Name:upper()
                            
                            if (nomeUpper:find("BUS") or nomeUpper:find("SCHOOL") or nomeUpper:find(playerUpper)) then
                                local seat = obj:FindFirstChildOfClass("VehicleSeat") or obj:FindFirstChild("VehicleSeat", true)
                                -- Ignora ônibus antigos que ficaram presos no Void (Y < -50)
                                if seat and seat.Position.Y > -50 then
                                    ultimoOnibus = obj
                                    ultimoSeat = seat
                                end
                            end
                        end
                    end
                    if ultimoOnibus and ultimoSeat then
                        return ultimoOnibus, ultimoSeat
                    end
                    task.wait(0.2)
                end
                return nil, nil
            end

            local onibus, seatMotorista = encontrarNovoOnibus()
            local myChar = LocalPlayer.Character
            local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

            if onibus and seatMotorista and myHum then
                pcall(function() seatMotorista:Sit(myHum) end)
                task.wait(0.1)

                Notify("Bus Kill 3D", "Perseguindo em 3D: " .. alvo.Name, 3)

                local girando = true
                local conexaoRender

                conexaoRender = RunService.RenderStepped:Connect(function()
                    if girando and rootAlvo and rootAlvo.Parent and onibus and onibus.Parent then
                        local tempo = tick() * 25
                        local rotX = math.rad(tempo * 50 % 360)
                        local rotY = math.rad(tempo * 80 % 360)
                        local rotZ = math.rad(tempo * 30 % 360)

                        local posicaoAlvo = rootAlvo.CFrame
                        onibus:PivotTo(posicaoAlvo * CFrame.Angles(rotX, rotY, rotZ))
                    else
                        if conexaoRender then conexaoRender:Disconnect() end
                    end
                end)

                local conexaoSentouBus
                conexaoSentouBus = humanoidAlvo.Seated:Connect(function(isSeated, seat)
                    if isSeated and seat and seat:IsDescendantOf(onibus) then
                        girando = false
                        if conexaoRender then conexaoRender:Disconnect() end
                        
                        
                        -- 1. Manda o ônibus para Y = -300
                        onibus:PivotTo(CFrame.new(rootAlvo.Position.X, -300, rootAlvo.Position.Z))
                        task.wait(0.2)

                        -- 2. Te tira do assento e te manda para a superfície na Praça
                        pcall(function()
                            if myHum then myHum.Sit = false end
                            if myHrp then myHrp.CFrame = CFrame.new(-26, 7, 1) end
                        end)

                        Notify("Bus Kill 3D", " Você voltou para a superfície!", 3)
                        
                        if conexaoSentouBus then conexaoSentouBus:Disconnect() end
                        busAtivo = false
                    end
                end)

                task.delay(30, function()
                    girando = false
                    busAtivo = false
                    if conexaoRender then conexaoRender:Disconnect() end
                    if conexaoSentouBus then conexaoSentouBus:Disconnect() end
                end)
            else
                Notify("Erro", "Falha ao gerar novo ônibus! Tente novamente.", 3)
                busAtivo = false
            end
        end)
    end,
})


UI.Button(Tabs.Troll, {
    Name = "⏹️ Parar Bus Fling 3D",
    Callback = function()
        busAtivo = false
        Notify("Troll", "Bus Kill desativado!", 2)
    end,
})

-- ----------------------------------------------------------
-- 3. HEAD SIT (SENTAR NA CABEÇA DO ALVO)
-- ----------------------------------------------------------
UI.Paragraph(Tabs.Troll, {
    Title = "👑 Interações de Personagem",
    Content = "Grude no personagem do jogador selecionado.",
    Height = 42
})

local conexaoHeadSit = nil

UI.Toggle(Tabs.Troll, {
    Name = "👑 Head Sit (Sentar na Cabeça do Alvo)",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local alvo = Players:FindFirstChild(alvoTrollSelecionado)
            if not alvo or not alvo.Character then
                Notify("Troll", "Selecione uma vítima válida!", 2)
                return
            end

            Notify("Troll", "Sentado na cabeça de: " .. alvo.Name, 2)

            if conexaoHeadSit then conexaoHeadSit:Disconnect() end
            conexaoHeadSit = RunService.RenderStepped:Connect(function()
                pcall(function()
                    local meuChar = LocalPlayer.Character
                    local meuHrp = meuChar and meuChar:FindFirstChild("HumanoidRootPart")
                    local meuHum = meuChar and meuChar:FindFirstChildOfClass("Humanoid")
                    local cabecaAlvo = alvo.Character and alvo.Character:FindFirstChild("Head")

                    if meuHrp and meuHum and cabecaAlvo then
                        meuHum.Sit = true
                        meuHrp.CFrame = cabecaAlvo.CFrame * CFrame.new(0, 1.6, 0)
                    else
                        if conexaoHeadSit then conexaoHeadSit:Disconnect() end
                    end
                end)
            end)
        else
            if conexaoHeadSit then
                conexaoHeadSit:Disconnect()
                conexaoHeadSit = nil
            end
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Sit = false
                end
            end)
            Notify("Troll", "Saiu da cabeça do alvo", 2)
        end
    end
})

-- ----------------------------------------------------------
-- 4. DOG MODE / ATTACH (GRUDAR NAS COSTAS)
-- ----------------------------------------------------------
local conexaoAttach = nil

UI.Toggle(Tabs.Troll, {
    Name = "🐶 Dog Mode (Grudar nas Costas do Alvo)",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local alvo = Players:FindFirstChild(alvoTrollSelecionado)
            if not alvo or not alvo.Character then
                Notify("Troll", "Selecione uma vítima válida!", 2)
                return
            end

            Notify("Troll", "Grudado nas costas de: " .. alvo.Name, 2)
            if conexaoAttach then conexaoAttach:Disconnect() end

            conexaoAttach = RunService.RenderStepped:Connect(function()
                pcall(function()
                    local meuHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local hrpAlvo = alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart")

                    if meuHrp and hrpAlvo then
                        meuHrp.CFrame = hrpAlvo.CFrame * CFrame.new(0, 0, 1.5)
                    else
                        if conexaoAttach then conexaoAttach:Disconnect() end
                    end
                end)
            end)
        else
            if conexaoAttach then
                conexaoAttach:Disconnect()
                conexaoAttach = nil
            end
            Notify("Troll", "Soltou do alvo", 2)
        end
    end
})

-- ----------------------------------------------------------
-- 5. FLING ALL PROPS
-- ----------------------------------------------------------
--[[
UI.Button(Tabs.Troll, {
    Name = "🌀 Girar Todos os Props (Fling Props)",
    Callback = function()
        pcall(function()
            local WorkspaceCom = Workspace:FindFirstChild("WorkspaceCom")
            if WorkspaceCom then
                for _, container in ipairs(WorkspaceCom:GetChildren()) do
                    for _, prop in ipairs(container:GetChildren()) do
                        local remote = prop:FindFirstChild("SetCurrentCFrame")
                        if remote then
                            task.spawn(function()
                                for i = 1, 10 do
                                    remote:InvokeServer(CFrame.new(prop:GetPivot().Position) * CFrame.Angles(0, math.rad(i * 36), 0))
                                    task.wait(0.05)
                                end
                            end)
                        end
                    end
                end
            end
        end)
        Notify("Troll", "Props rotacionados!", 2)
    end
})
--]]
-- ==========================================================
-- 📦 SISTEMA DE PROPS COMPLETO (Kill / Bring / All)
-- ==========================================================

local PROP_KILL_Y      = -300
local PROP_MOVE_SPEED  = 6
local PROP_MOVE_RANGE  = 3
local TEMPO_MAX_SIT    = 10
local PROP_TIPO        = "FurnitureBleachers"
local PROP_CATEGORIA   = "Furniture"

local alvoPropSelecionado = LocalPlayer.Name

-- 1. Lista de Jogadores (Inclui você para facilidade de testes)
local function obterListaProp()
    local lista = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(lista, p.Name)
    end
    if #lista == 0 then table.insert(lista, LocalPlayer.Name) end
    return lista
end

local dropdownProp = UI.Dropdown(Tabs.Troll, {
    Name = "🎯 Alvo (Props)",
    Options = obterListaProp(),
    CurrentOption = {LocalPlayer.Name},
    Callback = function(opt) 
        if opt and opt[1] then
            alvoPropSelecionado = opt[1] 
        end
    end,
})

UI.Button(Tabs.Troll, {
    Name = "🔄 Atualizar Lista (Props)",
    Callback = function()
        local novaLista = obterListaProp()
        dropdownProp:Refresh(novaLista)
        Notify("Props", "Lista atualizada!", 2)
    end,
})

-- 2. Equipar e Selecionar PropMaker
local function pegarPropMaker()
    local RE = ReplicatedStorage:FindFirstChild("RE")
    if not RE then return nil end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if not char or not hum then return nil end

    local propMaker = char:FindFirstChild("PropMaker")
    if propMaker then return propMaker end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    propMaker = backpack and backpack:FindFirstChild("PropMaker")

    if not propMaker then
        local toolRemote = RE:FindFirstChild("1Too1l")
        if toolRemote then
            pcall(function()
                toolRemote:InvokeServer("PickingTools", "PropMaker")
            end)
        end
        task.wait(0.4)
        propMaker = char:FindFirstChild("PropMaker") or (backpack and backpack:FindFirstChild("PropMaker"))
    end

    if propMaker and propMaker.Parent ~= char then
        pcall(function() hum:EquipTool(propMaker) end)
        task.wait(0.3)
    end

    return char:FindFirstChild("PropMaker")
end

local function selecionarProp(nome, categoria)
    local RE = ReplicatedStorage:FindFirstChild("RE")
    if not RE then return end
    local clearRemote = RE:FindFirstChild("1Clea1rTool1s")
    if not clearRemote then return end

    task.wait(0.2)
    pcall(function() clearRemote:FireServer("OpenPropMenu") end)
    task.wait(0.3)
    pcall(function()
        clearRemote:FireServer("RequestingPropName", nome or PROP_TIPO, categoria or PROP_CATEGORIA)
    end)
    task.wait(0.3)
end

-- 3. Invocação do Prop na posição
local function spawnarProp(posicao)
    local char = LocalPlayer.Character
    if not char then return false end
    
    local propMaker = char:FindFirstChild("PropMaker")
    if not propMaker then return false end

    local toolProp = propMaker:FindFirstChild("Tool_PropMake") or propMaker:FindFirstChildOfClass("RemoteEvent")
    
    local chao = Workspace:FindFirstChild("Model")
        and Workspace.Model:FindFirstChild("Street")
        and Workspace.Model.Street:FindFirstChild("Street")
        or Workspace

    if toolProp then
        pcall(function()
            toolProp:FireServer(chao, posicao)
        end)
    end

    pcall(function()
        local camera = Workspace.CurrentCamera
        local posTela, naTela = camera:WorldToViewportPoint(posicao)
        if naTela then
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton1(Vector2.new(posTela.X, posTela.Y))
        end
    end)

    return true
end

-- 4. Busca Props no WorkspaceCom
local function encontrarMeusProps()
    local WorkspaceCom = Workspace:FindFirstChild("WorkspaceCom")
    if not WorkspaceCom then return {} end

    local props = {}
    local meuNome = LocalPlayer.Name

    for _, container in ipairs(WorkspaceCom:GetChildren()) do
        for _, prop in ipairs(container:GetChildren()) do
            if prop.Name:find(meuNome, 1, true) then
                if prop:FindFirstChild("SetCurrentCFrame") or prop:IsA("Model") then
                    table.insert(props, prop)
                end
            end
        end
    end
    return props
end

local function moverProp(prop, cf)
    if not prop or not prop.Parent then return end
    local remote = prop:FindFirstChild("SetCurrentCFrame")
    if remote then
        pcall(function() remote:InvokeServer(cf) end)
    elseif prop:IsA("Model") then
        pcall(function() prop:PivotTo(cf) end)
    end
end

local function deletarTodosProps()
    local RE = ReplicatedStorage:FindFirstChild("RE")
    if not RE then return end
    local clearRemote = RE:FindFirstChild("1Clea1rTool1s")
    if clearRemote then
        pcall(function() clearRemote:FireServer("ClearAllProps") end)
    end
end

-- 5. Lógica do Kill Prop
local function executarKillProp(nomeAlvo)
    local alvo = Players:FindFirstChild(nomeAlvo)
    if not alvo or not alvo.Character then
        return false 
    end

    local hum = alvo.Character:FindFirstChildOfClass("Humanoid")
    local hrp = alvo.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return false end

    local antes = #encontrarMeusProps()

    spawnarProp(hrp.Position)
    task.wait(0.5)

    local agora = encontrarMeusProps()
    local prop = agora[#agora]

    if not prop then
        Notify("Props", "Clique 1x no chão para liberar o Prop!", 3)
        local t0 = tick()
        while tick() - t0 < 6 do
            task.wait(0.3)
            agora = encontrarMeusProps()
            if #agora > antes then
                prop = agora[#agora]
                break
            end
        end
    end

    if not prop then
        Notify("Props", "Prop não foi criado.", 2)
        return false
    end

    local sentou = false
    local tInicio = tick()
    local conexao

    conexao = RunService.Heartbeat:Connect(function()
        if sentou or (tick() - tInicio > TEMPO_MAX_SIT) then
            if conexao then conexao:Disconnect() end
            return
        end

        if not alvo.Character or not alvo.Character:FindFirstChild("HumanoidRootPart") then return end
        local hrpAtual = alvo.Character.HumanoidRootPart

        local t = tick() * PROP_MOVE_SPEED
        local offsetY = math.sin(t) * PROP_MOVE_RANGE
        local posPerseguicao = hrpAtual.Position + Vector3.new(0, offsetY, 0)

        moverProp(prop, CFrame.new(posPerseguicao))

        if hum.Sit then
            sentou = true
            if conexao then conexao:Disconnect() end
            task.wait(0.1)
            
            moverProp(prop, CFrame.new(hrpAtual.Position.X, PROP_KILL_Y, hrpAtual.Position.Z))
            task.wait(0.8)
            deletarTodosProps()
        end
    end)
    return true
end

-- 6. Lógica do Bring Prop
local function executarBringProp(nomeAlvo)
    local alvo = Players:FindFirstChild(nomeAlvo)
    if not alvo or not alvo.Character then
        return false 
    end

    local hum = alvo.Character:FindFirstChildOfClass("Humanoid")
    local hrp = alvo.Character:FindFirstChild("HumanoidRootPart")
    local meuHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or not meuHrp then return false end

    local antes = #encontrarMeusProps()

    spawnarProp(meuHrp.Position + (meuHrp.CFrame.LookVector * 4))
    task.wait(0.5)

    local agora = encontrarMeusProps()
    local prop = agora[#agora]

    if not prop then
        Notify("Props", "Clique 1x no chão para liberar o Prop!", 3)
        local t0 = tick()
        while tick() - t0 < 6 do
            task.wait(0.3)
            agora = encontrarMeusProps()
            if #agora > antes then
                prop = agora[#agora]
                break
            end
        end
    end

    if not prop then
        Notify("Props", "Prop não foi criado.", 2)
        return false
    end

    local sentou = false
    local tInicio = tick()
    local conexao

    conexao = RunService.Heartbeat:Connect(function()
        if sentou or (tick() - tInicio > TEMPO_MAX_SIT) then
            if conexao then conexao:Disconnect() end
            return
        end

        if not alvo.Character or not alvo.Character:FindFirstChild("HumanoidRootPart") then return end
        local hrpAtual = alvo.Character.HumanoidRootPart

        local t = tick() * PROP_MOVE_SPEED
        local offsetY = math.sin(t) * PROP_MOVE_RANGE
        moverProp(prop, CFrame.new(hrpAtual.Position + Vector3.new(0, offsetY, 0)))

        if hum.Sit then
            sentou = true
            if conexao then conexao:Disconnect() end
            task.wait(0.1)

            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                moverProp(prop, LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 0))
            end
            task.wait(0.8)
            deletarTodosProps()
        end
    end)
    return true
end

-- ==========================================================
-- 🔘 BOTÕES DA ABA PROPS
-- ==========================================================

UI.Button(Tabs.Troll, {
    Name = "💀 Kill Prop (Alvo)",
    Callback = function()
        if not alvoPropSelecionado then 
            Notify("Props", "Selecione um alvo!", 2) 
            return 
        end
        if not pegarPropMaker() then 
            Notify("Props", "Falha ao equipar caixa", 2) 
            return 
        end
        selecionarProp()
        Notify("Props", "Iniciando Kill Prop...", 2)
        task.spawn(function() executarKillProp(alvoPropSelecionado) end)
    end,
})

UI.Button(Tabs.Troll, {
    Name = "🎣 Bring Prop (Trazer Alvo)",
    Callback = function()
        if not alvoPropSelecionado then 
            Notify("Props", "Selecione um alvo!", 2) 
            return 
        end
        if not pegarPropMaker() then 
            Notify("Props", "Falha ao equipar caixa", 2) 
            return 
        end
        selecionarProp()
        Notify("Props", "Iniciando Bring Prop...", 2)
        task.spawn(function() executarBringProp(alvoPropSelecionado) end)
    end,
})

UI.Button(Tabs.Troll, {
    Name = "🧹 Limpar TODOS os Props",
    Callback = function()
        deletarTodosProps()
        Notify("Props", "Props limpos!", 2)
    end,
})

--------------------------------------------------------------------------------
-- ABA OUTROS
--------------------------------------------------------------------------------
UI.Button(Tabs.Outros, { 
    Name = "⚡ Otimizar Hub (Irreversível)", 
    Callback = function()
        pcall(function()
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then 
                    v.CastShadow = false 
                    v.Material = Enum.Material.SmoothPlastic 
                end
            end
        end)
    end 
})


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
UI.Button(Tabs.Protecao, {
    Name = "⚡ Ativar Anti-AFK (Evita Desconexão)",
    Callback = function()
        pcall(function()
            local vu = game:GetService("VirtualUser")
            LocalPlayer.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            end)
        end)
        Notify("Proteção", "Anti-AFK ativado!", 3)
    end
})

-- ==========================================================
-- 👻 INVISIBLE PLAYER
-- ==========================================================
local invisivelAtivo = false

UI.Toggle(Tabs.Player, {
    Name = "👻 Personagem Invisível",
    CurrentValue = false,
    Callback = function(state)
        invisivelAtivo = state
        local char = LocalPlayer.Character
        if not char then return end

        pcall(function()
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.Transparency = invisivelAtivo and 1 or 0
                elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then
                    part.Handle.Transparency = invisivelAtivo and 1 or 0
                end
            end
        end)

        if invisivelAtivo then
            Notify("Player", "Você está invisível!", 2)
        else
            Notify("Player", "Visibilidade restaurada!", 2)
        end
    end
})

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
-- ==========================================================
-- ⚙️ ABA CONFIG
-- ==========================================================

-- Variáveis globais
_G.RD4X_NotifAtivas = true
_G.RD4X_SomAtivo = true

-- Variável da borda pulsante (usada no bloco de baixo)
local bordaPulsando = true

-- ─── SEÇÃO: VISUAL ───
UI.Paragraph(Tabs.Config, {
    Title = "🎨 Visual",
    Content = "Controle os efeitos visuais do hub.",
    Height = 42
})

UI.Toggle(Tabs.Config, {
    Name = "🫧 Bolhas Coloridas",
    CurrentValue = true,
    Callback = function(v)
        bolhasAtivas = v
        if v then
            task.spawn(function()
                while bolhasAtivas and BolhasContainer.Parent do
                    criarBolha()
                    task.wait(math.random(8, 30) / 100)
                end
            end)
        end
    end
})

UI.Toggle(Tabs.Config, {
    Name = "💚 Borda Pulsante",
    CurrentValue = true,
    Callback = function(v)
        bordaPulsando = v
        if not v then
            strokeMain.Transparency = 0.3
            strokeMain.Thickness = 1.2
        end
    end
})

-- ─── SEÇÃO: COR DO HUB ───
UI.Paragraph(Tabs.Config, {
    Title = "🌈 Cor Notify",
    Content = "Escolha a cor das Notificações.",
    Height = 42
})

local function trocarCorHub(novaCor)
    COR_VERDE = novaCor
    
    for _, gui in ipairs(ScreenGui:GetDescendants()) do
        pcall(function()
            if gui:IsA("UIStroke") and (gui.Color == Color3.fromRGB(46, 204, 113) or gui.Color == Color3.fromRGB(240, 240, 245)) then
                gui.Color = novaCor
            end
            if gui:IsA("TextLabel") and gui.TextColor3 == Color3.fromRGB(46, 204, 113) then
                gui.TextColor3 = novaCor
            end
            if gui:IsA("TextButton") and gui.BackgroundColor3 == Color3.fromRGB(46, 204, 113) then
                gui.BackgroundColor3 = novaCor
            end
            if gui:IsA("Frame") and gui.BackgroundColor3 == Color3.fromRGB(46, 204, 113) then
                gui.BackgroundColor3 = novaCor
            end
        end)
    end
    
    Notify("Config", "Cor aplicada!", 2)
end

UI.Button(Tabs.Config, { Name = "🟢 Verde (padrão)", Callback = function() trocarCorHub(Color3.fromRGB(46, 204, 113)) end })
UI.Button(Tabs.Config, { Name = "🔵 Azul",           Callback = function() trocarCorHub(Color3.fromRGB(52, 152, 219)) end })
UI.Button(Tabs.Config, { Name = "🟣 Roxo",           Callback = function() trocarCorHub(Color3.fromRGB(155, 89, 182)) end })
UI.Button(Tabs.Config, { Name = "🔴 Vermelho",       Callback = function() trocarCorHub(Color3.fromRGB(231, 76, 60)) end })
UI.Button(Tabs.Config, { Name = "🟡 Amarelo",        Callback = function() trocarCorHub(Color3.fromRGB(241, 196, 15)) end })
UI.Button(Tabs.Config, { Name = "🟠 Laranja",        Callback = function() trocarCorHub(Color3.fromRGB(230, 126, 34)) end })
UI.Button(Tabs.Config, { Name = "🩷 Rosa",           Callback = function() trocarCorHub(Color3.fromRGB(255, 105, 180)) end })
UI.Button(Tabs.Config, { Name = "💠 Turquesa",       Callback = function() trocarCorHub(Color3.fromRGB(26, 188, 156)) end })

-- ─── SEÇÃO: NOTIFICAÇÕES E SONS ───
UI.Paragraph(Tabs.Config, {
    Title = "🔔 Notificações & Sons",
    Content = "Controle os avisos e sons do hub.",
    Height = 42
})

UI.Toggle(Tabs.Config, {
    Name = "🔔 Notificações",
    CurrentValue = true,
    Callback = function(v)
        _G.RD4X_NotifAtivas = v
        if v then Notify("Config", "Notificações ativadas", 2) end
    end
})

UI.Toggle(Tabs.Config, {
    Name = "🔊 Som de Clique",
    CurrentValue = true,
    Callback = function(v)
        _G.RD4X_SomAtivo = v
        if v then Notify("Config", "Som ativado", 2) end
    end
})

UI.Toggle(Tabs.Config, {
    Name = "🎵 Música de Fundo",
    CurrentValue = true,
    Callback = function(v)
        pcall(function()
            if _G.RD4X_MusicaFundo then
                if v then
                    _G.RD4X_MusicaFundo:Resume()
                else
                    _G.RD4X_MusicaFundo:Pause()
                end
            end
        end)
    end
})

UI.Input(Tabs.Config, {
    Name = "Volume da Música",
    CurrentValue = "0.15",
    PlaceholderText = "0 a 1",
    Callback = function(v)
        local n = tonumber(v) or 0.15
        pcall(function()
            if _G.RD4X_MusicaFundo then _G.RD4X_MusicaFundo.Volume = n end
        end)
    end,
})

-- ─── SEÇÃO: TRANSPARÊNCIA ───
UI.Paragraph(Tabs.Config, {
    Title = "🌫️ Transparência",
    Content = "Ajuste a transparência do hub.",
    Height = 42
})

UI.Input(Tabs.Config, {
    Name = "Transparência (0-1)",
    CurrentValue = "0.25",
    PlaceholderText = "0 = sólido",
    Callback = function(v)
        local n = tonumber(v) or 0.25
        MainFrame.BackgroundTransparency = n
        Notify("Config", "Transparência: " .. n, 2)
    end,
})

-- ─── SEÇÃO: PERFORMANCE ───
UI.Paragraph(Tabs.Config, {
    Title = "⚡ Performance",
    Content = "Reduza efeitos pra melhorar o FPS.",
    Height = 42
})

UI.Toggle(Tabs.Config, {
    Name = "⚡ Modo Leve (desativa efeitos)",
    CurrentValue = false,
    Callback = function(v)
        if v then
            bolhasAtivas = false
            bordaPulsando = false
            strokeMain.Transparency = 0.5
            Notify("Config", "Modo leve ativado", 2)
        else
            bolhasAtivas = true
            bordaPulsando = true
            task.spawn(function()
                while bolhasAtivas and BolhasContainer.Parent do
                    criarBolha()
                    task.wait(math.random(8, 30) / 100)
                end
            end)
            Notify("Config", "Modo normal", 2)
        end
    end,
})

UI.Button(Tabs.Config, {
    Name = "🗑️ Limpar Notificações",
    Callback = function()
        for _, notif in ipairs(NotifHolder:GetChildren()) do
            if notif:IsA("Frame") then notif:Destroy() end
        end
    end,
})

-- ─── SEÇÃO: SISTEMA ───
UI.Paragraph(Tabs.Config, {
    Title = "🛠️ Sistema",
    Content = "Controles gerais do hub.",
    Height = 42
})

UI.Button(Tabs.Config, {
    Name = "❌ Fechar Hub",
    Callback = function()
        MainFrame.Visible = false
        BotaoFlutuante.Visible = false
    end,
})

UI.Paragraph(Tabs.Config, {
    Title = "ℹ️ Sobre",
    Content = "Rd4X Hub v1.0\nBy Rd4X Team Oficial\nhttps://discord.gg/SsPh5Eyr9Q",
    Height = 70
})
-- ==========================================================
-- 💚 BORDA PULSANTE (controlada pela aba Config)
-- ==========================================================
task.spawn(function()
    while MainFrame.Parent do
        if bordaPulsando then
            TweenService:Create(strokeMain, TweenInfo.new(1.5), {Transparency = 0.8, Thickness = 2.5}):Play()
            task.wait(1.5)
            TweenService:Create(strokeMain, TweenInfo.new(1.5), {Transparency = 0.2, Thickness = 1.2}):Play()
            task.wait(1.5)
        else
            task.wait(0.5)
        end
    end
end) 
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
                if remoteName then remoteName:FireServer("RolePlayName", "👑 Rd4X Creator◾") end
            else
                if remoteName then remoteName:FireServer("RolePlayName", "🇧🇷 Rd4X Hub◾") end
            end
        end
    end)
end)
-- ==========================================================
-- 📢 POPUP DE ANÚNCIO (aparece ao abrir o hub)
-- ==========================================================
task.spawn(function()
    task.wait(1)

    -- Limpa se já existir
    local oldAd = CoreGui:FindFirstChild("Rd4X_Ad_Anuncio")
    if oldAd then oldAd:Destroy() end

    -- ScreenGui separado (pra não conflitar ZIndex)
    local AdGui = Instance.new("ScreenGui")
    AdGui.Name = "Rd4X_Ad_Anuncio"
    AdGui.ResetOnSpawn = false
    AdGui.DisplayOrder = 9999
    AdGui.IgnoreGuiInset = true
    AdGui.Parent = CoreGui

    -- Frame principal
    local anuncio = Instance.new("Frame", AdGui)
    anuncio.Size = UDim2.new(0, 0, 0, 0)
    anuncio.Position = UDim2.new(0.5, 0, 0.5, 0)
    anuncio.BackgroundColor3 = COR_FUNDO
    anuncio.BackgroundTransparency = 0
    anuncio.BorderSizePixel = 0
    anuncio.ClipsDescendants = true
    anuncio.ZIndex = 1

    local cAd = Instance.new("UICorner", anuncio)
    cAd.CornerRadius = UDim.new(0, 10)

    local sAd = Instance.new("UIStroke", anuncio)
    sAd.Color = COR_VERDE
    sAd.Thickness = 2
    sAd.ZIndex = 2

    -- 🫧 Bolhas coloridas dentro do anúncio
    local bolhasAd = Instance.new("Frame", anuncio)
    bolhasAd.Size = UDim2.new(1, 0, 1, 0)
    bolhasAd.BackgroundTransparency = 1
    bolhasAd.ClipsDescendants = true
    bolhasAd.ZIndex = 0

    local adAberto = true

    task.spawn(function()
        while adAberto and bolhasAd.Parent do
            local tam = math.random(5, 12)
            local b = Instance.new("Frame", bolhasAd)
            b.Size = UDim2.new(0, tam, 0, tam)
            b.Position = UDim2.new(math.random(), 0, 1, 5)
            local cores = {
                Color3.fromRGB(46, 204, 113),
                Color3.fromRGB(52, 152, 219),
                Color3.fromRGB(155, 89, 182),
                Color3.fromRGB(241, 196, 15),
                Color3.fromRGB(231, 76, 60),
            }
            b.BackgroundColor3 = cores[math.random(1, #cores)]
            b.BackgroundTransparency = math.random(20, 45) / 100
            b.BorderSizePixel = 0
            b.ZIndex = 0

            local cc = Instance.new("UICorner", b)
            cc.CornerRadius = UDim.new(1, 0)

            local tw = TweenService:Create(b, TweenInfo.new(math.random(4, 8), Enum.EasingStyle.Linear), {
                Position = UDim2.new(b.Position.X.Scale, 0, 0, -15),
                BackgroundTransparency = 1
            })
            tw:Play()
            tw.Completed:Connect(function() if b and b.Parent then b:Destroy() end end)
            task.wait(math.random(12, 35) / 100)
        end
    end)

    -- ─── Header ───
    local adHeader = Instance.new("Frame", anuncio)
    adHeader.Size = UDim2.new(1, 0, 0, 40)
    adHeader.BackgroundColor3 = COR_SECUNDARIA
    adHeader.BackgroundTransparency = 0.1
    adHeader.BorderSizePixel = 0
    adHeader.ZIndex = 2

    local cH = Instance.new("UICorner", adHeader)
    cH.CornerRadius = UDim.new(0, 10)

    local adIcon = Instance.new("TextLabel", adHeader)
    adIcon.Size = UDim2.new(0, 24, 0, 24)
    adIcon.Position = UDim2.new(0, 10, 0.5, -12)
    adIcon.BackgroundTransparency = 1
    adIcon.Text = "📢"
    adIcon.TextSize = 15
    adIcon.ZIndex = 3

    local adTitle = Instance.new("TextLabel", adHeader)
    adTitle.Size = UDim2.new(1, -70, 1, 0)
    adTitle.Position = UDim2.new(0, 40, 0, 0)
    adTitle.BackgroundTransparency = 1
    adTitle.Text = "Updates!"
    adTitle.TextColor3 = COR_VERDE
    adTitle.TextSize = 13
    adTitle.Font = Enum.Font.GothamBold
    adTitle.TextXAlignment = Enum.TextXAlignment.Left
    adTitle.ZIndex = 3

    local adClose = Instance.new("TextButton", adHeader)
    adClose.Size = UDim2.new(0, 24, 0, 24)
    adClose.Position = UDim2.new(1, -32, 0.5, -12)
    adClose.BackgroundTransparency = 1
    adClose.Text = "✕"
    adClose.TextColor3 = COR_TEXTO_CINZA
    adClose.TextSize = 14
    adClose.Font = Enum.Font.GothamBold
    adClose.AutoButtonColor = false
    adClose.ZIndex = 3

    adClose.MouseEnter:Connect(function() adClose.TextColor3 = COR_VERMELHO end)
    adClose.MouseLeave:Connect(function() adClose.TextColor3 = COR_TEXTO_CINZA end)

    -- ─── Conteúdo (EDITA AQUI) ───
    local adText = Instance.new("TextLabel", anuncio)
    adText.Size = UDim2.new(1, -20, 1, -80)
    adText.Position = UDim2.new(0, 10, 0, 48)
    adText.BackgroundTransparency = 1
    adText.Text = "🎉 Bem-vindo ao Rd4X Hub!\n\nEste hub foi lançado a pouco tempo e já está com diversas funções!... Mas, essa é a primeira versão de muitas, por isso, se achar bugs/falhas nos conte no Discord!\n\nPara Desativar a Música de Fundo, vá até a Aba Config-Música de Fundo."
    adText.TextColor3 = COR_TEXTO
    adText.TextSize = 11
    adText.Font = Enum.Font.Gotham
    adText.TextXAlignment = Enum.TextXAlignment.Left
    adText.TextYAlignment = Enum.TextYAlignment.Top
    adText.TextWrapped = true
    adText.ZIndex = 3

    -- ─── Botão "Entendi!" ───
    local adOk = Instance.new("TextButton", anuncio)
    adOk.Size = UDim2.new(1, -20, 0, 32)
    adOk.Position = UDim2.new(0, 10, 1, -42)
    adOk.BackgroundColor3 = COR_VERDE
    adOk.BackgroundTransparency = 0
    adOk.BorderSizePixel = 0
    adOk.Text = "Entendi!"
    adOk.TextColor3 = Color3.fromRGB(255, 255, 255)
    adOk.TextSize = 12
    adOk.Font = Enum.Font.GothamBold
    adOk.AutoButtonColor = false
    adOk.ZIndex = 3

    local cOk = Instance.new("UICorner", adOk)
    cOk.CornerRadius = UDim.new(0, 6)

    -- ─── Fechar com animação ───
    local function fecharAd()
        adAberto = false
        TweenService:Create(anuncio, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        }):Play()
        for _, obj in ipairs(anuncio:GetDescendants()) do
            pcall(function()
                if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    TweenService:Create(obj, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                elseif obj:IsA("Frame") then
                    TweenService:Create(obj, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                elseif obj:IsA("UIStroke") then
                    TweenService:Create(obj, TweenInfo.new(0.3), {Transparency = 1}):Play()
                end
            end)
        end
        task.wait(0.35)
        AdGui:Destroy()
    end

    adClose.MouseButton1Click:Connect(fecharAd)
    adOk.MouseButton1Click:Connect(fecharAd)

    -- 🎬 Animação de entrada
    TweenService:Create(anuncio, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 340, 0, 220),
        Position = UDim2.new(0.5, -170, 0.5, -110)
    }):Play()
end)

Notify("RD4X Hub", "Interface carregada com sucesso!", 4)
-- ==========================================================
-- 🎵 MÚSICA DE FUNDO
-- ==========================================================
_G.RD4X_MusicaFundo = Instance.new("Sound", SoundService)
_G.RD4X_MusicaFundo.SoundId = "rbxassetid://134959834418523"
_G.RD4X_MusicaFundo.Volume = 0.15
_G.RD4X_MusicaFundo.Looped = true
_G.RD4X_MusicaFundo:Play()
UI.Button(Tabs.Outros, {
    Name = "🎵 Play/Pause Música",
    Callback = function()
        if _G.RD4X_MusicaFundo.IsPlaying then
            _G.RD4X_MusicaFundo:Pause()
            Notify("Música", "Música pausada", 2)
        else
            _G.RD4X_MusicaFundo:Resume()
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
-- ==========================================================
-- 📝 AUTO-BIO: Welcome, NomeDoJogador (aplica 1x ao executar)
-- ==========================================================
task.spawn(function()
    task.wait(2)   -- espera o hub carregar

    local RE = ReplicatedStorage:FindFirstChild("RE")
    local RPNameText = RE and RE:FindFirstChild("1RPNam1eTex1t")

    if not RPNameText then
        -- tenta de novo depois (alguns servidores demoram pra carregar o RE)
        task.wait(2)
        RE = ReplicatedStorage:FindFirstChild("RE")
        RPNameText = RE and RE:FindFirstChild("1RPNam1eTex1t")
    end

    if RPNameText then
        local textoBio = "Welcome, " .. LocalPlayer.Name
        pcall(function()
            RPNameText:FireServer("RolePlayBio", textoBio)
        end)
    end
end)
-- ==========================================================
-- 🔒 SEGUNDO MENU VIP/ADMIN
-- ==========================================================
if UsuarioAutorizado then

    local oldVIPGui = CoreGui:FindFirstChild("Rd4XHubVIP")
    if oldVIPGui then oldVIPGui:Destroy() end
    
    local ScreenGuiVIP = Instance.new("ScreenGui")
    ScreenGuiVIP.Name = "Rd4XHubVIP"
    ScreenGuiVIP.ResetOnSpawn = false
    ScreenGuiVIP.DisplayOrder = 1000
    ScreenGuiVIP.Parent = CoreGui
    
    -- ⭐ Painel MENOR: 480x340
    local MainFrameVIP = Instance.new("Frame", ScreenGuiVIP)
    MainFrameVIP.Name = "MainFrameVIP"
    MainFrameVIP.Size = UDim2.new(0, 480, 0, 340)
    MainFrameVIP.Position = UDim2.new(0.5, -240, 0.5, -170)
    MainFrameVIP.BackgroundColor3 = COR_FUNDO
    MainFrameVIP.BackgroundTransparency = TRANSP_FUNDO
    MainFrameVIP.BorderSizePixel = 0
    MainFrameVIP.ClipsDescendants = true
    MainFrameVIP.ZIndex = 1
    MainFrameVIP.Visible = false   -- 👈 começa invisível
    MainFrameVIP.Active = false    -- 👈 evita conflito de drag
    
    local cornerVIP = Instance.new("UICorner", MainFrameVIP)
    cornerVIP.CornerRadius = UDim.new(0, 10)
    
    -- ❌ SEM borda verde (removi o UIStroke)
    
    -- 🫧 Bolhas coloridas do menu VIP
    local BolhasVIP = Instance.new("Frame", MainFrameVIP)
    BolhasVIP.Name = "BolhasVIP"
    BolhasVIP.Size = UDim2.new(1, 0, 1, 0)
    BolhasVIP.BackgroundTransparency = 1
    BolhasVIP.ClipsDescendants = true
    BolhasVIP.ZIndex = 0
    BolhasVIP.Active = false
    
    task.spawn(function()
        while BolhasVIP.Parent do
            local tam = math.random(6, 14)
            local b = Instance.new("Frame", BolhasVIP)
            b.Size = UDim2.new(0, tam, 0, tam)
            b.Position = UDim2.new(math.random() * 0.95, 0, 1, 10)
            local cores = {
                Color3.fromRGB(46, 204, 113),
                Color3.fromRGB(52, 152, 219),
                Color3.fromRGB(155, 89, 182),
                Color3.fromRGB(241, 196, 15),
                Color3.fromRGB(231, 76, 60),
            }
            b.BackgroundColor3 = cores[math.random(1, #cores)]
            b.BackgroundTransparency = math.random(15, 40) / 100
            b.BorderSizePixel = 0
            b.ZIndex = 0
            
            local c = Instance.new("UICorner", b)
            c.CornerRadius = UDim.new(1, 0)
            
            local strokeB = Instance.new("UIStroke", b)
            strokeB.Color = Color3.fromRGB(255, 255, 255)
            strokeB.Thickness = 1.5
            strokeB.Transparency = 0.3
            
            local tween = TweenService:Create(b, TweenInfo.new(math.random(6, 12), Enum.EasingStyle.Linear), {
                Position = UDim2.new(b.Position.X.Scale, math.random(-60, 60), 0, -20),
                BackgroundTransparency = 1
            })
            tween:Play()
            tween.Completed:Connect(function() if b and b.Parent then b:Destroy() end end)
            task.wait(math.random(8, 30) / 100)
        end
    end)
    
    -- Header VIP
    local HeaderVIP = Instance.new("Frame", MainFrameVIP)
    HeaderVIP.Size = UDim2.new(1, 0, 0, 38)
    HeaderVIP.BackgroundTransparency = 1
    HeaderVIP.ZIndex = 5
    
    local IconVIP = Instance.new("ImageLabel", HeaderVIP)
    IconVIP.Size = UDim2.new(0, 24, 0, 24)
    IconVIP.Position = UDim2.new(0, 10, 0, 7)
    IconVIP.BackgroundTransparency = 1
    IconVIP.Image = "rbxassetid://109276734890323"
    IconVIP.ScaleType = Enum.ScaleType.Crop
    IconVIP.ZIndex = 6
    local cIVIP = Instance.new("UICorner", IconVIP)
    cIVIP.CornerRadius = UDim.new(1, 0)
    
    local TitleVIP = Instance.new("TextLabel", HeaderVIP)
    TitleVIP.Size = UDim2.new(0, 300, 0, 38)
    TitleVIP.Position = UDim2.new(0, 34, 0, 0)
    TitleVIP.BackgroundTransparency = 1
    TitleVIP.Text = "🔒 Rd4X Hub VIP $ 「 Exclusivo 」"
    TitleVIP.TextColor3 = COR_VERDE
    TitleVIP.TextSize = 11
    TitleVIP.Font = Enum.Font.GothamBold
    TitleVIP.TextXAlignment = Enum.TextXAlignment.Left
    TitleVIP.ZIndex = 6
    
    local BadgeVIP = Instance.new("TextLabel", HeaderVIP)
    BadgeVIP.Size = UDim2.new(0, 60, 0, 38)
    BadgeVIP.Position = UDim2.new(1, -90, 0, 0)
    BadgeVIP.BackgroundTransparency = 1
    BadgeVIP.Text = "⭐ VIP"
    BadgeVIP.TextColor3 = COR_VERDE
    BadgeVIP.TextSize = 10
    BadgeVIP.Font = Enum.Font.GothamBold
    BadgeVIP.TextXAlignment = Enum.TextXAlignment.Right
    BadgeVIP.ZIndex = 6
    
    -- Botão MINIMIZAR
    local MinimizeVIP = Instance.new("TextButton", HeaderVIP)
    MinimizeVIP.Size = UDim2.new(0, 20, 0, 20)
    MinimizeVIP.Position = UDim2.new(1, -26, 0, 9)
    MinimizeVIP.BackgroundTransparency = 1
    MinimizeVIP.Text = "—"
    MinimizeVIP.TextColor3 = COR_TEXTO_CINZA
    MinimizeVIP.TextSize = 14
    MinimizeVIP.Font = Enum.Font.GothamBold
    MinimizeVIP.ZIndex = 6
    MinimizeVIP.AutoButtonColor = false
    
    MinimizeVIP.MouseEnter:Connect(function()
        MinimizeVIP.TextColor3 = COR_TEXTO
    end)
    MinimizeVIP.MouseLeave:Connect(function()
        MinimizeVIP.TextColor3 = COR_TEXTO_CINZA
    end)
    
    -- Sidebar VIP
    local SidebarVIP = Instance.new("ScrollingFrame", MainFrameVIP)
    SidebarVIP.Size = UDim2.new(0, 130, 1, -38)
    SidebarVIP.Position = UDim2.new(0, 0, 0, 38)
    SidebarVIP.BackgroundColor3 = COR_SIDEBAR
    SidebarVIP.BackgroundTransparency = TRANSP_SIDEBAR
    SidebarVIP.BorderSizePixel = 0
    SidebarVIP.ScrollBarThickness = 2
    SidebarVIP.CanvasSize = UDim2.new(0, 0, 0, 0)
    SidebarVIP.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SidebarVIP.ZIndex = 5
    
    local layoutVIP = Instance.new("UIListLayout", SidebarVIP)
    layoutVIP.Padding = UDim.new(0, 3)
    layoutVIP.SortOrder = Enum.SortOrder.LayoutOrder
    
    local padVIP = Instance.new("UIPadding", SidebarVIP)
    padVIP.PaddingTop = UDim.new(0, 6)
    padVIP.PaddingBottom = UDim.new(0, 6)
    padVIP.PaddingLeft = UDim.new(0, 6)
    padVIP.PaddingRight = UDim.new(0, 6)
    
    -- Sistema de abas VIP
    local TabFramesVIP = {}
    local TabButtonsVIP = {}
    
    local function ShowTabVIP(name)
        for n, f in pairs(TabFramesVIP) do f.Visible = (n == name) end
        for n, b in pairs(TabButtonsVIP) do
            if n == name then
                b.BackgroundTransparency = TRANSP_CARDS
                b.TextColor3 = COR_TEXTO
            else
                b.BackgroundTransparency = 1
                b.TextColor3 = COR_TEXTO_CINZA
            end
        end
    end
    
    local function CreateTabVIP(name)
        local btn = Instance.new("TextButton", SidebarVIP)
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
        
        local content = Instance.new("ScrollingFrame", MainFrameVIP)
        content.Size = UDim2.new(1, -142, 1, -50)
        content.Position = UDim2.new(0, 136, 0, 44)
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
        
        TabFramesVIP[name] = content
        TabButtonsVIP[name] = btn
        
        btn.MouseButton1Click:Connect(function() ShowTabVIP(name) end)
        return content
    end
    
    local TabsVIP = {
        Admin = CreateTabVIP("👑 Admin"),
        VIP = CreateTabVIP("VIP"),
        Jumpscare = CreateTabVIP("Jumpscare"),
    }
    
    ShowTabVIP("👑 Admin")
    
    -- 🎯 Drag SEPARADO (não conflita com o menu principal)
    local dragVIP = false
    local startVIP = nil
    local posVIP = nil
    
    MainFrameVIP.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragVIP = true
            startVIP = input.Position
            posVIP = MainFrameVIP.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then 
                    dragVIP = false 
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragVIP and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startVIP
            MainFrameVIP.Position = UDim2.new(posVIP.X.Scale, posVIP.X.Offset + delta.X, posVIP.Y.Scale, posVIP.Y.Offset + delta.Y)
        end
    end)
    
    -- Botão MINIMIZAR
    local vipMinimizado = false
    local alturaVIPNormal = 340
    local alturaVIPMinimizada = 38
    
    MinimizeVIP.MouseButton1Click:Connect(function()
        vipMinimizado = not vipMinimizado
        if vipMinimizado then
            TweenService:Create(MainFrameVIP, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 480, 0, alturaVIPMinimizada)
            }):Play()
            SidebarVIP.Visible = false
            for _, c in pairs(TabFramesVIP) do c.Visible = false end
            MinimizeVIP.Text = "▢"
            MinimizeVIP.TextColor3 = COR_VERDE
        else
            TweenService:Create(MainFrameVIP, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 480, 0, alturaVIPNormal)
            }):Play()
            task.wait(0.35)
            SidebarVIP.Visible = true
            for n, c in pairs(TabFramesVIP) do
                if TabButtonsVIP[n].TextColor3 == COR_TEXTO then
                    c.Visible = true
                end
            end
            MinimizeVIP.Text = "—"
            MinimizeVIP.TextColor3 = COR_TEXTO_CINZA
        end
    end)
    
    -- ═══════════════════════════════════════════════════════
    -- 👑 CONTEÚDO ADMIN
    -- ═══════════════════════════════════════════════════════
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

    local DropdownAdmin = UI.Dropdown(TabsVIP.Admin, {
        Name = "Lista de Usuários do Hub",
        Options = obterUsuariosDoHub(),
        CurrentOption = {LocalPlayer.Name},
        Callback = function(Option) AlvoSelecionado = Option[1] end,
    })

    UI.Button(TabsVIP.Admin, { Name = "🔄 Atualizar Hub (Lista)", Callback = function()
        DropdownAdmin:Refresh(obterUsuariosDoHub())
        Notify("Admin", "Lista atualizada!", 3)
    end})

    local cameraOriginalCFrame = nil

    UI.Button(TabsVIP.Admin, { Name = "Cam (ver câmera)", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("Head") then
            cameraOriginalCFrame = Camera.CFrame
            Camera.CameraSubject = alvo.Character.Humanoid
            Notify("Admin", "Assistindo " .. alvo.Name, 2)
        end
    end})

    UI.Button(TabsVIP.Admin, { Name = "Voltar Cam", Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
            if cameraOriginalCFrame then Camera.CFrame = cameraOriginalCFrame end
            Notify("Admin", "Câmera restaurada.", 2)
        end
    end})

    UI.Button(TabsVIP.Admin, { Name = "Kick", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo == LocalPlayer then LocalPlayer:Kick("Kickado") end
        Notify("Admin", "Kick enviado.", 2)
    end})

    UI.Button(TabsVIP.Admin, { Name = "Kill", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("Humanoid") then
            alvo.Character.Humanoid.Health = 0
            Notify("Admin", "Kill executado.", 2)
        end
    end})

    UI.Button(TabsVIP.Admin, { Name = "Freeze", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") then
            alvo.Character.HumanoidRootPart.Anchored = true
            Notify("Admin", "Congelado.", 2)
        end
    end})

    UI.Button(TabsVIP.Admin, { Name = "Unfreeze", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") then
            alvo.Character.HumanoidRootPart.Anchored = false
            Notify("Admin", "Descongelado.", 2)
        end
    end})

    UI.Button(TabsVIP.Admin, { Name = "Jail", Callback = function()
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

    UI.Button(TabsVIP.Admin, { Name = "UnJail", Callback = function()
        if JaulaModelo then JaulaModelo:Destroy(); JaulaModelo = nil end
        Notify("Admin", "Jaula removida!", 2)
    end})

    UI.Button(TabsVIP.Admin, { Name = "Bring", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            alvo.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            Notify("Admin", "Jogador trazido.", 2)
        end
    end})

    UI.Button(TabsVIP.Admin, { Name = "Teleport", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = alvo.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            Notify("Admin", "Teleportado.", 2)
        end
    end})

    UI.Button(TabsVIP.Admin, { Name = "Fling", Callback = function()
        local alvo = Players:FindFirstChild(AlvoSelecionado)
        if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") then
            alvo.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999)
            Notify("Admin", "Fling aplicado!", 2)
        end
    end})

    UI.Button(TabsVIP.Admin, { Name = "Spam", Callback = function()
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

    UI.Button(TabsVIP.Admin, { Name = "UnSpam", Callback = function()
        if conexaoSpam then task.cancel(conexaoSpam); conexaoSpam = nil end
        Notify("Admin", "Spam desativado.", 2)
    end})
    -- ==========================================================
-- 😱 ABA JUMPSCARE
-- ==========================================================
--
-- 🎨 COMO ADICIONAR SEUS JUMPSCARES:
--
--     ["Jumpscare 1"] = {
--         imagem = "rbxassetid://80935650312065",
--         som    = "rbxassetid://140558918020400",
--     },
--
-- ═══════════════════════════════════════════════════════════
local LISTA_JUMPSCARES = {

    -- ═══════════════════════════════════════════════════════
    -- 👇 ADICIONE SEUS JUMPSCARES AQUI EMBAIXO
    -- ═══════════════════════════════════════════════════════

    -- ─── Exemplos (podem ser deletados) ───
    ["Jumpscare 1"] = {
        imagem = "rbxassetid://83706098778583",
        som    = "rbxassetid://130586258888902",
    },

    ["😱 Jumpscare 2"] = {
        imagem = "rbxassetid://125557150437761",
        som    = "rbxassetid://133973334152130",
    },

    ["Jumpscare 3"] = {
        imagem = "rbxassetid://117625655704744",
        som    = "rbxassetid://140558918020400",
    },

    -- ─── Seus jumpscares personalizados ───
    ["🔴 Jumpscare 4"] = {
        imagem = "rbxassetid://106883295632038",
        som    = "rbxassetid://130586258888902",
    },

    ["🔴 Jumpscare 5"] = {
        imagem = "rbxassetid://105916553275189",
        som    = "rbxassetid://140558918020400",
    },
    -- 👆 ADICIONE MAIS AQUI EM CIMA
    -- ═══════════════════════════════════════════════════════
}

-- ─── Gera a lista de nomes pro dropdown ───
local function obterNomesJumpscare()
    local nomes = {}
    for nome, _ in pairs(LISTA_JUMPSCARES) do
        table.insert(nomes, nome)
    end
    table.sort(nomes)
    return nomes
end

-- ─── Função que executa o jumpscare ───
local function executarJumpscare(nomeAlvo, nomeJumpscare)
    local alvo = Players:FindFirstChild(nomeAlvo)
    if not alvo then
        Notify("Jumpscare", "Alvo não encontrado!", 2)
        return
    end

    local pg = alvo:FindFirstChild("PlayerGui")
    if not pg then return end

    local dados = LISTA_JUMPSCARES[nomeJumpscare]
    if not dados then
        Notify("Jumpscare", "Jumpscare inválido!", 2)
        return
    end

    -- 🔊 Toca o som
    pcall(function()
        local som = Instance.new("Sound", SoundService)
        som.SoundId = dados.som
        som.Volume = 5
        som:Play()
        task.delay(3, function() som:Destroy() end)
    end)

    -- 🖼️ Cria a tela do jumpscare
    local sgJump = Instance.new("ScreenGui", pg)
    sgJump.Name = "RD4X_JumpScare"
    sgJump.IgnoreGuiInset = true
    sgJump.DisplayOrder = 99999

    -- 🔴 Flash vermelho
    local flash = Instance.new("Frame", sgJump)
    flash.Size = UDim2.new(1, 0, 1, 0)
    flash.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    flash.BackgroundTransparency = 0
    flash.BorderSizePixel = 0

    -- 👹 Cara
    local cara = Instance.new("ImageLabel", sgJump)
    cara.Size = UDim2.new(0.3, 0, 0.3, 0)
    cara.Position = UDim2.new(0.35, 0, 0.35, 0)
    cara.BackgroundTransparency = 1
    cara.Image = dados.imagem
    cara.ScaleType = Enum.ScaleType.Fit
    cara.ImageTransparency = 0

    -- 🎬 Efeitos
    task.spawn(function()
        TweenService:Create(cara, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Size = UDim2.new(1.5, 0, 1.5, 0),
            Position = UDim2.new(-0.25, 0, -0.25, 0)
        }):Play()

        local Lighting = game:GetService("Lighting")
        local blur = Instance.new("BlurEffect", Lighting)
        blur.Size = 0
        TweenService:Create(blur, TweenInfo.new(0.1), {Size = 24}):Play()

        for i = 1, 6 do
            TweenService:Create(flash, TweenInfo.new(0.05), {BackgroundTransparency = 0}):Play()
            task.wait(0.05)
            TweenService:Create(flash, TweenInfo.new(0.05), {BackgroundTransparency = 0.6}):Play()
            task.wait(0.05)
        end

        if alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = alvo.Character.HumanoidRootPart
            local offsetOriginal = hrp.CFrame
            task.spawn(function()
                for i = 1, 10 do
                    hrp.CFrame = offsetOriginal * CFrame.new(
                        math.random(-30, 30) / 100,
                        math.random(-30, 30) / 100,
                        0
                    )
                    task.wait(0.02)
                end
                hrp.CFrame = offsetOriginal
            end)
        end

        task.wait(2.5)
        TweenService:Create(cara, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
        TweenService:Create(blur, TweenInfo.new(0.3), {Size = 0}):Play()
        TweenService:Create(flash, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.wait(0.4)
        blur:Destroy()
        sgJump:Destroy()
    end)
end

-- ═══════════════════════════════════════════════════════════
-- 🎨 UI DA ABA JUMPSCARE
-- ═══════════════════════════════════════════════════════════

UI.Paragraph(TabsVIP.Jumpscare, {
    Title = "😱 Sistema de Jumpscare",
    Content = "Escolha um jumpscare da lista e envie pro alvo.",
    Height = 42
})

-- Dropdown de seleção
local jumpscareSelecionado = nil
local nomesJumpscare = obterNomesJumpscare()
if #nomesJumpscare > 0 then
    jumpscareSelecionado = nomesJumpscare[1]
end

UI.Dropdown(TabsVIP.Jumpscare, {
    Name = "😱 Escolha o Jumpscare",
    Options = nomesJumpscare,
    CurrentOption = {jumpscareSelecionado or "Nenhum"},
    Callback = function(opt)
        if opt and opt[1] then
            jumpscareSelecionado = opt[1]
        end
    end,
})

-- Botão principal
UI.Button(TabsVIP.Jumpscare, {
    Name = "😱 Ativar Jumpscare no Alvo",
    Callback = function()
        if not AlvoSelecionado then
            Notify("Jumpscare", "Selecione um alvo na aba Admin!", 2)
            return
        end
        if not jumpscareSelecionado then
            Notify("Jumpscare", "Escolha um jumpscare!", 2)
            return
        end
        executarJumpscare(AlvoSelecionado, jumpscareSelecionado)
        Notify("😱 Jumpscare", "Susto em " .. AlvoSelecionado, 3)
    end,
})

-- Botão: enviar pra TODOS os jogadores
UI.Button(TabsVIP.Jumpscare, {
    Name = "😱 Jumpscare em TODOS os Jogadores",
    Callback = function()
        if not jumpscareSelecionado then
            Notify("Jumpscare", "Escolha um jumpscare!", 2)
            return
        end
        local enviados = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                executarJumpscare(p.Name, jumpscareSelecionado)
                enviados = enviados + 1
                task.wait(0.3)
            end
        end
        Notify("😱 Jumpscare", "Susto em " .. enviados .. " jogadores!", 3)
    end,
})

    -- ═══════════════════════════════════════════════════════
    -- 🎬 EFEITO DE ENTRADA (só quando o loading terminar)
    -- ═══════════════════════════════════════════════════════
    task.spawn(function()
        -- Espera o loading terminar
        while not _G.RD4X_Loading_Completo do
            task.wait(0.1)
        end
        
        -- Aguarda 0.3s pra dar um tempo
        task.wait(0.3)
        
        -- Animação de entrada
        MainFrameVIP.Visible = true
        MainFrameVIP.Size = UDim2.new(0, 0, 0, 0)
        MainFrameVIP.Position = UDim2.new(0.5, 0, 0.5, 0)
        MainFrameVIP.BackgroundTransparency = 1
        
        TweenService:Create(MainFrameVIP, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 480, 0, 340),
            Position = UDim2.new(0.5, -240, 0.5, -170),
            BackgroundTransparency = TRANSP_FUNDO
        }):Play()
    end)
    
end
