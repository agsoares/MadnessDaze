//
//  GameScene.swift
//  FCTeste
//
//  Created by Adriano Soares on 04/08/15.
//  Copyright (c) 2015 bepid. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, UIGestureRecognizerDelegate, UIAlternateTapGestureRecognizerDelegate {
    var gameState = GameState.sharedInstance;
    var level: JSON!
    var background: SKSpriteNode?
    var enemyControl = EnemyControl()
    var manager = GameManager.sharedInstance
    var playerHidden = false;
    
    override func didMoveToView(view: SKView) {
        //self.manager.setPlayerPosition(0)
        manager.firstPlay = false
        if let filePath = NSBundle.mainBundle().pathForResource("Level1", ofType: "json") {
            level =  JSON(data: NSData(contentsOfFile: filePath)!)
        } else {
            level = JSON.nullJSON
        }
        let swipeLeft    = UISwipeGestureRecognizer(target: self, action: Selector("swipeLeft:"))
        let swipeUp      = UISwipeGestureRecognizer(target: self, action: Selector("swipeUp:"))
        let swipeRight   = UISwipeGestureRecognizer(target: self, action: Selector("swipeRight:"))
        let swipeDown    = UISwipeGestureRecognizer(target: self, action: Selector("swipeDown:"))
        let longPress    = UILongPressGestureRecognizer(target: self, action: Selector("longPress:"))
        
        let alternateTap = UIAlternateTapGestureRecognizer(target: self, action: Selector("alternateTapping:"));
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("presentGameOver"),
            name: "gameOver",
            object: nil)
        
        //GameManager.clearRoomSoundArray(); // Room sounds now stop playing on change room
        manager.stopStorySound(); //StorySound now stop playing on change room
        
        swipeLeft.direction  = .Left
        swipeUp.direction    = .Up
        swipeRight.direction = .Right
        swipeDown.direction  = .Down
        longPress.minimumPressDuration = 1.0;
        alternateTap.numberOfTapsRequired = 5;
        alternateTap.delegate = self
        
        view.addGestureRecognizer(alternateTap)
        view.addGestureRecognizer(longPress)
        view.addGestureRecognizer(swipeLeft)
        view.addGestureRecognizer(swipeUp)
        view.addGestureRecognizer(swipeRight)
        view.addGestureRecognizer(swipeDown)
        loadRoom()
        
        manager.playBGSound("storm", frmt: "mp3")
        
        self.runEnemyBehavior()
        
    }

    // MARK: Enemy Behavior
    
    func runEnemyBehavior(){
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.waitForDuration(2.0),
                SKAction.runBlock({
                    if (!self.manager.storyP[self.manager.i-1].storyPlayer.playing){
                        self.enemyControl.updateEnemiesPosition()
                        self.enemyControl.playEnemiesPosition()
                    }else{
                        self.enemyControl.stopEnemiesPosition()
                    }
                })
                ])
            ))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    // MARK: Level Functions
    
    func loadRoom () {
        var tex = SKTexture(imageNamed: level[gameState.room]["background"].stringValue + "-" + gameState.rotation.description)
        print(tex.description);

        if (tex.size().width != 128) {
            background = SKSpriteNode(texture: tex);
            background?.position = CGPoint(x: frame.midX, y: frame.midY)
            addChild(background!)
        } else {
            tex = SKTexture(imageNamed: level[gameState.room]["background"].stringValue)
            if (tex.size().width != 128) {
                background = SKSpriteNode(texture: tex);
                background?.position = CGPoint(x: frame.midX, y: frame.midY)
                addChild(background!)
            } else {
                background = SKSpriteNode(imageNamed: "asylumRoom2")
                background?.position = CGPoint(x: frame.midX, y: frame.midY)
                addChild(background!)
            }
            
        }

        gameState.saveState()
        manager.listenerAngularPosition(Float(gameState.rotation)*(90.0));
        checkStoryRequisite(level[gameState.room])
        checkDirectionSoundRequisite(level[gameState.room])
        if let levelSounds = level[gameState.room]["playOnEnter"].array {
            playSoundArray(levelSounds)

        }

    }

    // MARK: Controls


    func swipeLeft(gesture: UISwipeGestureRecognizer) {
        
        doAction("swipeLeft")
    }
    
    func swipeUp(gesture: UISwipeGestureRecognizer) {
        doAction("swipeUp")
    }
    func swipeRight(gesture: UISwipeGestureRecognizer) {
        doAction("swipeRight")
       
    }
    
    func swipeDown(gesture: UISwipeGestureRecognizer) {
        doAction("swipeDown")
    }
    
    func didTap(gesture: UIAlternateTapGestureRecognizer) {
        doAction("tap")
    }
    
    func longPress(gesture: UILongPressGestureRecognizer) {
        if (gesture.state == UIGestureRecognizerState.Began) {
            doAction("longPress")
        } else if (gesture.state == UIGestureRecognizerState.Ended) {
            doAction("longPressEnded")
        }
    }
    
    func alternateTapping(gesture: UITapGestureRecognizer) {
        //doAction("alternateTap");
    
    }
    
    
    
    func doAction(name: String) {
        var newAction = name;
        _ = 0
        switch name {
            case "swipeLeft":
                newAction = gameState.actions[(0+gameState.rotation)%4]
                break;
            case "swipeUp":
                newAction = gameState.actions[(1+gameState.rotation)%4]
                break;
            case "swipeRight":
                newAction = gameState.actions[(2+gameState.rotation)%4]
                break;
            case "swipeDown":
                newAction = gameState.actions[(3+gameState.rotation)%4]
                break;
            case "longPress":
                if let hideable = level[gameState.room]["hide"].bool {
                    if (hideable) {
                        gameState.playerHidden = true;
                    }
                }
                break;
            case "longPressEnded":
                gameState.playerHidden = false;
                break;
//            case "alternateTap":
//                if (!manager.storyP[manager.i-1].storyPlayer.playing || gameState.debug){
//                    
//                    var alternateTap = UIAlternateTapGestureRecognizer(target: self, action: Selector("alternateTapping:"));
//                    tapNumber++
//                    if (tapNumber >= alternateTap.numberOfTapsRequired){
//                        println("YAY IM FREE!!!!!!!")
//                        }
//                }
//                break;
            default:
                break;
        }
        //&& !manager.storyP[manager.i-1].storyPlayer.playing == no swipe until speech is over
        let event = level[gameState.room]["events"][newAction]
        if ((event.description != "null" &&  !manager.storyP[manager.i-1].storyPlayer.playing) || gameState.debug) {
            switch event["action"].stringValue {
            case "pickItem":
                pickItem(event)
                break;
            case "gotoRoom":
                goToRoom(event, swipeDirection: newAction)
                GameManager.addSoundArray("playerSteps", frmt: "mp3", x: 0.0, y: 0.0)
                break;
            default:
                break;
                
            }
            
        }
    }
    
    func checkDirectionSoundRequisite(action: JSON){
        if let prerequisite = action["crossingWay"].int {
            var soundName = "";
            switch prerequisite {
                case 0:
                    //playSound Front or Right
                    if(gameState.rotation == 0){
                        //sound front right
                        soundName = "hallway-direita_frente_01"
                    } else if (gameState.rotation == 1){
                        //sound front left right
                        soundName = "hallway-direita_esquerda_frente_01"
                    } else if (gameState.rotation == 2){
                        //front left
                         soundName = "hallway-esquerda_frente_01"
                    } else {
                        //left right
                         soundName = "hallway-direita_esquerda_01"
                    }
                    break;
                case 1:
                    //playSound front or Left
                    if(gameState.rotation == 0){
                        //sound front left
                         soundName = "hallway-esquerda_frente_01"
                    } else if (gameState.rotation == 1){
                        //sound left right
                         soundName = "hallway-direita_esquerda_01"
                    } else if (gameState.rotation == 2){
                        //front right
                         soundName = "hallway-direita_frente_01"
                    } else {
                        //left right front
                         soundName = "hallway-direita_esquerda_frente_01"
                    }
                    break;
                case 2:
                    //playSound left or right
                    if(gameState.rotation == 0){
                        //sound right left
                         soundName = "hallway-direita_esquerda_01"
                    }else if (gameState.rotation == 1){
                        //sound front right
                         soundName = "hallway-direita_frente_01"
                    }else if (gameState.rotation == 2){
                        //front right left
                         soundName = "hallway-direita_esquerda_frente_01"
                    }else {
                        //left front
                         soundName = "hallway-esquerda_frente_01"
                    }
                    break;
                case 3:
                    //playSound left right front
                    if(gameState.rotation == 0){
                        //sound right left front
                         soundName = "hallway-direita_esquerda_frente_01"
                    }else if (gameState.rotation == 1){
                        //sound left front
                         soundName = "hallway-esquerda_frente_01"
                    }else if (gameState.rotation == 2){
                        //right left
                         soundName = "hallway-direita_esquerda_01"
                    }else {
                        //right front
                         soundName = "hallway-direita_frente_01"
                    }
                    break;
                case 4:
                    //right only
                    if(gameState.rotation == 0){
                        //sound right
                         soundName = "hallway-direita_01"
                    }else if (gameState.rotation == 1){
                        //sound front right
                         soundName = "hallway-direita_frente_01"
                    }else if (gameState.rotation == 2){
                        //front left
                         soundName = "hallway-esquerda_frente_01"
                    }else {
                        //left
                         soundName = "hallway-esquerda_01"
                    }
                    break;
                case 5:
                    //left only
                    if(gameState.rotation == 0){
                        //sound left
                         soundName = "hallway-esquerda_01"
                    }else if (gameState.rotation == 1){
                        //sound right
                        soundName = "hallway-direita_01"
                    }else if (gameState.rotation == 2){
                        //front front right
                         soundName = "hallway-direita_frente_01"
                    }else {
                        //left front
                         soundName = "hallway-esquerda_frente_01"
                    }
                    break;
                case 6:
                    //right front without back
                    if(gameState.rotation == 0){
                        //sound front right
                         soundName = "hallway-direita_frente_01"
                    }else if (gameState.rotation == 1){
                        //sound left front
                         soundName = "hallway-esquerda_frente_01"
                    }else if (gameState.rotation == 2){
                        //left
                         soundName = "hallway-esquerda_01"
                    }else {
                        //right
                         soundName = "hallway-direita_01"
                    }
                    break;
                default:
                    //front left without back
                    if(gameState.rotation == 0){
                        //sound front left
                         soundName = "hallway-esquerda_frente_01"
                    }else if (gameState.rotation == 1){
                        //sound left
                         soundName = "hallway-esquerda_01"
                    }else if (gameState.rotation == 2){
                        //right
                         soundName = "hallway-direita_01"
                    }else {
                        //front right
                         soundName = "hallway-direita_frente_01"
                    }
                    break;
            }
            GameManager.addRoomSoundArray(soundName, frmt: "mp3", x: 0.0, y: 0.0)
        }
    }
    
    func checkStoryRequisite (action: JSON) {
        if let _ = action["hasStory"].bool {
            if (!manager.storyP[action["storyNumber"].intValue].played){
                manager.playStorySound()
            }
        }
    }
    
    func checkPrerequisite (action: JSON) -> Bool {
        if let prerequisite = action["prerequisite"].string {
            let items = gameState.items.filter( {$0 == prerequisite } )
            if (items.count > 0) {
                return true;
            } else {
                if let failPrerequisite = action["failPrerequisite"].array {
                    print("locked")
                    playSoundArray(failPrerequisite)
                }
                
                
                return false;
            }
        } else {
            return true;
        }
        
    }
    
    func checkItem (action: JSON) -> Bool {
        if let item = action["item"].string {
            let items = gameState.items.filter( {$0 == item } )
            if (items.count > 0) {
                if let hasItem = action["hasItem"].array {
                    print("hasItem")
                    playSoundArray(hasItem)
                }
                return false;
            }
        }
        
        return true;
    }

    
    // MARK: Actions

    func goToRoom (action :JSON, swipeDirection: String) {
        if (checkPrerequisite(action)) {
            
            switch swipeDirection {
            case "swipeRight":
                gameState.rotation = 1;
                break;
            case "swipeUp":
                gameState.rotation = 0;
                break;
            case "swipeLeft":
                gameState.rotation = 3;
                break;
            case "swipeDown":
                gameState.rotation = 2;
                break;
            default:
                break;
            }
            gameState.room = action["room"].intValue
            self.manager.setPlayerPosition(gameState.room)
            self.manager.updateEnemiesListenerPosition()
            gameState.updateState()
            let transition = SKTransition.fadeWithDuration(0)
            let scene = GameScene(size: self.size)
            if let recognizers = self.view?.gestureRecognizers {
                for recognizer in recognizers {
                    self.view?.removeGestureRecognizer(recognizer )
                }
            }
            
            self.view?.presentScene(scene, transition: transition)
        }
    }
    
    func pickItem (action :JSON) {
        if (checkPrerequisite(action) && checkItem(action)) {
            gameState.items.append(action["item"].stringValue)
            gameState.updateState()
            
        }
    
    }
    
    
    func playSoundArray (action : [JSON]) {
        for sound: JSON in action {
            playSound(sound.dictionaryValue)
        }
    }
    
    func playSound (action: [String: JSON]) {
        if let soundName = action["sound"]?.string {
            print(soundName)
            if let format = action["format"]?.string {
                var x:Float = 0.0;
                var y:Float = 0.0;
                if let offsetX = action["x"]?.float {
                    x = offsetX;
                }
                if let offsetY = action["y"]?.float {
                    y = offsetY;
                }
                var offset:Float = 0.0
                if let newOffset = action["offset"]?.float {
                    offset = newOffset;
                }
                runAction(
                    SKAction.sequence([
                        SKAction.waitForDuration(NSTimeInterval(offset)),
                        SKAction.runBlock({ GameManager.addSoundArray(soundName, frmt: format, x: x, y: y) })
                        ])
                    )
            }
        }

    }
    
    func presentGameOver () {
        
        let transition = SKTransition.fadeWithDuration(0)
        let scene = GameOverScene(size: self.size)
        if let recognizers = self.view?.gestureRecognizers {
            for recognizer in recognizers {
                self.view?.removeGestureRecognizer(recognizer )
            }
        }
        
        self.view?.presentScene(scene, transition: transition)
    
    }
}
