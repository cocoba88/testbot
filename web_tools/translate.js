const {
    quote
} = require("@mengkodingan/ckptw");
const axios = require("axios");

module.exports = {
    name: "translate",
    aliases: ["tr"],
    category: "web_tools",
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

        let textToTranslate = ctx.args.join(" ") || null;
        let langCode = "id";

        if (ctx.quoted.caption || ctx.quoted.text) {
            const quotedMessage = ctx.quoted;
            textToTranslate = Object.values(quotedMessage).find(msg => msg.caption || msg.text)?.caption || textToTranslate || null;

            if (ctx.args[0] && ctx.args[0].length === 2) langCode = ctx.args[0];
        } else {
            if (ctx.args[0] && ctx.args[0].length === 2) {
                langCode = ctx.args[0];
                textToTranslate = textToTranslate ? textToTranslate : ctx.args.slice(1).join(" ");
            }
        }

        if (!textToTranslate) return ctx.reply(
            `${quote(global.tools.msg.generateInstruction(["send"], ["text"]))}\n` +
            quote(global.tools.msg.generateCommandExample(ctx._used.prefix + ctx._used.command, "en halo dunia!"))
        );

        try {
            const translation = await global.tools.general.translate(textToTranslate, langCode);

            return ctx.reply(translation);
        } catch (error) {
            console.error(`[${global.config.pkg.name}] Error:`, error);
            if (error.status !== 200) return ctx.reply(global.config.msg.notFound);
            return ctx.reply(quote(`❎ Terjadi kesalahan: ${error.message}`));
        }
    }
};