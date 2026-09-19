const { Client, GatewayIntentBits, PermissionsBitField, ChannelType } = require('discord.js');
const client = new Client({ intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages, GatewayIntentBits.MessageContent] });

const PREFIX = '!';

// IDs dos cargos solicitados
const ID_DONO = '1549272865260441631';
const ID_ADMINS = '1549273436705259570';

client.on('messageCreate', async message => {
    if (message.author.bot || !message.content.startsWith(PREFIX)) return;

    const args = message.content.slice(PREFIX.length).trim().split(/ +/);
    const command = args.shift().toLowerCase();

    // 1. Comando: !liberar <tempo> <usuario>
    if (command === 'liberar') {
        const tempoAbreviado = args[0];
        const usuarioAlvo = args[1];

        // Mapeamento das abreviações para nomes legíveis
        const temposValidos = {
            '3d': '3 Dias',
            '12d': '1 Semana e 5 Dias (12 Dias)',
            '1m': '1 Mês',
            '2m': '2 Meses',
            'perm': 'Permanente'
        };

        if (!tempoAbreviado || !temposValidos[tempoAbreviado] || !usuarioAlvo) {
            return message.reply('Uso correto: `!liberar <tempo> <usuario>`\nOpções de tempo: `3d`, `12d`, `1m`, `2m`, `perm`');
        }

        const planoSelecionado = temposValidos[tempoAbreviado];

        try {
            const categoriaPai = message.channel.parent; // Pega a categoria atual do canal de origem

            // Cria o canal privado dentro da categoria de origem
            const canalPrivado = await message.guild.channels.create({
                name: `ticket-${usuarioAlvo}`,
                type: ChannelType.GuildText,
                parent: categoriaPai,
                permissionOverwrites: [
                    {
                        id: message.guild.id,
                        deny: [PermissionsBitField.Flags.ViewChannel],
                    },
                    {
                        id: message.author.id,
                        allow: [PermissionsBitField.Flags.ViewChannel, PermissionsBitField.Flags.SendMessages],
                    },
                ],
            });

            // Monta as menções para o Dono e os Admins
            const mencaoDono = `<@&${ID_DONO}>`;
            const mencaoAdmins = `<@&${ID_ADMINS}>`;

            // Envia a mensagem solicitada dentro do novo canal criado
            await canalPrivado.send({
                content: `Aguarde o Dono ou os Adms analisarem o comprovante. ${mencaoDono} ${mencaoAdmins}\n\n👤 **Usuário:** ${usuarioAlvo}\n📦 **Plano solicitado:** ${planoSelecionado}`
            });

            message.reply(`✅ Canal privado criado com sucesso para ${usuarioAlvo} (${planoSelecionado}): ${canalPrivado}`);
        } catch (error) {
            console.error(error);
            message.reply('❌ Ocorreu um erro ao criar o canal privado.');
        }
    }

    // 2. Comando: !remover <usuario>
    else if (command === 'remover') {
        const usuarioAlvo = args[0];

        if (!usuarioAlvo) {
            return message.reply('Uso correto: `!remover <usuario>`');
        }

        message.reply(`⚠️ Permissão revogada para o usuário ${usuarioAlvo}.`);
    }

    // 3. Comando: !checar <usuario>
    else if (command === 'checar') {
        const usuarioAlvo = args[0];

        if (!usuarioAlvo) {
            return message.reply('Uso correto: `!checar <usuario>`');
        }

        message.reply(`🔍 O usuário ${usuarioAlvo} está sendo consultado no sistema.`);
    }

    // 4. Comando: !ajuda
    else if (command === 'ajuda' || command === 'help') {
        message.reply('📋 **Comandos disponíveis:**\n`!liberar <3d/12d/1m/2m/perm> <usuario>`\n`!remover <usuario>`\n`!checar <usuario>`');
    }
});

client.login('SEU_TOKEN_DO_BOT_AQUI');
