const { Client, GatewayIntentBits, ActionRowBuilder, ButtonBuilder, ButtonStyle, ChannelType, PermissionFlagsBits, EmbedBuilder, AttachmentBuilder } = require('discord.js');
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
        const dados = usuariosLiberados.get(nickRoblox);
        const expiraEm = typeof dados === 'object' ? dados.expiraEm : dados;
        
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
const ID_CARGO_CLIENTE = "1549273666951577691"; // Cole aqui o ID do Cargo VIP do seu Discord
const CHAVE_PIX = "85777075550";
const ID_CANAL_LOGS = "1549274555175018587"; 
const ID_CANAL_AVALIACOES = "1549458044331757660"; 

// Bancos de dados em memória
const usuariosLiberados = new Map(); // nickRoblox -> { expiraEm, discordId, avisadoExpiracao }
const blacklist = new Set(); 
const ticketsAtivos = new Map(); // idCanal -> { logs, messageId, ultimoContato, avisoInatividade }
const cooldownTickets = new Map(); // discordId -> timestamp

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

    // --- (RECURSO 4) STATUS DINÂMICO DO BOT ---
    let indiceStatus = 0;
    setInterval(() => {
        const totalClientes = usuariosLiberados.size;
        const listaStatus = [
            { name: 'RD4X Hub | v2.0 🚀', type: 0 }, // Playing
            { name: `${totalClientes} Clientes VIP 💎`, type: 3 }, // Watching
            { name: '!ajuda | Suporte 🎫', type: 2 } // Listening
        ];
        
        client.user.setActivity(listaStatus[indiceStatus].name, { type: listaStatus[indiceStatus].type });
        indiceStatus = (indiceStatus + 1) % listaStatus.length;
    }, 15000);

    // --- (RECURSO 1) AVISO AUTOMÁTICO DE EXPIRAÇÃO DE WHITELIST (DM) ---
    setInterval(async () => {
        const agora = Date.now();
        const doisDiasEmMs = 2 * 24 * 60 * 60 * 1000;

        for (const [nick, dados] of usuariosLiberados.entries()) {
            if (dados.expiraEm && dados.expiraEm !== "perm") {
                const tempoRestante = dados.expiraEm - agora;

                if (tempoRestante > 0 && tempoRestante <= doisDiasEmMs && !dados.avisadoExpiracao) {
                    dados.avisadoExpiracao = true;
                    if (dados.discordId) {
                        try {
                            const user = await client.users.fetch(dados.discordId);
                            if (user) {
                                await user.send(`⚠️ **Aviso de Expiração — RD4X Hub**\n\nOlá! Seu painel no Roblox para a conta **${nick}** irá expirar em menos de 48 horas.\nAbra um ticket no servidor para renovar seu acesso!`);
                            }
                        } catch (e) {}
                    }
                }

                if (tempoRestante <= 0) {
                    if (dados.discordId && ID_CARGO_CLIENTE && !ID_CARGO_CLIENTE.includes("SEU_ID")) {
                        for (const guild of client.guilds.cache.values()) {
                            try {
                                const member = await guild.members.fetch(dados.discordId);
                                if (member) await member.roles.remove(ID_CARGO_CLIENTE).catch(() => {});
                            } catch (e) {}
                        }
                    }
                    usuariosLiberados.delete(nick);
                }
            }
        }
    }, 60000);

    // --- (RECURSO 7) AUTO-CLOSE POR INATIVIDADE (24h) ---
    setInterval(async () => {
        const agora = Date.now();
        const vinteEQuatroHoras = 24 * 60 * 60 * 1000;

        for (const [idCanal, dados] of ticketsAtivos.entries()) {
            if (dados.ultimoContato && (agora - dados.ultimoContato >= vinteEQuatroHoras) && !dados.avisoInatividade) {
                dados.avisoInatividade = true;
                const canal = client.channels.cache.get(idCanal);
                if (canal) {
                    await canal.send("⏱️ **Aviso de Inatividade:** Este ticket está sem respostas há 24 horas e poderá ser encerrado em breve.");
                }
            }
        }
    }, 300000);
});

