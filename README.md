## Carrot quest для iOS

![Version](https://img.shields.io/static/v1?label=Version&message=3.1.2&color=brightgreen)[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

## Содержание

- [Установка](#setup_pods)
- [Обновление до версии 3.0.0](#3.0.0_update)
- [Swift](#swift)
  - [Инициализация](#init_swift)
  - [Авторизация пользователей](#auth_swift)
  - [Свойства пользователей](#prop_swift)
  - [События](#event_swift)
  - [Трекинг навигации](#tracking_swift)
  - [Чат с оператором](#chat_swift)
  - [Открытие ссылок вручную](#custom_url_opener_swift)
  - [Уведомления](#notif_swift)
- [Objective-C](#init_objc)
  - [Инициализация](#init_objc)
  - [Авторизация пользователей](#auth_objc)
  - [Свойства пользователей](#prop_objc)
  - [События](#event_objc)
  - [Трекинг навигации](#tracking_objc)
  - [Чат с оператором](#chat_objc)
  - [Открытие ссылок вручную](#custom_url_opener_objc)
  - [Уведомления](#notif_objc)
- [Важная информация о Push уведомлениях](#important_push)
- [Дублирование уведомлений и статистика доставленных пушей](#notif_extension)
- [Метод отписки от пушей](#notifications_unsubscribe)
- [Локализация](#localization)
- [Xcode 15](#xcode15)
- [Использование ссылок в пушах](#Push+link) 
- [Отключение дебажных логов](#TurnOffLogs)

<a name="setup_pods"></a>

## Установка

На данный момент Carrot quest для iOS можно установить с помощью CocoaPods и Swift Package Manager.

## CocoaPods
Добавьте следующую строчку в Podfile:
```swift
pod 'CarrotquestSDK'
```

## Swift Package Manager

В Xcode нажмите «File → Add Package Dependencies...»

Затем в появившемся окне в поле "Search or Enter Package URL" вставьте ссылку на SwiftPM репозиторий:

```url
https://github.com/carrotquest/carrotquest-ios-spm.git
```

## Инициализация

Для работы с Carrot quest для iOS вам понадобится API Key и User Auth Key. Вы можете найти эти ключи на вкладке "Настройки > Разработчикам":
![Разработчикам](https://raw.githubusercontent.com/carrotquest/ios-sdk/master/assets/ApiKeys.png)

<a name="3.0.0_update"></a>

## Обновление до версии 3.0.0

Обратите внимание, что при переходе на версию 3.0.0 были внесены некоторые важные изменения в способ взаимодействия с библиотекой. 

Если у вас есть авторизация пользователей необходимо вызывать ее при старте приложения. Наилучшим местом для этого является successHandler у метода setup:

```swift
Carrot.shared.setup(
    withApiKey: apiKey,
    successHandler: {
        if let userId = userId {
            Carrot.shared.auth(
                withUserId: userId, 
                withUserAuthKey: userAuthKey, // or withHash: hash,
                    successHandler: { carrotId in
                        print("Carrotquest SDK user auth succeeded, CarrotId = \(carrotId)")
                    },
                    errorHandler: { error in
                        print("Carrotquest SDK user auth error: " + error)
                    })
        }
    },
    errorHandler: { error in
        print("Failed to connect Carrotquest SDK, reason: \(error)")
    }
)
```

Таким образом это предотвратит лишнее возникновение анонимных пользователей. 

Так же, для унификации кода с AndroidSDK аргумент withTheme был вынесен из метода setup в отдельный метод:

```swift
Carrot.shared.setTheme(.fromMobile)
```

Как и раньше, возможны 4 значения:

```swift
enum Theme {
	case light // Светлая тема
	case dark // Темная тема
	case fromMobile // Повторять тему устройства
	case fromWeb // Повторять тему указанную в настройках админки
}
```

<a name="swift"></a>

# Swift

<a name="init_swift"></a>

## Инициализация

Для инициализации Carrot quest вам нужно добавить следующий код в файл AppDelegate вашего приложения:

```Swift
import CarrotSDK

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey:Any]?) -> Bool {
    ....
    Carrot.shared.setup(
        withApiKey: API-KEY,
        successHandler: {
                print("Carrotquest SDK connected")
        },
        errorHandler: { error in
            print("Carrotquest SDK error: " + error)
        })
    ....
}
```

<a name="auth_swift"></a>

## Авторизация пользователей

Если в вашем приложении присутствует авторизация пользователей, вы можете передать ID пользователя в Carrot quest. Существует два способа авторизации: напрямую передать userAuthKey, передать hash генерируемый у вас на бэке.

1. Вход через user auth key:

```Swift
Carrot.shared.auth(
    withUserId: userId, 
    withUserAuthKey: userAuthKey,
        successHandler: { carrotId in
                print("Carrotquest SDK user auth successed, CarrotId = \(carrotId)")
        },
        errorHandler: { error in
            print("Carrotquest SDK user auth error: " + error)
        })
```

2. Вход через hash:

```Swift
Carrot.shared.hashedAuth(
    withUserId: userId, 
    withHash: hash,
        successHandler: { carrotId in
                print("Carrotquest SDK user auth successed, CarrotId = \(carrotId)")
        },
        errorHandler: { error in
            print("Carrotquest SDK user auth error: " + error)
        })
```

Для реализации функции выхода:

```Swift
Carrot.shared.logout(
    successHandler: {
            print("Carrotquest SDK user logout successed")
    },
    errorHandler: { error in
        print("Carrotquest SDK user logout error: " + error)
    })
```

<a name="prop_swift"></a>

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
Более подробно про `Operations` можно прочитать в разделе [«Свойства пользователя»](https://developers.carrotquest.io/props/#_3).

`Внимание!`

Поле `key` не может начинаться с символа `$`.


Для установки [системных свойств](https://developers.carrotquest.io/props/#_4) реализовано 2 класса `CarrotUserProperty` и `EcommerceUserProperty`.

<a name="event_swift"></a>

## События

Для отслеживания событий используйте:
```Swift
Carrot.shared.trackEvent(withName: name, withParams: params)
```
где `params` &mdash; дополнительные параметры для события в виде JSON-строки.

<a name="tracking_swift"></a>

## Трекинг навигации

B SDK есть возможность трекинга навигации внутри приложения для того, чтобы при необходимости запускать различные триггерные сообщения на определенных экранах. Для этого используйте метод:

```Swift
let name: String = "screenName"
Carrot.shared.trackScreen(name)
```

<a name="chat_swift"></a>

## Чат с оператором

Вы можете дать пользователю мобильного приложения возможность перейти в чат с оператором из любого места. Это можно реализовать двумя разными путями - через плавающую кнопку, либо напрямую вызвав метод открытия чата в любое нужное время.

### Плавающая кнопка (Floating Button)
Виджет предоставляющий быстрый доступ к чату. Добавить кнопку можно с помощью следующего метода:

```Swift
Carrot.shared.showButton(in: view)
```

Для того чтобы скрыть кнопку воспользуйтесь методом:
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
Carrot.shared.getUnreadConversationsCount { count in
    print("Carrotquest SDK dialogs count: \(count)")
}
```

и для количества непрочтенных сообщений:

```swift
Carrot.shared.getUnreadMessagesCount { count in
    print("Carrotquest SDK messages count: \(count)")
}
```

### Отслеживание отображения UI SDK

Вы можете отследить, отображается ли сейчас какой-либо UI элемент библиотеки на экране (чат, список диалогов, попап). Колбэк вызывается каждый раз при показе или скрытии этих элементов:

```swift
Carrot.shared.onVisibilityUIChanged { isVisible in
    print("Carrotquest SDK - isVisible: \(isVisible)")
}
```

Если isVisible == true, значит один из экранов SDK (чат, попап и т. д.) отображается. Если false — ничего не показывается.

<a name="custom_url_opener_swift"></a>

## Открытие ссылок вручную

Для того, чтобы при клике на ссылку внутри SDK правильно работали диплинки (universal link) существует специальный метод ручного управления методом открытия ссылок. Его можно вызвать где угодно, но лучше всего где-то в вашем AppDelegate/SceneDelegate рядом с инициализацией SDK:

```swift
import CarrotSDK

CustomUrlOpener.shared.set(for: .chat, customLogic: { url in
      // Любая кастомная логика по открытию ссылок
})
```

Как вы можете заметить, первый аргумент, который имеет label `for` на 4 доступных варианта:

- push - изменяет логику при клике на ссылку в пуше
- chat - изменяет логику при клике на ссылку в чате
- popup - изменяет логику при клике на ссылку в попапе
- all - изменяет логику при клике на ссылку во всех 3 местах

Таким образом, если вы хотите обработать клики на диплинк (universal link) во всех местах SDK, можно написать какой-то такой код:

```swift
import CarrotSDK

CustomUrlOpener.shared.set(for: .all) { url in
    if url.host?.contains("ВАШ ДОМЕН") ?? false {
        CustomUrlOpener.shared.openUniversalLink(url)
    } else {
        CustomUrlOpener.shared.openBrowserLink(url)
    }
}
```

Если что, ошибки тут нет. Актуальные версии Swift позволяют не указывать label последнего замыкания в вызове функции. 

<a name="notif_swift"></a>

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

Так же, необходимо запросить разрешение на показ уведомлений. Рекомендованное место:

```swift
class AppDelegate {  
    func application(
      _ application: UIApplication, 
    	didFinishLaunchingWithOptions launchOptions: 											[UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
      
			...
      
      UNUserNotificationCenter
      	.current()
      	.requestAuthorization(
          options: [.alert, .badge, .sound]
        ) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication
                  	.shared
                  	.registerForRemoteNotifications()
                }
            }
                                                                            }

        return true
    }
}
```

Так же, рекомендуем убедиться, что запрос на показ уведолмений происходит раньше чем установка токена через CarrotNotificationService.shared.setToken. 

# Objective-C

<a name="init_objc"></a>

## Инициализация

Для инициализации Carrot quest вам нужно добавить следующий код в файл AppDelegate вашего приложения:

```objective-c
#import "CarrotSDK/CarrotSDK.h"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  	....
    Carrot *carrot = [Carrot shared];
    [
        carrot
        setupWithApiKey: API-KEY
        successHandler: ^(){
            NSLog(@"Carrotquest SDK connected");
        }
        errorHandler: ^(NSString *error){
            NSLog(@"Carrotquest SDK error: %@", error);
    }];
  	....
    return YES;
}
```

<a name="auth_objc"></a>

## Авторизация пользователей

Если в вашем приложении присутствует авторизация пользователей, вы можете передать ID пользователя в Carrot quest. Существует два способа авторизации: напрямую передать userAuthKey, передать hash генерируемый у вас на бэке.

1. Вход через user auth key:

```objective-c
Carrot *carrot = [Carrot shared];
[
  carrot
  authWithUserId: userId
  withUserAuthKey: userAuthKey
  successHandler: ^(NSString *carrotId){
      NSLog(@"Carrotquest SDK user auth successed, CarrotId: %@", carrotId);
  }
  errorHandler: ^(NSString *error){
      NSLog(@"Carrotquest SDK user auth error: %@", error);
}];
```

2. Вход через hash:

```objective-c
Carrot *carrot = [Carrot shared];
[
  carrot
  authWithUserId: userId
  withHash: hash
  successHandler: ^(NSString *carrotId){
      NSLog(@"Carrotquest SDK user auth successed, CarrotId: %@", carrotId);
  }
  errorHandler: ^(NSString *error){
      NSLog(@"Carrotquest SDK user auth error: %@", error);
}];
```

Для реализации функции выхода:

```objective-c
Carrot *carrot = [Carrot shared];
[
  carrot
  logoutWithSuccessHandler: ^(){
     NSLog(@"Carrotquest SDK user logout successed");
  } errorHandler: ^(NSString *error){
     NSLog(@"Carrotquest SDK user logout error: %@", error);
}];
```

<a name="prop_objc"></a>

## Свойства пользователей

Вы можете установить необходимые свойства пользователя с помощью:

```objective-c
Carrot *carrot = [Carrot shared];
[
  carrot
  setUserProperty:userProperties
]
```

Где `userProperties` это объект типа `[UserProperty]`.

Для описания свойств пользователя используйте класс `UserProperty`:

```objective-c
Carrot *carrot = [Carrot shared];
UserProperty *userProp = [[UserProperty alloc] initWithKey: key value: value];
UserProperty *userProp = [[UserProperty alloc] initWithKey: key value: value operation: @"updateOrCreate"];
```

Более подробно про `Operations` можно прочитать в разделе [«Свойства пользователя»](https://developers.carrotquest.io/props/#_3).

`Внимание!`

Поле `key` не может начинаться с символа `$`.


Для установки [системных свойств](https://developers.carrotquest.io/props/#_4) реализовано 2 класса `CarrotUserProperty` и `EcommerceUserProperty`.

<a name="event_objc"></a>

## События

Для отслеживания событий используйте:

```objective-c
Carrot *carrot = [Carrot shared];
[
  carrot
  trackEventWithName: name
  withParams: params
];
```

где `params` &mdash; дополнительные параметры для события в виде JSON-строки.

<a name="tracking_objc"></a>

## Трекинг навигации

B SDK есть возможность трекинга навигации внутри приложения для того, чтобы при необходимости запускать различные триггерные сообщения на определенных экранах. Для этого используйте метод:

```objective-c
Carrot *carrot = [Carrot shared];
[carrot trackScreen:@"screenName"];
```

<a name="chat_objc"></a>

## Чат с оператором

Вы можете дать пользователю мобильного приложения возможность перейти в чат с оператором из любого места. Это можно реализовать двумя разными путями - через плавающую кнопку, либо напрямую вызвав метод открытия чата в любое нужное время.

### Плавающая кнопка (Floating Button)

Виджет предоставляющий быстрый доступ к чату. Добавить кнопку можно с помощью следующего метода:

```objective-c
Carrot *carrot = [Carrot shared];
[carrot showButtonIn: self.view];
```

Для того чтобы скрыть кнопку возпльзуйтесь методом:

```objective-c
Carrot *carrot = [Carrot shared];
[carrot hideButton];
```

### Открытие чата из произвольного места

Открыть чат можно также, вызвав из произвольного места (после инициализации) следующий код:

```objective-c
Carrot *carrot = [Carrot shared];
[carrot openChat];
```

### Получение количества непрочтенных диалогов и сообщений

Для отслеживания количества непрочтенных диалогов:

```objective-c
Carrot *carrot = [Carrot shared];
[
  carrot
  getUnreadConversationsCount:^(NSInteger count){
		NSLog(@"Carrotquest SDK dialogs count: %ld", (long)count);
}];
```

и для количества непрочтенных сообщений:

```objective-c
Carrot.shared.getUnreadMessagesCount({ count in
    print("Carrotquest SDK messages count: \(count)")
})
Carrot *carrot = [Carrot shared];
[
  carrot
  getUnreadMessagesCount:^(NSInteger count){
		NSLog(@"Carrotquest SDK dialogs count: %ld", (long)count);
}];
```

### Отслеживание отображения UI SDK

Вы можете отследить, отображается ли сейчас какой-либо UI элемент библиотеки на экране (чат, список диалогов, попап). Колбэк вызывается каждый раз при показе или скрытии этих элементов:

```objective-c
Carrot *carrot = [Carrot shared];
[
  carrot
  onVisibilityUIChanged:^(BOOL isVisible){
		NSLog(@"Carrotquest SDK — isVisible: %@", isVisible ? @"YES" : @"NO");
}];
```

Если isVisible == true, значит один из экранов SDK (чат, попап и т. д.) отображается. Если false — ничего не показывается.

<a name="custom_url_opener_objc"></a>

## Открытие ссылок вручную

Для того, чтобы при клике на ссылку внутри SDK правильно работали диплинки (universal link) существует специальный метод ручного управления методом открытия ссылок. Его можно вызвать где угодно, но лучше всего где-то в вашем AppDelegate/SceneDelegate рядом с инициализацией SDK:

```objective-c
CustomUrlOpener *opener = [CustomUrlOpener shared];

[
  opener
  for: 1
  customLogic: ^(NSURL *url){
       // Любая кастомная логика по открытию ссылок
   }
];
```

Как вы можете заметить, первый аргумент, который имеет label `for` на 4 доступных варианта:

- push - изменяет логику при клике на ссылку в пуше
- chat - изменяет логику при клике на ссылку в чате
- popup - изменяет логику при клике на ссылку в попапе
- all - изменяет логику при клике на ссылку во всех 3 местах

Таким образом, если вы хотите обработать клики на диплинк (universal link) во всех местах SDK, можно написать какой-то такой код:

```objective-c
CustomUrlOpener *opener = [CustomUrlOpener shared];

[
  opener
  for: 3
  customLogic: ^(NSURL *url){
       if ([[url host] containsString:@"ВАШ ДОМЕН"]) {
            [[CustomUrlOpener shared] openUniversalLink:url];
        } else {
            [[CustomUrlOpener shared] openBrowserLink:url];
        }
   }
];
```

<a name="notif_objc"></a>

## Уведомления

Для работы с уведомлениями SDK использует сервис Firebase Cloud Messaging. В связи с этим необходимо получить ключ и отправить его в Carrot. Вы можете найти поле для ввода ключа на вкладке Настройки > Разработчикам. Процесс настройки сервиса Firebase Cloud Messaging описан [здесь](https://firebase.google.com/docs/cloud-messaging/ios/client).

Далее, в делегате MessagingDelegate необходимо установить fcmToken для Carrot SDK:

```objective-c
#import "CarrotSDK/CarrotSDK.h"
#import <Firebase.h>

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    CarrotNotificationService *service = [CarrotNotificationService shared];
    [service setToken: fcmToken];
}
```

Для отображения уведомлений, необходимо добавить код в AppDelegate:

```objective-c
#import <UserNotifications/UserNotifications.h>

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    CarrotNotificationService *service = [CarrotNotificationService shared];
    if ([service canHandle:notification]) {
        [service show:notification appGroudDomain:nil completionHandler:completionHandler];
    } else {
        // Логика для пользовательских уведомлений
    }
}
```

Для обработки кликов на уведомления:

```objective-c
#import <UserNotifications/UserNotifications.h>

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    CarrotNotificationService *service = [CarrotNotificationService shared];
    if ([service canHandleWithResponse:response]) {
        [service clickNotificationWithNotificationResponse:response appGroudDomain:nil openLink:YES];
    } else {
        // Логика для пользовательских уведомлений
    }
}
```

Подробнее о том, зачем нужен пункт appGroudDomain можно почитать [тут](#notif_extension). 

Подробнее о том, зачем нужен пункт openLink можно почитать [тут](#Push+link).

Так же, необходимо запросить разрешение на показ уведомлений. Рекомендованное место:

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {

    ...

    [[UNUserNotificationCenter currentNotificationCenter]
        requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound)
                      completionHandler:^(BOOL granted, NSError * _Nullable error) {
                          if (granted) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [[UIApplication sharedApplication] registerForRemoteNotifications];
                              });
                          }
                      }];

    return YES;
}
```

Так же, рекомендуем убедиться, что запрос на показ уведолмений происходит раньше чем установка токена через CarrotNotificationService.shared.setToken. 

<a name="important_push"></a>

## Важная информация о Push уведомлениях

Необходимо добавить в info.plist вашего проекта параметр:

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<string>0</string>
```

И обязательно, убедиться, что поле имеет значение string. Если кратко, то это переключает управление уведомлениями в ручной режим и позволяет SDK правильно функционировать. Подробнее можете почитать [тут](https://firebase.google.com/docs/cloud-messaging/ios/client?hl=ru).

<a name="notif_extension"></a>

## Дублирование уведомлений и статистика доставленных пушей

Мы используем 2 канала доставки сообщений, поэтому в некоторых случаях уведомления могут дублироваться. Например: при выходе из приложения, или при очень быстром удалении уведомления, возможно получение повторного уведомления. Для предотвращения такого поведения нужно создать Notification Service Extension. В Xcode, в списке файлов выберите свой проект, а затем File/New/Target/Notification Service Extension.

После чего необходимо зарегистрировать AppGroup в [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list/applicationGroup). Identifier App Group должен быть уникальным, и начинаться на "group." иначе Xcode его не примет. 

Теперь необходимо добавить Identifier в Xcode:

![AppGroup](https://raw.githubusercontent.com/carrotquest/ios-sdk/dashly/assets/AppGroup.png)

1) В списке файлов выберите свой проект. 

2) В списке targets выберите пункт с именем вашего проекта. 

3) Во вкладке "Signing & Capabilities" нажмите на "+ Capability". 

4) В выпадающем списке найдите найдите и выберите App Group.

5) На вкладке появится пустой список для идентификаторов App Group. Добавьте туда Identifier, который зарегистрировали в Apple Developer Portal ранее. 

6) Вернитесь к списку Targets. Аналогичным образом добавте App Group к вашему Notification Service Extension. 


Внесите изменения в метод инициализирующий библиотеку:
```
   Carrot.shared.setup(
   ...
       withAppGroup: <group_id>,
   ...
   )
```

Теперь нужно добавить логику в ваш Notification Service Extension. В списке файлов, должна была появиться новая папка с именем вашего Notification Service Extension. Добавьте код в файл NotificationService.swift:

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

<a name="notifications_unsubscribe"></a>

## Метод отписки от пушей

Существуют методы отписать конкретного пользователя от пушей и от всех рассылок в принципе. 

Метод для отписки от пушей:

```swift
import CarrotSDK

CarrotNotificationService.shared.pushNotificationsUnsubscribe()
```

Метод для отписки от всех рассылок:

```swift
import CarrotSDK

CarrotNotificationService.shared.pushCampaignsUnsubscribe()
```

<a name="localization"></a>

## Локализация

Для того, чтобы SDK автоматически подтягивал и русскую локализацию, кроме стандартной, английской, необходимо убедиться, что в Xcode проекте такая локализация включена. 

![Локализация](https://raw.githubusercontent.com/carrotquest/ios-sdk/master/assets/Localozations.png)

<a name="xcode15"></a>

## Xcode 15

Если вы используете Xcode 15 и выше, и CocoaPods 1.12.1 и ниже, то у вас возникнет ошибка директорий, вроде такой:

![Локализация](https://raw.githubusercontent.com/carrotquest/ios-sdk/master/assets/ErrorXcode15.png)

Чтобы исправить это, добавьте следующий код в конец своего podfile:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.base_configuration_reference.is_a? Xcodeproj::Project::Object::PBXFileReference
        xcconfig_path = config.base_configuration_reference.real_path
        IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
      end
    end
  end
end
```

Возможно, в будущем, CocoaPods обновится, и этот код придется удалить, но в данный момент, он необходим. 

<a name="Push+link"></a>

## Использование ссылок в пушах

Небольшой словарь терминов, перед тем как мы начнем:

Universal link (еще его называют Deeplink, но это не терминология Apple):

```html
https://example.com/section
```

URL scheme:

```html
example://section
```

Итак, вы можете приложить ссылку к пушу. 

![PushLink](https://raw.githubusercontent.com/carrotquest/ios-sdk/master/assets/Push1.png)

Однако, не все так просто. Внутри обработчика пуша лежит функция:

```swift
if let clickActionUrl = URL(string: "Ваша ссылка") {
		UIApplication.shared.open(clickActionUrl, options: [:])
}
```

Простейшая логика. Однако, по какой-то причине, функция iOS для открытия ссылок, указанная выше, не распознает универсальную ссылку приложения, если она вызывается из этого же приложения. Это отправит пользователя прямо в браузер.

Поэтому, есть два возможных варианта решения проблемы:

1. URL Scheme
2. Ручная обработка Universal link

-----

1. URL Scheme

Если в вашем приложении настроены URL Scheme то все уже готово. Просто приложите нужную схему к пушу. 

Далее прикладываю небольшой туториал по настройке URL Scheme.

URL Scheme - это более простой и надежный способ открыть нужную страницу в приложении, в отличии от Universal Link. Однако, они не выглядят как ссылка из интернета:

```html
deeplink://test
```

Перейдем к настройке. Выберите цель в настройках проекта Xcode и перейдите на вкладку «Информация». Внизу страницы вы найдете раздел «URL Types».

![URL_scheme](https://raw.githubusercontent.com/carrotquest/ios-sdk/master/assets/Push2.png)

Нажав `+`, мы можем создать новый тип. В качестве идентификатора люди часто повторно используют пакет приложения. Для схем URL-адресов мы рекомендуем использовать название приложения (или сокращенное название), чтобы оно было как можно более кратким. В нем не должно быть никаких специальных символов. Мы будем использовать `deeplink` в качестве примера.

Ваше приложение готово распознать URL схему, теперь нам нужно обработать его, когда мы его получим.

Приложение фиксирует открытие следующим образом в более ранних приложениях, в которых есть только `AppDelegate`.

```swift
extension AppDelegate {

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {

        print(url)
        return true
    }
}
```

Для новых приложений, включающих SceneDelegate, необходимо добавить обработчик еще и туда. Важно отметить, что метод AppDelegateне будет вызван, даже если вы его реализуете.

```swift
extension SceneDelegate {
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let firstUrl = URLContexts.first?.url else {
            return
        }

        print(firstUrl.absoluteString)
    }
}
```

Если хотите проверить ссылку, введите ее в браузере Safari. Так же, доступен вариант для быстрой проверки на симуляторе. Вот команда для терминала: 

```bash
xcrun simctl openurl booted "deeplink://test"
```

2. Ручная обработка Universal link

Вернитесь к обработчику кликов на пуши, и передайте аргумент false в параметр openLink:

```swift
CarrotNotificationService.shared.clickNotification(
		notificationResponse: response,
		openLink: false
)
```

Затем, нужно достать ссылку из объекта response, который пришел в пуше. Мы заранее подготовили для этого функцию:

```swift
let link: String? = CarrotNotificationService.shared.getLink(from: response)
```

Обратите внимание, что функция возвращает опционал, потому что пуш не всегда содержит ссылку.

Таким образом, в методе обработки кликов на пуши, у вас получится что-то такое:

```swift
import CarrotSDK
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        let notificationService = CarrotNotificationService.shared
        if notificationService.canHandle(response) {
            notificationService.clickNotification(notificationResponse: response, openLink: false)
						if let link = CarrotNotificationService.shared.getLink(from: response) {
								print(link)
								// Обработчик открытия Universal link
        }
        completionHandler()
    }
}
```

<a name="TurnOffLogs"></a>

## Отключение дебажных логов

Для отключения дебажных логов от встроенного в SDK Moya, и от самого SDK, необходимо добавить специальный ключ в info.plist вашего проекта. 

```XML (Plist)
<key>moyaLog</key>
<string>0</string>
```

0 - логи выключены

1 - логи включены