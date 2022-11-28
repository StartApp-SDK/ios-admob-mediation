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
static NSString* const kNativeImageSize = @"nativeImageSize";
static NSString* const kNativeSecondaryImageSize = @"nativeSecondaryImageSize";

@interface StartioAdmobParameters()
@property (nonatomic, copy, nullable) NSString* appId;
@property (nonatomic, getter=isVideo) BOOL video;
@property (nonatomic, copy, nullable) NSString *adTag;
@property (nonatomic, assign) double minCPM;
@property (nonatomic, copy, nullable) NSString *nativePrimaryImageSize;
@property (nonatomic, copy, nullable) NSString *nativeSecondaryImageSize;
@end

@implementation StartioAdmobParameters

- (void)readFromJSONString:(nullable NSString*)paramsJSON {
    if (paramsJSON == nil) {
        return;
    }
    
    NSData* jsonData = [paramsJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error = nil;
    NSDictionary* jsonMap = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error || !jsonMap) {
        return;
    }
    self.appId = jsonMap[kAppId];
    
    self.video = [jsonMap[kInterstitialMode] isKindOfClass:NSString.class] && [jsonMap[kInterstitialMode] isEqualToString:@"VIDEO"];
    
    self.adTag = jsonMap[kAdTag];

    if ([jsonMap[kMinCPM] isKindOfClass:NSNumber.class]) {
        self.minCPM = [jsonMap[kMinCPM] doubleValue];
    }

    self.nativePrimaryImageSize = jsonMap[kNativeImageSize];

    self.nativeSecondaryImageSize = jsonMap[kNativeSecondaryImageSize];
}

@end
