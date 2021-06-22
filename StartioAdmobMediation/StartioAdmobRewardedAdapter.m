/**
 * Copyright 2021 Start.io Inc
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "StartioAdmobRewardedAdapter.h"
#import "StartioAdmobAdapterConfiguration.h"
#import "StartioAdmobExtras.h"

@import GoogleMobileAds;
#import <StartApp/StartApp.h>

@interface StartioAdmobRewardedAdapter () <GADMediationAdapter, GADMediationRewardedAd, STADelegateProtocol>

@property (nonatomic, nullable) STAStartAppAd* startioAd;
@property (nonatomic, copy) GADMediationRewardedLoadCompletionHandler loadCallbacks;
@property (nonatomic, weak) id<GADMediationRewardedAdEventDelegate> delegate;

@end

@implementation StartioAdmobRewardedAdapter

+ (GADVersionNumber)adapterVersion {
    GADVersionNumber version = self.adSDKVersion;
    version.patchVersion = version.patchVersion * 100 + 1;
    return version;
}

+ (GADVersionNumber)adSDKVersion {
    NSString* versionString = STAStartAppSDK.sharedInstance.version;
    NSArray<NSString*>* versionComponents = [versionString componentsSeparatedByString:@"."];
    GADVersionNumber version = {0};
    if (versionComponents.count == 3) {
        version.majorVersion = [versionComponents[0] integerValue];
        version.minorVersion = [versionComponents[1] integerValue];
        version.patchVersion = [versionComponents[2] integerValue];
    }
    return version;
}

+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
    return Nil;
}

- (void)loadRewardedAdForAdConfiguration:(GADMediationRewardedAdConfiguration*)adConfiguration
                       completionHandler:(GADMediationRewardedLoadCompletionHandler)completionHandler {
    
    NSLog(@"Attempt to load Start.io rewarded ad.");
    NSString* serverParameter = adConfiguration.credentials.settings[@"parameter"];
    StartioAdmobExtras* extras = adConfiguration.hasUserLocation
        ? [[StartioAdmobExtras alloc] initWithJson:serverParameter lat:adConfiguration.userLatitude lon:adConfiguration.userLongitude]
        : [[StartioAdmobExtras alloc] initWithJson:serverParameter];
    [StartioAdmobAdapterConfiguration initializeSdkIfNecessary:extras.appId withTestAds:adConfiguration.isTestRequest];
    
    self.startioAd = [[STAStartAppAd alloc] init];
    self.loadCallbacks = completionHandler;
    [self.startioAd loadRewardedVideoAdWithDelegate:self withAdPreferences:extras.prefs];
}

- (void)presentFromViewController:(UIViewController*)viewController {
    if (self.startioAd.isReady) {
        [self.startioAd showAd];
    } else {
        NSError* error = [NSError errorWithDomain:@"GADMediationAdapterStartioAdNetwork"
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey:@"Rewarded ad is not ready."}];
        [self.delegate didFailToPresentWithError:error];
    }
}

#pragma mark - STADelegateProtocol

- (void)didLoadAd:(STAAbstractAd*)ad {
    self.delegate = self.loadCallbacks(self, nil);
    NSLog(@"Start.io rewarded ad has been loaded successfully.");
}

- (void)failedLoadAd:(STAAbstractAd*)ad withError:(NSError*)error {
    self.loadCallbacks(nil, error);
    NSLog(@"Start.io rewarded ad is failed to load, %@", error.localizedDescription);
}

- (void)didShowAd:(STAAbstractAd*)ad {
    [self.delegate willPresentFullScreenView];
    [self.delegate reportImpression];
    [self.delegate didStartVideo];
    NSLog(@"Start.io rewarded ad has been shown.");
}

- (void)failedShowAd:(STAAbstractAd*)ad withError:(NSError*)error {
    NSLog(@"Start.io rewarded ad is failed to show, %@", error.localizedDescription);
}

- (void)didCloseAd:(STAAbstractAd*)ad {
    [self.delegate didDismissFullScreenView];
    NSLog(@"Start.io rewarded ad is dismissed.");
}

- (void)didClickAd:(STAAbstractAd*)ad {
    [self.delegate reportClick];
    NSLog(@"Start.io rewarded ad was clicked.");
}

- (void)didCompleteVideo:(STAAbstractAd*)ad {
    [self.delegate didEndVideo];
    GADAdReward* reward = [[GADAdReward alloc] initWithRewardType:@"" rewardAmount:NSDecimalNumber.one];
    [self.delegate didRewardUserWithReward:reward];
    NSLog(@"Start.io rewarded ad gave a rewarded.");
}

@end
