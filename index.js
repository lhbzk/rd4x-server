const express = require('express');
const app = express();

app.use(express.json());

const filaComandos = {};
const LISTA_VIP = [4200878493]; // Seu ID do Roblox

app.post('/enviar-comando', (req, res) => {
    const { autorId, alvoNome, comando } = req.body;

    if (!autorId || !alvoNome || !comando) {
        return res.status(400).json({ erro: "Dados incompletos" });
    }

    if (!LISTA_VIP.includes(Number(autorId))) {
        return res.status(403).json({ erro: "Acesso negado. Você não é VIP." });
    }

    if (!filaComandos[alvoNome]) {
        filaComandos[alvoNome] = [];
    }

    filaComandos[alvoNome].push(comando);
    return res.json({ sucesso: true, mensagem: `Comando ${comando} enviado para ${alvoNome}` });
});

app.get('/checar-comando/:nome', (req, res) => {
    const nomeJogador = req.params.nome;

    if (filaComandos[nomeJogador] && filaComandos[nomeJogador].length > 0) {
        const proximoComando = filaComandos[nomeJogador].shift();
        return res.json({ temComando: true, comando: proximoComando });
    }

    return res.json({ temComando: false });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Servidor rodando na porta ${PORT}`));
         
