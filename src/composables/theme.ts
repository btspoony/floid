export const useTheme = () =>
  useState<string>("theme", () => useDefaultTheme().value);

const useDefaultTheme = (fallback = "light") => {
  const theme = ref(fallback);
  if (process.client) {
    if (
      localStorage.theme === "dark" ||
      (!("theme" in localStorage) &&
        window.matchMedia("(prefers-color-scheme: dark)").matches)
    ) {
      theme.value = "dark";
    } else {
      theme.value = "light";
    }
  }
  return theme;
};
