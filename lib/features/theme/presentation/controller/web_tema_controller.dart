// presentation/controllers/tema_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:notehub/core/const/config.dart';
import 'package:notehub/features/theme/domain/tema_repository.dart';
import 'package:notehub/features/theme/models/tema_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebTemaController extends GetxController {
  late final WebViewController webViewController;
  final TemaRepository repository;

  WebTemaController({required this.repository});

  @override
  void onInit() {
    super.onInit();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'ThemeChannel',
        // jika menerima pesan dari JS
        onMessageReceived: (msg) async {
          print("📩 Dari JS: ${msg.message}");
          try {
            final data = jsonDecode(msg.message); // data dari JS
            final tema = TemaModel.fromJs(data); // buat TemaModel dari data JS
            await repository.updateTema(tema); // simpan tema ke database dengan rest API
            Get.snackbar(
              "Sukses",
              "Tema berhasil disimpan untuk Note ${tema.noteId}",
              duration: Duration(seconds: 3),
            );
          } catch (e) {
            Get.snackbar(
              "Sukses",
              "alert('Gagal simpan tema: $e')",
              duration: Duration(seconds: 3),
            );
          }
        },
      );
  }

  Future<void> loadPage(String noteId, String userName) async {
    final fullUrl = "${Config.url_web}note_id=$noteId&user_name=$userName&_v=${DateTime.now().millisecondsSinceEpoch}";

    // bersihkan cache dulu agar menggunakan tampilan web terbaru
    await webViewController.clearCache();
    // load webview controller dengan URL yang juga ada param noteId & userName
    webViewController.loadRequest(Uri.parse(fullUrl));
  }
}
