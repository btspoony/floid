module.exports = {
  content: ["./src/**/*.{js,ts,vue}"],
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
      colors: {
        gray: {
          darkest: "#30353E",
          dark: "#444444",
          DEFAULT: "#5C626F",
          light: "#707376",
          lightest: "#999999",
        },
        green: {
          muted: "#66D78F",
          dark: "#17DA88",
          DEFAULT: "#00EF8B",
        },
        blue: {
          DEFAULT: "#1972A4",
        },
        gold: {
          DEFAULT: "#E67B49",
        },
        purple: {
          DEFAULT: "#512BBD",
        },
        red: {
          DEFAULT: "#E55A3D",
        },
      },
      minWidth: {
        40: "10rem",
      },
    },
  },
};
