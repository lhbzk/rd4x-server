const express = require('express');
const { Client, GatewayIntentBits } = require('discord.js');

const app = express();
app.use(express.json());

// Banco de dados em memória para armazenar XP e dados dos usuários
const database = {};

function getUserData(username) {
    if (!database[username]) {
        database[username] = { xp: 0, isVipManual: false };
    }
    return database[username];
}

// -----------------------------------------------------------------------------
// ROTAS DA API PARA O ROBLOX / CRAFTLAND
// -----------------------------------------------------------------------------

// Rota para consultar status VIP e progresso do jogador
app.get('/checar-vip/:user', (req, res) => {
    const user = getUserData(req.params.user);
    const xp = user.xp;
    
    let role = "User";
    let isVip = user.isVipManual || false;

    if (xp >= 200000) {
        isVip = true;
        role = "VIP PERM";
    } else if (xp >= 100000) {
        role = "User [Degustação VIP 1 Semana]";
    } else if (xp >= 50000) {
        role = "User [Degustação VIP 5 Dias]";
    } else if (xp >= 25000) {
        role = "User Dedicado";
    }

    res.json({ 
        vip: isVip, 
        role: role, 
        xp: xp,
        faltaParaVip: Math.max(0, 200000 - xp)
    });
});

// Rota para adicionar XP
app.post('/add-xp', (req, res) => {
    const { username, xpAmount } = req.body;
    if (!username || !xpAmount) return res.status(400).json({ error: "Dados inválidos." });

    const user = getUserData(username);
    user.xp += parseInt(xpAmount);
    
    res.json({ success: true, novoXP: user.xp });
});

// Rota para zerar a trajetória por auto-click
app.post('/reset-xp', (req, res) => {
    const { username } = req.body;
    if (!username) return res.status(400).json({ error: "Usuário não informado." });

    const user = getUserData(username);
    user.xp = 0;

    res.json({ success: true, message: "Trajetória zerada por auto-click.", novoXP: 0 });
});

// -----------------------------------------------------------------------------
// BOT DO DISCORD & INICIALIZAÇÃO
// -----------------------------------------------------------------------------
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

client.once('ready', () => {
    console.log(`Bot do RD4X Hub online como: ${client.user.tag}`);
});

client.on('messageCreate', async (message) => {
    if (message.author.bot) return;

    if (message.content.toLowerCase() === '!encerrar') {
        if (!message.member.permissions.has('ManageChannels')) {
            return message.reply('❌ Você não tem permissão para usar este comando.');
        }

        await message.reply('🔒 Encerrando e apagando este ticket em 5 segundos...');
        setTimeout(() => {
            message.channel.delete().catch(() => {});
        }, 5000);
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`API rodando na porta ${PORT}`);
});

if (process.env.DISCORD_TOKEN) {
    client.login(process.env.DISCORD_TOKEN);
}
