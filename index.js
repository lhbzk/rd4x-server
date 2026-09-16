const { Client, GatewayIntentBits, ActionRowBuilder, ButtonBuilder, ButtonStyle, ChannelType, PermissionsBitField, MessageFlags } = require('discord.js');

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

// Guardar o estado do ticket por ID do Tópico/Canal
const etapasTicket = {};

client.on('ready', () => {
    console.log(`Bot online como: ${client.user.tag}`);
});

client.on('messageCreate', async (message) => {
    if (message.author.bot || !message.guild) return;

    // 1. Comando para enviar o Painel com o Botão de Atendimento
    if (message.content.toLowerCase() === '!painel') {
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

    // 2. Fluxo de conversa DENTRO do tópico criado
    const canalId = message.channel.id;

    if (etapasTicket[canalId] === 'AGUARDANDO_DADOS') {
        delete etapasTicket[canalId];

        // Busca os cargos de Dono e ADM no servidor pelo nome exato
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

    // 3. Comando para encerrar o tópico
    if (message.content.toLowerCase() === '!encerrar') {
        if (message.channel.isThread()) {
            await message.channel.send('🔒 Encerrando e deletando este tópico em 5 segundos...');
            setTimeout(() => {
                message.channel.delete().catch(err => console.error("Erro ao deletar tópico:", err));
            }, 5000);
        } else {
            message.reply('Este comando só pode ser usado dentro de um tópico de atendimento!');
        }
    }
});

// Resposta ao clique do botão
client.on('interactionCreate', async (interaction) => {
    if (!interaction.isButton()) return;

    if (interaction.customId === 'abrir_ticket') {
        try {
            // CRIAR TÓPICO PRIVADO dentro do próprio canal onde está o painel
            const topico = await interaction.channel.threads.create({
                name: `ticket-${interaction.user.username}`,
                autoArchiveDuration: 1440, // 24 horas de inatividade
                type: ChannelType.PrivateThread, // Tópico privado (não cria canal externo)
                reason: 'Atendimento de Compra VIP'
            });

            // Adiciona o usuário que clicou ao tópico
            await topico.members.add(interaction.user.id);

            // Marca que este tópico está aguardando o envio do comprovante/nick
            etapasTicket[topico.id] = 'AGUARDANDO_DADOS';

            // Envia a instrução inicial dentro do tópico
            await topico.send(
                `Olá ${interaction.user}! Bem-vindo ao seu ticket.\nPor favor, envie o **comprovante do Pix** e o seu **Nick do Roblox** aqui!`
            );

            // Responde ao clique com aviso discreto
            await interaction.reply({
                content: `Seu atendimento foi aberto! Acesse o tópico: ${topico}`,
                flags: MessageFlags.Ephemeral
            });

        } catch (error) {
            console.error('Erro ao criar tópico:', error);
            await interaction.reply({
                content: 'Houve um erro ao criar seu atendimento. Verifique se o bot tem permissão de "Criar Tópicos Privados".',
                flags: MessageFlags.Ephemeral
            });
        }
    }
});

client.login(process.env.DISCORD_TOKEN);
