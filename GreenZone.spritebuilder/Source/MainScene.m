//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene {
    CCLabelTTF *_highScoreLabel;
    CCLabelTTF *_previousScoreLabel;
}

-(void)didLoadFromCCB {
    NSNumber *highScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"HighScore"];
    NSNumber *prevScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"PreviousScore"];
    _highScoreLabel.string = [NSString stringWithFormat:@"%d",highScore.intValue];
    _previousScoreLabel.string = [NSString stringWithFormat:@"%d",prevScore.intValue];
}

-(void)start {
    CCScene *recapScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:recapScene];
}

@end
