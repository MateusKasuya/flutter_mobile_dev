# Documentação de Produto — Frota Fácil Mobile

Aplicativo móvel (Android e iOS) para **controle de pneus de frota**, do ecossistema Transporte Fácil (transportefacil.com.br). Este documento descreve o produto do ponto de vista de negócio: para quem é, o que faz, os fluxos de uso e as regras. Os detalhes de implementação estão na [documentação técnica](documentacao-tecnica.md).

## 1. Visão do produto

Pneus são um dos maiores custos operacionais de uma frota, e cada pneu passa por um ciclo longo: entra no estoque, é montado num veículo, roda, sai para conserto ou recapagem, volta, e no fim da vida é sucateado ou vendido. O Frota Fácil Mobile dá à equipe de frota uma forma de **consultar e registrar essas movimentações na hora e no local em que acontecem** — no pátio, pelo celular — em vez de depender de anotações para lançamento posterior.

O app é um cliente do sistema Transporte Fácil: os dados (veículos, pneus, localizações, fornecedores) vêm do servidor, e toda movimentação registrada no app é enviada para ele.

**Público-alvo:** equipes de frota de transportadoras que já usam o Transporte Fácil — gestor de frota, borracheiro, operador de pátio. O acesso usa o CPF e a senha do usuário já cadastrado no sistema.

## 2. Conceitos do domínio

| Conceito | Significado |
|---|---|
| **Localização** | Onde o pneu está: `ESTOQUE`, `FROTA` (montado num veículo), `CONSERTO`, `RECAPAGEM`, `SUCATA` ou `VENDA` |
| **Situação** | Estado do pneu: NOVO, USADO, RECAPADO ou SUCATA |
| **Movimentação** | Qualquer troca de localização de um pneu, incluindo montagem/desmontagem no veículo |
| **Recapagem** | Recuperação da banda de rodagem do pneu por um fornecedor especializado; estende a vida útil |
| **Vida do pneu** | Contador de ciclos do pneu (pneu novo → recapagens sucessivas) |
| **Sucateamento** | Fim de vida do pneu, sempre registrado com um **motivo** (lista mantida no sistema) |
| **Esquema de eixos** | Código que descreve o chassi do veículo (toco, truck, bitruck, carreta, moto...) — quantos eixos e se cada um tem rodado simples ou duplo |
| **Posição do pneu** | Eixo + lado + posição no rodado. Ex.: `2EI` = 2º eixo, lado esquerdo, pneu interno |
| **Placa** | Formatos aceitos: antigo (`ABC1234`) e Mercosul (`ABC1D23`) |

## 3. Funcionalidades

### 3.1 Acesso

- Login com **CPF e senha** do Transporte Fácil, com validação de CPF no próprio formulário.
- Opção **"Lembrar usuário e senha"**: preenche os campos automaticamente nas próximas aberturas (a senha fica guardada no cofre seguro do aparelho).
- A sessão permanece ativa entre aberturas do app. Quando expira no servidor, o app volta sozinho para a tela de login.

### 3.2 Painel (Home)

- Visão de **quantos pneus há em cada localização** (estoque, frota, conserto, recapagem, sucata, venda), em cards com ícones.
- Atualização puxando a lista para baixo (pull-to-refresh).
- Botão **"Adicionar Movimento"** leva ao menu de movimentações.

### 3.3 Menu Movimento

Três áreas: **Frotas** (movimentações a partir do veículo), **Pneus** (controle geral de pneus) e **Abastecimento** (previsto, ainda não disponível — ver §7).

### 3.4 Frotas — consulta por veículo

- Busca do veículo **pela placa**, digitada ou **fotografada**: o app lê a placa na foto (OCR), preenche o campo e já busca o veículo sozinho.
- Ficha do veículo: placa, nº de frota, marca, modelo, ano, cor e tipo.
- **Diagrama de eixos**: desenho do chassi do veículo com cada pneu na sua posição, respeitando o esquema de eixos (rodado simples/duplo, moto, carreta etc.). Posições vazias aparecem tracejadas.
  - **Toque** num pneu: detalhes (nº, posição, marca, modelo, dimensão, tipo, vida, quilometragens, última atualização).
  - **Toque duplo** num pneu: abre as ações de movimentação (desmontagem).
  - **Toque duplo** numa posição vazia: inicia a montagem de um pneu naquela posição.

### 3.5 Pneus — lista geral

- Lista dos pneus **que não estão montados em veículo** (estoque, conserto, recapagem, sucata, venda), com **busca** por nº do pneu, marca, modelo, placa, frota, série, situação, tipo ou localização.
- Pneu montado em veículo **não aparece nesta lista**: a movimentação dele é feita somente pela tela **Frotas** (§3.4), a partir do diagrama de eixos.
- Cada card mostra situação (com cor: NOVO verde, USADO laranja, RECAPADO roxo, SUCATA vermelho), marca/modelo, dimensão e a localização.
- Tocar num pneu abre as mesmas ações de movimentação.

### 3.6 Movimentações de pneu

Três tipos de operação, todos registrados no servidor na hora:

1. **Montagem** (estoque/conserto/recapagem → veículo): escolhe-se a posição no diagrama, a origem do pneu, o pneu na lista, a data e o KM do veículo.
2. **Desmontagem** (veículo → localização): informa-se data do retorno, KM de saída e observação; se o destino for sucata, o motivo.
3. **Entre localizações** (ex.: estoque → conserto, conserto → recapagem): campos variam conforme origem e destino — data, valor (quando há custo ou venda), motivo, fornecedor de recauchutagem, observação.

