-- ==========================================================
-- 🇧🇷 Rd4X Hub Oficial - Brookhaven RP
-- Creator: J. Epstein ( By Rd4X Team oficial )
-- Versão: 4.0 (Interface Fixa, Minimizar Interativo & Toggle Button)
-- ==========================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- ==========================================================
-- PALETA DE CORES
-- ==========================================================
local COR_FUNDO = Color3.fromRGB(18, 18, 22)           -- Fundo Escuro Fosco
local COR_SIDEBAR = Color3.fromRGB(22, 22, 26)         -- Barra Lateral
local COR_SECUNDARIA = Color3.fromRGB(28, 28, 34)      -- Cards e Opções Ativas
local COR_TEXTO = Color3.fromRGB(240, 240, 245)        -- Texto Principal
local COR_TEXTO_CINZA = Color3.fromRGB(140, 140, 150)  -- Subtítulos e Créditos
local COR_VERDE = Color3.fromRGB(46, 204, 113)         -- Botão Copy Link / Sucesso
local COR_VERMELHO = Color3.fromRGB(231, 76, 60)       -- Vermelho Destaque / Alerta
local COR_BORDA = Color3.fromRGB(40, 40, 48)           -- Borda Discreta

-- Remove UI antiga se existir
local oldGui = CoreGui:FindFirstChild("Rd4XHubOficial")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Rd4XHubOficial"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999 -- Garante prioridade acima de qualquer UI do jogo
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- ==========================================================
-- BOTÃO FLUTUANTE DE ABRIR/FECHAR (TOGGLE BUTTON)
-- ==========================================================
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleHubBtn"
ToggleBtn.Size = UDim2.new(0, 42, 0, 42)
ToggleBtn.Position = UDim2.new(0, 15, 0.5, -21)
ToggleBtn.BackgroundColor3 = COR_SIDEBAR
ToggleBtn.Text = "🇧🇷"
ToggleBtn.TextSize = 20
ToggleBtn.ZIndex = 1000000
ToggleBtn.Parent = ScreenGui

local cornerToggle = Instance.new("UICorner", ToggleBtn)
cornerToggle.CornerRadius = UDim.new(0, 21)

local strokeToggle = Instance.new("UIStroke", ToggleBtn)
strokeToggle.Color = COR_VERMELHO
strokeToggle.Thickness = 1.5

-- Torna o botão flutuante arrastável na tela
local draggingTB, dragStartTB, startPosTB
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingTB = true
        dragStartTB = input.Position
        startPosTB = ToggleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingTB = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingTB and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartTB
        ToggleBtn.Position = UDim2.new(startPosTB.X.Scale, startPosTB.X.Offset + delta.X, startPosTB.Y.Scale, startPosTB.Y.Offset + delta.Y)
    end
end)

-- ==========================================================
-- JANELA PRINCIPAL
-- ==========================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 530, 0, 370)
MainFrame.Position = UDim2.new(0.5, -265, 0.5, -185)
MainFrame.BackgroundColor3 = COR_FUNDO
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 999999
MainFrame.Parent = ScreenGui

local cornerMain = Instance.new("UICorner", MainFrame)
cornerMain.CornerRadius = UDim.new(0, 10)

local strokeMain = Instance.new("UIStroke", MainFrame)
strokeMain.Color = COR_BORDA
strokeMain.Thickness = 1.2

-- Ação do Botão Flutuante (Abrir / Fechar)
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Sistema de Arrastar da Janela Principal
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

-- ==========================================================
-- TOPO (HEADER)
-- ==========================================================
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 38)
Header.BackgroundTransparency = 1

local IconHeader = Instance.new("TextLabel", Header)
IconHeader.Size = UDim2.new(0, 20, 0, 20)
IconHeader.Position = UDim2.new(0, 10, 0, 9)
IconHeader.BackgroundTransparency = 1
IconHeader.Text = "🇧🇷"
IconHeader.TextSize = 13

