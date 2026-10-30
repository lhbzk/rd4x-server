const { Client, GatewayIntentBits, ActionRowBuilder, ButtonBuilder, ButtonStyle, ChannelType, PermissionFlagsBits, EmbedBuilder, AttachmentBuilder } = require('discord.js');
const express = require('express');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// ============================================================
// RD4X HUB — BOT + TICKETS + WHITELIST/HWID + DASHBOARD API
// V10 — persistência local sem banco nativo, ideal para hospedagem móvel
// ============================================================

const app = express();
const port = process.env.SERVER_PORT || process.env.PORT || 3000;
app.use(express.json({ limit: '1mb' }));

const DATA_DIR = path.join(__dirname, 'data');
const TRANSCRIPT_DIR = path.join(DATA_DIR, 'transcripts');
fs.mkdirSync(DATA_DIR, { recursive: true });
fs.mkdirSync(TRANSCRIPT_DIR, { recursive: true });
const DB_FILE = path.join(DATA_DIR, 'rd4x-data.json');

const ID_DONO = process.env.ID_DONO || '1549272865260441631';
const ID_CARGO_ADMIN = process.env.ID_CARGO_ADMIN || '1549273436705259570';
const ID_CARGO_CLIENTE = process.env.ID_CARGO_CLIENTE || '1549273666951577691';
const CHAVE_PIX = process.env.CHAVE_PIX || '85777075550';
const ID_CANAL_LOGS = process.env.ID_CANAL_LOGS || '1549274555175018587';
const ID_CANAL_AVALIACOES = process.env.ID_CANAL_AVALIACOES || '1549458044331757660';
const GUILD_ID = process.env.GUILD_ID || '';
const DASHBOARD_API_KEY = process.env.DASHBOARD_API_KEY || '';

const DEFAULT_DB = {
  version: 2,
  totalExecucoesGlobais: 0,
  historicoVendas: [],
  usuariosLiberados: {},
  blacklist: [],
  tickets: {},
  cooldownTickets: {},
  auditoria: [],
  incidentes: [],
  adminDevices: {},
  releaseWindow: []
};

function loadDB() {
  try {
    if (!fs.existsSync(DB_FILE)) return structuredClone(DEFAULT_DB);
    const parsed = JSON.parse(fs.readFileSync(DB_FILE, 'utf8'));
    return { ...structuredClone(DEFAULT_DB), ...parsed };
  } catch (err) {
    console.error('[DB] Falha ao ler banco local:', err);
    return structuredClone(DEFAULT_DB);
  }
}

let db = loadDB();
let saveTimer = null;
function saveDB(immediate = false) {
  if (saveTimer) clearTimeout(saveTimer);
  const write = () => {
    const tmp = `${DB_FILE}.tmp`;
    fs.writeFileSync(tmp, JSON.stringify(db, null, 2), 'utf8');
    fs.renameSync(tmp, DB_FILE);
  };
  if (immediate) write();
  else saveTimer = setTimeout(() => { try { write(); } catch (e) { console.error('[DB] Erro ao salvar:', e); } }, 250);
}

// Compatibilidade com o código anterior: os nomes continuam existindo.
const usuariosLiberados = new Map(Object.entries(db.usuariosLiberados));
const historicoVendas = db.historicoVendas;
const blacklist = new Set(db.blacklist);
const ticketsAtivos = new Map(Object.entries(db.tickets));
const cooldownTickets = new Map(Object.entries(db.cooldownTickets));
let totalExecucoesGlobais = db.totalExecucoesGlobais || 0;

function syncDB() {
  db.usuariosLiberados = Object.fromEntries(usuariosLiberados);
  db.tickets = Object.fromEntries(ticketsAtivos);
  db.cooldownTickets = Object.fromEntries(cooldownTickets);
  db.blacklist = [...blacklist];
  db.totalExecucoesGlobais = totalExecucoesGlobais;
  saveDB();
}

function audit(actor, action, target = '', details = {}) {
  db.auditoria.push({ id: crypto.randomUUID(), at: new Date().toISOString(), actor, action, target, details });
  if (db.auditoria.length > 5000) db.auditoria.splice(0, db.auditoria.length - 5000);
  saveDB();
}

function incident(type, severity, details = {}) {
  db.incidentes.push({ id: crypto.randomUUID(), at: new Date().toISOString(), type, severity, status: 'open', details });
  if (db.incidentes.length > 1000) db.incidentes.splice(0, db.incidentes.length - 1000);
  saveDB();
}

function isAdmin(member, userId) {
  return userId === ID_DONO || Boolean(member?.roles?.cache?.has(ID_CARGO_ADMIN));
}
function isOwner(userId) { return userId === ID_DONO; }

