using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotater : MonoBehaviour {

    [SerializeField] float speed = 30f;
	
	void Update () {
	}

    void FixedUpdate () {
        var t = Time.timeSinceLevelLoad;
        var nx = Mathf.PerlinNoise(t, -10f);
        var ny = Mathf.PerlinNoise(10f, t);
        var nz = Mathf.PerlinNoise(t, -t);
        transform.rotation *= Quaternion.AngleAxis(Time.fixedDeltaTime * speed, (new Vector3(nx, ny, nz)).normalized);
    }

}
