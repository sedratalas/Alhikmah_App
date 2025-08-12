import 'package:alhekmah_app/core/utils/color_manager.dart';
import 'package:flutter/material.dart';
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 250,
                color: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.account_circle,
                        size: 80,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'مريم حسان',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '0930195053',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildCreditItem(
                          icon: Icons.headphones,
                          value: '80',
                          color: Colors.white,
                        ),
                        const SizedBox(width: 16),
                        _buildCreditItem(
                          icon: Icons.abc,
                          value: '150',
                          color: Colors.amber,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // خيارات القائمة
              _buildDrawerItem(
                icon: Icons.notifications,
                title: 'الإشعارات',
                onTap: () {
                  // هنا يتم تنفيذ الإجراء عند الضغط
                },
              ),
              _buildDrawerItem(
                icon: Icons.redeem,
                title: 'باقات التسميع',
                onTap: () {
                  // هنا يتم الانتقال إلى صفحة باقات التسميع
                },
              ),
              const Divider(), // خط فاصل
              _buildDrawerItem(
                icon: Icons.vpn_key,
                title: 'إعادة تعيين كلمة المرور',
                onTap: () {
                  // هنا يتم الانتقال إلى صفحة إعادة تعيين كلمة المرور
                },
              ),
              _buildDrawerItem(
                icon: Icons.logout,
                title: 'تسجيل الخروج',
                onTap: () {
                  // هنا يتم تنفيذ إجراء تسجيل الخروج
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة مساعدة لإنشاء عناصر القائمة
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Function() onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.blueGrey,
        ),
      ),
      onTap: onTap,
    );
  }

  // دالة مساعدة لإنشاء عناصر الرصيد
  Widget _buildCreditItem({required IconData icon, required String value, required Color color}) {
    return Row(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          icon,
          color: color,
        ),
      ],
    );
  }
}