async function getGuild() {
  if (GUILD_ID) return client.guilds.cache.get(GUILD_ID) || await client.guilds.fetch(GUILD_ID).catch(() => null);
  return client.guilds.cache.first() || null;
}

async function notificarSuspeitaHWID(nick, hwidTentativa, hwidRegistrado) {
  if (!ID_CANAL_LOGS || !client.isReady()) return;
  try {
    const canal = client.channels.cache.get(ID_CANAL_LOGS);
    if (!canal) return;
    const embedHWID = new EmbedBuilder()
      .setTitle('🚨 Alerta de Segurança — HWID Incompatível')
      .setDescription(`Tentativa de uso em outro aparelho detectada!\n\n**Nick:** \`${nick}\`\n**HWID Registrado:** \`${hwidRegistrado}\`\n**HWID Tentativa:** \`${hwidTentativa}\``)
      .setColor(0xff0000).setTimestamp();
    await canal.send({ embeds: [embedHWID] });
    incident('hwid_mismatch', 'high', { nick });
  } catch (e) { console.error('[HWID]', e); }
}

// ============================================================
// API ROBLOX
// ============================================================
app.get('/', (req, res) => res.send('RD4X Bot está online e ativo!'));

app.get('/api/v2/whitelist', async (req, res) => {
  const nickRoblox = req.query.nick || req.query.userid;
  const hwidCliente = req.query.hwid || req.headers['x-hwid'] || 'HWID_NAO_ENVIADO';
  if (!nickRoblox) return res.json({ success: false, whitelisted: false, message: 'Nick ausente' });

  if (nickRoblox === ID_DONO) return res.json({ success: true, whitelisted: true, role: 'Dono' });

  if (usuariosLiberados.has(nickRoblox)) {
    const dados = usuariosLiberados.get(nickRoblox);
    const expiraEm = typeof dados === 'object' ? dados.expiraEm : dados;

    if (expiraEm !== 'perm' && Date.now() > expiraEm) {
      usuariosLiberados.delete(nickRoblox);
      syncDB();
      return res.json({ success: false, whitelisted: false, message: 'Expirado' });
    }

    if (dados.hwid && dados.hwid !== 'LIVRE') {
      if (dados.hwid !== hwidCliente) {
        await notificarSuspeitaHWID(nickRoblox, hwidCliente, dados.hwid);
        return res.json({ success: false, whitelisted: false, message: 'HWID incompativel. Uso em outro aparelho detectado!' });
      }
    } else {
      dados.hwid = hwidCliente;
      usuariosLiberados.set(nickRoblox, dados);
      audit('ROBLOX_API', 'hwid_bound', nickRoblox);
      syncDB();
    }
    return res.json({ success: true, whitelisted: true });
  }
  return res.json({ success: false, whitelisted: false });
});

app.post('/api/v2/execucoes', async (req, res) => {
  const { nick, jogo } = req.body || {};
  totalExecucoesGlobais++;
  syncDB();
  if (ID_CANAL_LOGS && client.isReady()) {
    const canal = client.channels.cache.get(ID_CANAL_LOGS);
    if (canal) {
      const embedExec = new EmbedBuilder()
        .setTitle('🎮 RD4X Hub — Executado no Roblox')
        .setDescription(`**Jogador:** \`${nick || 'Desconhecido'}\`\n**Jogo:** \`${jogo || 'Blox Fruits / Geral'}\`\n**Status:** ✅ Acesso Validado`)
        .setColor(0x00ff88).setTimestamp();
      await canal.send({ embeds: [embedExec] }).catch(() => {});
    }
  }
  res.json({ success: true, logged: true });
});

function dashboardAuth(req, res, next) {
  if (!DASHBOARD_API_KEY) return res.status(503).json({ error: 'DASHBOARD_API_KEY não configurada' });
  if (req.headers.authorization !== `Bearer ${DASHBOARD_API_KEY}`) return res.status(401).json({ error: 'Não autorizado' });
  next();
}

// API para o dashboard. Em produção, o OAuth Discord deve proteger a sessão antes de chegar aqui.
app.get('/api/dashboard/overview', dashboardAuth, (req, res) => {
  const ativos = [...usuariosLiberados.entries()].filter(([_, d]) => d.expiraEm === 'perm' || d.expiraEm > Date.now()).length;
  const abertos = [...ticketsAtivos.values()].filter(t => t.status !== 'closed').length;
  const faturamento = historicoVendas.reduce((a, v) => a + Number(v.valor || 0), 0);
  res.json({ success: true, data: { ativos, ticketsAbertos: abertos, execucoes: totalExecucoesGlobais, vendas: historicoVendas.length, faturamento, incidentesAbertos: db.incidentes.filter(i => i.status === 'open').length } });
});

