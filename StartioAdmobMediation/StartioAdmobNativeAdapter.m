/**
 * Copyright 2022 Start.io Inc
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
#import "StartioAdmobParameters.h"
#import "StartioAdmobNativeAd.h"
#import "STAAdPreferences+AdMob.h"

@import GoogleMobileAds;
@import StartApp;


@interface StartioAdmobNativeAdapter () <STADelegateProtocol>

@property (nonatomic, strong) STAStartAppNativeAd* startioAd;
@property (nonatomic, copy) GADMediationNativeLoadCompletionHandler completionHandler;
@property (nonatomic, weak) id<GADMediationNativeAdEventDelegate> delegate;

@end

@implementation StartioAdmobNativeAdapter

- (void)loadAdForAdConfiguration:(GADMediationNativeAdConfiguration *)adConfiguration
          startioAdmobParameters:(StartioAdmobParameters *)startioAdmobParameters
               completionHandler:(id)completionHandler {
    self.completionHandler = completionHandler;
    
    STANativeAdPreferences *adPrefs = [[STANativeAdPreferences alloc] initWithAdConfiguration:adConfiguration startioAdmobParameters:startioAdmobParameters];
    for (GADNativeAdImageAdLoaderOptions* imageOptions in adConfiguration.options) {
        if (![imageOptions isKindOfClass:GADNativeAdImageAdLoaderOptions.class]) {
            continue;
        }
        adPrefs.autoBitmapDownload = !imageOptions.disableImageLoading;
    }
    adPrefs.adsNumber = 1;
    self.startioAd = [[STAStartAppNativeAd alloc] init];
    [self.startioAd loadAdWithDelegate:self withNativeAdPreferences:adPrefs];
}

#pragma mark - STADelegateProtocol
- (void)didLoadAd:(STAAbstractAd*)ad {
    if (self.startioAd.adsDetails.count == 0) {
        NSError* error = [NSError errorWithDomain:@"StartAppSDK"
                                             code:STAErrorNoContent
                                         userInfo:@{NSLocalizedDescriptionKey:@"no fill"}];
        if (self.completionHandler) {
            self.completionHandler(nil, error);
        }
        NSLog(@"Start.io native ad is empty. (no fill)");
    }
    else {
        STANativeAdDetails* details = self.startioAd.adsDetails.firstObject;
        
        StartioAdmobNativeAd *nativeAd = [[StartioAdmobNativeAd alloc] initWithStartioNativeAd:details];
        if (self.completionHandler) {
            self.delegate = self.completionHandler(nativeAd, nil);
        }
        NSLog(@"Start.io native ad did load successfully.");
    }
}

- (void)failedLoadAd:(STAAbstractAd*)ad withError:(NSError*)error {
    if (self.completionHandler) {
        self.completionHandler(nil, error);
    }
    NSLog(@"Start.io native ad did fail to load with error \"%@\"", error.localizedDescription);
}

- (void)didSendImpressionForNativeAdDetails:(STANativeAdDetails *)nativeAdDetails {
    if ([self.delegate respondsToSelector:@selector(reportImpression)]) {
        [self.delegate reportImpression];
    }
    NSLog(@"Start.io native ad did send an impression.");
}

- (void)didClickNativeAdDetails:(STANativeAdDetails*)nativeAdDetails {
    if ([self.delegate respondsToSelector:@selector(reportClick)]) {
        [self.delegate reportClick];
    }
    NSLog(@"Start.io native ad was clicked.");
}

@end