local TitleHeader = Instance.new("TextLabel", Header)
TitleHeader.Size = UDim2.new(0, 280, 0, 38)
TitleHeader.Position = UDim2.new(0, 34, 0, 0)
TitleHeader.BackgroundTransparency = 1
TitleHeader.Text = "Rd4X Hub Oficial $ 「 Brookhaven RP 🇧🇷 」"
TitleHeader.TextColor3 = COR_VERMELHO
TitleHeader.TextSize = 11
TitleHeader.Font = Enum.Font.GothamBold
TitleHeader.TextXAlignment = Enum.TextXAlignment.Left

local UserCredit = Instance.new("TextLabel", Header)
UserCredit.Size = UDim2.new(0, 220, 0, 38)
UserCredit.Position = UDim2.new(1, -270, 0, 0)
UserCredit.BackgroundTransparency = 1
UserCredit.Text = "By Rd4X Team oficial ( Creator : J. Epstein )"
UserCredit.TextColor3 = COR_VERDE
UserCredit.TextSize = 9
UserCredit.Font = Enum.Font.Gotham
UserCredit.TextXAlignment = Enum.TextXAlignment.Right

-- Botões de Minimizar e Fechar
local MinimizeBtn = Instance.new("TextButton", Header)
MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
MinimizeBtn.Position = UDim2.new(1, -44, 0, 9)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = COR_TEXTO_CINZA
MinimizeBtn.TextSize = 12
MinimizeBtn.Font = Enum.Font.GothamBold

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -24, 0, 9)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = COR_TEXTO_CINZA
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = COR_VERMELHO}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = COR_TEXTO_CINZA}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ==========================================================
-- BARRA LATERAL & CONTEÚDO PRINCIPAL
-- ==========================================================
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, -38)
Sidebar.Position = UDim2.new(0, 0, 0, 38)
Sidebar.BackgroundColor3 = COR_SIDEBAR
Sidebar.BorderSizePixel = 0

local sideLayout = Instance.new("UIListLayout", Sidebar)
sideLayout.Padding = UDim.new(0, 4)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder

local sidePadding = Instance.new("UIPadding", Sidebar)
sidePadding.PaddingTop = UDim.new(0, 6)
sidePadding.PaddingLeft = UDim.new(0, 6)
sidePadding.PaddingRight = UDim.new(0, 6)

local menuOptions = {
    {name = "Informações", iconId = "rbxassetid://89728202307832", active = true},
    {name = "Jogador", iconId = "rbxassetid://101446301918377", active = false},
    {name = "Avatar", iconId = "rbxassetid://6023426915", active = false},
    {name = "Perfil", iconId = "rbxassetid://6023426915", active = false},
    {name = "Casa", iconId = "rbxassetid://6023426915", active = false},
    {name = "Veículo", iconId = "rbxassetid://6023426915", active = false},
    {name = "Música", iconId = "rbxassetid://6023426915", active = false},
    {name = "Troll", iconId = "rbxassetid://6023426915", active = false},
}

for _, item in ipairs(menuOptions) do
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = item.active and COR_SECUNDARIA or Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = item.active and 0 or 1
    btn.Text = "          " .. item.name
    btn.TextColor3 = item.active and COR_TEXTO or COR_TEXTO_CINZA
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    
    local cornerBtn = Instance.new("UICorner", btn)
    cornerBtn.CornerRadius = UDim.new(0, 6)

    if item.active then
        local activeBar = Instance.new("Frame", btn)
        activeBar.Size = UDim2.new(0, 2, 0, 16)
        activeBar.Position = UDim2.new(0, 4, 0.5, -8)
        activeBar.BackgroundColor3 = COR_TEXTO
        activeBar.BorderSizePixel = 0
        local cornerBar = Instance.new("UICorner", activeBar)
        cornerBar.CornerRadius = UDim.new(0, 1)
    end

    local iconImg = Instance.new("ImageLabel", btn)
    iconImg.Size = UDim2.new(0, 14, 0, 14)
    iconImg.Position = UDim2.new(0, 12, 0.5, -7)
    iconImg.BackgroundTransparency = 1
    iconImg.Image = item.iconId
    iconImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
end

local ContentFrame = Instance.new("ScrollingFrame", MainFrame)
ContentFrame.Size = UDim2.new(1, -148, 1, -44)
ContentFrame.Position = UDim2.new(0, 144, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 2
ContentFrame.ScrollBarImageColor3 = COR_BORDA
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 360)

