import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../utils/app_colors.dart';

class LanguageSelector extends StatelessWidget {
  final bool showInDialog;

  const LanguageSelector({super.key, this.showInDialog = false});

  @override
  Widget build(BuildContext context) {
    final localeService = LocalizationService();

    if (showInDialog) {
      return _buildDialogSelector(context, localeService);
    }

    return _buildInlineSelector(context, localeService);
  }

  Widget _buildDialogSelector(
    BuildContext context,
    LocalizationService localeService,
  ) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.language, color: AppColors.bloodRed),
          const SizedBox(width: 8),
          Text(localeService.translate('select_language')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageOption(
            context,
            localeService,
            AppLanguage.bangla,
            '🇧🇩 বাংলা',
            'Bangla',
          ),
          const SizedBox(height: 12),
          _buildLanguageOption(
            context,
            localeService,
            AppLanguage.english,
            '🇬🇧 English',
            'English',
          ),
        ],
      ),
    );
  }

  Widget _buildInlineSelector(
    BuildContext context,
    LocalizationService localeService,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.language, color: AppColors.bloodRed, size: 20),
              const SizedBox(width: 8),
              Text(
                localeService.translate('language'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLanguageButton(
                  context,
                  localeService,
                  AppLanguage.bangla,
                  '🇧🇩 বাংলা',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLanguageButton(
                  context,
                  localeService,
                  AppLanguage.english,
                  '🇬🇧 English',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    LocalizationService localeService,
    AppLanguage language,
    String label,
    String subtitle,
  ) {
    final isSelected = localeService.currentLanguage == language;

    return InkWell(
      onTap: () async {
        await localeService.setLanguage(language);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                language == AppLanguage.bangla
                    ? 'ভাষা পরিবর্তন হয়েছে'
                    : 'Language changed',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.bloodRed : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.bloodRed.withValues(alpha: 0.1)
              : Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.bloodRed : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? AppColors.bloodRed : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.bloodRed,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(
    BuildContext context,
    LocalizationService localeService,
    AppLanguage language,
    String label,
  ) {
    final isSelected = localeService.currentLanguage == language;

    return ElevatedButton(
      onPressed: () async {
        await localeService.setLanguage(language);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              language == AppLanguage.bangla
                  ? 'ভাষা পরিবর্তন হয়েছে'
                  : 'Language changed',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.bloodRed : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: isSelected ? 4 : 1,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? AppColors.bloodRed : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

/// Quick Language Switch Button (for AppBar)
class LanguageSwitchButton extends StatelessWidget {
  const LanguageSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final localeService = LocalizationService();

    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          localeService.isBangla ? '🇧🇩' : '🇬🇧',
          style: const TextStyle(fontSize: 18),
        ),
      ),
      tooltip: localeService.translate('select_language'),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const LanguageSelector(showInDialog: true),
        );
      },
    );
  }
}
