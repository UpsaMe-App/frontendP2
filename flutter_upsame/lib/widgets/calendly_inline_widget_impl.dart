import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Mobile / non-web implementation: show a fallback UI with a button to open Calendly.
class CalendlyInlineWidgetImpl extends StatelessWidget {
  final String calendlyUrl;
  final double height;
  final bool embedInline;

  const CalendlyInlineWidgetImpl({
    Key? key,
    required this.calendlyUrl,
    this.height = 600,
    this.embedInline = false,
  }) : super(key: key);

  Future<void> _openUrl(BuildContext context) async {
    final uri = Uri.tryParse(calendlyUrl);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('URL inválida')));
      return;
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Calendly', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: Text(
                    embedInline
                        ? 'La vista embebida no está disponible en esta plataforma.\nSe abrirá en el navegador.'
                        : 'Vista embebida no disponible en esta plataforma.\nAbre el calendario en el navegador.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openUrl(context),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Abrir Calendly'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
