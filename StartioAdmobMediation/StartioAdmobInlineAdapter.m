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

#import "StartioAdmobInlineAdapter.h"
#import "StartioAdmobAdapterConfiguration.h"
#import "StartioAdmobExtras.h"

@import GoogleMobileAds;
#import <StartApp/StartApp.h>


@interface StartioAdmobInlineAdapter () <GADCustomEventBanner, STABannerDelegateProtocol>

@property (nonatomic, nullable) UIView* fakeView;
@property (nonatomic, nullable) STABannerView* inlineView;

@end

@implementation StartioAdmobInlineAdapter

@synthesize delegate;

- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(nullable NSString*)serverParameter
                  label:(nullable NSString*)serverLabel
                request:(nonnull GADCustomEventRequest*)request {
    
    NSLog(@"Attempt to load Start.io inline ad.");
    StartioAdmobExtras* extras = request.userHasLocation
        ? [[StartioAdmobExtras alloc] initWithJson:serverParameter lat:request.userLatitude lon:request.userLongitude]
        : [[StartioAdmobExtras alloc] initWithJson:serverParameter];
    [StartioAdmobAdapterConfiguration initializeSdkIfNecessary:extras.appId withTestAds:request.isTesting];
    
    STABannerSize inlineSize;
    if ([self getInlineSize:&inlineSize forGADSize:adSize]) {
        if (inlineSize.isAuto) {
            if (!CGSizeEqualToSize(adSize.size, CGSizeZero)) {
                self.inlineView = [self createInlineWithSize:inlineSize gadSize:CGSizeFromGADAdSize(adSize) prefs:extras.prefs];
            } else if (GADAdSizeIsFluid(adSize)) {
                [self forceRecallRequestBannerAdWithCalculatedSize];
            }
        } else {
            self.inlineView = [[STABannerView alloc] initWithSize:inlineSize
                                                       autoOrigin:STAAdOrigin_Bottom
                                                    adPreferences:extras.prefs
                                                     withDelegate:self];
            [self.inlineView loadAd];
        }
    } else { // called on forced recall when GADAdSizeIsFluid is true
        self.inlineView = [self createInlineWithSize:inlineSize gadSize:CGSizeFromGADAdSize(adSize) prefs:extras.prefs];
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

- (STABannerView*)createInlineWithSize:(STABannerSize)size gadSize:(CGSize)gadSize prefs:(STAAdPreferences*)prefs {
    STABannerView* inlineView = [[STABannerView alloc] initWithSize:size
                                                         autoOrigin:STAAdOrigin_Bottom
                                                      adPreferences:prefs
                                                       withDelegate:self];
    self.fakeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, gadSize.width, gadSize.height)];
    [self.fakeView addSubview:inlineView];
    return inlineView;
}

- (void)forceRecallRequestBannerAdWithCalculatedSize {
    // we just need to return any stub view
    [self.delegate customEventBanner:self didReceiveAd:[[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds]];
}

#pragma mark - STABannerDelegateProtocol

- (void)bannerAdIsReadyToDisplay:(STABannerView*)banner {
    [self.delegate customEventBanner:self didReceiveAd:banner];
    NSLog(@"Start.io inline ad has been loaded successfully.");
}

- (void)didDisplayBannerAd:(STABannerView*)banner {
    [self.delegate customEventBanner:self didReceiveAd:banner];
    [self.delegate customEventBannerWillPresentModal:self];
    NSLog(@"Start.io inline ad has been shown.");
}

- (void)failedLoadBannerAd:(STABannerView*)banner withError:(NSError*)error {
    [self.delegate customEventBanner:self didFailAd:error];
    NSLog(@"Start.io inline ad is failed to load, %@", error.localizedDescription);
}

- (void)didClickBannerAd:(STABannerView*)banner {
    [self.delegate customEventBannerWasClicked:self];
    NSLog(@"Start.io inline ad was clicked.");
}

- (void)didCloseBannerInAppStore:(STABannerView*)banner {
    [self.delegate customEventBannerWillDismissModal:self];
    [self.delegate customEventBannerDidDismissModal:self];
    NSLog(@"Start.io inline ad is dismissed.");
}

@end
