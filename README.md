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

- Flutter SDK
- Dart SDK
- Android Studio ou VS Code com suporte ao Flutter
- Emulador Android/iOS ou dispositivo físico

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

## Como executar

Para rodar o aplicativo em um emulador ou dispositivo conectado:

```bash
flutter run --dart-define=API_KEY=YOUR_API_KEY_HERE --dart-define=ENV=prod
```

Se quiser rodar em um dispositivo específico:

```bash
flutter devices
flutter run -d <device-id> --dart-define=API_KEY=YOUR_API_KEY_HERE --dart-define=ENV=prod
```

## Testes

Para executar a suíte de testes:

```bash
flutter test
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
