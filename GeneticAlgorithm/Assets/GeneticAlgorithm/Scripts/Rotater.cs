using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotater : MonoBehaviour {

	[SerializeField] float speed = 10f;

	void FixedUpdate () {
		transform.localRotation *= Quaternion.AngleAxis(Time.fixedDeltaTime * speed, Vector3.forward);
	}

}
