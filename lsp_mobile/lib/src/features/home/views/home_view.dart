import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lsp_mobile/cores/constants/color_const.dart';
import 'package:lsp_mobile/src/features/cashflow/views/add_income_view.dart';
import 'package:lsp_mobile/src/features/cashflow/views/add_outcome_view.dart';
import 'package:lsp_mobile/src/features/cashflow/views/detail_cashflow_view.dart';
import 'package:lsp_mobile/src/features/home/views/line_chart_widget.dart';
import 'package:lsp_mobile/src/features/settings/views/setting_view.dart';
import 'package:lsp_mobile/src/models/cash_flow_model.dart';
import 'package:lsp_mobile/src/repositories/sqlite_repository.dart';
import 'package:lsp_mobile/src/shared/format/text_formatter.dart';
import 'package:lsp_mobile/src/shared/helpers/date_helper.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final SQLiteRepository _sqliteRepository = SQLiteRepository();
  List<CashFlowModel> cashFlowData = [];
  num totalIncome = 0;
  num totalOutcome = 0;

  DateTime now = DateTime.now();

  /// Get cash flow data from database
  /// and calculate total income and outcome
  void getCashFlowData() async {
    totalIncome = 0;
    totalOutcome = 0;

    List<CashFlowModel> result = await _sqliteRepository.getAllCashFlow(
      startDate: DateTime(now.year, now.month - 1,
          DateHelper.daysInMonth(now.year, now.month - 1), 0, 0, 0),
      endDate: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
    );

    for (var item in result) {
      if (item.type == 0) {
        totalOutcome += (item.amount ?? 0);
      } else {
        totalIncome += (item.amount ?? 0);
      }
    }

    setState(() {});
  }

  /// Get cash flow data from database by 5 days before today
  /// and join the same date and same type
  /// and add to [cashFlowData]
  void getCashFlowDataForGraph() async {
    cashFlowData.clear();

    // get only 5 days before today
    DateTime startDate = DateTime(now.year, now.month, now.day - 5);
    DateTime endDate = DateTime(now.year, now.month, now.day);

    List<CashFlowModel> result = await _sqliteRepository.getAllCashFlow(
      startDate: startDate,
      endDate: endDate,
    );

    // order by date
    result.sort(
      (a, b) => (DateTime.parse(a.date!)).compareTo(
        DateTime.parse(b.date!),
      ),
    );

    List<CashFlowModel> totalData = [];
    for (var item in result) {
      if (totalData.isEmpty) {
        totalData.add(item);
      } else {
        bool isSameDate = false;
        for (var data in totalData) {
          DateTime date1 = DateTime.parse(data.date!);
          DateTime date2 = DateTime.parse(item.date!);

          if (date1.day == date2.day && data.type == item.type) {
            isSameDate = true;

            data.amount = (data.amount ?? 0) + (item.amount ?? 0);
          }
        }

        if (!isSameDate) {
          totalData.add(item);
        }
      }
    }

    for (var item in totalData) {
      cashFlowData.add(item);
    }

    setState(() {});
  }

  /// Initialize data
  void initializeData() {
    getCashFlowData();
    getCashFlowDataForGraph();
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: ColorConst.primary400,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                height: 200,
                width: double.infinity,
                color: ColorConst.primary400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Rangkuman Bulan Ini",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Pengeluaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      TextFormatter.formatAmount(totalOutcome),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Pemasukan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      TextFormatter.formatAmount(totalIncome),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ExpansionTileTheme(
                        data: const ExpansionTileThemeData(
                          iconColor: Colors.white,
                          textColor: Colors.white,
                          collapsedIconColor: Colors.white,
                          backgroundColor: ColorConst.primary400,
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          tilePadding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          collapsedBackgroundColor: ColorConst.primary400,
                        ),
                        child: ExpansionTile(
                          title: const Text(
                            'Grafik 5 hari terakhir',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                                top: 58,
                                bottom: 12,
                              ),
                              decoration: const BoxDecoration(
                                color: ColorConst.primary400,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(24),
                                  bottomRight: Radius.circular(24),
                                ),
                              ),
                              child: cashFlowData.isEmpty
                                  ? const SizedBox(
                                      height: 250,
                                      child: Center(
                                        child: Text(
                                          'Tidak ada data',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 270,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 200,
                                            child: LineChartWidget(
                                              data: cashFlowData,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: Colors.blueAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Text(
                                                'Pemasukan',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: Colors.redAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Text(
                                                'Pengeluaran',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 24,
                        ),
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddIncomeView(),
                                  ),
                                );
                                initializeData();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 24,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.playlist_add_check_circle_outlined,
                                      color: ColorConst.primary400,
                                      size: 64,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Tambah Pemasukan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AddOutcomeView(),
                                  ),
                                );
                                initializeData();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 24,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.playlist_remove_rounded,
                                      color: Colors.redAccent,
                                      size: 64,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Tambah Pengeluaran',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const DetailCashFlowView(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 24,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.list_alt_rounded,
                                      color: Colors.blueAccent,
                                      size: 64,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Detail Cash Flow',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SettingView(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 24,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.settings,
                                      color: Colors.orangeAccent,
                                      size: 64,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Pengaturan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
