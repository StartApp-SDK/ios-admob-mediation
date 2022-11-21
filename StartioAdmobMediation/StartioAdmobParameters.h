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

@import Foundation;

@class STAAdPreferences;
@class STANativeAdPreferences;

NS_ASSUME_NONNULL_BEGIN

@interface StartioAdmobParameters : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithParametersJSON:(NSString *)paramsJSON;

@property (nonatomic, copy, nullable) NSString* appId;
@property (nonatomic, assign) BOOL testAdsEnabled;
@property (nonatomic, getter=isVideo) BOOL video;
@property (nonatomic, copy, nullable) NSString *adTag;
@property (nonatomic, assign) double minCPM;
@property (nonatomic, copy, nullable) NSString *nativePrimaryImageSize;
@property (nonatomic, copy, nullable) NSString *nativeSecondaryImageSize;

@property (nonatomic, readonly) STAAdPreferences *adPreferences;
@property (nonatomic, readonly) STANativeAdPreferences *nativeAdPreferences;

@end

NS_ASSUME_NONNULL_END
