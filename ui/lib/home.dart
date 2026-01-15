import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ui/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<BrowserTab> tabs = [];
  int selectedIndex = 0;
  int tabCounter = 0;

  final List<String> tabNames = [
    'Home',
    'Dashboard',
    'Settings',
    'Profile',
    'Notifications',
    'Analytics',
  ];

  @override
  void initState() {
    super.initState();
    addNewTab();
  }

  void addNewTab() {
    setState(() {
      final nameIndex = tabCounter % tabNames.length;
      tabs.add(BrowserTab(id: 'tab_$tabCounter', label: tabNames[nameIndex]));
      selectedIndex = tabs.length - 1;
      tabCounter++;
    });
  }

  void closeTab(int index) {
    if (tabs.length <= 1) return;

    setState(() {
      tabs.removeAt(index);
      if (selectedIndex >= tabs.length) {
        selectedIndex = tabs.length - 1;
      } else if (selectedIndex > index) {
        selectedIndex--;
      }
    });
  }

  void selectTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.secondary.withOpacity(0.25),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.tabBarBackground,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColor.primary.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: ChromeTabBar(
                              tabs: tabs,
                              selectedIndex: selectedIndex,
                              onTabSelected: selectTab,
                              onTabClosed: closeTab,
                              onAddTab: addNewTab,
                            ),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrowserTab {
  final String id;
  final String label;
  final Color? color;

  const BrowserTab({required this.id, required this.label, this.color});
}

class ChromeTabBar extends StatelessWidget {
  final List<BrowserTab> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;
  final Function(int) onTabClosed;
  final VoidCallback onAddTab;

  const ChromeTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onTabClosed,
    required this.onAddTab,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  ...List.generate(tabs.length, (index) {
                    return ChromeTab(
                      key: ValueKey(tabs[index].id),
                      tab: tabs[index],
                      isSelected: index == selectedIndex,
                      onTap: () => onTabSelected(index),
                      onClose: tabs.length > 1
                          ? () => onTabClosed(index)
                          : null,
                    );
                  }),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AddTabButton(onTap: onAddTab),
          ),
        ],
      ),
    );
  }
}

//! add tab button
class AddTabButton extends StatefulWidget {
  final VoidCallback onTap;

  const AddTabButton({super.key, required this.onTap});

  @override
  State<AddTabButton> createState() => _AddTabButtonState();
}

class _AddTabButtonState extends State<AddTabButton>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => isPressed = true);
        controller.forward();
      },
      onTapUp: (_) {
        setState(() => isPressed = false);
        controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => isPressed = false);
        controller.reverse();
      },
      child: AnimatedBuilder(
        animation: scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPressed
                      ? [AppColor.primary, AppColor.primaryLight]
                      : [AppColor.tabHover, AppColor.tabSelected],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isPressed ? AppColor.primary : AppColor.glassBorder,
                  width: 1,
                ),
                boxShadow: isPressed
                    ? [
                        BoxShadow(
                          color: AppColor.shadowPrimary,
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                Icons.add_rounded,
                size: 22,
                color: isPressed ? AppColor.white : AppColor.textSecondary,
              ),
            ),
          );
        },
      ),
    );
  }
}

//! chrome tab ui
class ChromeTab extends StatefulWidget {
  final BrowserTab tab;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onClose;

  const ChromeTab({
    super.key,
    required this.tab,
    required this.isSelected,
    required this.onTap,
    this.onClose,
  });

  @override
  State<ChromeTab> createState() => _ChromeTabState();
}

class _ChromeTabState extends State<ChromeTab>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => isPressed = true);
              controller.forward();
            },
            onTapUp: (_) {
              setState(() => isPressed = false);
              controller.reverse();
              widget.onTap();
            },
            onTapCancel: () {
              setState(() => isPressed = false);
              controller.reverse();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? LinearGradient(
                        colors: [AppColor.tabSelected, AppColor.surface],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                color: widget.isSelected ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: widget.isSelected
                    ? Border.all(
                        color: AppColor.primary.withOpacity(0.3),
                        width: 1,
                      )
                    : null,
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: AppColor.shadowPrimary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      fontSize: widget.isSelected ? 14 : 13,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: widget.isSelected
                          ? AppColor.textPrimary
                          : AppColor.textSecondary,
                    ),
                    child: Text(
                      widget.tab.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  if (widget.onClose != null) ...[
                    const SizedBox(width: 8),
                    CloseTabButton(
                      onTap: widget.onClose!,
                      isTabSelected: widget.isSelected,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

//! close tab button
class CloseTabButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isTabSelected;

  const CloseTabButton({
    super.key,
    required this.onTap,
    required this.isTabSelected,
  });

  @override
  State<CloseTabButton> createState() => _CloseTabButtonState();
}

class _CloseTabButtonState extends State<CloseTabButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColor.tertiary.withOpacity(0.3)
              : (widget.isTabSelected
                    ? AppColor.glassWhite
                    : Colors.transparent),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.close_rounded,
          size: 14,
          color: _isHovered
              ? AppColor.tertiary
              : (widget.isTabSelected
                    ? AppColor.textSecondary
                    : AppColor.textMuted),
        ),
      ),
    );
  }
}
