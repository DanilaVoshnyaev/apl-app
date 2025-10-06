import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_state.dart';
import '../../core/push.dart';
import '../header.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
    setState(() {
      bonusData = result;
      loadingBonus = false;
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();

    return Scaffold(
      appBar: CustomHeader(),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== БОНУСНАЯ АКТИВНОСТЬ =====
            const Divider(height: 32),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(app.L('bonus_activiti'),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            if (loadingBonus)
              const Center(child: CircularProgressIndicator())
            else if (bonusData == null)
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(app.L('fail_load_data')),
              )
            else
              Column(
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
            const Divider(height: 32),

            // ===== НОВОСТИ =====
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(app.L('news_company'),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: app.fetchNews(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final news = snapshot.data ?? [];
                if (news.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(app.L('not_news')),
                  );
                }

                return Column(
                  children: news.map((item) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (ctx) => DraggableScrollableSheet(
                              expand: false,
                              builder: (ctx, controller) {
                                return SingleChildScrollView(
                                  controller: controller,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item['title'] ?? '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall),
                                        Image.network(
                                          "https://backoffice.aplgo.com${item["image"]}",
                                          width: double.infinity,
                                          height: 180,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.broken_image),
                                          loadingBuilder:
                                              (context, child, progress) {
                                            if (progress == null) return child;
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        Text(item['created'] ?? '',
                                            style: const TextStyle(
                                                color: Colors.grey)),
                                        const SizedBox(height: 16),
                                        Html(data: item['text'] ?? ''),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              "https://backoffice.aplgo.com${item["image"]}",
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['title'] ?? 'Без названия',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  Text(item['created'] ?? '',
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const Divider(height: 32),

            // ===== ПРОМО =====
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(app.L('promo_company'),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: app.fetchPromo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final news = snapshot.data ?? [];
                if (news.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(app.L('not_promo')),
                  );
                }

                return Column(
                  children: news.map((item) {
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (ctx) => DraggableScrollableSheet(
                              expand: false,
                              builder: (ctx, controller) {
                                return SingleChildScrollView(
                                  controller: controller,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item['title'] ?? '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall),
                                        Image.network(
                                          "https://backoffice.aplgo.com${item["image"]}",
                                          width: double.infinity,
                                          height: 180,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.broken_image),
                                          loadingBuilder:
                                              (context, child, progress) {
                                            if (progress == null) return child;
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        Text(item['created'] ?? '',
                                            style: const TextStyle(
                                                color: Colors.grey)),
                                        const SizedBox(height: 16),
                                        Html(data: item['text'] ?? ''),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              "https://backoffice.aplgo.com${item["image"]}",
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['title'] ?? 'Без названия',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  Text(item['created'] ?? '',
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const Divider(height: 32),
          ],
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
        leading: Icon(
          status ? Icons.check_circle : Icons.cancel,
          color: status ? Colors.green : Colors.red,
        ),
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
              .map((branch) => buildBranch(branch))
              .toList(),
        ],
      ),
    );
  }

  Widget buildSelfActivity(Map<String, dynamic>? selfActivity) {
    if (selfActivity == null) return const SizedBox.shrink();
    final status = selfActivity['status'] == true;
    return ExpansionTile(
      leading: Icon(
        status ? Icons.check_box : Icons.check_box_outline_blank,
        color: status ? Colors.green : Colors.red,
      ),
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
              onPressed: () {
                _openUrl(selfActivity['button']['link']);
              },
              child: Text(selfActivity['button']['text']),
            ),
          ),
      ],
    );
  }

  Widget buildBranch(Map<String, dynamic> branch) {
    final status = branch['status'] == true;
    return ExpansionTile(
      leading: Icon(
        status ? Icons.check_box : Icons.check_box_outline_blank,
        color: status ? Colors.green : Colors.red,
      ),
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
              onPressed: () {
                _openUrl(branch['button']['link']);
              },
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
            tabs: sortedKeys.map((key) {
              return Tab(
                  text: key == 'all'
                      ? partnersList['text']['branch-all']
                      : "${partnersList['text']['branch']} ${key.replaceAll("branch_", "")}");
            }).toList(),
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              children: sortedKeys.map((key) {
                final partners = branches[key]['list'] as List;
                return ListView.builder(
                  itemCount: partners.length,
                  itemBuilder: (context, i) {
                    final partner = partners[i];
                    return ListTile(
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
