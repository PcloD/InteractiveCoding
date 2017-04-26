using System;
using System.Collections;
using System.Collections.Generic;

using UnityEngine;
using Random = UnityEngine.Random;

using mattatz.GeneticAlgorithm;

public class Nematode : Creature {

    List<Vector2> points;

    public Nematode(int count)
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

	public Nematode(DNA dna): base(dna) {
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

	public Texture2D GetTexture () {
		int w = this.dna.genes.Length / 2;
		var tex = new Texture2D(w, 1, TextureFormat.RGBAFloat, false);
		for(int x = 0; x < w; x++) {
			int idx = x * 2;

			// 0.0 ~ 1.0
			var nx = this.dna.genes[idx];
			var ny = this.dna.genes[idx + 1];
			tex.SetPixel(x, 0, new Color(nx, ny, NormalizedFitness));
		}
		tex.Apply();

		return tex;
	}

}
