using System.Linq;
using System.Collections;
using System.Collections.Generic;

using UnityEngine;

using mattatz.Utils;
using mattatz.GeneticAlgorithm;

public class GeneticAlgorithm : MonoBehaviour {

	public int Generations { get { return generations; } }
	public int Strokes { get { return strokes; } }
	public List<Nematode> Nematodes { get { return nematodes; } }

	[SerializeField] float mutationRate = 0.2f;
	[SerializeField, Range(0f, 0.2f)] float mutationScale = 0.05f;
	[SerializeField] int count = 50;
	[SerializeField] int strokes = 20;
	int generations = 0;

    [SerializeField] Texture2D source = null;
    [SerializeField] Texture2D dst = null;
    [SerializeField] int resolution = 32;
	[SerializeField] Gradient grad;

	[SerializeField, Range(2, 10)] int frequency = 4;
	[SerializeField] bool automatic = true;
	[SerializeField] bool showTexture;

	List<Nematode> nematodes;
    Color[] pixels;

	public void Setup () {
		if(nematodes != null) nematodes.Clear();

		generations = 0;

		nematodes = new List<Nematode>();

		for(int i = 0; i < count; i++) {
			var painter = new Nematode(strokes);
			nematodes.Add(painter);
		}

		dst = Compress(source);
		pixels = dst.GetPixels();

        ComputeFitnesses();
	}

	void Awake () {
		Setup();
	}
	
	void Update () {
		if(Input.GetKey(KeyCode.E)) {
			Evolve();
		} else if(automatic && Time.frameCount % frequency == 0) {
			Evolve();
		}

		if(Input.GetKeyDown(KeyCode.Space)) {
			Setup();
		}
	}

    Texture2D Compress(Texture2D source)
    {
        var prev = RenderTexture.active;

        var rt = new RenderTexture(resolution, resolution, 0);
        var dst = new Texture2D(resolution, resolution);
        Graphics.Blit(source, rt);
        {
            RenderTexture.active = rt;
            dst.ReadPixels(new Rect(0, 0, resolution, resolution), 0, 0);
            dst.Apply();
        }

        RenderTexture.active = prev;

        rt.Release();
        return dst;
    }

	void Evolve() {
		generations++;

		nematodes = Reproduction();
        ComputeFitnesses();
	}

	List<Nematode> Selection () {
		var pool = new List<Nematode>();
		nematodes.ForEach(c => {
			int n = Mathf.FloorToInt(c.NormalizedFitness * 50);
			for(int j = 0; j < n; j++) {
				pool.Add(c);
			}
		});
		return pool;
	}

	List<Nematode> Reproduction () {
		var pool = Selection();
		if(pool.Count <= 0) {
			Debug.LogWarning("mating pool is empty.");
		}

		var next = new List<Nematode>();

		for(int i = 0, n = nematodes.Count; i < n; i++) {
			int m = Random.Range(0, pool.Count);
			int d = Random.Range(0, pool.Count);

			DNA mom = pool[m].DNA;
			DNA dad = pool[d].DNA;

			DNA child = mom.Crossover(dad);
			child.Mutate(mutationRate, mutationScale);

			next.Add(new Nematode(child));
		}

		return next;
	}

	float GetMaxFitness() {
		float max = 0f;
		nematodes.ForEach(creature => {
			var fitness = creature.Fitness;
			if(fitness > max) {
				max = fitness;
			}
		});
		return max;
	}

	bool Fit(int x, int y) {
		if(x < 0 || x >= resolution || y < 0 || y >= resolution) return false;
		var color = pixels[y * resolution + x];
		return color.a > 0.5f;
		// return color.a < 0.1f;
	}

    void ComputeFitnesses()
    {
		nematodes.ForEach(painter => { ComputeFitness(painter); });
		float maxFitness = GetMaxFitness();
        nematodes.ForEach(painter =>
        {
            painter.NormalizedFitness = painter.Fitness / maxFitness;
        });
    }

