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

#import "STANativeAdPreferences+AdMob.h"
#import "STAAdPreferences+AdMob.h"

@implementation STANativeAdPreferences (AdMob)

- (instancetype)initWithAdConfiguration:(GADMediationAdConfiguration *)adConfiguration startioAdmobParameters:(StartioAdmobParameters *)parameters {
    self = [super initWithAdConfiguration:adConfiguration startioAdmobParameters:parameters];
    if (self) {
        self.primaryImageSize = [self nativeAdBitmapSizeFromString:parameters.nativePrimaryImageSize];
        self.secondaryImageSize = [self nativeAdBitmapSizeFromString:parameters.nativeSecondaryImageSize];
    }
    return self;
}

- (STANativeAdBitmapSize)nativeAdBitmapSizeFromString:(NSString*)bitmapSizeString {
    if ([bitmapSizeString isEqualToString:@"SIZE72X72"]) {
        return SIZE_72X72;
    } else if ([bitmapSizeString isEqualToString:@"SIZE100X100"]) {
        return SIZE_100X100;
    } else if ([bitmapSizeString isEqualToString:@"SIZE150X150"]) {
        return SIZE_150X150;
    } else if ([bitmapSizeString isEqualToString:@"SIZE340X340"]) {
        return SIZE_340X340;
    } else if ([bitmapSizeString isEqualToString:@"SIZE1200X628"]) {
        return SIZE_1200X628;
    }
    return SIZE_150X150;
}

@end
