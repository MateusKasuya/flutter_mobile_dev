import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/veiculo.dart';
import '../providers/auth_provider.dart';
import '../services/frota_service.dart' as frota_service;
import '../services/ocr_service.dart' as ocr_service;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/breakpoints.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_toast.dart';
import '../utils/friendly_error.dart';
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

    // Depois de um await o widget pode ter sido desmontado (usuario saiu da tela).
    // Se isso ocorreu, mexer em setState/controller lanca erro; entao abortamos.
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final ocrText = await widget.ocrFn(photo.path);
      // Idem: apos o await do OCR, garantimos que o widget ainda esta montado
      // antes de escrever no _placaController (que seria disposto no dispose()).
      if (!mounted) return;
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
        MaterialPageRoute(builder: (_) => FrotaDetalheScreen(veiculo: veiculo)),
      );
    } catch (e) {
      showErrorToast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= kTabletBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.backgroundScreen,
      appBar: AppBar(
        title: isTablet
            ? SvgPicture.asset(
                'assets/logo_horizontal.svg',
                height: 22,
                width: 177.17,
              )
            : Text(
                'Buscar Veículo',
                style: AppTextStyles.labelBar,
                textAlign: TextAlign.center,
              ),
        centerTitle: true,
        backgroundColor: Colors.white,
        toolbarHeight: 60,
      ),
      body: Padding(
        padding: const EdgeInsets.all(26),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isTablet) ...[
                const SizedBox(height: 36),
                Text('Buscar veículo', style: AppTextStyles.screenTitleTablet),
                const SizedBox(height: 13),
              ] else
                const SizedBox(height: 26),
              Text('Placa do veículo', style: AppTextStyles.sublabelForm),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: TextFormField(
                  controller: _placaController,
                  textCapitalization: TextCapitalization.characters,
                  style: AppTextStyles.inputValue,
                  decoration: InputDecoration(
                    hintText: 'ABC1D23',
                    hintStyle: AppTextStyles.inputPlaceholder,
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 18, right: 12),
                      child: SvgPicture.asset(
                        'assets/frota-icon.svg',
                        height: 16,
                        width: 25.64,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.textPlaceholder,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.textPlaceholder,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.textPlaceholder,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe a placa';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(56),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x4D000000),
                      offset: Offset(0, 4),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _buscar,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.search, size: 16, weight: 700),
                  label: Text(
                    _isLoading ? 'Buscando...' : 'Buscar',
                    style: AppTextStyles.button,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(56),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Desabilita o FAB durante o loading para evitar scan/busca concorrente.
        // Com onPressed null, o Flutter ja deixa o botao visualmente acinzentado.
        onPressed: _isLoading ? null : _scanPlaca,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
