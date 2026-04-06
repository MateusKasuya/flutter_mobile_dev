import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/veiculo.dart';
import '../providers/auth_provider.dart';
import '../services/frota_service.dart' as frota_service;
import '../services/ocr_service.dart' as ocr_service;
import '../utils/app_toast.dart';
import '../utils/placa_utils.dart';
import 'frota_detalhe_screen.dart';

Future<XFile?> _defaultPickImage() async {
  final picker = ImagePicker();
  return picker.pickImage(
    source: ImageSource.camera,
    preferredCameraDevice: CameraDevice.rear,
    imageQuality: 85,
  );
}

Future<String> _defaultOcr(String imagePath) =>
    ocr_service.extractTextFromImage(imagePath);

class FrotaBuscaScreen extends StatefulWidget {
  final Future<Veiculo> Function(String token, String placa) fetchFn;
  final Future<XFile?> Function() pickImageFn;
  final Future<String> Function(String imagePath) ocrFn;

  const FrotaBuscaScreen({
    super.key,
    this.fetchFn = frota_service.fetchVeiculo,
    this.pickImageFn = _defaultPickImage,
    this.ocrFn = _defaultOcr,
  });

  @override
  State<FrotaBuscaScreen> createState() => _FrotaBuscaScreenState();
}

class _FrotaBuscaScreenState extends State<FrotaBuscaScreen> {
  final _placaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _placaController.dispose();
    super.dispose();
  }

  Future<void> _scanPlaca() async {
    final photo = await widget.pickImageFn();
    if (photo == null) return;

    setState(() => _isLoading = true);

    try {
      final ocrText = await widget.ocrFn(photo.path);
      final placa = extractPlaca(ocrText);

      if (placa != null) {
        _placaController.text = placa;
        showSuccessToast('Placa detectada: $placa');
      } else {
        showErrorToast('Nenhuma placa encontrada na imagem');
      }
    } catch (e) {
      showErrorToast('Erro ao processar imagem: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _buscar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final token = context.read<AuthProvider>().token;
      final veiculo = await widget.fetchFn(
        token,
        _placaController.text.trim().toUpperCase(),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FrotaDetalheScreen(veiculo: veiculo),
        ),
      );
    } catch (e) {
      showErrorToast(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Veículo')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: _placaController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Placa do veículo',
                  hintText: 'Ex: ABC1D23',
                  prefixIcon: Icon(Icons.directions_car),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a placa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _buscar,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: Text(_isLoading ? 'Buscando...' : 'Buscar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanPlaca,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
