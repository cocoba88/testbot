const {
    quote
} = require("@mengkodingan/ckptw");

module.exports = {
    name: "about",
    category: "information",
    code: async (ctx) => {
        const {
            status,
            message
        } = await global.handler(ctx, {
            cooldown: true
        });
        if (status) return ctx.reply(message);

        return ctx.reply(
            `Halo! Saya adalah Bot WhatsApp bernama ${global.config.bot.name}, dimiliki oleh ${global.config.owner.name}. Saya bisa melakukan banyak perintah, seperti membuat stiker, menggunakan AI untuk pekerjaan tertentu, dan beberapa perintah berguna lainnya. Saya di sini untuk menghibur dan menyenangkan Anda!`
        ); // Dapat diubah sesuai keinginan Anda.
    }
};