local contentLayout = Instance.new("UIListLayout", ContentFrame)
contentLayout.Padding = UDim.new(0, 8)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Conteúdo da Aba Informações
local LinkText = Instance.new("TextLabel", ContentFrame)
LinkText.Size = UDim2.new(1, -8, 0, 16)
LinkText.BackgroundTransparency = 1
LinkText.Text = "https://discord.gg/RefSgafC2"
LinkText.TextColor3 = COR_TEXTO_CINZA
LinkText.TextSize = 10
LinkText.Font = Enum.Font.Gotham
LinkText.TextXAlignment = Enum.TextXAlignment.Left

local DiscordCard = Instance.new("Frame", ContentFrame)
DiscordCard.Size = UDim2.new(1, -8, 0, 52)
DiscordCard.BackgroundColor3 = COR_SECUNDARIA
DiscordCard.BorderSizePixel = 0
local cornerDC = Instance.new("UICorner", DiscordCard)
cornerDC.CornerRadius = UDim.new(0, 6)

local IconDC = Instance.new("TextLabel", DiscordCard)
IconDC.Size = UDim2.new(0, 32, 0, 32)
IconDC.Position = UDim2.new(0, 10, 0, 10)
IconDC.BackgroundColor3 = COR_FUNDO
IconDC.Text = "🚀"
IconDC.TextSize = 14
local cornerIDC = Instance.new("UICorner", IconDC)
cornerIDC.CornerRadius = UDim.new(0, 16)

local TitleDC = Instance.new("TextLabel", DiscordCard)
TitleDC.Size = UDim2.new(1, -55, 0, 18)
TitleDC.Position = UDim2.new(0, 48, 0, 9)
TitleDC.BackgroundTransparency = 1
TitleDC.Text = "Comunidade Rd4X Hub Oficial"
TitleDC.TextColor3 = COR_TEXTO
TitleDC.TextSize = 11
TitleDC.Font = Enum.Font.GothamBold
TitleDC.TextXAlignment = Enum.TextXAlignment.Left

local SubDC = Instance.new("TextLabel", DiscordCard)
SubDC.Size = UDim2.new(1, -55, 0, 14)
SubDC.Position = UDim2.new(0, 48, 0, 26)
SubDC.BackgroundTransparency = 1
SubDC.Text = "Entre no servidor oficial do Discord"
SubDC.TextColor3 = COR_TEXTO_CINZA
SubDC.TextSize = 10
SubDC.Font = Enum.Font.Gotham
SubDC.TextXAlignment = Enum.TextXAlignment.Left

local CopyBtn = Instance.new("TextButton", ContentFrame)
CopyBtn.Size = UDim2.new(1, -8, 0, 30)
CopyBtn.BackgroundColor3 = COR_VERDE
CopyBtn.Text = "Copiar Link do Discord"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.TextSize = 11
CopyBtn.Font = Enum.Font.GothamBold
local cornerCopy = Instance.new("UICorner", CopyBtn)
cornerCopy.CornerRadius = UDim.new(0, 6)

CopyBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://discord.gg/RefSgafC2") end)
end)

local InfoBox = Instance.new("Frame", ContentFrame)
InfoBox.Size = UDim2.new(1, -8, 0, 52)
InfoBox.BackgroundColor3 = COR_SECUNDARIA
InfoBox.BorderSizePixel = 0
local cornerIB = Instance.new("UICorner", InfoBox)
cornerIB.CornerRadius = UDim.new(0, 6)

local InfoTitle = Instance.new("TextLabel", InfoBox)
InfoTitle.Size = UDim2.new(1, -15, 0, 16)
InfoTitle.Position = UDim2.new(0, 8, 0, 6)
InfoTitle.BackgroundTransparency = 1
InfoTitle.Text = "ℹ️ Informações sobre o Hub"
InfoTitle.TextColor3 = COR_TEXTO
InfoTitle.TextSize = 11
InfoTitle.Font = Enum.Font.GothamBold
InfoTitle.TextXAlignment = Enum.TextXAlignment.Left

