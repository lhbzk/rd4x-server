const { Client, GatewayIntentBits, ActionRowBuilder, ButtonBuilder, ButtonStyle, ChannelType, PermissionFlagsBits, EmbedBuilder } = require('discord.js');
const express = require('express');

// --- SERVIDOR WEB & API PARA O ROBLOX (Para manter o bot acordado e validar o Hub) ---
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
    res.send('RD4X Bot está online e ativo!');
});

// Rota de Whitelist consultada pelo seu Hub do Roblox via game:HttpGet
app.get('/api/v2/whitelist', (req, res) => {
    const nickRoblox = req.query.nick || req.query.userid;
    if (!nickRoblox) {
        return res.json({ success: false, whitelisted: false });
    }

    // Se for o dono, libera automaticamente por segurança
    if (nickRoblox === ID_DONO) {
        return res.json({ success: true, whitelisted: true });
    }

    // Verifica se o usuário está liberado na memória e se o tempo não expirou
    if (usuariosLiberados.has(nickRoblox)) {
        const expiraEm = usuariosLiberados.get(nickRoblox);
        
        // Se expiraEm for "perm", o acesso é vitalício
        if (expiraEm === "perm") {
            return res.json({ success: true, whitelisted: true });
        }

        if (Date.now() > expiraEm) {
            usuariosLiberados.delete(nickRoblox);
            return res.json({ success: false, whitelisted: false, message: "Expirado" });
        }
        return res.json({ success: true, whitelisted: true });
    }

    return res.json({ success: false, whitelisted: false });
});

app.listen(port, () => {
    console.log(`[WEB] Servidor web e API rodando na porta ${port}`);
});

// --- CONFIGURAÇÕES E IDS ---
const ID_DONO = "1549272865260441631";
const ID_CARGO_ADMIN = "1549273436705259570";
const CHAVE_PIX = "85777075550";
const ID_CANAL_LOGS = "SEU_ID_DE_CANAL_DE_LOGS_AQUI"; 
const ID_CANAL_AVALIACOES = "SEU_ID_DE_CANAL_DE_AVALIACOES_AQUI"; 

// Bancos de dados em memória
const usuariosLiberados = new Map(); 
const blacklist = new Set(); 

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

// Função auxiliar para enviar logs no canal de staff
async function enviarLog(guild, titulo, descricao, cor) {
    if (!ID_CANAL_LOGS || ID_CANAL_LOGS.includes("SEU_ID")) return;
    try {
        const canalLogs = guild.channels.cache.get(ID_CANAL_LOGS);
        if (canalLogs) {
            const embed = new EmbedBuilder()
                .setTitle(`📋 [LOG] ${titulo}`)
                .setDescription(descricao)
                .setColor(cor || 0x2b2d31)
                .setTimestamp();
            await canalLogs.send({ embeds: [embed] });
        }
    } catch (e) {
        console.error("Erro ao enviar log:", e);
    }
}

