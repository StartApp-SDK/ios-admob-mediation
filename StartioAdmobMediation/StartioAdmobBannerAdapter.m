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

#import "StartioAdmobBannerAdapter.h"
#import "StartioAdmobAdapterConfiguration.h"
#import "StartioAdmobParameters.h"
#import "StartioAdmobBannerAd.h"
#import "STAAdPreferences+AdMob.h"

@import GoogleMobileAds;

@interface StartioAdmobBannerAdapter () <STABannerDelegateProtocol>

@property (nonatomic, strong) UIView* fakeView;
@property (nonatomic, strong) STABannerView* bannerView;
@property (nonatomic, assign) BOOL isAutoSizeBanner;
@property (nonatomic, copy) GADMediationBannerLoadCompletionHandler completionHandler;
@property (nonatomic, weak) id<GADMediationBannerAdEventDelegate> delegate;

@end

@implementation StartioAdmobBannerAdapter

- (void)loadAdForAdConfiguration:(GADMediationBannerAdConfiguration *)adConfiguration
          startioAdmobParameters:(StartioAdmobParameters *)startioAdmobParameters
               completionHandler:(id)completionHandler {
    self.completionHandler = completionHandler;
    
    STAAdPreferences *adPrefs = [[STAAdPreferences alloc] initWithAdConfiguration:adConfiguration startioAdmobParameters:startioAdmobParameters];
    
    GADAdSize gadSize = adConfiguration.adSize;
    STABannerSize staSize;
    
    if ([self getInlineSize:&staSize forGADSize:gadSize]) {
        if (staSize.isAuto) {
            self.isAutoSizeBanner = YES;
            if (!CGSizeEqualToSize(gadSize.size, CGSizeZero)) {
                self.bannerView = [self createAutoSizeBannerWithContainerSize:CGSizeFromGADAdSize(gadSize) adPreferences:adPrefs];
            } else if (GADAdSizeIsFluid(gadSize)) {
                self.bannerView = [self createAutoSizeBannerWithContainerSize:adConfiguration.topViewController.view.frame.size adPreferences:adPrefs];
            }
        } else {
            self.bannerView = [[STABannerView alloc] initWithSize:staSize
                                                       autoOrigin:STAAdOrigin_Bottom
                                                    adPreferences:adPrefs
                                                     withDelegate:self];
            [self.bannerView loadAd];
        }
    } else { // called on forced recall when GADAdSizeIsFluid is true
        self.bannerView = [self createAutoSizeBannerWithContainerSize:CGSizeFromGADAdSize(gadSize) adPreferences:adPrefs];
    }
    
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

- (STABannerView*)createAutoSizeBannerWithContainerSize:(CGSize)containerSize adPreferences:(STAAdPreferences*)prefs {
    STABannerView* bannerView = [[STABannerView alloc] initWithSize:STA_AutoAdSize
                                                         autoOrigin:STAAdOrigin_Bottom
                                                      adPreferences:prefs
                                                       withDelegate:self];
    self.fakeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerSize.width, containerSize.height)];
    [self.fakeView addSubview:bannerView];
    return bannerView;
}

#pragma mark - STABannerDelegateProtocol
- (void)bannerAdIsReadyToDisplay:(STABannerViewBase *)banner {
    if (self.completionHandler) {
        StartioAdmobBannerAd *bannerAd = [[StartioAdmobBannerAd alloc] initWithSTABannerView:self.bannerView];
        self.delegate = self.completionHandler(bannerAd, nil);
    }
    NSLog(@"Start.io banner ad did load successfully.");
}

- (void)didDisplayBannerAd:(STABannerViewBase *)banner {
    if (self.isAutoSizeBanner && self.completionHandler) {
        StartioAdmobBannerAd *bannerAd = [[StartioAdmobBannerAd alloc] initWithSTABannerView:self.bannerView];
        self.delegate = self.completionHandler(bannerAd, nil);
    }
    NSLog(@"Start.io banner ad did display.");
}

- (void)failedLoadBannerAd:(STABannerView*)banner withError:(NSError*)error {
    if (self.completionHandler) {
        self.completionHandler(nil, error);
    }
    NSLog(@"Start.io banner ad did fail to load with error \"%@\"", error.localizedDescription);
}

- (void)didSendImpressionForBannerAd:(STABannerViewBase *)banner {
    if ([self.delegate respondsToSelector:@selector(reportImpression)]) {
        [self.delegate reportImpression];
    }
    NSLog(@"Start.io banner ad did report impression.");
}

- (void)didClickBannerAd:(STABannerView*)banner {
    if ([self.delegate respondsToSelector:@selector(reportClick)]) {
        [self.delegate reportClick];
    }
    NSLog(@"Start.io banner ad was clicked.");
}

@end
