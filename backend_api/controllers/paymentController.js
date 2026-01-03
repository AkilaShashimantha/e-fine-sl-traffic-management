const md5 = require('md5');

const generateHash = (req, res) => {
    try {
        const { order_id, amount, currency } = req.body;

        const merchantSecret = process.env.PAYHERE_SECRET;
        const merchantId = process.env.PAYHERE_MERCHANT_ID;

        if (!merchantSecret || !merchantId) {
            return res.status(500).json({ error: "PayHere credentials missing in .env" });
        }

        // 1. Merchant Secret එක Hash කරනවා (md5)
        const hashedSecret = md5(merchantSecret).toUpperCase();

        // 2. Amount එක format කරනවා (දශම ස්ථාන 2ක් තියෙන්න ඕනේ, කොමා නැතුව)
        // උදා: 1000 -> 1000.00
        let amountFormatted = parseFloat(amount).toFixed(2);

        // 3. අනිත් දත්ත එකතු කරලා ආයේ Hash කරනවා (PayHere Formula)
        // Formula: md5(merchant_id + order_id + amount + currency + hashedSecret)
        const hashString = merchantId + order_id + amountFormatted + currency + hashedSecret;
        const finalHash = md5(hashString).toUpperCase();

        res.json({ hash: finalHash });
    } catch (error) {
        console.error("Hash Gen Error:", error);
        res.status(500).json({ error: "Hash generation failed" });
    }
};

module.exports = { generateHash };
