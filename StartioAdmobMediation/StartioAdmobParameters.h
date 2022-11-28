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

NS_ASSUME_NONNULL_BEGIN

@interface StartioAdmobParameters : NSObject

- (void)readFromJSONString:(nullable NSString*)paramsJSON;

@property (nonatomic, readonly, nullable) NSString* appId;
@property (nonatomic, readonly, getter=isVideo) BOOL video;
@property (nonatomic, readonly, nullable) NSString *adTag;
@property (nonatomic, readonly) double minCPM;
@property (nonatomic, readonly, nullable) NSString *nativePrimaryImageSize;
@property (nonatomic, readonly, nullable) NSString *nativeSecondaryImageSize;

@end

NS_ASSUME_NONNULL_END
