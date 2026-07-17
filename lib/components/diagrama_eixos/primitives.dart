import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/eixo.dart';
import '../../models/pneu.dart';
import '../../theme/app_colors.dart';

const double chassisGap = 24.0;
const double chassisGapTablet = 58.0;
const double chassisWidth = 3.0;
const double chassisWidthTablet = 6.0;
const double hubSize = 12.0;
const double hubSizeTablet = 30.0;

// Dimensões do pneu em vista de cima:
// estreito na direção do eixo (largura da seção) e alto na direção de rolagem.
const double tireW = 28.0;
const double tireH = 47.0;
const double tireWTablet = 62.0;
const double tireHTablet = 105.0;
const double labelH = 16.0; // espaço acima do pneu para o número
const double labelToTireGap = 7.0; // espaço entre o número e o pneu
const double labelHTablet = 24.0;
const double labelToTireGapTablet = 19.0;

// Centro vertical do círculo do pneu a partir do topo do tile completo.
const double tireCenterFromTop = labelH + labelToTireGap + tireH / 2;
const double tireCenterFromTopTablet =
    labelHTablet + labelToTireGapTablet + tireHTablet / 2;

// Faixa de estepes, ACIMA do chassi. Por ser uma faixa horizontal (e não uma
// coluna disputando largura com os eixos), o rótulo usa a mesma fonte do rótulo
// do eixo — não há mais aperto de largura que exigisse encolhê-lo.
const double estepeLabelFont = 10.0;
const double estepeLabelFontTablet = 16.0;
const double estepeSlotGap = 16.0; // respiro horizontal entre X1 e X2
const double estepeSlotGapTablet = 34.0;
const double estepeBandBottomGap = 8.0; // respiro entre a faixa e o chassi
const double estepeBandBottomGapTablet = 16.0;

// Altura aproximada da faixa, usada só no orçamento de altura do diagrama
// (a faixa em si tem altura natural). Generosa de propósito: se sobrar, vira
// um respiro; o cálculo nunca depende dela para evitar overflow.
const double estepeBandHeight = 112.0;
const double estepeBandHeightTablet = 212.0;

/// Indicador "FRENTE" no topo do diagrama.
class DirecaoIndicator extends StatelessWidget {
  final bool isTablet;

  const DirecaoIndicator({super.key, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    // No tablet, chevron iOS rotacionado (spec do Figma: 11×22, angle 90,
    // cor #5F5F5F). No mobile, mantém o keyboard_arrow_up original.
    // Setas dos dois lados deixam o Row naturalmente simétrico, então o
    // "FRENTE" cai no centro visual (alinhado com o chassi) sem spacer.
    final arrow = isTablet
        ? const RotatedBox(
            quarterTurns: 3,
            child: Icon(
              Icons.arrow_forward_ios,
              size: 22,
              color: Color(0xFF5F5F5F),
            ),
          )
        : const Icon(
            Icons.keyboard_arrow_up,
            size: 18,
            color: Color(0xFF5F5F5F),
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        arrow,
        const SizedBox(width: 4),
        Text(
          'FRENTE',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: isTablet ? 16 : 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF363636),
            height: 1.0,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: 4),
        arrow,
      ],
    );
  }
}

/// Duas longarinas verticais (chassi visto de cima).
class ChassisRails extends StatelessWidget {
  final bool isTablet;

