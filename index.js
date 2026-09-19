const { Client, GatewayIntentBits } = require('discord.js');

// Criação do cliente do bot com as intents necessárias
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

// Evento disparado quando o bot estiver online e pronto
client.once('ready', () => {
    console.log(`[SUCESSO] Bot online e conectado como ${client.user.tag}!`);
});

// Exemplo básico de comando de teste no chat (!ping)
client.on('messageCreate', async (message) => {
    if (message.author.bot) return; // Ignora mensagens de outros bots

    if (message.content === '!ping') {
        await message.reply('Pong! 🏓 O bot está funcionando perfeitamente no Render.');
    }
});

// Realiza o login utilizando o token configurado no Environment do Render
client.login(process.env.DISCORD_TOKEN);
