const { Client, GatewayIntentBits, ActionRowBuilder, ButtonBuilder, ButtonStyle, ChannelType, PermissionFlagsBits } = require('discord.js');
const express = require('express');

// --- SERVIDOR WEB (Para manter o bot acordado no Render) ---
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
    res.send('RD4X Bot está online e ativo!');
});

app.listen(port, () => {
    console.log(`[WEB] Servidor web rodando na porta ${port}`);
});

// --- CONFIGURAÇÕES E IDS ---
const ID_DONO = "1549272865260441631";
const ID_CARGO_ADMIN = "1549273436705259570";
const CHAVE_PIX = "85777075550";

// Simulação de banco de dados simples para os nicks liberados (pode expandir depois)
const usuariosLiberados = new Set(["Joyce"]);

// --- BOT DO DISCORD ---
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

client.once('ready', () => {
    console.log(`[SUCESSO] Bot online e conectado como ${client.user.tag}!`);
});

client.on('messageCreate', async (message) => {
    if (message.author.bot) return;

    const args = message.content.trim().split(/\s+/);
    const comando = args[0].toLowerCase();

    // 1. !painel - Envia a mensagem com o botão de criar ticket
    if (comando === '!painel') {
        const row = new ActionRowBuilder().addComponents(
            new ButtonBuilder()
                .setCustomId('criar_ticket')
                .setLabel('Criar Ticket')
                .setStyle(ButtonStyle.Primary)
                .setEmoji('🎫')
        );

        await message.reply({
            content: "Clique em criar ticket para comprar o Painel Admin.",
            components: [row]
        });
        return;
    }

    // 2. !liberar [tempo] [nome_da_conta]
    if (comando === '!liberar') {
        const tempo = args[1];
        const nickRoblox = args[2];
        if (!tempo || !nickRoblox) {
            return message.reply("⚠️ Uso correto: `!liberar [tempo] [nick]` (Ex: `!liberar 1m Joyce`)");
        }
        usuariosLiberados.add(nickRoblox);
        await message.reply(`✅ Acesso liberado com sucesso para o jogador **${nickRoblox}** por **${tempo}**!`);
        return;
    }

    // 3. !retirarpainel [nome_da_conta]
    if (comando === '!retirarpainel') {
        const nickRoblox = args[1];
        if (!nickRoblox) {
            return message.reply("⚠️ Uso correto: `!retirarpainel [nick]`");
        }
        usuariosLiberados.delete(nickRoblox);
        await message.reply(`🔒 O painel de **${nickRoblox}** foi revogado/retirado.`);
        return;
    }

    // 4. !status [nome_da_conta]
    if (comando === '!status') {
        const nickRoblox = args[1];
        if (!nickRoblox) {
            return message.reply("⚠️ Uso correto: `!status [nick]`");
        }
        
        if (usuariosLiberados.has(nickRoblox)) {
            await message.reply(`🟢 O jogador **${nickRoblox}** possui um painel **ativo** registrado.`);
        } else {
            await message.reply(`🔴 O jogador **${nickRoblox}** **não** possui registro ativo no sistema.`);
        }
        return;
    }

    // 5. !suporte - Marca apenas os Admins para problemas com o Pix
    if (comando === '!suporte') {
        let msgSuporte = `🆘 **Ajuda com o pagamento solicitada!**\n\n` +
            `Aguarde os administradores analisarem. <@&${ID_CARGO_ADMIN}>`;
        
        await message.reply({
            content: msgSuporte,
            allowedMentions: { roles: [ID_CARGO_ADMIN] }
        });
        return;
    }

    // 6. !fechar - Exclui o canal de ticket atual
    if (comando === '!fechar') {
        if (!message.channel.name.startsWith('ticket-')) {
            return message.reply("❌ Este comando só pode ser usado dentro de um canal de ticket!");
        }
        await message.reply("🔒 Fechando canal de atendimento em 3 segundos...");
        setTimeout(async () => {
            await message.channel.delete().catch(() => {});
        }, 3000);
        return;
    }
});

// --- INTERAÇÃO COM O BOTÃO DE CRIAR TICKET ---
client.on('interactionCreate', async (interaction) => {
    if (!interaction.isButton()) return;

    if (interaction.customId === 'criar_ticket') {
        const guild = interaction.guild;
        const member = interaction.member;
        const parentCategory = interaction.channel.parentId;

        const nomeCanal = `ticket-${member.user.username}`.toLowerCase();
        const canalExistente = guild.channels.cache.find(c => c.name === nomeCanal);
        if (canalExistente) {
            return interaction.reply({ content: `❌ Você já possui um ticket aberto: ${canalExistente}`, ephemeral: true });
        }

        await interaction.deferReply({ ephemeral: true });

        const channel = await guild.channels.create({
            name: nomeCanal,
            type: ChannelType.GuildText,
            parent: parentCategory,
            permissionOverwrites: [
                {
                    id: guild.id,
                    deny: [PermissionFlagsBits.ViewChannel],
                },
                {
                    id: member.id,
                    allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory],
                },
                {
                    id: ID_DONO,
                    allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory],
                },
                {
                    id: ID_CARGO_ADMIN,
                    allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory],
                },
            ],
        });

        let textoTicket = `Para adquirir seu Painel Admin, mande seu pix na chave abaixo.\n` +
            `\`${CHAVE_PIX}\`\n\n` +
            `Após isso, mande o comprovante, Seu Nick no Roblox e a confirmação da quantidade de dias.`;

        await channel.send({ 
            content: `<@${member.user.id}>\n\n` + textoTicket,
            allowedMentions: { users: [member.user.id] }
        });

        // Aviso marcando APENAS o cargo de Administradores (sem marcar o dono)
        let avisoResponsaveis = `Aguarde os responsáveis analisarem o comprovante. <@&${ID_CARGO_ADMIN}>`;
        await channel.send({
            content: avisoResponsaveis,
            allowedMentions: { roles: [ID_CARGO_ADMIN] }
        });

        await interaction.editReply({ content: `✅ Seu ticket foi criado com sucesso aqui: ${channel}` });
    }
});

client.login(process.env.DISCORD_TOKEN);
