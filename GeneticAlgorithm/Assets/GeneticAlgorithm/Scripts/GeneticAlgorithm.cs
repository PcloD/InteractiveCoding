using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using mattatz.GeneticAlgorithm;

public class GeneticAlgorithm : MonoBehaviour {

    [SerializeField] Texture2D source = null;
    [SerializeField] Texture2D dst = null;
    [SerializeField] int resolution = 32;

    List<Vector3> points;
    List<Painter> painters;
    Color[] pixels;

	void Start () {
        painters = new List<Painter>();
        for(int i = 0; i < 50; i++)
        {
            var painter = new Painter(50);
            painters.Add(painter);
        }

        dst = Compress(source);
        pixels = dst.GetPixels();

        points = new List<Vector3>();
        for(int i = 0; i < 20; i++)
        {
            points.Add(new Vector3(Random.value * resolution, Random.value * resolution, 0f));
        }
	}
	
	void Update () {
	}

    Texture2D Compress(Texture2D source)
    {
        var rt = new RenderTexture(resolution, resolution, 0);
        var dst = new Texture2D(resolution, resolution);
        Graphics.Blit(source, rt);

        var prev = RenderTexture.active;
        {
            RenderTexture.active = rt;
            dst.ReadPixels(new Rect(0, 0, resolution, resolution), 0, 0);
            dst.Apply();
        }
        RenderTexture.active = prev;

        rt.Release();
        return dst;
    }

    void ComputeFitness(Painter painter)
    {
        var points = painter.GetPoints(resolution);
        for(int i = 1, n = points.Count; i < n; i++)
        {
            var i0 = i - 1;
            var i1 = i;
            var i2 = (i + 1) % n;
            var i3 = (i + 2) % n;

            const float step = 0.1f;
            for(var t = 0f; t < 1f; t += step)
            {
                var p0 = Spline.GetPosition(t, points[i0], points[i1], points[i2], points[i3]);
                var p1 = Spline.GetPosition(t + step, points[i0], points[i1], points[i2], points[i3]);
                var dir = (p1 - p0);
                var norm = dir.normalized;
                var m = dir.magnitude;
                for(var tt = 0f; tt < 1f; tt += step)
                {
                    // Gizmos.DrawLine(p0, p1);
                }
            }
        }

        /*
        var genes = painter.DNA.genes;
        for(int i = 0, n = genes.Length; i < n; i+=2)
        {
        }
        */
    }

    void DrawPainterGizmos (Painter painter)
    {
        var points = painter.GetPoints(resolution);

        for(int i = 1, n = points.Count; i < n; i++)
        {
            var i0 = i - 1;
            var i1 = i;
            var i2 = (i + 1) % n;
            var i3 = (i + 2) % n;

            Gizmos.color = Color.red;
            const float step = 0.1f;
            for(var t = 0f; t < 1f; t += step)
            {
                var p0 = Spline.GetPosition(t, points[i0], points[i1], points[i2], points[i3]);
                var p1 = Spline.GetPosition(t + step, points[i0], points[i1], points[i2], points[i3]);
                Gizmos.DrawLine(p0, p1);
            }
        }
    }

    void OnDrawGizmos ()
    {
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

        if (painters == null) return;
        painters.ForEach(painter =>
        {
            DrawPainterGizmos(painter);
        });
    }

}
