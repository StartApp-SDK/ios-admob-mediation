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

#import "StartioAdmobInterstitialAdLoader.h"
#import "STAAdPreferences+AdMob.h"

@interface StartioAdmobInterstitialAdLoader ()

@property (nonatomic, strong) STAStartAppAd* startioAd;

@end

@implementation StartioAdmobInterstitialAdLoader

- (void)performLoadWithAdConfiguration:(GADMediationInterstitialAdConfiguration *)adConfiguration
                startioAdmobParameters:(StartioAdmobParameters *)startioAdmobParameters {
    self.startioAd = [[STAStartAppAd alloc] init];
    
    STAAdPreferences *adPrefs = [[STAAdPreferences alloc] initWithAdConfiguration:adConfiguration startioAdmobParameters:startioAdmobParameters];
    
    if (startioAdmobParameters.isVideo) {
        [self.startioAd loadVideoAdWithDelegate:self withAdPreferences:adPrefs];
    }
    else {
        [self.startioAd loadAdWithDelegate:self withAdPreferences:adPrefs];
    }
}

- (NSString *)adNameForLog {
    return @"interstitial";
}

#pragma mark STADelegateProtocol
- (void)didLoadAd:(STAAbstractAd*)ad {
    if (self.completionHandler) {
        StartioAdmobInterstitialAd *interstitialAd = [[StartioAdmobInterstitialAd alloc] initWithStartioAd:self.startioAd];
        self.delegate = self.completionHandler(interstitialAd, nil);
        self.completionHandler = nil;
    }
    StartioLog(@"Start.io %@ ad did load successfully.", self.adNameForLog);
}

- (void)failedLoadAd:(STAAbstractAd*)ad withError:(NSError*)error {
    if (self.completionHandler) {
        self.completionHandler(nil, error);
        self.completionHandler = nil;
    }
    StartioLog(@"Start.io %@ ad did fail to load with error \"%@\"", self.adNameForLog, error.localizedDescription);
}

- (void)didShowAd:(STAAbstractAd*)ad {
    if ([self.delegate respondsToSelector:@selector(willPresentFullScreenView)]) {
        [self.delegate willPresentFullScreenView];
    }
    StartioLog(@"Start.io %@ ad did show.", self.adNameForLog);
}

- (void)didSendImpression:(STAAbstractAd *)ad {
    if ([self.delegate respondsToSelector:@selector(reportImpression)]) {
        [self.delegate reportImpression];
    }
    StartioLog(@"Start.io %@ ad did send impression.", self.adNameForLog);
}

- (void)failedShowAd:(STAAbstractAd*)ad withError:(NSError*)error {
    if ([self.delegate respondsToSelector:@selector(didFailToPresentWithError:)]) {
        [self.delegate didFailToPresentWithError:error];
    }
    StartioLog(@"Start.io %@ did fail to show, %@", self.adNameForLog, error.localizedDescription);
}

- (void)didCloseAd:(STAAbstractAd*)ad {
    StartioLog(@"Start.io %@ did dismiss.", self.adNameForLog);
    if ([self.delegate respondsToSelector:@selector(willDismissFullScreenView)]) {
        [self.delegate willDismissFullScreenView];
    }
    if ([self.delegate respondsToSelector:@selector(didDismissFullScreenView)]) {
        [self.delegate didDismissFullScreenView];
    }
}

- (void)didClickAd:(STAAbstractAd*)ad {
    if ([self.delegate respondsToSelector:@selector(reportClick)]) {
        [self.delegate reportClick];
    }
    StartioLog(@"Start.io %@ ad was clicked.", self.adNameForLog);
}
@end

#pragma mark - StartioAdmobInterstitialAd
@interface StartioAdmobInterstitialAd()
@property (nonatomic, strong) STAStartAppAd *startioAd;
@end

@implementation StartioAdmobInterstitialAd

- (instancetype)initWithStartioAd:(STAStartAppAd *)ad {
    self = [super init];
    if (self) {
        _startioAd = ad;
    }
    return self;
}

- (void)presentFromViewController:(UIViewController *)viewController {
    [self.startioAd showAd];
}

@end
