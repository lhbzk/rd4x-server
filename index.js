const { Client, GatewayIntentBits, PermissionsBitField } = require('discord.js');
const express = require('express');

const app = express();
app.use(express.json());

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent,
        GatewayIntentBits.GuildMembers
    ]
});

client.once('ready', () => {
    console.log(`🤖 Bot online com sucesso como: ${client.user.tag}`);
});

// Listener de mensagens
client.on('messageCreate', async (message) => {
    // Ignora mensagens enviadas por bots
    if (message.author.bot) return;

    const content = message.content.trim();
    const args = content.split(/ +/);
    const command = args.shift().toLowerCase();

    // COMANDO !PAINEL
    if (command === '!painel') {
        await message.channel.send('📋 Painel de Atendimento ativo!');
        return;
    }

    // COMANDO !LIBERAR (Exemplo: !liberar 7d NomeDoUsuario)
    if (command === '!liberar') {
        const tempo = args[0] || '7d';
        const usuario = args[1] || 'desconhecido';
        await message.channel.send(`✅ VIP liberado por **${tempo}** para **${usuario}**!`);
        return;
    }

    // COMANDO !ENCERRAR
    if (command === '!encerrar') {
        await message.channel.send('🔒 Encerrando e apagando este ticket em 5 segundos...');
        setTimeout(async () => {
            try {
                await message.channel.delete();
            } catch (err) {
                console.error('Erro ao deletar o canal do ticket:', err);
                await message.channel.send('⚠️ Não tenho permissão para apagar este canal! Verifique a permissão "Gerenciar Canais".');
            }
        }, 5000);
        return;
    }

    // RESPOSTA AUTOMÁTICA EM CANAIS DE TICKET
    // Verifica se o canal atual é um ticket (se o nome da sala contém 'ticket')
    if (message.channel.name.includes('ticket')) {
        // Se a mensagem contém anexos (ex: comprovante PIX)
        if (message.attachments.size > 0) {
            await message.reply('📸 Comprovante recebido! Um administrador irá verificar o pagamento em breve.');
        } else {
            // Se for mensagem de texto normal (ex: Nick do jogador)
            await message.reply(`✅ Dados recebidos: **${message.content}**\nAguarde a confirmação da equipe!`);
        }
    }
});

// Servidor Web para manter o Render ativo
app.get('/', (req, res) => {
    res.send('API RD4X Hub está online!');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});

client.login(process.env.DISCORD_TOKEN);
