import 'package:flutter/material.dart';
import '../../../widgets/sidebar.dart';
import '../../dashborad/dashboard.dart';
import 'doc_overview_content.dart';
import 'ocr_upload_content.dart'; // Import the new widget

class DocumentOverviewScreen extends StatefulWidget {
  const DocumentOverviewScreen({Key? key}) : super(key: key);

  @override
  State<DocumentOverviewScreen> createState() => _DocumentOverviewScreenState();
}

class _DocumentOverviewScreenState extends State<DocumentOverviewScreen> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedMenu: 'Documents',
            onMenuSelected: (menu) => _onSidebarMenuSelected(menu, context),
          ),
          Expanded(
            child: Navigator(
              key: _navigatorKey,
              initialRoute: 'overview',
              onGenerateRoute: (settings) {
                switch (settings.name) {
                  case 'overview':
                    return MaterialPageRoute(
                      builder: (_) => OverviewContent(
                        onOcrUploadPressed: () =>
                            _navigatorKey.currentState?.pushNamed('ocr-upload'),
                        onSearchPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Search not implemented yet')),
                        ), // Placeholder for search
                      ),
                    );
                  case 'ocr-upload':
                    return MaterialPageRoute(
                        builder: (_) => const OcrUploadContent());
                  default:
                    return MaterialPageRoute(
                      builder: (_) => OverviewContent(
                        onOcrUploadPressed: () =>
                            _navigatorKey.currentState?.pushNamed('ocr-upload'),
                        onSearchPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Search not implemented yet')),
                        ),
                      ),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onSidebarMenuSelected(String menu, BuildContext context) {
    if (menu == 'Documents') {
      _navigatorKey.currentState
          ?.popUntil((route) => route.settings.name == 'overview');
    } else if (menu == 'Overview') {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const DashboardPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigate to $menu')),
      );
    }
  }
}
