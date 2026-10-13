const { Client, GatewayIntentBits, ActionRowBuilder, ButtonBuilder, ButtonStyle, ChannelType, PermissionFlagsBits, EmbedBuilder, AttachmentBuilder } = require('discord.js');
const express = require('express');

// --- SERVIDOR WEB & API PARA O ROBLOX ---
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

app.get('/', (req, res) => {
    res.send('RD4X Bot está online e ativo!');
});

// --- ROTA DE WHITELIST COM LOCK DE HWID / DISPOSITIVO ---
app.get('/api/v2/whitelist', (req, res) => {
    const nickRoblox = req.query.nick || req.query.userid;
    const hwidCliente = req.query.hwid || req.headers['x-hwid'] || "HWID_NAO_ENVIADO";

    if (!nickRoblox) {
        return res.json({ success: false, whitelisted: false, message: "Nick ausente" });
    }

    if (nickRoblox === ID_DONO) {
        return res.json({ success: true, whitelisted: true, role: "Dono" });
    }

    if (usuariosLiberados.has(nickRoblox)) {
        const dados = usuariosLiberados.get(nickRoblox);
        const expiraEm = typeof dados === 'object' ? dados.expiraEm : dados;
        
        if (expiraEm !== "perm" && Date.now() > expiraEm) {
            usuariosLiberados.delete(nickRoblox);
            return res.json({ success: false, whitelisted: false, message: "Expirado" });
        }

        if (dados.hwid && dados.hwid !== "LIVRE") {
            if (dados.hwid !== hwidCliente) {
                notificarSuspeitaHWID(nickRoblox, hwidCliente, dados.hwid);
                return res.json({ success: false, whitelisted: false, message: "HWID incompativel. Uso em outro aparelho detectado!" });
            }
        } else {
            dados.hwid = hwidCliente;
            usuariosLiberados.set(nickRoblox, dados);
        }

        return res.json({ success: true, whitelisted: true });
    }

    return res.json({ success: false, whitelisted: false });
});

// --- ROTA DE LOGS DE EXECUÇÃO DO HUB NO ROBLOX ---
app.post('/api/v2/execucoes', async (req, res) => {
    const { nick, jogo } = req.body;
    totalExecucoesGlobais++;

    if (ID_CANAL_LOGS && client.isReady()) {
        try {
            const canal = client.channels.cache.get(ID_CANAL_LOGS);
            if (canal) {
                const embedExec = new EmbedBuilder()
                    .setTitle("🎮 RD4X Hub — Executado no Roblox")
                    .setDescription(`**Jogador:** \`${nick || 'Desconhecido'}\`\n**Jogo:** \`${jogo || 'Blox Fruits / Geral'}\`\n**Status:** ✅ Acesso Validado`)
                    .setColor(0x00ff88)
                    .setTimestamp();
                await canal.send({ embeds: [embedExec] });
            }
        } catch (e) {
            console.error("Erro ao mandar log de execução:", e);
        }
    }

    return res.json({ success: true, logged: true });
});

app.listen(port, () => {
    console.log(`[WEB] Servidor web e API rodando na porta ${port}`);
});

// --- CONFIGURAÇÕES E IDS ---
const ID_DONO = "1549272865260441631";
const ID_CARGO_ADMIN = "1549273436705259570";
const ID_CARGO_CLIENTE = "1549273666951577691"; // Substitua pelo ID real do seu cargo VIP
const CHAVE_PIX = "85777075550";
const ID_CANAL_LOGS = "1549274555175018587"; 
const ID_CANAL_AVALIACOES = "1549458044331757660"; 

// Estatísticas e Bancos em Memória
let totalExecucoesGlobais = 0;
let historicoVendas = []; 
const usuariosLiberados = new Map(); 
const blacklist = new Set(); 
const ticketsAtivos = new Map(); 
const cooldownTickets = new Map(); 

// --- BOT DO DISCORD ---
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

async function notificarSuspeitaHWID(nick, hwidTentativa, hwidRegistrado) {
    if (!ID_CANAL_LOGS) return;
    try {
        const canal = client.channels.cache.get(ID_CANAL_LOGS);
        if (canal) {
            const embedHWID = new EmbedBuilder()
                .setTitle("🚨 Alerta de Segurança — HWID Incompatível")
                .setDescription(`Tentativa de uso em outro aparelho detectada!\n\n**Nick:** \`${nick}\`\n**HWID Registrado:** \`${hwidRegistrado}\`\n**HWID Tentativa:** \`${hwidTentativa}\``)
                .setColor(0xff0000)
                .setTimestamp();
            await canal.send({ embeds: [embedHWID] });
        }
    } catch (e) {}
}

