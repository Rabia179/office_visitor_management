import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const VisitorApp());

const navy = Color(0xFF071923);
const panel = Color(0xFF102B35);
const teal = Color(0xFF19C3B1);
const amber = Color(0xFFF2B84B);
const green = Color(0xFF4ADE80);

class VisitorApp extends StatelessWidget {
  const VisitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Office Visitor Management',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: navy,
        colorScheme: ColorScheme.fromSeed(
          seedColor: teal,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: panel,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const VisitorHome(),
    );
  }
}

class Visitor {
  String id;
  String name;
  String phone;
  String identity;
  String host;
  String purpose;
  String date;
  String checkIn;
  String checkOut;
  String status;

  Visitor({
    required this.id,
    required this.name,
    required this.phone,
    required this.identity,
    required this.host,
    required this.purpose,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'identity': identity,
    'host': host,
    'purpose': purpose,
    'date': date,
    'checkIn': checkIn,
    'checkOut': checkOut,
    'status': status,
  };

  factory Visitor.fromJson(Map<String, dynamic> j) => Visitor(
    id: j['id'],
    name: j['name'],
    phone: j['phone'],
    identity: j['identity'],
    host: j['host'],
    purpose: j['purpose'],
    date: j['date'],
    checkIn: j['checkIn'],
    checkOut: j['checkOut'],
    status: j['status'],
  );
}

class Storage {
  static Future<List<Visitor>> getVisitors() async {
    final p = await SharedPreferences.getInstance();
    final data = p.getString('visitors');
    if (data == null) return [];

    return (jsonDecode(data) as List)
        .map((e) => Visitor.fromJson(e))
        .toList();
  }

  static Future<void> save(List<Visitor> visitors) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      'visitors',
      jsonEncode(
        visitors.map((e) => e.toJson()).toList(),
      ),
    );
  }
}

class VisitorHome extends StatefulWidget {
  const VisitorHome({super.key});

  @override
  State<VisitorHome> createState() => _VisitorHomeState();
}

