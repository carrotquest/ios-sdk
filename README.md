
## Dashly for iOS

![Version](https://img.shields.io/static/v1?label=Version&message=2.12.6&color=brightgreen)
​

## Table of Contents

- [Installation](#setup_pods)
- [Swift](#swift)
  - [Initialization](#init_swift)
  - [User authorization](#auth_swift)
  - [User properties and events](#prop_swift)
  - [Live chat](#chat_swift)
  - [Notifications](#notif_swift)
- [Objective-C](#init_objc)
  - [Initialization](#init_objc)
  - [User authorization](#auth_objc)
  - [User properties and events](#prop_objc)
  - [Live chat](#chat_objc)
  - [Notifications](#notif_objc)
- [Double notifications](#notif_extension)
- [Xcode 15](#xcode15)
- [Turn off logs](#TurnOffLogs)

<a name="setup_pods"></a>

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
![Developers](https://github.com/carrotquest/ios-sdk/blob/dashly/assets/ApiKeys.png?raw=true)<a name="swift"></a>

# Swift

<a name="init_swift"></a>

## Initialization

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



<a name="auth_swift"></a>

## User authorization

In case your application has user authorization, you might want to send user id to Dashly. There are two ways of authorization: send userAuthKey directly, send hash generated at your backend.

1. Send userAuthKey directly

```Swift
Dashly.shared.auth(
    withUserId: userId, 
    withUserAuthKey: userAuthKey,
        successHandler: { dashlyId in
            print("Dashly SDK user auth successed, DashlyID = \(dashlyId)")
        },
        errorHandler: { error in
            print("Dashly SDK user auth error: " + error)
        })
```

2. Send hash generated at your backend

```Swift
Dashly.shared.hashedAuth(
    withUserId: userId, 
    withHash: hash,
        successHandler: { dashlyId in
            print("Dashly SDK user auth successed, DashlyID = \(dashlyId)")
        },
        errorHandler: { error in
            print("Dashly SDK user auth error: " + error)
        })
```

To realize the logout function:

```Swift
Dashly.shared.logout(
    successHandler: {
        print("Dashly SDK user logout successed")
    },
    errorHandler: { error in
        print("Dashly SDK user logout error: " + error)
    })
```

<a name="prop_swift"></a>

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
`DashlyUserProperty` and `EcommerceUProperty` classes should be used to set [system properties](https://developers.dashly.io/props/#_4).
​
​
Use the following method for events tracking:

```Swift
Dashly.shared.trackEvent(withName: name, withParams: params)
```
where `params` is a JSON string with additional set of event parameters
​

<a name="chat_swift"></a>

## Live chat

You can give your users an opportunity to start a live chat (with your operator) from anywhere. This can be done two ways - either by adding a floating button or by directly calling a chat openning method at desired moment.
### Floating Button
You can use the following method to add chat button:
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

<a name="notif_swift"></a>

## Notifications

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

<a name="init_objc"></a>

# Objective-C

## Initialization

You should add this code into your app's AppDelegate file in order to initialize Dashly:
​

```objective-c
#import "DashlySDK/DashlySDK.h"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  	....
    Dashly *dashly = [Dashly shared];
    [
        dashly
        setupWithApiKey: API-KEY
        successHandler: ^(){
            NSLog(@"Dashly SDK connected");
        }
        errorHandler: ^(NSString *error){
            NSLog(@"Dashly SDK error: %@", error);
    }];
  	....
    return YES;
}
```



<a name="auth_objc"></a>

## User authorization

In case your application has user authorization, you might want to send user id to Dashly. There are two ways of authorization: send userAuthKey directly, send hash generated at your backend.

1. Send userAuthKey directly

```objective-c
Dashly *dashly = [Dashly shared];
[
  dashly
  authWithUserId: userId
  withUserAuthKey: userAuthKey
  successHandler: ^(NSString *dashlyId){
      NSLog(@"Dashly SDK user auth successed, DashlyId: %@", dashlyId);
  }
  errorHandler: ^(NSString *error){
      NSLog(@"Dashly SDK user auth error: %@", error);
}];
```

2. Send hash generated at your backend

```objective-c
Dashly *dashly = [Dashly shared];
[
  dashly
  authWithUserId: userId
  withHash: hash
  successHandler: ^(NSString *dashlyId){
      NSLog(@"Dashly SDK user auth successed, DashlyId: %@", dashlyId);
  }
  errorHandler: ^(NSString *error){
      NSLog(@"Dashly SDK user auth error: %@", error);
}];
```

To realize the logout function:

```objective-c
Dashly *dashly = [Dashly shared];
[
  dashly
  logoutWithSuccessHandler: ^(){
     NSLog(@"Dashly SDK user logout successed");
  } errorHandler: ^(NSString *error){
     NSLog(@"Dashly SDK user logout error: %@", error);
}];
```

<a name="prop_objc"></a>

## User properties and events

You can set user properties, using this method:

```objective-c
Dashly *dashly = [Dashly shared];
[
  dashly
  setUserProperty:userProperties
];
```

Where `userProperties` is an object of `[UserProperty]` type.
​
`UserProperty` class should be used for user properties description:

```objective-c
Dashly *dashly = [Dashly shared];
UserProperty *userProp = [[UserProperty alloc] initWithKey: key value: value];
UserProperty *userProp = [[UserProperty alloc] initWithKey: key value: value operation: @"updateOrCreate"];
```

More info on `Operations` can be found in [«User properties»](https://developers.dashly.io/props/#_3) section.
​
`Important!`
​
`key` field value should not start with `$`.
​
​
`DashlyUserProperty` and `EcommerceUProperty` classes should be used to set [system properties](https://developers.dashly.io/props/#_4).
​
​
Use the following method for events tracking:

```objective-c
Dashly *dashly = [Dashly shared];
[
  dashly
  trackEventWithName: name
  withParams: params
];
```

where `params` is a JSON string with additional set of event parameters
​

<a name="chat_objc"></a>

## Live chat

You can give your users an opportunity to start a live chat (with your operator) from anywhere. This can be done two ways - either by adding a floating button or by directly calling a chat openning method at desired moment.
​

### Floating Button

You can use the following method to add chat button:

```objective-c
Dashly *dashly = [Dashly shared];
[dashly showButtonIn: self.view];
```

Use this method to hide chat button:

```objective-c
Dashly *dashly = [Dashly shared];
[dashly hideButton];
```

### Open chat from anywhere

After initialization you can open chat from any place using thix method:

```objective-c
Dashly *dashly = [Dashly shared];
[dashly openChat];
```

### Getting the number of unread dialogs and messages

To keep track of the number of unread dialogs:

```objective-c
Dashly *dashly = [Dashly shared];
[
  dashly
  getUnreadConversationsCount:^(NSInteger count){
		NSLog(@"Dashly SDK dialogs count: %ld", (long)count);
}];
```

and for the number of unread messages:

```objective-c
Dashly *dashly = [Dashly shared];
[
  dashly
  getUnreadMessagesCount:^(NSInteger count){
		NSLog(@"Dashly SDK dialogs count: %ld", (long)count);
}];
```

<a name="notif_objc"></a>

## Notifications

SDK uses Firebase Cloud Messaging for sending notifications. At the moment you are required to get a key and send it to our support. You can find an input for this key at "Settings" - "Developers" tab of Dashly admin panel. Cloud Messaging setup is described [here](https://firebase.google.com/docs/cloud-messaging/ios/client).
​
fcmToken for Dashly SDK should be set in MessagingDelegate next:

```objective-c
#import "DashlySDK/DashlySDK.h"
#import <Firebase.h>

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    DashlyNotificationService *service = [DashlyNotificationService shared];
    [service setToken: fcmToken];
}
```

Add this code into UNUserNotificationCenterDelegate to display notifications:

```objective-c
#import <UserNotifications/UserNotifications.h>

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    DashlyNotificationService *service = [DashlyNotificationService shared];
    if ([service canHandle:notification]) {
        [service show:notification appGroudDomain:nil completionHandler:completionHandler];
    } else {
        // user notifications logic
    }
}
```

Use this for handling clicks on notifications:

```objective-c
#import <UserNotifications/UserNotifications.h>

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    DashlyNotificationService *service = [DashlyNotificationService shared];
    if ([service canHandleWithResponse:response]) {
        [service clickNotificationWithNotificationResponse:response appGroudDomain:nil openLink:true];
    } else {
        // user notifications logic
    }
}
```

<a name="notif_extension"></a>

You can read more about why you need the appGroudDomain clause [here](#notif_extension). 

You can read more about why you need the openLink clause [here](#Push+link).

## Double notifications

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

<a name="xcode15"></a>

## Xcode 15

If you are using Xcode 15 and above, and CocoaPods 1.12.1 and below, you will get a directory error like this:

![Xcode](https://raw.githubusercontent.com/carrotquest/ios-sdk/master/assets/ErrorXcode15.png)

To fix this, add the following code to the end of your podfile:

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

Perhaps in the future, CocoaPods will be updated and this code will have to be removed, but for now, it is necessary.

<a name="TurnOffLogs"></a>

## Turn off logs

To turn off the debug logs from the SDK's built-in moya, and from the SDK itself, you need to add a special key to your project's info.plist. 

```XML (Plist)
<key>moyaLog</key>
<string>0</string>
```

0 - logs off

1 - logs on