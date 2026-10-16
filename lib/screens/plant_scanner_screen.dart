import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class PlantScannerScreen extends StatefulWidget {
  const PlantScannerScreen({super.key});

  @override
  State<PlantScannerScreen> createState() =>
      _PlantScannerScreenState();
}

class _PlantScannerScreenState extends State<PlantScannerScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController =
  TextEditingController();

  bool _isScanning = false;
  String? _errorMessage;
  String? _imagePath;

  Future<void> _scanLabel() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (image == null || !mounted) {
        return;
      }

      setState(() {
        _isScanning = true;
        _imagePath = image.path;
        _nameController.clear();
      });

      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );

      String recognizedText;

      try {
        final inputImage = InputImage.fromFilePath(image.path);
        final result = await textRecognizer.processImage(inputImage);
        recognizedText = result.text;
      } finally {
        await textRecognizer.close();
      }

      if (!mounted) return;

      setState(() {
        _nameController.text = recognizedText.trim();
        _isScanning = false;

        if (recognizedText.trim().isEmpty) {
          _errorMessage =
          'Текст не распознан. Попробуйте сделать более чёткую фотографию '
              'или введите название вручную.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isScanning = false;
        _errorMessage =
        'Не удалось распознать текст. Попробуйте ещё раз '
            'или введите название вручную.';
      });

      debugPrint('Ошибка OCR: $e');
    }
  }

  void _confirmName() {
    final String name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Введите или распознайте название растения.';
      });
      return;
    }

    Navigator.of(context).pop(name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF477653);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сканирование растения'),
        backgroundColor: const Color(0xFFE5EDDF),
        foregroundColor: const Color(0xFF294B31),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.document_scanner_outlined,
                    size: 64,
                    color: primaryGreen,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Наведите камеру на этикетку',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Постарайтесь, чтобы название было '
                        'хорошо освещено и находилось в фокусе.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _scanLabel,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Сфотографировать этикетку'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            if (_isScanning) ...[
              const SizedBox(height: 24),
              const Center(
                child: CircularProgressIndicator(
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Распознаём текст...',
                textAlign: TextAlign.center,
              ),
            ],

            if (_imagePath != null && !_isScanning) ...[
              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: primaryGreen),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Фотография обработана',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            const Text(
              'Распознанное название',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _nameController,
              enabled: !_isScanning,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Например, Монстера',
                prefixIcon: const Icon(Icons.eco_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: _isScanning ? null : _confirmName,
              icon: const Icon(Icons.check),
              label: const Text('Подтвердить название'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Перед подтверждением можно исправить '
                  'ошибки распознавания вручную.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}