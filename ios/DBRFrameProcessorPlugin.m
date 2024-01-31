//
//  VisionCameraDBRPlugin.m
//  vision-camera-dynamsoft-barcode-reader
//
//  Created by xulihang on 2022/1/26.
//

#import <Foundation/Foundation.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>
#import <VisionCamera/Frame.h>
#import "VisionCameraDynamsoftBarcodeReader-Swift.h"

@interface DBRFrameProcessorPlugin (FrameProcessorPluginLoader)
@end

@implementation DBRFrameProcessorPlugin (FrameProcessorPluginLoader)

+ (void)load
{
    [FrameProcessorPluginRegistry addFrameProcessorPlugin:@"decode"
                                        withInitializer:^FrameProcessorPlugin* (VisionCameraProxyHolder* proxy, NSDictionary* options) {
        return [[DBRFrameProcessorPlugin alloc] initWithProxy:proxy withOptions:options];
    }];
}

@end
