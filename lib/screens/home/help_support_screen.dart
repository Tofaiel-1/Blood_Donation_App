import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@blooddonation.app',
      query: 'subject=Help Request&body=Hello, I need help with...',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+880123456789');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact Support Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.support_agent,
                          color: Colors.red[700],
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contact Support',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'We\'re here to help you 24/7',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Icon(Icons.email, color: Colors.blue[700]),
                    title: const Text('Email Support'),
                    subtitle: const Text('support@blooddonation.app'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _launchEmail,
                  ),
                  ListTile(
                    leading: Icon(Icons.phone, color: Colors.green[700]),
                    title: const Text('Call Support'),
                    subtitle: const Text('+880 123-456-789'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _launchPhone,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // FAQ Section
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFAQItem(
            'How do I donate blood?',
            'To donate blood, go to the "Donate" tab, fill in the donation form with date, location, and hospital details. You must be 18+ years old and meet the 120-day gap requirement.',
          ),
          _buildFAQItem(
            'What is the 120-day rule?',
            'You must wait at least 120 days (4 months) between blood donations to ensure your health and safety. The app automatically tracks this for you.',
          ),
          _buildFAQItem(
            'How do I request blood?',
            'Go to the "Home" tab and tap "Request Blood". Fill in the patient details, blood type needed, hospital location, and urgency level.',
          ),
          _buildFAQItem(
            'How can I search for donors?',
            'Use the "Search" tab to find donors by blood type, location, and availability. You can filter results and contact donors directly.',
          ),
          _buildFAQItem(
            'What are badges?',
            'Badges are rewards you earn based on your donation count. They recognize your contribution as a donor and motivate continued donations.',
          ),
          _buildFAQItem(
            'How do I change my availability status?',
            'Go to your "Profile" and tap the availability dropdown. Select Available, Busy, or Unavailable based on your current status.',
          ),
          const SizedBox(height: 24),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildQuickAction(
            context,
            Icons.report_problem,
            'Report an Issue',
            'Found a bug or problem?',
            Colors.orange,
          ),
          _buildQuickAction(
            context,
            Icons.feedback,
            'Send Feedback',
            'Share your thoughts with us',
            Colors.blue,
          ),
          _buildQuickAction(
            context,
            Icons.article,
            'User Guide',
            'Learn how to use the app',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Opening $title...')));
        },
      ),
    );
  }
}
