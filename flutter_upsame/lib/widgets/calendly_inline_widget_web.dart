// Web implementation: Shows an inline iframe when embedInline=true,
// otherwise shows a button that opens Calendly in a new tab.
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class CalendlyInlineWidgetImpl extends StatefulWidget {
  final String calendlyUrl;
  final double height;
  final bool embedInline;

  const CalendlyInlineWidgetImpl({
    Key? key,
    required this.calendlyUrl,
    this.height = 600,
    this.embedInline = false,
  }) : super(key: key);

  @override
  State<CalendlyInlineWidgetImpl> createState() => _CalendlyInlineWidgetImplState();
}

class _CalendlyInlineWidgetImplState extends State<CalendlyInlineWidgetImpl> {
  String? _viewType;

  @override
  void initState() {
    super.initState();
    if (widget.embedInline) {
      // Create a unique view type for this iframe
      _viewType = 'calendly-iframe-${widget.calendlyUrl.hashCode}';
      
      // Register the iframe view factory
      // ignore: undefined_prefixed_name
      ui_web.platformViewRegistry.registerViewFactory(_viewType!, (int viewId) {
        final iframe = html.IFrameElement()
          ..src = widget.calendlyUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If embedInline is true, show the iframe
    if (widget.embedInline && _viewType != null) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: HtmlElementView(viewType: _viewType!),
        ),
      );
    }

    // Otherwise, show a button that opens in new tab
    return Card(
      color: const Color(0xFFFAF5FC),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: widget.height,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Abrir Calendly',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Se abrirá Calendly en una nueva pestaña.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B61FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  try {
                    html.window.open(widget.calendlyUrl, '_blank');
                  } catch (e) {
                    // ignore
                  }
                },
                child: const Text('Abrir Calendly'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
