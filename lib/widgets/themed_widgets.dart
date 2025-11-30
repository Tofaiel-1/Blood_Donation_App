import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/responsive.dart';

/// Reusable themed widgets for the Blood Donation App
/// These widgets maintain consistent styling across the app

/// Emergency request card with gradient background
class EmergencyCard extends StatelessWidget {
  final String bloodType;
  final String hospital;
  final String urgency;
  final VoidCallback? onTap;

  const EmergencyCard({
    super.key,
    required this.bloodType,
    required this.hospital,
    this.urgency = 'URGENT',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: Responsive.responsiveElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          Responsive.responsiveBorderRadius(context),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          Responsive.responsiveBorderRadius(context),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(
              Responsive.responsiveBorderRadius(context),
            ),
          ),
          padding: Responsive.responsiveCardPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.responsiveSpacing(context),
                      vertical: Responsive.responsiveSpacing(context) * 0.3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(
                        Responsive.responsiveBorderRadius(context) + 4,
                      ),
                    ),
                    child: Text(
                      urgency,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: Responsive.responsiveTextSize(
                          context,
                          mobile: 11.0,
                          tablet: 12.0,
                          desktop: 13.0,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.emergency,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: Responsive.responsiveIconSize(context) + 4,
                  ),
                ],
              ),
              SizedBox(height: Responsive.responsiveSpacing(context)),
              Text(
                bloodType,
                style: AppTextStyles.bloodType(context).copyWith(
                  color: Colors.white,
                  fontSize: Responsive.responsiveTextSize(
                    context,
                    mobile: 36.0,
                    tablet: 42.0,
                    desktop: 48.0,
                  ),
                ),
              ),
              SizedBox(height: Responsive.responsiveSpacing(context) * 0.5),
              Text(
                hospital,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w600,
                  fontSize: Responsive.responsiveTextSize(
                    context,
                    mobile: 14.0,
                    tablet: 16.0,
                    desktop: 18.0,
                  ),
                ),
              ),
              SizedBox(height: Responsive.responsiveSpacing(context)),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: Responsive.responsiveIconSize(context) - 4,
                  ),
                  SizedBox(width: Responsive.responsiveSpacing(context) * 0.3),
                  Text(
                    'Posted just now',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: Responsive.responsiveTextSize(
                        context,
                        mobile: 11.0,
                        tablet: 12.0,
                        desktop: 13.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Blood type badge with themed styling
class BloodTypeBadge extends StatelessWidget {
  final String bloodType;
  final double size;
  final bool isPrimary;

  const BloodTypeBadge({
    super.key,
    required this.bloodType,
    this.size = 60,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPrimary
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          bloodType,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// Status indicator chip
class StatusChip extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusChip({super.key, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case StatusType.available:
        backgroundColor = AppColors.statusAvailable;
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case StatusType.busy:
        backgroundColor = AppColors.statusBusy;
        textColor = Colors.white;
        icon = Icons.cancel;
        break;
      case StatusType.pending:
        backgroundColor = AppColors.statusPending;
        textColor = Colors.black87;
        icon = Icons.access_time;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum StatusType { available, busy, pending }

/// Donation statistics card
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? color;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Theme.of(context).colorScheme.primary;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: isSmallScreen ? 24 : 32, color: cardColor),
            SizedBox(height: isSmallScreen ? 8 : 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: AppTextStyles.statsNumber(
                  context,
                ).copyWith(fontSize: isSmallScreen ? 28 : 36, color: cardColor),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: isSmallScreen ? 10 : 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Gradient action button
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isFullWidth;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      height: 50,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.bloodRed.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 8),
                ],
                Text(text, style: AppTextStyles.buttonText(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Info banner for important messages
class InfoBanner extends StatelessWidget {
  final String message;
  final BannerType type;
  final VoidCallback? onDismiss;

  const InfoBanner({
    super.key,
    required this.message,
    this.type = BannerType.info,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case BannerType.info:
        backgroundColor = AppColors.trustBlue;
        textColor = Colors.white;
        icon = Icons.info;
        break;
      case BannerType.warning:
        backgroundColor = AppColors.warningAmber;
        textColor = Colors.black87;
        icon = Icons.warning;
        break;
      case BannerType.error:
        backgroundColor = AppColors.urgentRed;
        textColor = Colors.white;
        icon = Icons.error;
        break;
      case BannerType.success:
        backgroundColor = AppColors.hopeGreen;
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(Icons.close, color: textColor),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

enum BannerType { info, warning, error, success }

/// Donation history list item
class DonationHistoryTile extends StatelessWidget {
  final String bloodType;
  final String location;
  final DateTime date;
  final bool isCompleted;
  // Recipient information
  final String? recipientPatientName;
  final String? recipientHospital;
  final String? recipientBloodType;

  const DonationHistoryTile({
    super.key,
    required this.bloodType,
    required this.location,
    required this.date,
    this.isCompleted = true,
    this.recipientPatientName,
    this.recipientHospital,
    this.recipientBloodType,
  });

  bool get hasRecipient =>
      recipientPatientName != null && recipientPatientName!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BloodTypeBadge(
                  bloodType: bloodType,
                  size: 50,
                  isPrimary: isCompleted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _formatDate(date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                StatusChip(
                  label: isCompleted ? 'Completed' : 'Pending',
                  type: isCompleted ? StatusType.available : StatusType.pending,
                ),
              ],
            ),
            // Show recipient info if available
            if (hasRecipient) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.bloodRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.bloodRed.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 16,
                          color: AppColors.bloodRed,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'রোগী: $recipientPatientName',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.bloodRed,
                          ),
                        ),
                      ],
                    ),
                    if (recipientHospital != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.local_hospital,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              recipientHospital!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Themed app bar with gradient
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: actions,
        leading: leading,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