// --- FUNÇÃO DE LOGS COMPACTOS ---
async function registrarLogTicket(guild, idTicket, tituloGeral, usuario, novoEvento, cor) {
    if (!ID_CANAL_LOGS || ID_CANAL_LOGS.includes("SEU_ID")) return;
    try {
        const canalLogs = guild.channels.cache.get(ID_CANAL_LOGS);
        if (!canalLogs) return;

        let dadosTicket = ticketsAtivos.get(idTicket) || { logs: [], messageId: null, ultimoContato: Date.now() };
        const dataFormatada = `<t:${Math.floor(Date.now() / 1000)}:R>`;
        
        dadosTicket.logs.push(`• [${dataFormatada}] ${novoEvento}`);

        const embed = new EmbedBuilder()
            .setTitle(`🎫 Painel de Atendimento — ${tituloGeral}`)
            .setColor(cor || 0x0015ff)
            .setDescription(`**Usuário:** ${usuario}\n\n**Histórico de Atividades:**\n${dadosTicket.logs.join('\n')}`)
            .setFooter({ text: "RD4X Hub • Sistema Unificado de Logs" })
            .setTimestamp();

        if (dadosTicket.messageId) {
            try {
                const msgExistente = await canalLogs.messages.fetch(dadosTicket.messageId);
                if (msgExistente) {
                    await msgExistente.edit({ embeds: [embed] });
                    ticketsAtivos.set(idTicket, dadosTicket);
                    return;
                }
            } catch (e) {}
        }

        const novaMsg = await canalLogs.send({ embeds: [embed] });
        dadosTicket.messageId = novaMsg.id;
        ticketsAtivos.set(idTicket, dadosTicket);

    } catch (e) {
        console.error("Erro ao registrar log agrupado:", e);
    }
}

