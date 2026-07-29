import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Dados visuais (ícone/cor/label) usados pelos diálogos e formulários de
/// movimentação para desenhar a origem/destino de um pneu.
///
/// [PneuAcao] implementa esta interface para as 5 localizações reais da API.
/// [EstepeOrigem] e [EixoDestino] a implementam para casos que NÃO são
/// localização real — o estepe (`X1`/`X2`) já montado no veículo, de onde um
/// pneu pode sair (origem), e a posição de eixo do mesmo veículo pra onde ele
/// pode ir (destino) — permitindo reusar o mesmo componente visual sem que o
/// `label` dessas origens/destinos seja enviado como localização válida à API
/// (ver `localizacaoOrigemOverride` no formulário de entrada).
abstract interface class OrigemVisual {
  String get label;
  IconData get icon;
  Color get color;
  Color? get bgColor;
  Color? get borderColor;
  String? get asset;
  bool get mirrorX;
}

/// Ações que podem ser executadas ao arrastar um pneu para uma zona.
enum PneuAcao implements OrigemVisual {
  estoque(
    'Estoque',
    Icons.inventory_2,
    Color(0xFF1976D2),
    bgColor: Color(0xFFDDEBFF),
    borderColor: Color(0xFF2371DE),
    asset: 'assets/estoque.svg',
  ),
  conserto(
    'Conserto',
    Icons.build,
    Color(0xFFF57C00),
    bgColor: Color(0xFFFFE6CB),
    borderColor: Color(0xFFFF8126),
    asset: 'assets/conserto.svg',
    mirrorX: true,
  ),
  recapagem(
    'Recapagem',
    Icons.autorenew,
    Color(0xFF388E3C),
    bgColor: Color(0xFFF0EEFF),
    borderColor: Color(0xFF7D00DE),
    asset: 'assets/recapagem.svg',
  ),
  sucata(
    'Sucata',
    Icons.delete_outline,
    Color(0xFFD32F2F),
    bgColor: Color(0xFFFFE2E2),
    borderColor: Color(0xFFF03E26),
    asset: 'assets/sucata.svg',
  ),
  venda(
    'Venda',
    Icons.attach_money,
    Color(0xFF7B1FA2),
    bgColor: Color(0xFFE2FBC3),
    borderColor: Color(0xFF00AF3E),
    asset: 'assets/venda.svg',
  );

  @override
  final String label;
  @override
  final IconData icon;
  @override
  final Color color;
  @override
  final Color? bgColor;
  @override
  final Color? borderColor;
  @override
  final String? asset;
  @override
  final bool mirrorX;

  const PneuAcao(
    this.label,
    this.icon,
    this.color, {
    this.bgColor,
    this.borderColor,
    this.asset,
    this.mirrorX = false,
  });
}

/// Origem visual do pneu estepe (`X1`/`X2`) já montado no veículo, para a
/// ação de movê-lo para uma posição de eixo do mesmo veículo.
///
/// Não é um [PneuAcao] porque "estepe" não é uma localização real da API — é
/// só a posição do pneu dentro de `FROTA` (ver `docs/documentacao-tecnica.md`).
/// O payload enviado ao mover usa `localizacaoOrigemOverride: 'FROTA'`, não
/// o [label] abaixo, que é só para exibição.
class EstepeOrigem implements OrigemVisual {
  const EstepeOrigem();

  @override
  String get label => 'Estepe';

  @override
  IconData get icon => Icons.album_outlined;

  @override
  Color get color => AppColors.primary;

  @override
  Color? get bgColor => const Color(0xFFDFF3F3);

  @override
  Color? get borderColor => AppColors.primaryBorder;

  @override
  String? get asset => 'assets/pneu-icon.svg';

  @override
  bool get mirrorX => false;
}

/// Visual do card "Eixo" no diálogo de ações de um pneu — oferecido só
/// quando o pneu é um estepe já montado (`X1`/`X2`), representando o destino
/// "mover para uma posição de eixo do mesmo veículo".
///
/// Não é um [PneuAcao] pelo mesmo motivo de [EstepeOrigem]: "eixo" aqui não é
/// uma localização real da API, é a categoria de destino mostrada no card —
/// a posição concreta (`1D`, `2EI`...) é escolhida depois, num diálogo à
/// parte.
class EixoDestino implements OrigemVisual {
  const EixoDestino();

  @override
  String get label => 'Eixo';

  @override
  IconData get icon => Icons.compare_arrows;

  @override
  Color get color => AppColors.primary;

  @override
  Color? get bgColor => const Color(0xFFDFF3F3);

  @override
  Color? get borderColor => AppColors.primaryBorder;

  @override
  String? get asset => null;

  @override
  bool get mirrorX => false;
}
