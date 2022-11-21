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

#import "StartioAdmobCustomEvent.h"
#import "StartioAdmobMediationConstants.h"
#import "StartioAdmobInterstitialAdapter.h"
#import "StartioAdmobRewardedAdapter.h"
#import "StartioAdmobBannerAdapter.h"
#import "StartioAdmobNativeAdapter.h"
#import "StartioAdmobParameters.h"

@import StartApp;

static NSString* const kSettingsParameterKey = @"parameter";

@interface StartioAdmobCustomEvent ()
@property (nonatomic, strong) StartioAdmobInterstitialAdapter *interstitialAdapter;
@property (nonatomic, strong) StartioAdmobRewardedAdapter *rewardedAdapter;
@property (nonatomic, strong) StartioAdmobBannerAdapter *bannerAdapter;
@property (nonatomic, strong) StartioAdmobNativeAdapter *nativeAdapter;
@end

@implementation StartioAdmobCustomEvent

+ (GADVersionNumber)adapterVersion {
    return [self GADVersionFromString:StartioAdmobAdapterVersion];
}

+ (GADVersionNumber)adSDKVersion {
    __block NSString *version = nil;
    if ([NSThread isMainThread]) {
        version = [[STAStartAppSDK sharedInstance] version];
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            version = [[STAStartAppSDK sharedInstance] version];
        });
    }
    return [self GADVersionFromString:version];
}

+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
    return nil;
}

+ (void)setUpWithConfiguration:(GADMediationServerConfiguration *)serverConfiguration completionHandler:(GADMediationAdapterSetUpCompletionBlock)completionHandler {
    if (serverConfiguration.credentials.count == 0) {
        completionHandler([NSError errorWithDomain:GADErrorDomain code:GADErrorMediationAdapterError userInfo:@{NSLocalizedDescriptionKey : @"No mdiation parameters received"}]);
    }
    else {
        StartioAdmobParameters *mediationParameters = [[StartioAdmobParameters alloc] initWithParametersJSON:serverConfiguration.credentials[0].settings[@"parameter"]];
        if (mediationParameters.appId.length != 0) {
            if ([NSThread isMainThread]) {
                [self setupStartioSDKWithMediationParameters:mediationParameters testAdsEnabled:NO];
                completionHandler(nil);
            }
            else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self setupStartioSDKWithMediationParameters:mediationParameters testAdsEnabled:NO];
                });
                completionHandler(nil);
            }
        }
        else {
            completionHandler([NSError errorWithDomain:GADErrorDomain code:GADErrorMediationAdapterError userInfo:@{NSLocalizedDescriptionKey : @"No Start.io AppID provided yet"}]);
        }
    }
}

+ (void)setupStartioSDKWithMediationParameters:(StartioAdmobParameters *)mediationParameters testAdsEnabled:(BOOL)testAdsEnabled {
    STAStartAppSDK *sdk = [STAStartAppSDK sharedInstance];
    
    sdk.appID = mediationParameters.appId;
    sdk.returnAdEnabled = NO;
    sdk.consentDialogEnabled = NO;
    [sdk addWrapperWithName:@"AdMob" version:StartioAdmobAdapterVersion];
    sdk.testAdsEnabled = YES;
#ifdef DEBUG
    sdk.testAdsEnabled = YES;
#else
    sdk.testAdsEnabled = testAdsEnabled;
#endif
}

- (void)loadBannerForAdConfiguration:(nonnull GADMediationBannerAdConfiguration *)adConfiguration completionHandler:(nonnull GADMediationBannerLoadCompletionHandler)completionHandler {
    self.bannerAdapter = [[StartioAdmobBannerAdapter alloc] init];
    [self loadAdForAdapter:self.bannerAdapter adConfiguration:adConfiguration completionHandler:completionHandler];
}

- (void)loadInterstitialForAdConfiguration:(nonnull GADMediationInterstitialAdConfiguration *)adConfiguration completionHandler:(nonnull GADMediationInterstitialLoadCompletionHandler)completionHandler {
    self.interstitialAdapter = [[StartioAdmobInterstitialAdapter alloc] init];
    [self loadAdForAdapter:self.interstitialAdapter adConfiguration:adConfiguration completionHandler:completionHandler];
}

- (void)loadNativeAdForAdConfiguration:(nonnull GADMediationNativeAdConfiguration *)adConfiguration completionHandler:(nonnull GADMediationNativeLoadCompletionHandler)completionHandler {
    self.nativeAdapter = [[StartioAdmobNativeAdapter alloc] init];
    [self loadAdForAdapter:self.nativeAdapter adConfiguration:adConfiguration completionHandler:completionHandler];
}

- (void)loadRewardedAdForAdConfiguration:(nonnull GADMediationRewardedAdConfiguration *)adConfiguration completionHandler:(nonnull GADMediationRewardedLoadCompletionHandler)completionHandler {
    self.rewardedAdapter = [[StartioAdmobRewardedAdapter alloc] init];
    [self loadAdForAdapter:self.rewardedAdapter adConfiguration:adConfiguration completionHandler:completionHandler];
}

- (void)loadAdForAdapter:(nonnull id<StartioAdmobAdAdapter>)adapter adConfiguration:(nonnull GADMediationAdConfiguration *)adConfiguration completionHandler:(nonnull id)completionHandler {
    StartioAdmobParameters *parameters = [[StartioAdmobParameters alloc] initWithParametersJSON:adConfiguration.credentials.settings[kSettingsParameterKey]];
    [StartioAdmobCustomEvent setupStartioSDKWithMediationParameters:parameters testAdsEnabled:adConfiguration.isTestRequest];
    [adapter loadAdForAdConfiguration:adConfiguration startioAdmobParameters:parameters completionHandler:completionHandler];
}

#pragma mark - Helper methods
+ (GADVersionNumber)GADVersionFromString:(NSString *)versionString {
    NSArray<NSString *> *versionNumberComponents = [versionString componentsSeparatedByString:@"."];
    GADVersionNumber version;
    version.majorVersion = 0;
    version.minorVersion = 0;
    version.patchVersion = 0;
    
    if (versionNumberComponents.count > 0) {
        version.majorVersion = versionNumberComponents[0].integerValue;
    }
    if (versionNumberComponents.count > 1) {
        version.minorVersion = versionNumberComponents[1].integerValue;
    }
    if (versionNumberComponents.count > 2) {
        version.patchVersion = versionNumberComponents[2].integerValue;
    }
    
    return version;
}

@end

