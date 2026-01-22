import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:cloud_functions/cloud_functions.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:lottie/lottie.dart'; // 🔥 Lottie import kiya

class PaymentService {
  late Razorpay _razorpay;

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String _razorpayKey = "rzp_live_S1SIB8qif2h9V5";

  Function? onPaymentSuccess;

  Function? onPaymentError;

  void init({
    required Function successCallback,

    required Function failureCallback,
  }) {
    _razorpay = Razorpay();

    onPaymentSuccess = successCallback;

    onPaymentError = failureCallback;

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);

    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // 🎆 CELEBRATION DIALOG LOGIC

  void _showSuccessCelebration(BuildContext context) {
    showDialog(
      context: context,

      barrierDismissible: false,

      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,

          elevation: 0,

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              // Lottie Animation
              Lottie.network(
                'https://assets9.lottiefiles.com/packages/lf20_tou9ypsa.json',

                repeat: false,

                width: 300,

                height: 300,
              ),

              const SizedBox(height: 10),

              const Text(
                "Congratulations! 🏆",

                style: TextStyle(
                  color: Colors.amber,

                  fontSize: 24,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const Text(
                "Premium Access Activated",

                style: TextStyle(color: Colors.white, fontSize: 16),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),

                onPressed: () => Navigator.pop(context),

                child: const Text(
                  "Get Started",

                  style: TextStyle(
                    color: Colors.black,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> openCheckout({
    required int amountInRupees,

    required BuildContext context,
  }) async {
    try {
      Fluttertoast.showToast(msg: "Connecting to secure server...");

      HttpsCallable callable = _functions.httpsCallable('createOrder');

      final response = await callable.call(<String, dynamic>{
        'amount': amountInRupees,
      });

      final String orderId = response.data['orderId'];

      var options = {
        'key': _razorpayKey,

        'amount': amountInRupees * 100,

        'name': 'Smart Prep Pro',

        'order_id': orderId,

        'description': 'Premium Plan Activation',

        'prefill': {
          'contact': '',

          'email': _auth.currentUser?.email ?? 'user@example.com',
        },

        'notes': {'userId': _auth.currentUser!.uid},

        'modal': {'confirm_close': true},
      };

      // Pass context for celebration dialog

      _razorpay.open(options);
    } catch (e) {
      debugPrint('Order Error: $e');

      Fluttertoast.showToast(msg: "Server Busy! Please try again.");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Fluttertoast.showToast(
      msg: "Verifying with Bank...",

      toastLength: Toast.LENGTH_LONG,
    );

    try {
      HttpsCallable verifyCallable = _functions.httpsCallable('verifyPayment');

      final result = await verifyCallable.call({
        'razorpay_order_id': response.orderId,

        'razorpay_payment_id': response.paymentId,

        'razorpay_signature': response.signature,
      });

      if (result.data['status'] == 'verified') {
        await _updatePremiumAccess(response.paymentId!, response.orderId!);

        // 🔥 Celebration dikhane ke liye current context dhoondna (Navigator state se)

        // Note: Ideal tarika openCheckout mein context save karna hai

        onPaymentSuccess?.call();

        Fluttertoast.showToast(
          msg: "Success! Premium Activated.",

          backgroundColor: Colors.green,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Security Check Failed!",

          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      debugPrint('Verification Error: $e');

      Fluttertoast.showToast(
        msg: "Processing... Please check status in a minute.",
      );
    }
  }

  Future<void> _updatePremiumAccess(String paymentId, String orderId) async {
    final user = _auth.currentUser;

    if (user == null) return;

    WriteBatch batch = _firestore.batch();

    DocumentReference userRef = _firestore.collection('users').doc(user.uid);

    batch.update(userRef, {
      'isPremium': true,

      'plan': 'Premium_Activated',

      'lastPurchaseDate': FieldValue.serverTimestamp(),
    });

    DocumentReference paymentRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('payments')
        .doc(paymentId);

    batch.set(paymentRef, {
      'amount': 'Premium Plan',

      'order_id': orderId,

      'paymentId': paymentId,

      'status': 'success',

      'timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onPaymentError?.call();

    Fluttertoast.showToast(
      msg: "Payment Cancelled",

      backgroundColor: Colors.red,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "Wallet Selected: ${response.walletName}");
  }

  void dispose() {
    _razorpay.clear();
  }
}
