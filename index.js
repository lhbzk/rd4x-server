const {
  Client,
  GatewayIntentBits,
  ActionRowBuilder,
  ButtonBuilder,
  ButtonStyle,
  ChannelType,
  PermissionFlagsBits,
  EmbedBuilder,
  AttachmentBuilder,
  REST,
  Routes,
  SlashCommandBuilder
} = require('discord.js');

const express = require('express');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// ============================================================
// RD4X HUB — BOT + TICKETS + WHITELIST/HWID + DASHBOARD API
// V10
// ============================================================

const app = express();

const port =
process.env.SERVER_PORT ||
process.env.PORT ||
3000;

app.use(
express.json({
limit: '1mb'
})
);

// ============================================================
// ARQUIVOS / BANCO
// ============================================================

const DATA_DIR =
path.join(__dirname, 'data');

const TRANSCRIPT_DIR =
path.join(
DATA_DIR,
'transcripts'
);

fs.mkdirSync(
DATA_DIR,
{
recursive: true
}
);

fs.mkdirSync(
TRANSCRIPT_DIR,
{
recursive: true
}
);

const DB_FILE =
path.join(
DATA_DIR,
'rd4x-data.json'
);

// ============================================================
// CONFIGURAÇÕES
// ============================================================

const ID_DONO =
process.env.ID_DONO ||
'1549272865260441631';

const ID_CARGO_ADMIN =
process.env.ID_CARGO_ADMIN ||
'1549273436705259570';

const ID_CARGO_CLIENTE =
process.env.ID_CARGO_CLIENTE ||
'1549273666951577691';

const CHAVE_PIX =
process.env.CHAVE_PIX ||
'85777075550';

const ID_CANAL_LOGS =
process.env.ID_CANAL_LOGS ||
'1549274555175018587';

const ID_CANAL_AVALIACOES =
process.env.ID_CANAL_AVALIACOES ||
'1549458044331757660';

const ID_CANAL_GERAR =
process.env.ID_CANAL_GERAR ||
'1566184054670360617';

const GUILD_ID =
process.env.GUILD_ID ||
'';

const DASHBOARD_API_KEY =
process.env.DASHBOARD_API_KEY ||
'';
const DISCORD_CLIENT_ID =
  process.env.DISCORD_CLIENT_ID ||
  '';

const DISCORD_CLIENT_SECRET =
  process.env.DISCORD_CLIENT_SECRET ||
  '';

const DISCORD_OAUTH_REDIRECT_URI =
  process.env.DISCORD_OAUTH_REDIRECT_URI ||
  '';

const ID_CANAL_SENHA_DASHBOARD =
  process.env.ID_CANAL_SENHA_DASHBOARD ||
  '1566184054670360617';

const DASHBOARD_CODE_TTL =
  5 * 60 * 1000;

// ============================================================
// BANCO PADRÃO
// ============================================================

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

releaseWindow: [],

dashboardCodes: {},

productKeys: {}
};

// ============================================================
// BANCO
// ============================================================

function loadDB() {
try {
if (!fs.existsSync(DB_FILE)) {
return structuredClone(
DEFAULT_DB
);
}

const parsed =
  JSON.parse(
    fs.readFileSync(
      DB_FILE,
      'utf8'
    )
  );

return {
  ...structuredClone(
    DEFAULT_DB
  ),
  ...parsed
};

} catch (err) {
console.error(
'[DB] Falha ao ler banco local:',
err
);

return structuredClone(
  DEFAULT_DB
);

}
}

let db =
loadDB();

let saveTimer =
null;

function saveDB(
immediate = false
) {
if (saveTimer) {
clearTimeout(
saveTimer
);
}

const write = () => {
const tmp =
  `${DB_FILE}.tmp`; 

fs.writeFileSync(
  tmp,
  JSON.stringify(
    db,
    null,
    2
  ),
  'utf8'
);

fs.renameSync(
  tmp,
  DB_FILE
);

};

if (immediate) {
write();
return;
}

saveTimer =
setTimeout(
() => {
try {
write();
} catch (e) {
console.error(
'[DB] Erro ao salvar:',
e
);
}
},
250
);
}
/*
 * ==============================================
 * LIMPEZA AUTOMÁTICA DE PRODUCT KEYS
 *
 * - Key não resgatada:
 *   expira em 5 minutos.
 *
 * - Key resgatada:
 *   sessão dura exatamente 2 horas.
 *
 * - Não existe histórico de Keys.
 *   Quando expira, a entrada é removida.
 * ==============================================
 */

setInterval(
  () => {
    try {

      if (
        !db.productKeys ||
        typeof db.productKeys !== 'object'
      ) {
        return;
      }

      const agora =
        Date.now();

      let alterou =
        false;

      for (
        const [
          hash,
          dados
        ] of Object.entries(
          db.productKeys
        )
      ) {

        if (
          !dados ||
          typeof dados !== 'object'
        ) {
          delete db.productKeys[hash];

          alterou = true;

          continue;
        }

        /*
         * ========================================
         * KEY NÃO RESGATADA
         *
         * Expira 5 minutos depois da criação.
         * ========================================
         */

        const expirouSemResgate =
          !dados.redeemedAt &&
          dados.expiresAt &&
          dados.expiresAt !== 'perm' &&
          Number(dados.expiresAt) < agora;

        /*
         * ========================================
         * SESSÃO RESGATADA
         *
         * Expira 2 horas depois do primeiro resgate.
         * ========================================
         */

        const expirouSessao =
          dados.redeemedAt &&
          dados.sessionExpiresAt &&
          Number(dados.sessionExpiresAt) < agora;

        /*
         * ========================================
         * REMOVE A KEY
         * ========================================
         */

        if (
          expirouSemResgate ||
          expirouSessao
        ) {
          delete db.productKeys[hash];

          alterou = true;
        }
      }

      /*
       * Só salva o banco se alguma coisa mudou.
       */

      if (alterou) {
        saveDB();
      }

    } catch (error) {

      console.error(
        '[KEY CLEANUP]',
        error
      );
    }

  },
  60 * 1000
);
// ============================================================
// MAPAS / ESTRUTURAS
// ============================================================

const usuariosLiberados =
new Map(
Object.entries(
db.usuariosLiberados || {}
)
);

const historicoVendas =
db.historicoVendas || [];

const blacklist =
new Set(
db.blacklist || []
);

const ticketsAtivos =
new Map(
Object.entries(
db.tickets || {}
)
);

const cooldownTickets =
new Map(
Object.entries(
db.cooldownTickets || {}
)
);

let totalExecucoesGlobais =
db.totalExecucoesGlobais || 0;

// ============================================================
// SINCRONIZAÇÃO
// ============================================================

function syncDB() {
db.usuariosLiberados =
Object.fromEntries(
usuariosLiberados
);

db.tickets =
Object.fromEntries(
ticketsAtivos
);

db.cooldownTickets =
Object.fromEntries(
cooldownTickets
);

db.blacklist =
[...blacklist];

db.totalExecucoesGlobais =
totalExecucoesGlobais;

saveDB();
}

// ============================================================
// AUDITORIA
// ============================================================

function audit(
actor,
action,
target = '',
details = {}
) {
db.auditoria.push({
id:
crypto.randomUUID(),

at:
  new Date().toISOString(),

actor,

action,

target,

details

});

if (
db.auditoria.length >
5000
) {
db.auditoria.splice(
0,
db.auditoria.length - 5000
);
}

saveDB();
}

// ============================================================
// INCIDENTES
// ============================================================

function incident(
type,
severity,
details = {}
) {
db.incidentes.push({
id:
crypto.randomUUID(),

at:
  new Date().toISOString(),

type,

severity,

status:
  'open',

details

});

if (
db.incidentes.length >
1000
) {
db.incidentes.splice(
0,
db.incidentes.length - 1000
);
}

saveDB();
}

// ============================================================
// PERMISSÕES
// ============================================================

function isAdmin(
member,
userId
) {
return (
userId === ID_DONO ||
Boolean(
member?.roles?.cache?.has(
ID_CARGO_ADMIN
)
)
);
}

function isOwner(
userId
) {
return (
userId === ID_DONO
);
}
// ============================================================
// AUTENTICAÇÃO DO DASHBOARD — CÓDIGOS DE USO ÚNICO
// ============================================================

function normalizeDashboardCode(code) {
  return String(code || '')
    .trim()
    .toUpperCase();
}

function hashDashboardCode(code) {
  return crypto
    .createHash('sha256')
    .update(
      normalizeDashboardCode(code)
    )
    .digest('hex');
}
// ============================================================
// KEY DE PRODUTO — GERAÇÃO E HASH
// ============================================================

function generateProductKey() {
  const chars =
    'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  let raw = '';

  for (let i = 0; i < 12; i++) {
    raw += chars[
      crypto.randomInt(0, chars.length)
    ];
  }

  return (
    `RD4X-${raw.slice(0, 4)}-` +
    `${raw.slice(4, 8)}-` +
    `${raw.slice(8, 12)}`
  );
}

function hashProductKey(key) {
  return crypto
    .createHash('sha256')
    .update(
      String(key || '')
        .trim()
        .toUpperCase()
    )
    .digest('hex');
}

function generateDashboardCode() {
  const alphabet =
    'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  const random =
    crypto.randomBytes(12);

  let raw = '';

  for (
    let i = 0;
    i < 12;
    i++
  ) {
    raw +=
      alphabet[
        random[i] %
          alphabet.length
      ];
  }

  return (
    `RD4X-${raw.slice(0, 4)}-` +
    `${raw.slice(4, 8)}-${raw.slice(8, 12)}`
  );
}

function cleanupDashboardCodes() {
  const agora =
    Date.now();

  for (
    const [
      hash,
      data
    ] of Object.entries(
      db.dashboardCodes || {}
    )
  ) {
    if (
      !data ||
      data.expiresAt <= agora ||
      data.used
    ) {
      delete db.dashboardCodes[
        hash
      ];
    }
  }
}

function createDashboardCode(
  discordId
) {
  cleanupDashboardCodes();

  const code =
    generateDashboardCode();

  const hash =
    hashDashboardCode(
      code
    );

  db.dashboardCodes[
    hash
  ] = {
    discordId:
      String(discordId),

    createdAt:
      Date.now(),

    expiresAt:
      Date.now() +
      DASHBOARD_CODE_TTL,

    used:
      false
  };

  saveDB();

  return code;
}