app.get('/api/dashboard/users', dashboardAuth, (req, res) => {
  const data = [...usuariosLiberados.entries()].map(([nick, d]) => ({ nick, ...d }));
  res.json({ success: true, data });
});

app.get('/api/dashboard/admins', dashboardAuth, async (req, res) => {
  try {
    const guild = await getGuild();

    if (!guild) {
      return res.status(404).json({
        success: false,
        error: 'Servidor Discord não encontrado'
      });
    }

    const membros = await guild.members.fetch();

    const admins = membros
      .filter(member =>
        member.user &&
        member.roles.cache.has(ID_CARGO_ADMIN)
      )
      .map(member => ({
        id: member.id,
        discordId: member.id,
        name: member.user.username,
        tag: member.user.tag,
        avatar: member.user.displayAvatarURL({ size: 128 }),
        role: 'Administrador',
        isOwner: false,
        status: member.presence?.status || 'offline'
      }));

    return res.json({
      success: true,
      data: admins
    });

  } catch (error) {
    console.error('[DASHBOARD ADMINS]', error);

    return res.status(500).json({
      success: false,
      error: 'Erro ao buscar administradores'
    });
  }
});

app.get('/api/dashboard/tickets', dashboardAuth, (req, res) => {
  res.json({
    success: true,
    data: [...ticketsAtivos.entries()].map(([channelId, t]) => ({
      channelId,
      ...t
    }))
  });
});

app.get('/api/dashboard/audit', dashboardAuth, (req, res) => {
  res.json({ success: true, data: db.auditoria.slice(-500).reverse() });
});

app.post('/api/dashboard/release', dashboardAuth, async (req, res) => {
  const { actorId, actorTag, tempo, nick, discordId, valor = 0 } = req.body || {};
  if (!actorId || (!isOwner(actorId) && actorId !== 'verified-admin')) return res.status(403).json({ error: 'Administrador não verificado' });
  const parsed = String(tempo || '').toLowerCase();
  let expiraEm;
  if (parsed === 'perm' || parsed === 'permanente') expiraEm = 'perm';
  else {
    const match = parsed.match(/^(\d+)(d|m|h)$/);
    if (!match) return res.status(400).json({ error: 'Tempo inválido. Use 3d, 12d, 1m, 2m ou perm.' });
    const qtd = Number(match[1]);
    const dias = match[2] === 'm' ? qtd * 30 : match[2] === 'h' ? qtd / 24 : qtd;
    expiraEm = Date.now() + dias * 86400000;
  }
  usuariosLiberados.set(nick, { expiraEm, discordId: discordId || null, avisadoExpiracao: false, hwid: 'LIVRE', valorPago: Number(valor) || 0, dataVenda: new Date().toISOString() });
  if (Number(valor) > 0) historicoVendas.push({ nick, valor: Number(valor), data: new Date().toISOString() });
  db.releaseWindow.push(Date.now());
  db.releaseWindow = db.releaseWindow.filter(t => Date.now() - t < 15 * 60 * 1000);
  audit(actorTag || actorId, 'release', nick, { tempo: parsed, valor });
  if (db.releaseWindow.length > 50) incident('mass_release_threshold', 'critical', { count: db.releaseWindow.length });
  syncDB();

  if (discordId && ID_CARGO_CLIENTE) {
    const guild = await getGuild();
    const member = guild ? await guild.members.fetch(discordId).catch(() => null) : null;
    if (member) await member.roles.add(ID_CARGO_CLIENTE).catch(() => {});
  }
  res.json({ success: true, nick, expiraEm });
});

app.post('/api/dashboard/reset-hwid', dashboardAuth, (req, res) => {
  const { actorId, actorTag, nick } = req.body || {};
  if (!actorId) return res.status(400).json({ error: 'actorId ausente' });
  if (usuariosLiberados.has(nick)) {
    const dados = usuariosLiberados.get(nick);
    dados.hwid = 'LIVRE';
    dados.hwidResetAt = new Date().toISOString();
    usuariosLiberados.set(nick, dados);
    audit(actorTag || actorId, 'reset_hwid', nick);
    syncDB();
    return res.json({ success: true });
  }
  res.status(404).json({ error: 'Cliente não encontrado' });
});

app.post('/api/dashboard/revoke', dashboardAuth, async (req, res) => {
  const { actorId, actorTag, nick } = req.body || {};
  const dados = usuariosLiberados.get(nick);
  if (!dados) return res.status(404).json({ error: 'Cliente não encontrado' });
  const guild = await getGuild();
  if (guild && dados.discordId && ID_CARGO_CLIENTE) {
    const member = await guild.members.fetch(dados.discordId).catch(() => null);
    if (member) await member.roles.remove(ID_CARGO_CLIENTE).catch(() => {});
  }
  usuariosLiberados.delete(nick);
  audit(actorTag || actorId, 'revoke_panel', nick);
  syncDB();
  res.json({ success: true });
});

