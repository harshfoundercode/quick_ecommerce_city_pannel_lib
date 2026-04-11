import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DisputeHubDir/details_panel.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DisputeHubDir/dispute_card.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DisputeHubDir/dispute_demo_data.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DisputeHubDir/dispute_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DisputeHubDir/summary_bar.dart' show SummaryBar;


class DisputePanelScreen extends StatefulWidget {
  const DisputePanelScreen({super.key});

  @override
  State<DisputePanelScreen> createState() => _DisputePanelScreenState();
}

class _DisputePanelScreenState extends State<DisputePanelScreen> {
  DisputeItem? _selectedDispute;
  String _activeFilter = 'all';

  List<DisputeItem> get _filteredDisputes {
    if (_activeFilter == 'all') return demoDisputes;
    return demoDisputes.where((d) => d.type == _activeFilter).toList();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _activeFilter = filter;
      _selectedDispute = null;
    });
  }

  void _onDisputeSelected(DisputeItem dispute) {
    setState(() => _selectedDispute = dispute);
  }

  void _onStatusUpdated(DisputeItem updated) {
    setState(() {
      final idx = demoDisputes.indexWhere((d) => d.id == updated.id);
      if (idx != -1) demoDisputes[idx] = updated;
      _selectedDispute = demoDisputes[idx];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F3),
      body: Column(
        children: [
          SummaryBar(disputes: demoDisputes),
          Expanded(
            child: isWide
                ? Row(
              children: [
                SizedBox(
                  width: 420,
                  child: _buildLeftPanel(),
                ),
                const VerticalDivider(width: 1, thickness: 0.5),
                Expanded(
                  child: DetailPane(
                    dispute: _selectedDispute,
                    onStatusUpdated: _onStatusUpdated,
                  ),
                ),
              ],
            )
                : _buildMobileLayout(),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Column(
      children: [
        _buildFilterTabs(),
        Expanded(
          child: _filteredDisputes.isEmpty
              ? const Center(
            child: Text(
              'No disputes found',
              style: TextStyle(color: Color(0xFF888780), fontSize: 14),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _filteredDisputes.length,
            itemBuilder: (ctx, i) {
              final d = _filteredDisputes[i];
              return HubDisputeCard(
                dispute: d,
                isSelected: _selectedDispute?.id == d.id,
                onTap: () => _onDisputeSelected(d),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      ('all', 'All'),
      ('defective', 'Defective'),
      ('missing', 'Missing'),
      ('pending', 'Pending'),
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: filters.map((f) {
          final isActive = _activeFilter == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => _onFilterChanged(f.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF1A1A1A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFFD3D1C7),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  f.$2,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : const Color(0xFF888780),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return _selectedDispute == null
        ? _buildLeftPanel()
        : Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _selectedDispute = null),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Row(
              children: [
                Icon(Icons.arrow_back_ios, size: 14, color: Color(0xFF185FA5)),
                SizedBox(width: 6),
                Text(
                  'Back to list',
                  style: TextStyle(fontSize: 13, color: Color(0xFF185FA5)),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: DetailPane(
            dispute: _selectedDispute,
            onStatusUpdated: _onStatusUpdated,
          ),
        ),
      ],
    );
  }
}