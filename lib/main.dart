import 'package:alhekmah_app/screen/hadeth_recitation/bloc/hadith_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'model/hadith_model.dart';
import 'screen/ahadith/ahadith_screen.dart';
import 'screen/hadeth_recitation/hadeth_recitation_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => HadithBloc(
                ahadithList: ahadithList,
                initialIndex: 0,
            ),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AhadithScreen(),
      ),
    );
  }
}

