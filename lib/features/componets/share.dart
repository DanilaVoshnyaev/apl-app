import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';

void showSharingPopup(BuildContext context) {
  final appState = Provider.of<AppState>(context, listen: false);
  final login = (appState.user?['login'] ?? '').toString();

  final registrationLink = "https://backoffice.aplgo.com/register/?sp=$login";
  final partnerLink = "https://aplgo.com/j/$login";
  final shopLink = "https://aplshop.com/j/$login";
  final catalogLink = "https://aplshop.com/j/$login/catalog/";

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appState.L('share_partner'),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _shareItem(ctx, appState.L('reg_in_backoffice'), registrationLink),
            _shareItem(ctx, appState.L('share_partner'), partnerLink),
            const Divider(),
            Text(appState.L('share_client'),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _shareItem(ctx, appState.L('store'), shopLink),
            _shareItem(ctx, appState.L('catalog'), catalogLink),
          ],
        ),
      ),
    ),
  );
}

Widget _shareItem(BuildContext context, String title, String link) {
  final appState = Provider.of<AppState>(context, listen: false);
  return Card(
    child: ListTile(
      title: Text(title),
      subtitle: Text(link),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: link));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(appState.L('copy_link')),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(appState.L('qr_code')),
                  content: SizedBox(
                    width: 220,
                    height: 220,
                    child: Center(
                      child: QrImageView(
                        data: link,
                        version: QrVersions.auto,
                        gapless: true,
                        size: 200,
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(appState.L('close')),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
