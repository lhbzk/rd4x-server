const { Client, GatewayIntentBits, ActionRowBuilder, ButtonBuilder, ButtonStyle, ChannelType, PermissionFlagsBits, EmbedBuilder } = require('discord.js');
const express = require('express');

// --- SERVIDOR WEB & API PARA O ROBLOX ---
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
    res.send('RD4X Bot está online e ativo!');
});

app.get('/api/v2/whitelist', (req, res) => {
    const nickRoblox = req.query.nick || req.query.userid;
    if (!nickRoblox) {
        return res.json({ success: false, whitelisted: false });
    }

    if (nickRoblox === ID_DONO) {
        return res.json({ success: true, whitelisted: true });
    }

    if (usuariosLiberados.has(nickRoblox)) {
        const expiraEm = usuariosLiberados.get(nickRoblox);
        
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
const ID_CANAL_LOGS = "1549274555175018587"; // ID configurado do seu canal de logs
const ID_CANAL_AVALIACOES = "SEU_ID_DE_CANAL_DE_AVALIACOES_AQUI"; 

// Bancos de dados em memória
const usuariosLiberados = new Map(); 
const blacklist = new Set(); 
const ticketsAtivos = new Map(); // Guarda o histórico de eventos e mensagem do log para cada ticket

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

// --- FUNÇÃO DE LOGS COMPACTOS (MESCLA MENSAGENS EM UMA SÓ) ---
async function registrarLogTicket(guild, idTicket, tituloGeral, usuario, novoEvento, cor) {
    if (!ID_CANAL_LOGS || ID_CANAL_LOGS.includes("SEU_ID")) return;
    try {
        const canalLogs = guild.channels.cache.get(ID_CANAL_LOGS);
        if (!canalLogs) return;

        let dadosTicket = ticketsAtivos.get(idTicket) || { logs: [], messageId: null };
        const dataFormatada = `<t:${Math.floor(Date.now() / 1000)}:R>`;
        
        // Adiciona a nova mensagem ao histórico
        dadosTicket.logs.push(`• [${dataFormatada}] ${novoEvento}`);

        const embed = new EmbedBuilder()
            .setTitle(`🎫 Painel de Atendimento — ${tituloGeral}`)
            .setColor(cor || 0x0015ff)
            .setDescription(`**Usuário:** ${usuario}\n\n**Histórico de Atividades:**\n${dadosTicket.logs.join('\n')}`)
            .setFooter({ text: "RD4X Hub • Sistema Unificado de Logs" })
            .setTimestamp();

        // Se já existe uma mensagem enviada para esse ticket, edita ela em vez de mandar uma nova
        if (dadosTicket.messageId) {
            try {
                const msgExistente = await canalLogs.messages.fetch(dadosTicket.messageId);
                if (msgExistente) {
                    await msgExistente.edit({ embeds: [embed] });
                    ticketsAtivos.set(idTicket, dadosTicket);
                    return;
                }
            } catch (e) {
                // Se a mensagem sumiu, envia uma nova abaixo
            }
        }

        // Caso contrário, cria a primeira mensagem de log
        const novaMsg = await canalLogs.send({ embeds: [embed] });
        dadosTicket.messageId = novaMsg.id;
        ticketsAtivos.set(idTicket, dadosTicket);

    } catch (e) {
        console.error("Erro ao registrar log agrupado:", e);
    }
}

client.on('messageCreate', async (message) => {
    if (message.author.bot) return;

    // Resposta automática de confirmação de envio de comprovante/imagem dentro de um ticket
    if (message.channel.name?.startsWith('ticket-')) {
        if (message.attachments.size > 0) {
            await message.reply("Aguarde um momento, você já será respondido! ⌛");
            
            await registrarLogTicket(
                message.guild, 
                message.channel.id, 
                message.channel.name, 
                `<@${message.author.id}>`, 
                `📷 Anexo/Comprovante enviado pelo cliente.`, 
                0xffaa00
            );
        }
    }

    const args = message.content.trim().split(/\s+/);
    const comando = args[0].toLowerCase();

    // 1. !admin_help / !adminhelp
    if (comando === '!admin_help' || comando === '!adminhelp') {
        const eAdmin = message.member.roles.cache.has(ID_CARGO_ADMIN) || message.author.id === ID_DONO;
        
        if (!eAdmin) {
            return message.reply("❌ Apenas administradores do **RD4X Hub** podem usar este comando!");
        }

        const embedAdmin = new EmbedBuilder()
            .setTitle("🛡️ Painel Administrativo — Comandos de Staff")
            .setDescription("Abaixo estão listados os comandos restritos para gerenciamento:")
            .addFields(
                { name: "🔑 `!liberar [tempo] [nick]`", value: "Libera o painel no Roblox (`perm`, `30d`, `1m`)." },
                { name: "🔒 `!retirarpainel [nick]`", value: "Revoga imediatamente o acesso do usuário no jogo." },
                { name: "🚫 `!blacklist [nick/id]`", value: "Bloqueia a pessoa de abrir novos tickets." },
                { name: "✅ `!unblacklist [nick/id]`", value: "Remove o bloqueio de abertura de tickets." },
                { name: "❌ `!fechar`", value: "Encerra o ticket atual, limpa o painel e gera histórico unificado." }
            )
            .setColor(0x0088ff)
            .setFooter({ text: "RD4X Hub • Acesso Restrito" })
            .setTimestamp();

        await message.reply({ embeds: [embedAdmin] });
        return;
    }

    // 2. !painel
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

    // 3. !ajuda / !help
    if (comando === '!ajuda' || comando === '!help') {
        const embedAjuda = new EmbedBuilder()
            .setTitle("🤖 Central de Ajuda — RD4X Hub")
            .setDescription("Aqui estão os comandos disponíveis para consulta e suporte:")
            .addFields(
                { name: "🎫 `!suporte`", value: "Chama os administradores no ticket.", inline: false },
                { name: "⏳ `!tempo [seu-nick]`", value: "Consulta quantos dias restam para o seu painel expirar.", inline: false },
                { name: "📦 `!status [seu-nick]`", value: "Verifica se o seu nick possui o painel ativo.", inline: false }
            )
            .setColor(0x00ffcc)
            .setFooter({ text: "RD4X Hub • Todos os direitos reservados" })
            .setTimestamp();

        await message.reply({ embeds: [embedAjuda] });
        return;
    }

    // 4. !liberar [tempo] [nick]
    if (comando === '!liberar') {
        const eAdmin = message.member.roles.cache.has(ID_CARGO_ADMIN) || message.author.id === ID_DONO;
        if (!eAdmin) return message.reply("❌ Sem permissão!");

        const tempoInput = args[1]?.toLowerCase();
        const nickRoblox = args[2];

        if (!tempoInput || !nickRoblox) {
            return message.reply("⚠️ Uso correto: `!liberar [tempo] [nick]`\nExemplos: `perm`, `30d`, `7d`, `1m`");
        }

        let tempoExpiracao;
        let textoTempoExibicao = "";

        if (tempoInput === "perm" || tempoInput === "permanente") {
            tempoExpiracao = "perm";
            textoTempoExibicao = "permanente (vitalício)";
        } else {
            const match = tempoInput.match(/^(\d+)([a-z]*)$/);
            if (!match) {
                return message.reply("⚠️ Formato de tempo inválido! Use `30d`, `perm` ou `1m`.");
            }

            const quantidade = parseInt(match[1]);
            const unidade = match[2] || 'd';

            let diasTotais = quantidade;
            if (unidade === 'm') diasTotais = quantidade * 30;
            else if (unidade === 'h') diasTotais = quantidade / 24;

            tempoExpiracao = Date.now() + (diasTotais * 24 * 60 * 60 * 1000);
            textoTempoExibicao = `${quantidade} ${unidade === 'm' ? 'mês/meses' : 'dia(s)'}`;
        }

        usuariosLiberados.set(nickRoblox, tempoExpiracao);

        await message.reply(`✅ Acesso liberado para **${nickRoblox}** por **${textoTempoExibicao}**!`);
        
        if (message.channel.name?.startsWith('ticket-')) {
            await registrarLogTicket(
                message.guild, 
                message.channel.id, 
                message.channel.name, 
                `<@${message.author.id}>`, 
                `🔓 Acesso liberado no Roblox para **${nickRoblox}** (${textoTempoExibicao}) por ${message.author.tag}.`, 
                0x00ff88
            );
        }
        return;
    }

    // 5. !retirarpainel [nick]
    if (comando === '!retirarpainel') {
        const eAdmin = message.member.roles.cache.has(ID_CARGO_ADMIN) || message.author.id === ID_DONO;
        if (!eAdmin) return message.reply("❌ Sem permissão!");

        const nickRoblox = args[1];
        if (!nickRoblox) return message.reply("⚠️ Uso correto: `!retirarpainel [nick]`");
        
        usuariosLiberados.delete(nickRoblox);
        await message.reply(`🔒 O painel de **${nickRoblox}** foi revogado.`);
        return;
    }

    // 6. !status [nick]
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

    // 7. !tempo [nick]
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

    // 8. !blacklist / !unblacklist
    if (comando === '!blacklist') {
        const eAdmin = message.member.roles.cache.has(ID_CARGO_ADMIN) || message.author.id === ID_DONO;
        if (!eAdmin) return message.reply("❌ Sem permissão!");

        const alvo = args[1];
        if (!alvo) return message.reply("⚠️ Uso correto: `!blacklist [nick ou id]`");
        blacklist.add(alvo);
        await message.reply(`🚫 **${alvo}** foi adicionado à **Blacklist**.`);
        return;
    }

    if (comando === '!unblacklist') {
        const eAdmin = message.member.roles.cache.has(ID_CARGO_ADMIN) || message.author.id === ID_DONO;
        if (!eAdmin) return message.reply("❌ Sem permissão!");

        const alvo = args[1];
        if (!alvo) return message.reply("⚠️ Uso correto: `!unblacklist [nick ou id]`");
        if (blacklist.has(alvo)) {
            blacklist.delete(alvo);
            await message.reply(`✅ **${alvo}** foi removido da Blacklist.`);
        } else {
            await message.reply(`❌ **${alvo}** não está na blacklist.`);
        }
        return;
    }

    // 9. !suporte
    if (comando === '!suporte') {
        let msgSuporte = `🆘 **Ajuda solicitada!**\n\nAguarde os administradores. <@&${ID_CARGO_ADMIN}>`;
        await message.reply({ content: msgSuporte, allowedMentions: { roles: [ID_CARGO_ADMIN] } });
        return;
    }

    // 10. !fechar (Limpa mensagens antigas do bot, registra o log final e deleta o canal)
    if (comando === '!fechar') {
        if (!message.channel.name.startsWith('ticket-')) {
            return message.reply("❌ Este comando só pode ser usado dentro de um canal de ticket!");
        }

        await message.reply("🔒 Limpando mensagens do painel, encerrando o atendimento e atualizando os logs...");

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

        await registrarLogTicket(
            message.guild, 
            message.channel.id, 
            message.channel.name, 
            `<@${message.author.id}>`, 
            `🔒 Ticket encerrado por ${message.author.tag}.`, 
            0xff0044
        );

        if (ID_CANAL_AVALIACOES && !ID_CANAL_AVALIACOES.includes("SEU_ID")) {
            const canalAvaliacoes = message.guild.channels.cache.get(ID_CANAL_AVALIACOES);
            if (canalAvaliacoes) {
                const embedAvaliacao = new EmbedBuilder()
                    .setTitle("⭐ Nova Avaliação de Atendimento")
                    .setDescription(`Atendimento encerrado para o ticket **${message.channel.name}**.\nObrigado por comprar com o RD4X!`)
                    .setColor(0x00ffcc)
                    .setTimestamp();
                await canalAvaliacoes.send({ embeds: [embedAvaliacao] }).catch(() => {});
            }
        }

        setTimeout(async () => {
            ticketsAtivos.delete(message.channel.id);
            await message.channel.delete().catch(() => {});
        }, 3000);
        return;
    }
});

// --- INTERAÇÃO DE CRIAR TICKET ---
client.on('interactionCreate', async (interaction) => {
    if (!interaction.isButton()) return;

    if (interaction.customId === 'criar_ticket') {
        const guild = interaction.guild;
        const member = interaction.member;

        if (blacklist.has(member.user.username) || blacklist.has(member.id)) {
            return interaction.reply({ content: `❌ Você está bloqueado de abrir tickets.`, ephemeral: true });
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

        let textoTicket = `Para adquirir seu Painel Admin, mande seu pix na chave abaixo:\n` +
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

        await registrarLogTicket(
            guild, 
            channel.id, 
            nomeCanal, 
            `<@${member.user.id}>`, 
            `🟢 Ticket criado pelo cliente.`, 
            0x00ffcc
        );

        await interaction.editReply({ content: `✅ Seu ticket foi criado com sucesso aqui: ${channel}` });
    }
});

client.login(process.env.DISCORD_TOKEN);
