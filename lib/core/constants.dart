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

List<String> categoryAssetIconList = [
  'assets/icons/expense/baby.png',
  'assets/icons/expense/beauty.png',
  'assets/icons/expense/bicycle.png',
  'assets/icons/expense/bike.png',
  'assets/icons/expense/bills.png',
  'assets/icons/expense/car.png',
  'assets/icons/expense/clothing.png',
  'assets/icons/expense/education.png',
  'assets/icons/expense/electronics.png',
  'assets/icons/expense/emi.png',
  'assets/icons/expense/entertainment.png',
  'assets/icons/expense/fuel.png',
  'assets/icons/expense/food.png',
  'assets/icons/expense/gadgets.png',
  'assets/icons/expense/gym.png',
  'assets/icons/expense/health.png',
  'assets/icons/expense/home.png',
  'assets/icons/expense/insurance.png',
  'assets/icons/expense/shopping.png',
  'assets/icons/expense/social.png',
  'assets/icons/expense/sports.png',
  'assets/icons/expense/subscriptions.png',
  'assets/icons/expense/tax.png',
  'assets/icons/expense/telephone.png',
  'assets/icons/expense/transportation.png',
  'assets/icons/income/awards.png',
  'assets/icons/income/coupons.png',
  'assets/icons/income/grants.png',
  'assets/icons/income/lottery.png',
  'assets/icons/income/receiving.png',
  'assets/icons/income/refunds.png',
  'assets/icons/income/rental.png',
  'assets/icons/income/salary.png',
  'assets/icons/income/sale.png',
  'assets/icons/transfer.png'
];

const List<Map<String, dynamic>> expenseCategories = [
  {'name': 'Baby', 'iconNumber': 0, 'type': 'expense'},
  {'name': 'Beauty', 'iconNumber': 1, 'type': 'expense'},
  {'name': 'Bicycle', 'iconNumber': 2, 'type': 'expense'},
  {'name': 'Bike', 'iconNumber': 3, 'type': 'expense'},
  {'name': 'Bills', 'iconNumber': 4, 'type': 'expense'},
  {'name': 'Car', 'iconNumber': 5, 'type': 'expense'},
  {'name': 'Clothing', 'iconNumber': 6, 'type': 'expense'},
  {'name': 'Education', 'iconNumber': 7, 'type': 'expense'},
  {'name': 'Electronics', 'iconNumber': 8, 'type': 'expense'},
  {'name': 'EMI', 'iconNumber': 9, 'type': 'expense'},
  {'name': 'Entertainment', 'iconNumber': 10, 'type': 'expense'},
  {'name': 'Fuel', 'iconNumber': 11, 'type': 'expense'},
  {'name': 'Food', 'iconNumber': 12, 'type': 'expense'},
  {'name': 'Gadgets', 'iconNumber': 13, 'type': 'expense'},
  {'name': 'Gym', 'iconNumber': 14, 'type': 'expense'},
  {'name': 'Health', 'iconNumber': 15, 'type': 'expense'},
  {'name': 'Home', 'iconNumber': 16, 'type': 'expense'},
  {'name': 'Insurance', 'iconNumber': 17, 'type': 'expense'},
  {'name': 'Shopping', 'iconNumber': 18, 'type': 'expense'},
  {'name': 'Social', 'iconNumber': 19, 'type': 'expense'},
  {'name': 'Sports', 'iconNumber': 20, 'type': 'expense'},
  {'name': 'Subscriptions', 'iconNumber': 21, 'type': 'expense'},
  {'name': 'Tax', 'iconNumber': 22, 'type': 'expense'},
  {'name': 'Telephone', 'iconNumber': 23, 'type': 'expense'},
  {'name': 'Transportation', 'iconNumber': 24, 'type': 'expense'},
];

// Updated income categories with `iconNumber`
const List<Map<String, dynamic>> incomeCategories = [
  {'name': 'Awards', 'iconNumber': 25, 'type': 'income'},
  {'name': 'Coupons', 'iconNumber': 26, 'type': 'income'},
  {'name': 'Grants', 'iconNumber': 27, 'type': 'income'},
  {'name': 'Lottery', 'iconNumber': 28, 'type': 'income'},
  {'name': 'Receiving', 'iconNumber': 29, 'type': 'income'},
  {'name': 'Refunds', 'iconNumber': 30, 'type': 'income'},
  {'name': 'Rental', 'iconNumber': 31, 'type': 'income'},
  {'name': 'Salary', 'iconNumber': 32, 'type': 'income'},
  {'name': 'Sale', 'iconNumber': 33, 'type': 'income'},
];
