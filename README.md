
## Dashly for iOS

![Version](https://img.shields.io/static/v1?label=Version&message=2.8.8&color=brightgreen)
​

## Installation
At the moment Dashly for iOS can be installed via CocoaPod.
​
## CocoaPods
Add the following string into the pod file:
```swift
pod 'DashlySDK'
```

## Initialization
You'll need API Key and User Auth Key to work with Dashly for iOS. Those can be found on Settings - Developers tab:
![Developers](https://github.com/carrotquest/ios-sdk/blob/dashly/assets/ApiKeys.png?raw=true)
​
You should add this code into your app's AppDelegate file in order to initialize Dashly:
​

```Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey:Any]?) -> Bool {
    ....
    Dashly.shared.setup(
        withApiKey: key,
        successHandler: {
                print("Dashly SDK connected")
        },
        errorHandler: { error in
            print("Dashly SDK error: " + error)
        })
    ....
}
```



## User authorization

In case your application has user authorization, you might want to send user id to Dashly:
​
```Swift
Dashly.shared.auth(
    withUserId: userId, 
    withUserAuthKey: userAuthKey,
        successHandler: {
                print("Dashly SDK user auth successed")
        },
        errorHandler: { error in
            print("Dashly SDK user auth error: " + error)
        })
```

## User properties and events

You can set user properties, using this method:
```Swift
Dashly.shared.setUserProperty(userProperties)
```
Where `userProperties` is an object of `[UserProperty]` type.
​
`UserProperty` class should be used for user properties description:
```Swift
UserProperty(key: key, value: value)
UserProperty(key: key, value: value, operation: .updateOrCreate)
```
More info on `Operations` can be found in [«User properties»](https://developers.dashly.io/props/#_3) section.
​
`Important!`
​
`key` field value should not start with `$`.
​
​
`CarrotUserProperty` and `EcommerceUProperty` classes should be used to set [system properties](https://developers.dashly.io/props/#_4).
​
​
Use the following method for events tracking:
```Swift
Dashly.shared.trackEvent(withName: name, withParams: params)
```
where `params` is a JSON string with additional set of event parameters
​
## Live chat
You can give your users an opportunity to start a live chat (with your operator) from anywhere. This can be done two ways - either by adding a floating button or by directly calling a chat openning method at desired moment.
​
### Floating Button
You can use the following method to add chat button:
​
```Swift
Dashly.shared.showButton(in: view)
```

Use this method to hide chat button:
```Swift
Dashly.shared.hideButton()
```

### Open chat from anywhere
After initialization you can open chat from any place using thix method:
```swift
Dashly.shared.openChat()
```

### Notofications
SDK uses Firebase Cloud Messaging for sending notifications. At the moment you are required to get a key and send it to our support. You can find an input for this key at "Settings" - "Developers" tab of Dashly admin panel. Cloud Messaging setup is described [here](https://firebase.google.com/docs/cloud-messaging/ios/client).
​
fcmToken for Dashly SDK should be set in MessagingDelegate next:
​
```swift
import FirebaseMessaging
import DashlySDK
extension AppDelegate: MessagingDelegate {  
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        if let fcmToken = fcmToken {
            DashlyNotificationService.shared.setToken(fcmToken)
        } else {
            print("Dashly SDK error: fcmToken not found")
        }
        ...
    }
}
```

Add this code into UNUserNotificationCenterDelegate to display notifications:
​
```swift
import DashlySDK
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let notificationService = DashlyNotificationService.shared
        if notificationService.canHandle(notification) {
            notificationService.show(notification, completionHandler: completionHandler)
        } else {
            // user notifications logic
        }
    }
}
```

Use this for handling clicks on notifications:
​
```swift
import DashlySDK
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        let notificationService = DashlyNotificationService.shared
        if notificationService.canHandle(response) {
            notificationService.clickNotification(notificationResponse: response)
        } else {
            // user notifications logic
        }
        completionHandler()
    }
}
```

### Double notifications

We're delivering messagis via 2 channels, thus same notification can be received twice. Examples: when logging out or quickly deleting a notification there is a possibility of getting the same notification. Notification Service Extension should be created to prevent such behaviour. Choose your project in files list of Xcode, then File/New/Target/Notification Service Extension.

After that register in AppGroup [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list/applicationGroup). Identifier App Group should be unique and start with "group.", otherwise it would not be accepted by Xcode. 
​
Add Identifier into Xcode:
​
![AppGroup](https://github.com/carrotquest/ios-sdk/blob/dashly/assets/AppGroup.png?raw=true)
​
1) Choose your project in the files list. 
​
2) Choose your project's name in targets list. 
​
3) Click "+ Capability" in "Singing & Capabitities" tab. 
​
4) Find and choose App Group in droplist.
​
5) An empty App Group identifiers list will be shown in the tab. Add Identifier previously registered on Apple Developer Portal here. 
​
6) Go back to Targets list. Add App Group into your Notification Service Extension. 
​
​
Add next string to SDK init:
```
   Dashly.shared.setup(
   ...
       withAppGroup: <group_id>,
   ...
   )
```
​
You should now add logic into your Notification Service Extension. A new folder with your Notification Service Extension name should have appeared in the files list. Add code into NotificationService.swift:
​
```swift
import UserNotifications
import DashlySDK

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        guard let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
            return
        }
        self.bestAttemptContent = bestAttemptContent
        let domain = "Identifier previously registered on the Apple Developer Portal"
        DashlyNotificationService.shared.deleteDuplicateNotification(withContent: bestAttemptContent, appGroudDomain: domain)
        contentHandler(bestAttemptContent)
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
```

Refresh your pod file and add this:
```
   target 'NotificationService' do
     inherit! :search_paths
     pod 'DashlySDK'
   end
```

Lastly, send Identifier previously registered on Apple Developer Portal into show method in UNUserNotificationCenterDelegate:
​
```swift
let domain = "Identifier previously registered on Apple Developer Portal"
notificationService.show(notification, appGroudDomain: domain, completionHandler: completionHandler)
```
