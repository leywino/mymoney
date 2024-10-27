import 'package:flutter/material.dart';
import 'package:mymoney/components/show_add_category_dialogue.dart';
import 'package:mymoney/core/color.dart';
import 'package:mymoney/core/constants.dart';
import 'package:mymoney/core/database_helper.dart';
import 'package:mymoney/models/category_model.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late Future<List<Category>> _incomeCategoriesFuture;
  late Future<List<Category>> _expenseCategoriesFuture;

  @override
  void initState() {
    super.initState();
    _incomeCategoriesFuture = _fetchIncomeCategories();
    _expenseCategoriesFuture = _fetchExpenseCategories();
  }

  Future<List<Category>> _fetchIncomeCategories() async {
    return await DatabaseHelper().getCategoriesByTypeList('income');
  }

  Future<List<Category>> _fetchExpenseCategories() async {
    return await DatabaseHelper().getCategoriesByTypeList('expense');
  }

  void refreshCategories() async {
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      _incomeCategoriesFuture = _fetchIncomeCategories();
      _expenseCategoriesFuture = _fetchExpenseCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.darkGray,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Income categories section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Income categories',
                        style: TextStyle(
                          color: AppColors.lightYellow,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      Divider(color: AppColors.lightYellow),
                    ],
                  ),
                ),
                _buildFutureCategoryList(_incomeCategoriesFuture),
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expense categories',
                        style: TextStyle(
                          color: AppColors.lightYellow,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      Divider(color: AppColors.lightYellow),
                    ],
                  ),
                ),
                _buildFutureCategoryList(_expenseCategoriesFuture),
                Center(
                  child: _buildAddNewCategoryButton(context),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFutureCategoryList(Future<List<Category>> futureCategoryList) {
    return FutureBuilder<List<Category>>(
      future: futureCategoryList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No categories found.',
              style: TextStyle(color: AppColors.secondaryText),
            ),
          );
        } else {
          final categories = snapshot.data!;
          return Column(
            children: categories
                .map((category) => _buildCategoryCard(category))
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[900],
          child: Image.asset(categoryAssetIconList[category.iconNumber]),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            color: AppColors.lightYellow,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.lightYellow),
          onPressed: () {
            _showCategoryOptions(category);
          },
        ),
      ),
    );
  }

  void _showCategoryOptions(Category category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.customOliveGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.lightYellow),
              title: const Text('Edit',
                  style: TextStyle(color: AppColors.lightYellow)),
              onTap: () {
                Navigator.pop(context);
                _editCategory(category);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.lightYellow),
              title: const Text('Delete',
                  style: TextStyle(color: AppColors.lightYellow)),
              onTap: () {
                Navigator.pop(context);
                _deleteCategory(category);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddNewCategoryButton(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () async {
        final isAdded = await showAddCategoryDialog(context);
        if (isAdded) {
          refreshCategories();
        }
      },
      child: Container(
        width: size.width * 0.6,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: AppColors.lightYellow, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.lightYellow),
            SizedBox(width: 8),
            Text(
              'ADD NEW CATEGORY',
              style: TextStyle(
                color: AppColors.lightYellow,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editCategory(Category category) {
    // Handle the logic for editing the category here
    // You can open a dialog or navigate to another page to edit the category
  }

  void _deleteCategory(Category category) {
    // Handle the logic for deleting the category
    // Ensure to refresh the category list after deletion
    setState(() {
      _incomeCategoriesFuture = _fetchIncomeCategories();
      _expenseCategoriesFuture = _fetchExpenseCategories();
    });
  }
}
