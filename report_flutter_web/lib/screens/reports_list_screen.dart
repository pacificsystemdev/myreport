import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/auth_provider.dart';
import '../providers/reports_provider.dart';
import '../models/models.dart';
import 'report_screen.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReports());
  }

  Future<void> _loadReports() async {
    try {
      final auth = context.read<AuthProvider>();
      if (!auth.isLoggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to view reports')),
        );
        return;
      }
      final reportsProvider = context.read<ReportsProvider>();
      await reportsProvider.fetchReports(
        auth.user!.token,
        auth.user!.userId,
        year: reportsProvider.filterYear,
        month: reportsProvider.filterMonth,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load reports: $e')));
      }
    }
  }

  void _showFilterDialog() {
    final reportsProvider = context.read<ReportsProvider>();
    int? selectedYear = reportsProvider.filterYear;
    int? selectedMonth = reportsProvider.filterMonth;

    final isMobile = MediaQuery.of(context).size.width < 600;
    final filterContent = StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text('Filter Reports', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<int>(
              value: selectedMonth,
              decoration: InputDecoration(
                labelText: 'Month',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...List.generate(
                  12,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('${DateFormat('MMM').format(DateTime(2000, i + 1))} (${i + 1})'),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => selectedMonth = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: selectedYear,
              decoration: InputDecoration(
                labelText: 'Year',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: List.generate(10, (i) {
                final year = 2020 + i;
                return DropdownMenuItem(value: year, child: Text('$year'));
              }),
              onChanged: (value) => setState(() => selectedYear = value),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    reportsProvider.clearFilter();
                    Navigator.pop(context);
                    await _loadReports();
                  },
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    reportsProvider.setFilter(year: selectedYear, month: selectedMonth);
                    Navigator.pop(context);
                    await _loadReports();
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => SafeArea(child: filterContent),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: filterContent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => auth.logout(),
              );
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, ReportsProvider>(
        builder: (context, auth, reportsProvider, child) {
          if (!auth.isLoggedIn) {
            return const Center(child: Text('Login required to view reports'));
          }
          if (reportsProvider.isLoading) {
            return ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(16),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: CircleAvatar(child: Container()),
                      title: Container(height: 16),
                      subtitle: Container(height: 12),
                      trailing: Container(width: 60, height: 16),
                    ),
                  ),
                ),
              ),
            );
          }
          final reports = reportsProvider.filteredReports;
          if (reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.note_add_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No reports yet',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reportsProvider.filterYear != null || reportsProvider.filterMonth != null
                        ? 'Try adjusting your filter or create your first report'
                        : 'Get started by creating your first report',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('New Report'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _loadReports,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final crossAxisCount = isWide ? 2 : 1;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: isWide ? 3 / 1.2 : 3 / 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportScreen(existingReport: report),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      size: 22,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          report.customerName.isEmpty ? 'Internal Activity' : report.customerName,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          _dateFormat.format(report.reportDate),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${report.customerFee.toStringAsFixed(0)}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Expanded(
                                child: Text(
                                  report.workactivity.length > 100
                                      ? '${report.workactivity.substring(0, 100)}...'
                                      : report.workactivity,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
