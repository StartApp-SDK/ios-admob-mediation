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

#import "StartioAdmobInterstitialAd.h"

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

- (void)presentFromViewController:(nonnull UIViewController *)viewController {
    [self.startioAd showAd];
}

@end