function consumeDashboardCode(
  discordId,
  code
) {
  cleanupDashboardCodes();

  const normalized =
    normalizeDashboardCode(
      code
    );

  const hash =
    hashDashboardCode(
      normalized
    );

  const data =
    db.dashboardCodes[
      hash
    ];

  if (!data) {
    return {
      valid: false,
      error:
        'Senha inválida ou expirada.'
    };
  }

  if (
    data.used
  ) {
    return {
      valid: false,
      error:
        'Essa senha já foi utilizada.'
    };
  }

  if (
    data.expiresAt <=
    Date.now()
  ) {
    delete db.dashboardCodes[
      hash
    ];

    saveDB();

    return {
      valid: false,
      error:
        'Essa senha expirou.'
    };
  }

  if (
    String(
      data.discordId
    ) !==
    String(
      discordId
    )
  ) {
    return {
      valid: false,
      error:
        'Essa senha pertence a outro administrador.'
    };
  }

  data.used =
    true;

  data.usedAt =
    Date.now();

  delete db.dashboardCodes[
    hash
  ];

  saveDB();

  return {
    valid: true
  };
      }

// ============================================================
// DISCORD
// ============================================================

let client;

async function getGuild() {
if (!client) {
return null;
}

if (GUILD_ID) {
return (
client.guilds.cache.get(
GUILD_ID
) ||
await client.guilds
.fetch(GUILD_ID)
.catch(() => null)
);
}

return (
client.guilds.cache.first() ||
null
);
}

// ============================================================
// SEGURANÇA HWID
// ============================================================

async function notificarSuspeitaHWID(
nick,
hwidTentativa,
hwidRegistrado
) {
if (
!ID_CANAL_LOGS ||
!client?.isReady()
) {
return;
}

try {
const canal =
client.channels.cache.get(
ID_CANAL_LOGS
);

if (!canal) {
  return;
}

const embedHWID =
  new EmbedBuilder()
    .setTitle(
      '🚨 Alerta de Segurança — HWID Incompatível'
    )
    .setDescription(
      `Tentativa de uso em outro aparelho detectada!\n\n` +
      `**Nick:** \`${nick}\`\n` +
      `**HWID Registrado:** \`${hwidRegistrado}\`\n` +
      `**HWID Tentativa:** \`${hwidTentativa}\``
    )
    .setColor(0xff0000)
    .setTimestamp();

await canal.send({
  embeds: [
    embedHWID
  ]
});

incident(
  'hwid_mismatch',
  'high',
  {
    nick
  }
);

} catch (e) {
console.error(
'[HWID]',
e
);
}
}

// ============================================================
// API ROBLOX
// ============================================================

app.get(
'/',
(req, res) => {
res.send(
'RD4X Bot está online e ativo!'
);
}
);

app.get(
'/api/v2/whitelist',
async (req, res) => {
const nickRoblox =
req.query.nick ||
req.query.userid;

const hwidCliente =
  req.query.hwid ||
  req.headers['x-hwid'] ||
  'HWID_NAO_ENVIADO';

if (!nickRoblox) {
  return res.json({
    success: false,
    whitelisted: false,
    message: 'Nick ausente'
  });
}

if (
  nickRoblox === ID_DONO
) {
  return res.json({
    success: true,
    whitelisted: true,
    role: 'Dono'
  });
}

if (
  usuariosLiberados.has(
    nickRoblox
  )
) {
  const dados =
    usuariosLiberados.get(
      nickRoblox
    );

  const expiraEm =
    typeof dados === 'object'
      ? dados.expiraEm
      : dados;

  if (
    expiraEm !== 'perm' &&
    Date.now() > expiraEm
  ) {
    usuariosLiberados.delete(
      nickRoblox
    );

    syncDB();

    return res.json({
      success: false,
      whitelisted: false,
      message: 'Expirado'
    });
  }

  if (
    dados.hwid &&
    dados.hwid !== 'LIVRE'
  ) {
    if (
      dados.hwid !==
      hwidCliente
    ) {
      await notificarSuspeitaHWID(
        nickRoblox,
        hwidCliente,
        dados.hwid
      );

      return res.json({
        success: false,
        whitelisted: false,
        message:
          'HWID incompativel. Uso em outro aparelho detectado!'
      });
    }
  } else {
    dados.hwid =
      hwidCliente;

    usuariosLiberados.set(
      nickRoblox,
      dados
    );

    audit(
      'ROBLOX_API',
      'hwid_bound',
      nickRoblox
    );

    syncDB();
  }

  return res.json({
    success: true,
    whitelisted: true
  });
}

return res.json({
  success: false,
  whitelisted: false
});

}
);

// ============================================================
// EXECUÇÕES
// ============================================================

app.post(
'/api/v2/execucoes',
async (req, res) => {
const {
nick,
jogo
} = req.body || {};

totalExecucoesGlobais++;

syncDB();

if (
  ID_CANAL_LOGS &&
  client?.isReady()
) {
  const canal =
    client.channels.cache.get(
      ID_CANAL_LOGS
    );

  if (canal) {
    const embedExec =
      new EmbedBuilder()
        .setTitle(
          '🎮 RD4X Hub — Executado no Roblox'
        )
        .setDescription(
          `**Jogador:** \`${nick || 'Desconhecido'}\`\n` +
          `**Jogo:** \`${jogo || 'Blox Fruits / Geral'}\`\n` +
          `**Status:** ✅ Acesso Validado`
        )
        .setColor(0x00ff88)
        .setTimestamp();

    await canal.send({
      embeds: [
        embedExec
      ]
    }).catch(
      () => {}
    );
  }
}

res.json({
  success: true,
  logged: true
});

}
);

// ============================================================
// KEY DE PRODUTO — VALIDAÇÃO
// ============================================================
//
// Fluxo em 2 fases:
//
// FASE 1 (resgate): Key só pode ser resgatada dentro de
// 5 minutos após ser gerada. Primeira validação OK define
// redeemedAt e sessionExpiresAt (+2h).
//
// FASE 2 (sessão): depois do resgate, expiresAt é ignorado.
// Só vale sessionExpiresAt. Cada nova validação NÃO renova
// o prazo — as 2h são fixas a partir do resgate.
//
// REGRAS DE SEGURANÇA:
// 1. A Key só pode ser resgatada pela MESMA pessoa que
//    gerou (discordId enviado pelo Worker/site).
// 2. Cada Key só é resgatada UMA vez (redeemedAt).
// 3. HWID (opcional) trava a Key ao primeiro dispositivo.
// 4. Sem histórico: a Key é deletada ao expirar.
// ============================================================
app.post(
  '/api/v2/keys/validate',
  dashboardAuth,
  (req, res) => {
    try {
      const {
        key,
        hwid,
        discordId
      } = req.body || {};

      /*
       * ==========================================
       * KEY AUSENTE
       * ==========================================
       */

      if (!key) {
        return res.json({
          success: true,
          valid: false,
          reason: 'key_ausente'
        });
      }

      /*
       * ==========================================
       * DISCORD ID OBRIGATÓRIO
       *
       * A Key pertence a um usuário específico.
       * Isso impede que outra pessoa copie a Key
       * e tente utilizá-la.
       * ==========================================
       */

      if (!discordId) {
        return res.json({
          success: true,
          valid: false,
          reason: 'discordid_ausente'
        });
      }

      /*
       * ==========================================
       * HASH DA KEY
       * ==========================================
       */

      const keyHash =
        hashProductKey(key);

      if (
        !db.productKeys ||
        typeof db.productKeys !== 'object'
      ) {
        db.productKeys = {};
      }

      const dados =
        db.productKeys[keyHash];

      /*
       * ==========================================
       * KEY NÃO ENCONTRADA
       * ==========================================
       */

      if (!dados) {
        return res.json({
          success: true,
          valid: false,
          reason: 'key_invalida'
        });
      }

      /*
       * ==========================================
       * KEY PERTENCE A OUTRO USUÁRIO
       * ==========================================
       */

      if (
        String(dados.discordId) !==
        String(discordId)
      ) {
        return res.json({
          success: true,
          valid: false,
          reason: 'key_de_outro_usuario'
        });
      }

      /*
       * ==========================================
       * KEY INATIVA
       * ==========================================
       */

      if (dados.status !== 'active') {
        return res.json({
          success: true,
          valid: false,
          reason: 'key_inativa'
        });
      }

      const agora =
        Date.now();

      const hwidCliente =
        hwid
          ? String(hwid)
          : null;

      /*
       * ==========================================
       * PRIMEIRO RESGATE
       *
       * A Key ainda não foi resgatada.
       * Aqui verificamos a janela de 5 minutos.
       * ==========================================
       */

      if (!dados.redeemedAt) {

        /*
         * KEY NÃO RESGATADA DENTRO DOS 5 MINUTOS
         */

        if (
          dados.expiresAt &&
          dados.expiresAt !== 'perm' &&
          Number(dados.expiresAt) < agora
        ) {
          delete db.productKeys[keyHash];

          saveDB();

          return res.json({
            success: true,
            valid: false,
            reason: 'key_nao_resgatada'
          });
        }

        /*
         * ======================================
         * PRIMEIRO RESGATE
         * ======================================
         */

        dados.redeemedAt =
          agora;

        /*
         * A partir daqui começa a sessão fixa
         * de 2 horas.
         *
         * IMPORTANTE:
         * Esse horário NÃO é renovado nas
         * próximas validações.
         */

        dados.sessionExpiresAt =
          agora +
          (2 * 60 * 60 * 1000);

        /*
         * Vincula o HWID no primeiro resgate,
         * caso o Worker tenha enviado um.
         */

        if (hwidCliente) {
          dados.hwid =
            hwidCliente;
        }

        saveDB();

        return res.json({
          success: true,
          valid: true,
          justRedeemed: true,

          data: {
            discordId:
              dados.discordId,

            username:
              dados.username || null,

            createdAt:
              dados.createdAt || null,

            redeemedAt:
              dados.redeemedAt,

            sessionExpiresAt:
              dados.sessionExpiresAt,

            sessionRemainingSeconds:
              Math.max(
                0,
                Math.floor(
                  (
                    dados.sessionExpiresAt -
                    agora
                  ) / 1000
                )
              ),

            status:
              dados.status,

            hwid:
              dados.hwid || null
          }
        });
      }

      /*
       * ==========================================
       * SESSÃO DE 2 HORAS EXPIRADA
       * ==========================================
       */

      if (
        dados.sessionExpiresAt &&
        Number(dados.sessionExpiresAt) < agora
      ) {
        delete db.productKeys[keyHash];

        saveDB();

        return res.json({
          success: true,
          valid: false,
          reason: 'sessao_expirada'
        });
      }

      /*
       * ==========================================
       * HWID
       *
       * Se a Key já possui HWID e o cliente
       * enviar outro HWID, rejeita.
       * ==========================================
       */

      if (
        dados.hwid &&
        hwidCliente &&
        dados.hwid !== hwidCliente
      ) {
        return res.json({
          success: true,
          valid: false,
          reason: 'hwid_mismatch'
        });
      }

      /*
       * Caso a Key ainda não possua HWID e o
       * cliente envie um, vincula agora.
       */

      if (
        !dados.hwid &&
        hwidCliente
      ) {
        dados.hwid =
          hwidCliente;

        saveDB();
      }

      /*
       * ==========================================
       * KEY VÁLIDA DURANTE A SESSÃO
       * ==========================================
       */

      return res.json({
        success: true,
        valid: true,
        justRedeemed: false,

        data: {
          discordId:
            dados.discordId,

          username:
            dados.username || null,

          createdAt:
            dados.createdAt || null,

          redeemedAt:
            dados.redeemedAt,

          sessionExpiresAt:
            dados.sessionExpiresAt,

          sessionRemainingSeconds:
            Math.max(
              0,
              Math.floor(
                (
                  dados.sessionExpiresAt -
                  agora
                ) / 1000
              )
            ),

          status:
            dados.status,

          hwid:
            dados.hwid || null
        }
      });

    } catch (error) {

      console.error(
        '[KEY VALIDATE]',
        error
      );

      return res.status(500).json({
        success: false,
        valid: false,
        reason: 'erro_interno'
      });
    }
  }
);

