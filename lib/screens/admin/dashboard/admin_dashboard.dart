import 'package:flutter/material.dart';
import 'widgets/stat_card.dart';
import 'widgets/control_panel_card.dart';
import 'widgets/activity_log_list.dart';
import 'widgets/analytics_chart.dart';
import 'widgets/create_user_dialog.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.local_hospital, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Admin Dashboard'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle profile actions
            },
            itemBuilder: (BuildContext context) {
              return {'Profile', 'Settings', 'Logout'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: CircleAvatar(
                backgroundColor: Colors.red,
                child: Text('AD', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return _buildDesktopLayout(context);
          } else {
            return _buildMobileLayout(context);
          }
        },
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Text(
                'Admin Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Users'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Events'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.summarize),
              title: const Text('Reports'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsGrid(context, crossAxisCount: 2),
          const SizedBox(height: 24),
          Text('Operations', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildControlPanelGrid(context, crossAxisCount: 2),
          const SizedBox(height: 24),
          const DonationTrendsChart(),
          const SizedBox(height: 24),
          _buildActivityLogs(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NavigationRail(
          selectedIndex: 0,
          onDestinationSelected: (int index) {},
          labelType: NavigationRailLabelType.all,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.dashboard),
              label: Text('Dashboard'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.people),
              label: Text('Users'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.event),
              label: Text('Events'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.summarize),
              label: Text('Reports'),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsGrid(context, crossAxisCount: 4),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Operations',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          _buildControlPanelGrid(context, crossAxisCount: 3),
                          const SizedBox(height: 24),
                          const DonationTrendsChart(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: Column(children: [_buildActivityLogs()]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, {required int crossAxisCount}) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        StatCard(
          title: 'Total Users',
          value: '543',
          icon: Icons.people,
          color: Colors.blue,
          onTap: () {},
        ),
        StatCard(
          title: 'Approved Donors',
          value: '420',
          icon: Icons.check_circle,
          color: Colors.green,
          onTap: () {},
        ),
        StatCard(
          title: 'Events',
          value: '5',
          icon: Icons.event,
          color: Colors.orange,
          onTap: () {},
        ),
        StatCard(
          title: 'Completed',
          value: '120',
          icon: Icons.task_alt,
          color: Colors.purple,
          onTap: () {},
        ),
        StatCard(
          title: 'Pending',
          value: '15',
          icon: Icons.pending,
          color: Colors.amber,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildControlPanelGrid(
    BuildContext context, {
    required int crossAxisCount,
  }) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: [
        ControlPanelCard(
          title: 'Add User',
          icon: Icons.person_add,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const CreateUserDialog(),
            );
          },
        ),
        ControlPanelCard(
          title: 'Manage Users',
          icon: Icons.manage_accounts,
          onTap: () {},
        ),
        ControlPanelCard(title: 'Org Info', icon: Icons.info, onTap: () {}),
        ControlPanelCard(
          title: 'Create Event',
          icon: Icons.add_box,
          onTap: () {},
        ),
        ControlPanelCard(
          title: 'Donation Status',
          icon: Icons.update,
          onTap: () {},
        ),
        ControlPanelCard(title: 'Reports', icon: Icons.bar_chart, onTap: () {}),
      ],
    );
  }

  Widget _buildActivityLogs() {
    return ActivityLogList(
      logs: const [
        {'action': 'User Approved', 'time': '10 mins ago', 'user': 'Admin'},
        {'action': 'Event Created', 'time': '2 hours ago', 'user': 'Admin'},
        {'action': 'Donation Verified', 'time': '4 hours ago', 'user': 'Admin'},
      ],
    );
  }
}
