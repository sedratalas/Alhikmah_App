import 'package:alhekmah_app/core/utils/color_manager.dart';
import 'package:alhekmah_app/screen/all_books/bloc/all_book_bloc.dart';
import 'package:alhekmah_app/screen/widget/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/asset_manager.dart';
import '../ahadith/ahadith_screen.dart';
import '../widget/bloc/profile_bloc.dart';

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
    screenWidth = MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: AppDrawer(),
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          title: const Align(
            alignment: Alignment.centerRight,
            child: Text("المقررات"),
          ),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: "Cairo",
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
          // actions: [
          //   GestureDetector(
          //     onTap: (){
          //       Scaffold.of(context).openDrawer();
          //     },
          //     child: Builder(
          //       builder: (context) {
          //         return Padding(
          //           padding: EdgeInsets.only(right: screenWidth * (30 / 390)),
          //           child: Image.asset(AssetManager.profile),
          //         );
          //       }
          //     ),
          //   ),
          // ],
        ),
        body: BlocBuilder<AllBookBloc, AllBookState>(
          builder: (context, state) {
            if (state is SuccessLoadingBooksState) {
              final allBooks = state.books;
              return Padding(
                padding: EdgeInsets.only(
                  top: screenHeight * (74 / 840),
                  right: screenWidth * (45 / 390),
                  left: screenWidth * (45 / 390),
                ),
                child: ListView.builder(
                  itemCount: allBooks.length,
                  itemBuilder: (context, index) {
                    final book = allBooks[index];
                    return GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AhadithScreen(book: book)
                            ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * (30 / 840)),
                        child: Container(
                          width: screenWidth * (300 / 390),
                          height: screenHeight * (160 / 840),
                          decoration: BoxDecoration(
                            color: AppColors.babyBlue,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xff9FCAD7),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              book.title,
                              maxLines: 2,
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontFamily: "Cairo",
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (state is LoadingBooksState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FailedLoadingBooksState) {
              return Center(
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: AppColors.gray),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}