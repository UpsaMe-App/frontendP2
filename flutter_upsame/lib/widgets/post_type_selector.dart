import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';

class PostTypeSelector extends StatelessWidget {
  final PostType selectedType;
  final ValueChanged<PostType> onTypeChanged;

  const PostTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de publicación',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTypeButton(
              type: PostType.helper,
              label: 'Ayudante',
              icon: Icons.school_rounded,
              color: const Color(0xFF388E3C),
            ),
            _buildTypeButton(
              type: PostType.student,
              label: 'Estudiante',
              icon: Icons.person_rounded,
              color: const Color(0xFF388E3C),
            ),
            _buildTypeButton(
              type: PostType.comment,
              label: 'Comentario',
              icon: Icons.chat_bubble_rounded,
              color: const Color(0xFF7B1FA2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required PostType type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = selectedType == type;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTypeChanged(type),
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.transparent : color.withOpacity(0.4),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              Icon(icon, size: 18, color: isSelected ? Colors.white : color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
