module.exports = {
  darkMode: "class",
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
    extend: {
      screens: {
        "2xl": "1372px",
      },
      screens: {
        "2xl": "1372px",
        "3xl": "1536px",
      },
      minWidth: {
        40: "10rem",
      },
    },
  },
  plugins: [require("@tailwindcss/typography"), require("daisyui")],
  // daisyUI config (optional)
  daisyui: {
    themes: [
      {
        floid: {
          primary: "#128F8B",
          secondary: "#3DE0D2",
          accent: "#65a30d",
          neutral: "#4b5563",
          info: "#ccfbf1",
          success: "#4ade80",
          warning: "#fcd34d",
          error: "#F34949",
        },
      },
      "forest",
    ],
  },
};
