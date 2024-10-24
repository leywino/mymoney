import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mymoney/bloc/records_cubit/records_cubit.dart';
import 'package:mymoney/components/balance_text_widget.dart';
import 'package:mymoney/core/color.dart';
import 'package:mymoney/core/constants.dart';
import 'package:mymoney/core/database_helper.dart';
import 'package:mymoney/models/category_model.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGray,
      body: BlocBuilder<RecordsCubit, RecordsState>(
        builder: (context, state) {
          if (state is RecordsAnalyticsLoaded) {
            return _buildAnalyticsContent(state, context);
          } else if (state is RecordsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text("No data available"));
          }
        },
      ),
    );
  }

  Widget _buildAnalyticsContent(
      RecordsAnalyticsLoaded state, BuildContext context) {
    final categoryTotals = state.categoryTotals;
    final totalSpent = state.totalSpent;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _buildPieChart(categoryTotals, totalSpent, context)),
                Expanded(
                    child: Column(
                  children: categoryTotals.entries.map((entry) {
                    final categoryId = entry.key;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Box.w25,
                        Container(
                          height: 15,
                          width: 15,
                          color: categoryColors[categoryId],
                        ),
                        Box.w3,
                        FutureBuilder(
                          future:
                              DatabaseHelper().getCategoryWithId(categoryId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return const Text(
                                'Error loading category',
                                style: TextStyle(color: Colors.red),
                              );
                            } else if (snapshot.hasData &&
                                snapshot.data != null) {
                              final category = snapshot.data!;
                              return Text(
                                category.name,
                                style: const TextStyle(
                                  color: AppColors.lightYellow,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              );
                            } else {
                              return const Text(
                                'Category not found',
                                style: TextStyle(color: Colors.grey),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  }).toList(),
                ))
              ],
            ),
            const SizedBox(height: 30),
            _buildCategoryList(categoryTotals, totalSpent),
          ],
        ),
      ),
    );
  }

  // Pie chart for showing the category breakdown
  Widget _buildPieChart(Map<int, double> categoryTotals, double totalSpent,
      BuildContext context) {
    if (categoryTotals.isEmpty) {
      return const Center(
        child: Text(
          "No expense data",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    final size = MediaQuery.of(context).size;

    List<PieChartSectionData> sections = [];
    categoryTotals.forEach((category, amount) {
      final percentage = (amount / totalSpent) * 100;
      sections.add(
        PieChartSectionData(
          title: "",
          value: percentage,
          radius: 50,
          color: categoryColors[category],
        ),
      );
    });

    return SizedBox(
      height: size.width * 0.5,
      width: size.width * 0.5,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 0,
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  // List of categories with expense amount and percentage
  Widget _buildCategoryList(
      Map<int, double> categoryTotals, double totalSpent) {
    return Column(
      children: categoryTotals.entries.map((entry) {
        final categoryId = entry.key;
        final amount = entry.value;
        final percentage = (amount / totalSpent) * 100;
        final databaseHelper = DatabaseHelper();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FutureBuilder<Category?>(
                    future: databaseHelper.getCategoryWithId(categoryId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey,
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return const CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.error),
                        );
                      } else if (snapshot.hasData && snapshot.data != null) {
                        final category = snapshot.data!;
                        return CircleAvatar(
                          radius: 24,
                          backgroundImage: AssetImage(
                            category.assetPath,
                          ),
                        );
                      } else {
                        return const CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.category),
                        );
                      }
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FutureBuilder(
                                future: databaseHelper
                                    .getCategoryWithId(categoryId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return const Text(
                                      'Error loading category',
                                      style: TextStyle(color: Colors.red),
                                    );
                                  } else if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    final category = snapshot.data!;
                                    return Text(
                                      category.name,
                                      style: const TextStyle(
                                        color: AppColors.lightYellow,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    );
                                  } else {
                                    return const Text(
                                      'Category not found',
                                      style: TextStyle(color: Colors.grey),
                                    );
                                  }
                                },
                              ),
                              BalanceTextWidget(
                                balance: -amount,
                                isMinusOnly: true,
                              ),
                            ],
                          ),
                          Box.h10,
                          LinearProgressIndicator(
                            minHeight: 7,
                            value: percentage / 100,
                            backgroundColor: Colors.grey[300],
                            color: categoryColors[categoryId],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    "${percentage.toStringAsFixed(2)}%",
                    style: const TextStyle(color: AppColors.lightYellow),
                  ),
                ],
              ),
              const SizedBox(height: 5),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Dummy method to return category icons
  // Widget _buildCategoryIcon(int category) {
  //   // You can replace this with actual icons or images for each category
  //   // For now, we'll just use a placeholder CircleAvatar
  //   return CircleAvatar(
  //     backgroundColor: _getCategoryColor(category),
  //     child: Text(
  //       category[0], // Display first letter of the category
  //       style: const TextStyle(color: Colors.white),
  //     ),
  //   );
  // }
}
