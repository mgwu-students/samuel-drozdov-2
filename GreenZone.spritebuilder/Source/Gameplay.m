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
    CCNodeColor *_barBackground;
    
    float direction;
    float shrinkSpeed;
    float greenSpeed;
    
    CCColor *barBackgroundColor;
    CCColor *greenZoneColor;
    int colorTimer;
    
    bool gameEnd;
    int gameEndTimer;
}

- (void)onEnter {
    [super onEnter];
    direction = 2.0;
    shrinkSpeed = 0.0015;
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
    barBackgroundColor = _barBackground.color;
    
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
    
        _greenZone.scaleY = _greenZone.scaleYInPoints - shrinkSpeed;
        if(_greenZone.scaleYInPoints <= 0) {
            [MGWU logEvent:@"ShrinkedGreenZoneLoss" withParams:nil];
            _greenZone.scale = 0;
            gameEndTimer = 0;
            gameEnd = true;
        }
        
        if(score >= 10) {
            _greenZone.positionInPoints = ccp(_greenZone.positionInPoints.x, _greenZone.    positionInPoints.y + greenSpeed);
            if(_greenZone.positionInPoints.y + _greenZone.boundingBox.size.height/2 >= 350
               || _greenZone.positionInPoints.y - _greenZone.boundingBox.size.height/2 <= 0) {
                greenSpeed *= -1;
            }
        }
        
        float gHeight = _greenZone.boundingBox.size.height;
        CCColor *barBackgroundHolder = _barBackground.color;
        if(gHeight >= 98) {
            _barBackground.color = [CCColor whiteColor];
        }
        _barBackground.color = barBackgroundHolder;
    }
    
    //the green bar blinks white
    if(colorTimer == 2) {
        _greenZone.color = greenZoneColor;
        _barBackground.color = barBackgroundColor;
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
       shrinkSpeed += 0.000032;
       
       _greenZone.color = [CCColor whiteColor];
          _barBackground.color = [CCColor greenColor];
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
    [[CCDirector sharedDirector] replaceScene:mainScene withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionDown duration:0.5f]];
}


@end
