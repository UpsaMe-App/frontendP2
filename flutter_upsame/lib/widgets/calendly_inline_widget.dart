import 'package:flutter/material.dart';

import 'calendly_inline_widget_impl.dart'
    if (dart.library.html) 'calendly_inline_widget_web.dart';

/// Public widget that delegates to a platform-specific implementation.
class CalendlyInlineWidget extends StatelessWidget {
  final String calendlyUrl;
  final double height;
  final bool embedInline; // when true on web, attempt an inline iframe

  const CalendlyInlineWidget({
    Key? key,
    required this.calendlyUrl,
    this.height = 600,
    this.embedInline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => CalendlyInlineWidgetImpl(
    calendlyUrl: calendlyUrl,
    height: height,
    embedInline: embedInline,
  );
}
