//
//  LLWebViewModel.m
//  LLDebugToolDemo
//
//  Created by apple on 2019/9/29.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLWebViewModel.h"
#import "LLTool.h"

@interface LLWebViewModel()

@property (nonatomic , copy , nonnull) NSString *headerString;

@property (nonatomic , strong) NSDate *dateDescription;

@end

@implementation LLWebViewModel

- (void)setStartDate:(NSString *)startDate {
    if (![_startDate isEqualToString:startDate]) {
        _startDate = [startDate copy];
        if (!_identity) {
            _identity = [startDate stringByAppendingString:[LLTool absolutelyIdentity]];
        }
    }
}

- (NSString *)headerString {
    if (!_headerString) {
        _headerString = [LLTool convertJSONStringFromDictionary:self.headerFields];
    }
    return _headerString;
}

- (NSDate *)dateDescription {
    if (!_dateDescription && self.startDate.length) {
        _dateDescription = [LLTool dateFromString:self.startDate];
    }
    return _dateDescription;
}

-(NSString *)storageIdentity{
    return self.identity ;
}

@end
