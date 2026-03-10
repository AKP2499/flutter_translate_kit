import 'package:flutter/material.dart';

import '../core/translation_service.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// KitLanguageChangeOverlay
///
/// Shows a full-screen loading overlay while the app is switching language,
/// so users see "Changing language..." until all KitText widgets have updated.
///
/// Wrap your app (e.g. inside [KitScope]) with this widget:
///
/// ```dart
/// KitScope(
///   builder: (locale, delegates) => MaterialApp(
///     locale: locale,
///     localizationsDelegates: delegates,
///     supportedLocales: KitScope.supportedLocales,
///     home: KitLanguageChangeOverlay(
///       child: HomeScreen(),
///     ),
///   ),
/// )
/// ```
///
/// When the user changes language (e.g. via [KitLanguageSwitcher]), the overlay
/// appears until [TranslationService.languageChangeLoadingDuration] elapses.
/// ─────────────────────────────────────────────────────────────────────────────
class KitLanguageChangeOverlay extends StatelessWidget {
  /// The app content to show under the overlay.
  final Widget child;

  /// Optional message shown while changing. Default: "Changing language..."
  final String? message;

  /// Optional custom loading widget. If null, shows a centered [CircularProgressIndicator].
  final Widget? loadingWidget;

  const KitLanguageChangeOverlay({
    super.key,
    required this.child,
    this.message,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final service = TranslationService.instance;
    return Stack(
      children: [
        child,
        StreamBuilder<bool>(
          stream: service.languageChangingStream,
          initialData: service.isLanguageChanging,
          builder: (context, snapshot) {
            final changing = snapshot.data ?? false;
            if (!changing) return const SizedBox.shrink();

            // Full-screen dimmed barrier + centered loader
            return Positioned.fill(
              child: AbsorbPointer(
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: loadingWidget ??
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            message ?? 'Changing language...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
