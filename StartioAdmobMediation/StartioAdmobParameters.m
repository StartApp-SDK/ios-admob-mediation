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

#import "StartioAdmobParameters.h"
@import StartApp;

static NSString* const kAppId = @"startioAppId";
static NSString* const kInterstitialMode = @"interstitialMode";
static NSString* const kAdTag = @"adTag";
static NSString* const kMinCPM = @"minCPM";
static NSString* const kMuteVideo = @"muteVideo";
static NSString* const kNativeImageSize = @"nativeImageSize";
static NSString* const kNativeSecondaryImageSize = @"nativeSecondaryImageSize";

@implementation StartioAdmobParameters

- (instancetype)initWithParametersJSON:(NSString *)paramsJSON {
    if (self = [self init]) {
        [self parseParams:paramsJSON];
    }
    return self;
}

- (void)parseParams:(nullable NSString*)params {
    if (params == nil) {
        return;
    }
    
    NSData* jsonData = [params dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error = nil;
    NSDictionary* jsonMap = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error || !jsonMap) {
        return;
    }
    
    if (jsonMap[kAppId]) {
        self.appId = jsonMap[kAppId];
    }
    
    if (jsonMap[kInterstitialMode]) {
        self.video = [jsonMap[kInterstitialMode] isEqualToString:@"VIDEO"];
    }

    if (jsonMap[kAdTag]) {
        self.adTag = jsonMap[kAdTag];
    }

    if (jsonMap[kMinCPM]) {
        self.minCPM = [jsonMap[kMinCPM] doubleValue];
    }

    if (jsonMap[kMuteVideo]) {
        // TODO: needs to implement in the sdk STAAdPreferences
        // self.prefs.muteVideo = [jsonMap[kMuteVideo] boolValue];
    }

    if (jsonMap[kNativeImageSize]) {
        self.nativePrimaryImageSize = jsonMap[kNativeImageSize];
    }

    if (jsonMap[kNativeSecondaryImageSize]) {
        self.nativeSecondaryImageSize = jsonMap[kNativeSecondaryImageSize];
    }
}

@end
