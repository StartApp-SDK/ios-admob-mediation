# ios-admob-mediation
## Enables you to serve Start.io (formerly StartApp) Ads in your iOS application using Google's AdMob mediation network

### 1. Getting Started

The following instructions assume you are already familiar with the AdMob mediation network and have already integrated the AdMob iOS SDK into your application. Otherwise, please start by visiting AdMob site and reading the instructions on how to add AdMob mediation code into your app.
  * [AdMob mediation](https://developers.google.com/admob/ios/mediate)
  * [AdMob quick start](https://developers.google.com/admob/ios/quick-start)
  
### 2. Adding Your Application to Your Start.io Developer's Account
1. Login into your [Start.io developer's account](https://portal.start.io/#/signin)
1. Add your application and get its App ID

### 3. Integrating the Start.io <-> AdMob Mediation Adapter
The easiest way is to use CocoaPods, just add to your Podfile the dependency
```
pod 'startio-admob-mediation'
```
But you might as well use [this source code](https://github.com/StartApp-SDK/ios-admob-mediation) from Github and add it to your project

### 4. Adding a Custom Event
1. Login into your [Admob account](https://apps.admob.com)
1. From the left menu select "Mediation"
1. Press "CREATE MEDIATION GROUP" unless you already have prepared one
1. Fill out all the fields regarding to your ad parameters
1. Select your previously created ad unit pressing "ADD AD UNITS"
1. On the "Waterfall" panel press "ADD CUSTOM EVENT"
1. Fill in "Label" and "eCPM" as you need
1. Fill in the appeared fields "Class Name" and "Parameter" regarding to your ad type:

Ad Type | Class Name | Parameter | Options
------- | ------------------ | ----------------- | -------
Interstitial | StartioAdmobFullscreenAdapter | {"startioAppId":"your_id_from_portal", "adTag":"any_your_tag", "interstitialMode":"OVERLAY", "minCPM":0.02} | interstitialMode can be OVERLAY or VIDEO
Banner/Medium Rectangle | StartioAdmobInlineAdapter | {"startioAppId":"your_id_from_portal", "adTag":"any_your_tag", "minCPM":0.02} | 
Rewarded | StartioAdmobRewardedAdapter | {"startioAppId":"your_id_from_portal", "adTag":"any_your_tag", "minCPM":0.02} |
Native | StartioAdmobNativeAdapter | {"startioAppId":"your_id_from_portal", "adTag":"any_your_tag", "minCPM":0.02, "nativeImageSize":"SIZE150X150", "nativeSecondaryImageSize":"SIZE100X100"} | nativeImageSize and nativeSecondaryImageSize can be any of SIZE72X72, SIZE100X100, SIZE150X150, SIZE340X340, SIZE1200X628(for main image only) | 

All parameters in the "Parameter" field are optional except the "startioAppId" which you must provide in any case.

#### If you need additional assistance you can take a look on our app example which works with this mediation adapter [here](https://github.com/StartApp-SDK/ios-admob-mediation-sample)

