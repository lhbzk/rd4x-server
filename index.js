const express = require('express');
const fs = require('fs');
const app = express();

app.use(express.json());

const VIP_FILE = './vips.json';

// Função para ler a lista de VIPs
function getVips() {
    if (!fs.existsSync(VIP_FILE)) {
        fs.writeFileSync(VIP_FILE, JSON.stringify([]));
    }
    return JSON.parse(fs.readFileSync(VIP_FILE, 'utf-8'));
}

// Função para salvar a lista de VIPs
function saveVips(vips) {
    fs.writeFileSync(VIP_FILE, JSON.stringify(vips, null, 2));
}

// 1. Rota para o Script do Roblox CHECAR se a pessoa é VIP
app.get('/check-vip', (req, res) => {
    const userId = req.query.id;
    if (!userId) return res.json({ vip: false, reason: "ID não fornecido" });

    const vips = getVips();
    const isVip = vips.includes(String(userId));

    return res.json({ vip: isVip });
});

// 2. Rota para o Bot do Discord ADICIONAR um novo VIP
app.post('/add-vip', (req, res) => {
    const { userId, secretKey } = req.body;

    // Senha de segurança para ninguém adicionar VIP sem autorização
    if (secretKey !== "SUA_CHAVE_SECRETA_AQUI") {
        return res.status(403).json({ success: false, message: "Acesso negado!" });
    }

    if (!userId) return res.status(400).json({ success: false, message: "ID inválido!" });

    let vips = getVips();
    if (!vips.includes(String(userId))) {
        vips.push(String(userId));
        saveVips(vips);
    }

    return res.json({ success: true, message: `ID ${userId} adicionado ao VIP!` });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Servidor rodando na porta ${PORT}`));
