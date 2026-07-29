# Domain Docs

Como as engineering skills devem consumir a documentação de domínio deste repo ao explorar o código.

## Before exploring, read these

- **`docs/documentacao-tecnica.md`** — arquitetura, API, modelos, telas, testes, plataformas e dívidas conhecidas.
- **`docs/documentacao-produto.md`** — visão de produto, conceitos do domínio, funcionalidades, fluxos e regras de negócio.

Este repo **não** usa `CONTEXT.md`, `CONTEXT-MAP.md` nem `docs/adr/` — o `CLAUDE.md` proíbe explicitamente ADRs e estruturas de doc extras (um vault Obsidian anterior, com wikilinks/frontmatter/dev logs/tasks, foi deliberadamente removido). A documentação de domínio vive só nos dois arquivos canônicos acima.

## File structure

Repo single-context:

```
/
├── docs/
│   ├── documentacao-tecnica.md
│   └── documentacao-produto.md
└── lib/
```

## Use the glossary's vocabulary

Quando seu output nomear um conceito de domínio (título de issue, proposta de refactor, hipótese, nome de teste), use o termo como definido em `docs/documentacao-produto.md` (conceitos de domínio) ou `docs/documentacao-tecnica.md` (arquitetura/API). Não escorregue para sinônimos que esses docs evitam.

Se o conceito que você precisa ainda não está documentado, isso é um sinal — ou você está inventando um termo que o projeto não usa (reconsidere), ou há uma lacuna real, que deve ser adicionada ao doc canônico correspondente na mesma mudança de código (regra já existente no `CLAUDE.md`).

## Flag conflicts

Se seu output contradisser algum dos dois docs canônicos, sinalize isso explicitamente em vez de sobrepor silenciosamente.

## No ADRs, no CONTEXT.md

Não crie `CONTEXT.md`, `CONTEXT-MAP.md` ou `docs/adr/` neste repo, mesmo que o comportamento padrão de outra skill sugira isso. As necessidades de domain-modeling deste projeto são atendidas inteiramente pelos dois docs canônicos acima.