// ============================================================
// AUTENTICAÇÃO DASHBOARD
// ============================================================

function dashboardAuth(req, res, next) {
  const expectedKey =
    String(process.env.DASHBOARD_API_KEY || '').trim();

  const authorization =
    String(req.get('authorization') || '').trim();

  if (!expectedKey) {
    console.error(
      '[DASHBOARD AUTH] DASHBOARD_API_KEY não está carregada no processo.'
    );

    return res.status(503).json({
      success: false,
      error: 'DASHBOARD_API_KEY não configurada'
    });
  }

  if (!authorization) {
    console.error(
      '[DASHBOARD AUTH] Requisição chegou sem Authorization.'
    );

    return res.status(401).json({
      success: false,
      error: 'Não autorizado'
    });
  }

  const match =
    authorization.match(/^Bearer\s+(.+)$/i);

  if (!match) {
    console.error(
      '[DASHBOARD AUTH] Authorization recebido em formato inválido.'
    );

    return res.status(401).json({
      success: false,
      error: 'Não autorizado'
    });
  }

  const receivedKey =
    String(match[1] || '').trim();

  if (receivedKey !== expectedKey) {
    console.error(
      `[DASHBOARD AUTH] Chave diferente. Recebida: ${receivedKey.length} caracteres | Esperada: ${expectedKey.length} caracteres.`
    );

    return res.status(401).json({
      success: false,
      error: 'Não autorizado'
    });
  }

  next();
}
// ============================================================
// DASHBOARD — LISTAR TODOS OS CANAIS DO SERVIDOR
// ============================================================

app.get(
  '/api/dashboard/discord/channels',
  dashboardAuth,
  async (req, res) => {
    try {
      const guild = await getGuild();

      if (!guild) {
        return res.status(404).json({
          ok: false,
          error: 'Servidor do Discord não encontrado.'
        });
      }

      const channels = await guild.channels.fetch();

      const result = [...channels.values()]
        .filter(Boolean)
        .map((channel) => {
          let type = 'unknown';

          if (channel.type === ChannelType.GuildText) {
            type = 'text';
          } else if (
            channel.type === ChannelType.GuildAnnouncement
          ) {
            type = 'announcement';
          } else if (
            channel.type === ChannelType.GuildForum
          ) {
            type = 'forum';
          } else if (
            channel.type === ChannelType.GuildCategory
          ) {
            type = 'category';
          } else if (
            channel.type === ChannelType.GuildVoice
          ) {
            type = 'voice';
          } else if (
            channel.type === ChannelType.GuildStageVoice
          ) {
            type = 'stage';
          }

          return {
            id: channel.id,
            name: channel.name,
            type,
            category: channel.parent?.name || null,
            categoryId: channel.parentId || null,
            canSendMessages:
              typeof channel.isTextBased === 'function'
                ? channel.isTextBased()
                : false
          };
        })
        .sort((a, b) => {
          if (a.type === 'category' && b.type !== 'category') {
            return -1;
          }

          if (a.type !== 'category' && b.type === 'category') {
            return 1;
          }

          return a.name.localeCompare(
            b.name,
            'pt-BR',
            { sensitivity: 'base' }
          );
        });

      return res.json({
        ok: true,
        guild: {
          id: guild.id,
          name: guild.name
        },
        channels: result
      });

    } catch (error) {
      console.error(
        '[DASHBOARD] Erro ao listar canais do Discord:',
        error
      );

      return res.status(500).json({
        ok: false,
        error: 'Não foi possível carregar os canais do servidor.'
      });
    }
  }
);
// ============================================================
// OAUTH2 DISCORD — EXCHANGE CONTROLADO PELO WORKER
// ============================================================

app.post(
  '/api/auth/discord/exchange',
  dashboardAuth,
  async (req, res) => {
    try {
      const {
        code,
        redirectUri
      } = req.body || {};

      if (
        !DISCORD_CLIENT_ID ||
        !DISCORD_CLIENT_SECRET
      ) {
        return res.status(503).json({
          success: false,
          error:
            'OAuth2 do Discord não configurado no bot.'
        });
      }

      if (
        !code ||
        !redirectUri
      ) {
        return res.status(400).json({
          success: false,
          error:
            'Código OAuth ou redirectUri ausente.'
        });
      }

      if (
        DISCORD_OAUTH_REDIRECT_URI &&
        redirectUri !==
          DISCORD_OAUTH_REDIRECT_URI
      ) {
        return res.status(400).json({
          success: false,
          error:
            'Redirect URI inválido.'
        });
      }

      const tokenResponse =
        await fetch(
          'https://discord.com/api/oauth2/token',
          {
            method:
              'POST',

            headers: {
              'Content-Type':
                'application/x-www-form-urlencoded'
            },

            body:
              new URLSearchParams({
                client_id:
                  DISCORD_CLIENT_ID,

                client_secret:
                  DISCORD_CLIENT_SECRET,

                grant_type:
                  'authorization_code',

                code:
                  String(code),

                redirect_uri:
                  redirectUri
              }).toString()
          }
        );

      const tokenText =
        await tokenResponse.text();

      let tokenData;

      try {
        tokenData =
          JSON.parse(
            tokenText
          );
      } catch {
        tokenData =
          null;
      }

      if (
        !tokenResponse.ok ||
        !tokenData?.access_token
      ) {
        console.error(
          '[OAUTH] Discord rejeitou o token:',
          tokenResponse.status
        );

        return res.status(401).json({
          success: false,
          error:
            'OAuth2 do Discord recusado.'
        });
      }

      const userResponse =
        await fetch(
          'https://discord.com/api/users/@me',
          {
            headers: {
              Authorization:
                `Bearer ${tokenData.access_token}`
            }
          }
        );

      const userData =
        await userResponse.json();

      if (
        !userResponse.ok ||
        !userData?.id
      ) {
        return res.status(401).json({
          success: false,
          error:
            'Não foi possível identificar o usuário Discord.'
        });
      }

      const guild =
        await getGuild();

      if (!guild) {
        return res.status(404).json({
          success: false,
          error:
            'Servidor Discord não encontrado.'
        });
      }

      const member =
        await guild.members
          .fetch(
            userData.id
          )
          .catch(
            () => null
          );

      if (!member) {
        audit(
          userData.username ||
            userData.id,
          'dashboard_login_denied',
          userData.id,
          {
            reason:
              'not_in_guild'
          }
        );

        return res.status(403).json({
          success: false,
          error:
            'Você não está no servidor RD4X.'
        });
      }

      const admin =
        isAdmin(
          member,
          userData.id
        );

      if (!admin) {
        audit(
          userData.username ||
            userData.id,
          'dashboard_login_denied',
          userData.id,
          {
            reason:
              'not_admin'
          }
        );

        return res.status(403).json({
          success: false,
          error:
            'Você não possui o cargo administrativo do RD4X.'
        });
      }

      const owner =
        isOwner(
          userData.id
        );

      audit(
        userData.username ||
          userData.id,
        'dashboard_login',
        userData.id,
        {
          role:
            owner
              ? 'Dono'
              : 'Administrador'
        }
      );

      return res.json({
        success: true,

        data: {
          id:
            userData.id,

          discordId:
            userData.id,

          username:
            userData.username,

          globalName:
            userData.global_name ||
            null,

          avatar:
            member.user.displayAvatarURL({
              size: 256
            }),

          role:
            owner
              ? 'Dono'
              : 'Administrador',

          isOwner:
            owner,

          isAdmin:
            true
        }
      });

    } catch (error) {
      console.error(
        '[OAUTH EXCHANGE]',
        error
      );

      return res.status(500).json({
        success: false,
        error:
          'Erro interno na autenticação Discord.'
      });
    }
  }
);
// ============================================================
// DASHBOARD — VALIDAR SENHA DE USO ÚNICO
// ============================================================

app.post(
  '/api/auth/discord/verify-code',
  dashboardAuth,
  async (req, res) => {
    try {
      const discordId =
        String(
          req.headers[
            'x-dashboard-user-id'
          ] || ''
        ).trim();

      const code =
        req.body?.code;

      if (!discordId) {
        return res.status(401).json({
          success: false,
          error:
            'Usuário do Dashboard não identificado.'
        });
      }

      if (!code) {
        return res.status(400).json({
          success: false,
          error:
            'Senha ausente.'
        });
      }

      const guild =
        await getGuild();

      if (!guild) {
        return res.status(404).json({
          success: false,
          error:
            'Servidor Discord não encontrado.'
        });
      }

      const member =
        await guild.members
          .fetch(
            discordId
          )
          .catch(
            () => null
          );

      if (
        !member ||
        !isAdmin(
          member,
          discordId
        )
      ) {
        return res.status(403).json({
          success: false,
          error:
            'Administrador não autorizado.'
        });
      }

      const result =
        consumeDashboardCode(
          discordId,
          code
        );

      if (!result.valid) {
        audit(
          discordId,
          'dashboard_code_failed',
          discordId,
          {
            reason:
              result.error
          }
        );

        return res.status(401).json({
          success: false,
          error:
            result.error
        });
      }

      audit(
        discordId,
        'dashboard_code_verified',
        discordId
      );

      return res.json({
        success: true,

        data: {
          verified:
            true,

          discordId
        }
      });

    } catch (error) {
      console.error(
        '[DASHBOARD CODE]',
        error
      );

      return res.status(500).json({
        success: false,
        error:
          'Erro ao validar senha.'
      });
    }
  }
);

// ============================================================
// DASHBOARD — OVERVIEW
// ============================================================

