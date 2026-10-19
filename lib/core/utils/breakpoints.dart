enum ScreenSize {
  compact, // < 600 dp (2-col grid, BottomNavigationBar)
  medium, // 600 - 1024 dp (3-4 col grid, NavigationRail)
  expanded, // > 1024 dp (Master-Detail side-by-side + NavigationRail)
}

class Breakpoints {
  Breakpoints._();

  static const double compactMaxWidth = 600.0;
  static const double mediumMaxWidth = 1024.0;

  static ScreenSize fromWidth(double width) {
    if (width < compactMaxWidth) {
      return ScreenSize.compact;
    } else if (width <= mediumMaxWidth) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.expanded;
    }
  }

  static int gridColumnsForWidth(double width) {
    if (width < compactMaxWidth) return 2;
    if (width < 900) return 3;
    return 4;
  }
}
