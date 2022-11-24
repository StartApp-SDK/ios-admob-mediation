/**
 * Copyright 2022 Start.io Inc
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 StartioAdmobAdoptedAdLoaderaderader of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "StartioAdmobBaseAdLoader.h"
#include <stdatomic.h>

@implementation StartioAdmobBaseAdLoader

- (void)loadAdForAdConfiguration:(GADMediationAdConfiguration *)adConfiguration
          startioAdmobParameters:(StartioAdmobParameters *)startioAdmobParameters
               completionHandler:(StartioAdmobAdLoaderCompletion)completionHandler {
    [self setupWithCompletionHandler:completionHandler];
    [self performLoadWithAdConfiguration:adConfiguration startioAdmobParameters:startioAdmobParameters];
}

- (void)setupWithCompletionHandler:(StartioAdmobAdLoaderCompletion)completionHandler {
    __block atomic_flag completionHandlerCalled = ATOMIC_FLAG_INIT;
    __block GADMediationRewardedLoadCompletionHandler originalCompletionHandler = [completionHandler copy];

    self.completionHandler = ^id<GADMediationAdEventDelegate>(_Nullable id<GADMediationRewardedAd> ad, NSError *_Nullable error) {
        // Only allow completion handler to be called once.
        if (atomic_flag_test_and_set(&completionHandlerCalled)) {
            return nil;
        }
        
        id<GADMediationRewardedAdEventDelegate> delegate = nil;
        if (originalCompletionHandler) {
            // Call original handler and hold on to its return value.
            delegate = originalCompletionHandler(ad, error);
        }
        
        // Release reference to handler. Objects retained by the handler will also be released.
        originalCompletionHandler = nil;
        
        return delegate;
    };
}

- (void)performLoadWithAdConfiguration:(GADMediationAdConfiguration *)adConfiguration
                startioAdmobParameters:(StartioAdmobParameters *)startioAdmobParameters {
    //overriden in child classes
}

@end