app.get(
'/api/dashboard/overview',
dashboardAuth,
(req, res) => {
const ativos =
[
...usuariosLiberados.entries()
]
.filter(
([_, d]) =>
d.expiraEm === 'perm' ||
d.expiraEm > Date.now()
)
.length;

const abertos =
  [
    ...ticketsAtivos.values()
  ]
    .filter(
      t =>
        t.status !==
        'closed'
    )
    .length;

const faturamento =
  historicoVendas.reduce(
    (a, v) =>
      a +
      Number(
        v.valor || 0
      ),
    0
  );

res.json({
  success: true,

  data: {
    ativos,

    ticketsAbertos:
      abertos,

    execucoes:
      totalExecucoesGlobais,

    vendas:
      historicoVendas.length,

    faturamento,

    incidentesAbertos:
      db.incidentes.filter(
        i =>
          i.status === 'open'
      ).length
  }
});

}
);

// ============================================================
// DASHBOARD — USUÁRIOS
// ============================================================

app.get(
'/api/dashboard/users',
dashboardAuth,
(req, res) => {
const data =
[
...usuariosLiberados.entries()
].map(
([nick, d]) => ({
nick,
...d
})
);

res.json({
  success: true,
  data
});

}
);

// ============================================================
// DASHBOARD — TICKETS
// ============================================================

app.get(
'/api/dashboard/tickets',
dashboardAuth,
(req, res) => {
res.json({
success: true,

  data:
    [
      ...ticketsAtivos.entries()
    ].map(
      ([channelId, t]) => ({
        channelId,
        ...t
      })
    )
});

}
);

// ============================================================
// DASHBOARD — AUDITORIA
// ============================================================

app.get(
'/api/dashboard/audit',
dashboardAuth,
(req, res) => {
res.json({
success: true,

  data:
    db.auditoria
      .slice(-500)
      .reverse()
});

}
);

// ============================================================
// DASHBOARD — RELEASES
// ============================================================

app.get(
'/api/dashboard/releases',
dashboardAuth,
(req, res) => {
try {
const agora =
Date.now();

  const data =
    [
      ...usuariosLiberados.entries()
    ]
    .map(
      ([nick, dados]) => ({
        nick,

        discordId:
          dados?.discordId ||
          null,

        expiraEm:
          dados?.expiraEm ??
          null,

        avisadoExpiracao:
          Boolean(
            dados?.avisadoExpiracao
          ),

        hwid:
          dados?.hwid ||
          'LIVRE',

        valorPago:
          Number(
            dados?.valorPago || 0
          ),

        dataVenda:
          dados?.dataVenda ||
          null,

        status:
          dados?.expiraEm === 'perm'
            ? 'permanent'
            : (
              Number(
                dados?.expiraEm || 0
              ) > agora
                ? 'active'
                : 'expired'
            )
      })
    )
    .filter(
      release =>
        release.status !==
        'expired'
    );

  data.sort(
    (a, b) => {
      const ta =
        a.dataVenda
          ? new Date(
              a.dataVenda
            ).getTime()
          : 0;

      const tb =
        b.dataVenda
          ? new Date(
              b.dataVenda
            ).getTime()
          : 0;

      return tb - ta;
    }
  );

  return res.json({
    success: true,
    data
  });

} catch (error) {
  console.error(
    '[DASHBOARD RELEASES]',
    error
  );

  return res.status(500).json({
    success: false,
    error:
      'Erro ao buscar releases'
  });
}

}
);

// ============================================================
// DASHBOARD — CRIAR RELEASE
// ============================================================

app.post(
'/api/dashboard/release',
dashboardAuth,
async (req, res) => {
try {
const {
actorId,
actorTag,
tempo,
nick,
discordId,
valor = 0
} = req.body || {};

  if (
    !actorId ||
    (
      !isOwner(actorId) &&
      actorId !== 'verified-admin'
    )
  ) {
    return res.status(403).json({
      success: false,
      error:
        'Administrador não verificado'
    });
  }

  if (!nick) {
    return res.status(400).json({
      success: false,
      error:
        'Nick ausente'
    });
  }

  const parsed =
    String(
      tempo || ''
    )
    .trim()
    .toLowerCase();

  let expiraEm;

  if (
    parsed === 'perm' ||
    parsed === 'permanente'
  ) {
    expiraEm =
      'perm';

  } else {
    const match =
      parsed.match(
        /^(\d+)(d|m|h)$/
      );

    if (!match) {
      return res.status(400).json({
        success: false,
        error:
          'Tempo inválido. Use 3d, 12d, 1m, 2m ou perm.'
      });
    }

    const qtd =
      Number(
        match[1]
      );

    const unidade =
      match[2];

    const dias =
      unidade === 'm'
        ? qtd * 30
        : unidade === 'h'
          ? qtd / 24
          : qtd;

    expiraEm =
      Date.now() +
      dias *
      86400000;
  }

  const valorNumerico =
    Number(
      valor || 0
    );

  const dataVenda =
    new Date().toISOString();

  usuariosLiberados.set(
    nick,
    {
      expiraEm,

      discordId:
        discordId ||
        null,

      avisadoExpiracao:
        false,

      hwid:
        'LIVRE',

      valorPago:
        Number.isFinite(
          valorNumerico
        )
          ? valorNumerico
          : 0,

      dataVenda
    }
  );

  if (
    valorNumerico > 0
  ) {
    historicoVendas.push({
      nick,

      valor:
        valorNumerico,

      data:
        dataVenda
    });
  }

  db.releaseWindow.push(
    Date.now()
  );

  db.releaseWindow =
    db.releaseWindow.filter(
      timestamp =>
        Date.now() -
        timestamp <
        15 * 60 * 1000
    );

  audit(
    actorTag ||
    actorId,
    'release',
    nick,
    {
      tempo: parsed,
      valor:
        valorNumerico,
      discordId:
        discordId ||
        null
    }
  );

  if (
    db.releaseWindow.length >
    50
  ) {
    incident(
      'mass_release_threshold',
      'critical',
      {
        count:
          db.releaseWindow.length
      }
    );
  }

  syncDB();

  if (
    discordId &&
    ID_CARGO_CLIENTE
  ) {
    const guild =
      await getGuild();

    const member =
      guild
        ? await guild.members
            .fetch(discordId)
            .catch(
              () => null
            )
        : null;

    if (member) {
      await member.roles
        .add(
          ID_CARGO_CLIENTE
        )
        .catch(
          () => {}
        );
    }
  }

  return res.json({
    success: true,

    nick,

    expiraEm,

    discordId:
      discordId ||
      null,

    valorPago:
      valorNumerico,

    dataVenda
  });

} catch (error) {
  console.error(
    '[DASHBOARD RELEASE]',
    error
  );

  return res.status(500).json({
    success: false,
    error:
      'Erro ao criar release'
  });
}

}
);

// ============================================================
// DASHBOARD — RESET HWID
// ============================================================

app.post(
'/api/dashboard/reset-hwid',
dashboardAuth,
(req, res) => {
const {
actorId,
actorTag,
nick
} = req.body || {};

if (!actorId) {
  return res.status(400).json({
    success: false,
    error:
      'actorId ausente'
  });
}

if (
  usuariosLiberados.has(
    nick
  )
) {
  const dados =
    usuariosLiberados.get(
      nick
    );

  dados.hwid =
    'LIVRE';

  dados.hwidResetAt =
    new Date().toISOString();

  usuariosLiberados.set(
    nick,
    dados
  );

  audit(
    actorTag ||
    actorId,
    'reset_hwid',
    nick
  );

  syncDB();

  return res.json({
    success: true
  });
}

return res.status(404).json({
  success: false,
  error:
    'Cliente não encontrado'
});

}
);

// ============================================================
// DASHBOARD — REVOGAR
// ============================================================

app.post(
'/api/dashboard/revoke',
dashboardAuth,
async (req, res) => {
const {
actorId,
actorTag,
nick
} = req.body || {};

const dados =
  usuariosLiberados.get(
    nick
  );

if (!dados) {
  return res.status(404).json({
    success: false,
    error:
      'Cliente não encontrado'
  });
}

const guild =
  await getGuild();

if (
  guild &&
  dados.discordId &&
  ID_CARGO_CLIENTE
) {
  const member =
    await guild.members
      .fetch(
        dados.discordId
      )
      .catch(
        () => null
      );

  if (member) {
    await member.roles
      .remove(
        ID_CARGO_CLIENTE
      )
      .catch(
        () => {}
      );
  }
}

usuariosLiberados.delete(
  nick
);

audit(
  actorTag ||
  actorId,
  'revoke_panel',
  nick
);

syncDB();

return res.json({
  success: true
});

}
);

// ============================================================
// DASHBOARD — BLACKLIST
// ============================================================

app.post(
'/api/dashboard/blacklist',
dashboardAuth,
(req, res) => {
const {
actorId,
actorTag,
value
} = req.body || {};

if (!value) {
  return res.status(400).json({
    success: false,
    error:
      'value ausente'
  });
}

blacklist.add(
  String(value)
);

audit(
  actorTag ||
  actorId,
  'blacklist',
  String(value)
);

syncDB();

res.json({
  success: true
});

}
);

// ============================================================
// DASHBOARD — REMOVER BLACKLIST
// ============================================================

app.post(
'/api/dashboard/unblacklist',
dashboardAuth,
(req, res) => {
const {
actorId,
actorTag,
value
} = req.body || {};

blacklist.delete(
  String(value)
);

audit(
  actorTag ||
  actorId,
  'unblacklist',
  String(value)
);

syncDB();

res.json({
  success: true
});

}
);

// ============================================================
// DASHBOARD — ADMINISTRADORES
// ============================================================
//
// 1. O Dono aparece mesmo sem possuir o cargo ADMIN.
// 2. Administradores continuam sendo encontrados pelo cargo.
// 3. Presence Intent permite status online/idle/dnd/offline.
// 4. fetch({ force: true }) atualiza os membros.
// 5. Esta rota existe apenas uma vez.
// ============================================================

