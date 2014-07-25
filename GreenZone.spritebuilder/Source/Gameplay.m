//
//  Gameplay.m
//  GreenZone
//
//  Created by Samuel Drozdov on 7/25/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"

@implementation Gameplay {
    CCLabelTTF *_scoreLabel;
    int score;
    
    CCNode *_playBar;
    CCNode *_greenZone;
    CCNode *_pointer;
    
    double direction;
    double speed;
    double greenSpeed;
}

- (void)onEnter {
    [super onEnter];
    direction = 2.0;
    speed = 0.002;
    score = 0;
    greenSpeed = 1.0;
}

-(void)onExit {
    [super onExit];
}

-(void)didLoadFromCCB {
    // accept touches on the grid
    self.userInteractionEnabled = YES;
}

-(void)update:(CCTime)delta {
    _pointer.positionInPoints = ccp(_pointer.positionInPoints.x, _pointer.positionInPoints.y+direction);
    if(_pointer.positionInPoints.y+5 >= 350) {
        direction *= -1;
    } else if(_pointer.positionInPoints.y-5 <= 0) {
        direction *= -1;
    }
    
    _greenZone.scaleY = _greenZone.scaleYInPoints - speed;
    if(_greenZone.scaleYInPoints <= 0) {
        [MGWU logEvent:@"ShrinkedGreenZoneLoss" withParams:nil];
        [self gameEnd];
    }
    
    if(score >= 10) {
        _greenZone.positionInPoints = ccp(_greenZone.positionInPoints.x, _greenZone.positionInPoints.y + greenSpeed);
        if(_greenZone.positionInPoints.y + _greenZone.boundingBox.size.height/2 >= 350) {
            greenSpeed *= -1;
        } else if(_greenZone.positionInPoints.y - _greenZone.boundingBox.size.height/2 <= 0) {
            greenSpeed *= -1;
        }
    }
    
    _scoreLabel.string = [NSString stringWithFormat:@"%d",score];
}
       
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
   if(_pointer.positionInPoints.y <= _greenZone.positionInPoints.y + _greenZone.boundingBox.size.height/2
      && _pointer.positionInPoints.y >= _greenZone.positionInPoints.y - _greenZone.boundingBox.size.height/2) {
       float gHeight = _greenZone.boundingBox.size.height;
       if(gHeight < 100 && _greenZone.positionInPoints.y + gHeight*1.3/2 < 350 && _greenZone.positionInPoints.y - gHeight*1.3/2 > 0) {
           _greenZone.scaleY += 0.3;
       }
       score++;
       speed+=0.00005;
       
       if(direction > 0) {
           direction += 0.1;
       } else if(direction < 0) {
           direction -= 0.1;
       }
       
   } else {
       [MGWU logEvent:@"MissClickedLoss" withParams:nil];
       [self gameEnd];
   }
}

-(void)gameEnd {
    NSNumber *highScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"HighScore"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:score] forKey:@"PreviousScore"];
    
    NSNumber* finalScore = [NSNumber numberWithInt:score];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys: finalScore, @"score", nil];
    [MGWU logEvent:@"FinalScore" withParams:params];
    
    if(score > highScore.intValue) {
        if(score > 20) {
            [MGWU showMessage:@"New High Score!" withImage:nil];
        }
        // new highscore!
        highScore = [NSNumber numberWithInt:score];
        [[NSUserDefaults standardUserDefaults] setObject:highScore forKey:@"HighScore"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene];
}


@end
