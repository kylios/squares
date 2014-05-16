library actor;

import 'dart:async';
import 'dart:html';

import 'package:squares/component.dart';
import 'package:squares/scene.dart';

class GameMessage {

    final Actor sender;

    GameMessage(this.sender);
}

class GameMessageResponse {

    final Actor receiver;

    GameMessageResponse(this.receiver);
}

/**
 * Represents a game actor or entity that needs to send and receive messages
 * from other entities.
 */
abstract class Actor {

    StreamController<GameMessage> _messageStream = new StreamController<GameMessage>();

    /**
     * Send a message to this actor.  The message will be processed asynchronously,
     * so the response is returned in a future.
     */
    Future<GameMessageResponse> sendMessage(GameMessage message) =>
            new Future.delayed(new Duration(), () => this.handleMessage(message));

    /**
     * Abstract method, should be overridden by any child class.  Handle a
     * game message and return a response
     */
    GameMessageResponse handleMessage(GameMessage message);

    /**
     * Stream to listen on for messages produced by this actor.
     */
    Stream<GameMessage> get messageStream => this._messageStream.stream;

    /**
     * Broadcast a message to any subscribers that might be listening.
     */
    void broadcastMessage(GameMessage message) => this._messageStream.add(message);

    /**
     * Update this object by timestamps
     */
    void update(Scene world, DateTime prev, DateTime cur);
}

abstract class Movable {

    ControlComponent controlComponent;

    double x;
    double y;
    double width;
    double height;

    void update(Scene world, DateTime prev, DateTime cur) =>
            this.controlComponent.update(world, this, prev, cur);
}

abstract class Drawable {

    DrawingComponent drawingComponent;

    void draw(CanvasRenderingContext2D context) => this.drawingComponent.update(context, this);
}

abstract class GameActor extends Actor with Drawable, Movable {

}