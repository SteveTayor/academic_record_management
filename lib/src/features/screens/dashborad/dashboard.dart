import 'package:flutter/material.dart';

// lib/pages/dashboard_page.dart


import '../../../core/model/activity_item.dart';
import '../../../core/service/data_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DataService _dataService = DataService();

  List<ActivityItem> recentActivities = [];
  bool _isLoading = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });
    try {
      final activities = await _dataService.fetchRecentActivities();
      setState(() {
        recentActivities = activities;
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to load recent activities: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1) Side Navigation
          Container(
            width: 250,
            color: Colors.deepPurple.shade700,
            child: _buildSideNav(),
          ),
          // 2) Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 16),
                  _buildSystemOverview(context),
                  const SizedBox(height: 16),
                  _buildRecentActivity(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNav() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          children: [
            Text(
              'SecureAuth',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            _buildNavItem(
              icon: Icons.description_outlined,
              label: 'Documents',
              onTap: () {},
            ),
            _buildNavItem(
              icon: Icons.people_outline,
              label: 'Users',
              onTap: () {},
            ),
            _buildNavItem(
              icon: Icons.lock_clock_outlined,
              label: 'Access Logs',
              onTap: () {},
            ),
            _buildNavItem(
              icon: Icons.analytics_outlined,
              label: 'Reports',
              onTap: () {},
            ),
            const Spacer(),
            ListTile(
              leading: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white54,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: const Text(
                'Admin User',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'System Administrator',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          const Text(
            'Dashboard > Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSystemOverview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _buildOverviewCard(
            title: 'Documents',
            value: '156 active docs',
            buttonText: 'Manage Documents',
            icon: Icons.description_outlined,
            onPressed: () {},
          ),
          _buildOverviewCard(
            title: 'Users',
            value: '1,234 registered users',
            buttonText: 'View Users',
            icon: Icons.people_outline,
            onPressed: () {},
          ),
          _buildOverviewCard(
            title: 'Access Logs',
            value: '892 events today',
            buttonText: 'View Logs',
            icon: Icons.lock_clock_outlined,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String value,
    required String buttonText,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.deepPurple.shade700, size: 28),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade700,
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              offset: const Offset(0, 2),
              blurRadius: 5,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_message.isNotEmpty)
              Text(
                _message,
                style: const TextStyle(color: Colors.red),
              )
            else
              _buildActivityTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTable() {
    if (recentActivities.isEmpty) {
      return const Text('No recent activity.');
    }

    return DataTable(
      columns: const [
        DataColumn(label: Text('Event')),
        DataColumn(label: Text('User/Document')),
        DataColumn(label: Text('Time')),
        DataColumn(label: Text('Status')),
      ],
      rows: recentActivities.map((activity) {
        return DataRow(cells: [
          DataCell(Text(activity.event)),
          DataCell(Text(activity.userOrDocument)),
          DataCell(Text(
            // example: how long ago from now
            '${_timeAgoString(activity.time)}',
          )),
          DataCell(
            Text(
              activity.success ? 'Successful' : 'Failed',
              style: TextStyle(
                color: activity.success ? Colors.green : Colors.red,
              ),
            ),
          ),
        ]);
      }).toList(),
    );
  }

  // Example function to display "time ago"
  String _timeAgoString(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}
