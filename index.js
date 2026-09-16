const { 
    Client, 
    GatewayIntentBits, 
    ActionRowBuilder, 
    ButtonBuilder, 
    ButtonStyle 
} = require('discord.js');
const express = require('express');

const app = express();
app.use(express.json());

// CONFIGURAÇÕES DE IDs (Insira os IDs do Discord aqui)
const ID_DONO = "COLOQUE_O_ID_DO_DONO_AQUI"; 
const ID_CARGO_ADM = "COLOQUE_O_ID_DO_CARGO_ADM_AQUI"; 

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

// Listener de Mensagens
client.on('messageCreate', async (message) => {
    // Ignora mensagens de outros bots
    if (message.author.bot) return;

    const content = message.content.trim();
    const args = content.split(/ +/);
    const command = args.shift().toLowerCase();

    // 1. COMANDO !PAINEL
    if (command === '!painel') {
        await message.channel.send('📋 Painel de Atendimento ativo!');
        return;
    }

    // 2. COMANDO !LIBERAR (Ex: !liberar 7d wx_br7)
    if (command === '!liberar') {
        const tempo = args[0] || '7d';
        const usuario = args[1] || 'desconhecido';

        const row = new ActionRowBuilder().addComponents(
            new ButtonBuilder()
                .setCustomId(`remover_vip_${usuario}`)
                .setLabel(`🚫 Remover VIP de ${usuario}`)
                .setStyle(ButtonStyle.Danger)
        );

        await message.channel.send({
            content: `✅ VIP liberado por **${tempo}** para o jogador **${usuario}**!`,
            components: [row]
        });
        return;
    }

    // 3. COMANDO !TIRARVIP (Ex: !tirarvip wx_br7)
    if (command === '!tirarvip') {
        const usuario = args[0] || 'desconhecido';
        await message.channel.send(`🚫 O VIP do jogador **${usuario}** foi revogado por descumprimento das regras!`);
        return;
    }

    // 4. COMANDO !ENCERRAR
    if (command === '!encerrar') {
        await message.channel.send('🔒 Encerrando e apagando este ticket em 5 segundos...');
        
        setTimeout(async () => {
            try {
                await message.channel.delete();
            } catch (err) {
                console.error('Erro ao deletar o canal:', err);
                await message.channel.send('⚠️ Não foi possível apagar o canal. Verifique se o bot tem a permissão "Gerenciar Canais".');
            }
        }, 5000);
        return;
    }

    // 5. RESPOSTA AUTOMÁTICA EM CANAIS DE TICKET (Correção do ||)
    const nomeCanal = message.channel.name.toLowerCase();
    
    if (nomeCanal.startsWith('ticket-') || nomeCanal.includes('ticket')) {
        const mencaoDono = ID_DONO !== "COLOQUE_O_ID_DO_DONO_AQUI" ? `<@${ID_DONO}>` : "**Dono**";
        const mencaoAdm = ID_CARGO_ADM !== "COLOQUE_O_ID_DO_CARGO_ADM_AQUI" ? `<@&${ID_CARGO_ADM}>` : "**ADMs**";

        // Se o usuário mandou imagem (Comprovante)
        if (message.attachments.size > 0) {
            await message.reply(`📸 Comprovante recebido com sucesso!\n⏳ Aguarde a confirmação do ${mencaoDono} ou dos ${mencaoAdm}.`);
        } 
        // Se o usuário mandou texto (Nick) e não é um comando com '!'
        else if (!content.startsWith('!')) {
            await message.reply(`✅ Dados recebidos: **${message.content}**\n⏳ Aguarde a confirmação do ${mencaoDono} ou dos ${mencaoAdm}.`);
        }
    }
});

// Listener de Cliques em Botões
client.on('interactionCreate', async (interaction) => {
    if (!interaction.isButton()) return;

    if (interaction.customId.startsWith('remover_vip_')) {
        const usuario = interaction.customId.replace('remover_vip_', '');
        await interaction.reply({
            content: `🚫 O VIP do jogador **${usuario}** foi removido com sucesso via botão por ${interaction.user}!`,
            ephemeral: false
        });
    }
});

// Servidor Web para manter a Render ativa
app.get('/', (req, res) => {
    res.send('API RD4X Hub está online!');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});

client.login(process.env.DISCORD_TOKEN);
