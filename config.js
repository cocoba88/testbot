const pkg = require("./package.json");
const {
    monospace,
    italic,
    quote
} = require("@mengkodingan/ckptw");

// Bot.
global.config = {
    bot: {
        name: "boTai",
        prefix: /^[°•π÷×¶∆£¢€¥®™+✓_=|/~!?@#%^&.©^]/i,
        phoneNumber: "6287854163981", // Abaikan jika Anda menggunakan kode QR untuk otentikasi.
        picture: {
            thumbnail: "https://widipe.com/file/KU00bdkMDCoq.jpg",
            profile: "https://widipe.com/file/ZqD0Nv3Mpr67.png"
        },
        groupChat: "https://wa.me/settings" // Jangan lupa untuk bergabung ya teman-teman!
    },

    // MSG (Pesan).
    msg: {
        // Akses perintah.
        admin: quote("❎ Perintah hanya dapat diakses oleh admin grup!"),
        banned: quote("❎ Tidak dapat memproses karena Anda telah dibanned!"),
        botAdmin: quote("❎ Bot bukan admin, tidak bisa menggunakan perintah!"),
        cooldown: quote("❎ Perintah ini sedang dalam cooldown, tunggu..."),
        coin: quote("❎ Anda tidak punya cukup koin!"),
        group: quote("❎ Perintah hanya dapat diakses dalam grup!"),
        owner: quote("❎ Perintah hanya dapat diakses Owner!"),
        premium: quote("❎ Anda bukan pengguna Premium!"),
        private: quote("❎ Perintah hanya dapat diakses dalam obrolan pribadi!"),
        restrict: quote("❎ Perintah ini telah dibatasi karena alasan keamanan!"),

        // Antarmuka perintah.
        watermark: `${pkg.name}@^${pkg.version}`,
        footer: italic("🤡"),
        readmore: "\u200E".repeat(4001),

        // Proses perintah.
        wait: quote("🔄 Tunggu sebentar..."),
        notFound: quote("❎ Tidak ada yang ditemukan!"),
        urlInvalid: quote("❎ URL tidak valid!")
    },

    // Owner & CoOwner.
    owner: {
        name: "indra",
        number: "6289628608383",
        organization: "Mushroom Kingdom",
        co: ["6285378444386"]
    },

    // Stiker.
    sticker: {
        packname: "Duarrrr",
        author: "Nmaxxxxx"
    },

    // Sistem.
    system: {
        autoRead: true,
        cooldown: 5000,
        restrict: true, // Membatasi beberapa perintah yang akan mengakibatkan banned.
        selfReply: true,
        timeZone: "Asia/Jakarta",
        useInteractiveMessage: true,
        usePairingCode: true
    }
};