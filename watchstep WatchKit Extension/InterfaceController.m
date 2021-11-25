//
//  InterfaceController.m
//  watchstep WatchKit Extension
//
//  Created by Huasali on 2021/11/23.
//

#import "InterfaceController.h"
#import <HealthKit/HealthKit.h>
#import <ClockKit/ClockKit.h>

@interface InterfaceController (){
    HKHealthStore *_healthStore;
    NSDateFormatter *_dateFormatter;
}

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *stepLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *goalButton;
@property (weak, nonatomic) IBOutlet WKInterfaceTextField *inputTextField;

@end


@implementation InterfaceController

- (instancetype)init {
    if (self = [super init]) {
        _dateFormatter = [[NSDateFormatter alloc]init];
        _dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
        [_dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss:SSS"];
        _healthStore = [[HKHealthStore alloc]init];
    }
    return self;
}

- (void)awakeWithContext:(id)context {
    // Configure interface objects here.
    NSLog(@"[app] awakeWithContext");
    HKObjectType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSSet *healthSet = [NSSet setWithObjects:stepType, nil];
    [_healthStore requestAuthorizationToShareTypes:nil readTypes:healthSet completion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            [self updateStepData];
            NSInteger goal = [[NSUserDefaults standardUserDefaults] integerForKey:@"goal"];
            [self.goalButton setTitle:[NSString stringWithFormat:@"%li",(long)goal]];
            [self.inputTextField setText:[NSString stringWithFormat:@"%li",(long)goal]];
        }
        else{
            NSLog(@"[app] 获取步数权限失败");
        }
    }];
}

- (void)updateStepData{
    HKSampleType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSSortDescriptor *start = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    NSSortDescriptor *end = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    long todayStartTime = (long)([[NSDate date] timeIntervalSince1970]/86400)*86400 - 8*60*60;
    long todayEndTime   = todayStartTime + 86400;
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:[NSDate dateWithTimeIntervalSince1970:todayStartTime] endDate:[NSDate dateWithTimeIntervalSince1970:todayEndTime] options:(HKQueryOptionNone)];
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        int allStepCount = 0;
        for (int i = 0; i < results.count; i ++) {
            HKQuantitySample *result = results[i];
            if ([result.device.model isEqualToString:@"Watch"]) {
                double stepCount = [result.quantity doubleValueForUnit:[HKUnit countUnit]];
                NSLog(@"[app] %@：%@ - %@ 步数%.0f",result.device.model,[self->_dateFormatter stringFromDate:result.startDate],[self->_dateFormatter stringFromDate:result.endDate],stepCount);
                allStepCount = allStepCount + stepCount;
            }
        }
        NSLog(@"[app] 今天的总步数＝＝＝＝%d",allStepCount);
        self.stepLabel.text = [NSString stringWithFormat:@"%d",allStepCount];
        [[NSUserDefaults standardUserDefaults] setValue:@(allStepCount) forKey:@"step"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self refreshComplication];
    }];
    [_healthStore executeQuery:sampleQuery];
}
- (void)willActivate {
    NSLog(@"[app] willActivate");
    [self updateStepData];
    // This method is called when watch view controller is about to be visible to user
}

- (void)didDeactivate {
    NSLog(@"[app] didDeactivate");
    // This method is called when watch view controller is no longer visible
}
- (IBAction)TextFieldAction:(NSString *)value {
    if (value) {
        [self.goalButton setTitle:[NSString stringWithFormat:@"%@",value]];
        [self.goalButton setHidden:false];
        [self.inputTextField setHidden:true];
        [[NSUserDefaults standardUserDefaults] setValue:value forKey:@"goal"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self refreshComplication];
    }
}
- (IBAction)buttonAction {
    [self.goalButton setHidden:true];
    [self.inputTextField setHidden:false];
}
- (void)refreshComplication{
    CLKComplicationServer *complicationServer = [CLKComplicationServer sharedInstance];
    for (CLKComplication * complication in complicationServer.activeComplications) {
        if ([@"ComplicationStep" isEqualToString:complication.identifier]) {
            [complicationServer reloadTimelineForComplication:complication];
        }
    }
}
@end



