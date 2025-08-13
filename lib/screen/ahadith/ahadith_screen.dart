
import 'package:alhekmah_app/model/standard_remote_book.dart';
import 'package:alhekmah_app/screen/hadeth_recitation/bloc/hadith_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/asset_manager.dart';
import '../../core/utils/color_manager.dart';
//import '../hadeth_recitation/backup_design.dart';
import '../hadeth_recitation/bloc/hadith_bloc.dart';
//import '../hadeth_recitation/hadeth_recitation_screen.dart';
//import '../hadeth_recitation/hadith_recitation.dart';
import '../hadeth_recitation/recitation_and_listen.dart';
import '../widget/app_drawer.dart';
import '../widget/bloc/profile_bloc.dart';

class AhadithScreen extends StatelessWidget {
   AhadithScreen({super.key, required this.book});
   final RemotBook book;
  late double screenWidth;
  late double screenHeight;
  @override
  Widget build(BuildContext context) {
    screenWidth =MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          title: Align(
            alignment: Alignment.centerRight,
            child: Text("الأربعون النووية",
            ),
          ),
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
                    padding:  EdgeInsets.only(right: screenWidth*(20/390)),
                    child: Image.asset(AssetManager.profile),
                  ),
                );
              }
          ),
        ),
        body: Padding(
          padding:  EdgeInsets.only(top: screenHeight*(48/840),),
          child: ListView.builder(
              itemCount: book.hadiths.length,
              itemBuilder: (context,index){
                return Padding(
                  padding:  EdgeInsets.only(left: screenWidth*(10/390), right: screenWidth*(10/390),bottom: screenHeight*(14/840)),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => HadithBloc(
                                book: book,
                                initialIndex: index,
                              )..add(FetchHadithByIdEvent(index)),
                              child: HadethRecitationScreen(),
                            ),
                          ));
      
                    },
                    child: Container(
                      width: screenWidth*(370/390),
                      height: screenHeight*(59/844),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primaryBlue,
                        ),
                        color: AppColors.babyBlue,
                      ),
                      child: Center(
                        child: Text(book.hadiths[index].title,style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontFamily: "Cairo",
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        ),
                      ),
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
