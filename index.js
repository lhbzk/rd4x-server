const { Client, GatewayIntentBits } = require('discord.js');
const express = require('express');

const app = express();
app.use(express.json());

// Instância do Bot com as permissões necessárias para ler mensagens
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

// Evento quando o bot conecta com sucesso
client.once('ready', () => {
    console.log(`🤖 Bot online com sucesso como: ${client.user.tag}`);
});

// Leitor de Comandos
client.on('messageCreate', async (message) => {
    // Ignora mensagens enviadas por outros bots
    if (message.author.bot) return;

    const args = message.content.trim().split(/ +/);
    const command = args.shift().toLowerCase();

    // 1. COMANDO !LIBERAR (Exemplo: !liberar 7s usuario)
    if (command === '!liberar') {
        const tempo = args[0] || '7d';
        const usuario = args[1] || 'desconhecido';
        
        await message.channel.send(`✅ VIP liberado por **${tempo}** para o jogador **${usuario}**!`);
    }

    // 2. COMANDO !ENCERRAR (Deleta o canal do ticket)
    if (command === '!encerrar') {
        await message.channel.send('🔒 Encerrando e apagando este ticket em 5 segundos...');
        
        setTimeout(async () => {
            try {
                await message.channel.delete();
            } catch (err) {
                console.error('Erro ao deletar o canal:', err);
            }
        }, 5000);
    }
});

// Rota padrão HTTP para manter a API viva no Render
app.get('/', (req, res) => {
    res.send('API RD4X Hub está online!');
});

// Rota de Logs do Roblox (recebe requisições do script Lua)
app.post('/log', (req, res) => {
    const { usuario, acao, detalhes } = req.body;
    console.log(`[ROBLOX LOG] ${usuario} executou: ${acao} - ${detalhes}`);
    res.json({ status: 'sucesso', message: 'Log registrado' });
});

// Inicia o servidor Web na porta fornecida pelo Render
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});

// Conecta o bot usando o Token das variáveis de ambiente
client.login(process.env.DISCORD_TOKEN);