app.get(
'/api/dashboard/admins',
dashboardAuth,
async (req, res) => {
try {
const guild =
await getGuild();

  if (!guild) {
    console.error(
      '[DASHBOARD ADMINS] Servidor Discord não encontrado.'
    );

    return res.status(404).json({
      success: false,
      error:
        'Servidor Discord não encontrado'
    });
  }

  console.log(
    `[DASHBOARD ADMINS] Guild: ${guild.name} (${guild.id})`
  );

  console.log(
    `[DASHBOARD ADMINS] Cargo Admin: ${ID_CARGO_ADMIN}`
  );

  const cargoAdmin =
    guild.roles.cache.get(
      ID_CARGO_ADMIN
    );

  if (!cargoAdmin) {
    console.warn(
      `[DASHBOARD ADMINS] O cargo ${ID_CARGO_ADMIN} não foi encontrado neste servidor.`
    );
  }

  const membros =
    await guild.members.fetch({
      force: true
    });

  const admins =
    membros
      .filter(
        member =>
          Boolean(
            member.user
          ) &&
          (
            member.id ===
              ID_DONO ||
            member.roles.cache.has(
              ID_CARGO_ADMIN
            )
          )
      )
      .map(
        member => {
          const owner =
            member.id ===
            ID_DONO;

          return {
            id:
              member.id,

            discordId:
              member.id,

            name:
              member.user.username,

            globalName:
              member.user.globalName ||
              null,

            tag:
              member.user.tag,

            avatar:
              member.user.displayAvatarURL({
                size: 128
              }),

            role:
              owner
                ? 'Dono'
                : 'Administrador',

            isOwner:
              owner,

            status:
              member.presence?.status ||
              'offline'
          };
        }
      );

  admins.sort(
    (a, b) => {
      if (
        a.isOwner &&
        !b.isOwner
      ) {
        return -1;
      }

      if (
        !a.isOwner &&
        b.isOwner
      ) {
        return 1;
      }

      return a.name.localeCompare(
        b.name,
        'pt-BR'
      );
    }
  );

  console.log(
    `[DASHBOARD ADMINS] ${admins.length} administrador(es) encontrado(s).`
  );

  for (
    const admin of admins
  ) {
    console.log(
      `[DASHBOARD ADMINS] ${admin.name} (${admin.id}) → ${admin.status}`
    );
  }

  return res.json({
    success: true,

    data:
      admins
  });

} catch (error) {
  console.error(
    '[DASHBOARD ADMINS]',
    error
  );

  return res.status(500).json({
    success: false,
    error:
      'Erro ao buscar administradores'
  });
}

}
);

// ============================================================
// DASHBOARD — INCIDENTES
// ============================================================

app.get(
'/api/dashboard/incidents',
dashboardAuth,
(req, res) => {
try {
const data =
Array.isArray(
db.incidentes
)
? db.incidentes
.slice(-1000)
.reverse()
: [];

  return res.json({
    success: true,
    data
  });

} catch (error) {
  console.error(
    '[DASHBOARD INCIDENTS]',
    error
  );

  return res.status(500).json({
    success: false,
    error:
      'Erro ao buscar incidentes'
  });
}

}
);

// ============================================================
// DASHBOARD — TRANSCRIPTS
// ============================================================

app.get(
'/api/dashboard/transcripts',
dashboardAuth,
(req, res) => {
try {
if (
!fs.existsSync(
TRANSCRIPT_DIR
)
) {
return res.json({
success: true,
data: []
});
}

  const arquivos =
    fs.readdirSync(
      TRANSCRIPT_DIR
    )
    .filter(
      file =>
        file
          .toLowerCase()
          .endsWith('.txt')
    );

  const transcripts = [];

  for (
    const fileName of arquivos
  ) {
    try {
      const filePath =
        path.join(
          TRANSCRIPT_DIR,
          fileName
        );

      const stat =
        fs.statSync(
          filePath
        );

      const texto =
        fs.readFileSync(
          filePath,
          'utf8'
        );

      const linhas =
        texto
          .split(/\r?\n/)
          .filter(
            linha =>
              linha.trim()
          );

      const messages =
        linhas.map(
          (linha, index) => {
            const match =
              linha.match(
                /^\[([^\]]+)\]\s+([^:]+):\s?(.*)$/ 
              );

            if (match) {
              return {
                id:
                  `${fileName}-${index}`,

                role:
                  'message',

                author:
                  match[2],

                time:
                  match[1],

                text:
                  match[3]
              };
            }

            return {
              id:
                `${fileName}-${index}`,

              role:
                'message',

              author:
                '—',

              time:
                '',

              text:
                linha
            };
          }
        );

      const channelMatch =
        fileName.match(
          /^transcript-(\d+)-/
        );

      const channelId =
        channelMatch
          ? channelMatch[1]
          : '';

      transcripts.push({
        id:
          fileName
            .replace(
              /\.txt$/i,
              ''
            ),

        ticketId:
          channelId,

        userId:
          '',

        admin:
          '—',

        createdAt:
          stat.birthtime &&
          !Number.isNaN(
            stat.birthtime.getTime()
          )
            ? stat.birthtime.toISOString()
            : stat.mtime.toISOString(),

        messages,

        fileName
      });

    } catch (error) {
      console.error(
        `[DASHBOARD TRANSCRIPTS] Erro ao ler ${fileName}:`,
        error
      );
    }
  }

  transcripts.sort(
    (a, b) =>
      new Date(
        b.createdAt
      ).getTime() -
      new Date(
        a.createdAt
      ).getTime()
  );

  return res.json({
    success: true,
    data: transcripts
  });

} catch (error) {
  console.error(
    '[DASHBOARD TRANSCRIPTS]',
    error
  );

  return res.status(500).json({
    success: false,
    error:
      'Erro ao buscar transcripts'
  });
}

}
);

// ============================================================
// SERVIDOR WEB
// ============================================================

app.listen(
port,
'0.0.0.0',
() => {
console.log(
"[WEB] RD4X API rodando na porta ${port}"
);
}
);

// ============================================================
// DISCORD CLIENT
// ============================================================
//
// GuildPresences foi adicionado para que
// member.presence?.status funcione.
// ============================================================

client =
new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent,
    GatewayIntentBits.GuildMembers,
    GatewayIntentBits.GuildPresences
  ]
});
// ============================================================
// READY
// ============================================================

client.once(
  'ready',
  async () => {
console.log(
  `[SUCESSO] Bot online como ${client.user.tag}!`
);
console.log(
  `[DISCORD] Servidores conectados: ${client.guilds.cache.size}`
);

let i = 0;

// ========================================================
// SLASH COMMAND — SENHA DO DASHBOARD
// ========================================================

try {
  const rest =
    new REST({
      version: '10'
    }).setToken(
      process.env.DISCORD_TOKEN
    );

  const command =
    new SlashCommandBuilder()
      .setName(
        'dashboard-senha'
      )
      .setDescription(
        'Gera uma senha temporária para acessar o RD4X Dashboard.'
      );

  if (GUILD_ID) {
    await rest.put(
      Routes.applicationGuildCommands(
        DISCORD_CLIENT_ID,
        GUILD_ID
      ),
      {
        body: [
          command.toJSON()
        ]
      }
    );
  }

  console.log(
    '[DASHBOARD] Slash command /dashboard-senha registrado.'
  );

} catch (error) {
  console.error(
    '[DASHBOARD] Erro ao registrar /dashboard-senha:',
    error
  );
} 

setInterval(
  () => {
    const lista = [
      {
        name:
          'RD4X Hub | Tickets 🎫',
        type: 0
      },

      {
        name:
          `${usuariosLiberados.size} Clientes VIP 💎`,
        type: 3
      },

      {
        name:
          `${totalExecucoesGlobais} Execuções 🎮`,
        type: 0
      },

      {
        name:
          '!ajuda | Suporte 🎫',
        type: 2
      }
    ];

    client.user.setActivity(
      lista[i].name,
      {
        type:
          lista[i].type
      }
    );

    i =
      (i + 1) %
      lista.length;

  },
  15000
);

// ========================================================
// EXPIRAÇÃO
// ========================================================

setInterval(
  async () => {
    const agora =
      Date.now();

    for (
      const [
        nick,
        dados
      ] of usuariosLiberados.entries()
    ) {
      if (
        dados.expiraEm &&
        dados.expiraEm !==
          'perm'
      ) {
        const restante =
          dados.expiraEm -
          agora;

        if (
          restante > 0 &&
          restante <=
            172800000 &&
          !dados.avisadoExpiracao
        ) {
          dados.avisadoExpiracao =
            true;

          if (
            dados.discordId
          ) {
            const user =
              await client.users
                .fetch(
                  dados.discordId
                )
                .catch(
                  () => null
                );

            if (user) {
              await user
                .send(
                  `⚠️ **Aviso de Expiração — RD4X Hub**\n\n` +
                  `Seu painel para **${nick}** expira em menos de 48 horas. ` +
                  `Abra um ticket para renovar.`
                )
                .catch(
                  () => {}
                );
            }
          }
        }

        if (
          restante <= 0
        ) {
          const guild =
            await getGuild();

          if (
            guild &&
            dados.discordId &&
            ID_CARGO_CLIENTE
          ) {
            const member =
              await guild.members
                .fetch(
                  dados.discordId
                )
                .catch(
                  () => null
                );

            if (member) {
              await member.roles
                .remove(
                  ID_CARGO_CLIENTE
                )
                .catch(
                  () => {}
                );
            }
          }

          usuariosLiberados.delete(
            nick
          );

          audit(
            'SYSTEM',
            'expiration',
            nick
          );
        }
      }
    }

    syncDB();

  },
  60000
);

// ========================================================
// INATIVIDADE DE TICKETS
// ========================================================

setInterval(
  async () => {
    const agora =
      Date.now();

    for (
      const [
        idCanal,
        dados
      ] of ticketsAtivos.entries()
    ) {
      if (
        dados.ultimoContato &&
        agora -
          dados.ultimoContato >=
          86400000 &&
        !dados.avisoInatividade
      ) {
        dados.avisoInatividade =
          true;

        const canal =
          client.channels.cache.get(
            idCanal
          );

        if (canal) {
          await canal
            .send(
              '⏱️ **Aviso de Inatividade:** este ticket está sem respostas há 24 horas e poderá ser encerrado em breve.'
            )
            .catch(
              () => {}
            );
        }
      }
    }

    syncDB();

  },
  300000
);

}
);

// ============================================================
// LOGS DE TICKET
// ============================================================

async function registrarLogTicket(
guild,
idTicket,
tituloGeral,
usuario,
novoEvento,
cor = 0xff0033
) {
const dados =
ticketsAtivos.get(
idTicket
) || {
logs: [],
messageId: null,
ultimoContato:
Date.now(),
status: 'open'
};

dados.logs.push(
"• [<t:${Math.floor(Date.now() / 1000)}:R>] ${novoEvento}"
);

dados.ultimoContato =
Date.now();

ticketsAtivos.set(
idTicket,
dados
);

syncDB();

if (!ID_CANAL_LOGS) {
return;
}

const canalLogs =
guild.channels.cache.get(
ID_CANAL_LOGS
);

if (!canalLogs) {
return;
}

const embed =
new EmbedBuilder()
.setTitle(
"🎫 Atendimento — ${tituloGeral}"
)
.setColor(cor)
.setDescription(
"**Usuário:** ${usuario}\n\n" +
"**Histórico:**\n" +
"${dados.logs .slice(-20) .join('\n')}"
)
.setFooter({
text:
'RD4X Hub • Logs de Atendimento'
})
.setTimestamp();

try {
if (
dados.messageId
) {
const msg =
await canalLogs.messages
.fetch(
dados.messageId
);

  await msg.edit({
    embeds: [
      embed
    ]
  });

} else {
  const msg =
    await canalLogs.send({
      embeds: [
        embed
      ]
    });

  dados.messageId =
    msg.id;

  ticketsAtivos.set(
    idTicket,
    dados
  );

  syncDB();
}

} catch {}
}

