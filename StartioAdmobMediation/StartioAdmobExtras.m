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

#import "StartioAdmobExtras.h"
#import <StartApp/StartApp.h>

static NSString* const kAppId = @"startioAppId";
static NSString* const kInterstitialMode = @"interstitialMode";
static NSString* const kAdTag = @"adTag";
static NSString* const kMinCPM = @"minCPM";
static NSString* const kMuteVideo = @"muteVideo";
static NSString* const kNativeImageSize = @"nativeImageSize";
static NSString* const kNativeSecondaryImageSize = @"nativeSecondaryImageSize";

static STANativeAdBitmapSize stringToBitmapSize(NSString* format) {
    if ([format isEqualToString:@"SIZE72X72"]) {
        return SIZE_72X72;
    } else if ([format isEqualToString:@"SIZE100X100"]) {
        return SIZE_100X100;
    } else if ([format isEqualToString:@"SIZE150X150"]) {
        return SIZE_150X150;
    } else if ([format isEqualToString:@"SIZE340X340"]) {
        return SIZE_340X340;
    } else if ([format isEqualToString:@"SIZE1200X628"]) {
        return SIZE_1200X628;
    }
    return SIZE_150X150;
}

@implementation StartioAdmobExtras

- (instancetype)initWithJson:(nullable NSString*)jsonString {
    if (self = [self init]) {
        _prefs = [[STANativeAdPreferences alloc] init];
        _prefs.adsNumber = 1;
        _prefs.autoBitmapDownload = NO;
        
        [self parseParams:jsonString];
    }
    return self;
}

- (instancetype)initWithJson:(nullable NSString*)jsonString lat:(CGFloat)lat lon:(CGFloat)lon {
    if (self = [self initWithJson:jsonString]) {
        _prefs.userLocation.latitude = lat;
        _prefs.userLocation.longitude = lon;
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
        self.prefs.adTag = jsonMap[kAdTag];
    }
    
    if (jsonMap[kMinCPM]) {
        self.prefs.minCPM = [jsonMap[kMinCPM] doubleValue];
    }
    
    if (jsonMap[kMuteVideo]) {
        // TODO: needs to implement in the sdk STAAdPreferences
        // self.prefs.muteVideo = [jsonMap[kMuteVideo] boolValue];
    }
    
    if (jsonMap[kNativeImageSize]) {
        self.prefs.primaryImageSize = stringToBitmapSize(jsonMap[kNativeImageSize]);
    }
    
    if (jsonMap[kNativeSecondaryImageSize]) {
        self.prefs.secondaryImageSize = stringToBitmapSize(jsonMap[kNativeSecondaryImageSize]);
    }
}

@end
