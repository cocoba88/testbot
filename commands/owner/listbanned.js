const {
    quote
} = require("@mengkodingan/ckptw");
const {
    S_WHATSAPP_NET
} = require("@whiskeysockets/baileys");

module.exports = {
    name: "listbanned",
    aliases: ["listban"],
    category: "owner",
    code: async (ctx) => {
        const {
            status,
            message
        } = await global.handler(ctx, {
            owner: true
        });
        if (status) return ctx.reply(message);

        try {
            const databaseJSON = JSON.stringify(global.db);
            const parsedDB = JSON.parse(databaseJSON);
            const users = parsedDB.user;
            const bannedUsers = [];

            for (const userId in users) {
                if (users[userId].isBanned === true) bannedUsers.push(userId);
            }

            let resultText = "";
            let userMentions = [];

            bannedUsers.forEach((userId) => {
                resultText += `${quote(`@${userId}`)}\n`;
            });

            bannedUsers.forEach((userId) => {
                userMentions.push(userId + S_WHATSAPP_NET);
            });

            return ctx.reply({
                text: `${resultText}` +
                    "\n" +
                    global.config.msg.footer,
                mentions: userMentions
            });
        } catch (error) {
            console.error(`[${global.config.pkg.name}] Error:`, error);
            return ctx.reply(quote(`❎ Terjadi kesalahan: ${error.message}`));
        }
    }
};