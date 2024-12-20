import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mymoney/bloc/accounts_cubit/accounts_cubit.dart';
import 'package:mymoney/bloc/budgets_cubit/budgets_cubit.dart';
import 'package:mymoney/bloc/records_cubit/records_cubit.dart';
import 'package:mymoney/core/database_helper.dart';
import 'package:mymoney/pages/home_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseHelper = DatabaseHelper();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RecordsCubit(databaseHelper)..fetchRecords(),
        ),
        BlocProvider(
          create: (context) => AccountsCubit(databaseHelper),
        ),
        BlocProvider(
          create: (context) => BudgetsCubit(databaseHelper),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Poppins'),
        home: const HomePage(),
      ),
    );
  }
}
