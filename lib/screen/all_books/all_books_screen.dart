import 'package:alhekmah_app/core/utils/color_manager.dart';
import 'package:alhekmah_app/screen/all_books/bloc/all_book_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/asset_manager.dart';

class AllBooksScreen extends StatefulWidget {
  const AllBooksScreen({super.key});

  @override
  State<AllBooksScreen> createState() => _AllBooksScreenState();
}

class _AllBooksScreenState extends State<AllBooksScreen> {
  late double screenWidth;
  late double screenHeight;

  @override
  Widget build(BuildContext context) {
    screenWidth =MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Align(
          alignment: Alignment.centerRight,
          child: Text("المقررات",
          ),
        ),
        titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: "Cairo"
        ),
        actions: [
          Padding(
            padding:  EdgeInsets.only(right: screenWidth*(30/390)),
            child: Image.asset(AssetManager.profile),
          ),
        ],
      ),
      body: BlocBuilder<AllBookBloc, AllBookState>(
    builder: (context, state) {
      if(state is SuccessLoadingBooksState){
        final remoteBooks = state.remotBook;
        return Padding(
          padding:  EdgeInsets.only(top: screenHeight*(74/840),right: screenWidth*(45/390), left: screenWidth*(45/390)),
          child: ListView.builder(
              itemCount: remoteBooks.length,
              itemBuilder: (context,index){
                final remoteBook = remoteBooks[index];
                return Padding(
                  padding:  EdgeInsets.only(bottom: screenHeight*(30/840)),
                  child: Container(
                    width: screenWidth*(300/390),
                    height: screenHeight*(160/840),
                    decoration: BoxDecoration(
                        color: AppColors.babyBlue,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Color(0xff9FCAD7),
                        )
                    ),
                    child: Center(child: Text(remoteBook.title, style: TextStyle(color: AppColors.primaryBlue,fontFamily: "Cairo", fontSize: 20,fontWeight: FontWeight.w600),)),
                  ),
                );
              }
          ),
        );
      }
      else if(state is LoadingBooksState){
        return Center(child: CircularProgressIndicator(),);
      }else{
        return Text("error");
      }
  },
),
    );
  }
}
