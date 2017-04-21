using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Spline {

    public static Vector3 GetPosition(float t, Vector3 p0, Vector3 p1, Vector3 p2, Vector3 p3)
    {
        var tm1 = t - 1f;
        var tm2 = tm1 * tm1;
        var t2 = t * t;

        var m1 = 0.5f * (p2 - p0);
        var m2 = 0.5f * (p3 - p1);

        return (1f + 2f * t) * tm2 * p1 + t * tm2 * m1 + t2 * (3 - 2f * t) * p2 + t2 * tm1 * m2;
    }

}
