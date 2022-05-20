export const useTheme = () => useState<string>("theme", () => ref("light"));
