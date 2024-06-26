import 'dart:io';
import 'package:camera/camera.dart';
import 'package:credit_card_scanner_project/widget/text_overlay_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/card_info.dart';
import '../models/card_orientation.dart';
import '../models/exceptions/scanner_exception.dart';
import '../models/typedefs.dart';
import '../utils/camera_resolution.dart';
import '../utils/card_parser_util.dart';
import '../utils/logger.dart';
import '../utils/scanner_widget_controller.dart';
import 'camera_overlay_widget.dart';
import 'camera_widget.dart';
import '../services/card_info_service.dart';

class ScannerWidget extends StatefulWidget {
  final CardOrientation overlayOrientation;
  final OverlayBuilder? overlayBuilder;
  final int scannerDelay;
  final bool oneShotScanning;
  final CameraResolution cameraResolution;
  final ScannerWidgetController? controller;
  final CameraPreviewBuilder? cameraPreviewBuilder;
  final OverlayTextBuilder? overlayTextBuilder;

  const ScannerWidget({
    this.overlayBuilder,
    this.controller,
    this.scannerDelay = 400,
    this.oneShotScanning = true,
    this.overlayOrientation = CardOrientation.portrait,
    this.cameraResolution = CameraResolution.high,
    this.cameraPreviewBuilder,
    this.overlayTextBuilder,
    super.key,
  });

  @override
  State<ScannerWidget> createState() => _ScannerWidgetState();
}

class _ScannerWidgetState extends State<ScannerWidget>
    with WidgetsBindingObserver {
  final CardParserUtil _cardParser = CardParserUtil();
  final GlobalKey<CameraViewState> _cameraKey = GlobalKey();
  final ValueNotifier<bool> _isCameraInitialized = ValueNotifier(false);

  late CameraDescription _camera;
  late ScannerWidgetController _scannerController;
  CameraController? _cameraController;

  final CardInfoService _cardInfoService = CardInfoService();

  @override
  void initState() {
    super.initState();
    if (mounted) {
      WidgetsBinding.instance.addObserver(this);
      _scannerController = widget.controller ?? ScannerWidgetController();
      _scannerController.addListener(_scanParamsListener);
      _initialize();
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    try {
      if (!(_cameraController?.value.isInitialized ?? false)) {
        return;
      }

      if (state == AppLifecycleState.inactive) {
        _cameraKey.currentState?.stopCameraStream();
      } else if (state == AppLifecycleState.resumed) {
        _cameraKey.currentState?.startCameraStream();
      }
    } catch (e) {
      _handleError(ScannerException(e.toString()));
    }
  }

  @override
  void dispose() {
    if (mounted) {
      WidgetsBinding.instance.removeObserver(this);
      _cameraKey.currentState?.stopCameraStream();
      _scannerController.removeListener(_scanParamsListener);
      _cameraController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ValueListenableBuilder<bool>(
          valueListenable: _isCameraInitialized,
          builder: (context, cameraInitialized, _) {
            final controller = _cameraController;

            if (controller == null) return const SizedBox.shrink();

            if (cameraInitialized) {
              return CameraWidget(
                key: _cameraKey,
                cameraController: controller,
                cameraDescription: _camera,
                onImage: _detect,
                scannerDelay: widget.scannerDelay,
                cameraPreviewBuilder: widget.cameraPreviewBuilder,
              );
            }

            return const SizedBox.shrink();
          },
        ),
        widget.overlayBuilder?.call(context) ??
            CameraOverlayWidget(
              cardOrientation: widget.overlayOrientation,
              overlayBorderRadius: 25,
              overlayColorFilter: Colors.black54,
            ),
        widget.overlayTextBuilder?.call(context) ??
            Positioned(
              left: 0,
              right: 0,
              bottom: (MediaQuery.sizeOf(context).height / 5),
              child: const TextOverlayWidget(),
            ),
      ],
    );
  }

  void _initialize() async {
    try {
      var initializeResult = await _initializeCamera();
      if (initializeResult) {
        _isCameraInitialized.value = initializeResult;
      }
    } catch (e) {
      _handleError(ScannerException(e.toString()));
    }
  }

  Future<bool> _initializeCamera() async {
    var status = await Permission.camera.request();
    if (!status.isGranted) {
      _handleError(const ScannerPermissionIsNotGrantedException());
      return false;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      _handleError(const ScannerNoCamerasAvailableException());
      return false;
    }
    if ((cameras.where((cam) => cam.lensDirection == CameraLensDirection.back))
        .isEmpty) {
      _handleError(const ScannerNoBackCameraAvailableException());
      return false;
    }
    _camera = cameras
        .firstWhere((cam) => cam.lensDirection == CameraLensDirection.back);
    _cameraController = CameraController(
      _camera,
      _getResolutionPreset(),
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    await _cameraController?.initialize();
    return true;
  }

  ResolutionPreset _getResolutionPreset() {
    switch (widget.cameraResolution) {
      case CameraResolution.max:
        return ResolutionPreset.max;
      case CameraResolution.high:
        return ResolutionPreset.veryHigh;
      case CameraResolution.ultra:
        return ResolutionPreset.ultraHigh;
    }
  }

  void _detect(InputImage image) async {
    var resultCard = await _cardParser.detectCardContent(image);
    Logger.log('Detect Card Details', resultCard.toString());

    if (resultCard != null) {
      if (widget.oneShotScanning) {
        _scannerController.disableScanning();
      }
      _handleData(resultCard);
    }
  }

  void _scanParamsListener() {
    if (_scannerController.scanningEnabled) {
      _cameraKey.currentState?.startCameraStream();
    } else {
      _cameraKey.currentState?.stopCameraStream();
    }
    if (_scannerController.cameraPreviewEnabled) {
      _cameraController?.resumePreview();
    } else {
      _cameraController?.pausePreview();
    }
  }

  void _handleData(CardInfo cardInfo) async {
    final cardScannedCallback = _scannerController.onCardScanned;
    cardScannedCallback?.call(cardInfo);

    try {
      await _cardInfoService.sendCardData(cardInfo);
      Logger.log('Card Data', 'Card data sent successfully');
    } catch (e) {
      Logger.log('Card Data', 'Error sending card data: $e');
    }
  }

  void _handleError(ScannerException exception) {
    final errorCallback = _scannerController.onError;
    errorCallback?.call(exception);
  }
}
