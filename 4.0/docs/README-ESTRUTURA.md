# Guia da estrutura do Meu App Estudos

## Páginas do aplicativo

As páginas HTML principais permanecem na raiz do repositório para preservar os endereços usados pelo GitHub Pages, pela navegação e pelo Service Worker.

- `index.html`: entrada do app.
- `dashboard-inicio.html`: painel inicial.
- `estudos-area.html`: Estudos e Foco.
- `nutricao.html`: Nutrição.
- `constancia.html`: Constância.
- `comunidade.html`: Comunidade e comparativos.
- `questoes.html`: carregador do Banco de Questões.

## Pastas

- `assets/`: imagens e recursos visuais.
- `assets/banco-questoes/`: imagens auxiliares e arquivo `bt_questoes.json`.
- `banco-questoes/`: nove partes GZIP do Banco de Questões, manifesto, instruções e somas de verificação. Não renomear nem recomprimir os arquivos GZIP.
- `database/`: scripts SQL do Supabase.
- `docs/`: manuais e relatórios técnicos.
- `ferramentas/`: páginas auxiliares de diagnóstico.
- `icons/`: ícones do PWA.
- `backups/` e `.github/backups/`: cópias históricas.
- `.github/`: automações e configurações do repositório.

## Banco de dados e segurança

Os scripts de criação, políticas e correções do Supabase ficam em `database/`. Nunca colocar senha, chave `service_role` ou segredo administrativo no código publicado. As permissões dos dados devem continuar protegidas por RLS.

## Publicação

O GitHub Pages publica a partir da raiz da branch `main`. Não mover os arquivos de entrada nem o `service-worker.js` sem revisar todos os caminhos. Acompanhe as execuções em https://github.com/doiserrer1895-dotcom/meu-app-estudos/actions e só considere a publicação concluída quando terminar com sucesso.

## Regra para alterações

Antes de mudar uma função importante, identificar o que ela lê, o que altera e onde salva os dados. Fazer mudanças pequenas e preservar uma branch de backup.
