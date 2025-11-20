# Blood Donation App - Theming System Documentation

## Overview

This Blood Donation App features a comprehensive theming system built with **flex_color_scheme** and **Google Fonts**, providing a professional, medical-themed design that aligns perfectly with the blood donation context.

## 🎨 Design Philosophy

### Color Inspiration
- **Blood Red**: Primary color representing blood, life, and urgency
- **Life Orange**: Warm accent representing energy and vitality
- **Hope Green**: Success states and positive actions
- **Trust Blue**: Medical trust and reliability
- **Warm Gradients**: Creating an approachable, life-saving atmosphere

### Typography
- **Montserrat**: Bold, modern font for headings and displays
- **Poppins**: Clean, readable font for body text and UI elements
- Optimized hierarchy for readability and accessibility

## 📁 File Structure

```
lib/
├── utils/
│   ├── theme_manager.dart      # Main theme configuration with flex_color_scheme
│   ├── app_colors.dart         # Custom color palette constants
│   └── app_text_styles.dart    # Typography system
└── screens/
    └── theme_showcase_screen.dart  # Interactive theme demonstration
```

## 🎨 Color Palette

### Primary Colors
- **Blood Red**: `#B71C1C` - Deep, professional blood red
- **Blood Red Light**: `#D32F2F` - Lighter variant for highlights
- **Blood Red Dark**: `#8E0E00` - Darker variant for depth

### Accent Colors
- **Life Orange**: `#FF5722` - Energy and warmth
- **Hope Green**: `#4CAF50` - Success and hope
- **Trust Blue**: `#1976D2` - Medical trust
- **Warning Amber**: `#FFA726` - Alerts and warnings

### Status Colors
- **Available**: `#66BB6A` - Green for available donors
- **Busy**: `#EF5350` - Red for unavailable
- **Pending**: `#FFCA28` - Yellow for pending requests

### Gradients
```dart
// Primary gradient for hero sections
LinearGradient(
  colors: [Color(0xFF8E0E00), Color(0xFFB71C1C), Color(0xFFD32F2F)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

## 🔤 Typography System

### Display Styles (Hero Sections)
- **Display Large**: 57sp, Bold (Montserrat)
- **Display Medium**: 45sp, Semi-bold (Montserrat)
- **Display Small**: 36sp, Semi-bold (Montserrat)

### Headline Styles
- **Headline Large**: 32sp, Bold (Montserrat)
- **Headline Medium**: 28sp, Semi-bold (Poppins)
- **Headline Small**: 24sp, Semi-bold (Poppins)

### Title Styles
- **Title Large**: 22sp, Semi-bold (Poppins)
- **Title Medium**: 16sp, Semi-bold (Poppins)
- **Title Small**: 14sp, Semi-bold (Poppins)

### Body Styles
- **Body Large**: 16sp, Regular (Poppins)
- **Body Medium**: 14sp, Regular (Poppins)
- **Body Small**: 12sp, Regular (Poppins)

### Label Styles (Buttons, Forms)
- **Label Large**: 14sp, Semi-bold (Poppins)
- **Label Medium**: 12sp, Semi-bold (Poppins)
- **Label Small**: 11sp, Medium (Poppins)

### Custom Styles
- **Blood Type**: 32sp, Extra-bold (Montserrat) - For displaying blood types
- **Emergency Text**: 16sp, Bold (Poppins) - For urgent messages
- **Stats Number**: 48sp, Extra-bold (Montserrat) - For statistics
- **Button Text**: 16sp, Semi-bold (Poppins) - For button labels

## 🎯 Component Styling

### Buttons
- **Border Radius**: 30px (fully rounded)
- **Elevation**: 2dp for elevated buttons
- **Colors**: Primary color with on-primary text

### Cards
- **Border Radius**: 16px
- **Elevation**: 2dp
- **Surface tint**: Subtle primary color blend

### Input Fields
- **Border Radius**: 12px
- **Border**: Visible outline with primary color focus
- **Background**: Slight primary color tint (alpha 0.15)
- **Prefix Icons**: Primary color

### Bottom Navigation
- **Selected**: Primary color
- **Unselected**: Muted on-surface color
- **Elevation**: 8dp
- **Height**: 80px

### Floating Action Button (FAB)
- **Shape**: Circular
- **Color**: Primary
- **Radius**: 16px
- **Icon Color**: On-primary

### Dialogs & Bottom Sheets
- **Dialog Radius**: 20px
- **Bottom Sheet Radius**: 28px (top corners)
- **Elevation**: 4-6dp

## 🌓 Dark Mode Support

The app includes a fully-featured dark mode that:
- Uses darker blood red variants
- Adjusts surface colors for better contrast
- Maintains the same visual hierarchy
- Automatically adapts all components

## 🚀 Usage Examples

### Accessing Theme Colors

```dart
// In any widget
Theme.of(context).colorScheme.primary
Theme.of(context).colorScheme.secondary

