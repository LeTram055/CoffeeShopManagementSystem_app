import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';
import '../../../managers/staff_serve/payment_manager.dart';
import '../../../models/payment.dart';

class PaidOrdersScreen extends StatefulWidget {
  const PaidOrdersScreen({super.key});

  @override
  _PaidOrdersScreenState createState() => _PaidOrdersScreenState();
}

class _PaidOrdersScreenState extends State<PaidOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<PaymentManager>(context, listen: false).loadPaidOrders();
    });
  }

  DateTime? _startDate;
  DateTime? _endDate;

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Lọc theo ngày thanh toán',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2022),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setModalState(() {
                                _startDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _startDate != null
                                  ? 'Từ: ${DateFormat('dd/MM/yyyy').format(_startDate!)}'
                                  : 'Chọn ngày bắt đầu',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(2022),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setModalState(() {
                                _endDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _endDate != null
                                  ? 'Đến: ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
                                  : 'Chọn ngày kết thúc',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Provider.of<PaymentManager>(context, listen: false)
                          .loadPaidOrders(
                              startDate: _startDate, endDate: _endDate);
                    },
                    icon: const Icon(Icons.filter_alt, color: Colors.white),
                    label: const Text("Lọc",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                      backgroundColor: const Color(0xFF0049ab),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Hàm hiển thị dialog PDF
  void _showInvoiceDialog(BuildContext context, String filePath,
      PaymentManager paymentManager) async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            height: 500,
            //padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: filePath.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : PDFView(
                          filePath: filePath,
                          enableSwipe: true,
                          swipeHorizontal: true,
                          autoSpacing: false,
                          pageSnap: true,
                          pageFling: true,
                          onError: (error) {
                            print(error.toString());
                          },
                          onRender: (pages) {
                            print('Rendered PDF with $pages pages');
                          },
                        ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text('Tải về'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onPressed: () async {
                        try {
                          final downloadPath = await paymentManager
                              .saveInvoiceToDownloads(filePath);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Tệp đã được tải về: $downloadPath'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.of(context)
                              .pop(); // Đóng dialog sau khi nhấn tải về
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Không thể tải về tệp'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      label: const Text('Đóng'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_nbg.png',
              height: 60,
            ),
            const SizedBox(width: 8),
            const Text(
              'Hóa đơn',
              style: TextStyle(fontFamily: 'Prata'),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              _showFilterDialog(context); // Gọi hàm show dialog
            },
          ),
        ],
      ),
      body: Consumer<PaymentManager>(
        builder: (context, paymentManager, child) {
          if (paymentManager.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (paymentManager.paidOrders.isEmpty) {
            return const Center(child: Text('Không có đơn nào đã thanh toán'));
          }

          return ListView.builder(
            itemCount: paymentManager.paidOrders.length,
            itemBuilder: (context, index) {
              Payment payment = paymentManager.paidOrders[index];
              return Card(
                color: Theme.of(context).colorScheme.surface,
                shadowColor: Theme.of(context).colorScheme.shadow,
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MTT: ${payment.paymentId}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${NumberFormat("#,###", "vi_VN").format(payment.finalPrice)}đ',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                        '${DateFormat('HH:mm:ss dd/MM/yyyy').format(payment.paymentTime)}'),
                    trailing: IconButton(
                      icon:
                          const Icon(Icons.picture_as_pdf, color: Colors.blue),
                      onPressed: () async {
                        try {
                          final invoicePdfUrl = await paymentManager
                              .fetchInvoicePdf(payment.paymentId);
                          _showInvoiceDialog(
                              context, invoicePdfUrl, paymentManager);
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Không thể xuất hóa đơn'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    )),
              );
            },
          );
        },
      ),
    );
  }
}
