import 'dart:html';
import 'dart:math';

import 'package:squares/actor.dart';
import 'package:squares/scene.dart';
import 'package:squares/component.dart';
import 'package:squares/direction.dart';




CanvasElement canvas;
List<GameActor> actors;
SquaresScene scene;

void main() {
    canvas = querySelector('#canvas');
    actors = new List<GameActor>();

    Map redConfig =     {
                             "pixels_per_second": 50,
                             "color": "red",
                             "x": 320.0,
                             "y": 280.0,
                             "width": 32.0,
                             "height": 32.0
                        };

    Map blackConfig =   {
                            "pixels_per_second": 4,
                            "color": "black"
                        };

    scene = new SquaresScene(redConfig, blackConfig);

    /*
    actors.add(new Square.fromConfig(redConfig,
            new PlayerControlComponent(),
            new SquareDrawer(canvas.getContext('2d'))));

    Random r = new Random();
    int numBlacks = 20;
    for (int i = 0; i < numBlacks; i++) {

        // Randomize directions
        Map<String, dynamic> config = blackConfig;
        config['direction'] = new Direction.random(r).toList();

        window.console.log("Adding black actor: ${config}");

        actors.add(new Square.fromConfig(config,
                new AIControlComponent(),
                new SquareDrawer(canvas.getContext("2d"))));

    }
    */

    //scene.start().then((var _) =>_runInternal(null));

    window.onKeyDown.listen((KeyboardEvent e) {

        if (e.keyCode == 32) {
            int num = scene.addGameActor(scene.createBlackSquare(blackConfig, new Random()));
            querySelector("#num_squares_id").innerHtml = num.toString();
        }
    });

    scene.start();
    _runInternal(null);
}


DateTime prev = new DateTime.now();

void _runInternal(var _) {
    DateTime cur = new DateTime.now();

    update(prev, cur);
    draw();

    window.requestAnimationFrame(_runInternal);
    prev = cur;
}

void update(DateTime prev, DateTime cur) {

    scene.update(null, prev, cur);

    /*
    actors.forEach((Actor a) => a.update(prev, cur));

    // Check actors' positions for collisions
    actors.forEach((Actor a) {
        a.checkCollision(this);
    }));
    */
}

void draw() {

    CanvasRenderingContext2D c = canvas.getContext('2d');
    c.fillStyle = 'white';
    c.fillRect(0, 0, 640, 480);

    scene.draw(c);

    //actors.forEach((GameActor a) => a.draw());
}