//
//  StartMenuScene+tvOS.swift
//  MadnessDaze
//
//  Created by Adriano Soares on 08/10/15.
//  Copyright © 2015 Paulo Ricardo Ramos da Rosa. All rights reserved.
//

import Foundation
import Foundation
import SpriteKit


extension StartMenuScene {
    
    
    func setupGestureRecognizerTV () {
        let tapRecognizerUp     = UITapGestureRecognizer(target: self, action: Selector("tappedUp:"))
        let tapRecognizerRight  = UITapGestureRecognizer(target: self, action: Selector("tappedRight:"))
        let tapRecognizerDown   = UITapGestureRecognizer(target: self, action: Selector("tappedDown:"))
        let tapRecognizerLeft   = UITapGestureRecognizer(target: self, action: Selector("tappedLeft:"))
        let tapRecognizerSelect = UITapGestureRecognizer(target: self, action: Selector("selectClick:"))
        let tapRecognizerPlay   = UITapGestureRecognizer(target: self, action: Selector("tappedPlay:"))

        
        tapRecognizerUp.allowedPressTypes       = [UIPressType.UpArrow.rawValue];
        tapRecognizerRight.allowedPressTypes    = [UIPressType.RightArrow.rawValue];
        tapRecognizerDown.allowedPressTypes     = [UIPressType.DownArrow.rawValue];
        tapRecognizerLeft.allowedPressTypes     = [UIPressType.LeftArrow.rawValue];
        tapRecognizerSelect.allowedPressTypes   = [UIPressType.Select.rawValue];
        tapRecognizerPlay.allowedPressTypes     = [UIPressType.PlayPause.rawValue];

        
        
        view!.addGestureRecognizer(tapRecognizerUp);
        view!.addGestureRecognizer(tapRecognizerRight);
        view!.addGestureRecognizer(tapRecognizerDown);
        view!.addGestureRecognizer(tapRecognizerLeft);
        view!.addGestureRecognizer(tapRecognizerSelect);
        view!.addGestureRecognizer(tapRecognizerPlay);
        
        
        labels.append(loadGame)
        labels.append(newGame)
        labels.append(tutorial)
        
        updateColor();
    }
    
    
    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        if (presses.first?.type == UIPressType.Menu) {
            super.pressesBegan(presses, withEvent: event);
        }
    }
    
    func updateColor () {
        for (var i = 0; i < labels.count; i++) {
            if (i == selected) {
                labels[i].fontColor = UIColor.redColor()
            } else {
                labels[i].fontColor = UIColor.whiteColor()
            }
        }
        voice();
        
        
        
    }
    
    func voice () {
        if (isOnNewGameScreen) {

        } else if (isOnStartMenuOptions) {
            switch (selected) {
            case 0:
                manager.playDirectionNarration("LANG-continuar", frmt: "mp3")
                break;
                
            case 1:
                manager.playDirectionNarration("LANG-iniciar", frmt: "mp3")
                break;
                
            case 2:
                manager.playDirectionNarration("LANG-tutorial", frmt: "mp3")
                break;
            default:
                break;
                
            }
        
        
        
        }
    }
    
    func tappedUp   (gesture: UITapGestureRecognizer) {
        print("tapUp")
        if (selected-1 < 0) {
            selected = labels.count-1
        }
        else {
            selected = (selected-1)%labels.count;
        }
        updateColor();
        
    }
    func tappedRight(gesture: UITapGestureRecognizer) {
        print("tapRight")
    }
    func tappedDown (gesture: UITapGestureRecognizer) {
        print("tapDown")
        selected = (selected+1)%labels.count;
        updateColor();
        
    }
    func tappedLeft (gesture: UITapGestureRecognizer) {
        print("tapLeft")
    }
    
    func selectClick(gesture: UITapGestureRecognizer) {
        if (selected == 0) {
            continueGame();
        } else if (selected == 1) {
            if (!manager.firstPlay  && false) {
                newGameScreen();
                
            
            
            } else {
                manager.gameState.eraseJson()
                manager.eraseManager()
                self.manager.initStoryArray()
                self.start()
            }

        
        } else if (selected == 2) {
            GameManager.addSoundArray("LANG-tutorialFull", frmt: "mp3", x: 0.0, y: 0.0)

        }
        
        print("selectClick")
    }
    
    
    func tappedPlay (gesture: UITapGestureRecognizer) {
        if (!manager.firstPlay) {
            continueGame();
        } else {
            manager.gameState.eraseJson()
            manager.eraseManager()
            self.manager.initStoryArray()
            self.start()
        }
    }
}