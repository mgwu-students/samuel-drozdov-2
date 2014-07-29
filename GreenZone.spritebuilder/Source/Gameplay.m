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
    
    CCColor *greenZoneColor;
    int colorTimer;
    
    bool gameEnd;
    int gameEndTimer;
    
    CCNode *_full1;
    CCNode *_full2;
}

- (void)onEnter {
    [super onEnter];
    direction = 2.0;
    speed = 0.002;
    score = 0;
    greenSpeed = 1.0;
    
    greenZoneColor = _greenZone.color;
    colorTimer = 0;
    
    gameEnd = false;
    gameEndTimer = 0;
}

-(void)onExit {
    [super onExit];
}

-(void)didLoadFromCCB {
    // accept touches on the grid
    self.userInteractionEnabled = YES;
    
    greenZoneColor = _greenZone.color;
    colorTimer = 0;
}

-(void)update:(CCTime)delta {
    if(!gameEnd) {
        _pointer.positionInPoints = ccp(_pointer.positionInPoints.x, _pointer.positionInPoints.y+   direction);
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
            _greenZone.positionInPoints = ccp(_greenZone.positionInPoints.x, _greenZone.    positionInPoints.y + greenSpeed);
            if(_greenZone.positionInPoints.y + _greenZone.boundingBox.size.height/2 >= 350) {
                greenSpeed *= -1;
            } else if(_greenZone.positionInPoints.y - _greenZone.boundingBox.size.height/2 <= 0) {
                greenSpeed *= -1;
            }
        }
        
        float gHeight = _greenZone.boundingBox.size.height;
        if(gHeight >= 98) {
            _full1.scale = 1;
            _full2.scale = 1;
        } else if(_full1.scaleY >= 0) {
            _full1.scaleY -= .03;
            _full2.scaleY -= .03;
        } else {
            _full1.scaleY = 0;
            _full2.scaleY = 0;
        }
    }
    
    //the green bar blinks white
    if(colorTimer == 1) {
        _greenZone.color = greenZoneColor;
        colorTimer = 0;
    }
    colorTimer++;
    
    //the pointer turns red for a moment before the game ends
    if(gameEnd && gameEndTimer == 40) {
        [self gameEnd];
    }
    gameEndTimer++;
    
    _scoreLabel.string = [NSString stringWithFormat:@"%d",score];
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
   if((_pointer.positionInPoints.y <= _greenZone.positionInPoints.y + _greenZone.boundingBox.size.height/2
      || _pointer.positionInPoints.y - 5 <= _greenZone.positionInPoints.y + _greenZone.boundingBox.size.height/2)
      && (_pointer.positionInPoints.y >= _greenZone.positionInPoints.y - _greenZone.boundingBox.size.height/2
      || _pointer.positionInPoints.y + 5 >= _greenZone.positionInPoints.y - _greenZone.boundingBox.size.height/2)) {
       float gHeight = _greenZone.boundingBox.size.height;
       if(_greenZone.positionInPoints.y + gHeight*1.2/2 < 350 && _greenZone.positionInPoints.y - gHeight*1.2/2 > 0) {
           if(gHeight*1.2 < 100) {
               _greenZone.scaleY += 0.2;
           } else {
               _greenZone.scale = 1;
           }
       }
       score++;
       speed+=0.00003;
       
       _greenZone.color = [CCColor whiteColor];
       colorTimer = 0;
       
       if(direction > 0) {
           direction += 0.08;
       } else if(direction < 0) {
           direction -= 0.08;
       }
       
   } else {
       [MGWU logEvent:@"MissClickedLoss" withParams:nil];
       _pointer.color = [CCColor redColor];
       gameEndTimer = 0;
       gameEnd = true;
   }
}

-(void)gameEnd {
    NSNumber *highScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"HighScore"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:score] forKey:@"PreviousScore"];
    
    NSNumber* finalScore = [NSNumber numberWithInt:score];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys: finalScore, @"score", nil];
    [MGWU logEvent:@"FinalScore" withParams:params];
    
    if(score > highScore.intValue) {
        [MGWU showMessage:@"New High Score!" withImage:nil];
        // new highscore!
        highScore = [NSNumber numberWithInt:score];
        [[NSUserDefaults standardUserDefaults] setObject:highScore forKey:@"HighScore"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionDown duration:0.5f]];;
}


@end
