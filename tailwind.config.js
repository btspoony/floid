module.exports = {
  content: ["./src/**/*.{js,ts,vue}"],
  purge: {
    enabled: process.env.NODE_ENV === "production",
    layers: ["components", "utilities"],
    content: [
      "./src/composables/**/*.{js,ts}",
      "./src/components/**/*.vue",
      "./src/layouts/**/*.vue",
      "./src/pages/**/*.vue",
      "./src/plugins/**/*.{js,ts}",
      "./src/nuxt.config.{js,ts}",
    ],
  },
  theme: {
    fontFamily: {
      sans: [
        // English Fonts
        "Overpass",
        "Roboto",
        "Helvetica Neue",
        "Arial",
        "Helvetica",
        // Chinese Fonts, Mac/Win/Linux
        "PingFang SC",
        "Microsoft Yahei",
        "微软雅黑",
        "WenQuanYi Micro Hei",
        // System Fonts
        "system-ui",
        "-apple-system",
        "BlinkMacSystemFont",
        "Segoe UI",
        "sans-serif",
        // emoji fonts
        "apple color emoji",
        "segoe ui emoji",
        "segoe ui symbol",
      ],
      mono: "Overpass Mono, monospace",
    },
    container: {
      center: true,
    },
    extend: {},
  },
  variants: {},
  plugins: [],
};
