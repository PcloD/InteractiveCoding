using System;
using System.Collections;
using System.Collections.Generic;

using UnityEngine;
using Random = UnityEngine.Random;

using mattatz.GeneticAlgorithm;

public class Painter : Creature {

    List<Vector2> points;

    public Painter(int count)
    {
        var genes = new float[count * 2];
        for(int i = 0, n = genes.Length; i < n; i += 2)
        {
            genes[i] = Random.value;
            genes[i + 1] = Random.value;
        }
        dna = new DNA(genes);
		Normalize();
    }

	public Painter(DNA dna): base(dna) {
		Normalize();
	}

	void Normalize() {
		for(int i = 0, n = dna.genes.Length; i < n; i++) {
			dna.genes[i] = Mathf.Clamp01(dna.genes[i]);
		}
	}

    public List<Vector2> GetPoints (int resolution)
    {
        if (points != null) return points;
        points = new List<Vector2>();
        var genes = this.dna.genes;
        for(int i = 0, n = genes.Length; i < n; i+=2)
        {
            var x = genes[i];
            var y = genes[i + 1];
            points.Add(new Vector2(x * resolution, y * resolution));
        }
        return points;
    }

}
