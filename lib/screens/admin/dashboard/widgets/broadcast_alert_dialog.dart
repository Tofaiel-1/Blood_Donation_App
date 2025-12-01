import 'package:flutter/material.dart';
import '../../../../services/broadcast_alert_service.dart';
import '../../../../models/broadcast_alert.dart';
import '../../../../utils/app_colors.dart';

class BroadcastAlertDialog extends StatefulWidget {
  const BroadcastAlertDialog({super.key});

  @override
  State<BroadcastAlertDialog> createState() => _BroadcastAlertDialogState();
}

class _BroadcastAlertDialogState extends State<BroadcastAlertDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BroadcastAlertService _alertService = BroadcastAlertService();

  // Form controllers
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  AlertType _selectedType = AlertType.general;
  AlertTarget _selectedTarget = AlertTarget.all;
  String? _targetValue;
  bool _isSending = false;

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isSmallScreen ? screenWidth * 0.95 : 600,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.campaign, color: AppColors.bloodRed, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Broadcast Alert',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: AppColors.bloodRed,
              indicatorColor: AppColors.bloodRed,
              tabs: const [
                Tab(icon: Icon(Icons.send), text: 'Send Alert'),
                Tab(icon: Icon(Icons.history), text: 'History'),
              ],
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSendAlertTab(isSmallScreen),
                  _buildHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendAlertTab(bool isSmallScreen) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Field
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Alert Title *',
              hintText: 'Enter alert title',
              prefixIcon: const Icon(Icons.title),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLength: 100,
          ),
          const SizedBox(height: 16),

          // Message Field
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              labelText: 'Message *',
              hintText: 'Enter your message here...',
              prefixIcon: const Icon(Icons.message),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            maxLength: 500,
          ),
          const SizedBox(height: 16),

          // Alert Type Selection
          Text(
            'Alert Type',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AlertType.values.map((type) {
              final isSelected = _selectedType == type;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(BroadcastAlert.getAlertIcon(type)),
                    const SizedBox(width: 4),
                    Text(type.name.toUpperCase()),
                  ],
                ),
                selected: isSelected,
                selectedColor: Color(BroadcastAlert.getAlertColor(type)),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedType = type);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Target Selection
          Text(
            'Target Audience',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AlertTarget.values.map((target) {
              final isSelected = _selectedTarget == target;
              return ChoiceChip(
                label: Text(BroadcastAlert.getTargetName(target)),
                selected: isSelected,
                selectedColor: AppColors.bloodRed,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedTarget = target;
                      if (target != AlertTarget.bloodType) {
                        _targetValue = null;
                      }
                    });
                  }
                },
              );
            }).toList(),
          ),

          // Blood Type Selector (if bloodType target selected)
          if (_selectedTarget == AlertTarget.bloodType) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _targetValue,
              decoration: InputDecoration(
                labelText: 'Select Blood Type *',
                prefixIcon: const Icon(Icons.bloodtype),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _bloodTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() => _targetValue = value);
              },
            ),
          ],

          const SizedBox(height: 24),

          // Preview Card
          Card(
            color: Color(
              BroadcastAlert.getAlertColor(_selectedType),
            ).withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        BroadcastAlert.getAlertIcon(_selectedType),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Preview',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(
                    _titleController.text.isEmpty
                        ? '(No title)'
                        : _titleController.text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _messageController.text.isEmpty
                        ? '(No message)'
                        : _messageController.text,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(_selectedType.name.toUpperCase()),
                        backgroundColor: Color(
                          BroadcastAlert.getAlertColor(_selectedType),
                        ).withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: Color(
                            BroadcastAlert.getAlertColor(_selectedType),
                          ),
                          fontSize: 12,
                        ),
                      ),
                      Chip(
                        label: Text(
                          BroadcastAlert.getTargetName(_selectedTarget),
                        ),
                        backgroundColor: AppColors.bloodRed.withValues(
                          alpha: 0.2,
                        ),
                        labelStyle: TextStyle(
                          color: AppColors.bloodRed,
                          fontSize: 12,
                        ),
                      ),
                      if (_targetValue != null)
                        Chip(
                          label: Text(_targetValue!),
                          backgroundColor: Colors.red.withValues(alpha: 0.2),
                          labelStyle: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Send Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isSending ? null : _sendAlert,
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(_isSending ? 'Sending...' : 'Send Broadcast Alert'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bloodRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return StreamBuilder<List<BroadcastAlert>>(
      stream: _alertService.getAllAlerts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final alerts = snapshot.data ?? [];

        if (alerts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No broadcast alerts sent yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(
                    BroadcastAlert.getAlertColor(alert.type),
                  ).withValues(alpha: 0.2),
                  child: Text(
                    BroadcastAlert.getAlertIcon(alert.type),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                title: Text(
                  alert.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(alert.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
                trailing: alert.isActive
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.cancel, color: Colors.grey),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _sendAlert() async {
    // Validation
    if (_titleController.text.trim().isEmpty) {
      _showError('Please enter alert title');
      return;
    }
    if (_messageController.text.trim().isEmpty) {
      _showError('Please enter alert message');
      return;
    }
    if (_selectedTarget == AlertTarget.bloodType && _targetValue == null) {
      _showError('Please select a blood type');
      return;
    }

    setState(() => _isSending = true);

    try {
      await _alertService.createAlert(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        type: _selectedType,
        target: _selectedTarget,
        targetValue: _targetValue,
      );

      if (!mounted) return;

      // Clear form
      _titleController.clear();
      _messageController.clear();
      setState(() {
        _selectedType = AlertType.general;
        _selectedTarget = AlertTarget.all;
        _targetValue = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Broadcast alert sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Switch to history tab
      _tabController.animateTo(1);
    } catch (e) {
      _showError('Failed to send alert: $e');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}
