import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/revenue_view_model.dart';

class TransactionHistoryList extends StatefulWidget {
  final RevenueViewModel vm;
  const TransactionHistoryList({super.key, required this.vm});

  @override
  State<TransactionHistoryList> createState() => _TransactionHistoryListState();
}

class _TransactionHistoryListState extends State<TransactionHistoryList> {

  final TextEditingController _searchController = TextEditingController();


  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: ColorConst.cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: ColorConst.borderColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Transaction Filters
        _buildTransactionFilters(),
        const SizedBox(height: 16),

        // Transactions List
        Expanded(
          child: _buildEnhancedTransactionsList(widget.vm),
        ),
      ],
    );
  }
  Widget _buildTransactionFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search transactions...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Status Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: "All Status",
                items: ["All Status", "Paid", "Pending", "Failed"]
                    .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 13)),
                ))
                    .toList(),
                onChanged: (v) {},
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Sort Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.sort_rounded,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  "Latest",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTransactionsList(RevenueViewModel vm) {
    return Container(
      decoration: _boxDecoration(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 20, // Replace with vm.transactions.length
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                // Transaction Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: index % 3 == 0
                        ? Colors.green.withValues(alpha:0.1)
                        : (index % 3 == 1
                        ? Colors.orange.withValues(alpha:0.1)
                        : Colors.blue.withValues(alpha:0.1)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    index % 3 == 0
                        ? Icons.check_circle_rounded
                        : (index % 3 == 1
                        ? Icons.pending_rounded
                        : Icons.receipt_rounded),
                    size: 20,
                    color: index % 3 == 0
                        ? Colors.green
                        : (index % 3 == 1
                        ? Colors.orange
                        : Colors.blue),
                  ),
                ),
                const SizedBox(width: 16),

                // Transaction Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "#ORD-${2024000 + index}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: index % 3 == 0
                                  ? Colors.green.withValues(alpha:0.1)
                                  : (index % 3 == 1
                                  ? Colors.orange.withValues(alpha:0.1)
                                  : Colors.red.withValues(alpha:0.1)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              index % 3 == 0
                                  ? "Paid"
                                  : (index % 3 == 1 ? "Pending" : "Failed"),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: index % 3 == 0
                                    ? Colors.green
                                    : (index % 3 == 1
                                    ? Colors.orange
                                    : Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Rahul Sharma • Gomti Nagar Hub",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "15 Jan 2024 • 10:30 AM",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹${(index + 1) * 450}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ColorConst.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: index % 2 == 0
                            ? Colors.blue.withValues(alpha:0.1)
                            : Colors.purple.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        index % 2 == 0 ? "Cash" : "Online",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: index % 2 == 0 ? Colors.blue : Colors.purple,
                        ),
                      ),
                    ),
                  ],
                ),

                // Action Button
                IconButton(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 18,
                    color: Colors.grey.shade500,
                  ),
                  onPressed: () {
                    _showTransactionDetails(context, index);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Transaction Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow("Order ID", "#ORD-${2024000 + index}"),
              _buildDetailRow("Customer", "Rahul Sharma"),
              _buildDetailRow("Hub", "Gomti Nagar Hub"),
              _buildDetailRow("Amount", "₹${(index + 1) * 450}"),
              _buildDetailRow("Payment Method", index % 2 == 0 ? "Cash" : "Online"),
              _buildDetailRow("Status", index % 3 == 0 ? "Paid" : (index % 3 == 1 ? "Pending" : "Failed")),
              _buildDetailRow("Date", "15 Jan 2024 • 10:30 AM"),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Close"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConst.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("View Order"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


}
