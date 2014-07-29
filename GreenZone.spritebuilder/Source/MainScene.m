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
    
    CCNode *_titleNode;
}

-(void)didLoadFromCCB {
    NSNumber *highScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"HighScore"];
    NSNumber *prevScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"PreviousScore"];
    _highScoreLabel.string = [NSString stringWithFormat:@"%d",highScore.intValue];
    _previousScoreLabel.string = [NSString stringWithFormat:@"%d",prevScore.intValue];
    
    CCActionInterval *moveT = [CCActionMoveTo actionWithDuration:(1.1f) position:ccp(160,284)];
    CCActionInterval *easeT = [CCActionEaseElasticOut actionWithAction:moveT];
    [_titleNode runAction:easeT];
}

-(void)start {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionUp duration:0.5f]];;
}

@end
