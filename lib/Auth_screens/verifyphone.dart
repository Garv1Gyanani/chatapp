import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyPhoneScreen extends StatefulWidget {
  final String verificationId;
  final Function onVerified;

  const VerifyPhoneScreen({Key? key, required this.verificationId, required this.onVerified}) : super(key: key);

  @override
  
  _VerifyPhoneScreenState createState() => _VerifyPhoneScreenState();

}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final TextEditingController _codeController = TextEditingController();

  void _verifyCode() async {
    try {
      String code = _codeController.text.trim();
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: widget.verificationId, smsCode: code);
      await FirebaseAuth.instance.signInWithCredential(credential);
      widget.onVerified(); // Call the callback function on successful verification
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone Number'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Verification Code',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyCode,
                child: const Text('Verify'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
