library square;

import 'dart:html';
import 'dart:async';

import 'package:squares/component.dart';
import 'package:squares/actor.dart';
import 'package:squares/direction.dart';
import 'package:squares/scene.dart';

class BlackSquareOffscreenMessage extends GameMessage {

    BlackSquareOffscreenMessage(Square sender) : super(sender);
}

class RedSquareCollideMessage extends GameMessage {

    final Square collidedWith;

    RedSquareCollideMessage(Actor sender, this.collidedWith) : super(sender);
}

class AIControlComponent extends ControlComponent {

    void update(SquaresScene world, Square a, DateTime prev, DateTime cur) {

        Duration moveDuration = cur.difference(prev);
        double moveAmount = moveDuration.inMilliseconds * a.pixelsPerSecond / 1000.0;

        double moveX = a.direction.xComponent * a.pixelsPerSecond;
        double moveY = a.direction.yComponent * a.pixelsPerSecond;

        a.x += moveX;
        a.y += moveY;

        // check collisions
        if ((a.x + a.width < 0 || a.x >= world.width ||
                a.y + a.height < 0 || a.y >= world.height) ) {
            world.sendMessage(new BlackSquareOffscreenMessage(a));
        }
    }
}

class PlayerControlComponent extends ControlComponent {

    static const KEY_LEFT = 37;
    static const KEY_UP = 38;
    static const KEY_RIGHT = 39;
    static const KEY_DOWN = 40;

    Map<int, bool> _pressed;

    PlayerControlComponent() {
        document.onKeyDown.listen(this._onKeyDown);
        document.onKeyUp.listen(this._onKeyUp);
        document.onKeyPress.listen(this._onKeyPressed);

        this._pressed = new Map<int, bool>();
    }

    void update(SquaresScene world, Square a, DateTime prev, DateTime cur) {

        Duration moveDuration = cur.difference(prev);
        double moveAmount = moveDuration.inMilliseconds * a.pixelsPerSecond / 1000.0;

        if (this._pressed[KEY_UP] == true) {
            a.y -= moveAmount;
        }
        if (this._pressed[KEY_DOWN] == true) {
            a.y += moveAmount;
        }
        if (this._pressed[KEY_LEFT] == true) {
            a.x -= moveAmount;
        }
        if (this._pressed[KEY_RIGHT] == true) {
            a.x += moveAmount;
        }

        // Check collision asynchronously
        Timer.run(() {
            world.gameActors.forEach((Actor square) {
                if (square is! Movable) {
                    return;
                }

                Square s = square;

                if ((s.x > a.x && s.x < a.x + a.width ||
                        s.x < a.x && s.x + s.width > a.x) &&
                        (s.y > a.y && s.y < a.y + a.height ||
                        s.y < a.x && s.y + s.height > a.y)) {

                    a.sendMessage(new RedSquareCollideMessage(world, s));
                }
            });
        });
    }

    void _onKeyDown(KeyboardEvent e) {

        this._pressed[e.keyCode] = true;
    }

    void _onKeyUp(KeyboardEvent e) {

        this._pressed[e.keyCode] = false;
    }

    void _onKeyPressed(KeyboardEvent e) {

    }
}

class SquareDrawer extends DrawingComponent {

    String _color;

    void update(CanvasRenderingContext2D context, Square s) {

        String fillStyle = context.fillStyle;
        context.fillStyle = s.color;
        context.fillRect(s.x, s.y, s.width, s.height);
        context.fillStyle = fillStyle;
    }
}

class Square extends GameActor {

    int _pixelsPerSecond;
    String _color;
    Direction _dir;

    Square.fromConfig(Map config, ControlComponent cc, DrawingComponent dc) :
            super() {
        this.controlComponent = cc;
        this.drawingComponent = dc;

        this._pixelsPerSecond = config['pixels_per_second'];
        this._color = config['color'];
        this.x = this._getConfigOption(config, 'x', 320.0);
        this.y = this._getConfigOption(config, 'y', 240.0);
        this.width = this._getConfigOption(config, 'width', 16.0);
        this.height = this._getConfigOption(config, 'height', 16.0);
        List<double> dirVector = this._getConfigOption(config, 'direction', [1.0, 0.0]);
        this._dir = new Direction(dirVector[0], dirVector[1]);
    }

    dynamic _getConfigOption(Map<String, dynamic> config, String option, var defaultValue) {
        if (null == config[option]) {
            return defaultValue;
        }
        return config[option];
    }

    int get pixelsPerSecond => this._pixelsPerSecond;
    String get color => this._color;
    Direction get direction => this._dir;

    void update(SquaresScene world, DateTime prev, DateTime cur) {
        this.controlComponent.update(world, this, prev, cur);
    }

    void draw(CanvasRenderingContext2D context) {
        this.drawingComponent.update(context, this);
    }

    GameMessageResponse handleMessage(GameMessage message) {

        if (message is RedSquareCollideMessage) {

            if (this.width > message.collidedWith.width && this.width < 120) {
                this.width += message.collidedWith.width;
            } else if (this.width > 1){
                this.width -= this.width / 10;
            }

            if (this.height > message.collidedWith.height && this.height < 120) {
                this.height += message.collidedWith.height;
            } else if (this.height > 1) {
                this.height -= this.height / 10;
            }
        }

        return new GameMessageResponse(this);
    }
}