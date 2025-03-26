import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../managers/staff_serve/order_manager.dart';
import '../../../models/order.dart';
import '../../../models/promotion.dart';
import '../../../models/payment.dart';
import '../../../managers/auth_manager.dart';

class PaymentModal extends StatefulWidget {
  final Order order;
  const PaymentModal({Key? key, required this.order}) : super(key: key);

  @override
  _PaymentModalState createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  String selectedMethod = "cash";
  double discount = 0.0;
  double amountReceived = 0.0;
  double finalPrice = 0.0;
  List<Promotion> promotions = [];
  Promotion? selectedPromotion;

  final Map<String, String> paymentMethods = {
    "cash": "Tiền mặt",
    "bank_transfer": "Chuyển khoản",
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPromotions();
    });
    calculateFinalPrice();
  }

  void fetchPromotions() async {
    await Provider.of<OrderServeManager>(context, listen: false)
        .loadPromotions(widget.order.orderId);

    if (!mounted) return;

    setState(() {
      promotions =
          Provider.of<OrderServeManager>(context, listen: false).promotions;
    });
  }

  void calculateFinalPrice() {
    double total = widget.order.items.fold(
      0.0,
      (sum, item) => sum + (item.quantity * item.item.price),
    );
    setState(() {
      finalPrice = total - discount;
    });
  }

  void applyPromotion(Promotion? promo) {
    if (promo != null) {
      setState(() {
        selectedPromotion = promo;
        discount = promo.discountType == 'percentage'
            ? widget.order.totalPrice * promo.discountValue / 100
            : promo.discountValue;
        calculateFinalPrice();
      });
    } else {
      setState(() {
        selectedPromotion = null;
        discount = 0.0;
        calculateFinalPrice();
      });
    }
  }

  void completePayment() async {
    if (amountReceived < finalPrice) {
      Navigator.pop(context, false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Số tiền nhận không đủ!"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final currentUser =
        Provider.of<AuthManager>(context, listen: false).currentUser;
    if (currentUser == null) {
      Navigator.pop(context, false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Người dùng không hợp lệ!"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final payment = Payment(
      paymentId: 0, // Backend sẽ tự tạo ID
      orderId: widget.order.orderId,
      employeeId: currentUser.employeeId,
      promotionId: selectedPromotion?.promotionId ?? 0,
      discountAmount: discount,
      finalPrice: finalPrice,
      paymentMethod: selectedMethod,
      amountReceived: amountReceived,
      paymentTime: DateTime.now(),
    );

    try {
      await Provider.of<OrderServeManager>(context, listen: false)
          .savePayment(payment);
      if (!mounted) return; // Check if the widget is still mounted
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Thanh toán thành công!"),
        backgroundColor: Colors.green,
      ));
    } catch (error) {
      if (!mounted) return;
      Navigator.pop(context, false); // Check if the widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Lỗi khi lưu thanh toán!"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Thanh toán đơn hàng",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),

          // Chọn phương thức thanh toán
          const Text('Phương thức thanh toán',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

          DropdownButtonFormField<String>(
            value: selectedMethod,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            isExpanded: true,
            items: paymentMethods.entries
                .map((entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ))
                .toList(),
            onChanged: (value) => setState(() => selectedMethod = value!),
          ),
          const SizedBox(height: 10),

          // Chọn khuyến mãi
          const Text('Chọn khuyến mãi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          DropdownButtonFormField<Promotion>(
            value: selectedPromotion,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            isExpanded: true,
            hint: const Text("Chọn khuyến mãi"),
            items: promotions.isNotEmpty
                ? promotions.map((promo) {
                    return DropdownMenuItem(
                      value: promo,
                      child: Text(
                        "${promo.name} (${promo.discountType == 'percentage' ? '${promo.discountValue}%' : '${NumberFormat("#,###", "vi_VN").format(promo.discountValue)}đ'})",
                      ),
                    );
                  }).toList()
                : [],
            onChanged:
                promotions.isNotEmpty ? (value) => applyPromotion(value) : null,
          ),
          const SizedBox(height: 10),

          Text(
              "Tổng tiền: ${NumberFormat("#,###", "vi_VN").format(widget.order.totalPrice)}đ",
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(
              "Tổng phải trả: ${NumberFormat("#,###", "vi_VN").format(finalPrice)}đ",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
          const SizedBox(height: 10),

          // Nhập số tiền khách đưa
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Số tiền khách đưa",
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                amountReceived = double.tryParse(value) ?? 0.0;
              });
            },
          ),
          const SizedBox(height: 10),

          // Hiển thị tiền thừa
          Text(
            "Tiền thừa: ${NumberFormat("#,###", "vi_VN").format(amountReceived - finalPrice)}đ",
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 10),

          // Nút xác nhận thanh toán
          ElevatedButton(
            onPressed: completePayment,
            child: Text("Xác nhận thanh toán",
                style: TextStyle(fontSize: 16, color: Colors.white)),
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16)),
          ),
        ],
      ),
    );
  }
}
