# Meu App Estudos

Aplicativo web pessoal para organizar estudos, acompanhar desempenho e acessar áreas complementares.

## Abrir o aplicativo

- **Versão publicada:** https://doiserrer1895-dotcom.github.io/meu-app-estudos/
- **Repositório:** https://github.com/doiserrer1895-dotcom/meu-app-estudos

## Mapa rápido dos arquivos

| Caminho | O que faz |
|---|---|
| `index.html` | Tela principal: estudos, disciplinas, cronograma, registros, desempenho, temporizador, conta e sincronização com a nuvem. |
| `nutricao.html` | Área de Nutrição. |
| `constancia.html` | Área de Constância: missões, habilidades, atributos, evolução, calendário e perfil. |
| `comunidade.html` | Comunidade: perfil, ranking, amizades, notificações e comparativos. |
| `service-worker.js` | Cache e funcionamento offline/PWA. |
| `manifest.webmanifest` | Nome, ícone e configurações de instalação do aplicativo. |
| `supabase-comunidade.sql` | Estrutura e permissões do banco usadas pela Comunidade. |
| `corrigir-permissoes-comunidade.sql` | Correção pontual das políticas de leitura/gravação dos totais diários. |
| `supabase-seguranca.sql` | Políticas e cópias de segurança privadas dos dados de estudo. |
| `assets/` | Imagens e recursos visuais usados pelas telas. |
| `icons/` | Ícones do aplicativo instalado. |
| `backups/` | Cópias antigas de arquivos principais preservadas no próprio repositório. |
| `.github/backups/` | Cópias adicionais históricas, separadas dos arquivos publicados. |
| `.github/` | Configurações e automações do GitHub, incluindo publicação do site. |
| `docs/` | Guias de manutenção, estrutura, segurança e relatórios técnicos. |

## Regras para não perder o aplicativo

1. Não apagar nem renomear os arquivos HTML da raiz sem atualizar todos os links e o cache do PWA.
2. Não mover `index.html`, `nutricao.html`, `constancia.html` ou `comunidade.html` para subpastas: os caminhos atuais são usados pela navegação e pelo Service Worker.
3. Antes de uma alteração grande, criar uma branch de backup a partir do commit atual da `main`.
4. Não substituir arquivos inteiros sem comparar a versão atual e preservar as funcionalidades existentes.
5. Nunca publicar chave `service_role`, senha ou segredo administrativo. A chave publishable do Supabase pode ficar no cliente; as permissões reais devem ser garantidas por RLS.
6. Depois de cada publicação, conferir o resultado do GitHub Pages e testar login, gravação, recarga e navegação no celular.

## Backups importantes

- `backup-versao-2.0-2026-11-11`: versão 2.0 preservada.
- `backup-versao-2.1-2026-11-12`: backup anterior da versão 2.1.
- `backup-checkup-2026-11-12`: fotografia integral da `main` antes da organização e documentação deste check-up.

## Documentação complementar

Consulte [docs/README-ESTRUTURA.md](docs/README-ESTRUTURA.md) para entender cada área e [docs/CHECKUP-2026-11-12.md](docs/CHECKUP-2026-11-12.md) para ver o estado, os riscos e os testes pendentes.
