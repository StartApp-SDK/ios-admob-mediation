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

#import "StartioAdmobNativeAdLoader.h"
#import "STAAdPreferences+AdMob.h"

@interface StartioAdmobNativeAdLoader () <STADelegateProtocol>

@property (nonatomic, strong) STAStartAppNativeAd* startioAd;

@end

@implementation StartioAdmobNativeAdLoader

- (void)performLoadWithAdConfiguration:(GADMediationNativeAdConfiguration *)adConfiguration
                startioAdmobParameters:(StartioAdmobParameters *)startioAdmobParameters {
    
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

#pragma mark STADelegateProtocol
- (void)didLoadAd:(STAAbstractAd*)ad {
    if (self.startioAd.adsDetails.count == 0) {
        NSError* error = [NSError errorWithDomain:@"StartAppSDK"
                                             code:STAErrorNoContent
                                         userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"No fill", @"")}];
        if (self.completionHandler) {
            self.completionHandler(nil, error);
        }
        StartioLog(@"Start.io native ad is empty. (no fill)");
    }
    else {
        STANativeAdDetails* details = self.startioAd.adsDetails.firstObject;
        
        StartioAdmobNativeAd *nativeAd = [[StartioAdmobNativeAd alloc] initWithStartioNativeAd:details];
        if (self.completionHandler) {
            self.delegate = self.completionHandler(nativeAd, nil);
        }
        StartioLog(@"Start.io native ad did load successfully.");
    }
}

- (void)failedLoadAd:(STAAbstractAd*)ad withError:(NSError*)error {
    if (self.completionHandler) {
        self.completionHandler(nil, error);
    }
    StartioLog(@"Start.io native ad did fail to load with error \"%@\"", error.localizedDescription);
}

- (void)didSendImpressionForNativeAdDetails:(STANativeAdDetails *)nativeAdDetails {
    if ([self.delegate respondsToSelector:@selector(reportImpression)]) {
        [self.delegate reportImpression];
    }
    StartioLog(@"Start.io native ad did send an impression.");
}

- (void)didClickNativeAdDetails:(STANativeAdDetails*)nativeAdDetails {
    if ([self.delegate respondsToSelector:@selector(reportClick)]) {
        [self.delegate reportClick];
    }
    StartioLog(@"Start.io native ad was clicked.");
}

@end

#pragma mark - StartioAdmobNativeAd
@interface StartioAdmobNativeAd ()

@property (nonatomic) STANativeAdDetails* nativeAd;
@property (nonatomic, copy) NSArray<GADNativeAdImage*>* mappedImages;
@property (nonatomic) GADNativeAdImage* mappedIcon;
@property (nonatomic, nullable) UIImageView* adChoicesImage;

@end

@implementation StartioAdmobNativeAd

- (instancetype)initWithStartioNativeAd:(STANativeAdDetails*)nativeAd {
    if (self = [super init]) {
        _nativeAd = nativeAd;
        
        if (nativeAd.imageBitmap) {
            _mappedImages = @[[[GADNativeAdImage alloc] initWithImage:nativeAd.imageBitmap]];
        } else {
            NSURL* imageUrl = [[NSURL alloc] initFileURLWithPath:nativeAd.imageUrl];
            _mappedImages = @[[[GADNativeAdImage alloc] initWithURL:imageUrl scale:1]];
        }
        if (nativeAd.secondaryImageBitmap) {
            _mappedIcon = [[GADNativeAdImage alloc] initWithImage:nativeAd.secondaryImageBitmap];
        } else {
            NSURL* imageUrl = [[NSURL alloc] initFileURLWithPath:nativeAd.secondaryImageUrl];
            _mappedIcon = [[GADNativeAdImage alloc] initWithURL:imageUrl scale:1];
        }
        _adChoicesImage = [[UIImageView alloc] initWithImage:self.nativeAd.policyImage];
    }
    return self;
}

#pragma mark GADMediationNativeAd methods
- (BOOL)handlesUserClicks {
    return YES;
}

- (BOOL)handlesUserImpressions {
    return YES;
}

#pragma mark GADMediatedUnifiedNativeAd methods

- (nullable NSString*)advertiser {
    return nil;
}

- (nullable NSString*)headline {
    return self.nativeAd.title;
}

- (nullable NSArray*)images {
    return self.mappedImages;
}

- (nullable NSString*)body {
    return self.nativeAd.description;
}

- (nullable GADNativeAdImage*)icon {
    return self.mappedIcon;
}

- (nullable NSString*)callToAction {
    return self.nativeAd.callToAction;
}

- (nullable NSDecimalNumber*)starRating {
    if (self.nativeAd.rating) {
        return [NSDecimalNumber decimalNumberWithDecimal:self.nativeAd.rating.decimalValue];
    }
    return nil;
}

- (nullable NSString*)store {
    return nil;
}

- (nullable NSString*)price {
    return nil;
}

- (nullable NSDictionary*)extraAssets {
    return nil;
}

- (nullable UIView*)adChoicesView {
    return self.adChoicesImage;
}

- (BOOL)hasVideoContent {
    return self.nativeAd.isVideo;
}

- (nullable UIView*)mediaView {
    return self.nativeAd.mediaView;
}

- (CGFloat)mediaContentAspectRatio {
    return self.nativeAd.videoAspectRatio;
}

- (void)didRenderInView:(UIView*)view
    clickableAssetViews:(NSDictionary<GADNativeAssetIdentifier, UIView*>*)clickableAssetViews
 nonclickableAssetViews:(NSDictionary<GADNativeAssetIdentifier, UIView*>*)nonclickableAssetViews
         viewController:(UIViewController*)viewController {
    
    NSUInteger amount = 0;
    NSArray<UIView*>* clickableViews = clickableAssetViews.allValues;
    for (UIView* view in clickableViews) {
        if (!view.userInteractionEnabled) {
            break;
        }
        ++amount;
    }
    if (amount == clickableViews.count) {
        [self.nativeAd registerViewForImpression:view andViewsForClick:clickableAssetViews.allValues];
    } else {
        [self.nativeAd registerViewForImpressionAndClick:view];
    }
}


- (void)didUntrackView:(UIView*)view {
    [self.nativeAd unregisterViews];
}

@end
