import 'package:alhekmah_app/core/utils/asset_manager.dart';
import 'package:alhekmah_app/core/utils/color_manager.dart';
import 'package:alhekmah_app/screen/widget/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'payment_screen.dart';
import '../widget/bloc/profile_bloc.dart';



class BouquetScreen extends StatefulWidget {
  const BouquetScreen({super.key});

  @override
  State<BouquetScreen> createState() => _BouquetScreenState();
}

class _BouquetScreenState extends State<BouquetScreen> {
  late double screenWidth;
  late double screenHeight;
  @override
  Widget build(BuildContext context) {
    screenWidth =MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: AppDrawer(

        ),
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: "Cairo"
          ),
          leading: Builder(
            builder: (context) {
              return GestureDetector(
                onTap: (){
                  BlocProvider.of<ProfileBloc>(context).add(FetchUserProfile());
                  Scaffold.of(context).openDrawer();
                },
                child: Padding(
                    padding:  EdgeInsets.only(right: screenWidth*(30/390)),
                    child: Image.asset(AssetManager.profile),
                  ),
              );
            }
          ),
          actions: [
            Row(
              children: [
                Text("80"),
                Image.asset(AssetManager.minihead),
                Text("|"),
                Text("500"),
                Image.asset(AssetManager.feather),
              ],
            )
          ],
        ),
        backgroundColor: AppColors.lightBackground,
        body: Padding(
          padding:  EdgeInsets.only(left: screenWidth*(20/390),right:screenWidth*(20/390) ,top: screenHeight*(40/840)),
          child: ListView.builder(
              itemBuilder: (context,index){
                return Padding(
                  padding:  EdgeInsets.only(bottom: screenHeight*(15/840)),
                  child: Container(
                    width: screenWidth*(350/390),
                    height: screenHeight*(198/840),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primaryBlue,
                      ),
                      color: AppColors.babyBlue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding:  EdgeInsets.only(right: screenWidth*(27/390),top: screenHeight*(32/840)),
                              child: Row(
                                children: [
                                  Text("80",style: TextStyle(color: AppColors.primaryBlue,fontSize: 18, fontFamily: "Cairo", fontWeight: FontWeight.w700, decoration: TextDecoration.underline,decorationColor: AppColors.primaryBlue),),
                                  Text("  تسميعة  ب ",style: TextStyle(color: AppColors.primaryBlue,fontSize: 18, fontFamily: "Cairo", fontWeight: FontWeight.w700,)),
                                  Text("500",style: TextStyle(color: AppColors.orange,fontSize: 18, fontFamily: "Cairo", fontWeight: FontWeight.w700,),),
                                  Image.asset(AssetManager.feather2),
                                ],
                              ),
                            ),
                            Padding(
                              padding:  EdgeInsets.only(right: screenWidth*(20/390),top: screenHeight*(20/840)),
                              child: Row(
                                children: [
                                  Image.asset(AssetManager.book),
                                  SizedBox(width: screenWidth*(8/390),),
                                  Text("كتاب رياض الصالحين ",style: TextStyle(color: AppColors.primaryBlue,fontSize: 16, fontFamily: "Cairo", fontWeight: FontWeight.w500,)),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const PaymentScreen()),
                                );
                              },
                              child: Padding(
                                padding:  EdgeInsets.only(right: screenWidth*(20/390),top: screenHeight*(24/840),),
                                child: Container(
                                  width: screenWidth * (160 / 390),
                                  height: screenHeight * (40 / 844),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFF34B2C4),
                                        Color(0xFF088A9D),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                    "تفعيل الباقة",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "Cairo",
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(AssetManager.vector),
                            Column(
                              children: [
                                Padding(
                                  padding:  EdgeInsets.only(right: 20.0,top: 8),
                                  child: Image.asset(AssetManager.head),
                                ),
                                Image.asset(AssetManager.books),
                              ],
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                );
              }
          ),
        ),
      ),
    );
  }
}
