# Guia da estrutura do Meu App Estudos

Este documento explica onde cada parte do aplicativo fica e onde procurar antes de fazer uma alteração.

## 1. Telas principais

### `index.html` — Aplicativo principal
É a entrada do projeto. Contém a interface de estudos e o código que organiza disciplinas, assuntos, cronograma, sessões, desempenho e temporizador. Também contém o fluxo de autenticação e sincronização dos dados da conta com o Supabase.

**Atenção:** é um arquivo grande e concentra muitas funções. Antes de editar, procure o nome da função e entenda quem chama essa função e quais dados ela altera.

### `nutricao.html` — Nutrição
Área dedicada à parte de Nutrição. É um arquivo muito grande; alterações devem ser pequenas, isoladas e testadas em celular e desktop.

### `constancia.html` — Constância
Área de missões, habilidades, atributos, evolução, calendário, perfil e patentes. No estado inspecionado neste check-up, salva os dados principais em `localStorage`, na chave `constancia-v1`.

### `comunidade.html` — Comunidade
Área de perfil comunitário, ranking, amizades, notificações, sessões e comparativos. Usa Supabase para autenticar e sincronizar dados comunitários. A função `communityConstancia()` ainda lê a chave local `constancia-v1`; portanto, os dados de Constância não são automaticamente portados entre dispositivos por essa função.

## 2. Recursos de interface e instalação

### `assets/`
Imagens, ilustrações e arquivos visuais. Mantenha nomes descritivos e caminhos relativos compatíveis com as páginas.

### `icons/`
Ícones usados pelo aplicativo e pelo manifesto de instalação.

### `manifest.webmanifest`
Define nome, nome curto, ícone, endereço inicial, escopo e modo de exibição do PWA.

### `service-worker.js`
Define os arquivos essenciais em cache, atualiza o cache quando o identificador de versão muda e fornece fallback offline para navegações. Quando um novo arquivo essencial for adicionado, avaliar se ele precisa entrar na lista `SHELL`.

## 3. Banco de dados e segurança

### `supabase-comunidade.sql`
Cria as tabelas, funções, índices, políticas RLS e permissões usadas pela Comunidade. O arquivo também contém as políticas necessárias para os totais diários.

### `supabase-constancia.sql`
Cria a tabela privada `constancia_data`, com leitura e gravação limitadas à conta autenticada. É uma migração nova necessária para sincronizar a Constância entre dispositivos.

### `corrigir-permissoes-comunidade.sql`
Bloco curto para corrigir as permissões de totais diários em bancos que já receberam uma versão anterior do SQL.

### `supabase-seguranca.sql`
Configura proteção e cópias de segurança dos dados privados de estudo. As tabelas privadas devem continuar limitadas ao próprio usuário autenticado.

**Regra:** nunca colocar segredo administrativo no JavaScript do navegador. O acesso público deve usar apenas chave publishable e políticas RLS corretamente configuradas.

## 4. Backups

- `backups/`: versões anteriores de arquivos da aplicação.
- `.github/backups/`: cópias históricas adicionais.
- Branches `backup-*`: fotografias completas do repositório em um commit específico.

Uma branch de backup não é uma cópia do banco Supabase. Para proteger os dados dos usuários, manter também backups próprios do banco e exportações privadas.

## 5. Publicação

O projeto é publicado pelo GitHub Pages a partir da branch `main`. Um commit na `main` pode iniciar uma nova execução de publicação. Acompanhe a execução mais recente em:

https://github.com/doiserrer1895-dotcom/meu-app-estudos/actions

Só considerar a publicação concluída quando o workflow terminar com `success`. Depois, abrir o aplicativo e fazer testes reais.

## 6. Comentários no código

Foram adicionados comentários explicativos antes dos blocos principais de:
- estado e lógica da tela principal;
- autenticação e sincronização em nuvem;
- inicialização e integração da Comunidade;
- leitura local dos dados de Constância;
- cache e ciclo de vida do Service Worker.

Ao criar uma nova função importante, comentar brevemente:
1. o que ela faz;
2. quais dados lê;
3. quais dados altera ou salva;
4. se depende de internet, login ou armazenamento local.


## 7. Registros manuais e comparação por horário

Na tela principal, o formulário **Registrar estudo** aceita um horário de início opcional. As horas e questões contam mesmo quando o campo fica vazio. Somente registros com horário informado entram nas estatísticas de faixa horária. O sistema não cria horários estimados para registros antigos ou manuais sem horário.

## 8. Migração da Constância

A página `constancia.html` usa a sessão autenticada do Supabase e a tabela `constancia_data`. O estado é salvo localmente em uma chave vinculada ao ID da conta e sincronizado na nuvem. Na primeira entrada, se houver dados antigos sem vínculo de conta, a aplicação pede confirmação antes de mesclar/importar. A cópia antiga não é apagada.

**Ativação:** executar [supabase-constancia.sql](../supabase-constancia.sql) uma vez no SQL Editor do Supabase. Sem essa migração, a tela mantém os dados locais, mas a sincronização na nuvem fica pendente.
