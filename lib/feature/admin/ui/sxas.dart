import 'package:flutter/material.dart';

// --- الألوان الموحدة للمشروع ---
const Color primaryNavy = Color(0xFF0D1B3E); // الأزرق الملكي
const Color goldAccent = Color(0xFFC5A059);  // الذهبي الفاخر
const Color bgLight = Color(0xFFF2EFE9);     // الكريمي الملكي

void main() {
  runApp(const MaterialApp(
    home: OrdersListScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

// =============================================================================
// الشاشة الأولى: قائمة إدارة الطلبات
// =============================================================================
class OrdersListScreen extends StatelessWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: primaryNavy,
          elevation: 0,
          title: const Text('إدارة الطلبات الواردة', 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          leading: const Icon(Icons.menu, color: Colors.white),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3.0),
            child: Container(color: goldAccent, height: 3.0),
          ),
        ),
        body: Column(
          children: [
            // شريط البحث بتصميم ملكي
            _buildSearchBar(),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(15),
                children: [
                  _buildOrderItem(context, 'سارة محمد عبد الرحمن', 'جديد', Colors.blue, '2024/03/15'),
                  _buildOrderItem(context, 'أحمد علي محمد', 'قيد التحكيم', Colors.orange, '2024/03/10'),
                  _buildOrderItem(context, 'منى محمود حسن', 'معتمد', Colors.green, '2024/03/05'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.white,
      child: TextField(
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: 'بحث عن طلب برقم الهوية أو الاسم...',
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: primaryNavy),
          filled: true,
          fillColor: bgLight.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, String name, String status, Color statusColor, String date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: goldAccent.withOpacity(0.3), width: 1),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FullEmployeeReportScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              // الحالة في اليسار
              _buildStatusBadge(status, statusColor),
              const Spacer(),
              // البيانات
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(name, style: const TextStyle(color: primaryNavy, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(width: 15),
              // الأيقونة
              _buildIconFrame(Icons.description_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildIconFrame(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: goldAccent),
        color: primaryNavy.withOpacity(0.05),
      ),
    );
  }
}

// =============================================================================
// الشاشة الثانية: مراجعة ملف الموظف
// =============================================================================
class FullEmployeeReportScreen extends StatelessWidget {
  const FullEmployeeReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: primaryNavy,
          elevation: 0,
          title: const Text('مراجعة الملف والاعتماد', 
              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(color: goldAccent, height: 2.0),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildEmployeeHeader(),
              _buildSectionTitle("الموقف الوظيفي والترقيات"),
              _buildInfoBox([
                _buildInfoRow("تاريخ التعيين:", "15/09/2014"),
                _buildInfoRow("آخر ترقية:", "01/01/2020"),
                _buildInfoRow("الدرجة الحالية:", "أستاذ مشارك"),
              ]),
              _buildStatusCheck("استيفاء الشروط القانونية للترقية"),
              
              _buildSectionTitle("السجل الانضباطي"),
              _buildInfoBox([
                _buildInfoRow("عدد الجزاءات:", "0"),
                _buildInfoRow("الموقف الانضباطي:", "سليم"),
              ]),
              
              const SizedBox(height: 30),
              _buildActionSection(),
            ],
          ),
        ),
      ),
    );
  }

  // --- دوال مساعدة إضافية لتنظيم الكود ---
  Widget _buildEmployeeHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: goldAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 30, backgroundColor: primaryNavy, child: Icon(Icons.person, color: goldAccent, size: 35)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('د. رامي عبد العزيز', style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold, fontSize: 17)),
              Text('الرقم الوظيفي: 44201', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: primaryNavy.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: const Border(right: BorderSide(color: goldAccent, width: 4)),
      ),
      child: Text(title, style: const TextStyle(color: primaryNavy, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildInfoBox(List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(children: rows),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(fontSize: 12, color: primaryNavy, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatusCheck(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: goldAccent, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryNavy,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: goldAccent)),
      ),
      onPressed: () {},
      icon: const Icon(Icons.verified, color: goldAccent),
      label: const Text("اعتماد الملف النهائي", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }
}