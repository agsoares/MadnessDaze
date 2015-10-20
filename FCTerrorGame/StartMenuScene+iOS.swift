//
//  StartMenuScene+iOS.swift
//  MadnessDaze
//
//  Created by Adriano Soares on 08/10/15.
//  Copyright © 2015 Paulo Ricardo Ramos da Rosa. All rights reserved.
//

import Foundation
import SpriteKit


extension StartMenuScene {
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches
        let location = touch.first!.locationInNode(self)
        let node = self.nodeAtPoint(location)
        
        #if os(iOS)
            print("iOS")
            #else
            print("tvOS")
        #endif
        
        if (node.name == "newGame"){
            newGameTouch++
            loadGameTouch = 0
            tutorialTouch = 0
            
            manager.playDirectionNarration("LANG-iniciar", frmt: "mp3")
            print("NEWGAME")
            
        }else if (node.name == "tutorial"){
            print("TUTORIAL")
            tutorialTouch++
            newGameTouch = 0
            loadGameTouch = 0
           
            manager.playDirectionNarration("LANG-tutorial", frmt: "mp3")
        }else if (node.name == "loadGame"){
            loadGameTouch++
            newGameTouch = 0
            tutorialTouch = 0
            print("LOADGAME")
            
            manager.playDirectionNarration("LANG-continuar", frmt: "mp3")
        }
        
        if (node.name == "newGame" && newGameTouch > 1 && !manager.firstPlay){
            
            manager.playDirectionNarration("LANG-novoJogoConfirma", frmt: "mp3")
            self.newGameScreen()
        } else if (node.name == "newGame" && newGameTouch > 1 && manager.firstPlay){
            manager.gameState.eraseJson()
            manager.eraseManager()
            self.manager.initStoryArray()
            self.start()
        }
        
        
        if (node.name == "tutorial" && tutorialTouch > 1){
            print("PLAY TUTORIAL")
            
             manager.playDirectionNarration("LANG-tutorialFull", frmt: "mp3")
            self.tutorialTouch = 0
            self.newGameTouch = 0
            self.loadGameTouch = 0
        }
        
        if (node.name == "loadGame" && loadGameTouch > 1 && !manager.firstPlay){
            print("NOW LOADING GAME")
            continueGame()
        }
        
        if (node.name == "newGameNo"){
            noTouch++
            yesTouch = 0
            print("NO")

             manager.playDirectionNarration("LANG-nao", frmt: "mp3")
        }else if (node.name == "newGameYes"){
            yesTouch++
            noTouch = 0
            print("YES")

             manager.playDirectionNarration("LANG-sim", frmt: "mp3")
        }
        
        
        
        if (node.name == "newGameNo" && noTouch > 1){
            self.newGameNo.removeFromParent()
            self.newGameYes.removeFromParent()
            newGameTouch = 0
            loadGameTouch = 0
            tutorialTouch = 0
            noTouch = 0
            yesTouch = 0
            self.startMenuOptions()
        } else if (node.name == "newGameYes" && yesTouch > 1){
            manager.gameState.eraseJson()
            manager.eraseManager()
            self.manager.initStoryArray()
            self.start()
        }
    }
}