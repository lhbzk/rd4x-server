const { Client, GatewayIntentBits, ActionRowBuilder, ButtonBuilder, ButtonStyle, ChannelType, PermissionsBitField } = require('discord.js');
const express = require('express');

const app = express();
app.use(express.json());

// --- BANCO DE DADOS EM MEMÓRIA ---
// Guarda os VIPs: { "nome_do_jogador": data_expiracao_timestamp }
const vips = {}; 

// --- CONFIGURAÇÕES DO BOT DISCORD ---
const TOKEN = process.env.DISCORD_TOKEN; // Coloque o token nas variáveis de ambiente da Render
const CHAVE_PIX = "85777075550"; // Sua chave Pix atualizada

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

client.once('ready', () => {
    console.log(`Bot online como ${client.user.tag}`);
});

// Criar o botão de Ticket (Use o comando !painel em um canal para enviar a mensagem)
client.on('messageCreate', async (message) => {
    if (message.author.bot) return;

    if (message.content === '!painel' && message.member.permissions.has(PermissionsBitField.Flags.Administrator)) {
        const row = new ActionRowBuilder().addComponents(
            new ButtonBuilder()
                .setCustomId('abrir_ticket')
                .setLabel('Comprar VIP')
                .setStyle(ButtonStyle.Success)
        );

        await message.channel.send({
            content: "Clique no botão abaixo para abrir um ticket e comprar seu VIP!",
            components: [row]
        });
    }

    // Comando para liberar o VIP: !liberar <tempo> <nick_roblox>
    // Exemplos: !liberar 3d Nome, !liberar 1s5d Nome, !liberar 1m Nome, !liberar 2m Nome, !liberar perm Nome
    if (message.content.startsWith('!liberar') && message.member.permissions.has(PermissionsBitField.Flags.Administrator)) {
        const args = message.content.split(' ');
        if (args.length < 3) {
            return message.reply("Uso correto: `!liberar <tempo> <NickRoblox>` (Ex: `!liberar 3d João` ou `!liberar perm João`)");
        }

        const tempoStr = args[1].toLowerCase();
        const jogador = args[2];
        let dias = 0;

        if (tempoStr === 'perm') {
            vips[jogador] = 'permanente';
            return message.reply(`✅ VIP Permanente liberado com sucesso para **${jogador}**!`);
        }

        // Soma os dias baseados nos sufixos d (dias), s (semanas), m (meses)
        const dMatch = tempoStr.match(/(\d+)d/);
        const sMatch = tempoStr.match(/(\d+)s/);
        const mMatch = tempoStr.match(/(\d+)m/);

        if (dMatch) dias += parseInt(dMatch[1]);
        if (sMatch) dias += parseInt(sMatch[1]) * 7;
        if (mMatch) dias += parseInt(mMatch[1]) * 30;

        if (dias === 0) {
            return message.reply("Formato de tempo inválido! Use d (dias), s (semanas), m (meses) ou perm. Ex: `1s5d`, `3d`, `1m`.");
        }

        const expiracao = Date.now() + (dias * 24 * 60 * 60 * 1000);
        vips[jogador] = expiracao;

        return message.reply(`✅ VIP liberado por **${dias} dias** para o jogador **${jogador}**!`);
    }
});

// Sistema de clique no botão do ticket
client.on('interactionCreate', async (interaction) => {
    if (!interaction.isButton()) return;

    if (interaction.customId === 'abrir_ticket') {
        const canalExistente = interaction.guild.channels.cache.find(c => c.name === `ticket-${interaction.user.username.toLowerCase()}`);
        if (canalExistente) {
            return interaction.reply({ content: `Você já possui um ticket aberto: ${canalExistente}`, ephemeral: true });
        }

        const canal = await interaction.guild.channels.create({
            name: `ticket-${interaction.user.username}`,
            type: ChannelType.GuildText,
            permissionOverwrites: [
                { id: interaction.guild.id, deny: [PermissionsBitField.Flags.ViewChannel] },
                { id: interaction.user.id, allow: [PermissionsBitField.Flags.ViewChannel, PermissionsBitField.Flags.SendMessages] }
            ]
        });

        await canal.send(`Olá ${interaction.user}! Faça o pagamento na chave Pix abaixo:\n\n\`${CHAVE_PIX}\`\n\nApós o pagamento, envie aqui o **Comprovante** e o seu **Nick no Roblox**.`);
        await interaction.reply({ content: `Ticket criado: ${canal}`, ephemeral: true });
    }
});

// --- ROTA API PARA O ROBLOX CHECAR O VIP ---
app.get('/checar-vip/:nome', (req, res) => {
    const nomeJogador = req.params.nome;
    const tempoVip = vips[nomeJogador];

    if (!tempoVip) {
        return res.json({ vip: false, mensagem: "Usuário não possui VIP" });
    }

    if (tempoVip === 'permanente') {
        return res.json({ vip: true, tipo: "permanente" });
    }

    if (Date.now() > tempoVip) {
        delete vips[nomeJogador];
        return res.json({ vip: false, mensagem: "VIP expirado" });
    }

    return res.json({ vip: true, expiraEm: tempoVip });
});

// Inicialização
const PORT = process.env.PORT || 10000;
app.listen(PORT, () => console.log(`API rodando na porta ${PORT}`));

if (TOKEN) {
    client.login(TOKEN);
} else {
    console.log("AVISO: DISCORD_TOKEN não configurado no ambiente.");
                }
    
