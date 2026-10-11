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
    if (!ID_CANAL_LOGS) return;
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
            
            // Registra no canal de logs que o comprovante foi enviado
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

    // 1. !admin_help / !adminhelp (Comandos exclusivos para Admins)
    if (comando === '!admin_help' || comando === '!adminhelp') {
        const eAdmin = message.member.roles.cache.has(ID_CARGO_ADMIN) || message.author.id === ID_DONO;
        
        if (!eAdmin) {
            return message.reply("❌ Apenas administradores do **RD4X Hub** podem usar este comando!");
        }

        const embedAdmin = new EmbedBuilder()
            .setTitle("🛡️ Painel Administrativo — Comandos de Staff")
            .setDescription("Abaixo estão listados os comandos restritos para gerenciamento do hub e tickets:")
            .addFields(
                { name: "🔑 `!liberar [tempo] [nick]`", value: "Libera o painel no Roblox. Aceita: `perm`, `30d`, `7d`, `1m`." },
                { name: "🔒 `!retirarpainel [nick]`", value: "Revoga imediatamente o acesso do usuário no jogo." },
                { name: "🚫 `!blacklist [nick/id]`", value: "Bloqueia a pessoa de abrir novos tickets." },
                { name: "✅ `!unblacklist [nick/id]`", value: "Remove o bloqueio de abertura de tickets." },
                { name: "❌ `!fechar`", value: "Encerra o ticket atual, envia avaliação e gera histórico unificado." }
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
                { name: "🎫 `!suporte`", value: "Chama os administradores no ticket caso tenha dúvidas.", inline: false },
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
            textoTempoExibicao = "permanente (
 
