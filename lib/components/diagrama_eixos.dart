import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/eixo.dart';
import '../models/pneu.dart';

const _chassisGap = 24.0;
const _chassisWidth = 4.0;
const _hubSize = 14.0;

// Dimensões do pneu em vista de cima:
// estreito na direção do eixo (largura da seção) e alto na direção de rolagem.
const _tireW = 30.0;
const _tireH = 54.0;
const _labelH = 16.0; // espaço acima do pneu para o número

// Centro vertical do círculo do pneu a partir do topo do tile completo.
const _tireCenterFromTop = _labelH + _tireH / 2;

class DiagramaEixos extends StatelessWidget {
  final List<Eixo> eixos;
  final void Function(Pneu pneu)? onPneuTap;
  final void Function(Pneu pneu)? onPneuDoubleTap;
  final void Function(String localEixo)? onSlotVazioDoubleTap;

  const DiagramaEixos({
    super.key,
    required this.eixos,
    this.onPneuTap,
    this.onPneuDoubleTap,
    this.onSlotVazioDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    if (eixos.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _DirecaoIndicator(),
          const SizedBox(height: 12),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned.fill(child: _ChassisRails()),
                Column(
                  children: [
                    const _Parachoque(),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (final eixo in eixos)
                            _EixoRow(
                              eixo: eixo,
                              onPneuTap: onPneuTap,
                              onPneuDoubleTap: onPneuDoubleTap,
                              onSlotVazioDoubleTap: onSlotVazioDoubleTap,
                            ),
                        ],
                      ),
                    ),
                    const _Parachoque(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChassisRails extends StatelessWidget {
  const _ChassisRails();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: _chassisWidth,
          decoration: BoxDecoration(
            color: Colors.grey.shade500,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: _chassisGap),
        Container(
          width: _chassisWidth,
          decoration: BoxDecoration(
            color: Colors.grey.shade500,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

/// Parachoque dianteiro ou traseiro em vista de cima.
/// Usa LayoutBuilder para escalar com a largura disponível.
class _Parachoque extends StatelessWidget {
  const _Parachoque();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth * 0.54;
        return SizedBox(
          width: double.infinity,
          height: 14,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Corpo do parachoque
                Container(
                  width: w,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.grey.shade500,
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                // Nervura central (profundidade)
                Container(
                  width: w * 0.55,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DirecaoIndicator extends StatelessWidget {
  const _DirecaoIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.keyboard_arrow_up, size: 18, color: Colors.grey.shade500),
        Text(
          'Frente',
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _EixoRow extends StatelessWidget {
  final Eixo eixo;
  final void Function(Pneu pneu)? onPneuTap;
  final void Function(Pneu pneu)? onPneuDoubleTap;
  final void Function(String localEixo)? onSlotVazioDoubleTap;

  const _EixoRow({
    required this.eixo,
    this.onPneuTap,
    this.onPneuDoubleTap,
    this.onSlotVazioDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Barra do eixo (fundo)
        Positioned(
          top: _tireCenterFromTop - 2,
          left: 0,
          right: 0,
          child: Container(height: 4, color: Colors.grey.shade400),
        ),
        // 2. Hubs nos cruzamentos com as longarinas
        Positioned(
          top: _tireCenterFromTop - _hubSize / 2,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HubIndicator(),
              const SizedBox(width: _chassisGap + _chassisWidth - _hubSize),
              _HubIndicator(),
            ],
          ),
        ),
        // 3. Row de tiles (frente — pneus sobrepõem o eixo)
        Row(
          children: [
            _buildLadoEsquerdo(
              externo: eixo.esquerdoExterno,
              interno: eixo.esquerdoInterno,
              isDuplo: eixo.rodadoDuplo,
              n: eixo.numero,
            ),
            Expanded(
              child: Align(
                alignment: Alignment(
                  0,
                  (_tireCenterFromTop / (_labelH + _tireH)) * 2 - 1,
                ),
                child: _EixoLabel(numero: eixo.numero),
              ),
            ),
            _buildLadoDireito(
              externo: eixo.direitoExterno,
              interno: eixo.direitoInterno,
              isDuplo: eixo.rodadoDuplo,
              n: eixo.numero,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLadoEsquerdo({
    Pneu? externo,
    Pneu? interno,
    required bool isDuplo,
    required int n,
  }) {
    final posExterno = isDuplo ? '${n}EE' : '${n}E';
    final posInterno = '${n}EI';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PneuTile(
          pneu: externo,
          onTap: onPneuTap,
          onDoubleTap: onPneuDoubleTap,
          onEmptyDoubleTap: externo == null
              ? () => onSlotVazioDoubleTap?.call(posExterno)
              : null,
        ),
        if (isDuplo) ...[
          const SizedBox(width: 3),
          _PneuTile(
            pneu: interno,
            onTap: onPneuTap,
            onDoubleTap: onPneuDoubleTap,
            onEmptyDoubleTap: interno == null
                ? () => onSlotVazioDoubleTap?.call(posInterno)
                : null,
          ),
        ],
      ],
    );
  }

  Widget _buildLadoDireito({
    Pneu? externo,
    Pneu? interno,
    required bool isDuplo,
    required int n,
  }) {
    final posExterno = isDuplo ? '${n}DE' : '${n}D';
    final posInterno = '${n}DI';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDuplo) ...[
          _PneuTile(
            pneu: interno,
            onTap: onPneuTap,
            onDoubleTap: onPneuDoubleTap,
            onEmptyDoubleTap: interno == null
                ? () => onSlotVazioDoubleTap?.call(posInterno)
                : null,
          ),
          const SizedBox(width: 3),
        ],
        _PneuTile(
          pneu: externo,
          onTap: onPneuTap,
          onDoubleTap: onPneuDoubleTap,
          onEmptyDoubleTap: externo == null
              ? () => onSlotVazioDoubleTap?.call(posExterno)
              : null,
        ),
      ],
    );
  }
}

class _HubIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: _hubSize,
      height: _hubSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade500, width: 2),
      ),
    );
  }
}

class _EixoLabel extends StatelessWidget {
  final int numero;
  const _EixoLabel({required this.numero});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Text(
        'E$numero',
        style: GoogleFonts.montserrat(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}

/// Pneu em vista de cima: cápsula com sulcos longitudinais e sipes transversais.
class _PneuTile extends StatelessWidget {
  final Pneu? pneu;
  final void Function(Pneu pneu)? onTap;
  final void Function(Pneu pneu)? onDoubleTap;
  final VoidCallback? onEmptyDoubleTap;

  const _PneuTile({
    this.pneu,
    this.onTap,
    this.onDoubleTap,
    this.onEmptyDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    if (pneu == null) {
      final emptySlot = SizedBox(
        width: _tireW,
        height: _labelH + _tireH,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: _labelH),
            CustomPaint(
              size: const Size(_tireW, _tireH),
              painter: const _EmptyTirePainter(),
            ),
          ],
        ),
      );
      if (onEmptyDoubleTap == null) return emptySlot;
      return GestureDetector(
        onDoubleTap: onEmptyDoubleTap,
        child: emptySlot,
      );
    }

    return GestureDetector(
      onTap: () => onTap?.call(pneu!),
      onDoubleTap: () => onDoubleTap?.call(pneu!),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Número acima do pneu
          SizedBox(
            height: _labelH,
            width: _tireW,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                pneu!.nroPneu,
                style: GoogleFonts.montserrat(
                  color: Colors.grey.shade800,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Pneu (vista de cima)
          CustomPaint(
            size: const Size(_tireW, _tireH),
            painter: const _TirePainter(),
          ),
        ],
      ),
    );
  }
}

/// Slot de posição de pneu vazia: cápsula com borda tracejada.
class _EmptyTirePainter extends CustomPainter {
  const _EmptyTirePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final radius = w / 2;

    final rrect = RRect.fromLTRBR(0, 0, w, h, Radius.circular(radius));

    // Fill cinza claro
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFEEEEEE));

    final paint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()..addRRect(rrect);

    const dashLength = 4.0;
    const gapLength = 3.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      var drawing = true;
      while (distance < metric.length) {
        final end = (distance + (drawing ? dashLength : gapLength))
            .clamp(0.0, metric.length);
        if (drawing) {
          canvas.drawPath(metric.extractPath(distance, end), paint);
        }
        distance = end;
        drawing = !drawing;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

/// Desenha um pneu realista visto de cima:
/// - Cápsula escura (borracha)
/// - Dois sulcos longitudinais principais
/// - Sipes transversais nos blocos de banda de rodagem
/// - Ombros (shoulders) definidos nas laterais
class _TirePainter extends CustomPainter {
  const _TirePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final radius = w / 2;

    final outerRRect =
        RRect.fromLTRBR(0, 0, w, h, Radius.circular(radius));

    // ── 1. Borracha externa (base da cápsula) ──────────────────────
    canvas.drawRRect(outerRRect, Paint()..color = const Color(0xFF111111));

    // ── 2. Ombros (shoulders) — faixas laterais ligeiramente mais claras
    final shoulderW = w * 0.16;
    final shoulderPaint = Paint()..color = const Color(0xFF1F1F1F);
    // ombro esquerdo
    canvas.drawRect(
      Rect.fromLTWH(0, radius, shoulderW, h - radius * 2),
      shoulderPaint,
    );
    // ombro direito
    canvas.drawRect(
      Rect.fromLTWH(w - shoulderW, radius, shoulderW, h - radius * 2),
      shoulderPaint,
    );

    // ── 3. Área de banda de rodagem central ───────────────────────
    final treadL = shoulderW;
    final treadR = w - shoulderW;
    canvas.drawRect(
      Rect.fromLTWH(treadL, radius * 0.35, treadR - treadL, h - radius * 0.70),
      Paint()..color = const Color(0xFF181818),
    );

    // ── 4. Sulcos longitudinais principais (2 canais de drenagem) ──
    final groove1X = w * 0.37;
    final groove2X = w * 0.63;
    final groovePaint = Paint()
      ..color = const Color(0xFF060606)
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    canvas.drawLine(
      Offset(groove1X, radius * 0.4),
      Offset(groove1X, h - radius * 0.4),
      groovePaint,
    );
    canvas.drawLine(
      Offset(groove2X, radius * 0.4),
      Offset(groove2X, h - radius * 0.4),
      groovePaint,
    );

    // ── 5. Sipes transversais (cortes nos blocos) ──────────────────
    final sipePaint = Paint()
      ..color = const Color(0xFF0A0A0A)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    const blockCount = 6; // número de blocos por coluna
    final blockH = (h - radius) / blockCount;
    for (int i = 1; i < blockCount; i++) {
      final y = radius * 0.5 + i * blockH;
      // Sipe no bloco esquerdo
      canvas.drawLine(
        Offset(treadL + 1, y),
        Offset(groove1X - 1, y),
        sipePaint,
      );
      // Sipe no bloco central (offset para criar padrão alternado)
      canvas.drawLine(
        Offset(groove1X + 1, y + blockH * 0.35),
        Offset(groove2X - 1, y + blockH * 0.35),
        sipePaint,
      );
      // Sipe no bloco direito
      canvas.drawLine(
        Offset(groove2X + 1, y),
        Offset(treadR - 1, y),
        sipePaint,
      );
    }

    // ── 6. Mini-sulco de ombro (detalhe de textura nas laterais) ───
    final shoulderSipePaint = Paint()
      ..color = const Color(0xFF0D0D0D)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < blockCount * 2; i++) {
      final y = radius * 0.5 + i * (blockH / 2);
      if (y > radius * 0.5 && y < h - radius * 0.5) {
        canvas.drawLine(
          Offset(2, y),
          Offset(shoulderW - 1, y),
          shoulderSipePaint,
        );
        canvas.drawLine(
          Offset(w - shoulderW + 1, y),
          Offset(w - 2, y),
          shoulderSipePaint,
        );
      }
    }

    // ── 7. Borda da cápsula (highlight da parede lateral) ──────────
    canvas.drawRRect(
      outerRRect,
      Paint()
        ..color = const Color(0xFF2C2C2C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
