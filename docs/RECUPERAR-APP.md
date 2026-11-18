# Recuperar o Meu App Estudos

## Pacotes de segurança

- [Baixar backup 3.0 — código completo + Banco de Questões](https://github.com/doiserrer1895-dotcom/meu-app-estudos/archive/refs/heads/backup-versao-3.0-banco-instantaneo-2026-11-15.zip)
- [Baixar versão 2.0 — reserva](https://github.com/doiserrer1895-dotcom/meu-app-estudos/archive/refs/heads/backup-versao-2.0-2026-11-11.zip)

## Se o site sair do ar

1. Baixe e extraia o ZIP completo.
2. Restaure os arquivos no repositório mantendo a estrutura de pastas.
3. As páginas HTML principais ficam na raiz; os pacotes do banco ficam em `banco-questoes/`, imagens auxiliares em `assets/banco-questoes/` e scripts SQL em `database/`.
4. Em Settings → Pages, confira a publicação pela branch `main` e raiz (`/`).
5. Aguarde o workflow **pages build and deployment** terminar com sucesso.
6. Abra o app e confira login, navegação, Banco de Questões e sincronização.

Não renomeie, separe ou recomprima `banco-questoes/questoes-banco-01.gz` até `banco-questoes/questoes-banco-09.gz`: são partes do mesmo arquivo.

## Banco de dados e contas

O ZIP do GitHub guarda código e arquivos do site, mas não é uma cópia dos registros reais do Supabase nem das contas. Mantenha também um backup do banco pelo painel do Supabase. Os scripts SQL em `database/` ajudam a reconstruir a estrutura e as políticas, mas não substituem uma exportação dos dados.

Nunca coloque senha, chave `service_role` ou segredo administrativo no repositório.

## Versões preservadas

- `backup-versao-3.0-banco-instantaneo-2026-11-15`: ponto de restauração com o Banco de Questões.
- `backup-versao-2.0-2026-11-11`: versão 2.0 mantida como reserva.
