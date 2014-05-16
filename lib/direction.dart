library direction;

import 'dart:math';

class Direction {

    double _xComponent;
    double _yComponent;

    Direction(this._xComponent, this._yComponent);

    factory Direction.random([Random r = null]) {

        if (null == r) {
            r = new Random();
        }

        double xSpeed = 1.0 - 2.0 * r.nextDouble();
        double ySpeed = sqrt(1.0 - pow(xSpeed, 2));
        if (r.nextBool()) {
            ySpeed = -1 * ySpeed;
        }

        return new Direction(xSpeed, ySpeed);
    }

    double get xComponent => this._xComponent;
    double get yComponent => this._yComponent;

    List<double> toList() => [ this.xComponent, this.yComponent ];
}