app.post('/api/dashboard/blacklist', dashboardAuth, (req, res) => {
  const { actorId, actorTag, value } = req.body || {};
  if (!value) return res.status(400).json({ error: 'value ausente' });
  blacklist.add(String(value));
  audit(actorTag || actorId, 'blacklist', String(value));
  syncDB();
  res.json({ success: true });
});

app.post('/api/dashboard/unblacklist', dashboardAuth, (req, res) => {
  const { actorId, actorTag, value } = req.body || {};
  blacklist.delete(String(value));
  audit(actorTag || actorId, 'unblacklist', String(value));
  syncDB();
  res.json({ success: true });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`[WEB] RD4X API rodando na porta ${port}`);
});

// ============================================================
// DISCORD
// ============================================================
const client = new Client({ intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages, GatewayIntentBits.MessageContent, GatewayIntentBits.GuildMembers] });
client.once('ready', () => {
  console.log(`[SUCESSO] Bot online como ${client.user.tag}!`);
  let i = 0;
  setInterval(() => {
    const lista = [
      { name: 'RD4X Hub | Tickets 🎫', type: 0 },
      { name: `${usuariosLiberados.size} Clientes VIP 💎`, type: 3 },
      { name: `${totalExecucoesGlobais} Execuções 🎮`, type: 0 },
      { name: '!ajuda | Suporte 🎫', type: 2 }
    ];
    client.user.setActivity(lista[i].name, { type: lista[i].type });
    i = (i + 1) % lista.length;
  }, 15000);

  setInterval(async () => {
    const agora = Date.now();
    for (const [nick, dados] of usuariosLiberados.entries()) {
      if (dados.expiraEm && dados.expiraEm !== 'perm') {
        const restante = dados.expiraEm - agora;
        if (restante > 0 && restante <= 172800000 && !dados.avisadoExpiracao) {
          dados.avisadoExpiracao = true;
          if (dados.discordId) {
            const user = await client.users.fetch(dados.discordId).catch(() => null);
            if (user) await user.send(`⚠️ **Aviso de Expiração — RD4X Hub**\n\nSeu painel para **${nick}** expira em menos de 48 horas. Abra um ticket para renovar.`).catch(() => {});
          }
        }
        if (restante <= 0) {
          const guild = await getGuild();
          if (guild && dados.discordId && ID_CARGO_CLIENTE) {
            const member = await guild.members.fetch(dados.discordId).catch(() => null);
            if (member) await member.roles.remove(ID_CARGO_CLIENTE).catch(() => {});
          }
          usuariosLiberados.delete(nick);
          audit('SYSTEM', 'expiration', nick);
        }
      }
    }
    syncDB();
  }, 60000);

  setInterval(async () => {
    const agora = Date.now();
    for (const [idCanal, dados] of ticketsAtivos.entries()) {
      if (dados.ultimoContato && agora - dados.ultimoContato >= 86400000 && !dados.avisoInatividade) {
        dados.avisoInatividade = true;
        const canal = client.channels.cache.get(idCanal);
        if (canal) await canal.send('⏱️ **Aviso de Inatividade:** este ticket está sem respostas há 24 horas e poderá ser encerrado em breve.').catch(() => {});
      }
    }
    syncDB();
  }, 300000);
});

async function registrarLogTicket(guild, idTicket, tituloGeral, usuario, novoEvento, cor = 0xff0033) {
  const dados = ticketsAtivos.get(idTicket) || { logs: [], messageId: null, ultimoContato: Date.now(), status: 'open' };
  dados.logs.push(`• [<t:${Math.floor(Date.now() / 1000)}:R>] ${novoEvento}`);
  dados.ultimoContato = Date.now();
  ticketsAtivos.set(idTicket, dados);
  syncDB();
  if (!ID_CANAL_LOGS) return;
  const canalLogs = guild.channels.cache.get(ID_CANAL_LOGS);
  if (!canalLogs) return;
  const embed = new EmbedBuilder().setTitle(`🎫 Atendimento — ${tituloGeral}`).setColor(cor).setDescription(`**Usuário:** ${usuario}\n\n**Histórico:**\n${dados.logs.slice(-20).join('\n')}`).setFooter({ text: 'RD4X Hub • Logs de Atendimento' }).setTimestamp();
  try {
    if (dados.messageId) {
      const msg = await canalLogs.messages.fetch(dados.messageId);
      await msg.edit({ embeds: [embed] });
    } else {
      const msg = await canalLogs.send({ embeds: [embed] });
      dados.messageId = msg.id;
      ticketsAtivos.set(idTicket, dados);
      syncDB();
    }
  } catch {}
}

