import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_manager.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

/// Theme showcase and settings screen
/// Demonstrates the complete theming system and allows users to switch themes
class ThemeShowcaseScreen extends StatefulWidget {
  const ThemeShowcaseScreen({super.key});

  @override
  State<ThemeShowcaseScreen> createState() => _ThemeShowcaseScreenState();
}

class _ThemeShowcaseScreenState extends State<ThemeShowcaseScreen> {
  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme & Design'),
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeManager.toggleTheme(!isDark),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              tabs: const [
                Tab(text: 'Colors', icon: Icon(Icons.palette)),
                Tab(text: 'Typography', icon: Icon(Icons.text_fields)),
                Tab(text: 'Components', icon: Icon(Icons.widgets)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildColorsTab(context),
                  _buildTypographyTab(context),
                  _buildComponentsTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Color Palette', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),

        // Primary Colors
        _buildColorSection(context, 'Primary Colors', [
          ColorItem('Blood Red', AppColors.bloodRed),
          ColorItem('Blood Red Light', AppColors.bloodRedLight),
          ColorItem('Blood Red Dark', AppColors.bloodRedDark),
        ]),

        // Accent Colors
        _buildColorSection(context, 'Accent Colors', [
          ColorItem('Life Orange', AppColors.lifeOrange),
          ColorItem('Hope Green', AppColors.hopeGreen),
          ColorItem('Trust Blue', AppColors.trustBlue),
          ColorItem('Warning Amber', AppColors.warningAmber),
        ]),

        // Status Colors
        _buildColorSection(context, 'Status Colors', [
          ColorItem('Available', AppColors.statusAvailable),
          ColorItem('Busy', AppColors.statusBusy),
          ColorItem('Pending', AppColors.statusPending),
        ]),

        // Theme Colors
        _buildColorSection(context, 'Theme Colors', [
          ColorItem('Primary', Theme.of(context).colorScheme.primary),
          ColorItem('Secondary', Theme.of(context).colorScheme.secondary),
          ColorItem('Tertiary', Theme.of(context).colorScheme.tertiary),
          ColorItem('Error', Theme.of(context).colorScheme.error),
          ColorItem('Surface', Theme.of(context).colorScheme.surface),
          ColorItem('Background', Theme.of(context).colorScheme.surface),
        ]),
      ],
    );
  }

  Widget _buildColorSection(
    BuildContext context,
    String title,
    List<ColorItem> colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: colors.length,
          itemBuilder: (context, index) {
            final colorItem = colors[index];
            return Container(
              decoration: BoxDecoration(
                color: colorItem.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorItem.color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    colorItem.name,
                    style: TextStyle(
                      color: _getContrastColor(colorItem.color),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '#${colorItem.color.value.toRadixString(16).substring(2).toUpperCase()}',
                    style: TextStyle(
                      color: _getContrastColor(
                        colorItem.color,
                      ).withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTypographyTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Typography System',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),

        _buildTextExample(
          context,
          'Display Large',
          Theme.of(context).textTheme.displayLarge!,
        ),
        _buildTextExample(
          context,
          'Display Medium',
          Theme.of(context).textTheme.displayMedium!,
        ),
        _buildTextExample(
          context,
          'Display Small',
          Theme.of(context).textTheme.displaySmall!,
        ),

        const Divider(height: 40),

        _buildTextExample(
          context,
          'Headline Large',
          Theme.of(context).textTheme.headlineLarge!,
        ),
        _buildTextExample(
          context,
          'Headline Medium',
          Theme.of(context).textTheme.headlineMedium!,
        ),
        _buildTextExample(
          context,
          'Headline Small',
          Theme.of(context).textTheme.headlineSmall!,
        ),

        const Divider(height: 40),

        _buildTextExample(
          context,
          'Title Large',
          Theme.of(context).textTheme.titleLarge!,
        ),
        _buildTextExample(
          context,
          'Title Medium',
          Theme.of(context).textTheme.titleMedium!,
        ),
        _buildTextExample(
          context,
          'Title Small',
          Theme.of(context).textTheme.titleSmall!,
        ),

        const Divider(height: 40),

        _buildTextExample(
          context,
          'Body Large',
          Theme.of(context).textTheme.bodyLarge!,
        ),
        _buildTextExample(
          context,
          'Body Medium',
          Theme.of(context).textTheme.bodyMedium!,
        ),
        _buildTextExample(
          context,
          'Body Small',
          Theme.of(context).textTheme.bodySmall!,
        ),

        const Divider(height: 40),

        _buildTextExample(
          context,
          'Label Large',
          Theme.of(context).textTheme.labelLarge!,
        ),
        _buildTextExample(
          context,
          'Label Medium',
          Theme.of(context).textTheme.labelMedium!,
        ),
        _buildTextExample(
          context,
          'Label Small',
          Theme.of(context).textTheme.labelSmall!,
        ),

        const Divider(height: 40),

        // Custom text styles
        Text('Custom Styles', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        _buildTextExample(
          context,
          'Blood Type',
          AppTextStyles.bloodType(context),
        ),
        _buildTextExample(
          context,
          'Emergency Text',
          AppTextStyles.emergencyText(context),
        ),
        _buildTextExample(
          context,
          'Stats Number',
          AppTextStyles.statsNumber(context),
          text: '123',
        ),
      ],
    );
  }

  Widget _buildTextExample(
    BuildContext context,
    String label,
    TextStyle style, {
    String? text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(text ?? 'The quick brown fox', style: style),
          const SizedBox(height: 4),
          Text(
            'Size: ${style.fontSize?.toStringAsFixed(0)}sp | Weight: ${style.fontWeight?.toString().split('.').last}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('UI Components', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),

        // Buttons
        Text('Buttons', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('Elevated Button'),
            ),
            FilledButton(onPressed: () {}, child: const Text('Filled Button')),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined Button'),
            ),
            TextButton(onPressed: () {}, child: const Text('Text Button')),
          ],
        ),

        const SizedBox(height: 24),

        // Cards
        Text('Cards', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Card Title',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'This is a standard Material 3 card with elevated surface.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Input Fields
        Text('Input Fields', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Label',
            hintText: 'Enter text',
            prefixIcon: Icon(Icons.person),
          ),
        ),

        const SizedBox(height: 24),

        // Chips
        Text('Chips', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            Chip(label: const Text('Chip 1')),
            Chip(
              label: const Text('Chip 2'),
              avatar: const Icon(Icons.person, size: 16),
            ),
            ActionChip(label: const Text('Action Chip'), onPressed: () {}),
            FilterChip(
              label: const Text('Filter Chip'),
              selected: true,
              onSelected: (_) {},
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Switches and Checkboxes
        Text('Toggle Controls', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Switch'),
          value: true,
          onChanged: (_) {},
        ),
        CheckboxListTile(
          title: const Text('Checkbox'),
          value: true,
          onChanged: (_) {},
        ),
        RadioListTile(
          title: const Text('Radio Button'),
          value: 1,
          groupValue: 1,
          onChanged: (_) {},
        ),

        const SizedBox(height: 24),

        // Progress Indicators
        Text(
          'Progress Indicators',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        const LinearProgressIndicator(value: 0.7),
        const SizedBox(height: 12),
        const Center(child: CircularProgressIndicator()),

        const SizedBox(height: 40),
      ],
    );
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

class ColorItem {
  final String name;
  final Color color;

  ColorItem(this.name, this.color);
}
