import 'package:alhekmah_app/core/utils/color_manager.dart';
import 'package:alhekmah_app/screen/bouquet/bouquet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/asset_manager.dart';
import 'bloc/profile_bloc.dart';

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
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state is SuccessLoadingProfileState) {
                    final profile = state.profileModel;
                    final wallet = state.walletModel;
                    return Container(
                      height: 298,
                      color: const Color(0xff088395),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 40, top: 53),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset("assets/icons/profile-user 2.png"),
                            const SizedBox(height: 10),
                            Text(
                              profile.username,
                              style: const TextStyle(
                                fontFamily: "Cairo",
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.email,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("80",
                                    style: TextStyle(
                                      fontFamily: "Cairo",
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Image.asset(AssetManager.minihead),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset("assets/icons/Line 21.png"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "${wallet.balance}",
                                    style: const TextStyle(
                                      fontFamily: "Cairo",
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Image.asset(AssetManager.feather),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is FailedLoadingProfileState) {
                    return Container(
                      height: 298,
                      color: AppColors.primaryBlue,
                      child:  Center(
                        child: Text(state.message),
                      ),
                    );
                  }
                  return Container(
                    height: 298,
                    color: const Color(0xff088395),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                },
              ),
              ListTile(
                leading:  Image.asset("assets/icons/Group 147.png"),
                title: const Text(
                  'الإشعارات',
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff5A5953),
                  ),
                ),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> BouquetScreen()),);
                },
                child: ListTile(
                  leading:  Image.asset("assets/icons/Group 148.png"),
                  title:  Text(
                    'باقات التسميع',
                    style: TextStyle(
                      fontFamily: "Cairo",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff5A5953),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Divider(),
              ),
              ListTile(
                leading:  Image.asset("assets/icons/key 1.png"),
                title: const Text(
                  'إعادة تعيين كلمة المرور',
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff5A5953),
                  ),
                ),
                onTap: (){},
              ),
              ListTile(
                leading:  Image.asset("assets/icons/logout 1 (1).png"),
                title: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff5A5953),
                  ),
                ),
                onTap: (){},
              ),
            ],
          ),
        ),
      ),
    );
  }
}