// Using custom colors
import 'package:blood_bank/utils/app_colors.dart';

Container(
  color: AppColors.bloodRed,
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
  ),
)
```

### Using Text Styles

```dart
// Using theme text styles
Text(
  'Welcome to Blood Bank',
  style: Theme.of(context).textTheme.headlineLarge,
)

// Using custom text styles
import 'package:blood_bank/utils/app_text_styles.dart';

Text(
  'B+',
  style: AppTextStyles.bloodType(context),
)

Text(
  'URGENT BLOOD NEEDED',
  style: AppTextStyles.emergencyText(context),
)
```

### Switching Themes

```dart
import 'package:provider/provider.dart';
import 'package:blood_bank/utils/theme_manager.dart';

// In any widget
final themeManager = Provider.of<ThemeManager>(context);

// Toggle between light and dark
themeManager.toggleTheme(true); // dark mode
themeManager.toggleTheme(false); // light mode

// Set specific mode
themeManager.setThemeMode(ThemeMode.system);
themeManager.setThemeMode(ThemeMode.light);
themeManager.setThemeMode(ThemeMode.dark);
```

### Creating Themed Components

```dart
// Emergency Card with gradient
Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(16),
  ),
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      Text(
        'Emergency Request',
        style: AppTextStyles.headlineMedium(context).copyWith(
          color: Colors.white,
        ),
      ),
      Text(
        'B+ Blood Needed',
        style: AppTextStyles.bloodType(context).copyWith(
          color: Colors.white,
        ),
      ),
    ],
  ),
)
```

## 🎭 Theme Showcase Screen

To view all theme elements interactively:

```dart
// Navigate to the theme showcase
Navigator.pushNamed(context, '/theme-showcase');
```

The showcase screen displays:
1. **Colors Tab**: All color palette items with hex codes
2. **Typography Tab**: All text styles with specifications
3. **Components Tab**: Interactive UI components

## 🔧 Customization

### Adding New Colors

1. Add to `lib/utils/app_colors.dart`:
```dart
static const myNewColor = Color(0xFF123456);
```

2. Use in your widgets:
```dart
Container(color: AppColors.myNewColor)
```

### Adding New Text Styles

1. Add to `lib/utils/app_text_styles.dart`:
```dart
static TextStyle myCustomStyle(BuildContext context) => GoogleFonts.poppins(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: Theme.of(context).colorScheme.primary,
);
```

2. Use in your widgets:
```dart
Text('Hello', style: AppTextStyles.myCustomStyle(context))
```

### Modifying Theme Configuration

Edit `lib/utils/theme_manager.dart` to adjust:
- Border radius values
- Elevation levels
- Surface blend levels
- Component-specific styling

## 📱 Material 3 Features

The theming system leverages Material 3:
- Dynamic color schemes
- Enhanced component states
- Better accessibility
- Improved visual hierarchy
- Advanced surface tinting

## ♿ Accessibility

The theme ensures:
- WCAG AA contrast ratios
- Readable font sizes (minimum 12sp)
- Touch target sizes (minimum 48x48dp)
- Clear visual hierarchy
- Screen reader compatibility

## 🎯 Best Practices

1. **Always use theme colors** instead of hardcoded colors
2. **Use text styles** from the theme for consistency
3. **Test in both light and dark modes**
4. **Maintain consistent spacing** (8dp grid system)
5. **Use semantic colors** (primary, error, success) appropriately

## 📦 Dependencies

```yaml
dependencies:
  flex_color_scheme: ^8.0.2
  google_fonts: ^6.2.1
  provider: ^6.1.2
```

## 🔄 Migration from Old Theme

If migrating from the old theme:

1. Replace hardcoded `Colors.red[700]` with `Theme.of(context).colorScheme.primary`
2. Replace hardcoded text styles with theme text styles
3. Remove manual dark mode conditions - let the theme handle it
4. Update button styles to use theme defaults

## 🎨 Design Assets

The app uses Material Icons and custom gradients. For future additions:
- Use Material Icons when possible
- Create custom icons at 24dp size
- Export icons in vector format (SVG)
- Use theme colors for icon tinting

## 📚 Additional Resources

- [flex_color_scheme Documentation](https://pub.dev/packages/flex_color_scheme)
- [Google Fonts](https://fonts.google.com/)
- [Material Design 3](https://m3.material.io/)
- [Flutter Theming Guide](https://docs.flutter.dev/cookbook/design/themes)

## 🤝 Contributing

When adding new features:
1. Use existing color constants
2. Follow the typography hierarchy
3. Test in both themes
4. Document custom styles
5. Update this README if adding new patterns

---

**Created with ❤️ for saving lives through blood donation**
