const {
    quote
} = require("@mengkodingan/ckptw");
const axios = require("axios");
const os = require("os");

module.exports = {
    name: "server",
    category: "information",
    code: async (ctx) => {
        const apiUrl = global.tools.api.createUrl("http://ip-api.com", "/json", {});

        try {
            const {
                data
            } = await axios.get(apiUrl);
            const startTime = global.config.bot.readyAt;

            return ctx.reply(
                `${quote(`OS: ${os.type()} (${os.arch()} / ${os.release()})`)}\n` +
                `${quote(`RAM: ${global.tools.general.formatSize(process.memoryUsage().rss)} / ${global.tools.general.formatSize(os.totalmem())}`)}\n` +
                Object.entries(data).map(([key, value]) => `${quote(`${global.tools.general.ucword(key)}: ${value}`)}\n`).join("") +
                `${quote(`Waktu aktif: ${global.tools.general.convertMsToDuration(Date.now() - startTime)}`)}\n` +
                `${quote(`Prosesor: ${os.cpus()[0].model}`)}\n` +
                "\n" +
                global.config.msg.footer
            );
        } catch (error) {
            console.error(`[${global.config.pkg.name}] Error:`, error);
            return ctx.reply(quote(`❎ Terjadi kesalahan: ${error.message}`));
        }
    }
};