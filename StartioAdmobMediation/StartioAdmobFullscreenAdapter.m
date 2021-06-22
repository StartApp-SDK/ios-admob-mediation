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

#import "StartioAdmobFullscreenAdapter.h"
#import "StartioAdmobExtras.h"
#import "StartioAdmobAdapterConfiguration.h"

@import GoogleMobileAds;
#import <StartApp/StartApp.h>


@interface StartioAdmobFullscreenAdapter () <GADCustomEventInterstitial, STADelegateProtocol>

@property (nonatomic, nullable) STAStartAppAd* startioAd;

@end

@implementation StartioAdmobFullscreenAdapter

@synthesize delegate;

- (void)requestInterstitialAdWithParameter:(nullable NSString*)serverParameter
                                     label:(nullable NSString*)serverLabel
                                   request:(nonnull GADCustomEventRequest*)request {
    
    NSLog(@"Attempt to load Start.io fullscreen ad.");
    StartioAdmobExtras* extras = request.userHasLocation
        ? [[StartioAdmobExtras alloc] initWithJson:serverParameter lat:request.userLatitude lon:request.userLongitude]
        : [[StartioAdmobExtras alloc] initWithJson:serverParameter];
    [StartioAdmobAdapterConfiguration initializeSdkIfNecessary:extras.appId withTestAds:request.isTesting];
    
    self.startioAd = [[STAStartAppAd alloc] init];
    [self loadTargedAd:extras];
}

- (void)presentFromRootViewController:(nonnull UIViewController*)rootViewController {
    NSLog(@"Attempt to show Start.io fullscreen ad.");
    if (self.startioAd.isReady) {
        [self.startioAd showAd];
    } else {
        NSError* error = [NSError errorWithDomain:@"GADMediationAdapterStartioAdNetwork"
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey:@"Fullscreen ad is not ready."}];
        [self.delegate customEventInterstitial:self didFailAd:error];
    }
}

- (void)loadTargedAd:(StartioAdmobExtras*)extras {
    if (extras.isVideo) {
        [self.startioAd loadVideoAdWithDelegate:self withAdPreferences:extras.prefs];
    } else {
        [self.startioAd loadAdWithDelegate:self withAdPreferences:extras.prefs];
    }
}

#pragma mark - STADelegateProtocol

- (void)didLoadAd:(STAAbstractAd*)ad {
    [self.delegate customEventInterstitialDidReceiveAd:self];
    NSLog(@"Start.io fullscreen ad has been loaded successfully.");
}

- (void)failedLoadAd:(STAAbstractAd*)ad withError:(NSError*)error {
    [self.delegate customEventInterstitial:self didFailAd:error];
    NSLog(@"Start.io fullscreen ad is failed to load, %@", error.localizedDescription);
}

- (void)didShowAd:(STAAbstractAd*)ad {
    [self.delegate customEventInterstitialWillPresent:self];
    NSLog(@"Start.io fullscreen ad has been shown.");
}

- (void)failedShowAd:(STAAbstractAd*)ad withError:(NSError*)error {
    [self.delegate customEventInterstitial:self didFailAd:error];
    NSLog(@"Start.io fullscreen ad is failed to show, %@", error.localizedDescription);
}

- (void)didCloseAd:(STAAbstractAd*)ad {
    [self.delegate customEventInterstitialWillDismiss:self];
    [self.delegate customEventInterstitialDidDismiss:self];
    NSLog(@"Start.io fullscreen ad is dismissed.");
}

- (void)didClickAd:(STAAbstractAd*)ad {
    [self.delegate customEventInterstitialWasClicked:self];
    NSLog(@"Start.io fullscreen ad was clicked.");
}

@end
