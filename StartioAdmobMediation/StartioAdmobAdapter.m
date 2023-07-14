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

#import "StartioAdmobAdapter.h"
#import "StartioAdmobMediationConstants.h"
#import "StartioAdmobInterstitialAdLoader.h"
#import "StartioAdmobRewardedAdLoader.h"
#import "StartioAdmobBannerAdLoader.h"
#import "StartioAdmobNativeAdLoader.h"
#import "StartioAdmobParameters.h"

@import StartApp;

static NSString* const kSettingsParameterKey = @"parameter";

@interface StartioAdmobAdapter ()
@property (nonatomic, strong) StartioAdmobInterstitialAdLoader *interstitialAdLoader;
@property (nonatomic, strong) StartioAdmobRewardedAdLoader *rewardedAdLoader;
@property (nonatomic, strong) StartioAdmobBannerAdLoader *bannerAdLoader;
@property (nonatomic, strong) StartioAdmobNativeAdLoader *nativeAdLoader;
@end

@implementation StartioAdmobAdapter

+ (GADVersionNumber)adapterVersion {
    return [self GADVersionFromString:StartioAdmobAdapterVersion];
}

+ (GADVersionNumber)adSDKVersion {
    __block NSString *version = nil;
    [self executeBlockOnMainThread:^{
        version = [[STAStartAppSDK sharedInstance] version];
    }];
    return [self GADVersionFromString:version];
}

+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
    return nil;
}

+ (void)setUpWithConfiguration:(GADMediationServerConfiguration *)serverConfiguration completionHandler:(GADMediationAdapterSetUpCompletionBlock)completionHandler {
    if (serverConfiguration.credentials.count == 0) {
        completionHandler([NSError errorWithDomain:GADErrorDomain code:GADErrorMediationAdapterError userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"No mediation parameters received", @"")}]);
    }
    else {
        StartioAdmobParameters *mediationParameters = [[StartioAdmobParameters alloc] init];
        [mediationParameters readFromJSONString:serverConfiguration.credentials[0].settings[@"parameter"]];
        
        if (mediationParameters.appId.length != 0) {
            [self executeBlockOnMainThread:^{
                [self setupStartioSDKWithMediationParameters:mediationParameters testAdsEnabled:NO];
            }];
            completionHandler(nil);
        }
        else {
            completionHandler([NSError errorWithDomain:GADErrorDomain code:GADErrorMediationAdapterError userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"No Start.io AppID provided yet", @"")}]);
        }
    }
}

+ (void)setupStartioSDKWithMediationParameters:(StartioAdmobParameters *)mediationParameters testAdsEnabled:(BOOL)testAdsEnabled {
    STAStartAppSDK *sdk = [STAStartAppSDK sharedInstance];
    
    sdk.appID = mediationParameters.appId;
    [sdk enableMediationModeFor:@"AdMob" version:StartioAdmobAdapterVersion];
#ifdef DEBUG
    sdk.testAdsEnabled = YES;
#else
    sdk.testAdsEnabled = testAdsEnabled;
#endif
}

- (void)loadBannerForAdConfiguration:(nonnull GADMediationBannerAdConfiguration *)adConfiguration completionHandler:(nonnull GADMediationBannerLoadCompletionHandler)completionHandler {
    self.bannerAdLoader = [[StartioAdmobBannerAdLoader alloc] init];
    [self loadAdWithLoader:self.bannerAdLoader adConfiguration:adConfiguration completionHandler:completionHandler];
}

- (void)loadInterstitialForAdConfiguration:(nonnull GADMediationInterstitialAdConfiguration *)adConfiguration completionHandler:(nonnull GADMediationInterstitialLoadCompletionHandler)completionHandler {
    self.interstitialAdLoader = [[StartioAdmobInterstitialAdLoader alloc] init];
    [self loadAdWithLoader:self.interstitialAdLoader adConfiguration:adConfiguration completionHandler:completionHandler];
}

- (void)loadNativeAdForAdConfiguration:(nonnull GADMediationNativeAdConfiguration *)adConfiguration completionHandler:(nonnull GADMediationNativeLoadCompletionHandler)completionHandler {
    self.nativeAdLoader = [[StartioAdmobNativeAdLoader alloc] init];
    [self loadAdWithLoader:self.nativeAdLoader adConfiguration:adConfiguration completionHandler:completionHandler];
}

- (void)loadRewardedAdForAdConfiguration:(nonnull GADMediationRewardedAdConfiguration *)adConfiguration completionHandler:(nonnull GADMediationRewardedLoadCompletionHandler)completionHandler {
    self.rewardedAdLoader = [[StartioAdmobRewardedAdLoader alloc] init];
    [self loadAdWithLoader:self.rewardedAdLoader adConfiguration:adConfiguration completionHandler:completionHandler];
}

- (void)loadAdWithLoader:(nonnull StartioAdmobBaseAdLoader *)adLoader adConfiguration:(nonnull GADMediationAdConfiguration *)adConfiguration completionHandler:(nonnull id)completionHandler {
    [StartioAdmobAdapter executeBlockOnMainThread:^{
        StartioAdmobParameters *parameters = [[StartioAdmobParameters alloc] init];
        [parameters readFromJSONString:adConfiguration.credentials.settings[kSettingsParameterKey]];
        
        [StartioAdmobAdapter setupStartioSDKWithMediationParameters:parameters testAdsEnabled:adConfiguration.isTestRequest];
        [adLoader loadAdForAdConfiguration:adConfiguration startioAdmobParameters:parameters completionHandler:completionHandler];
    }];
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

+ (void)executeBlockOnMainThread:(void(^)(void))block {
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

@end

