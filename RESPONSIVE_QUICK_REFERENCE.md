# Responsive Design Quick Reference

## Import Statement
```dart
import '../utils/responsive.dart'; // Adjust path as needed
```

## Common Patterns

### Basic Padding
```dart
// All sides padding
padding: Responsive.responsivePadding(context)  
// Mobile: 16px, Tablet: 24px, Desktop: 32px

// Horizontal only
padding: Responsive.responsiveHorizontalPadding(context)
// Mobile: 16px, Tablet: 32px, Desktop: 64px

// Card padding (smaller)
padding: Responsive.responsiveCardPadding(context)
// Mobile: 12px, Tablet: 16px, Desktop: 20px
```

### Text Sizing
```dart
// Default sizing
fontSize: Responsive.responsiveTextSize(context)
// Mobile: 14px, Tablet: 16px, Desktop: 18px

// Custom sizing
fontSize: Responsive.responsiveTextSize(
  context,
  mobile: 16.0,
  tablet: 18.0,
  desktop: 20.0,
)
```

### Icon Sizing
```dart
size: Responsive.responsiveIconSize(context)
// Mobile: 20px, Tablet: 24px, Desktop: 28px
```

### Spacing (Gaps)
```dart
SizedBox(height: Responsive.responsiveSpacing(context))
// Mobile: 12px, Tablet: 16px, Desktop: 20px

// For smaller gaps
SizedBox(height: Responsive.responsiveSpacing(context) * 0.5)
// Mobile: 6px, Tablet: 8px, Desktop: 10px

// For larger gaps
SizedBox(height: Responsive.responsiveSpacing(context) * 2)
// Mobile: 24px, Tablet: 32px, Desktop: 40px
```

### Button Heights
```dart
height: Responsive.responsiveButtonHeight(context)
// Mobile: 48px, Tablet: 52px, Desktop: 56px
```

### Border Radius
```dart
borderRadius: BorderRadius.circular(
  Responsive.responsiveBorderRadius(context)
)
// Mobile: 8px, Tablet: 12px, Desktop: 16px

// For rounded buttons (multiply by 2-3)
borderRadius: BorderRadius.circular(
  Responsive.responsiveBorderRadius(context) * 2.5
)
// Mobile: 20px, Tablet: 30px, Desktop: 40px
```

### Elevation/Shadows
```dart
elevation: Responsive.responsiveElevation(context)
// Mobile: 2px, Tablet: 4px, Desktop: 6px
```

### AppBar Height
```dart
toolbarHeight: Responsive.responsiveAppBarHeight(context)
// Mobile: 56px, Tablet: 64px, Desktop: 72px
```

### Max Width Constraints
```dart
ConstrainedBox(
  constraints: BoxConstraints(
    maxWidth: Responsive.responsiveMaxWidth(context),
  ),
  child: YourContent(),
)
// Mobile: Infinity, Tablet: 600px, Desktop: 800px
```

### Device Detection
```dart
if (Responsive.isMobile(context)) {
  // Mobile-specific layout
} else if (Responsive.isTablet(context)) {
  // Tablet-specific layout
} else {
  // Desktop layout
}

// Or use ternary
final size = Responsive.isMobile(context) ? 70 : 90;
```

### Grid Layouts
```dart
// Simple grid count
crossAxisCount: Responsive.responsiveGridCount(context)
// Mobile: 2, Tablet: 3, Desktop: 4

// Custom grid count
crossAxisCount: Responsive.responsiveCrossAxisCount(
  context,
  mobile: 1,
  tablet: 2,
  desktop: 3,
)
```

### Dialog Sizing
```dart
width: Responsive.responsiveDialogWidth(context)
// Mobile: 90% of screen, Tablet: 70%, Desktop: 50%
```

## Complete Widget Example

