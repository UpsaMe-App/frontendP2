import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendlyInlineWidgetImpl extends StatelessWidget {
  final String calendlyUrl;
  final double height;

  const CalendlyInlineWidgetImpl({
    super.key,
    required this.calendlyUrl,
    required this.height,
  });

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(calendlyUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150, // Fixed height for the card/button area
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_month, size: 40, color: Color(0xFF66B2A8)),
          const SizedBox(height: 12),
          Text(
            'Agenda una cita',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _launchUrl,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF66B2A8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Abrir Calendly',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
