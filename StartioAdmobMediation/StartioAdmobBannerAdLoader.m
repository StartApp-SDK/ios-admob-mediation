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

#import "StartioAdmobBannerAdLoader.h"
#import "STAAdPreferences+AdMob.h"

@interface StartioAdmobBannerAdLoader () <STABannerDelegateProtocol>

@property (nonatomic, strong) STABannerLoader *bannerLoader;

@end

@implementation StartioAdmobBannerAdLoader

- (id<GADMediationBannerAdEventDelegate>)delegate {
    return (id<GADMediationBannerAdEventDelegate>)[super delegate];
}

- (void)performLoadWithAdConfiguration:(GADMediationBannerAdConfiguration *)adConfiguration
                startioAdmobParameters:(StartioAdmobParameters *)startioAdmobParameters {
    STAAdPreferences *adPrefs = [[STAAdPreferences alloc] initWithAdConfiguration:adConfiguration startioAdmobParameters:startioAdmobParameters];
    
    GADAdSize gadSize = adConfiguration.adSize;
    STABannerSize staSize;
    STABannerSize staSizeToLoad;
    if ([self getInlineSize:&staSize forGADSize:gadSize]) {
        if (staSize.isAuto) {
            staSizeToLoad.isAuto = YES;
            if (!CGSizeEqualToSize(gadSize.size, CGSizeZero)) {
                staSizeToLoad.size = CGSizeFromGADAdSize(gadSize);
            }
            else if (GADAdSizeIsFluid(gadSize)) {
                staSizeToLoad.size = adConfiguration.topViewController.view.bounds.size;
            }
        }
        else {
            staSizeToLoad = staSize;
        }
    }
    else { // called on forced recall when GADAdSizeIsFluid is true
        staSizeToLoad.isAuto = YES;
        staSizeToLoad.size = CGSizeFromGADAdSize(gadSize);
    }
    
    self.bannerLoader = [[STABannerLoader alloc] initWithSize:staSizeToLoad adPreferences:adPrefs];
    __weak typeof(self)weakSelf = self;
    [self.bannerLoader loadAdWithCompletion:^(STABannerViewCreator *creator, NSError *error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (error) {
            if (strongSelf.completionHandler) {
                strongSelf.completionHandler(nil, error);
            }
        }
        else {
            StartioAdmobBannerAd *bannerAd = [[StartioAdmobBannerAd alloc] initWithSTABannerViewCreator:creator];
            if (strongSelf.completionHandler) {
                bannerAd.delegate = strongSelf.completionHandler(bannerAd, nil);
            }
        }
        strongSelf.completionHandler = nil;
    }];
}

- (BOOL)getInlineSize:(STABannerSize*)size forGADSize:(GADAdSize)gadSize {
    const char* objcType = @encode(STABannerSize);
    NSArray<NSValue*>* staSizes = @[
        [NSValue value:&STA_PortraitAdSize_320x50 withObjCType:objcType],
        [NSValue value:&STA_LandscapeAdSize_480x50 withObjCType:objcType],
        [NSValue value:&STA_LandscapeAdSize_568x50 withObjCType:objcType],
        [NSValue value:&STA_PortraitAdSize_768x90 withObjCType:objcType],
        [NSValue value:&STA_LandscapeAdSize_1024x90 withObjCType:objcType],
        [NSValue value:&STA_MRecAdSize_300x250 withObjCType:objcType],
        [NSValue value:&STA_CoverAdSize withObjCType:objcType]
    ];

    BOOL isFullWidth = gadSize.size.width == UIScreen.mainScreen.bounds.size.width;
    BOOL isPadHeight90 = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad && gadSize.size.height == 90;
    BOOL isPhoneHeight50 = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && gadSize.size.height == 50;
    BOOL isFullWidthDefinedHeight = isFullWidth && (isPadHeight90 || isPhoneHeight50);
    BOOL isEmptySize = CGSizeEqualToSize(gadSize.size, CGSizeZero);
    if (isFullWidthDefinedHeight || isEmptySize) {
        *size = STA_AutoAdSize;
        return YES;
    } else {
        for (NSValue* valSize in staSizes) {
            [valSize getValue:size];
            if (CGSizeEqualToSize(CGSizeFromGADAdSize(gadSize), size->size)) {
                return YES;
            }
        }
    }
    return NO;
}

@end

#pragma mark - StartioAdmobBannerAd
@interface StartioAdmobBannerAd()<STABannerDelegateProtocol>
@property (nonatomic, strong) STABannerViewCreator *bannerViewCreator;
@property (nonatomic, strong) STABannerView* bannerView;
@end

@implementation StartioAdmobBannerAd
- (instancetype)initWithSTABannerViewCreator:(STABannerViewCreator *)bannerViewCreator {
    self = [super init];
    if (self) {
        _bannerViewCreator = bannerViewCreator;
    }
    return self;
}

- (UIView *)view {
    if (self.bannerView == nil) {
        self.bannerView = (STABannerView *)[self.bannerViewCreator createBannerViewForDelegate:self supportAutolayout:NO];
    }
    return self.bannerView;
}

#pragma mark STABannerDelegateProtocol

- (void)didSendImpressionForBannerAd:(STABannerViewBase *)banner {
    if ([self.delegate respondsToSelector:@selector(reportImpression)]) {
        [self.delegate reportImpression];
    }
    StartioLog(@"Start.io banner ad did report impression.");
}

- (void)didClickBannerAd:(STABannerView*)banner {
    if ([self.delegate respondsToSelector:@selector(reportClick)]) {
        [self.delegate reportClick];
    }
    StartioLog(@"Start.io banner ad was clicked.");
}
@end