    void ComputeFitness(Nematode painter)
    {
		var fitness = new Dictionary<int, bool>();
        var points = painter.GetPoints(resolution);

		const int fineness = 10;
		const float step = 1f / fineness;

        for(int i = 1, n = points.Count; i < n; i++)
        {
            var i0 = i - 1;
            var i1 = i;
            var i2 = (i + 1) % n;
            var i3 = (i + 2) % n;

            for(var t = 0f; t < 1f; t += step)
            {
                var p0 = Spline.GetPosition(t, points[i0], points[i1], points[i2], points[i3]);
                var p1 = Spline.GetPosition(t + step, points[i0], points[i1], points[i2], points[i3]);
                var dir = (p1 - p0);
                var norm = dir.normalized;
                var m = dir.magnitude;
                for(var tt = 0f; tt < 1f; tt += step)
                {
					var p = p0 + norm * m * tt;
					int x = Mathf.FloorToInt(p.x);
					int y = Mathf.FloorToInt(p.y);
					int address = y * resolution + x;
					/*
					if(Fit(x, y) && !fitness.ContainsKey(address)) {
						fitness[address] = true;
					}

					*/
					bool fit = Fit(x, y);
					if(!fitness.ContainsKey(address)) {
						fitness[address] = fit;
					} else {
						fitness[address] &= fit;
					}
                }
            }
        }

		// painter.Fitness = (1f * fitness.Values.ToList().FindAll((v) => v).Count) / (points.Count * fineness * fineness);
		var values = fitness.Values.ToList();
		painter.Fitness = (1f * values.FindAll((v) => v).Count) / values.Count;
    }

	void DrawPainterGizmos (Nematode painter)
    {
        var points = painter.GetPoints(resolution);
        const float step = 0.1f;

        for(int i = 1, n = points.Count; i < n; i++)
        {
            var i0 = i - 1;
            var i1 = i;
            var i2 = (i + 1) % n;
            var i3 = (i + 2) % n;

            for(var t = 0f; t < 1f; t += step)
            {
                var p0 = Spline.GetPosition(t, points[i0], points[i1], points[i2], points[i3]);
                var p1 = Spline.GetPosition(t + step, points[i0], points[i1], points[i2], points[i3]);
                Gizmos.DrawLine(p0, p1);

				/*
				var dir = (p1 - p0);
				var norm = dir.normalized;
				var m = dir.magnitude;
				for(var tt = 0f; tt < 1f; tt += step)
				{
					var p = p0 + norm * m * tt;
					int x = Mathf.FloorToInt(p.x);
					int y = Mathf.FloorToInt(p.y);
					int address = y * resolution + x;
					if(Fit(x, y)) {
						Gizmos.DrawSphere(p, 0.1f);
					}
				}
				*/
            }
        }
    }

    void OnDrawGizmos ()
    {
		#if UNITY_EDITOR

		UnityEditor.Handles.Label(Vector3.zero, "generations: " + generations.ToString());
		UnityEditor.Handles.Label(new Vector3(0f, -1f, 0f), "populations: " + count);

		#endif

		/*
        var l = resolution - 1; 
        for(int y = 0; y < resolution; y++)
        {
            for(int x = 0; x < resolution; x++)
            {
                if(x < l)
                {
                    Gizmos.DrawLine(new Vector3(x, y, 0f), new Vector3(x + 1f, y, 0f));
                }
                if(y < l)
                {
                    Gizmos.DrawLine(new Vector3(x, y, 0f), new Vector3(x, y + 1f, 0f));
                }
            }
        }
		*/

		/*
        if (nematodes == null) return;
		for(int i = 0, n = painters.Count; i < n; i++) {
			var painter = painters[i];
			var t = 1f * i / n;
			var color = grad.Evaluate(t);
			color.a *= Mathf.Lerp(0.5f, 1f, t);
			Gizmos.color = color;
            DrawPainterGizmos(painter);
		}
		*/

		if(showTexture) {
			Gizmos.DrawGUITexture(new Rect(-0.5f, -0.5f, 1, 1), source);
		}

    }

}
