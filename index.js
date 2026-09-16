const express = require('express');
const { 
    Client, 
    GatewayIntentBits, 
    ActionRowBuilder, 
    ButtonBuilder, 
    ButtonStyle, 
    ChannelType, 
    MessageFlags 
} = require('discord.js');

const app = express();
app.use(express.json());

// -----------------------------------------------------------------------------
// BANCO DE DADOS EM MEMÓRIA
// -----------------------------------------------------------------------------
const database = {};

function getUserData(username) {
    if (!database[username]) {
        database[username] = { xp: 0, isVipManual: false };
    }
    return database[username];
}

// Controle de etapas dos tickets abertos por tópicos
const etapasTicket = {};

// -----------------------------------------------------------------------------
// ROTAS DA API REST (PARA O ROBLOX / CRAFTLAND)
// -----------------------------------------------------------------------------

// Rota padrão para manter o serviço ativo no Render
app.get('/', (req, res) => {
    res.send('API RD4X Hub está online!');
});

// Consulta status VIP e progresso de XP do jogador
app.get('/checar-vip/:user', (req, res) => {
    const user = getUserData(req.params.user);
    const xp = user.xp;
    
    let role = "User";
    let isVip = user.isVipManual || false;

    if (isVip || xp >= 200000) {
        isVip = true;
        role = "VIP PERM";
    } else if (xp >= 150000) {
        role = "Quase Lenda";
    } else if (xp >= 100000) {
        role = "User [Degustação VIP 1 Semana]";
    } else if (xp >= 50000) {
        role = "User [Degustação VIP 5 Dias]";
    } else if (xp >= 25000) {
        role = "User Dedicado";
    }

    res.json({ 
        vip: isVip, 
        role: role, 
        xp: xp,
        faltaParaVip: isVip ? 0 : Math.max(0, 200000 - xp)
    });
});

// Rota para adicionar XP via execução/ações
app.post('/add-xp', (req, res) => {
    const { username, xpAmount } = req.body;
    if (!username || !xpAmount) return res.status(400).json({ error: "Dados inválidos." });

    const user = getUserData(username);
    user.xp += parseInt(xpAmount);
    
    res.json({ success: true, novoXP: user.xp });
});

// Rota para zerar trajetória em caso de auto-click
app.post('/reset-xp', (req, res) => {
    const { username } = req.body;
    if (!username) return res.status(400).json({ error: "Usuário não informado." });

    const user = getUserData(username);
    user.xp = 0;
    user.isVipManual = false;

    res.json({ success: true, message: "Trajetória zerada por auto-click.", novoXP: 0 });
});

// Rota HTTP direta para liberação manual de VIP
app.post('/liberar-vip', (req, res) => {
    const { username } = req.body;
    if (!username) return res.status(400).json({ error: "Informe o Nick." });

    let user = getUserData(username);
    user.isVipManual = true;

    res.json({ success: true, message: `VIP ativado com sucesso para ${username}` });
});

// Rota de logs do Roblox
app.post('/log', (req, res) => {
    const { usuario, acao, detalhes } = req.body;
    console.log(`[ROBLOX LOG] ${usuario} executou: ${acao} - ${detalhes}`);
    res.json({ status: 'sucesso', message: 'Log registrado' });
});

// -----------------------------------------------------------------------------
// BOT DO DISCORD
// -----------------------------------------------------------------------------
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

client.once('ready', () => {
    console.log(`🤖 Bot do RD4X Hub online como: ${client.user.tag}`);
});

