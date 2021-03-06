//
//  TTTCellRoundRect.h
//  TTT
//
//  Created by Hans Yelek on 6/13/14.
//  Copyright (c) 2014 Hans Yelek. All rights reserved.
//

#import "TTTCell.h"

@interface TTTCellRoundRect : TTTCell

/* used for two-in-row animations */
@property (nonatomic, strong) CALayer * pondlayer1;
@property (nonatomic, strong) CALayer * pondLayer2;

@end
