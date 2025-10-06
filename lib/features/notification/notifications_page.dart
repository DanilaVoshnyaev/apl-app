import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../header.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _loading = true;
  bool _showArchive = false;
  List<dynamic> _notifications = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications({bool archive = false}) async {
    final app = context.read<AppState>();
    setState(() => _loading = true);

    final data = await app.fetchNotifications(archive: archive);
    if (data != null) {
      setState(() {
        _showArchive = archive;
        _notifications = List<Map<String, dynamic>>.from(data['notifications']);
        _unreadCount = data['unread_count'] ?? 0;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _archiveOne(AppState app, int id) async {
    final ok = await app.archiveNotification(id);
    if (ok) _loadNotifications(archive: _showArchive);
  }

  Future<void> _archiveAll(AppState app) async {
    final ok = await app.archiveAllNotifications();
    if (ok) _loadNotifications(archive: _showArchive);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: CustomHeader(),
      drawer: const CustomDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadNotifications(archive: _showArchive),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _showArchive
                            ? app.L('archive_notification')
                            : app.L('notification'),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (!_showArchive)
                        Text(
                          '${app.L('un_read_notification')}: $_unreadCount',
                          style: const TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (!_showArchive)
                        TextButton(
                          onPressed: () => _archiveAll(app),
                          child: Text(app.L('go_to_archive')),
                        ),
                      TextButton(
                        onPressed: () =>
                            _loadNotifications(archive: !_showArchive),
                        child: Text(_showArchive
                            ? app.L('back')
                            : app.L('show_archive')),
                      ),
                    ],
                  ),
                  const Divider(),
                  if (_notifications.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Text(
                          app.L('not_notification'),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    )
                  else
                    ..._notifications
                        .map((n) => _buildNotificationCard(app, n)),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationCard(AppState app, Map<String, dynamic> n) {
    final isCritical = n['critical'] == true;
    final isViewed = n['viewed'] == true;
    final archived = n['archived'] == true;
    final color = isCritical ? Colors.red.shade100 : Colors.blue.shade50;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCritical ? Colors.red.shade300 : Colors.grey.shade300,
        ),
      ),
      child: ListTile(
        title: Html(
          data: n['message'] ?? '',
        ),
        subtitle: Text(n['date'] ?? '',
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: !archived
            ? IconButton(
                icon: const Icon(Icons.archive_outlined),
                color: Colors.grey.shade700,
                tooltip: app.L('to_archive'),
                onPressed: () {
                  final app = context.read<AppState>();
                  _archiveOne(app, n['id']);
                },
              )
            : const Icon(Icons.archive, color: Colors.grey),
      ),
    );
  }
}