```dart
class MyResponsiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: Responsive.responsiveAppBarHeight(context),
        title: Text(
          'My Screen',
          style: TextStyle(
            fontSize: Responsive.responsiveTextSize(
              context,
              mobile: 18.0,
              tablet: 20.0,
              desktop: 22.0,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.responsiveMaxWidth(context),
          ),
          child: Center(
            child: Padding(
              padding: Responsive.responsivePadding(context),
              child: Column(
                children: [
                  SizedBox(height: Responsive.responsiveSpacing(context)),
                  
                  // Card
                  Card(
                    elevation: Responsive.responsiveElevation(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Responsive.responsiveBorderRadius(context),
                      ),
                    ),
                    child: Padding(
                      padding: Responsive.responsiveCardPadding(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            'Card Title',
                            style: TextStyle(
                              fontSize: Responsive.responsiveTextSize(
                                context,
                                mobile: 18.0,
                                tablet: 20.0,
                                desktop: 22.0,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: Responsive.responsiveSpacing(context) * 0.5),
                          
                          // Content
                          Text(
                            'Card content goes here',
                            style: TextStyle(
                              fontSize: Responsive.responsiveTextSize(context),
                            ),
                          ),
                          SizedBox(height: Responsive.responsiveSpacing(context)),
                          
                          // Button
                          Container(
                            width: double.infinity,
                            height: Responsive.responsiveButtonHeight(context),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.red, Colors.pink],
                              ),
                              borderRadius: BorderRadius.circular(
                                Responsive.responsiveBorderRadius(context) * 2,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                'Action',
                                style: TextStyle(
                                  fontSize: Responsive.responsiveTextSize(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

## Migration Checklist

When making a screen responsive:

- [ ] Add `import '../utils/responsive.dart';`
- [ ] Replace all `EdgeInsets.all(n)` with `Responsive.responsivePadding()` or similar
- [ ] Replace all `fontSize:` values with `Responsive.responsiveTextSize()`
- [ ] Replace all icon `size:` values with `Responsive.responsiveIconSize()`
- [ ] Replace all `SizedBox(height/width: n)` with `Responsive.responsiveSpacing()`
- [ ] Replace button heights with `Responsive.responsiveButtonHeight()`
- [ ] Replace border radius with `Responsive.responsiveBorderRadius()`
- [ ] Replace elevation values with `Responsive.responsiveElevation()`
- [ ] Add `ConstrainedBox` with `responsiveMaxWidth()` for main content
- [ ] Replace custom screen size checks with `Responsive.isMobile/isTablet/isDesktop()`
- [ ] Test on mobile, tablet, and desktop sizes
- [ ] Verify text readability at all sizes
- [ ] Ensure buttons have adequate touch targets (minimum 48px)

## Common Mistakes to Avoid

1. ❌ Mixing hardcoded and responsive values
   ```dart
   // Bad
   padding: EdgeInsets.symmetric(
     horizontal: Responsive.responsiveSpacing(context),
     vertical: 16, // Hardcoded!
   )
   
   // Good
   padding: Responsive.responsivePadding(context)
   ```

2. ❌ Not using device detection
   ```dart
   // Bad
   width: MediaQuery.of(context).size.width < 600 ? 70 : 90
   
   // Good
   width: Responsive.isMobile(context) ? 70 : 90
   ```

3. ❌ Forgetting max width constraints
   ```dart
   // Bad - content too wide on desktop
   Padding(
     padding: Responsive.responsivePadding(context),
     child: YourContent(),
   )
   
   // Good
   Center(
     child: ConstrainedBox(
       constraints: BoxConstraints(
         maxWidth: Responsive.responsiveMaxWidth(context),
       ),
       child: Padding(
         padding: Responsive.responsivePadding(context),
         child: YourContent(),
       ),
     ),
   )
   ```

4. ❌ Not multiplying spacing for variety
   ```dart
   // Bad - everything has same spacing
   SizedBox(height: Responsive.responsiveSpacing(context))
   
   // Good - varied spacing
   SizedBox(height: Responsive.responsiveSpacing(context) * 0.5) // Smaller
   SizedBox(height: Responsive.responsiveSpacing(context))       // Normal
   SizedBox(height: Responsive.responsiveSpacing(context) * 2)   // Larger
   ```

## Tips

- Use multipliers (0.5x, 2x, 3x) for spacing variations
- Border radius for buttons typically needs 2-3x multiplier for rounded look
- Always wrap main content in ConstrainedBox for large screens
- Test at the exact breakpoint values (600px, 1024px, 1440px)
- Consider both portrait and landscape orientations
- Ensure touch targets are minimum 48x48 dp on mobile

---

**Quick Command:** Search for hardcoded values in a file:
```
(const EdgeInsets|SizedBox\(height:|fontSize:|width:\s*\d+|height:\s*\d+)
```