// ============================================================
// DADOS DE TICKET
// ============================================================

function ticketData(
channelId,
userId
) {
return (
ticketsAtivos.get(
channelId
) || {
userId,

  status:
    'open',

  prioridade:
    'normal',

  tags: [],

  notas: [],

  logs: [],

  ultimoContato:
    Date.now(),

  avisoInatividade:
    false
}

);
}

// ============================================================
// MENSAGENS
// ============================================================

client.on(
'messageCreate',
async message => {
if (
message.author.bot
) {
return;
}

if (
  message.channel.name?.startsWith(
    'ticket-'
  )
) {
  const dados =
    ticketData(
      message.channel.id,
      message.author.id
    );

  dados.ultimoContato =
    Date.now();

  dados.avisoInatividade =
    false;

  if (
    message.attachments.size >
    0
  ) {
    dados.pagamento =
      'comprovante_recebido';

    await message
      .reply(
        'Aguarde um momento, você já vai ser respondido! ⌛'
      )
      .catch(
        () => {}
      );

    await registrarLogTicket(
      message.guild,
      message.channel.id,
      message.channel.name,
      `<@${message.author.id}>`,
      '📷 Comprovante/anexo recebido.',
      0xffaa00
    );
  }

  ticketsAtivos.set(
    message.channel.id,
    dados
  );

  syncDB();
}

const args =
  message.content
    .trim()
    .split(/\s+/);

const comando =
  (
    args[0] ||
    ''
  ).toLowerCase();

const admin =
  isAdmin(
    message.member,
    message.author.id
  );

// ========================================================
// GERAR KEY
// ========================================================

if (
  comando ===
  '!gerar'
) {
  if (
    ID_CANAL_GERAR &&
    message.channel.id !==
      ID_CANAL_GERAR
  ) {
    return;
  }

  await message
    .delete()
    .catch(
      () => {}
    );

  const rowGerarKey =
    new ActionRowBuilder()
      .addComponents(
        new ButtonBuilder()
          .setCustomId(
            'rd4x_gerar_senha'
          )
          .setLabel(
            'Gerar senha'
          )
          .setEmoji('🔑')
          .setStyle(
            ButtonStyle.Success
          )
      );

  return message.channel.send({
    content:
      '🔑 Sistema de geração RD4X',

    components: [
      rowGerarKey
    ]
  });
}

// ========================================================
// ADMIN HELP
// ========================================================
// ========================================================
// ADMIN HELP
// ========================================================

if (
  comando ===
    '!admin_help' ||
  comando ===
    '!adminhelp'
) {
  if (!admin) {
    return message.reply(
      '❌ Apenas administradores do RD4X podem usar este comando!'
    );
  }

  const embed =
    new EmbedBuilder()
      .setTitle(
        '🛡️ RD4X — Comandos de Atendimento'
      )
      .setColor(0xff0033)
      .addFields(
        {
          name:
            '🎫 Tickets',
          value:
            '`!painel` • `!fechar` • `!suporte` • `!assumir`'
        },

        {
          name:
            '🔑 Clientes',
          value:
            '`!liberar` • `!retirarpainel` • `!status` • `!tempo`'
        },

        {
          name:
            '🔄 HWID',
          value:
            '`!resetarhwid`'
        },

        {
          name:
            '🚫 Bloqueios',
          value:
            '`!blacklist` • `!unblacklist`'
        },

        {
          name:
            '📋 Atendimento',
          value:
            '`!prioridade` • `!tag` • `!nota` • `!resumo`'
        },

        {
          name:
            '📈 Dono',
          value:
            '`!financeiro` • `!emergencia`'
        }
      )
      .setTimestamp();

  return message.reply({
    embeds: [
      embed
    ]
  });
}

// ========================================================
// FINANCEIRO
// ========================================================

if (
  comando ===
    '!financeiro' ||
  comando ===
    '!vendas'
) {
  if (
    !isOwner(
      message.author.id
    )
  ) {
    return message.reply(
      '❌ Este comando é exclusivo do Dono.'
    );
  }

  const total =
    historicoVendas.reduce(
      (a, v) =>
        a +
        Number(
          v.valor || 0
        ),
      0
    );

  return message.reply({
    embeds: [
      new EmbedBuilder()
        .setTitle(
          '📈 RD4X — Financeiro'
        )
        .setColor(0xff0033)
        .addFields(
          {
            name:
              '💎 Clientes ativos',
            value:
              String(
                usuariosLiberados.size
              ),
            inline:true
          },

          {
            name:
              '🎮 Execuções',
            value:
              String(
                totalExecucoesGlobais
              ),
            inline:true
          },

          {
            name:
              '💰 Faturamento',
            value:
              `R$ ${total.toFixed(2)}`,
            inline:true
          },

          {
            name:
              '📦 Vendas',
            value:
              String(
                historicoVendas.length
              ),
            inline:true
          }
        )
        .setTimestamp()
    ]
  });
}

// ========================================================
// RESET HWID
// ========================================================

if (
  comando ===
  '!resetarhwid'
) {
  if (!admin) {
    return message.reply(
      '❌ Sem permissão!'
    );
  }

  const nick =
    args[1];

  if (!nick) {
    return message.reply(
      '⚠️ Use `!resetarhwid [nick]`'
    );
  }

  const dados =
    usuariosLiberados.get(
      nick
    );

  if (!dados) {
    return message.reply(
      `❌ **${nick}** não possui cadastro ativo.`
    );
  }

  dados.hwid =
    'LIVRE';

  dados.hwidResetAt =
    new Date().toISOString();

  usuariosLiberados.set(
    nick,
    dados
  );

  audit(
    message.author.tag,
    'reset_hwid',
    nick
  );

  syncDB();

  return message.reply(
    `🔄 HWID de **${nick}** resetado. O próximo aparelho válido será vinculado.`
  );
}

// ========================================================
// BLACKLIST
// ========================================================

if (
  comando ===
  '!blacklist'
) {
  if (!admin) {
    return message.reply(
      '❌ Sem permissão!'
    );
  }

  const valor =
    args[1];

  if (!valor) {
    return message.reply(
      '⚠️ Use `!blacklist [nick/id]`'
    );
  }

  blacklist.add(
    valor
  );

  audit(
    message.author.tag,
    'blacklist',
    valor
  );

  syncDB();

  return message.reply(
    `🚫 **${valor}** foi adicionado à blacklist.`
  );
}

if (
  comando ===
  '!unblacklist'
) {
  if (!admin) {
    return message.reply(
      '❌ Sem permissão!'
    );
  }

  const valor =
    args[1];

  if (!valor) {
    return message.reply(
      '⚠️ Use `!unblacklist [nick/id]`'
    );
  }

  blacklist.delete(
    valor
  );

  audit(
    message.author.tag,
    'unblacklist',
    valor
  );

  syncDB();

  return message.reply(
    `✅ **${valor}** foi removido da blacklist.`
  );
}

// ========================================================
// LIBERAR
// ========================================================

if (
  comando ===
  '!liberar'
) {
  if (!admin) {
    return message.reply(
      '❌ Sem permissão!'
    );
  }

  const tempo =
    (
      args[1] ||
      ''
    ).toLowerCase();

  const nick =
    args[2];

  const mencao =
    message.mentions.members.first();

  const valor =
    parseFloat(
      args[4] ||
      args[3]
    ) || 0;

  if (
    !tempo ||
    !nick
  ) {
    return message.reply(
      '⚠️ Use `!liberar [tempo] [nick] [@membro] [valor]`'
    );
  }

  let expiraEm;

  if (
    tempo === 'perm' ||
    tempo === 'permanente'
  ) {
    expiraEm =
      'perm';

  } else {
    const match =
      tempo.match(
        /^(\d+)(d|m|h)?$/
      );

    if (!match) {
      return message.reply(
        '⚠️ Tempo inválido. Exemplos: `3d`, `12d`, `1m`, `2m`, `perm`.'
      );
    }

    const qtd =
      Number(
        match[1]
      );

    const dias =
      match[2] === 'm'
        ? qtd * 30
        : match[2] === 'h'
          ? qtd / 24
          : qtd;

    expiraEm =
      Date.now() +
      dias *
      86400000;
  }

  usuariosLiberados.set(
    nick,
    {
      expiraEm,

      discordId:
        mencao?.id ||
        null,

      avisadoExpiracao:
        false,

      hwid:
        'LIVRE',

      valorPago:
        valor,

      dataVenda:
        new Date().toISOString()
    }
  );

  if (
    valor > 0
  ) {
    historicoVendas.push({
      nick,

      valor,

      data:
        new Date().toISOString()
    });
  }

  if (
    mencao &&
    ID_CARGO_CLIENTE
  ) {
    await mencao.roles
      .add(
        ID_CARGO_CLIENTE
      )
      .catch(
        () => {}
      );
  }

  audit(
    message.author.tag,
    'release',
    nick,
    {
      tempo,
      valor
    }
  );

  db.releaseWindow.push(
    Date.now()
  );

  db.releaseWindow =
    db.releaseWindow.filter(
      t =>
        Date.now() -
        t <
        900000
    );

  if (
    db.releaseWindow.length >
    50
  ) {
    incident(
      'mass_release_threshold',
      'critical',
      {
        count:
          db.releaseWindow.length
      }
    );
  }

  syncDB();

  return message.reply(
    `✅ Acesso liberado para **${nick}** por **${tempo}**${
      mencao
        ? ` • VIP concedido a <@${mencao.id}>.`
        : ''
    }`
  );
}

// ========================================================
// REVOGAR PAINEL
// ========================================================

if (
  comando ===
  '!retirarpainel'
) {
  if (!admin) {
    return message.reply(
      '❌ Sem permissão!'
    );
  }

  const nick =
    args[1];

  if (!nick) {
    return message.reply(
      '⚠️ Use `!retirarpainel [nick]`'
    );
  }

  const dados =
    usuariosLiberados.get(
      nick
    );

  const guild =
    message.guild;

  if (
    dados?.discordId &&
    ID_CARGO_CLIENTE
  ) {
    const member =
      await guild.members
        .fetch(
          dados.discordId
        )
        .catch(
          () => null
        );

    if (member) {
      await member.roles
        .remove(
          ID_CARGO_CLIENTE
        )
        .catch(
          () => {}
        );
    }
  }

  usuariosLiberados.delete(
    nick
  );

  audit(
    message.author.tag,
    'revoke_panel',
    nick
  );

  syncDB();

  return message.reply(
    `🔒 Painel de **${nick}** revogado.`
  );
}

// ========================================================
// STATUS
// ========================================================

if (
  comando ===
  '!status'
) {
  const nick =
    args[1];

  if (!nick) {
    return message.reply(
      '⚠️ Use `!status [nick]`'
    );
  }

  return message.reply(
    usuariosLiberados.has(
      nick
    ) ||
    nick === ID_DONO
      ? `🟢 **${nick}** possui painel ativo.`
      : `🔴 **${nick}** não possui registro ativo.`
  );
}

// ========================================================
// TEMPO
// ========================================================

if (
  comando ===
  '!tempo'
) {
  const nick =
    args[1];

  if (!nick) {
    return message.reply(
      '⚠️ Use `!tempo [nick]`'
    );
  }

  const dados =
    usuariosLiberados.get(
      nick
    );

  if (!dados) {
    return message.reply(
      `❌ **${nick}** não está cadastrado.`
    );
  }

  if (
    dados.expiraEm ===
    'perm'
  ) {
    return message.reply(
      `♾️ **${nick}** possui painel permanente.`
    );
  }

  const restante =
    dados.expiraEm -
    Date.now();

  if (
    restante <= 0
  ) {
    return message.reply(
      `⏱️ O painel de **${nick}** já expirou.`
    );
  }

  return message.reply(
    `⏳ Restam aproximadamente **${Math.ceil(restante / 86400000)} dia(s)** para **${nick}**.`
  );
}

// ========================================================
// SUPORTE
// ========================================================

if (
  comando ===
  '!suporte'
) {
  return message.reply({
    content:
      `🆘 **Ajuda solicitada!**\n\n` +
      `Aguarde os administradores. <@&${ID_CARGO_ADMIN}>`,

    allowedMentions: {
      roles: [
        ID_CARGO_ADMIN
      ]
    }
  });
}

// ========================================================
// ASSUMIR
// ========================================================

if (
  comando ===
  '!assumir'
) {
  if (!admin) {
    return message.reply(
      '❌ Sem permissão!'
    );
  }

  if (
    !message.channel.name.startsWith(
      'ticket-'
    )
  ) {
    return message.reply(
      '❌ Use dentro de um ticket.'
    );
  }

  const dados =
    ticketData(
      message.channel.id,
      message.channel.id
    );

  dados.assumidoPor = {
    id:
      message.author.id,

    tag:
      message.author.tag,

    at:
      new Date().toISOString()
  };

  dados.status =
    'em_atendimento';

  ticketsAtivos.set(
    message.channel.id,
    dados
  );

  audit(
    message.author.tag,
    'ticket_takeover',
    message.channel.name
  );

  syncDB();

  return message.reply(
    `🧑‍💻 Ticket assumido por **${message.author.tag}**.`
  );
}

// ========================================================
// PRIORIDADE
// ========================================================

if (
  comando ===
  '!prioridade'
) {
  if (!admin) {
    return message.reply(
      '❌ Sem permissão!'
    );
  }

  if (
    !message.channel.name.startsWith(
      'ticket-'
    )
  ) {
    return message.reply(
      '❌ Use dentro de um ticket.'
    );
  }

  const p =
    (
      args[1] ||
      ''
    ).toLowerCase();

  if (
    ![
      'baixa',
      'normal',
      'alta',
      'urgente'
    ].includes(p)
  ) {
    return message.reply(
      '⚠️ Use: `baixa`, `normal`, `alta` ou `urgente`.'
    );
  }

  const dados =
    ticketData(
      message.channel.id
    );

  dados.prioridade =
    p;

  ticketsAtivos.set(
    message.channel.id,
    dados
  );

  audit(
    message.author.tag,
    'ticket_priority',
    message.channel.name,
    {
      prioridade:
        p
    }
  );

  syncDB();

  return message.reply(
    `🚦 Prioridade definida como **${p}**.`
  );
}

// ========================================================
// TAG
// ========================================================

if (
  comando ===
  '!tag'
) {
  if (!admin) {
    return message.reply(
      '❌ Sem permissão!'
    );
  }

  if (
    !message.channel.name.startsWith(
      'ticket-'
    )
  ) {
    return message.reply(
      '❌ Use dentro de um ticket.'
    );
  }

  const tag =
    args
      .slice(1)
      .join(' ');

  if (!tag) {
    return message.reply(
      '⚠️ Use `!tag pagamento`, por exemplo.'
    );
  }

  const dados =
    ticketData(
      message.channel.id
    );

  dados.tags ||=
    [];

  if (
    !dados.tags.includes(
      tag
    )
  ) {
    dados.tags.push(
      tag
    );
  }

  ticketsAtivos.set(
    message.channel.id,
    dados
  );

  syncDB();

  return message.reply(
    `🏷️ Tag **${tag}** adicionada.`
  );
}

// ========================================================
// NOTA
// ========================================================

if (
  comando ===
  '!nota'
) {
  if (!admin) {
    return message.reply(
      '❌ Sem permissão!'
    );
  }

  if (
    !message.channel.name.startsWith(
      'ticket-'
    )
  ) {
    return message.reply(
      '❌ Use dentro de um ticket.'
    );
  }

  const nota =
    args
      .slice(1)
      .join(' ');

  if (!nota) {
    return message.reply(
      '⚠️ Escreva a nota.'
    );
  }

  const dados =
    ticketData(
      message.channel.id
    );

  dados.notas ||=
    [];

  dados.notas.push({
    by:
      message.author.tag,

    text:
      nota,

    at:
      new Date().toISOString()
  });

  ticketsAtivos.set(
    message.channel.id,
    dados
  );

  audit(
    message.author.tag,
    'ticket_note',
    message.channel.name
  );

  syncDB();

  return message.reply(
    '📝 Nota interna registrada.'
  );
}

// ========================================================
// RESUMO
// ========================================================

if (
  comando ===
  '!resumo'
) {
  if (!admin) {
    return message.reply(
      '❌ Sem permissão!'
    );
  }

  if (
    !message.channel.name.startsWith(
      'ticket-'
    )
  ) {
    return message.reply(
      '❌ Use dentro de um ticket.'
    );
  }

  const dados =
    ticketData(
      message.channel.id
    );

  return message.reply({
    embeds: [
      new EmbedBuilder()
        .setTitle(
          `🎫 Resumo — ${message.channel.name}`
        )
        .setColor(
          0xff0033
        )
        .addFields(
          {
            name:
              'Status',
            value:
              dados.status ||
              'open',
            inline:true
          },

          {
            name:
              'Prioridade',
            value:
              dados.prioridade ||
              'normal',
            inline:true
          },

          {
            name:
              'Pagamento',
            value:
              dados.pagamento ||
              'não informado',
            inline:true
          },

          {
            name:
              'Responsável',
            value:
              dados.assumidoPor?.tag ||
              'não assumido',
            inline:true
          },

          {
            name:
              'Tags',
            value:
              dados.tags?.join(
                ', '
              ) ||
              'nenhuma',
            inline:true
          },

          {
            name:
              'Notas',
            value:
              dados.notas?.length
                ? `${dados.notas.length} nota(s)`
                : 'nenhuma',
            inline:true
          }
        )
        .setTimestamp()
    ]
  });
}

// ========================================================
// PAINEL
// ========================================================

if (
  comando ===
  '!painel'
) {
  const row =
    new ActionRowBuilder()
      .addComponents(
        new ButtonBuilder()
          .setCustomId(
            'criar_ticket'
          )
          .setLabel(
            'Criar Ticket'
          )
          .setStyle(
            ButtonStyle.Danger
          )
          .setEmoji('🎫')
      );

  await message
    .delete()
    .catch(
      () => {}
    );

  return message.channel.send({
    content:
      '🎫 **RD4X Hub — Atendimento**\n\n' +
      'Clique abaixo para abrir um ticket e adquirir/renovar seu Painel.',

    components: [
      row
    ]
  });
}

// ========================================================
// AJUDA
// ========================================================

if (
  comando ===
    '!ajuda' ||
  comando ===
    '!help'
) {
  return message.reply({
    embeds: [
      new EmbedBuilder()
        .setTitle(
          '🤖 Central de Ajuda — RD4X Hub'
        )
        .setColor(
          0xff0033
        )
        .setDescription(
          'Comandos para clientes e atendimento.'
        )
        .addFields(
          {
            name:
              '🎫 Atendimento',
            value:
              '`!suporte` — chama a equipe.'
          },

          {
            name:
              '⏳ Seu painel',
            value:
              '`!tempo [nick]` — tempo restante.\n' +
              '`!status [nick]` — situação do painel.'
          },

          {
            name:
              '🛡️ Staff',
            value:
              'Administradores: use `!admin_help` para ver os comandos.'
          }
        )
        .setTimestamp()
    ]
  });
}

// ========================================================
// FECHAR TICKET
// ========================================================

if (
  comando ===
  '!fechar'
) {
  if (
    !message.channel.name.startsWith(
      'ticket-'
    )
  ) {
    return message.reply(
      '❌ Este comando só pode ser usado dentro de um ticket!'
    );
  }

  if (!admin) {
    return message.reply(
      '❌ Apenas a equipe pode fechar tickets.'
    );
  }

  await message
    .reply(
      '🔒 Gerando transcript e encerrando o ticket...'
    );

  let transcriptPath =
    null;

  try {
    const mensagens =
      await message.channel.messages
        .fetch({
          limit:100
        });

    const texto =
      mensagens
        .reverse()
        .map(
          m =>
            `[${m.createdAt.toLocaleString('pt-BR')}] ${m.author.tag}: ${m.content}`
        )
        .join('\n');

    transcriptPath =
      path.join(
        TRANSCRIPT_DIR,
        `transcript-${message.channel.id}-${Date.now()}.txt`
      );

    fs.writeFileSync(
      transcriptPath,
      texto,
      'utf8'
    );

    const attachment =
      new AttachmentBuilder(
        Buffer.from(
          texto,
          'utf8'
        ),
        {
          name:
            path.basename(
              transcriptPath
            )
        }
      );

    const canalLogs =
      message.guild.channels.cache.get(
        ID_CANAL_LOGS
      );

    if (canalLogs) {
      await canalLogs
        .send({
          content:
            `📑 **Transcript:** ${message.channel.name} fechado por **${message.author.tag}**.`,

          files: [
            attachment
          ]
        })
        .catch(
          () => {}
        );
    }

  } catch (e) {
    console.error(
      '[TRANSCRIPT]',
      e
    );
  }

  const dados =
    ticketData(
      message.channel.id
    );

  dados.status =
    'closed';

  dados.closedBy =
    message.author.tag;

  dados.closedAt =
    new Date().toISOString();

  ticketsAtivos.set(
    message.channel.id,
    dados
  );

  audit(
    message.author.tag,
    'ticket_close',
    message.channel.name,
    {
      transcriptPath
    }
  );

  await registrarLogTicket(
    message.guild,
    message.channel.id,
    message.channel.name,
    `<@${message.author.id}>`,
    '🔒 Ticket encerrado e transcript salvo.',
    0xff0033
  );

  syncDB();

  setTimeout(
    async () => {
      ticketsAtivos.delete(
        message.channel.id
      );

      syncDB();

      await message.channel
        .delete()
        .catch(
          () => {}
        );
    },
    3000
  );

  return;
}

}
);
client.on('interactionCreate', async interaction => {
// ============================================================
// INTERAÇÕES
// ============================================================
if (
  interaction.isChatInputCommand() &&
  interaction.commandName === 'dashboard-senha'
) {
  try {

    const code =
  createDashboardCode(
    interaction.user.id
  );

if (!code) {
  return interaction.reply({
    content:
      '❌ Não foi possível gerar a senha do Dashboard.',
    ephemeral: true
  });
}

return interaction.reply({
  content:
    [
      '🔐 **Senha do Dashboard gerada!**',
      '',
      `\`${code}\``,
      '',
      '⚠️ Não compartilhe essa senha.'
    ].join('\n'),
  ephemeral: true
});

  } catch (error) {

    console.error(
      '[DASHBOARD-SENHA]',
      error
    );

    if (
      interaction.replied ||
      interaction.deferred
    ) {
      return interaction.followUp({
        content:
          '❌ Ocorreu um erro ao gerar a senha.',
        ephemeral: true
      });
    }

    return interaction.reply({
      content:
        '❌ Ocorreu um erro ao gerar a senha.',
      ephemeral: true
    });
  }
}
// ============================================================
// GERAR PRODUCT KEY — DASHBOARD
// ============================================================

if (
  interaction.isButton() &&
  interaction.customId ===
    'rd4x_gerar_senha'
) {
  try {
    const discordId =
      String(
        interaction.user.id
      );

    const username =
      interaction.user.globalName ||
      interaction.user.username ||
      null;

    /*
     * Garante que exista o objeto
     * de Product Keys.
     */
    if (
      !db.productKeys ||
      typeof db.productKeys !==
        'object'
    ) {
      db.productKeys = {};
    }

    /*
     * Gera a Key e verifica colisão
     * antes de registrar.
     */
    let productKey = null;
    let productKeyHash = null;

    for (
      let attempt = 0;
      attempt < 10;
      attempt++
    ) {
      const candidate =
        generateProductKey();

      const candidateHash =
        hashProductKey(
          candidate
        );

      if (
        !db.productKeys[
          candidateHash
        ]
      ) {
        productKey =
          candidate;

        productKeyHash =
          candidateHash;

        break;
      }
    }

    /*
     * Falha extremamente improvável,
     * mas não devemos mostrar uma Key
     * que não foi registrada.
     */
    if (
      !productKey ||
      !productKeyHash
    ) {
      console.error(
        '[PRODUCT KEY] Não foi possível gerar uma Key única.'
      );

      return interaction.reply({
        content:
          '❌ Não foi possível gerar sua Key agora. Tente novamente.',
        ephemeral: true
      });
    }

    const agora =
      Date.now();

    /*
     * REGISTRO DA KEY
     *
     * A Key exibida ao usuário é
     * exatamente a Key cujo hash está
     * armazenado neste registro.
     */
    db.productKeys[
      productKeyHash
    ] = {
      discordId:
        discordId,

      username:
        username,

      createdAt:
        agora,

      redeemedAt:
        null,

      expiresAt:
        agora +
        (5 * 60 * 1000),

      sessionExpiresAt:
        null,

      status:
        'active',

      hwid:
        null
    };

    /*
     * Persiste imediatamente.
     *
     * Assim, se o usuário copiar a Key
     * e imediatamente abrir o Dashboard,
     * ela já estará disponível para
     * /api/v2/keys/validate.
     */
    saveDB(true);

    /*
     * Confirma internamente que o registro
     * existe antes de mostrar a Key.
     */
    const registered =
      db.productKeys[
        productKeyHash
      ];

    if (
      !registered ||
      String(
        registered.discordId
      ) !== discordId
    ) {
      console.error(
        '[PRODUCT KEY] Falha ao confirmar registro da Key.'
      );

      delete db.productKeys[
        productKeyHash
      ];

      saveDB(true);

      return interaction.reply({
        content:
          '❌ Ocorreu um erro ao registrar sua Key. Tente novamente.',
        ephemeral: true
      });
    }

    /*
     * Auditoria.
     *
     * Não salvamos a Key em texto puro
     * nos logs/banco de auditoria.
     */
    audit(
      discordId,
      'product_key_generated',
      discordId,
      {
        username,
        keyHash:
          productKeyHash,
        expiresAt:
          registered.expiresAt
      }
    );

    /*
     * Mostra a Key ao usuário.
     *
     * IMPORTANTE:
     * esta é a mesma Key registrada acima.
     */
    return interaction.reply({
      content:
        `🔑 **Sua RD4X Key foi gerada!**\n\n` +
        `\`${productKey}\`\n\n` +
        `⏳ Ela expira em **5 minutos** se não for utilizada.\n` +
        `📋 Copie a Key e cole manualmente no Dashboard.\n\n` +
        `⚠️ Não compartilhe esta Key com ninguém.`,
      ephemeral: true
    });

  } catch (error) {
    console.error(
      '[PRODUCT KEY] Erro ao gerar Key:',
      error
    );

    /*
     * Não exibimos detalhes internos
     * do erro ao usuário.
     */
    if (
      !interaction.replied &&
      !interaction.deferred
    ) {
      return interaction.reply({
        content:
          '❌ Não foi possível gerar sua Key agora. Tente novamente.',
        ephemeral: true
      });
    }
  }
}

// código atual de criação do ticket...

    if (
      interaction.customId !== 'criar_ticket'
    ) {
      return;
    }

    // código atual de criação do ticket...
  const guild =
  interaction.guild;

const member =
  interaction.member;

const agora =
  new Date();

const horas =
  (
    agora.getUTCHours() -
    3 +
    24
  ) % 24;

if (
  horas < 6 ||
  horas >= 22
) {
  return interaction.reply({
    content:
      '🌙 **Atendimento encerrado.** Funcionamento: **06:00 às 22:00**.',

    ephemeral:true
  });
}

const ultimo =
  Number(
    cooldownTickets.get(
      member.id
    ) || 0
  );

const restante =
  60000 -
  (
    Date.now() -
    ultimo
  );

if (
  ultimo &&
  restante > 0
) {
  return interaction.reply({
    content:
      `⏳ Aguarde **${Math.ceil(restante / 1000)} segundos** para abrir outro ticket.`,

    ephemeral:true
  });
}

if (
  blacklist.has(
    member.user.username
  ) ||
  blacklist.has(
    member.id
  )
) {
  return interaction.reply({
    content:
      '❌ Você está bloqueado de abrir tickets.',

    ephemeral:true
  });
}

const nomeCanal =
  `ticket-${member.user.username}`
    .toLowerCase();

const existente =
  guild.channels.cache.find(
    c =>
      c.name ===
      nomeCanal
  );

if (existente) {
  return interaction.reply({
    content:
      `❌ Você já possui um ticket aberto: ${existente}`,

    ephemeral:true
  });
}

cooldownTickets.set(
  member.id,
  Date.now()
);

const parentCategory =
  interaction.channel.parentId;

const channel =
  await guild.channels.create({
    name:
      nomeCanal,

    type:
      ChannelType.GuildText,

    parent:
      parentCategory,

    permissionOverwrites: [
      {
        id:
          guild.id,

        deny: [
          PermissionFlagsBits.ViewChannel
        ]
      },

      {
        id:
          member.id,

        allow: [
          PermissionFlagsBits.ViewChannel,
          PermissionFlagsBits.SendMessages,
          PermissionFlagsBits.ReadMessageHistory
        ]
      },

      {
        id:
          ID_DONO,

        allow: [
          PermissionFlagsBits.ViewChannel,
          PermissionFlagsBits.SendMessages,
          PermissionFlagsBits.ReadMessageHistory
        ]
      },

      {
        id:
          ID_CARGO_ADMIN,

        allow: [
          PermissionFlagsBits.ViewChannel,
          PermissionFlagsBits.SendMessages,
          PermissionFlagsBits.ReadMessageHistory
        ]
      }
    ]
  });

ticketsAtivos.set(
  channel.id,
  {
    userId:
      member.id,

    username:
      member.user.username,

    status:
      'aberto',

    prioridade:
      'normal',

    pagamento:
      'aguardando_comprovante',

    tags:[
      'venda'
    ],

    notas:[],

    logs:[],

    ultimoContato:
      Date.now(),

    avisoInatividade:
      false
  }
);

syncDB();

await channel.send({
  content:
    `<@${member.user.id}>\n\n` +
    `💳 **Para adquirir seu Painel Admin**\n\n` +
    `Envie o PIX para:\n` +
    `\`${CHAVE_PIX}\`\n\n` +
    `Depois envie seu **nick do Roblox**, **plano/duração** e o **comprovante de pagamento**.`,

  allowedMentions:{
    users:[
      member.user.id
    ]
  }
});

await channel.send({
  content:
    `Aguarde a análise do comprovante. <@&${ID_CARGO_ADMIN}>`,

  allowedMentions:{
    roles:[
      ID_CARGO_ADMIN
    ]
  }
});

await registrarLogTicket(
  guild,
  channel.id,
  nomeCanal,
  `<@${member.id}>`,
  '🟢 Ticket criado pelo cliente.',
  0xff0033
);

audit(
  member.user.tag,
  'ticket_create',
  channel.id
);

return interaction.reply({
  content:
    `✅ Ticket criado: ${channel}`,

  ephemeral:true
});

}
);

// ============================================================
// ENCERRAMENTO SEGURO
// ============================================================

for (
const sig of [
'SIGINT',
'SIGTERM'
]
) {
process.on(
sig,
() => {
try {
syncDB();
saveDB(true);
} finally {
process.exit(0);
}
}
);
}

// ============================================================
// LOGIN
// ============================================================

client.login(
process.env.DISCORD_TOKEN
);
