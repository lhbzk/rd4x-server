const etapasTicket = {};

client.on('messageCreate', async (message) => {
    if (message.author.bot) return;

    const canalId = message.channel.id;

    // 1. Inicia o pedido de dados no ticket
    if (message.content.toLowerCase() === '!dados') {
        etapasTicket[canalId] = 'AGUARDANDO_COMPROVANTE';
        return message.reply('Por favor, envie o **comprovante** e o seu **Nick** aqui no chat!');
    }

    // 2. Resposta do jogador com o comprovante e Nick
    if (etapasTicket[canalId] === 'AGUARDANDO_COMPROVANTE') {
        delete etapasTicket[canalId];

        // O bot procura os cargos no servidor pelo nome exato
        const cargoDono = message.guild.roles.cache.find(role => role.name === '👑 𝘿𝙊𝙉𝙊');
        const cargoAdm = message.guild.roles.cache.find(role => role.name === '🛡️𝐀𝐃𝐌');

        // Cria a mensagem de marcação
        let mencoes = '';
        if (cargoDono) mencoes += `${cargoDono} `;
        if (cargoAdm) mencoes += `${cargoAdm}`;

        await message.channel.send(
            `Aguarde a confirmação do Dono ou dos Adms. ${mencoes}`
        );
        return;
    }

    // 3. Comando para encerrar o ticket
    if (message.content.toLowerCase() === '!encerrar') {
        await message.channel.send('🔒 Encerrando e apagando este ticket em 5 segundos...');

        setTimeout(() => {
            message.channel.delete().catch(err => console.error("Erro ao deletar:", err));
        }, 5000);
    }
});
