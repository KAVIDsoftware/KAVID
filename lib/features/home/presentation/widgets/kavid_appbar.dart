import 'package:flutter/material.dart';

/// AppBar superior con el branding "K‑A‑V‑I‑D®"
class KavidAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KavidAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      centerTitle: true,
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      title: RichText(
        text: TextSpan(
          style: theme.textTheme.titleLarge?.copyWith(
            letterSpacing: 6, // separa K‑A‑V‑I‑D
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
          children: const [
            TextSpan(text: 'K A V I D'),
            TextSpan(
              text: ' ®',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
