const {
    youtubedl
} = require("@bochilteam/scraper-sosmed");
const {
    quote
} = require("@mengkodingan/ckptw");
const axios = require("axios");
const mime = require("mime-types");

module.exports = {
    name: "play",
    aliases: ["p"],
    category: "downloader",
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

        const input = ctx.args.join(" ") || null;

        if (!input) return ctx.reply(
            `${quote(global.tools.msg.generateInstruction(["send"], ["text"]))}\n` +
            quote(global.tools.msg.generateCommandExample(ctx._used.prefix + ctx._used.command, "hikaru utada - one last kiss"))
        );

        try {
            const searchApiUrl = global.tools.api.createUrl("agatz", "/api/ytsearch", {
                message: input
            });
            const searchResponse = await axios.get(searchApiUrl);
            const searchData = searchResponse.data.data[0];

            if (!searchData) return ctx.reply(global.config.msg.notFound);

            const data = searchData;

           

            const ytdlResponse = await youtubedl(data.url);
            const audioInfo = Object.values(ytdlResponse.audio)[0];
            const audioUrl = await audioInfo.download();

            if (!audioUrl) return ctx.reply(global.config.msg.notFound);

            return await ctx.reply({
                audio: {
                    url: audioUrl
                },
                mimetype: mime.contentType("mp3"),
                ptt: true
            });
        } catch (error) {
            console.error(`[${global.config.pkg.name}] Error:`, error);
            if (error.status !== 200) return ctx.reply(global.config.msg.notFound);
            return ctx.reply(quote(`❎ Terjadi kesalahan: ${error.message}`));
        }
    }
};