local InfoDesc = Instance.new("TextLabel", InfoBox)
InfoDesc.Size = UDim2.new(1, -15, 0, 24)
InfoDesc.Position = UDim2.new(0, 8, 0, 22)
InfoDesc.BackgroundTransparency = 1
InfoDesc.Text = "Rd4X Hub Oficial for Brookhaven 🏡 RP\nO melhor e mais completo script multifuncional e seguro para você utilizar."
InfoDesc.TextColor3 = COR_TEXTO_CINZA
InfoDesc.TextSize = 9
InfoDesc.Font = Enum.Font.Gotham
InfoDesc.TextXAlignment = Enum.TextXAlignment.Left
InfoDesc.TextYAlignment = Enum.TextYAlignment.Top

local ReleaseBox = Instance.new("Frame", ContentFrame)
ReleaseBox.Size = UDim2.new(1, -8, 0, 75)
ReleaseBox.BackgroundColor3 = COR_SECUNDARIA
ReleaseBox.BorderSizePixel = 0
local cornerRB = Instance.new("UICorner", ReleaseBox)
cornerRB.CornerRadius = UDim.new(0, 6)

local ReleaseTitle = Instance.new("TextLabel", ReleaseBox)
ReleaseTitle.Size = UDim2.new(1, -15, 0, 16)
ReleaseTitle.Position = UDim2.new(0, 8, 0, 6)
ReleaseTitle.BackgroundTransparency = 1
ReleaseTitle.Text = "🔥 Nova Atualização ( Rd4X v3.0 ):"
ReleaseTitle.TextColor3 = COR_VERMELHO
ReleaseTitle.TextSize = 11
ReleaseTitle.Font = Enum.Font.GothamBold
ReleaseTitle.TextXAlignment = Enum.TextXAlignment.Left

local ReleaseDesc = Instance.new("TextLabel", ReleaseBox)
ReleaseDesc.Size = UDim2.new(1, -15, 0, 48)
ReleaseDesc.Position = UDim2.new(0, 8, 0, 22)
ReleaseDesc.BackgroundTransparency = 1
ReleaseDesc.Text = "Melhorias de desempenho, Anti-Fling aprimorado, Fly gui, suporte a veículos e sistema de Whitelist exclusivo integrado ao servidor."
ReleaseDesc.TextColor3 = COR_TEXTO_CINZA
ReleaseDesc.TextSize = 9
ReleaseDesc.Font = Enum.Font.Gotham
ReleaseDesc.TextXAlignment = Enum.TextXAlignment.Left
ReleaseDesc.TextYAlignment = Enum.TextYAlignment.Top
ReleaseDesc.TextWrapped = true

local CreditsBox = Instance.new("Frame", ContentFrame)
CreditsBox.Size = UDim2.new(1, -8, 0, 42)
CreditsBox.BackgroundColor3 = COR_SECUNDARIA
CreditsBox.BorderSizePixel = 0
local cornerCB = Instance.new("UICorner", CreditsBox)
cornerCB.CornerRadius = UDim.new(0, 6)

local CreditsText = Instance.new("TextLabel", CreditsBox)
CreditsText.Size = UDim2.new(1, -15, 1, 0)
CreditsText.Position = UDim2.new(0, 8, 0, 0)
CreditsText.BackgroundTransparency = 1
CreditsText.Text = "Desenvolvimento:\nCriador: J. Epstein\nEquipe Oficial: Rd4X Team"
CreditsText.TextColor3 = COR_TEXTO_CINZA
CreditsText.TextSize = 9
CreditsText.Font = Enum.Font.Gotham
CreditsText.TextXAlignment = Enum.TextXAlignment.Left
CreditsText.TextYAlignment = Enum.TextYAlignment.Center

-- ==========================================================
-- LÓGICA DO BOTÃO MINIMIZAR ( - )
-- ==========================================================
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 530, 0, 38) or UDim2.new(0, 530, 0, 370)
    
    Sidebar.Visible = not isMinimized
    ContentFrame.Visible = not isMinimized
    
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = targetSize
    }):Play()
end)
