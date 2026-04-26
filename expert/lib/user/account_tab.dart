import 'package:flutter/material.dart';
import '../auth/splash_screen.dart';
import '../data/database_helper.dart';
import '../data/models.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  final DatabaseHelper _db = DatabaseHelper();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (SessionManager.currentUserId == null) return;
    final user = await _db.getUserById(SessionManager.currentUserId!);
    if (mounted) setState(() => _user = user);
  }

  void _logout() {
    SessionManager.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar
            CircleAvatar(
              radius: 45,
              backgroundColor: const Color(0xFF2E4CB9).withAlpha(30),
              child: const Icon(Icons.person, size: 50, color: Color(0xFF2E4CB9)),
            ),
            const SizedBox(height: 16),
            Text(_user?.name ?? '-', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_user?.email ?? '-', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 30),

            // Info cards
            _infoCard(Icons.person_outline, 'Nama', _user?.name ?? '-'),
            _infoCard(Icons.email_outlined, 'Email', _user?.email ?? '-'),
            _infoCard(Icons.phone_outlined, 'Telepon', _user?.phone ?? '-'),

            const Spacer(),

            // Logout
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('LOG OUT', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E4CB9), size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
