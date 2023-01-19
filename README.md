## Carrot quest для iOS

![Version](https://img.shields.io/static/v1?label=Version&message=2.8.1-beta0&color=brightgreen)

## Установка
На данный момент Carrot quest для iOS можно установить с помощью CocoaPod.

## CocoaPods
Добавьте следующую строчку в pod файл:
```swift
pod 'CarrotquestSDK'
```

## Инициализация
Для работы с Carrot quest для iOS вам понадобится API Key и User Auth Key. Вы можете найти эти ключи на вкладке "Настройки > Разработчикам":
![Разработчикам](https://raw.githubusercontent.com/carrotquest/ios-sdk/master/assets/ApiKeys.png)

Для инициализации Carrot quest вам нужно добавить следующий код в файл AppDelegate вашего приложения:

```Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey:Any]?) -> Bool {
    ....
    Carrot.shared.setup(
        withApiKey: key,
        successHandler: {
                print("Carrotquest SDK connected")
        },
        errorHandler: { error in
            print("Carrotquest SDK error: " + error)
        })
    ....
}
```



## Авторизация пользователей

Если в вашем приложении присутствует авторизация пользователей, вы можете передать ID пользователя в Carrot quest:

```Swift
Carrot.shared.auth(
    withUserId: userId, 
    withUserAuthKey: userAuthKey,
        successHandler: {
                print("Carrotquest SDK user auth successed")
        },
        errorHandler: { error in
            print("Carrotquest SDK user auth error: " + error)
        })
```

для реализации функции выхода:

```Swift
Carrot.shared.logout(
    successHandler: {
            print("Carrotquest SDK user auth successed")
    },
    errorHandler: { error in
        print("Carrotquest SDK user auth error: " + error)
    })
```

## Свойства пользователей

Вы можете установить необходимые свойства пользователя с помощью:
```Swift
Carrot.shared.setUserProperty(userProperties)
```
Где `userProperties` это объект типа `[UserProperty]`.

Для описания свойств пользователя используйте класс `UserProperty`:
```Swift
UserProperty(key: key, value: value)
UserProperty(key: key, value: value, operation: .updateOrCreate)
```
Более подробно про `Operations` можно прочитать в разделе [«Свойства пользователя»](/props#_3).

`Внимание!`

Поле `key` не может начинаться с символа `$`.


Для установки [системных свойств](/props#_4) реализовано 2 класса `CarrotUserProperty` и `EcommerceUserProperty`.

## События

Для отслеживания событий используйте:
```Swift
Carrot.shared.trackEvent(withName: name, withParams: params)
```
где `params` &mdash; дополнительные параметры для события в виде JSON-строки.

## Чат с оператором
Вы можете дать пользователю мобильного приложения возможность перейти в чат с оператором из любого места. Это можно реализовать двумя разными путями - через плавающую кнопку, либо напрямую вызвав метод открытия чата в любое нужное время.

### Плавающая кнопка (Floating Button)
Виджет предоставляющий быстрый доступ к чату. Добавить кнопку можно с помощью следующего метода:

```Swift
Carrot.shared.showButton(in: view)
```

Для того чтобы скрыть кнопку возпльзуйтесь методом:
```Swift
Carrot.shared.hideButton()
```

### Открытие чата из произвольного места
Открыть чат можно также, вызвав из произвольного места (после инициализации) следующий код:
```swift
Carrot.shared.openChat()
```

### Получение количества непрочтенных диалогов и сообщений
Для отслеживания количества непрочтенных диалогов:
```swift
Carrot.shared.getUnreadConversationsCount({ count in
    print("Carrotquest SDK dialogs count: \(count)")
})
```

и для количества непрочтенных сообщений:
```swift
Carrot.shared.getUnreadMessagesCount({ count in
    print("Carrotquest SDK messages count: \(count)")
})
```

## Уведомления
Для работы с уведомлениями SDK использует сервис Firebase Cloud Messaging. В связи с этим необходимо получить ключ и отправить его в Carrot. Вы можете найти поле для ввода ключа на вкладке Настройки > Разработчикам. Процесс настройки сервиса Firebase Cloud Messaging описан [здесь](https://firebase.google.com/docs/cloud-messaging/ios/client).

Далее, в делегате MessagingDelegate необходимо установить fcmToken для Carrot SDK:

```swift
import FirebaseMessaging
import CarrotSDK
extension AppDelegate: MessagingDelegate {  
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcmToken = fcmToken {
            CarrotNotificationService.shared.setToken(fcmToken)
        } else {
            print("Carrotquest SDK error: fcmToken not found")
        }
        ...
    }
}
```

Для отображения уведомлений, необходимо добавить код в UNUserNotificationCenterDelegate:

```swift
import CarrotSDK
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let notificationService = CarrotNotificationService.shared
        if notificationService.canHandle(notification) {
            notificationService.show(notification, completionHandler: completionHandler)
        } else {
            // Логика для пользовательских уведомлений
        }
    }
}
```

Для обработки кликов на уведомления:

```swift
import CarrotSDK
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        let notificationService = CarrotNotificationService.shared
        if notificationService.canHandle(response) {
            notificationService.clickNotification(notificationResponse: response)
        } else {
            // Логика для пользовательских уведомлений
        }
        completionHandler()
    }
}
```

### Дублирование уведомлений и статистика доставленных пушей

Мы используем 2 канала доставки сообщений, поэтому в некоторых случаях уведомления могут дублироваться. Например: при выходе из приложения, или при очень быстром удалении уведомления, возможно получение повтороного уведомления. Для предотвращения такого поведения нужно создать Notification Service Extension. В Xcode, в списке файлов выберите свой проект, а затем File/New/Target/Notification Service Extension.

После чего необходимо зарегистрировать AppGroup в [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list/applicationGroup). Identifier App Group должен быть уникальным, и начинаться на "group." иначе Xcode его не примет. 

Теперь необходимо добавить Identifier в Xcode:

![AppGroup](https://raw.githubusercontent.com/carrotquest/ios-sdk/dashly/assets/AppGroup.png)

1) В списке файлов выберите свой проект. 

2) В списке targets выберете пункт с именем вашего проекта. 

3) Во вкладке "Singing & Capabitities" нажмите на "+ Capability". 

4) В выпадающем списке найдите найдите и выберите App Group.

5) На вкладке появится пустой список для идентификаторов App Group. Добавте туда Identifier, который зарегистрировали в Apple Developer Portal ранее. 

6) Вернитесь к списку Targets. Аналогичным образом добавте App Group к вашему Notification Service Extension. 


Внесите изменения в метод инициализирующий библиотеку:
```
   Carrot.shared.setup(
   ...
       withAppGroup: <group_id>,
   ...
   )
```

Теперь нужно добавить логику в ваш Notification Service Extension. В списке файлов, должна была появиться новая папка с именем вашего Notification Service Extension. Добавте код в файл NotificationService.swift:

```swift
import UserNotifications
import CarrotSDK

class NotificationService: CarrotNotificationServiceExtension {
    override func setup() {
        self.apiKey = <api_key>
        self.domainIdentifier = <group_id>
    }
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        <ваша логика>
        super.didReceive(request, withContentHandler: contentHandler) 
    }
}
```

Обновите ваш pod файл, добавьте:
```
   target 'NotificationService' do
     inherit! :search_paths
     pod 'CarrotquestSDK'
   end
```

И напоследок, нужно передать Identifier зарегистрированный в Apple Developer Portal ранее в метод show в UNUserNotificationCenterDelegate:

```swift
let domain = "Identifier зарегистрированный в Apple Developer Portal ранее"
notificationService.show(notification, appGroudDomain: domain, completionHandler: completionHandler)
```