client.on('messageCreate', async (message) => {
    if (message.author.bot) return;

    if (message.channel.name?.startsWith('ticket-')) {
        let dados = ticketsAtivos.get(message.channel.id) || { logs: [], messageId: null };
        dados.ultimoContato = Date.now();
        dados.avisoInatividade = false;
        ticketsAtivos.set(message.channel.id, dados);

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

    // 1. !admin_help
    if (comando === '!admin_help' || comando === '!adminhelp') {
        const eAdmin = message.member.roles.cache.has(ID_CARGO_ADMIN) || message.author.id === ID_DONO;
        if (!eAdmin) return message.reply("❌ Apenas administradores do **RD4X Hub** podem usar este comando!");

        const embedAdmin = new EmbedBuilder()
            .setTitle("🛡️ Painel Administrativo — Comandos de Staff")
            .setDescription("Abaixo estão listados os comandos restritos para gerenciamento:")
            .addFields(
                { name: "🔑 `!liberar [tempo] [nick] [@membro]`", value: "Libera a whitelist e concede o cargo VIP no Discord." },
                { name: "🔒 `!retirarpainel [nick]`", value: "Revoga o acesso no Roblox e remove o cargo VIP." },
                { name: "🚫 `!blacklist [nick/id]`", value: "Bloqueia a pessoa de abrir novos tickets." },
                { name: "✅ `!unblacklist [nick/id]`", value: "Remove o bloqueio de abertura de tickets." },
                { name: "❌ `!fechar`", value: "Encerra o ticket, envia o arquivo transcript .txt nos logs e limpa mensagens." }
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
            content: `<@${message.author.id}> Clique em criar ticket abaixo para adquirir seu Painel Admin:`,
            components: [row]
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

    // 4. !liberar [tempo] [nick] [@membro] (RECURSO 5: Auto-Role)
    if (comando === '!liberar') {
        const eAdmin = message.member.roles.cache.has(ID_CARGO_ADMIN) || message.author.id === ID_DONO;
        if (!eAdmin) return message.reply("❌ Sem permissão!");

        const tempoInput = args[1]?.toLowerCase();
        const nickRoblox = args[2];
        const mencaoDiscord = message.mentions.members.first();

        if (!tempoInput || !nickRoblox) {
            return message.reply("⚠️ Uso correto: `!liberar [tempo] [nick] [@membro_opcional]`\nExemplos: `30d`, `perm`, `1m`");
        }

        let tempoExpiracao;
        let textoTempoExibicao = "";

        if (tempoInput === "perm" || tempoInput === "permanente") {
            tempoExpiracao = "perm";
            textoTempoExibicao = "permanente (vitalício)";
        } else {
            const match = tempoInput.match(/^(\d+)([a-z]*)$/);
            if (!match) return message.reply("⚠️ Formato de tempo inválido! Use `30d`, `perm` ou `1m`.");

            const quantidade = parseInt(match[1]);
            const unidade = match[2] || 'd';

            let diasTotais = quantidade;
            if (unidade === 'm') diasTotais = quantidade * 30;
            else if (unidade === 'h') diasTotais = quantidade / 24;

            tempoExpiracao = Date.now() + (diasTotais * 24 * 60 * 60 * 1000);
            textoTempoExibicao = `${quantidade} ${unidade === 'm' ? 'mês/meses' : 'dia(s)'}`;
        }

        usuariosLiberados.set(nickRoblox, {
            expiraEm: tempoExpiracao,
            discordId: mencaoDiscord ? mencaoDiscord.id : null,
            avisadoExpiracao: false
        });

        if (mencaoDiscord && ID_CARGO_CLIENTE && !ID_CARGO_CLIENTE.includes("SEU_ID")) {
            await mencaoDiscord.roles.add(ID_CARGO_CLIENTE).catch(() => {});
        }

        await message.reply(`✅ Acesso liberado para **${nickRoblox}** por **${textoTempoExibicao}**!${mencaoDiscord ? ` Cargo VIP concedido a <@${mencaoDiscord.id}>.` : ''}`);
        
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
        
        const dados = usuariosLiberados.get(nickRoblox);
        if (dados && dados.discordId && ID_CARGO_CLIENTE && !ID_CARGO_CLIENTE.includes("SEU_ID")) {
            const member = await message.guild.members.fetch(dados.discordId).catch(() => {});
            if (member) await member.roles.remove(ID_CARGO_CLIENTE).catch(() => {});
        }

        usuariosLiberados.delete(nickRoblox);
        await message.reply(`🔒 O painel de **${nickRoblox}** foi revogado.`);
        return;
    }

    // 6. !status / !tempo / !suporte
    if (comando === '!status') {
        const nickRoblox = args[1];
        if (!nickRoblox) return message.reply("⚠️ Uso correto: `!status [nick]`");
        
        if (usuariosLiberados.has(nickRoblox) || nickRoblox === ID_DONO) {
            await message.reply(`🟢 O jogador **${nickRoblox}** possui um painel **ativo**.`);
        } else {
            await message.reply(`🔴 O jogador **${nickRoblox}** **não** possui registro ativo.`);
        }
        return;
    }

    if (comando === '!tempo') {
        const nickRoblox = args[1];
        if (!nickRoblox) return message.reply("⚠️ Uso correto: `!tempo [nick]`");

        if (usuariosLiberados.has(nickRoblox)) {
            const dados = usuariosLiberados.get(nickRoblox);
            const expiraEm = typeof dados === 'object' ? dados.expiraEm : dados;
            
            if (expiraEm === "perm") return message.reply(`♾️ O painel de **${nickRoblox}** é **Permanente**.`);

            const tempoRestante = expiraEm - Date.now();
            if (tempoRestante <= 0) return message.reply(`⏱️ O painel de **${nickRoblox}** já expirou.`);
            
            const diasRestantes = Math.ceil(tempoRestante / (1000 * 60 * 60 * 24));
            await message.reply(`⏳ Restam aproximadamente **${diasRestantes} dia(s)** para o painel de **${nickRoblox}** expirar.`);
        } else {
            await message.reply(`❌ O jogador **${nickRoblox}** não está cadastrado.`);
        }
        return;
    }

    if (comando === '!suporte') {
        let msgSuporte = `🆘 **Ajuda solicitada!**\n\nAguarde os administradores. <@&${ID_CARGO_ADMIN}>`;
        await message.reply({ content: msgSuporte, allowedMentions: { roles: [ID_CARGO_ADMIN] } });
        return;
    }

    // 7. !fechar (RECURSO 2: Transcript em .TXT e Limpeza do Painel)
    if (comando === '!fechar') {
        if (!message.channel.name.startsWith('ticket-')) {
            return message.reply("❌ Este comando só pode ser usado dentro de um canal de ticket!");
        }

        await message.reply("🔒 Baixando histórico de conversas, enviando transcript e fechando o ticket...");

        let arquivoTranscript = null;
        try {
            const colecaoMensagens = await message.channel.messages.fetch({ limit: 100 });
            const conversas = colecaoMensagens.reverse().map(m => `[${m.createdAt.toLocaleString('pt-BR')}] ${m.author.tag}: ${m.content}`).join('\n');
            
            const bufferTranscript = Buffer.from(conversas, 'utf-8');
            arquivoTranscript = new AttachmentBuilder(bufferTranscript, { name: `transcript-${message.channel.name}.txt` });
        } catch (e) {
            console.error("Erro ao gerar transcript:", e);
        }

        try {
            const mensagens = await message.channel.messages.fetch({ limit: 20 });
            for (const [id, msg] of mensagens) {
                if (msg.author.id === client.user.id || msg.content.toLowerCase().includes('!painel')) {
                    await msg.delete().catch(() => {});
                }
            }
        } catch (e) {}

        if (ID_CANAL_LOGS && arquivoTranscript) {
            const canalLogs = message.guild.channels.cache.get(ID_CANAL_LOGS);
            if (canalLogs) {
                await canalLogs.send({ 
                    content: `📑 **Transcript em Anexo:** Conversa completa do canal \`${message.channel.name}\` fechado por **${message.author.tag}**.`,
                    files: [arquivoTranscript]
                }).catch(() => {});
            }
        }

        await registrarLogTicket(
            message.guild, 
            message.channel.id, 
            message.channel.name, 
            `<@${message.author.id}>`, 
            `🔒 Ticket encerrado e arquivo de histórico (Transcript) salvo.`, 
            0xff0044
        );

        setTimeout(async () => {
            ticketsAtivos.delete(message.channel.id);
            await message.channel.delete().catch(() => {});
        }, 3000);
        return;
    }
});

// --- INTERAÇÃO DE CRIAR TICKET (RECURSO 3: Antispam) ---
client.on('interactionCreate', async (interaction) => {
    if (!interaction.isButton()) return;

    if (interaction.customId === 'criar_ticket') {
        const guild = interaction.guild;
        const member = interaction.member;

        const tempoUltimoTicket = cooldownTickets.get(member.id);
        if (tempoUltimoTicket && (Date.now() - tempoUltimoTicket < 300000)) {
            const tempoRestante = Math.ceil((300000 - (Date.now() - tempoUltimoTicket)) / 1000);
            return interaction.reply({ content: `⏳ Por favor, aguarde **${tempoRestante} segundos** antes de abrir outro ticket.`, ephemeral: true });
        }

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
        cooldownTickets.set(member.id, Date.now());

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

        await channel.send({ content: `<@${member.user.id}>\n\n` + textoTicket, allowedMentions: { users: [member.user.id] } });
        await channel.send({ content: `Aguarde os responsáveis analisarem o comprovante. <@&${ID_CARGO_ADMIN}>`, allowedMentions: { roles: [ID_CARGO_ADMIN] } });

        await registrarLogTicket(guild, channel.id, nomeCanal, `<@${member.user.id}>`, `🟢 Ticket criado pelo cliente.`, 0x00ffcc);

        await interaction.editReply({ content: `✅ Seu ticket foi criado com sucesso aqui: ${channel}` });
    }
});

client.login(process.env.DISCORD_TOKEN);
