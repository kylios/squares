library component;

import 'dart:html';

import 'package:squares/actor.dart';
import 'package:squares/scene.dart';

abstract class Component extends Actor {

    Actor _currentActor;
    Actor get currentActor => this._currentActor;

    Component attach(Actor cur) {
        this._currentActor = cur;
        return this;
    }

    void update(Scene world, DateTime prev, DateTime cur);
}

abstract class ControlComponent {

    void update(Scene world, Movable a, DateTime prev, DateTime cur);
}

abstract class DrawingComponent {

    void update(CanvasRenderingContext2D context, Drawable a);
}

abstract class CollisionComponent {

    bool checkCollision(Movable a, Scene scene);

     onCollision(Movable a, Scene scene);
}