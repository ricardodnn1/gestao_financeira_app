# gestao_financeira

A new Flutter project.

## Getting Started

Arquitetura inicial:
```
lib/
├── core/
│   ├── di/
│   │   ├── app_container.dart
│   │   └── module.dart
│   ├── routing/
│   │   ├── app_router.dart
│   │   └── app_routes.dart
│   ├── network/
│   ├── errors/
│   ├── theme/
│   └── utils/
│
├── modules/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   ├── auth_module.dart
│   │   └── auth_routes.dart
│   │
│   ├── home/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   ├── home_module.dart
│   │   └── home_routes.dart
│   │
│   └── profile/
│       ├── data/
│       ├── domain/
│       ├── presentation/
│       ├── profile_module.dart
│       └── profile_routes.dart
│
└── main.dart
```

## Retorno da API 

```
{
  "bitcoin": {
    "usd": 78532
  }
}
```