class _VisitorHomeState extends State<VisitorHome> {
  int page = 0;
  bool loading = true;
  List<Visitor> visitors = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    visitors = await Storage.getVisitors();
    if (mounted) setState(() => loading = false);
  }

  Future<void> save() async {
    await Storage.save(visitors);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = [
      HomePage(visitors: visitors),
      VisitorsPage(
        visitors: visitors,
        onChanged: save,
      ),
      ActivePage(
        visitors: visitors,
        onChanged: save,
      ),
      HistoryPage(visitors: visitors),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ['Reception', 'Visitors', 'Active Visits', 'History'][page],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: navy,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Visitor records are saved locally'),
                ),
              );
            },
            icon: const Icon(Icons.security),
          ),
        ],
      ),
      body: pages[page],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0B222B),
        indicatorColor: teal,
        selectedIndex: page,
        onDestinationSelected: (v) {
          setState(() => page = v);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Visitors',
          ),
          NavigationDestination(
            icon: Icon(Icons.login_outlined),
            selectedIcon: Icon(Icons.login),
            label: 'Active',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Visitor> visitors;

  const HomePage({
    super.key,
    required this.visitors,
  });

  @override
  Widget build(BuildContext context) {
    final active =
        visitors.where((v) => v.status == 'Checked In').length;

    final today = visitors.where(
          (v) =>
      v.date ==
          '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
    ).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Office Reception',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Secure visitor management system',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.people,
                title: 'Total Visitors',
                value: '${visitors.length}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.login,
                title: 'Active',
                value: '$active',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.today,
                title: 'Today',
                value: '$today',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.verified_user,
                title: 'Secure',
                value: 'ON',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Reception Workflow',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const WorkflowTile(
          icon: Icons.person_add,
          title: 'Register Visitor',
          text: 'Record visitor information',
        ),
        const WorkflowTile(
          icon: Icons.badge,
          title: 'Issue Visitor Pass',
          text: 'Generate a digital visitor pass',
        ),
        const WorkflowTile(
          icon: Icons.login,
          title: 'Check In',
          text: 'Track visitors inside the office',
        ),
        const WorkflowTile(
          icon: Icons.logout,
          title: 'Check Out',
          text: 'Complete the visit safely',
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: panel,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: teal, size: 28),
            const SizedBox(height: 13),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkflowTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const WorkflowTile({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: panel,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: teal,
          foregroundColor: Colors.black,
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(text),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class VisitorsPage extends StatefulWidget {
  final List<Visitor> visitors;
  final VoidCallback onChanged;

  const VisitorsPage({
    super.key,
    required this.visitors,
    required this.onChanged,
  });

  @override
  State<VisitorsPage> createState() => _VisitorsPageState();
}

class _VisitorsPageState extends State<VisitorsPage> {
  String search = '';

  Future<void> addVisitor() async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final identity = TextEditingController();
    final host = TextEditingController();
    final purpose = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register Visitor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Visitor Name',
                ),
              ),
              TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                ),
              ),
              TextField(
                controller: identity,
                decoration: const InputDecoration(
                  labelText: 'ID / CNIC',
                ),
              ),
              TextField(
                controller: host,
                decoration: const InputDecoration(
                  labelText: 'Host / Employee',
                ),
              ),
              TextField(
                controller: purpose,
                decoration: const InputDecoration(
                  labelText: 'Visit Purpose',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (name.text.trim().isEmpty) return;

              final now = DateTime.now();

              widget.visitors.insert(
                0,
                Visitor(
                  id: now.millisecondsSinceEpoch.toString(),
                  name: name.text.trim(),
                  phone: phone.text.trim(),
                  identity: identity.text.trim(),
                  host: host.text.trim(),
                  purpose: purpose.text.trim(),
                  date:
                  '${now.day}/${now.month}/${now.year}',
                  checkIn:
                  '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                  checkOut: '',
                  status: 'Checked In',
                ),
              );

              widget.onChanged();

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  Future<void> editVisitor(Visitor v) async {
    final name = TextEditingController(text: v.name);
    final phone = TextEditingController(text: v.phone);
    final identity = TextEditingController(text: v.identity);
    final host = TextEditingController(text: v.host);
    final purpose = TextEditingController(text: v.purpose);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Visitor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration:
                const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phone,
                decoration:
                const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: identity,
                decoration:
                const InputDecoration(labelText: 'ID / CNIC'),
              ),
              TextField(
                controller: host,
                decoration:
                const InputDecoration(labelText: 'Host'),
              ),
              TextField(
                controller: purpose,
                decoration:
                const InputDecoration(labelText: 'Purpose'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              v.name = name.text.trim();
              v.phone = phone.text.trim();
              v.identity = identity.text.trim();
              v.host = host.text.trim();
              v.purpose = purpose.text.trim();

              widget.onChanged();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void deleteVisitor(Visitor v) {
    widget.visitors.removeWhere((x) => x.id == v.id);
    widget.onChanged();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.visitors.where((v) {
      final q = search.toLowerCase();
      return v.name.toLowerCase().contains(q) ||
          v.host.toLowerCase().contains(q) ||
          v.phone.contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (v) => setState(() => search = v),
            decoration: const InputDecoration(
              hintText: 'Search visitors...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? const Center(
            child: Text('No visitors found'),
          )
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              90,
            ),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final v = list[i];

              return Card(
                color: panel,
                margin:
                const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.all(12),
                  leading: const CircleAvatar(
                    backgroundColor: teal,
                    foregroundColor: Colors.black,
                    child: Icon(Icons.person),
                  ),
                  title: Text(
                    v.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Host: ${v.host}\n'
                        '${v.purpose} • ${v.status}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        editVisitor(v);
                      } else if (value == 'pass') {
                        showPass(v);
                      } else {
                        deleteVisitor(v);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: 'pass',
                        child: Text('Visitor Pass'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: addVisitor,
              icon: const Icon(Icons.person_add),
              label: const Text('Register New Visitor'),
            ),
          ),
        ),
      ],
    );
  }

  void showPass(Visitor v) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('VISITOR PASS'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: teal,
              foregroundColor: Colors.black,
              child: Icon(Icons.badge, size: 32),
            ),
            const SizedBox(height: 15),
            Text(
              v.name,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Host: ${v.host}'),
            Text('Purpose: ${v.purpose}'),
            Text('Pass ID: ${v.id.substring(v.id.length - 6)}'),
            const SizedBox(height: 10),
            Text(
              v.status,
              style: const TextStyle(
                color: green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class ActivePage extends StatelessWidget {
  final List<Visitor> visitors;
  final VoidCallback onChanged;

  const ActivePage({
    super.key,
    required this.visitors,
    required this.onChanged,
  });

  void checkout(BuildContext context, Visitor v) {
    final now = DateTime.now();

    v.status = 'Checked Out';
    v.checkOut =
    '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    onChanged();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${v.name} checked out successfully'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active =
    visitors.where((v) => v.status == 'Checked In').toList();

    if (active.isEmpty) {
      return const Center(
        child: Text('No active visitors'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: active.length,
      itemBuilder: (_, i) {
        final v = active[i];

        return Card(
          color: panel,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: green,
                      foregroundColor: Colors.black,
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          Text('Host: ${v.host}'),
                          Text('Check-in: ${v.checkIn}'),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.circle,
                      color: green,
                      size: 12,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => checkout(context, v),
                    icon: const Icon(Icons.logout),
                    label: const Text('Check Out'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HistoryPage extends StatefulWidget {
  final List<Visitor> visitors;

  const HistoryPage({
    super.key,
    required this.visitors,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final list = widget.visitors.where((v) {
      final q = search.toLowerCase();
      return v.name.toLowerCase().contains(q) ||
          v.host.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (v) => setState(() => search = v),
            decoration: const InputDecoration(
              hintText: 'Search visitor history...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? const Center(
            child: Text('No visitor history'),
          )
              : ListView.builder(
            padding:
            const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final v = list[i];

              return Card(
                color: panel,
                margin:
                const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(
                    v.status == 'Checked Out'
                        ? Icons.logout
                        : Icons.login,
                    color: v.status == 'Checked Out'
                        ? amber
                        : green,
                  ),
                  title: Text(v.name),
                  subtitle: Text(
                    '${v.date} • ${v.host}\n'
                        'In: ${v.checkIn}  '
                        'Out: ${v.checkOut.isEmpty ? '--' : v.checkOut}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    v.status,
                    style: TextStyle(
                      color: v.status == 'Checked Out'
                          ? amber
                          : green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}