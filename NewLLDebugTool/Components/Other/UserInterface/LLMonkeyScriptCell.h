//
//  LLMonkeyScriptCell.h
//  LLDebugToolDemo
//
//  Created by apple on 2019/10/17.
//  Copyright © 2019 li. All rights reserved.
//

#import "LLBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLMonkeyScriptCell : LLBaseTableViewCell

- (void)confirmWithControllerTitle:(NSString *)controllerTitle  controllerName:(NSString*)controllerName scriptTitle:(NSString*)scriptTitle scriptName:(NSString*)scriptName ;


@end

NS_ASSUME_NONNULL_END
