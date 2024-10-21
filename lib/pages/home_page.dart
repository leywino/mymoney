import 'package:flutter/material.dart';
import 'package:mymoney/components/date_range_picker.dart';
import 'package:mymoney/core/color.dart';
import 'package:mymoney/pages/add_page.dart';
import 'package:mymoney/pages/records_page.dart';
import 'package:page_transition/page_transition.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Placeholder widgets for the different pages
  static const List<Widget> _pages = <Widget>[
    RecordsPage(),
    Text('Analysis Page'),
    Text('Budgets Page'),
    Text('Accounts Page'),
    Text('Categories Page'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.darkGray,
      appBar: AppBar(
        backgroundColor: AppColors.darkGray,
        title: _buildAppBar(),
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      floatingActionButton: IconButton(
        onPressed: () {
          _navigateToAddPage();
        },
        icon: Container(
          height: size.height * 0.06,
          width: size.height * 0.06,
          decoration: const BoxDecoration(
            color: AppColors.grayBrown,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add,
            color: AppColors.lightYellow,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.grayBrown,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: AppColors.grayBrown,
            icon: Icon(Icons.receipt_outlined),
            activeIcon: Icon(Icons.receipt_rounded),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.analytics),
            icon: Icon(Icons.analytics_outlined),
            label: 'Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Budgets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_outlined),
            activeIcon: Icon(Icons.account_balance),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Categories',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.lightYellow,
        unselectedItemColor: AppColors.lightBeige,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        onTap: _onItemTapped,
      ),
    );
  }

  void _navigateToAddPage() {
    Navigator.push(
        context,
        PageTransition(
            duration: const Duration(milliseconds: 350),
            type: PageTransitionType.rightToLeft,
            child: const AddPage()));
  }

  Widget? _buildAppBar() {
    switch (_selectedIndex) {
      case 0:
        return const DateRangePicker();
      case 1:
        return const DateRangePicker();
      case 2:
        return null;
      case 3:
        return null;
      case 4:
        return null;
    }
    return null;
  }
}
