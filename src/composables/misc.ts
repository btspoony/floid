export const useTheme = () => useState<string>("theme", () => ref("light"));

interface ScrollStatus {
  isOnTop: boolean;
  isScrollUp: boolean;
  lastScrollY: number;
}

export const useScrollStatus = () =>
  useState<ScrollStatus>("scrollStatus", () =>
    reactive({
      isOnTop: true,
      isScrollUp: false,
      lastScrollY: 0,
    })
  );