// GERENCIAMENTO DE MENSAGENS E COMANDOS
client.on('messageCreate', async (message) => {
    if (message.author.bot || !message.guild) return;

    const args = message.content.trim().split(/ +/);
    const comando = args[0].toLowerCase();
    const canalId = message.channel.id;

    // 1. COMANDO !painel (Envia a mensagem com botão de Ticket)
    if (comando === '!painel') {
        if (!message.member.permissions.has('Administrator')) {
            return message.reply('❌ Apenas administradores podem enviar o painel.');
        }

        const row = new ActionRowBuilder().addComponents(
            new ButtonBuilder()
                .setCustomId('abrir_ticket')
                .setLabel('Comprar VIP')
                .setStyle(ButtonStyle.Success)
                .setEmoji('🛒')
        );

        await message.channel.send({
            content: '### 🚀 **RD4X Hub - Atendimento VIP**\nClique no botão abaixo para abrir seu atendimento privado diretamente aqui!',
            components: [row]
        });
        return;
    }

    // 2. FLUXO DE RESPOSTA DENTRO DO TÓPICO DE TICKET ABETO
    if (etapasTicket[canalId] === 'AGUARDANDO_DADOS') {
        delete etapasTicket[canalId];

        // Busca os cargos para marcar a equipe no tópico
        const cargoDono = message.guild.roles.cache.find(role => role.name === '👑 𝘿𝙊𝙉𝙊');
        const cargoAdm = message.guild.roles.cache.find(role => role.name === '🛡️𝐀𝐃𝐌');

        let mencoes = '';
        if (cargoDono) mencoes += `${cargoDono} `;
        if (cargoAdm) mencoes += `${cargoAdm}`;

        await message.channel.send(
            `✅ **Dados recebidos com sucesso!**\n\nAguarde a confirmação da equipe. ${mencoes}`
        );
        return;
    }

    // 3. COMANDOS DE LIBERAÇÃO DE VIP (!liberar)
    if (comando === '!liberar') {
        if (!message.member.permissions.has('Administrator')) {
            return message.reply('❌ Você não tem permissão para usar este comando.');
        }

        const subComando = args[1] ? args[1].toLowerCase() : null;
        const nickPlayer = args[2];

        if (!subComando || !nickPlayer) {
            return message.reply('❌ **Uso incorreto!** Sintaxe:\n`!liberar perm <nick>`\n`!liberar 1semana <nick>`\n`!liberar 5dias <nick>`\n`!liberar dedicado <nick>`');
        }

        let user = getUserData(nickPlayer);

        if (subComando === 'perm') {
            user.isVipManual = true;
            return message.reply(`👑 **VIP Permanente** ativado com sucesso para **${nickPlayer}**!`);
        } else if (subComando === '1semana') {
            user.xp = Math.max(user.xp, 100000);
            return message.reply(`🎉 **Degustação VIP de 1 Semana** (100.000 XP) liberada para **${nickPlayer}**!`);
        } else if (subComando === '5dias') {
            user.xp = Math.max(user.xp, 50000);
            return message.reply(`🎁 **Degustação VIP de 5 Dias** (50.000 XP) liberada para **${nickPlayer}**!`);
        } else if (subComando === 'dedicado') {
            user.xp = Math.max(user.xp, 25000);
            return message.reply(`⭐ Cargo **Usuário Dedicado** (25.000 XP) liberado para **${nickPlayer}**!`);
        } else {
            return message.reply('❌ Opção inválida! Escolha: `perm`, `1semana`, `5dias` ou `dedicado`.');
        }
    }

    // 4. COMANDO !encerrar (Apaga o ticket ou tópico)
    if (comando === '!encerrar') {
        if (!message.member.permissions.has('ManageChannels')) {
            return message.reply('❌ Você não tem permissão para encerrar este canal.');
        }

        await message.reply('🔒 Encerrando e apagando este ticket em 5 segundos...');
        setTimeout(() => {
            message.channel.delete().catch(err => console.error("Erro ao apagar canal:", err));
        }, 5000);
    }
});

// INTERAÇÃO AO CLICAR NO BOTÃO DE COMPRAR VIP
client.on('interactionCreate', async (interaction) => {
    if (!interaction.isButton()) return;

    if (interaction.customId === 'abrir_ticket') {
        try {
            // Cria um Tópico Privado dentro do canal onde o painel foi enviado
            const topico = await interaction.channel.threads.create({
                name: `ticket-${interaction.user.username}`,
                autoArchiveDuration: 1440, // 24 horas
                type: ChannelType.PrivateThread,
                reason: 'Atendimento de Compra VIP'
            });

            // Adiciona o comprador ao tópico
            await topico.members.add(interaction.user.id);

            // Marca que o tópico está aguardando o envio do comprovante/nick
            etapasTicket[topico.id] = 'AGUARDANDO_DADOS';

            // Envia mensagem inicial no tópico
            await topico.send(
                `Olá ${interaction.user}! Bem-vindo ao seu ticket de compra VIP.\nPor favor, envie aqui o **comprovante do Pix** e o seu **Nick do Roblox**!`
            );

            // Responde para o usuário com um aviso privado (Ephemeral)
            await interaction.reply({
                content: `Seu atendimento foi aberto com sucesso! Acesse o tópico: ${topico}`,
                flags: MessageFlags.Ephemeral
            });

        } catch (error) {
            console.error('Erro ao criar tópico:', error);
            await interaction.reply({
                content: 'Houve um erro ao criar seu atendimento. Verifique se o bot tem a permissão "Criar Tópicos Privados".',
                flags: MessageFlags.Ephemeral
            });
        }
    }
});

// -----------------------------------------------------------------------------
// INICIALIZAÇÃO DO SERVIDOR WEB E BOT DISCORD
// -----------------------------------------------------------------------------
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});

if (process.env.DISCORD_TOKEN) {
    client.login(process.env.DISCORD_TOKEN);
}
