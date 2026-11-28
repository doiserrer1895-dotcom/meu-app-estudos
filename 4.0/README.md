# Meu App Estudos

Aplicativo web pessoal para organizar estudos, acompanhar desempenho e acessar áreas complementares.

- **Aplicativo:** https://doiserrer1895-dotcom.github.io/meu-app-estudos/
- **Repositório:** https://github.com/doiserrer1895-dotcom/meu-app-estudos

## Mapa das pastas

| Local | O que tem |
|---|---|
| Arquivos HTML na raiz | Páginas principais. Ficam na raiz para preservar os endereços e o GitHub Pages. |
| `assets/` | Imagens e recursos visuais; imagens auxiliares do banco em `assets/banco-questoes/`. |
| `banco-questoes/` | Nove pacotes GZIP do banco, manifesto e instruções. |
| `database/` | Scripts SQL do Supabase. |
| `docs/` | Manuais, recuperação e relatórios técnicos. |
| `ferramentas/` | Ferramentas auxiliares de diagnóstico. |
| `icons/` | Ícones do aplicativo. |
| `backups/`, `.github/backups/` | Cópias históricas. |
| `.github/` | Configurações e automações do GitHub. |

## Páginas principais

- `index.html`: entrada do aplicativo.
- `dashboard-inicio.html`: painel inicial.
- `estudos-area.html`: Estudos e Foco.
- `nutricao.html`: Nutrição.
- `constancia.html`: Constância.
- `comunidade.html`: Comunidade e comparativos.
- `questoes.html`: carregador do Banco de Questões.
- `service-worker.js` e `manifest.webmanifest`: cache e instalação.

**Importante:** as páginas principais continuam na raiz porque os links atuais, o PWA e o GitHub Pages dependem desses caminhos. A organização foi feita nos materiais, scripts, documentação e ferramentas, sem deslocar as páginas usadas pelo app.

## Manutenção e segurança

1. Não mover nem renomear as páginas HTML da raiz sem revisar os links e o cache.
2. Não renomear, separar ou recomprimir os nove arquivos GZIP.
3. Preservar branches de backup antes de mudanças grandes.
4. Nunca publicar senha, chave `service_role` ou segredo administrativo.
5. Só considerar uma publicação concluída após o GitHub Pages terminar com sucesso e os fluxos principais serem verificados.

## Documentação

- [Guia da estrutura](docs/README-ESTRUTURA.md)
- [Como recuperar o aplicativo](docs/RECUPERAR-APP.md)
- [Relatório de check-up](docs/CHECKUP-2026-11-12.md)

Os scripts SQL ficam em `database/`. A versão 2.0 continua preservada na branch `backup-versao-2.0-2026-11-11`.