client.once('ready', () => {
    console.log(`[SUCESSO] Bot online e conectado como ${client.user.tag}!`);

    let indiceStatus = 0;
    setInterval(() => {
        const totalClientes = usuariosLiberados.size;
        const listaStatus = [
            { name: 'RD4X Hub | v2.0 🚀', type: 0 },
            { name: `${totalClientes} Clientes VIP 💎`, type: 3 },
            { name: `${totalExecucoesGlobais} Injeções no Roblox 🎮`, type: 0 },
            { name: '!ajuda | Suporte 🎫', type: 2 }
        ];
        
        client.user.setActivity(listaStatus[indiceStatus].name, { type: listaStatus[indiceStatus].type });
        indiceStatus = (indiceStatus + 1) % listaStatus.length;
    }, 15000);

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

async function registrarLogTicket(guild, idTicket, tituloGeral, usuario, novoEvento, cor) {
    if (!ID_CANAL_LOGS || ID_CANAL_LOGS.includes("SEU_ID")) return;
    try {
        const canalLogs = guild.channels.cache.get(ID_CANAL_LOGS);
        if (!canalLogs) return;

        let dadosTicket = ticketsAtivos.get(idTicket) || { logs: [], messageId: null, ultimoContato: Date.now() };
        const dataFormatada = `<t:${Math.floor(Date.now() / 1000)}:R>`;
        
        dadosTicket.logs.push(`• [${dataFormatada}]${novoEvento}`);

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

    if (comando === '!admin_help' || comando === '!adminhelp') {
        const eAdmin = message.member.roles.cache.has(ID_CARGO_ADMIN) || message.author.id === ID_DONO;
        if (!eAdmin) return message.reply("❌ Apenas administradores do **RD4X Hub** podem usar este comando!");

        const embedAdmin = new EmbedBuilder()
            .setTitle("🛡️ Painel Administrativo — Comandos de Staff")
            .setDescription("Abaixo estão listados os comandos restritos para gerenciamento:")
            .addFields(
                { name: "🔑 `!liberar [tempo] [nick] [@membro] [valor_opcional]`", value: "Libera whitelist, vincula VIP e registra faturamento." },
                { name: "🔄 `!resetarhwid [nick]`", value: "Reseta o HWID/Aparelho vinculado ao nick do cliente." },
                { name: "📈 `!financeiro`", value: "Exibe o painel de faturamento e vendas (Exclusivo Dono)." },
                { name: "🔒 `!retirarpainel [nick]`", value: "Revoga o acesso no Roblox e remove o cargo VIP." },
                { name: "🚫 `!blacklist [nick/id]`", value: "Bloqueia a pessoa de abrir novos tickets." },
                { name: "✅ `!unblacklist [nick/id]`", value: "Remove o bloqueio de abertura de tickets." },
                { name: "❌ `!fechar`", value: "Encerra o ticket, envia transcript e limpa mensagens." }
            )
            .setColor(0x0088ff)
            .setFooter({ text: "RD4X Hub • Acesso Restrito" })
            .setTimestamp();

        await message.reply({ embeds: [embedAdmin] });
        return;
    }

    if (comando === '!financeiro' || comando === '!vendas') {
        if (message.author.id !== ID_DONO) {
            return message.reply("❌ Este comando é exclusivo do **Dono** do RD4X Hub!");
        }

        let faturamentoTotal = historicoVendas.reduce((acc, v) => acc + (v.valor || 0), 0);

        const embedFinanceiro = new EmbedBuilder()
            .setTitle("📈 Painel Financeiro & Estatísticas — RD4X Hub")
            .setColor(0x00ff88)
            .addFields(
                { name: "💎 Clientes VIP Ativos", value: `\`${usuariosLiberados.size}\` clientes`, inline: true },
                { name: "🎮 Injeções no Roblox", value: `\`${totalExecucoesGlobais}\` execuções`, inline: true },
                { name: "💰 Faturamento Registrado", value: `\`R$ ${faturamentoTotal.toFixed(2)}\``, inline: true },
                { name: "📦 Total de Vendas", value: `\`${historicoVendas.length}\` vendas realizadas`, inline: true }
            )
            .setFooter({ text: "RD4X Hub • Dados Confidenciais" })
            .setTimestamp();

        await message.reply({ embeds: [embedFinanceiro] });
        return;
    }

    if (comando === '!resetarhwid') {
        const eAdmin = message.member.roles.cache.has(ID_CARGO_ADMIN) || message.author.id === ID_DONO;
        if (!eAdmin) return message.reply("❌ Sem permissão!");

        const nickRoblox = args[1];
        if (!nickRoblox) return message.reply("⚠️ Uso correto: `!resetarhwid [nick]`");

        if (usuariosLiberados.has(nickRoblox)) {
            const dados = usuariosLiberados.get(nickRoblox);
            dados.hwid = "LIVRE";
            usuariosLiberados.set(nickRoblox, dados);

            await message.reply(`🔄 O HWID do jogador **${nickRoblox}** foi resetado! O novo aparelho que entrar primeiro será vinculado.`);
            await registrarLogTicket(message.guild, message.channel.id, message.channel.name, `<@${message.author.id}>`, `🔄 HWID resetado para **${nickRoblox}**.`, 0x00aaff);
        } else {
            await message.reply(`❌ O jogador **${nickRoblox}** não possui cadastro ativo.`);
        }
        return;
    }

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

    if (comando === '!liberar') {
        const eAdmin = message.member.roles.cache.has(ID_CARGO_ADMIN) || message.author.id === ID_DONO;
        if (!eAdmin) return message.reply("❌ Sem permissão!");

        const tempoInput = args[1]?.toLowerCase();
        const nickRoblox = args[2];
        const mencaoDiscord = message.mentions.members.first();
        const valorComprado = parseFloat(args[4] || args[3]) || 0;

        if (!tempoInput || !nickRoblox) {
            return message.reply("⚠️ Uso correto: `!liberar [tempo] [nick] [@membro_opcional] [valor_opcional]`\nExemplo: `!liberar 30d Jogador123 @Cliente 15`");
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
            avisadoExpiracao: false,
            hwid: "LIVRE", 
            valorPago: valorComprado,
            dataVenda: new Date()
        });

        if (valorComprado > 0) {
            historicoVendas.push({ nick: nickRoblox, valor: valorComprado, data: new Date() });
        }

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

        await interaction.reply({ content: `🔄 Criando seu canal de ticket, aguarde um instante...`, ephemeral: true });
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
