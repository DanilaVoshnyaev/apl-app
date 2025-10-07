import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/web_container.dart';
import '../header.dart';

class BonusActivityPage extends StatefulWidget {
  const BonusActivityPage({super.key});

  @override
  State<BonusActivityPage> createState() => _BonusActivityPageState();
}

class _BonusActivityPageState extends State<BonusActivityPage> {
  Map<String, dynamic>? bonusData;
  bool loadingBonus = true;

  @override
  void initState() {
    super.initState();
    _loadBonusData();
  }

  Future<void> _loadBonusData() async {
    final app = context.read<AppState>();
    final result = await app.getBonusActivityData();
    if (!mounted) return;
    setState(() {
      bonusData = result;
      loadingBonus = false;
    });
  }

  Future<void> _openUrl(BuildContext context, String url,
      {String? title}) async {
    if (url.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WebContainer(url: url, title: title ?? 'Просмотр'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();

    return Scaffold(
      appBar: CustomHeader(),
      drawer: const CustomDrawer(),
      body: loadingBonus
          ? const Center(child: CircularProgressIndicator())
          : bonusData == null
              ? Center(child: Text(app.L('fail_load_data')))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        buildActivityBlock(
                            bonusData!['this-month'], app.L('this_month')),
                        const SizedBox(height: 12),
                        buildActivityBlock(
                            bonusData!['next-month'], app.L('next_month')),
                        const SizedBox(height: 12),
                        buildPartnersBlock(bonusData!['partners-list']),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget buildActivityBlock(Map<String, dynamic>? monthData, String title) {
    if (monthData == null) return const SizedBox.shrink();
    final status = monthData['status'] == true;
    return Card(
      color: status ? Colors.green[50] : Colors.red[50],
      child: ExpansionTile(
        leading: Icon(status ? Icons.check_circle : Icons.cancel,
            color: status ? Colors.green : Colors.red),
        title: Text(monthData['text'] ?? title),
        children: [
          if ((monthData['description'] as String?)?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(monthData['description'],
                  style: const TextStyle(color: Colors.grey)),
            ),
          buildSelfActivity(monthData['self-activity']),
          ...(monthData['branches'] as List<dynamic>)
              .map((b) => buildBranch(b))
              .toList(),
        ],
      ),
    );
  }

  Widget buildSelfActivity(Map<String, dynamic>? selfActivity) {
    if (selfActivity == null) return const SizedBox.shrink();
    final status = selfActivity['status'] == true;
    return ExpansionTile(
      leading: Icon(status ? Icons.check_box : Icons.check_box_outline_blank,
          color: status ? Colors.green : Colors.red),
      title: Text(selfActivity['text'] ?? "Личная активность"),
      children: [
        if ((selfActivity['description'] as String?)?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(selfActivity['description'],
                style: const TextStyle(color: Colors.grey)),
          ),
        buildParams(selfActivity['params'] ?? []),
        if (selfActivity['button'] != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () => _openUrl(
                context,
                selfActivity['button']['link'],
                title: selfActivity['button']['text'],
              ),
              child: Text(selfActivity['button']['text']),
            ),
          ),
      ],
    );
  }

  Widget buildBranch(Map<String, dynamic> branch) {
    final status = branch['status'] == true;
    return ExpansionTile(
      leading: Icon(status ? Icons.check_box : Icons.check_box_outline_blank,
          color: status ? Colors.green : Colors.red),
      title: Text(branch['text']),
      children: [
        if ((branch['description'] as String?)?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(branch['description'],
                style: const TextStyle(color: Colors.grey)),
          ),
        buildParams(branch['params'] ?? []),
        if (branch['button'] != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextButton(
              onPressed: () => _openUrl(
                context,
                branch['button']['link'],
                title: branch['button']['text'],
              ),
              child: Text(branch['button']['text']),
            ),
          ),
      ],
    );
  }

  Widget buildParams(List params, {bool nested = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: params.map<Widget>((param) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 4, horizontal: nested ? 16 : 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(param['text'] ?? '',
                      style: TextStyle(
                          color: nested ? Colors.grey : Colors.black)),
                  Text(param['status'] ?? '',
                      style: TextStyle(
                        fontWeight:
                            nested ? FontWeight.normal : FontWeight.bold,
                        color: Colors.grey[700],
                      )),
                ],
              ),
            ),
            if (param['params'] != null)
              buildParams(param['params'], nested: true),
          ],
        );
      }).toList(),
    );
  }

  Widget buildPartnersBlock(Map<String, dynamic>? partnersList) {
    if (partnersList == null) return const SizedBox.shrink();
    final branches = partnersList['data'] as Map<String, dynamic>;
    final sortedKeys = branches.keys.toList()..sort();

    return DefaultTabController(
      length: sortedKeys.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.primary,
            tabs: sortedKeys.map((key) {
              return Tab(
                text: key == 'all'
                    ? partnersList['text']['branch-all']
                    : "${partnersList['text']['branch']} ${key.replaceAll("branch_", "")}",
              );
            }).toList(),
          ),
          // 👇 исправленный блок с полной высотой и нормальным скроллом
          SizedBox(
            height: MediaQuery.of(context).size.height -
                kToolbarHeight - // высота AppBar
                180, // примерный запас под табы и отступы
            child: TabBarView(
              children: sortedKeys.map((key) {
                final partners = branches[key]['list'] as List;
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 32),
                  // чтобы не обрезался
                  itemCount: partners.length,
                  itemBuilder: (_, i) {
                    final partner = partners[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(partner['image']),
                      ),
                      title: Text("${partner['login']} ${partner['fio']}"),
                      subtitle: Row(
                        children: [
                          Chip(
                            label: Text(partnersList['text']['this-month']),
                            backgroundColor: partner['this-month']
                                ? Colors.green[100]
                                : Colors.red[100],
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(partnersList['text']['next-month']),
                            backgroundColor: partner['next-month']
                                ? Colors.green[100]
                                : Colors.red[100],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