client.on('messageCreate', async (message) => {
    if (message.author.bot) return;

    const args = message.content.trim().split(/\s+/);
    const comando = args[0].toLowerCase();

    // 1. !painel (Responde de forma efêmera ou limpa)
    if (comando === '!painel') {
        const row = new ActionRowBuilder().addComponents(
            new ButtonBuilder()
                .setCustomId('criar_ticket')
                .setLabel('Criar Ticket')
                .setStyle(ButtonStyle.Primary)
                .setEmoji('🎫')
        );

        await message.delete().catch(() => {});

        await message.channel.send({
            content: `<@${message.author.id}>`,
            components: [row],
            flags: 64
        }).catch(async () => {
            await message.channel.send({
                content: `<@${message.author.id}> Clique em criar ticket abaixo para comprar o Painel Admin:`,
                components: [row]
            });
        });
        return;
    }

    // 2. !ajuda / !help
    if (comando === '!ajuda' || comando === '!help') {
        const embedAjuda = new EmbedBuilder()
            .setTitle("🤖 Central de Ajuda — RD4X Hub")
            .setDescription("Aqui estão os comandos disponíveis para consulta e suporte:")
            .addFields(
                { name: "🎫 `!suporte`", value: "Chama os administradores no ticket caso tenha dúvidas sobre o pagamento ou ativação do painel.", inline: false },
                { name: "⏳ `!tempo [seu-nick]`", value: "Consulta quantos dias exatos restam para o seu painel do Roblox expirar.", inline: false },
                { name: "📦 `!status [seu-nick]`", value: "Verifica se o seu nick está com o acesso ativo no sistema.", inline: false }
            )
            .setColor(0x00ffcc)
            .setFooter({ text: "RD4X Hub • Todos os direitos reservados" })
            .setTimestamp();

        await message.reply({ embeds: [embedAjuda] });
        return;
    }

    // 3. !liberar [tempo/abreviação] [nick] (Aceita perm, 30d, 1m, etc.)
    if (comando === '!liberar') {
        const tempoInput = args[1]?.toLowerCase();
        const nickRoblox = args[2];

        if (!tempoInput || !nickRoblox) {
            return message.reply("⚠️ Uso correto: `!liberar [tempo] [nick]`\nExemplos de tempo: `perm`, `30d`, `7d`, `1m` (1 mês)");
        }

        let tempoExpiracao;
        let textoTempoExibicao = "";

        if (tempoInput === "perm" || tempoInput === "permanente") {
            tempoExpiracao = "perm";
            textoTempoExibicao = "permanente (vitalício)";
        } else {
            // Tenta extrair número e unidade (ex: 30d, 1m, ou apenas números como 30)
            const match = tempoInput.match(/^(\d+)([a-z]*)$/);
            if (!match) {
                return message.reply("⚠️ Formato de tempo inválido! Use algo como `30d`, `perm` ou `1m`.");
            }

            const quantidade = parseInt(match[1]);
            const unidade = match[2] || 'd'; // padrão para dias se não colocar letra

            let diasTotais = quantidade;
            if (unidade === 'm') {
                diasTotais = quantidade * 30; // Considera 1 mês = 30 dias
            } else if (unidade === 'h') {
                diasTotais = quantidade / 24; // Horas
            }

            tempoExpiracao = Date.now() + (diasTotais * 24 * 60 * 60 * 1000);
            textoTempoExibicao = `${quantidade} ${unidade === 'm' ? 'mês/meses' : 'dia(s)'}`;
        }

        usuariosLiberados.set(nickRoblox, tempoExpiracao);

        await message.reply(`✅ Acesso liberado para **${nickRoblox}** por **${textoTempoExibicao}**!`);
        enviarLog(message.guild, "Painel Liberado", `O admin **${message.author.tag}** liberou o painel para **${nickRoblox}** por **${textoTempoExibicao}**.`);
        return;
    }

    // 4. !retirarpainel [nick]
    if (comando === '!retirarpainel') {
        const nickRoblox = args[1];
        if (!nickRoblox) return message.reply("⚠️ Uso correto: `!retirarpainel [nick]`");
        
        usuariosLiberados.delete(nickRoblox);
        await message.reply(`🔒 O painel de **${nickRoblox}** foi revogado.`);
        enviarLog(message.guild, "Painel Revogado", `O admin **${message.author.tag}** retirou o painel de **${nickRoblox}**.`);
        return;
    }

    // 5. !status [nick]
    if (comando === '!status') {
        const nickRoblox = args[1];
        if (!nickRoblox) return message.reply("⚠️ Uso correto: `!status [nick]`");
        
        if (usuariosLiberados.has(nickRoblox) || nickRoblox === ID_DONO) {
            if (nickRoblox === ID_DONO) {
                return message.reply(`🟢 O jogador **${nickRoblox}** possui um painel **ativo (Dono)**.`);
            }

            const expiraEm = usuariosLiberados.get(nickRoblox);
            if (expiraEm !== "perm" && Date.now() > expiraEm) {
                usuariosLiberados.delete(nickRoblox);
                return message.reply(`🔴 O painel de **${nickRoblox}** **expirou**.`);
            }
            await message.reply(`🟢 O jogador **${nickRoblox}** possui um painel **ativo**.`);
        } else {
            await message.reply(`🔴 O jogador **${nickRoblox}** **não** possui registro ativo.`);
        }
        return;
    }

    // 6. !tempo [nick]
    if (comando === '!tempo') {
        const nickRoblox = args[1];
        if (!nickRoblox) return message.reply("⚠️ Uso correto: `!tempo [nick]`");

        if (nickRoblox === ID_DONO) {
            return message.reply(`♾️ O painel do Dono (**${nickRoblox}**) é permanente.`);
        }

        if (usuariosLiberados.has(nickRoblox)) {
            const expiraEm = usuariosLiberados.get(nickRoblox);
            
            if (expiraEm === "perm") {
                return message.reply(`♾️ O painel de **${nickRoblox}** é **Permanente**.`);
            }

            const tempoRestante = expiraEm - Date.now();
            if (tempoRestante <= 0) {
                return message.reply(`⏱️ O painel de **${nickRoblox}** já expirou.`);
            }
            const diasRestantes = Math.ceil(tempoRestante / (1000 * 60 * 60 * 24));
            await message.reply(`⏳ Restam aproximadamente **${diasRestantes} dia(s)** para o painel de **${nickRoblox}** expirar.`);
        } else {
            await message.reply(`❌ O jogador **${nickRoblox}** não está cadastrado.`);
        }
        return;
    }

    // 7. !blacklist [nick]
    if (comando === '!blacklist') {
        const alvo = args[1];
        if (!alvo) return message.reply("⚠️ Uso correto: `!blacklist [nick ou id]`");
        blacklist.add(alvo);
        await message.reply(`🚫 **${alvo}** foi adicionado à **Blacklist** com sucesso.`);
        enviarLog(message.guild, "Blacklist Adicionada", `**${message.author.tag}** adicionou **${alvo}** à blacklist.`);
        return;
    }

    // 8. !unblacklist [nick]
    if (comando === '!unblacklist') {
        const alvo = args[1];
        if (!alvo) return message.reply("⚠️ Uso correto: `!unblacklist [nick ou id]`");
        if (blacklist.has(alvo)) {
            blacklist.delete(alvo);
            await message.reply(`✅ **${alvo}** foi removido da Blacklist.`);
            enviarLog(message.guild, "Blacklist Removida", `**${message.author.tag}** removeu **${alvo}** da blacklist.`);
        } else {
            await message.reply(`❌ **${alvo}** não está na blacklist.`);
        }
        return;
    }

    // 9. !suporte
    if (comando === '!suporte') {
        let msgSuporte = `🆘 **Ajuda com o pagamento solicitada!**\n\nAguarde os administradores analisarem. <@&${ID_CARGO_ADMIN}>`;
        await message.reply({ content: msgSuporte, allowedMentions: { roles: [ID_CARGO_ADMIN] } });
        return;
    }

    // 10. !fechar
    if (comando === '!fechar') {
        if (!message.channel.name.startsWith('ticket-')) {
            return message.reply("❌ Este comando só pode ser usado dentro de um canal de ticket!");
        }

        await message.reply("🔒 Limpando mensagens do painel, fechando o atendimento e enviando avaliação...");

        try {
            const mensagens = await message.channel.messages.fetch({ limit: 20 });
            for (const [id, msg] of mensagens) {
                if (msg.author.id === client.user.id || msg.content.toLowerCase().includes('!painel')) {
                    await msg.delete().catch(() => {});
                }
            }
        } catch (e) {
            console.error("Erro ao apagar mensagens antigas:", e);
        }

        if (ID_CANAL_AVALIACOES && !ID_CANAL_AVALIACOES.includes("SEU_ID")) {
            const canalAvaliacoes = message.guild.channels.cache.get(ID_CANAL_AVALIACOES);
            if (canalAvaliacoes) {
                const embedAvaliacao = new EmbedBuilder()
                    .setTitle("⭐ Nova Avaliação de Atendimento")
                    .setDescription(`Atendimento encerrado para o ticket de **${message.channel.name}**.\nObrigado por comprar com a RD4X!`)
                    .setColor(0x00ffcc)
                    .setTimestamp();
                await canalAvaliacoes.send({ embeds: [embedAvaliacao] }).catch(() => {});
            }
        }

        enviarLog(message.guild, "Ticket Fechado", `O canal **${message.channel.name}** foi fechado por **${message.author.tag}**.`);

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

        if (blacklist.has(member.user.username) || blacklist.has(member.id)) {
            return interaction.reply({ content: `❌ Você está bloqueado de abrir tickets neste servidor.`, ephemeral: true });
        }

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
                { id: guild.id, deny: [PermissionFlagsBits.ViewChannel] },
                { id: member.id, allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory] },
                { id: ID_DONO, allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory] },
                { id: ID_CARGO_ADMIN, allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory] },
            ],
        });

        let textoTicket = `Para adquirir seu Painel Admin, mande seu pix na chave abaixo.\n` +
            `\`${CHAVE_PIX}\`\n\n` +
            `Após isso, mande o comprovante, Seu Nick no Roblox e a confirmação da quantidade de dias.`;

        await channel.send({ 
            content: `<@${member.user.id}>\n\n` + textoTicket,
            allowedMentions: { users: [member.user.id] }
        });

        let avisoResponsaveis = `Aguarde os responsáveis analisarem o comprovante. <@&${ID_CARGO_ADMIN}>`;
        await channel.send({
            content: avisoResponsaveis,
            allowedMentions: { roles: [ID_CARGO_ADMIN] }
        });

        enviarLog(guild, "Ticket Aberto", `Um novo ticket foi criado por **${member.user.tag}** no canal <#${channel.id}>.`);

        await interaction.editReply({ content: `✅ Seu ticket foi criado com sucesso aqui: ${channel}` });
    }
});

client.login(process.env.DISCORD_TOKEN);
