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

---

## Лаба 6

### Дизайн система

Реализована полноценная модульная дизайн-система для всего приложения.

### Структура DS

```
translator/Presentation/DesignSystem/
├── DS.swift              # Токены Colors, Spacing, Typography, TextStyle
├── DSButton.swift        # Переиспользуемая кнопка
├── DSTextField.swift     # Валидируемое поле ввода с ошибкой
└── DSStateViews.swift    # Компоненты состояний экрана
```

### Токены дизайн системы

| Категория | Значения |
|---|---|
| Colors | background, secondaryBackground, primary, textPrimary, textSecondary, error, tint, separator |
| Spacing | xs(4), s(8), m(16), l(24), xl(32), cornerRadius(12) |
| Typography | title, headline, body, caption, error |
| TextStyle | Enum с методом `UILabel.apply(_ style: TextStyle)` |

Все цвета автоматически поддерживают Light/Dark режим системы.

### Реализованные компоненты DS

*   **DSButton**
    - Стили: primary / secondary
    - Автоматическое состояние disabled
    - Все отступы и скругления из токенов

*   **DSTextField**
    - Заголовок над полем
    - Ошибка под полем, автоматическое скрытие/показ
    - Полный прокси всех свойств UITextField

*   **DSLoadingView**
*   **DSErrorView** с кнопкой retry
*   **DSEmptyView**

### Применение на экранах

1.  Экран авторизации - все элементы полностью переделаны на DS компоненты
2.  Экран списка фич - добавлена полная поддержка состояний loading / error / empty через DS компоненты

Все хардкодные цвета, шрифты и отступы заменены на токены DS.

### Реализованные дополнительные задания

D1 — Автоматическая поддержка Light/Dark темы
D3 — TextStyle enum + расширение для UILabel
D4 — DSTextField с заголовком и поддержкой ошибок валидации
D5 — Унифицированные компоненты для состояний экрана

### Как проверить

1.  Запустить приложение → экран авторизации теперь полностью соответствует DS
2.  Авторизоваться → экран Features с фичами
3.  Отключить интернет → появится DSErrorView
4.  Проверить переключение системной темы → вся дизайн система автоматически подстраивается

---

## Лаба 7

### Допы

- Расширенная дизайн система

```Swift
enum BDUIViewType: String, Decodable {
    case contentView
    case containerView
    case stackView
    case label
    case button
    case textField
    case imageView
    case spacer
    case separator
    case scrollView
}

struct BDUILayout: Decodable {
    let spacing: DSSpacingToken?
    let axis: BDUIAxis?
    let alignment: BDUIAlignment?
    let distribution: BDUIDistribution?
    let contentInsets: BDUIEdgeInsets?
    let backgroundColor: DSColorToken?
    let cornerRadius: CGFloat?
    let fixedSize: BDUIFixedSize?
}

struct BDUIConstraints: Decodable {
    let pinToSuperview: Bool?
    let top: CGFloat?
    let left: CGFloat?
    let bottom: CGFloat?
    let right: CGFloat?
    let centerX: Bool?
    let centerY: Bool?
    let width: CGFloat?
    let height: CGFloat?
}
```

- Реализованы экшены

```Swift
struct BDUIAction: Decodable {
    let kind: String
    let destination: String?
    let targetId: String?
    let value: String?
    let message: String?

    private enum CodingKeys: String, CodingKey {
        case kind = "type"
        case destination
        case targetId
        case value
        case message
    }
}
```

### Как проверить

Экран Translate сделан с помощью BDUI (конфиг в TranslateBDUIConfiguration.swift). 
Кнопка ReloadUI перестраивает экран (по тому же json), History делает роутинг на историю, Print вызывает экшен для алерта с текстом из конфига