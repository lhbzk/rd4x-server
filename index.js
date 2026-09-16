const { Client, GatewayIntentBits } = require('discord.js');
const express = require('express');

// Configuração do Servidor Web (API para o Roblox)
const app = express();
app.use(express.json());

// Armazena o anúncio global atual
let anuncioGlobal = {
    titulo: "👑 Rd4X Creator 👑",
    mensagem: "Bem-vindo ao RD4X Hub!"
};

// Rota que o Hub do Roblox vai consultar para buscar o anúncio global
app.get('/obter-anuncio-global', (req, res) => {
    res.json(anuncioGlobal);
});

// Rota raiz para o UptimeRobot ficar com status Verdinho (200 OK)
app.get('/', (req, res) => {
    res.send('RD4X Hub API Online e Operacional!');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`[API] Servidor rodando na porta ${PORT}`);
});

// Configuração do Bot do Discord
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

client.once('ready', () => {
    console.log(`[Discord] Bot logado com sucesso como ${client.user.tag}`);
});

// Escuta mensagens enviadas no Discord
client.on('messageCreate', async (message) => {
    // Ignora mensagens de bots
    if (message.author.bot) return;

    // Verifica se a mensagem foi enviada exatamente no canal chamado 'anuncio-global'
    if (message.channel.name === 'anuncio-global') {
        const textoAnuncio = message.content.trim();
        
        if (textoAnuncio.length > 0) {
            // Atualiza o cache global da API
            anuncioGlobal.mensagem = textoAnuncio;
            
            // Reage à mensagem no Discord confirmando que foi sincronizada
            await message.react('✅').catch(() => {});
            console.log(`[Anúncio Global Atualizado]: "${textoAnuncio}" por ${message.author.tag}`);
        }
    }
});

// Insira o Token do seu bot do Discord aqui ou utilize variáveis de ambiente no Render
client.login(process.env.DISCORD_TOKEN || "SEU_TOKEN_DO_BOT_AQUI");
