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
          "base-100": "#f8faf8",
          info: "#ccfbf1",
          success: "#4ade80",
          warning: "#fcd34d",
          error: "#F34949",

          "--rounded-box": "1rem",
          "--rounded-btn": "2rem",
          "--btn-focus-scale": "1", // scale transform of button when you focus on it
        },
      },
      {
        forest: {
          ...require("daisyui/src/colors/themes")["[data-theme=forest]"],
          "base-100": "rgb(20, 38, 28)",
          "base-200": "rgb(32, 50, 38)",
        },
      },
    ],
  },
};
