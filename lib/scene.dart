library scene;

import 'dart:async';
import 'dart:math';
import 'dart:html';

import 'package:squares/actor.dart';
import 'package:squares/direction.dart';
import 'package:squares/square.dart';

abstract class Scene extends Actor {

    List<GameActor> get gameActors;
    List<Actor> get actors;

    void start();
    void stop();
    void update(Scene world, DateTime prev, DateTime cur);
    void draw(CanvasRenderingContext2D context);
}

class SquaresScene extends Scene {

    Map _redConfig;
    Map _blackConfig;

    SquareDrawer _squareDrawer;
    AIControlComponent _aiControlComponent;
    PlayerControlComponent _playerControlComponent;

    List<GameActor> _actors;

    List<GameActor> get gameActors => this._actors;
    List<GameActor> get actors => null;

    int get width => 640;
    int get height => 480;

    SquaresScene(this._redConfig, this._blackConfig) :
                this._squareDrawer = new SquareDrawer(),
                this._aiControlComponent = new AIControlComponent(),
                this._playerControlComponent = new PlayerControlComponent()
                ;

    void start() {

        Completer c = new Completer();

        this._actors = new List<GameActor>();
        this._actors.add(new Square.fromConfig(this._redConfig,
                    this._playerControlComponent,
                    this._squareDrawer));

        Random r = new Random();
        int numBlacks = 1;
        for (int i = 0; i < numBlacks; i++) {

            Square blackSquare = this.createBlackSquare(this._blackConfig, r);
            this._actors.add(blackSquare);
            //Timer.run(c.complete);
        }

        //return c.future;
    }

    int addGameActor(Actor actor) {
        this._actors.add(actor);
        return this._actors.length;
    }

    Square createBlackSquare(Map<String, dynamic> config, Random r) {

        // Randomize directions
        config['direction'] = new Direction.random(r).toList();
        config['width'] = r.nextDouble() * 58;
        config['height'] = r.nextDouble() * 58;
        config['x'] = (r.nextBool() ? -1 * config['width'] : this.width.toDouble());
        config['y'] = (r.nextBool() ? -1 * config['height'] : this.height.toDouble());
        window.console.log("Adding black actor: ${config}");

        return new Square.fromConfig(config,
                this._aiControlComponent,
                this._squareDrawer);
    }

    void stop() {

        //return new Future.delayed(new Duration());
    }

    void update(Scene world, DateTime prev, DateTime cur) {

        this._actors.forEach((GameActor a) => a.update(this, prev, cur));
    }

    void draw(CanvasRenderingContext2D context) {

        this._actors.forEach((GameActor a) => a.drawingComponent.update(context, a)); //a.draw(context))*/;
    }

    GameMessageResponse handleMessage(GameMessage message) {

        if (message is BlackSquareOffscreenMessage) {
            this._actors.remove(message.sender);

            this._actors.add(this.createBlackSquare(this._blackConfig, new Random()));
        }

        return new GameMessageResponse(this);
    }
}