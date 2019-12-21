## Carrot quest для iOS (Beta)

`Внимание!` Библиотека находится в стадии активной разработки. Возможны сбои в работе.

Carrot quest для iOS поддерживает версию iOS 10 и выше, Swift 4.2, Xcode 10.

## Установка
На данный момент Carrot quest для iOS можно установить с помощью pod.

## CocoaPods
Добавьте следующую строчку в pod файл:
```swift
pod 'CarrotquestSDK'
```

## Инициализация
Для работы с Carrot quest для iOS вам понадобится API Key и User Auth Key. Вы можете найти эти ключи на вкладке "Настройки > Разработчикам":
![Разработчикам](/assets/img/carrot_api_keys.png)

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

##События

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
```java
Carrot.openChat(context);
```

### Уведомления
Для работы с уведомлениями SDK использует сервис Firebase Cloud Messaging. В связи с этим на данном этапе необходимо получить ключ и отправить его нам в поддержку. Процесс настройки сервиса Firebase Cloud Messaging описан [здесь](https://firebase.google.com/docs/cloud-messaging?authuser=0)

Если вы уже используете сервис Firebase Cloud Messaging для своих push-уведомлений, то для корректной работы push-уведомлений в SDK необходимо отредактировать вашу службу FirebaseMessagingService. Это необходимо для "прокидывания" наших сообщений внутрь SDK. Пример:
``` java
public class MyFirebaseMessagingService extends FirebaseMessagingService {
    @Override
    public void onMessageReceived (RemoteMessage remoteMessage) {
        Map<String, String> data = remoteMessage.getData();
        if (data.containsKey(NotificationsConstants.CQ_SDK_PUSH) && "true".equals(data.get(NotificationsConstants.CQ_SDK_PUSH))) {
            Carrot.sendFirebaseNotification(remoteMessage);
        } else {
            //Your code
        }
    }
}
```

Иконку уведомлений можно устанавливать используя метод:
``` java
Carrot.setNotificationIcon(notificationIconId)
```
где `notificationIconId` - это идентификатор ресурса иконки.

Если вы хотите из любого места вашего приложения получать информацию о новых сообщениях в SDK, то вы можете реализовать BroadcastReceiver. Пример реализации:
```java
public class MyNewMessageBroadcastReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if(intent.hasExtra(NotificationsConstants.CQ_SDK_NEW_MESSAGE_ARG)) {
            IncomingMessage incomingMessage = (IncomingMessage) intent.getSerializableExtra(NotificationsConstants.CQ_SDK_NEW_MESSAGE_ARG);
            if (incomingMessage != null) {
                Toast.makeText(context, incomingMessage.getText(), Toast.LENGTH_SHORT).show();
            }
        }
    }
}
```
`IncomingMessage` - класс, который описывает входящее сообщение.

Далее нужно зарегистрировать его:
``` java
MyNewMessageBroadcastReceiver messageReceiver = new MyNewMessageBroadcastReceiver();
IntentFilter filter = new IntentFilter();
filter.addAction(NotificationsConstants.CQ_SDK_NEW_MESSAGE_ACTION);
registerReceiver(messageReceiver, filter);
```