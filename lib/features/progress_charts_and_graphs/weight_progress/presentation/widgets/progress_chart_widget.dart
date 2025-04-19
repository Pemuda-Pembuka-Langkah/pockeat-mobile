import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_data.dart';

class ProgressChartWidget extends StatefulWidget {
  final Map<String, List<WeightData>> periodData;
  final String selectedPeriod;
  final Function(String?) onPeriodChanged;
  final Color primaryPink;
  
  const ProgressChartWidget({
    super.key,
    required this.periodData,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.primaryPink,
  });

  @override
  _ProgressChartWidgetState createState() => _ProgressChartWidgetState();
}

class _ProgressChartWidgetState extends State<ProgressChartWidget> {
  late String _selectedPeriod;
  // Store the chart series separately
  late List<CartesianSeries<WeightData, String>> _chartSeries;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.selectedPeriod;
    _updateChartSeries();
  }

  @override
  void didUpdateWidget(ProgressChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update if periodData changes from parent or if selectedPeriod changes
    if (oldWidget.periodData != widget.periodData || 
        oldWidget.selectedPeriod != widget.selectedPeriod) {
      _selectedPeriod = widget.selectedPeriod;
      _updateChartSeries();
    }
  }

  // Extract chart series creation to a separate method
  void _updateChartSeries() {
    _chartSeries = <CartesianSeries<WeightData, String>>[
      // Target Weight Line
      LineSeries<WeightData, String>(
        name: 'Target Weight',
        color: Colors.grey[300],
        width: 1,
        dashArray: const [2, 2],
        dataSource: [
          for (var data in widget.periodData[_selectedPeriod]!)
            WeightData(data.label, 70.0, 0, 0, '')
        ],
        xValueMapper: (WeightData data, _) => data.label,
        yValueMapper: (WeightData data, _) => data.weight,
      ),
      // Actual Weight Line
      LineSeries<WeightData, String>(
        name: 'Actual Weight',
        color: widget.primaryPink,
        width: 2,
        dataSource: widget.periodData[_selectedPeriod]!,
        xValueMapper: (WeightData data, _) => data.label,
        yValueMapper: (WeightData data, _) => data.weight,
        markerSettings: MarkerSettings(
          isVisible: true,
          height: 6,
          width: 6,
          shape: DataMarkerType.circle,
          borderWidth: 2,
          borderColor: widget.primaryPink,
          color: Colors.white,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progress Chart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPeriod,
                        isDense: true,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        items: ['Daily', 'Weekly', 'Monthly'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null && newValue != _selectedPeriod) {
                            setState(() {
                              _selectedPeriod = newValue;
                              // Update chart series when period changes
                              _updateChartSeries();
                            });
                            // Still notify parent, but the parent doesn't need to rebuild the entire widget
                            widget.onPeriodChanged(newValue);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Chart section - use the pre-created chart series
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: SfCartesianChart(
                margin: EdgeInsets.zero,
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  majorGridLines: MajorGridLines(
                    width: 1,
                    color: Colors.grey[200],
                    dashArray: const [5, 5],
                  ),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  minimum: 66,
                  maximum: 78,
                  interval: 2,
                  majorGridLines: MajorGridLines(
                    width: 1,
                    color: Colors.grey[200],
                    dashArray: const [5, 5],
                  ),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                  textStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                series: _chartSeries,
              ),
            ),
          ],
        ),
      ),
    );
  }
}