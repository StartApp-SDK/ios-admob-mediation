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

#import "StartioAdmobRewardedAdapter.h"
#import "STAAdPreferences+AdMob.h"
#import "StartioAdmobRewardedAd.h"

@interface StartioAdmobRewardedAdapter ()

@property (nonatomic, strong) STAStartAppAd* startioAd;
@property (nonatomic, copy) GADMediationRewardedLoadCompletionHandler completionHandler;
@property (nonatomic, weak) id<GADMediationRewardedAdEventDelegate> delegate;

@end

@implementation StartioAdmobRewardedAdapter
- (void)loadAdForAdConfiguration:(GADMediationRewardedAdConfiguration *)adConfiguration
          startioAdmobParameters:(StartioAdmobParameters *)startioAdmobParameters
               completionHandler:(id)completionHandler {
    self.completionHandler = completionHandler;
    
    self.startioAd = [[STAStartAppAd alloc] init];
    
    STANativeAdPreferences *adPrefs = [[STANativeAdPreferences alloc] initWithAdConfiguration:adConfiguration startioAdmobParameters:startioAdmobParameters];
    
    [self.startioAd loadRewardedVideoAdWithDelegate:self withAdPreferences:adPrefs];
}

- (NSString *)adNameForLog {
    return @"rewarded";
}

#pragma mark - STADelegateProtocol
- (void)didLoadAd:(STAAbstractAd*)ad {
    if (self.completionHandler) {
        StartioAdmobRewardedAd *rewardedAd = [[StartioAdmobRewardedAd alloc] initWithStartioAd:self.startioAd];
        self.delegate = self.completionHandler(rewardedAd, nil);
    }
    NSLog(@"Start.io %@ ad did load successfully.", self.adNameForLog);
}

- (void)didShowAd:(STAAbstractAd*)ad {
    [super didShowAd:ad];
    if ([self.delegate respondsToSelector:@selector(didStartVideo)]) {
        [self.delegate didStartVideo];
    }
}

- (void)didCompleteVideo:(STAAbstractAd *)ad {
    if ([self.delegate respondsToSelector:@selector(didEndVideo)]) {
        [self.delegate didEndVideo];
    }
    if ([self.delegate respondsToSelector:@selector(didRewardUser)]) {
        [self.delegate didRewardUser];
    }
    NSLog(@"Start.io %@ ad did reward user.", self.adNameForLog);
}

@end