O app confirma cada operação com a mensagem retornada pelo sistema e impede fechar o formulário no meio do envio.

### 3.7 Leitura de placa por câmera (OCR)

- Na busca de veículo, o botão de câmera fotografa a placa; o reconhecimento roda **no próprio aparelho** (sem enviar a foto para o servidor).
- Reconhece placas nos formatos antigo e Mercosul e ignora textos ao redor (ex.: "BRASIL", nome do município).
- Reconhecida a placa, o app preenche o campo e **já busca o veículo automaticamente** — sem precisar tocar em "Buscar".
- Se nenhuma placa for reconhecida, o app avisa e o usuário pode digitar normalmente.

### 3.8 Experiência

- Interface em português (pt-BR), com layouts adaptados para **celular e tablet**.
- Mensagens de erro amigáveis (sem jargão técnico) para falhas de conexão, demora do servidor ou dados inválidos.
- Funciona nas redes da operação (requer conexão com o servidor Transporte Fácil); apenas a leitura de placa funciona offline.

## 4. Fluxos principais

**Entrar no app**
1. Abrir o app → tela de abertura → login (CPF + senha; "lembrar" opcional) → painel.

**Consultar os pneus de um veículo**
1. Painel → "Adicionar Movimento" → **Frotas**.
2. Digitar a placa ou fotografá-la → **Buscar**.
3. Ver a ficha do veículo e o diagrama; tocar num pneu para ver os detalhes.

**Enviar um pneu montado para recapagem**
1. Localizar o veículo (fluxo acima).
2. Toque duplo no pneu no diagrama → escolher **Recapagem**.
3. Preencher data do retorno, KM de saída e observação → confirmar.
4. O pneu sai do diagrama e passa a contar na localização Recapagem.

**Montar um pneu num veículo**
1. Localizar o veículo → toque duplo na **posição vazia**.
2. Escolher a origem (estoque, conserto ou recapagem) → escolher o pneu na lista.
3. Preencher data e KM do veículo → confirmar. O pneu aparece na posição.

**Movimentar um pneu que não está montado**
1. Painel → "Adicionar Movimento" → **Pneus** → buscar o pneu → tocar nele.
2. Escolher o destino permitido → preencher o formulário → confirmar.

## 5. Regras de negócio

### Transições permitidas

| De \ Para | Veículo | Estoque | Conserto | Recapagem | Sucata | Venda |
|---|:-:|:-:|:-:|:-:|:-:|:-:|
| **Veículo (montado)** | — | ✔ | ✔ | ✔ | ✔ | ✔ |
| **Estoque** | ✔ | — | ✔ | ✔ | ✔ | ✔ |
| **Conserto** | ✔ | ✔ | — | ✔ | ✔ | ✖ |
| **Recapagem** | ✔ | ✔ | ✔ | — | ✔ | ✖ |
| **Sucata** | ✖ | ✖ | ✖ | ✖ | — | ✔ |
| **Venda** | ✖ | ✖ | ✖ | ✖ | ✖ | — |

Em resumo: **venda é terminal**; **sucata só pode ser vendida**; pneu em conserto ou recapagem não vai direto para venda (precisa voltar antes). O app desabilita visualmente as opções proibidas e a localização atual.

As movimentações da linha **Veículo (montado)** — desmontagem e montagem — acontecem **somente pela tela Frotas** (diagrama de eixos); a lista geral de Pneus não exibe pneus montados.

### Campos e validações por movimentação

- **Sucateamento** exige um **motivo** escolhido da lista do sistema.
- **Valor em R$** é informado quando a movimentação tem custo (saída de conserto ou recapagem) ou receita (destino venda).
- **Conserto → recapagem** pede o **fornecedor de recauchutagem** (busca na lista de fornecedores).
- **Saída de recapagem** oferece a opção "proibido futura recauchutagem".
- **Datas**: a data de retorno não pode ser anterior à de envio.
- **Quilometragem**: o KM de saída não pode ser menor que o KM de entrada.

### Acesso e sessão

- Somente usuários cadastrados no Transporte Fácil (CPF + senha).
- Sessão expirada = volta automática ao login; nenhum dado de movimentação é enviado sem sessão válida.

## 6. Plataformas e requisitos

| Item | Detalhe |
|---|---|
| Plataformas | Android e iOS (iOS 15.6 ou superior) |
| Aparelhos | Celulares e tablets, retrato e paisagem |
| Idioma | Português (Brasil) |
| Conexão | Necessária para tudo, exceto a leitura de placa pela câmera |
| Câmera | Opcional — usada apenas para ler a placa; a busca por digitação funciona sem ela |
| Ambiente atual | O app aponta por padrão para o servidor de **homologação** |

## 7. Estado atual e próximos passos

- **Versão 0.1.0, em desenvolvimento**, validada contra o ambiente de homologação. Não publicado nas lojas.
- **Abastecimento**: já aparece no menu Movimento, mas ainda sem funcionalidade — registro de abastecimentos é a próxima área prevista do produto.
- Pendências conhecidas antes de produção:
  - Servidor com HTTPS (hoje a comunicação é HTTP; depende do backend).
  - Identidade de publicação do app (identificador Android definitivo, contas das lojas).
