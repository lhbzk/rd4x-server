const { 
    Client, 
    GatewayIntentBits, 
    ActionRowBuilder, 
    ButtonBuilder, 
    ButtonStyle, 
    ChannelType, 
    PermissionsBitField,
    MessageFlags 
} = require('discord.js');
const express = require('express');

const app = express();
app.use(express.json());

// --- BANCO DE DADOS EM MEMÓRIA ---
const vips = {}; 

// --- CONFIGURAÇÕES DO BOT DISCORD ---
const TOKEN = process.env.DISCORD_TOKEN;
const CHAVE_PIX = "SUA_CHAVE_PIX_AQUI"; 

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

client.once('clientReady', () => {
    console.log(`Bot online como ${client.user.tag}`);
});

// --- COMANDOS E MENSAGENS ---
client.on('messageCreate', async (message) => {
    if (message.author.bot) return;

    // Comando !painel: Envia o botão para criar ticket
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

    // Comando !liberar <tempo> <nick>
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

// --- CLIQUE NO BOTÃO DE TICKET ---
client.on('interactionCreate', async (interaction) => {
    if (!interaction.isButton()) return;

    if (interaction.customId === 'abrir_ticket') {
        const nomeCanal = `ticket-${interaction.user.username.toLowerCase()}`;
        const canalExistente = interaction.guild.channels.cache.find(c => c.name === nomeCanal);

        if (canalExistente) {
            const rowIrCanal = new ActionRowBuilder().addComponents(
                new ButtonBuilder()
                    .setLabel('Ir para o Ticket')
                    .setStyle(ButtonStyle.Link)
                    .setURL(`https://discord.com/channels/${interaction.guild.id}/${canalExistente.id}`)
            );

            return interaction.reply({ 
                content: `Você já possui um ticket aberto!`, 
                components: [rowIrCanal],
                flags: MessageFlags.Ephemeral 
            });
        }

        // Cria o novo canal privado
        const canal = await interaction.guild.channels.create({
            name: nomeCanal,
            type: ChannelType.GuildText,
            permissionOverwrites: [
                { id: interaction.guild.id, deny: [PermissionsBitField.Flags.ViewChannel] },
                { id: interaction.user.id, allow: [PermissionsBitField.Flags.ViewChannel, PermissionsBitField.Flags.SendMessages] }
            ]
        });

        await canal.send(`Olá ${interaction.user}! Faça o pagamento na chave Pix abaixo:\n\n\`${CHAVE_PIX}\`\n\nApós o pagamento, envie aqui o **Comprovante** e o seu **Nick no Roblox**.`);

        // Botão direto para o canal recém-criado
        const rowIrCanal = new ActionRowBuilder().addComponents(
            new ButtonBuilder()
                .setLabel('Ir para o Ticket')
                .setStyle(ButtonStyle.Link)
                .setURL(`https://discord.com/channels/${interaction.guild.id}/${canal.id}`)
        );

        await interaction.reply({ 
            content: `Ticket criado com sucesso! Clique no botão para ir até ele:`, 
            components: [rowIrCanal],
            flags: MessageFlags.Ephemeral 
        });
    }
});

// --- ROTA API PARA O ROBLOX ---
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

// --- INICIALIZAÇÃO ---
const PORT = process.env.PORT || 10000;
app.listen(PORT, () => console.log(`API rodando na porta ${PORT}`));

if (TOKEN) {
    client.login(TOKEN);
} else {
    console.log("AVISO: DISCORD_TOKEN não configurado no ambiente.");
}
