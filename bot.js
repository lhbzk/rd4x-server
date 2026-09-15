const { Client, GatewayIntentBits } = require('discord.js');
const client = new Client({ 
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ] 
});

// Mensagem no terminal quando o bot ligar
client.on('ready', () => {
    console.log(`Bot do RD4X Hub online como: ${client.user.tag}`);
});

// Resposta simples para testar se o bot está lendo mensagens
client.on('messageCreate', (message) => {
    if (message.author.bot) return;

    if (message.content === '!ping') {
        message.reply('Pong! O Bot do RD4X Hub está funcionando!');
    }
});

// CONECTAR O BOT (COLE O SEU TOKEN ENTRE AS ASPAS ABAIXO)
client.login(process.env.DISCORD_TOKEN);