function ticketData(channelId, userId) {
  return ticketsAtivos.get(channelId) || { userId, status: 'open', prioridade: 'normal', tags: [], notas: [], logs: [], ultimoContato: Date.now(), avisoInatividade: false };
}

client.on('messageCreate', async (message) => {
  if (message.author.bot) return;

  if (message.channel.name?.startsWith('ticket-')) {
    const dados = ticketData(message.channel.id, message.author.id);
    dados.ultimoContato = Date.now();
    dados.avisoInatividade = false;
    if (message.attachments.size > 0) {
      dados.pagamento = 'comprovante_recebido';
      await message.reply('Aguarde um momento, você já vai ser respondido! ⌛').catch(() => {});
      await registrarLogTicket(message.guild, message.channel.id, message.channel.name, `<@${message.author.id}>`, '📷 Comprovante/anexo recebido.', 0xffaa00);
    }
    ticketsAtivos.set(message.channel.id, dados);
    syncDB();
  }

  const args = message.content.trim().split(/\s+/);
  const comando = (args[0] || '').toLowerCase();
  const admin = isAdmin(message.member, message.author.id);

  if (comando === '!admin_help' || comando === '!adminhelp') {
    if (!admin) return message.reply('❌ Apenas administradores do RD4X podem usar este comando!');
    const embed = new EmbedBuilder().setTitle('🛡️ RD4X — Comandos de Atendimento').setColor(0xff0033).addFields(
      { name: '🎫 Tickets', value: '`!painel` • `!fechar` • `!suporte` • `!assumir`' },
      { name: '🔑 Clientes', value: '`!liberar` • `!retirarpainel` • `!status` • `!tempo`' },
      { name: '🔄 HWID', value: '`!resetarhwid`' },
      { name: '🚫 Bloqueios', value: '`!blacklist` • `!unblacklist`' },
      { name: '📋 Atendimento', value: '`!prioridade` • `!tag` • `!nota` • `!resumo`' },
      { name: '📈 Dono', value: '`!financeiro` • `!emergencia`' }
    ).setTimestamp();
    return message.reply({ embeds: [embed] });
  }

  if (comando === '!financeiro' || comando === '!vendas') {
    if (!isOwner(message.author.id)) return message.reply('❌ Este comando é exclusivo do Dono.');
    const total = historicoVendas.reduce((a, v) => a + Number(v.valor || 0), 0);
    return message.reply({ embeds: [new EmbedBuilder().setTitle('📈 RD4X — Financeiro').setColor(0xff0033).addFields(
      { name: '💎 Clientes ativos', value: String(usuariosLiberados.size), inline: true },
      { name: '🎮 Execuções', value: String(totalExecucoesGlobais), inline: true },
      { name: '💰 Faturamento', value: `R$ ${total.toFixed(2)}`, inline: true },
      { name: '📦 Vendas', value: String(historicoVendas.length), inline: true }
    ).setTimestamp()] });
  }

  if (comando === '!resetarhwid') {
    if (!admin) return message.reply('❌ Sem permissão!');
    const nick = args[1];
    if (!nick) return message.reply('⚠️ Use `!resetarhwid [nick]`');
    const dados = usuariosLiberados.get(nick);
    if (!dados) return message.reply(`❌ **${nick}** não possui cadastro ativo.`);
    dados.hwid = 'LIVRE';
    dados.hwidResetAt = new Date().toISOString();
    usuariosLiberados.set(nick, dados);
    audit(message.author.tag, 'reset_hwid', nick);
    syncDB();
    return message.reply(`🔄 HWID de **${nick}** resetado. O próximo aparelho válido será vinculado.`);
  }

  if (comando === '!blacklist') {
    if (!admin) return message.reply('❌ Sem permissão!');
    const valor = args[1];
    if (!valor) return message.reply('⚠️ Use `!blacklist [nick/id]`');
    blacklist.add(valor);
    audit(message.author.tag, 'blacklist', valor);
    syncDB();
    return message.reply(`🚫 **${valor}** foi adicionado à blacklist.`);
  }

  if (comando === '!unblacklist') {
    if (!admin) return message.reply('❌ Sem permissão!');
    const valor = args[1];
    if (!valor) return message.reply('⚠️ Use `!unblacklist [nick/id]`');
    blacklist.delete(valor);
    audit(message.author.tag, 'unblacklist', valor);
    syncDB();
    return message.reply(`✅ **${valor}** foi removido da blacklist.`);
  }

  if (comando === '!liberar') {
    if (!admin) return message.reply('❌ Sem permissão!');
    const tempo = (args[1] || '').toLowerCase();
    const nick = args[2];
    const mencao = message.mentions.members.first();
    const valor = parseFloat(args[4] || args[3]) || 0;
    if (!tempo || !nick) return message.reply('⚠️ Use `!liberar [tempo] [nick] [@membro] [valor]`');
    let expiraEm;
    if (tempo === 'perm' || tempo === 'permanente') expiraEm = 'perm';
    else {
      const match = tempo.match(/^(\d+)(d|m|h)?$/);
      if (!match) return message.reply('⚠️ Tempo inválido. Exemplos: `3d`, `12d`, `1m`, `2m`, `perm`.');
      const qtd = Number(match[1]);
      const dias = match[2] === 'm' ? qtd * 30 : match[2] === 'h' ? qtd / 24 : qtd;
      expiraEm = Date.now() + dias * 86400000;
    }
    usuariosLiberados.set(nick, { expiraEm, discordId: mencao?.id || null, avisadoExpiracao: false, hwid: 'LIVRE', valorPago: valor, dataVenda: new Date().toISOString() });
    if (valor > 0) historicoVendas.push({ nick, valor, data: new Date().toISOString() });
    if (mencao && ID_CARGO_CLIENTE) await mencao.roles.add(ID_CARGO_CLIENTE).catch(() => {});
    audit(message.author.tag, 'release', nick, { tempo, valor });
    db.releaseWindow.push(Date.now());
    db.releaseWindow = db.releaseWindow.filter(t => Date.now() - t < 900000);
    if (db.releaseWindow.length > 50) incident('mass_release_threshold', 'critical', { count: db.releaseWindow.length });
    syncDB();
    return message.reply(`✅ Acesso liberado para **${nick}** por **${tempo}**${mencao ? ` • VIP concedido a <@${mencao.id}>.` : ''}`);
  }

  if (comando === '!retirarpainel') {
    if (!admin) return message.reply('❌ Sem permissão!');
    const nick = args[1];
    if (!nick) return message.reply('⚠️ Use `!retirarpainel [nick]`');
    const dados = usuariosLiberados.get(nick);
    const guild = message.guild;
    if (dados?.discordId && ID_CARGO_CLIENTE) {
      const member = await guild.members.fetch(dados.discordId).catch(() => null);
      if (member) await member.roles.remove(ID_CARGO_CLIENTE).catch(() => {});
    }
    usuariosLiberados.delete(nick);
    audit(message.author.tag, 'revoke_panel', nick);
    syncDB();
    return message.reply(`🔒 Painel de **${nick}** revogado.`);
  }

  if (comando === '!status') {
    const nick = args[1];
    if (!nick) return message.reply('⚠️ Use `!status [nick]`');
    return message.reply(usuariosLiberados.has(nick) || nick === ID_DONO ? `🟢 **${nick}** possui painel ativo.` : `🔴 **${nick}** não possui registro ativo.`);
  }

  if (comando === '!tempo') {
    const nick = args[1];
    if (!nick) return message.reply('⚠️ Use `!tempo [nick]`');
    const dados = usuariosLiberados.get(nick);
    if (!dados) return message.reply(`❌ **${nick}** não está cadastrado.`);
    if (dados.expiraEm === 'perm') return message.reply(`♾️ **${nick}** possui painel permanente.`);
    const restante = dados.expiraEm - Date.now();
    if (restante <= 0) return message.reply(`⏱️ O painel de **${nick}** já expirou.`);
    return message.reply(`⏳ Restam aproximadamente **${Math.ceil(restante / 86400000)} dia(s)** para **${nick}**.`);
  }

  if (comando === '!suporte') return message.reply({ content: `🆘 **Ajuda solicitada!**\n\nAguarde os administradores. <@&${ID_CARGO_ADMIN}>`, allowedMentions: { roles: [ID_CARGO_ADMIN] } });

  if (comando === '!assumir') {
    if (!admin) return message.reply('❌ Sem permissão!');
    if (!message.channel.name.startsWith('ticket-')) return message.reply('❌ Use dentro de um ticket.');
    const dados = ticketData(message.channel.id, message.channel.id);
    dados.assumidoPor = { id: message.author.id, tag: message.author.tag, at: new Date().toISOString() };
    dados.status = 'em_atendimento';
    ticketsAtivos.set(message.channel.id, dados);
    audit(message.author.tag, 'ticket_takeover', message.channel.name);
    syncDB();
    return message.reply(`🧑‍💻 Ticket assumido por **${message.author.tag}**.`);
  }

  if (comando === '!prioridade') {
    if (!admin) return message.reply('❌ Sem permissão!');
    if (!message.channel.name.startsWith('ticket-')) return message.reply('❌ Use dentro de um ticket.');
    const p = (args[1] || '').toLowerCase();
    if (!['baixa','normal','alta','urgente'].includes(p)) return message.reply('⚠️ Use: `baixa`, `normal`, `alta` ou `urgente`.');
    const dados = ticketData(message.channel.id);
    dados.prioridade = p; ticketsAtivos.set(message.channel.id, dados); audit(message.author.tag, 'ticket_priority', message.channel.name, { prioridade: p }); syncDB();
    return message.reply(`🚦 Prioridade definida como **${p}**.`);
  }

  if (comando === '!tag') {
    if (!admin) return message.reply('❌ Sem permissão!');
    if (!message.channel.name.startsWith('ticket-')) return message.reply('❌ Use dentro de um ticket.');
    const tag = args.slice(1).join(' ');
    if (!tag) return message.reply('⚠️ Use `!tag pagamento`, por exemplo.');
    const dados = ticketData(message.channel.id); dados.tags ||= []; if (!dados.tags.includes(tag)) dados.tags.push(tag); ticketsAtivos.set(message.channel.id, dados); syncDB();
    return message.reply(`🏷️ Tag **${tag}** adicionada.`);
  }

  if (comando === '!nota') {
    if (!admin) return message.reply('❌ Sem permissão!');
    if (!message.channel.name.startsWith('ticket-')) return message.reply('❌ Use dentro de um ticket.');
    const nota = args.slice(1).join(' ');
    if (!nota) return message.reply('⚠️ Escreva a nota.');
    const dados = ticketData(message.channel.id); dados.notas ||= []; dados.notas.push({ by: message.author.tag, text: nota, at: new Date().toISOString() }); ticketsAtivos.set(message.channel.id, dados); audit(message.author.tag, 'ticket_note', message.channel.name); syncDB();
    return message.reply('📝 Nota interna registrada.');
  }

  if (comando === '!resumo') {
    if (!admin) return message.reply('❌ Sem permissão!');
    if (!message.channel.name.startsWith('ticket-')) return message.reply('❌ Use dentro de um ticket.');
    const dados = ticketData(message.channel.id);
    return message.reply({ embeds: [new EmbedBuilder().setTitle(`🎫 Resumo — ${message.channel.name}`).setColor(0xff0033).addFields(
      { name: 'Status', value: dados.status || 'open', inline: true },
      { name: 'Prioridade', value: dados.prioridade || 'normal', inline: true },
      { name: 'Pagamento', value: dados.pagamento || 'não informado', inline: true },
      { name: 'Responsável', value: dados.assumidoPor?.tag || 'não assumido', inline: true },
      { name: 'Tags', value: dados.tags?.join(', ') || 'nenhuma', inline: true },
      { name: 'Notas', value: dados.notas?.length ? `${dados.notas.length} nota(s)` : 'nenhuma', inline: true }
    ).setTimestamp()] });
  }

  if (comando === '!painel') {
    const row = new ActionRowBuilder().addComponents(new ButtonBuilder().setCustomId('criar_ticket').setLabel('Criar Ticket').setStyle(ButtonStyle.Danger).setEmoji('🎫'));
    await message.delete().catch(() => {});
    return message.channel.send({ content: '🎫 **RD4X Hub — Atendimento**\n\nClique abaixo para abrir um ticket e adquirir/renovar seu Painel.', components: [row] });
  }

  if (comando === '!ajuda' || comando === '!help') {
    return message.reply({ embeds: [new EmbedBuilder().setTitle('🤖 Central de Ajuda — RD4X Hub').setColor(0xff0033).setDescription('Comandos para clientes e atendimento.').addFields(
      { name: '🎫 Atendimento', value: '`!suporte` — chama a equipe.' },
      { name: '⏳ Seu painel', value: '`!tempo [nick]` — tempo restante.\n`!status [nick]` — situação do painel.' },
      { name: '🛡️ Staff', value: 'Administradores: use `!admin_help` para ver os comandos.' }
    ).setTimestamp()] });
  }

  if (comando === '!fechar') {
    if (!message.channel.name.startsWith('ticket-')) return message.reply('❌ Este comando só pode ser usado dentro de um ticket!');
    if (!admin) return message.reply('❌ Apenas a equipe pode fechar tickets.');
    await message.reply('🔒 Gerando transcript e encerrando o ticket...');
    let transcriptPath = null;
    try {
      const mensagens = await message.channel.messages.fetch({ limit: 100 });
      const texto = mensagens.reverse().map(m => `[${m.createdAt.toLocaleString('pt-BR')}] ${m.author.tag}: ${m.content}`).join('\n');
      transcriptPath = path.join(TRANSCRIPT_DIR, `transcript-${message.channel.id}-${Date.now()}.txt`);
      fs.writeFileSync(transcriptPath, texto, 'utf8');
      const attachment = new AttachmentBuilder(Buffer.from(texto, 'utf8'), { name: path.basename(transcriptPath) });
      const canalLogs = message.guild.channels.cache.get(ID_CANAL_LOGS);
      if (canalLogs) await canalLogs.send({ content: `📑 **Transcript:** ${message.channel.name} fechado por **${message.author.tag}**.`, files: [attachment] }).catch(() => {});
    } catch (e) { console.error('[TRANSCRIPT]', e); }
    const dados = ticketData(message.channel.id); dados.status = 'closed'; dados.closedBy = message.author.tag; dados.closedAt = new Date().toISOString(); ticketsAtivos.set(message.channel.id, dados);
    audit(message.author.tag, 'ticket_close', message.channel.name, { transcriptPath });
    await registrarLogTicket(message.guild, message.channel.id, message.channel.name, `<@${message.author.id}>`, '🔒 Ticket encerrado e transcript salvo.', 0xff0033);
    syncDB();
    setTimeout(async () => { ticketsAtivos.delete(message.channel.id); syncDB(); await message.channel.delete().catch(() => {}); }, 3000);
    return;
  }
});

