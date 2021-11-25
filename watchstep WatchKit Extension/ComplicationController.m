//
//  ComplicationController.m
//  watchstep WatchKit Extension
//
//  Created by Huasali on 2021/11/23.
//

#import "ComplicationController.h"

@implementation ComplicationController

#pragma mark - Complication Configuration

- (void)getComplicationDescriptorsWithHandler:(void (^)(NSArray<CLKComplicationDescriptor *> * _Nonnull))handler {
    NSLog(@"[app][ComplicationController] getComplicationDescriptorsWithHandler");
        NSArray<CLKComplicationDescriptor *> *descriptors = @[
            [[CLKComplicationDescriptor alloc] initWithIdentifier:@"ComplicationStep"
                                                      displayName:@"步数"
                                                supportedFamilies:@[@(CLKComplicationFamilyGraphicCorner)]]
        ];
        handler(descriptors);
}

- (void)handleSharedComplicationDescriptors:(NSArray<CLKComplicationDescriptor *> *)complicationDescriptors {
    NSLog(@"[app][ComplicationController] handleSharedComplicationDescriptors");
    // Do any necessary work to support these newly shared complication descriptors
}

#pragma mark - Timeline Configuration

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    NSLog(@"[app][ComplicationController] getTimelineEndDateForComplication");
    // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
    handler(nil);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    // Call the handler with your desired behavior when the device is locked
    NSLog(@"[app][ComplicationController] getPrivacyBehaviorForComplication");
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    [self getLocalizableSampleTemplateForComplication:complication withHandler:^(CLKComplicationTemplate *_Nullable complicationTemplate) {
          if (complicationTemplate == nil) {
              handler(nil);
          }else{
              CLKComplicationTimelineEntry *entry = [CLKComplicationTimelineEntry new];
              entry.complicationTemplate = complicationTemplate;
              entry.date = NSDate.now;
              handler(entry);
          }
      }];
}
#pragma mark - Sample Templates

- (void)getLocalizableSampleTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTemplate * __nullable complicationTemplate))handler {
    if (complication.family == CLKComplicationFamilyGraphicCorner) {
        NSNumber *number = [[NSUserDefaults standardUserDefaults] valueForKey:@"step"];
        NSInteger goal = [[NSUserDefaults standardUserDefaults] integerForKey:@"goal"];
        if (goal == 0) {
            goal = 1;
        }
        NSLog(@"[app] 读取数值 %@/%ld = %f",number,(long)goal,number.floatValue/goal);
        if (!number) {
            number = @(0);
        }
        handler([CLKComplicationTemplateGraphicCornerGaugeText templateWithGaugeProvider:[CLKSimpleGaugeProvider gaugeProviderWithStyle:CLKGaugeProviderStyleFill gaugeColor:[UIColor greenColor] fillFraction:number.floatValue/goal] outerTextProvider:[CLKTextProvider textProviderWithFormat:@"%@",number]]);
    }
    else{
        handler(nil);
    }
}

@end
