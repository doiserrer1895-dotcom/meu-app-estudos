# Recuperar o Meu App Estudos

## Pacote principal para guardar no computador

Baixe e guarde o ZIP completo da versão 3.0:

- [Baixar backup 3.0 — código completo + Banco de Questões](https://github.com/doiserrer1895-dotcom/meu-app-estudos/archive/refs/heads/backup-versao-3.0-banco-instantaneo-2026-11-15.zip)
- [Baixar versão 2.0 — reserva](https://github.com/doiserrer1895-dotcom/meu-app-estudos/archive/refs/heads/backup-versao-2.0-2026-11-11.zip)

O pacote 3.0 inclui os arquivos do aplicativo, imagens e recursos, os nove arquivos compactados do Banco de Questões, os scripts SQL e a documentação.

## Se o site sair do ar

1. Baixe o ZIP da versão 3.0 e extraia tudo no computador.
2. No GitHub, abra o repositório `doiserrer1895-dotcom/meu-app-estudos`.
3. Restaure os arquivos extraídos na raiz do repositório, mantendo as pastas e os nomes originais. Não envie o ZIP como um único arquivo.
4. Confira em **Settings → Pages** se a publicação continua configurada para a branch `main` e a raiz (`/ `).
5. Aguarde a ação **pages build and deployment** terminar com sucesso.
6. Abra https://doiserrer1895-dotcom.github.io/meu-app-estudos/ e teste login, navegação, Banco de Questões e gravação/sincronização.

Não renomeie nem separe `questoes-banco-01.gz` até `questoes-banco-09.gz`: os nove arquivos são partes do mesmo banco.

## Banco de dados e contas — importante

O ZIP do GitHub guarda o código e os arquivos do site, mas **não é uma cópia dos registros reais do Supabase nem das contas de login**.

O projeto Supabase usado pelo aplicativo é `MeuAppEstudos`. Para uma recuperação completa dos dados, mantenha também um backup do banco no painel do Supabase (Database → Backups / exportação do banco, conforme as opções disponíveis no plano). Os arquivos `.sql` deste repositório ajudam a reconstruir a estrutura e as políticas, mas não substituem uma exportação dos dados reais.

Nunca coloque senha, chave `service_role` ou segredo administrativo dentro do ZIP ou do repositório.

## Versões preservadas

- `backup-versao-3.0-banco-instantaneo-2026-11-15`: ponto de restauração da versão atual com a correção de carregamento persistente do Banco de Questões.
- `backup-versao-2.0-2026-11-11`: versão 2.0 mantida como reserva.