client.on('interactionCreate', async (interaction) => {
  if (!interaction.isButton()) return;
  if (interaction.customId !== 'criar_ticket') return;

  const guild = interaction.guild;
  const member = interaction.member;
  const agora = new Date();
  const horas = (agora.getUTCHours() - 3 + 24) % 24;
  if (horas < 6 || horas >= 22) return interaction.reply({ content: '🌙 **Atendimento encerrado.** Funcionamento: **06:00 às 22:00**.', ephemeral: true });

  const ultimo = Number(cooldownTickets.get(member.id) || 0);
  const restante = 60000 - (Date.now() - ultimo); // 1 minuto, conforme configuração atual
  if (ultimo && restante > 0) return interaction.reply({ content: `⏳ Aguarde **${Math.ceil(restante / 1000)} segundos** para abrir outro ticket.`, ephemeral: true });

  if (blacklist.has(member.user.username) || blacklist.has(member.id)) return interaction.reply({ content: '❌ Você está bloqueado de abrir tickets.', ephemeral: true });

  const nomeCanal = `ticket-${member.user.username}`.toLowerCase();
  const existente = guild.channels.cache.find(c => c.name === nomeCanal);
  if (existente) return interaction.reply({ content: `❌ Você já possui um ticket aberto: ${existente}`, ephemeral: true });

  cooldownTickets.set(member.id, Date.now());
  const parentCategory = interaction.channel.parentId;
  const channel = await guild.channels.create({
    name: nomeCanal,
    type: ChannelType.GuildText,
    parent: parentCategory,
    permissionOverwrites: [
      { id: guild.id, deny: [PermissionFlagsBits.ViewChannel] },
      { id: member.id, allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory] },
      { id: ID_DONO, allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory] },
      { id: ID_CARGO_ADMIN, allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory] }
    ]
  });

  ticketsAtivos.set(channel.id, { userId: member.id, username: member.user.username, status: 'aberto', prioridade: 'normal', pagamento: 'aguardando_comprovante', tags: ['venda'], notas: [], logs: [], ultimoContato: Date.now(), avisoInatividade: false });
  syncDB();

  await channel.send({ content: `<@${member.user.id}>\n\n💳 **Para adquirir seu Painel Admin**\n\nEnvie o PIX para:\n\`${CHAVE_PIX}\`\n\nDepois envie seu **nick do Roblox**, **plano/duração** e o **comprovante de pagamento**.`, allowedMentions: { users: [member.user.id] } });
  await channel.send({ content: `Aguarde a análise do comprovante. <@&${ID_CARGO_ADMIN}>`, allowedMentions: { roles: [ID_CARGO_ADMIN] } });
  await registrarLogTicket(guild, channel.id, nomeCanal, `<@${member.id}>`, '🟢 Ticket criado pelo cliente.', 0xff0033);
  audit(member.user.tag, 'ticket_create', channel.id);
  return interaction.reply({ content: `✅ Ticket criado: ${channel}`, ephemeral: true });
});

// Encerramento seguro: salva tudo antes de o processo morrer.
for (const sig of ['SIGINT', 'SIGTERM']) {
  process.on(sig, () => {
    try { syncDB(); saveDB(true); } finally { process.exit(0); }
  });
}

client.login(process.env.DISCORD_TOKEN);
