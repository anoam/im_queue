# Problem

## ru
Разработать веб-сервис имитирующий отправку сообщений в мессенжеры (такие как [Telegram](https://telegram.org/), или [Viber](https://www.viber.com/))

**Сервис должен:**
- планировать отправку сообщений на заданное время;
- сообщать о невалидных параметрах (в т.ч. неизвестных мессендерах);
- учитывать возможность сбоев при работе с одним или несколькими параметрами;
- иметь возможность отправить одно сообщение нескольким получателям (в т.ч. в разные мессенджеры);
- иметь защиту от несанкционированного доступа.

Для разработки использовать `Ruby on Rails`.

Вместо библиотек, для работы с мессенжерами использовать заглушки. Интерфес этих библиотек разработать самому.

Требований к интерфейсу сервиса нет. Реализовать наиболее удобный.


## en

Create Web-service that simulates sending message to instant messengers (such as [Telegram](https://telegram.org/), or [Viber](https://www.viber.com/)).

**Service must:**
- to schedule message sending for a given time;
- to validate incoming parameters (including messengers);
- to consider the possibility of failures when working with one or more parameters;
- to be able to send one message to several recipients (including to different IMs);
- to have protection from unauthorized access.

Use `Ruby on Rails` as platform.

Use stubs as messengers immitation. Interfaces of stubs aren't specified.

No service interface requirements.


# How to run
## ru

1. Создайте `conf/redis.yml` (пример: `conf/redis.example.yml`). `connection_string` - url для подключения к `Redis`.
2. Создайте `conf/auth.yml` (пример: `conf/auth.example.yml`). `name` - логин, `password` - пароль для доступа к сервису.

В остальном:

Web-приложение запускается и работает как обычное Rails-приложение.

[Sidekiq](https://github.com/mperham/sidekiq) - как обычый сервер `Sidekiq`.

## en
1. Create `conf / redis.yml` (example:` conf / redis.example.yml`). `connection_string` is url to connect to` Redis`.
2. Create `conf / auth.yml` (example:` conf / auth.example.yml`). `name` is login,` password` is password for accessing the service.

After that, the Web app starts and runs as a normal Rails application. [Sidekiq](https://github.com/mperham/sidekiq) - as normal `Sidekiq` server.

# How to use
## ru

Сервис исполбзует базовую HTTP-авторизацию. Логин и пароль соответствуют указанным в `conf/auth.yml`.

У сервиса единственная точка входа: `/plan`. Принимает `POST`-запросы. Принимаются запросы как с `Content-Type: application/x-www-form-urlencoded`, так и с `Content-Type: application/json` 

Структура запроса:

```
message: "my_message"
send_at: "shedule_time"
receivers: array_of_receivers
```
Где:

`my_message` - текст сообщения.

`send_at` - строка с датой в фроматер [rfc3339](https://tools.ietf.org/html/rfc3339). Если время уже наступило - сообщение будет отправлено сразу.

`receivers` - массив получателей, каждый из которых содержит:

```
im: "messanger_name"
identifier: "user_identifier"
```

Где:
`messanger_name` - строка с названием мессенджера-получатея. Для тестов добавлены мессенджеры с названиями `im1` и `im2`.
`user_identifier` - строка с идентификатором пользовалея внутри мессенджера. Валидным является любое значение кроме пустой строки и `invalid_identifier`.

Все параметры обязательны. Необходим хотя бы один получатель.

**Пример запроса**:
```
POST /plain
Host: oneretarget.com
Content-Type: application/json

{
  "message": "Hello there!",
  "send_at": "2118-01-31 14:00:00+03:00",
  "receivers": [
    { "im": "im1", "identifier": "user1" },
    { "im": "im2", "identifier": "user2" },
  ]
}
```
Запланирует на 31.01.2018, 14:00 (МСК) отправку сообщения "Hello there!" пользователю мессенджера `im1` с идентификатором `user1` и пользователю мессенджера `im2` с идентификатором `user2`.

Сообщения вместо отправки будут выводиться в поток вывода Sidekiq'а.

В случае неудачной попытки (например в случае потери связи) будет добавлено сообщение в лог `log/sending_#{Rails.env}.log` и через некоторое время произойдёт повторная попытка.
Максимум - 25 попыток. [Подробности](https://github.com/mperham/sidekiq/wiki/Error-Handling#automatic-job-retry)

Чтобы съимитировать такую ситуацию нужно использовать отправить "unprocessable".
 
## en

The service uses basic HTTP authorization. Login and password will be taken from `conf / auth.yml`.

The service has the only entry point: `/ plan`. It accepts `POST`-requests.
Query with headers `Content-Type: application / x-www-form-urlencoded` and ` Content-Type: application / json` are allowed.

Request structure:

```
message: "my_message"
send_at: "shedule_time"
receivers: array_of_receivers
```

Where:

`my_message` - message text.

`send_at` - time in [rfc3339](https://tools.ietf.org/html/rfc3339) format. If date is in past - service tries to send message without delay. 

`receivers` - array of receivers each one contains:

```
im: "messanger_name"
identifier: "user_identifier"
```

Where:
`messanger_name` - IM's name. For testing `im1` and `im2` are added.
`user_identifier` - receiver's identifier identifier for messenger. For testing every values except blank string and `invalid_identifier` are valid.

All parameters are required. At least one receiver have to be present.

**Request example:**

```
POST /plain
Host: oneretarget.com
Content-Type: application/json

{
  "message": "Hello there!",
  "send_at": "2118-01-31 14:00:00+01:00",
  "receivers": [
    { "im": "im1", "identifier": "user1" },
    { "im": "im2", "identifier": "user2" },
  ]
}
```

Will schedule message "Hello there!" on 31/01/2118 2:00 pm (CET) for users `user1` in messenger `im1` and user `user2` in `im2`

If message sending will fail (e.g. link was missed), message will be added to log `log/sending_#{Rails.env}.log`.
After short time next attempt will be made. 
Maximum 25 attempts. [Details](https://github.com/mperham/sidekiq/wiki/Error-Handling#automatic-job-retry)

To simulate failure use "unprocessable" as message.