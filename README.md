# Transtalor

## Архитектура

**Выбрана:** MVVM + Coordinator + Clean Architecture

**Обоснование:**
- Чёткое разделение ответственности между слоями (Presentation, Domain, Data)
- Высокая тестируемость благодаря протоколам и внедрению зависимостей
- UIKit изолирован в Presentation слое
- Навигация вынесена в Coordinator, освобождая ViewController от этой задачи
- Domain слой не зависит от внешних фреймворков
- Легко масштабировать и поддерживать

---

## Модули

| Модуль | Ответственность |
|--------|------------------|
| **Auth** | Авторизация пользователя и восстановление сессии |
| **Features** | Отображение списка доступных функций переводчика |
| **Translate** | Перевод текста, управление историей и избранным |

---

## Экраны

### Auth

**Вход:**  
**Выход:** `onAuthorized(UserSession)`

**Сценарии:**
- Ввод email/password → успех → переход к списку фич
- Ошибка авторизации → отображение ошибки
- Восстановление сессии при запуске

---

### Features

**Вход:** `UserSession`  
**Выход:** `openFeature(FeatureType)`

**Сценарии:**
- Загрузка списка доступных фич
- Обработка offline-доступности
- Выбор фичи → переход к Translate

---

### Translate

**Вход:** `UserSession`, `FeatureType`  
**Выход:** `close`

**Сценарии:**
- Ввод текста → перевод → отображение результата
- Offline перевод при отсутствии сети
- Сохранение перевода в историю
- Отмена async задач при уходе в background

---

## Ключевые протоколы и модели

![Protocols and models](images/components.png)

## Диаграмма зависимостей модулей

![Dependency](images/dependency.jpg)

---

## Лаба 4

### API

**World Bank**

**Endpoint:** `GET https://api.worldbank.org/v2/country?format=json&per_page=300`

### Поля в FeatureCellViewModel

| Поле | Источник | Описание |
|------|----------|----------|
| `id` | `iso2Code` | Код страны ("US", "RU") |
| `title` | `name` | Название страны |
| `subtitle` | `region.value` | Регион ("Europe & Central Asia") |
| `rightText` | `isAvailableOffline` | "Offline" если из кэша |
| `imageURL` | `flagcdn.com` | URL флага по коду страны |

### Реализованные доп баллы

- **D1** — `NetworkError` с маппингом в читаемые сообщения
- **D2** — отмена предыдущего `Task` при повторном вызове `retry()`
- **D3** — локальный fallback через `languages.json` в Bundle (флаг `useLocalFallback`)
- **D5** — in-memory кэш в `DefaultFeaturesRepository`

---

## Лаба 5

### Подход к списку

**Выбран:** `UITableView` + `UITableViewDiffableDataSource`

**Обоснование:**
- `UITableView` — стандартный и оптимальный выбор для вертикальных списков в UIKit
- `UITableViewDiffableDataSource` обеспечивает анимированные и безопасные обновления без ручного управления `reloadRows`
- `FeaturesListManager` / `AvailableLanguagesListManager` инкапсулируют всю логику работы со списком
- Кастомные ячейки с корректным `prepareForReuse` для сброса асинхронных операций

### Структура экранов

```
Features (главное меню)
├── Translate → Translate screen
├── Available Languages → AvailableLanguages screen (список стран ~217)
│   └── тап на страну → Translate screen с языком
├── History → Stub screen
├── Favorites → Stub screen
└── Settings → Stub screen
```

### Как открыть экран списка

После авторизации открывается Features (главное меню). Тап на "Available Languages" → экран со списком стран.

### Состояния экрана Available Languages

| Состояние | Как увидеть |
|-----------|-------------|
| **Loading** | При запуске экрана (индикатор по центру) |
| **Content** | После загрузки (~217 стран с флагами) |
| **Empty** | API вернул пусто или поиск не дал результатов |
| **Error** | Нет интернета / ошибка сервера (кнопка Retry) |

### Что происходит по tap

- **Features:** тап на фичу → навигация к соответствующему экрану
- **Available Languages:** тап на страну → Translate screen с выбранным языком

### Реализованные дополнительные задания

- **D1 (Pull-to-refresh)** — `UIRefreshControl` на Available Languages
- **D2 (Поиск по списку)** — `UISearchBar` с клиентской фильтрацией
- **D3 (Картинки + кеширование + корректный reuse)** — `ImageLoader` + `NSCache` + отмена в `prepareForReuse`
- **D4 (Diffable Data Source)** — `UITableViewDiffableDataSource` через ListManager

### Как проверить

1. Авторизоваться → Features screen (Translate, Languages, History, Favorites, Settings)
2. Тап на "Available Languages" → список стран с флагами
3. Потянуть вниз для refresh
4. Ввести текст в searchBar для фильтрации
5. Тап на страну → Translate screen
6. Отключить интернет → error с кнопкой Retry
