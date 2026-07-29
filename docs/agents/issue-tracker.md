# Issue tracker: GitHub

Issues e PRDs deste repo vivem como GitHub issues. Use a CLI `gh` para todas as operações.

## Conventions

- **Create an issue**: `gh issue create --title "..." --body "..."`. Use um heredoc para bodies multi-linha.
- **Read an issue**: `gh issue view <number> --comments`, filtrando comments por `jq` e também buscando labels.
- **List issues**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'` com filtros `--label` e `--state` apropriados.
- **Comment on an issue**: `gh issue comment <number> --body "..."`
- **Apply / remove labels**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Close**: `gh issue close <number> --comment "..."`

Infira o repo a partir de `git remote -v` — `gh` faz isso automaticamente dentro de um clone (`MateusKasuya/flutter_mobile_dev`).

## Pull requests as a triage surface

**PRs as a request surface: no.** _(Mude para `yes` se este repo tratar PRs externos como feature requests; `/triage` lê essa flag.)_

Quando `yes`, PRs passam pelos mesmos labels e estados que issues, usando os equivalentes `gh pr`:

- **Read a PR**: `gh pr view <number> --comments` e `gh pr diff <number>` para o diff.
- **List external PRs for triage**: `gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments` mantendo apenas `authorAssociation` de `CONTRIBUTOR`, `FIRST_TIME_CONTRIBUTOR` ou `NONE` (descartar `OWNER`/`MEMBER`/`COLLABORATOR`).
- **Comment / label / close**: `gh pr comment`, `gh pr edit --add-label`/`--remove-label`, `gh pr close`.

GitHub compartilha um único espaço de números entre issues e PRs, então um `#42` isolado pode ser qualquer um dos dois — resolva com `gh pr view 42` e caia para `gh issue view 42` se falhar.

## When a skill says "publish to the issue tracker"

Crie uma GitHub issue.

## When a skill says "fetch the relevant ticket"

Rode `gh issue view <number> --comments`.

## Wayfinding operations

Usado por `/wayfinder`. O **map** é uma única issue com issues **child** como tickets.

- **Map**: uma issue única com label `wayfinder:map`, contendo o body de Notes / Decisions-so-far / Fog. `gh issue create --label wayfinder:map`.
- **Child ticket**: uma issue linkada ao map como GitHub sub-issue (`gh api` no endpoint de sub-issues). Onde sub-issues não estão habilitadas, adicione o child a uma task list no body do map e coloque `Part of #<map>` no topo do body do child. Labels: `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Uma vez reivindicado, o ticket é atribuído ao dev responsável.
- **Blocking**: as **native issue dependencies** do GitHub — a representação canônica, visível na UI. Adicione uma edge com `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`, onde `<blocker-db-id>` é o **database id** numérico do blocker (`gh api repos/<owner>/<repo>/issues/<n> --jq .id`, _não_ o `#number` nem o `node_id`). GitHub reporta `issue_dependencies_summary.blocked_by` (apenas blockers abertos — o gate ao vivo). Onde dependencies não estão disponíveis, caia para uma linha `Blocked by: #<n>, #<n>` no topo do body do child. Um ticket é desbloqueado quando todo blocker está fechado.
- **Frontier query**: liste os children abertos do map (`gh issue list --state open`, restrito às sub-issues / task list do map), descarte qualquer um com blocker aberto (`issue_dependencies_summary.blocked_by > 0`, ou uma issue aberta na linha `Blocked by`) ou com assignee; o primeiro na ordem do map vence.
- **Claim**: `gh issue edit <n> --add-assignee @me` — a primeira escrita da sessão.
- **Resolve**: `gh issue comment <n> --body "<answer>"`, depois `gh issue close <n>`, depois anexe um ponteiro de contexto (gist + link) ao Decisions-so-far do map.
