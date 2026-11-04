# Gestão Financeira

Aplicativo mobile em Flutter para controle financeiro pessoal, com dashboard de saldo, extrato, resumo por período e acompanhamento de movimentações.

## Visão geral

Este projeto foi desenvolvido para ajudar o usuário a acompanhar receitas, despesas, saldo disponível e evolução financeira ao longo do tempo. A aplicação combina uma interface simples e moderna com arquitetura modular, separando camadas de domínio, dados e apresentação.

## Funcionalidades

- Dashboard com saldo principal;
- Resumo financeiro por período;
- Listagem de transações recentes;
- Visualização de detalhes da transação;
- Alternância de visibilidade do saldo;
- Atualização manual de dados via refresh;
- Integração com API pública para consulta de preços/mercado;
- Cache local para melhorar desempenho e reduzir chamadas repetidas.

## Tecnologias utilizadas

- Flutter
- Dart
- Riverpod
- Go Router
- GetIt
- Shared Preferences
- HTTP
- Intl
- FlChart
- Equatable

## Estrutura do projeto

```text
gestao_financeira/
├── android/
├── ios/
├── lib/
│   ├── main.dart
│   └── src/
│       ├── app/
│       │   ├── app.dart
│       │   └── bootstrap.dart
│       ├── core/
│       │   ├── constants/
│       │   ├── errors/
│       │   ├── modules/
│       │   ├── network/
│       │   ├── routes/
│       │   ├── theme/
│       │   └── utils/
│       └── modules/
│           ├── dashboard/
│           ├── shared/
│           └── statement/
├── test/
├── analysis_options.yaml
├── pubspec.lock
├── pubspec.yaml
├── .gitignore
├── README.md
└── ...
```

## Arquitetura

O projeto foi organizado em módulos e camadas:

- `core`: configurações gerais, rotas, tema, rede e utilitários;
- `modules`: funcionalidades da aplicação, como dashboard e extrato;
- `shared`: entidades, casos de uso, repositórios e widgets reutilizáveis;
- `data`: fontes de dados locais e remotas.

## Requisitos

Antes de iniciar, certifique-se de ter os seguintes itens instalados:

- Flutter SDK 3.47.9 (stable) — versão disponível no ambiente de desenvolvimento;
- Dart SDK compatível com a restrição `^3.12.2` definida no `pubspec.yaml` (Dart 3.13.7 no ambiente de desenvolvimento);
- Android Studio ou VS Code com suporte ao Flutter
- Emulador ou dispositivo físico para a plataforma desejada.

O projeto não fixa uma versão específica do Flutter. Para conferir as versões instaladas e o estado das ferramentas:

```bash
flutter --version
flutter doctor
```

## Instalação

1. Clone o repositório:

```bash
git clone https://github.com/ricardodnn1/gestao_financeira_app.git
cd gestao_financeira
```

2. Instale as dependências:

```bash
flutter pub get
```

3. Verifique o ambiente:

```bash
flutter doctor
```

## Configuração de ambiente

O endereço da API pode ser configurado em tempo de compilação usando `--dart-define`. Se omitido, a aplicação usa `https://api.coingecko.com/api/v3`.

Para apontar para outro endereço, passe `API_BASE_URL` ao comando de execução ou build. Por exemplo:

```bash
flutter run --dart-define=API_BASE_URL=https://api.coingecko.com/api/v3
```

Não inclua chaves reais no README ou em outros arquivos versionados. O exemplo abaixo usa um placeholder; informe sua chave localmente se necessário. Atenção: na implementação atual, o app lê `API_BASE_URL`; `API_KEY` e `ENV` ainda não são consumidos pelo código.

## Como executar

Para rodar no emulador ou dispositivo conectado com os defines de ambiente:

```bash
flutter run --dart-define=API_KEY=YOUR_API_KEY_HERE --dart-define=ENV=prod
```

Para escolher um dispositivo ou sobrescrever o endereço da API:

```bash
flutter devices
flutter run -d <device-id> --dart-define=API_KEY=YOUR_API_KEY_HERE --dart-define=ENV=prod --dart-define=API_BASE_URL=https://api.coingecko.com/api/v3
```

## Testes

Execute a suíte completa de testes:

```bash
flutter test
```

## Gerar APK

Para gerar o APK de release:

```bash
flutter build apk --release
```

O arquivo será gerado em `build/app/outputs/flutter-apk/app-release.apk`. Para usar um endereço de API diferente do padrão, inclua `--dart-define` no comando:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.coingecko.com/api/v3
```

## Exemplo de resposta da API

A aplicação consome dados externos com estrutura semelhante a esta:

```json
{
  "bitcoin": {
    "usd": 78532
  }
}
```

## Observações

Este projeto está em andamento e sua estrutura foi pensada para escalar com novas funcionalidades, como:

- cadastro de transações;
- filtros avançados;
- gráficos detalhados;
- relatórios mensais;
- autenticação de usuário;
- integração com backend persistente.

## Contribuição

Contribuições são bem-vindas. Para colaborar:

1. Faça um fork do projeto;
2. Crie uma branch para a sua funcionalidade;
3. Faça o commit das alterações;
4. Abra um pull request com uma descrição clara do que foi feito.

## Licença

Este projeto ainda não possui uma licença definida no repositório. Caso seja necessário publicar ou distribuir o código em produção, é recomendável definir a licença adequada.

## Desenvolvedor

Ricardo D.N.N.
