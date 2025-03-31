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
                        ]),
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