  const ChassisRails({super.key, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final width = isTablet ? chassisWidthTablet : chassisWidth;
    final gap = isTablet ? chassisGapTablet : chassisGap;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: width,
          decoration: BoxDecoration(
            color: AppColors.textPlaceholder,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: gap),
        Container(
          width: width,
          decoration: BoxDecoration(
            color: AppColors.textPlaceholder,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

/// Parachoque dianteiro ou traseiro em vista de cima.
class Parachoque extends StatelessWidget {
  final bool isTablet;

  const Parachoque({super.key, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final outerWidth = isTablet ? 340.0 : 152.0;
    final outerHeight = isTablet ? 31.0 : 14.0;

    return SizedBox(
      width: double.infinity,
      height: outerHeight,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Corpo externo
            Container(
              width: outerWidth,
              height: outerHeight,
              decoration: BoxDecoration(
                color: AppColors.textPlaceholder,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            // Barra interna (nervura central)
            Container(
              width: isTablet ? 177 : 79,
              height: isTablet ? 6 : 3,
              decoration: BoxDecoration(
                color: const Color(0xFF363636),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pino-rei (king pin) / quinta-roda em vista de cima.
/// Usado na traseira de cavalos mecânicos e na dianteira de carretas — onde
/// o engate é feito em vez de um parachoque sólido.
class PinoRei extends StatelessWidget {
  const PinoRei({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 14,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Placa de engate (faixa horizontal curta)
            Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            // Pino central (círculo destacado)
            Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade600, width: 1.5),
              ),
            ),
            // Ponto interno do pino
            Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Linha de um eixo: barra horizontal + 2 hubs nas longarinas + pneus nas pontas
/// + label central (E1, E2…).
class EixoRow extends StatelessWidget {
  final Eixo eixo;
  final bool isTablet;
  final void Function(Pneu pneu)? onPneuTap;
  final void Function(Pneu pneu)? onPneuDoubleTap;
  final void Function(String localEixo)? onSlotVazioDoubleTap;

  const EixoRow({
    super.key,
    required this.eixo,
    this.isTablet = false,
    this.onPneuTap,
    this.onPneuDoubleTap,
    this.onSlotVazioDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final barHeight = isTablet ? 6.0 : 3.0;
    final cw = isTablet ? chassisWidthTablet : chassisWidth;
    final cg = isTablet ? chassisGapTablet : chassisGap;
    final centerTop =
        isTablet ? tireCenterFromTopTablet : tireCenterFromTop;
    final th = isTablet ? tireHTablet : tireH;
    final lh = isTablet ? labelHTablet : labelH;
    return Stack(
      children: [
        // 1. Barra do eixo (fundo)
        Positioned(
          top: centerTop - barHeight / 2,
          left: 0,
          right: 0,
          child: Container(height: barHeight, color: AppColors.textHint),
        ),
        // 2. Hubs nos cruzamentos com as longarinas
        Positioned(
          top: centerTop - (isTablet ? hubSizeTablet : hubSize) / 2,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HubIndicator(isTablet: isTablet),
              SizedBox(
                width: cg + cw - (isTablet ? hubSizeTablet : hubSize),
              ),
              HubIndicator(isTablet: isTablet),
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
                  (centerTop / (lh + th)) * 2 - 1,
                ),
                child: EixoLabel(numero: eixo.numero, isTablet: isTablet),
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
        PneuTile(
          pneu: externo,
          isTablet: isTablet,
          onTap: onPneuTap,
          onDoubleTap: onPneuDoubleTap,
          onEmptyDoubleTap: externo == null
              ? () => onSlotVazioDoubleTap?.call(posExterno)
              : null,
        ),
        if (isDuplo) ...[
          SizedBox(width: isTablet ? 20 : 9),
          PneuTile(
            pneu: interno,
            isTablet: isTablet,
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
          PneuTile(
            pneu: interno,
            isTablet: isTablet,
            onTap: onPneuTap,
            onDoubleTap: onPneuDoubleTap,
            onEmptyDoubleTap: interno == null
                ? () => onSlotVazioDoubleTap?.call(posInterno)
                : null,
          ),
          SizedBox(width: isTablet ? 20 : 9),
        ],
        PneuTile(
          pneu: externo,
          isTablet: isTablet,
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

/// Cubo (hub) na ponta da barra do eixo, sob a longarina.
class HubIndicator extends StatelessWidget {
  final bool isTablet;

  const HubIndicator({super.key, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final size = isTablet ? hubSizeTablet : hubSize;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.textPlaceholder, width: 2),
      ),
    );
  }
}

/// Rótulo do eixo (E1, E2…) — fica no centro da barra.
class EixoLabel extends StatelessWidget {
  final int numero;
  final bool isTablet;

  const EixoLabel({super.key, required this.numero, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isTablet ? 58 : 26,
      height: isTablet ? 44 : 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFF5F5F5F)),
      ),
      child: Text(
        'E$numero',
        textAlign: TextAlign.center,
        style: GoogleFonts.montserrat(
          fontSize: isTablet ? 16 : 10,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF363636),
          height: 1.0,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

/// Pneu em vista de cima: cápsula com sulcos longitudinais e sipes transversais.
/// Quando [pneu] é null, mostra slot vazio com borda tracejada.
class PneuTile extends StatelessWidget {
  final Pneu? pneu;
  final bool isTablet;
  final void Function(Pneu pneu)? onTap;
  final void Function(Pneu pneu)? onDoubleTap;
  final VoidCallback? onEmptyDoubleTap;

  const PneuTile({
    super.key,
    this.pneu,
    this.isTablet = false,
    this.onTap,
    this.onDoubleTap,
    this.onEmptyDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final tw = isTablet ? tireWTablet : tireW;
    final th = isTablet ? tireHTablet : tireH;
    final lh = isTablet ? labelHTablet : labelH;
    final gap = isTablet ? labelToTireGapTablet : labelToTireGap;

    if (pneu == null) {
      final emptySlot = SizedBox(
        width: tw,
        height: lh + gap + th,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: lh + gap),
            CustomPaint(
              size: Size(tw, th),
              painter: const EmptyTirePainter(),
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
            height: lh,
            width: tw,
            child: Align(
              alignment: Alignment.bottomCenter,
              // A caixa do rótulo tem a largura do PNEU (28pt no celular), mas
              // o número vem da API com até 5 dígitos — que nesta fonte chegam
              // a ~31pt, porque dígito largo ("9") ocupa mais que estreito
              // ("1"). Sem o FittedBox o Text corta o excedente EM SILÊNCIO
              // (TextOverflow.clip é o default do Flutter) e o último dígito
              // some; no rodado duplo não há sequer pra onde transbordar, já
              // que os dois pneus ficam a 9pt um do outro.
              //
              // scaleDown = reduz só quando não cabe, nunca aumenta: 3 e 4
              // dígitos (a maioria) seguem exatamente no tamanho de design, e o
              // de 5 encolhe ~11% em vez de perder um dígito. Acima de 5 continua
              // legível, encolhendo mais — degrada em vez de cortar.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  pneu!.nroPneu,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF363636),
                    fontSize: isTablet ? 20 : 10,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: gap),
          // Pneu (vista de cima)
          CustomPaint(
            size: Size(tw, th),
            painter: const TirePainter(),
          ),
        ],
      ),
    );
  }
}

/// Faixa de estepes, desenhada ACIMA do chassi.
///
/// O estepe não pertence a eixo nenhum — a API o identifica pelo `localeixo`
/// `X1`/`X2` —, então ele fica fora do frame, numa faixa horizontal no topo do
/// diagrama: os slots são [PneuTile]s idênticos aos dos eixos (mesmo toque para
/// detalhes, duplo toque para movimentar/montar), lado a lado, sob o rótulo
/// comum "ESTEPE". Os slots não são rotulados individualmente (`X1`/`X2` é só a
/// posição interna, mandada à API na montagem); o número do pneu montado
/// aparece acima dele, como nos eixos.
///
/// Por ser uma faixa (e não uma coluna lateral), não disputa largura com os
/// eixos: os dois pneus somam ~60pt, que cabem folgado mesmo no celular
/// pequeno. O custo é altura — a faixa empurra o chassi pra baixo.
///
/// [estepes] tem uma posição por slot, na ordem `X1`, `X2`; `null` = vazio.
class EstepeBand extends StatelessWidget {
  final List<Pneu?> estepes;
  final bool isTablet;
  final void Function(Pneu pneu)? onPneuTap;
  final void Function(Pneu pneu)? onPneuDoubleTap;
  final void Function(String localEixo)? onSlotVazioDoubleTap;

  const EstepeBand({
    super.key,
    required this.estepes,
    this.isTablet = false,
    this.onPneuTap,
    this.onPneuDoubleTap,
    this.onSlotVazioDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final fonte = isTablet ? estepeLabelFontTablet : estepeLabelFont;
    final slotGap = isTablet ? estepeSlotGapTablet : estepeSlotGap;

    return Padding(
      padding: EdgeInsets.only(
        bottom: isTablet ? estepeBandBottomGapTablet : estepeBandBottomGap,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ESTEPE',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: fonte,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF363636),
              height: 1.0,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: isTablet ? 10 : 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < estepes.length; i++) ...[
                if (i > 0) SizedBox(width: slotGap),
                PneuTile(
                  pneu: estepes[i],
                  isTablet: isTablet,
                  onTap: onPneuTap,
                  onDoubleTap: onPneuDoubleTap,
                  onEmptyDoubleTap: estepes[i] == null
                      ? () => onSlotVazioDoubleTap?.call('X${i + 1}')
                      : null,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Slot de posição de pneu vazia: cápsula com borda tracejada.
class EmptyTirePainter extends CustomPainter {
  const EmptyTirePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final rrect = RRect.fromLTRBR(0, 0, w, h, const Radius.circular(24));

    canvas.drawRRect(rrect, Paint()..color = AppColors.textHint);

    final paint = Paint()
      ..color = const Color(0xFF5F5F5F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()..addRRect(rrect);

    const dashLength = 6.0;
    const gapLength = 6.0;
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
class TirePainter extends CustomPainter {
  const TirePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final radius = w / 2;

    final outerRRect =
        RRect.fromLTRBR(0, 0, w, h, Radius.circular(radius));

    // ── 1. Borracha externa (base da cápsula) ──────────────────────
    canvas.drawRRect(outerRRect, Paint()..color = const Color(0xFF363636));

    // ── 2. Ombros (shoulders) — faixas laterais ligeiramente mais claras
    final shoulderW = w * 0.16;
    final shoulderPaint = Paint()..color = const Color(0xFF444444);
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
      Paint()..color = const Color(0xFF363636),
    );

    // ── 4. Sulcos longitudinais principais (2 canais de drenagem) ──
    final groove1X = w * 0.37;
    final groove2X = w * 0.63;
    final groovePaint = Paint()
      ..color = const Color(0xFF1A1A1A)
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
      ..color = const Color(0xFF222222)
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
      ..color = const Color(0xFF262626)
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
        ..color = const Color(0xFF515151)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
