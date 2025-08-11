# Task Management API

Микросервис для управления задачами на Flask с PostgreSQL, мониторингом и CI/CD.

##  Функциональность

- **CRUD операции** для управления задачами
- **REST API** с JSON-ответами
- **База данных PostgreSQL** для хранения данных
- **Мониторинг** с Prometheus и Grafana
- **Контейнеризация** с Docker
- **CI/CD** с GitHub Actions
- **Infrastructure as Code** с Terraform

##  API Endpoints

| Метод | Endpoint | Описание |
|-------|----------|----------|
| GET | `/tasks` | Получить все задачи |
| POST | `/tasks` | Создать новую задачу |
| GET | `/tasks/<id>` | Получить задачу по ID |
| DELETE | `/tasks/<id>` | Удалить задачу |

### Примеры запросов

**Создание задачи:**
```bash
curl -X POST http://localhost:5000/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Новая задача", "description": "Описание задачи"}'
```

**Получение всех задач:**
```bash
curl http://localhost:5000/tasks
```

##  Технологический стек

- **Backend:** Flask (Python)
- **База данных:** PostgreSQL 16
- **Мониторинг:** Prometheus + Grafana
- **Контейнеризация:** Docker & Docker Compose
- **CI/CD:** GitHub Actions
- **Infrastructure:** Terraform
- **Cloud:** Yandex Cloud

##  Структура проекта

```
.
├── app/                    # Основное приложение
│   ├── models/            # Модели данных
│   │   └── task.py        # Модель задачи
│   ├── tests/             # Тесты
│   │   ├── test_unit_task.py
│   │   └── test_integration_tasks.py
│   ├── app.py             # Главный файл приложения
│   ├── requirements.txt   # Зависимости Python
│   └── dockerfile         # Docker образ
├── monitoring/            # Конфигурация мониторинга
│   └── prometheus.yml     # Настройки Prometheus
├── terraform/             # Infrastructure as Code
│   ├── main.tf           # Основная конфигурация
│   └── default.tf        # Дополнительные ресурсы
├── .github/workflows/     # CI/CD пайплайны
│   └── ci.yml            # GitHub Actions workflow
├── docker-compose.yml     # Локальная разработка
└── docker-compose.staging.yml  # Staging среда
```

##  Быстрый старт

### Предварительные требования
- Docker и Docker Compose
- Python 3.13+ (для локальной разработки)
- Git

### Запуск с Docker Compose

1. Клонируйте репозиторий:
```bash
git clone <repository-url>
cd <project-name>
```

2. Запустите все сервисы:
```bash
docker-compose up -d
```

3. Проверьте доступность сервисов:
- **API:** http://localhost:5000
- **Grafana:** http://localhost:3000 (admin/admin)
- **Prometheus:** http://localhost:9090
- **PostgreSQL:** localhost:5432

### Локальная разработка

1. Установите зависимости:
```bash
cd app
pip install -r requirements.txt
```

2. Запустите PostgreSQL:
```bash
docker-compose up postgres -d
```

3. Запустите приложение:
```bash
python app.py
```

##  Тестирование

Проект включает unit и integration тесты:

```bash
cd app
python -m pytest tests/ -v
```

### Типы тестов:
- **Unit тесты:** `test_unit_task.py` - тестирование модели задач
- **Integration тесты:** `test_integration_tasks.py` - тестирование API endpoints

##  Мониторинг

### Prometheus
- URL: http://localhost:9090
- Метрики приложения и инфраструктуры
- Конфигурация: `monitoring/prometheus.yml`

### Grafana
- URL: http://localhost:3000
- Логин: admin / admin
- Дашборды для визуализации метрик

##  Деплой

### CI/CD с GitHub Actions
Автоматический пайплайн включает:
- Запуск тестов
- Сборку Docker образов
- Деплой в staging/production

### Infrastructure с Terraform
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

##  Конфигурация

### Переменные окружения
- `PORT` - порт приложения (по умолчанию: 5000)
- `DATABASE_URL` - строка подключения к БД
- `FLASK_ENV` - окружение Flask (development/production)

### Docker Compose профили
- `docker-compose.yml` - локальная разработка
- `docker-compose.staging.yml` - staging окружение

##  Логи и отладка

Просмотр логов сервисов:
```bash
docker-compose logs -f service-app
docker-compose logs -f postgres
```

##  Участие в разработке

1. Форкните репозиторий
2. Создайте feature ветку (`git checkout -b feature/amazing-feature`)
3. Зафиксируйте изменения (`git commit -m 'Add amazing feature'`)
4. Запушьте в ветку (`git push origin feature/amazing-feature`)
5. Откройте Pull Request

##  Лицензия

Этот проект распространяется под лицензией MIT. См. файл `LICENSE` для подробностей.

##  Поддержка

Если у вас возникли вопросы или проблемы:
- Создайте Issue в GitHub
- Проверьте логи контейнеров
- Убедитесь, что все сервисы запущены корректно