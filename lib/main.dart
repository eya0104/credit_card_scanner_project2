import 'package:credit_card_scanner_project/authentication/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:credit_card_scanner_project/utils/camera_resolution.dart';
import 'package:credit_card_scanner_project/utils/scanner_widget_controller.dart';
import 'package:credit_card_scanner_project/widget/scanner_widget.dart';
import 'models/exceptions/scanner_exception.dart';


import 'models/card_info.dart';
import 'models/card_orientation.dart';


import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(home: LoginScreen()));
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ScannerWidgetController _controller = ScannerWidgetController();
  final ValueNotifier<CardInfo?> _cardInfo = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _controller
      ..setCardListener(_onListenCard)
      ..setErrorListener(_onError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('credit card scanner'),
        centerTitle: true ,
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ScannerWidget(
                controller: _controller,
                overlayOrientation: CardOrientation.landscape,
                cameraResolution: CameraResolution.max,
              ),
            ),
            Container(
              width: MediaQuery.sizeOf(context).width,
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  ValueListenableBuilder<CardInfo?>(
                    valueListenable: _cardInfo,
                    builder: (context, card, child) {
                      return Text(card?.toString() ?? 'No Card Details');
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller
      ..removeCardListeners(_onListenCard)
      ..removeErrorListener(_onError)
      ..dispose();
    super.dispose();
  }

  void _onListenCard(CardInfo? value) {
    _cardInfo.value = value;
  }

  void _onError(ScannerException exception) {
    if (kDebugMode) {
      print('Error: ${exception.message}');
    }
  }
}
