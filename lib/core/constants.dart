import 'package:flutter/material.dart';

class Box {
  // Height SizedBox constants
  static const SizedBox h1 = SizedBox(height: 1);
  static const SizedBox h2 = SizedBox(height: 2);
  static const SizedBox h3 = SizedBox(height: 3);
  static const SizedBox h4 = SizedBox(height: 4);
  static const SizedBox h5 = SizedBox(height: 5);
  static const SizedBox h6 = SizedBox(height: 6);
  static const SizedBox h7 = SizedBox(height: 7);
  static const SizedBox h8 = SizedBox(height: 8);
  static const SizedBox h9 = SizedBox(height: 9);
  static const SizedBox h10 = SizedBox(height: 10);
  static const SizedBox h12 = SizedBox(height: 12);
  static const SizedBox h15 = SizedBox(height: 15);
  static const SizedBox h20 = SizedBox(height: 20);
  static const SizedBox h25 = SizedBox(height: 25);
  static const SizedBox h30 = SizedBox(height: 30);
  static const SizedBox h40 = SizedBox(height: 40);
  static const SizedBox h50 = SizedBox(height: 50);
  static const SizedBox h60 = SizedBox(height: 60);

  // Width SizedBox constants
  static const SizedBox w1 = SizedBox(width: 1);
  static const SizedBox w2 = SizedBox(width: 2);
  static const SizedBox w3 = SizedBox(width: 3);
  static const SizedBox w4 = SizedBox(width: 4);
  static const SizedBox w5 = SizedBox(width: 5);
  static const SizedBox w6 = SizedBox(width: 6);
  static const SizedBox w7 = SizedBox(width: 7);
  static const SizedBox w8 = SizedBox(width: 8);
  static const SizedBox w9 = SizedBox(width: 9);
  static const SizedBox w10 = SizedBox(width: 10);
  static const SizedBox w12 = SizedBox(width: 12);
  static const SizedBox w15 = SizedBox(width: 15);
  static const SizedBox w20 = SizedBox(width: 20);
  static const SizedBox w25 = SizedBox(width: 25);
  static const SizedBox w30 = SizedBox(width: 30);
  static const SizedBox w40 = SizedBox(width: 40);
  static const SizedBox w50 = SizedBox(width: 50);
  static const SizedBox w60 = SizedBox(width: 60);
}

List<String> accountsAssetIconList = [
  'assets/icons/account/cash.png',
  'assets/icons/account/card.png',
  'assets/icons/account/piggybank.png',
  'assets/icons/account/bank.png',
  'assets/icons/account/coins.png',
  'assets/icons/account/federalbank.png',
  'assets/icons/account/gold.png',
  'assets/icons/account/hdfc.png',
  'assets/icons/account/icici.png',
  'assets/icons/account/mastercard.png',
  'assets/icons/account/paypal.png',
  'assets/icons/account/safe.png',
  'assets/icons/account/visa.png',
  'assets/icons/account/wallet.png',
];

const List<Map<String, String>> expenseCategories = [
  {
    'name': 'Baby',
    'assetPath': 'assets/icons/expense/baby.png',
    'type': 'expense'
  },
  {
    'name': 'Beauty',
    'assetPath': 'assets/icons/expense/beauty.png',
    'type': 'expense'
  },
  {
    'name': 'Bicycle',
    'assetPath': 'assets/icons/expense/bicycle.png',
    'type': 'expense'
  },
  {
    'name': 'Bike',
    'assetPath': 'assets/icons/expense/bike.png',
    'type': 'expense'
  },
  {
    'name': 'Bills',
    'assetPath': 'assets/icons/expense/bills.png',
    'type': 'expense'
  },
  {
    'name': 'Car',
    'assetPath': 'assets/icons/expense/car.png',
    'type': 'expense'
  },
  {
    'name': 'Clothing',
    'assetPath': 'assets/icons/expense/clothing.png',
    'type': 'expense'
  },
  {
    'name': 'Education',
    'assetPath': 'assets/icons/expense/education.png',
    'type': 'expense'
  },
  {
    'name': 'Electronics',
    'assetPath': 'assets/icons/expense/electronics.png',
    'type': 'expense'
  },
  {
    'name': 'EMI',
    'assetPath': 'assets/icons/expense/emi.png',
    'type': 'expense'
  },
  {
    'name': 'Entertainment',
    'assetPath': 'assets/icons/expense/entertainment.png',
    'type': 'expense'
  },
  {
    'name': 'Food',
    'assetPath': 'assets/icons/expense/food.png',
    'type': 'expense'
  },
  {
    'name': 'Gadgets',
    'assetPath': 'assets/icons/expense/gadgets.png',
    'type': 'expense'
  },
  {
    'name': 'Gym',
    'assetPath': 'assets/icons/expense/gym.png',
    'type': 'expense'
  },
  {
    'name': 'Health',
    'assetPath': 'assets/icons/expense/health.png',
    'type': 'expense'
  },
  {
    'name': 'Home',
    'assetPath': 'assets/icons/expense/home.png',
    'type': 'expense'
  },
  {
    'name': 'Insurance',
    'assetPath': 'assets/icons/expense/insurance.png',
    'type': 'expense'
  },
  {
    'name': 'Shopping',
    'assetPath': 'assets/icons/expense/shopping.png',
    'type': 'expense'
  },
  {
    'name': 'Social',
    'assetPath': 'assets/icons/expense/social.png',
    'type': 'expense'
  },
  {
    'name': 'Sports',
    'assetPath': 'assets/icons/expense/sports.png',
    'type': 'expense'
  },
  {
    'name': 'Subscriptions',
    'assetPath': 'assets/icons/expense/subscriptions.png',
    'type': 'expense'
  },
  {
    'name': 'Tax',
    'assetPath': 'assets/icons/expense/tax.png',
    'type': 'expense'
  },
  {
    'name': 'Telephone',
    'assetPath': 'assets/icons/expense/telephone.png',
    'type': 'expense'
  },
  {
    'name': 'Transportation',
    'assetPath': 'assets/icons/expense/transportation.png',
    'type': 'expense'
  },
];

const List<Map<String, String>> incomeCategories = [
  {
    'name': 'Awards',
    'assetPath': 'assets/icons/income/awards.png',
    'type': 'income'
  },
  {
    'name': 'Coupons',
    'assetPath': 'assets/icons/income/coupons.png',
    'type': 'income'
  },
  {
    'name': 'Grants',
    'assetPath': 'assets/icons/income/grants.png',
    'type': 'income'
  },
  {
    'name': 'Lottery',
    'assetPath': 'assets/icons/income/lottery.png',
    'type': 'income'
  },
  {
    'name': 'Receiving',
    'assetPath': 'assets/icons/income/receiving.png',
    'type': 'income'
  },
  {
    'name': 'Refunds',
    'assetPath': 'assets/icons/income/refunds.png',
    'type': 'income'
  },
  {
    'name': 'Rental',
    'assetPath': 'assets/icons/income/rental.png',
    'type': 'income'
  },
  {
    'name': 'Salary',
    'assetPath': 'assets/icons/income/salary.png',
    'type': 'income'
  },
  {
    'name': 'Sale',
    'assetPath': 'assets/icons/income/sale.png',
    'type': 'income'
  },
];
