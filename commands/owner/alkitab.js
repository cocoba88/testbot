const {
    monospace,
    quote
} = require("@mengkodingan/ckptw");
const axios = require("axios");

module.exports = {
    name: "alkitab",
    aliases: ["injil"],
    category: "tools",
    code: async (ctx) => {
        const {
            status,
            message
        } = await global.handler(ctx, {
            banned: true,
            cooldown: true,
            coin: [10, "text", 1]
        });
        if (status) return ctx.reply(message);

        const [abbr, chapter] = ctx.args;

        if (!ctx.args.length) return ctx.reply(
            `${quote(`${global.tools.msg.generateInstruction(["send"], ["text"])} Bingung? Ketik ${monospace(`${ctx._used.prefix + ctx._used.command} list`)} untuk melihat daftar.`)}\n` +
            quote(global.tools.msg.generateCommandExample(ctx._used.prefix + ctx._used.command, "kej 2:18"))
        );

        if (ctx.args[0] === "list") {
            const listText = await global.tools.list.get("alkitab");
            return ctx.reply(listText);
        }

        try {
            const apiUrl = await global.tools.api.createUrl("https://beeble.vercel.app", `/api/v1/passage/${abbr}/${chapter}`, {});
            const {
                data
            } = (await axios.get(apiUrl)).data;

            const resultText = data.verses.map((d) =>
                `${quote(`Ayat: ${d.verse}`)}\n` +
                `${quote(`${d.content}`)}`
            ).join(
                "\n" +
                `${quote("─────")}\n`
            );
            return ctx.reply(
                `${quote(`Nama: ${data.book.name}`)}\n` +
                `${quote(`Bab: ${data.book.chapter}`)}\n` +
                `${quote("─────")}\n` +
                `${resultText}\n` +
                "\n" +
                global.config.msg.footer
            );
        } catch (error) {
            console.error(`[${global.config.pkg.name}] Error:`, error);
            if (error.status !== 200) return ctx.reply(global.config.msg.notFound);
            return ctx.reply(quote(`❎ Terjadi kesalahan: ${error.message}`));
        }
    }
};