import 'package:flutter/material.dart';
import '../../../../core/service/document_service.dart';
import '../../../widgets/sidebar.dart';
import '../../dashborad/dashboard.dart';
import '../../searc/search_screen.dart';
import 'doc_overview_content.dart';
import 'ocr_upload_content.dart'; // Import the new widget

class DocumentOverviewScreen extends StatefulWidget {
  const DocumentOverviewScreen({super.key});

  @override
  State<DocumentOverviewScreen> createState() => _DocumentOverviewScreenState();
}

class _DocumentOverviewScreenState extends State<DocumentOverviewScreen> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final DocumentService documentService = DocumentService();

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
                            _navigatorKey.currentState?.pushNamed('search'),
                      ),
                    );
                  case 'ocr-upload':
                    return MaterialPageRoute(
                        builder: (_) => const OcrUploadContent());
                  case 'search':
                    return MaterialPageRoute(
                      builder: (_) => SearchScreen(
                        documentService: documentService,
                        selectedMenu: 'Documents',
                        onMenuSelected: (menu) =>
                            _onSidebarMenuSelected(menu, context),
                      ),
                    );
                  default:
                    return MaterialPageRoute(
                      builder: (_) => OverviewContent(
                        onOcrUploadPressed: () =>
                            _navigatorKey.currentState?.pushNamed('ocr-upload'),
                        onSearchPressed: () =>
                            _navigatorKey.currentState?.pushNamed('search'),
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
