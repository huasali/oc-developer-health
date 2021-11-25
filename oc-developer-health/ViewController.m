//
//  ViewController.m
//  oc-developer-health
//
//  Created by Huasali on 2021/11/23.
//

#import "ViewController.h"
#import <HealthKit/HealthKit.h>

@interface ViewController (){
    HKHealthStore *_healthStore;
    NSDateFormatter *_dateFormatter;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dateFormatter = [[NSDateFormatter alloc]init];
    _dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [_dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss:SSS"];
    _healthStore = [[HKHealthStore alloc]init];
    HKObjectType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSSet *healthSet = [NSSet setWithObjects:stepType, nil];
    [_healthStore requestAuthorizationToShareTypes:nil readTypes:healthSet completion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            [self readStepData];
        }
        else{
            NSLog(@"获取步数权限失败");
        }
    }];
}

- (void)readStepData{
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
                NSLog(@"%@：%@ - %@ 步数%.0f",result.device.model,[self->_dateFormatter stringFromDate:result.startDate],[self->_dateFormatter stringFromDate:result.endDate],stepCount);
                allStepCount = allStepCount + stepCount;
            }
        }
        NSLog(@"今天的总步数＝＝＝＝%d",allStepCount);
    }];
    [_healthStore executeQuery:sampleQuery];
}

@end
