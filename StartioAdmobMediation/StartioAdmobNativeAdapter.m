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

#import "StartioAdmobNativeAdapter.h"
#import "StartioAdmobAdapterConfiguration.h"
#import "StartioAdmobExtras.h"
#import "StartioAdmobNativeAd.h"

@import GoogleMobileAds;
#import <StartApp/StartApp.h>


@interface StartioAdmobNativeAdapter () <GADCustomEventNativeAd, STADelegateProtocol>

@property (nonatomic, nullable) STAStartAppNativeAd* startioAd;
@property (nonatomic, nullable) StartioAdmobNativeAd* mediatedAd;

@end

@implementation StartioAdmobNativeAdapter

@synthesize delegate;

- (void)requestNativeAdWithParameter:(nonnull NSString*)serverParameter
                             request:(nonnull GADCustomEventRequest*)request
                             adTypes:(nonnull NSArray*)adTypes
                             options:(nonnull NSArray*)options
                  rootViewController:(nonnull UIViewController*)rootViewController {
    
    NSLog(@"Attempt to load Start.io native ad.");
    StartioAdmobExtras* extras = request.userHasLocation
        ? [[StartioAdmobExtras alloc] initWithJson:serverParameter lat:request.userLatitude lon:request.userLongitude]
        : [[StartioAdmobExtras alloc] initWithJson:serverParameter];
    [StartioAdmobAdapterConfiguration initializeSdkIfNecessary:extras.appId withTestAds:request.isTesting];
    
    for (GADNativeAdImageAdLoaderOptions* imageOptions in options) {
        if (![imageOptions isKindOfClass:GADNativeAdImageAdLoaderOptions.class]) {
            continue;
        }
        extras.prefs.autoBitmapDownload = !imageOptions.disableImageLoading;
    }
    extras.prefs.adsNumber = 1;
    self.startioAd = [[STAStartAppNativeAd alloc] init];
    [self.startioAd loadAdWithDelegate:self withNativeAdPreferences:extras.prefs];
}

- (BOOL)handlesUserClicks {
    return YES;
}

- (BOOL)handlesUserImpressions {
    return YES;
}

#pragma mark - STADelegateProtocol

- (void)didLoadAd:(STAAbstractAd*)ad {
    if (self.startioAd != ad || self.startioAd.adsDetails.count <= 0) {
        NSError* error = [NSError errorWithDomain:@"GADMediationAdapterStartioAdNetwork"
                                             code:12
                                         userInfo:@{NSLocalizedDescriptionKey:@"no fill"}];
        [self.delegate customEventNativeAd:self didFailToLoadWithError:error];
        NSLog(@"Start.io native ad is empty. (no fill)");
    }
    
    STANativeAdDetails* details = self.startioAd.adsDetails.firstObject;
    self.mediatedAd = [[StartioAdmobNativeAd alloc] initWithStartioNativeAd:details];
    [self.delegate customEventNativeAd:self didReceiveMediatedUnifiedNativeAd:self.mediatedAd];
    NSLog(@"Start.io native ad has been loaded successfully.");
}

- (void)failedLoadAd:(STAAbstractAd*)ad withError:(NSError*)error {
    [self.delegate customEventNativeAd:self didFailToLoadWithError:error];
    NSLog(@"Start.io native ad is failed to load, %@", error.localizedDescription);
}

- (void)didShowNativeAdDetails:(STANativeAdDetails*)nativeAdDetails {
    [GADMediatedUnifiedNativeAdNotificationSource mediatedNativeAdDidRecordImpression:self.mediatedAd];
    NSLog(@"Start.io native ad sent an impression.");
}

- (void)didClickNativeAdDetails:(STANativeAdDetails*)nativeAdDetails {
    [GADMediatedUnifiedNativeAdNotificationSource mediatedNativeAdDidRecordClick:self.mediatedAd];
    [GADMediatedUnifiedNativeAdNotificationSource mediatedNativeAdWillLeaveApplication:self.mediatedAd];
    NSLog(@"Start.io native ad record a click.");
}

@end
