import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';


class DeliveryBoysDirectoryScreen extends StatefulWidget {
  const DeliveryBoysDirectoryScreen({
    super.key,
  });

  @override
  State<DeliveryBoysDirectoryScreen> createState() => _DeliveryBoysDirectoryScreenState();
}

class _DeliveryBoysDirectoryScreenState extends State<DeliveryBoysDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = "All";
  final bool _isLoading = false;

  final List<String> _filterOptions = ["All", "Active", "Offline", "On Duty", "On Leave"];

  final List<Map<String, dynamic>> _deliveryBoys = List.generate(
    15,
        (index) => {
      'id': 'DB00${index + 1}',
      'name': 'Rahul Sharma ${index + 1}',
      'phone': '+91 98765 4321$index',
      'email': 'rahul.sharma${index + 1}@example.com',
      'status': index % 3 == 0 ? 'Active' : (index % 3 == 1 ? 'On Duty' : 'Offline'),
      'hub': 'Hub - Gomti Nagar',
      'rating': (4 + (index % 5) / 10).toStringAsFixed(1),
      'deliveries': 45 + index * 3,
      'avatar': null,
    },
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SizedBox(
        width: Sizes.screenWidth * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(Sizes.screenWidth * 0.015),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsSummary(),

                    CustomWidgets.verticalSpace(0.02),

                    _buildSearchAndFilter(),

                    CustomWidgets.verticalSpace(0.02),

                    _buildResultsCount(),

                    CustomWidgets.verticalSpace(0.015),

                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildDeliveryBoysList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(Sizes.screenWidth * 0.015),
      decoration: BoxDecoration(
        color: ColorConst.primaryExtraLightGreen,
        borderRadius:  const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),

        border: const Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorConst.primaryGreen.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delivery_dining,
              color: ColorConst.primaryGreen,
              size: 24,
            ),
          ),

          CustomWidgets.horizontalSpace(0.015),

          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.bold(
                  "Delivery Boys Directory",
                  fontSize: 18,
                ),
                CustomText.medium(
                  "View and manage all delivery personnel",
                  fontSize: 12,
                  color: ColorConst.textGrey,
                ),
              ],
            ),
          ),

            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.close, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            label: "Total Boys",
            value: "24",
            icon: Icons.people_outline,
            color: Colors.blue,
          ),
          _buildStatItem(
            label: "Active Now",
            value: "18",
            icon: Icons.circle,
            color: Colors.green,
          ),
          _buildStatItem(
            label: "On Duty",
            value: "12",
            icon: Icons.delivery_dining,
            color: Colors.orange,
          ),
          _buildStatItem(
            label: "On Leave",
            value: "3",
            icon: Icons.beach_access,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText.bold(value, fontSize: 16, color: color),
            CustomText.medium(label, fontSize: 11, color: ColorConst.textGrey),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        // Search Field
        Expanded(
          flex: 3,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by name, phone or hub...",
                prefixIcon: const Icon(Icons.search, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                ),
              ),
              onChanged: (value) {
                // Implement search
              },
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Filter Dropdown
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFilter,
              icon: const Icon(Icons.filter_list, size: 20),
              items: _filterOptions.map((String option) {
                return DropdownMenuItem(
                  value: option,
                  child: Row(
                    children: [
                      _getStatusIndicator(option),
                      const SizedBox(width: 8),
                      CustomText.medium(option, fontSize: 13),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFilter = newValue!;
                });
              },
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Export Button
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: IconButton(
            icon: const Icon(Icons.download_outlined, size: 20),
            onPressed: () {
              // Implement export
            },
          ),
        ),
      ],
    );
  }

  Widget _getStatusIndicator(String status) {
    Color color;
    switch (status) {
      case "Active":
      case "On Duty":
        color = Colors.green;
        break;
      case "Offline":
        color = Colors.grey;
        break;
      case "On Leave":
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildResultsCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText.medium(
            "Showing 10 of ${_deliveryBoys.length} delivery boys",
            fontSize: 12,
            color: ColorConst.textGrey,
          ),
          Row(
            children: [
              CustomText.medium("Sort by: ", fontSize: 12, color: ColorConst.textGrey),
              DropdownButton<String>(
                value: "Recent",
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: "Recent", child: Text("Recent")),
                  DropdownMenuItem(value: "Name", child: Text("Name")),
                  DropdownMenuItem(value: "Rating", child: Text("Rating")),
                ],
                onChanged: (value) {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryBoysList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: _deliveryBoys.length,
      itemBuilder: (context, index) {
        final boy = _deliveryBoys[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildEnhancedDirectoryTile(boy),
        );
      },
    );
  }

  Widget _buildEnhancedDirectoryTile(Map<String, dynamic> boy) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        shape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: ColorConst.primaryExtraLightGreen,
              backgroundImage: boy['avatar'] != null
                  ? NetworkImage(boy['avatar'])
                  : null,
              child: boy['avatar'] == null
                  ? Text(
                boy['name'][0],
                style: const TextStyle(
                  color: ColorConst.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(boy['status']),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText.semiBold(boy['name'], fontSize: 14),
                  const SizedBox(height: 2),
                  CustomText.medium(boy['phone'], fontSize: 12, color: Colors.grey),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(boy['status']).withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _getStatusColor(boy['status']),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  CustomText.medium(
                    boy['status'],
                    fontSize: 11,
                    color: _getStatusColor(boy['status']),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Column(
              children: [
                // Details Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.email_outlined,
                        label: "Email",
                        value: boy['email'],
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.location_on_outlined,
                        label: "Hub",
                        value: boy['hub'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.star_outline,
                        label: "Rating",
                        value: "${boy['rating']}/5.0",
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.delivery_dining,
                        label: "Deliveries",
                        value: "${boy['deliveries']} today",
                      ),
                    ),
                  ],
                ),
                 SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppBtn(
                      width: Sizes.screenWidth*0.1,
                      height: Sizes.screenHeight*0.05,
                      onTap: () {},
                      title:"Message",
                      titleColor: ColorConst.white,
                      color: ColorConst.textGrey,
                    ),
                    CustomWidgets.horizontalSpace(0.012),
                    AppBtn(
                      width: Sizes.screenWidth*0.1,
                      height: Sizes.screenHeight*0.05,
                      title: "View Details",
                      onTap: (){},
                      color: ColorConst.primaryGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: ColorConst.textGrey),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText.medium(label, fontSize: 10, color: Colors.grey),
              CustomText.medium(value, fontSize: 12),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
      case 'On Duty':
        return Colors.green;
      case 'Offline':
        return Colors.grey;
      case 'On Leave':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}