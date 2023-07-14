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

#import "STAAdPreferences+AdMob.h"

@implementation STAAdPreferences (AdMob)

- (instancetype)initWithAdConfiguration:(GADMediationAdConfiguration *)adConfiguration startioAdmobParameters:(StartioAdmobParameters *)parameters {
    self = [super init];
    if (self) {
        if (adConfiguration.hasUserLocation) {
            STAUserLocation *staLocation = [[STAUserLocation alloc] init];
            staLocation.latitude = adConfiguration.userLatitude;
            staLocation.longitude = adConfiguration.userLongitude;
            self.userLocation = staLocation;
        }
        
        self.minCPM = parameters.minCPM;
        self.adTag = parameters.adTag;
        
        if (nil == self.placementId) {
            self.placementId = [self.class unitIdFromAdConfiguration:adConfiguration];
        }
    }
    return self;
}

+ (NSString *)unitIdFromAdConfiguration:(GADMediationAdConfiguration *)adConfiguration {
    NSDictionary *privateAdConfiguration = nil;
    @try {
        [adConfiguration valueForKey:@"adConfiguration"];
    } @catch (NSException *exception) {
        
    }
    
    privateAdConfiguration = [privateAdConfiguration isKindOfClass:[NSDictionary class]] ? privateAdConfiguration : nil;
    NSString *unitId = privateAdConfiguration[@"initial_ad_unit_id"];
    return  unitId;
}

@end
