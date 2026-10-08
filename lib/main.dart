import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ساختمان شهریار',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = TextEditingController();
  String _pass = '1234';

  @override
  void initState() {
    super.initState();
    _loadPass();
  }

  Future<void> _loadPass() async {
    final p = await SharedPreferences.getInstance();
    setState(() => _pass = p.getString('admin_pass') ?? '1234');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('ورود مدیر', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: _controller,
                obscureText: true,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'کد عبور',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_controller.text == _pass) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کد عبور نادرست است')));
                  }
                },
                child: const Padding(padding: EdgeInsets.all(12), child: Text('ورود', style: TextStyle(fontSize: 18))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selected = 0;
  final List<Member> _members = [];
  final String _cardNumber = '5022291058925981';
  final String _bankName = 'پاسارگاد';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ساختمان شهریار'), centerTitle: true),
      body: Row(
        children: [
          Container(
            width: 220,
            color: Colors.purple.shade900,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 30),
                _menuItem(0, 'خانه', Icons.home),
                _menuItem(1, 'مدیریت اعضا', Icons.people),
                _menuItem(2, 'پرداخت‌ها', Icons.payment),
                _menuItem(3, 'گزارش‌ها', Icons.description),
                _menuItem(4, 'پیامک و اطلاع‌رسانی', Icons.sms),
                _menuItem(5, 'تنظیمات', Icons.settings),
              ],
            ),
          ),
          Expanded(child: _buildScreen()),
        ],
      ),
    );
  }

  Widget _menuItem(int idx, String title, IconData icon) {
    final sel = _selected == idx;
    return ListTile(
      leading: Icon(icon, color: sel ? Colors.white : Colors.white70),
      title: Text(title, style: TextStyle(color: sel ? Colors.white : Colors.white70)),
      selected: sel,
      onTap: () => setState(() => _selected = idx),
    );
  }

  Widget _buildScreen() {
    switch (_selected) {
      case 0: return _home();
      case 1: return _membersPage();
      case 2: return _paymentsPage();
      case 3: return _reportsPage();
      case 4: return _smsPage();
      case 5: return _settingsPage();
      default: return _home();
    }
  }

  Widget _home() {
    final j = Jalali.now();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('تاریخ: ${j.formatter.yyyy}/${j.formatter.mm}/${j.formatter.dd}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 30),
          const Text('ساختمان شهریار — ۸ واحد', style: TextStyle(fontSize: 22)),
          const SizedBox(height: 10),
          Text('تعداد اعضا: ${_members.length}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          Text('کارت بانک $_bankName: $_cardNumber', style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _membersPage() {
    return Scaffold(
      body: _members.isEmpty
          ? const Center(child: Text('هنوز عضوی اضافه نشده'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _members.length,
              itemBuilder: (_, i) {
                final m = _members[i];
                return Card(
                  child: ListTile(
                    title: Text(m.name),
                    subtitle: Text('مالک: ${m.ownerPhone}\nمستاجر: ${m.tenantPhone}'),
                    isThreeLine: true,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMember,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _paymentsPage() => const Center(child: Text('مدیریت پرداخت‌ها و صندوق ساختمان'));
  Widget _smsPage() => const Center(child: Text('ارسال پیامک یادآوری و اطلاع‌رسانی'));
  Widget _settingsPage() => const Center(child: Text('تنظیمات برنامه'));

  Widget _reportsPage() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('خروجی PDF گزارش مالی'),
          onPressed: _generatePdf,
        ),
        const SizedBox(height: 20),
        const Text('ارسال گزارش از طریق واتساپ، تلگرام، ایتا و بله'),
      ],
    ),
  );

  Future<void> _addMember() async {
    final nameCtrl = TextEditingController();
    final ownerCtrl = TextEditingController();
    final tenantCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('افزودن واحد'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'نام واحد')),
          TextField(controller: ownerCtrl, decoration: const InputDecoration(labelText: 'شماره تماس مالک')),
          TextField(controller: tenantCtrl, decoration: const InputDecoration(labelText: 'شماره تماس مستاجر')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('لغو')),
          ElevatedButton(
            onPressed: () {
              setState(() => _members.add(Member(nameCtrl.text, ownerCtrl.text, tenantCtrl.text)));
              Navigator.pop(context);
            },
            child: const Text('ثبت'),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      build: (pw.Context context) => pw.Column(
        children: [
          pw.Text('گزارش گردش مالی ساختمان شهریار', style: pw.TextStyle(fontSize: 20)),
          pw.SizedBox(height: 20),
          pw.Text('تاریخ گزارش: ${Jalali.now().formatter.yyyy}/${Jalali.now().formatter.mm}/${Jalali.now().formatter.dd}'),
          pw.SizedBox(height: 10),
          pw.Text('شماره کارت بانک پاسارگاد: $_cardNumber'),
        ],
      ),
    ));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/gozaresh.pdf');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: 'گزارش مالی ساختمان شهریار');
  }
}

class Member {
  final String name;
  final String ownerPhone;
  final String tenantPhone;
  Member(this.name, this.ownerPhone, this.tenantPhone);
}
