using System.Collections;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.UI;

[RequireComponent (typeof(MeshFilter), typeof(MeshRenderer))]
public class Visualizer : MonoBehaviour {

	[SerializeField] GeneticAlgorithm ga;
	[SerializeField] Text generationsLabel;

	[SerializeField] int count = 64;
	[SerializeField] Shader shader;

	[SerializeField] Texture2DArray array;
	[SerializeField] FboPingpong lines;
	[SerializeField] Gradient grad;

	[SerializeField] Texture2D feedback;

	Material updateMat;
	Material visualizeMat;

	enum LinesRenderMode {
		Init = 0,
		Update = 1,
		Birth = 2,
	};

	void Start () {
		updateMat = new Material(shader);
		visualizeMat = GetComponent<MeshRenderer>().sharedMaterial;

		Build();
	}
	
	void Update () {
		generationsLabel.text = ga.Generations.ToString();

		Graphics.Blit(lines.ReadTex, lines.WriteTex, updateMat, (int)LinesRenderMode.Update);
		lines.Swap();

		var prev = RenderTexture.active;
		{
			RenderTexture.active = lines.ReadTex;
			feedback.ReadPixels(new Rect(0.0f, 0.0f, count, 1), 0, 0);
			feedback.Apply();

			for(int x = 0; x < count; x++) {
				var line = feedback.GetPixel(x, 0);
				if(line.r >= 1f) {
					Reset(x);
				}
			}
		}
		RenderTexture.active = prev;

		Graphics.Blit(lines.ReadTex, lines.WriteTex, updateMat, (int)LinesRenderMode.Birth);
		lines.Swap();
	}

	void Reset(int index) {
		var cr = ga.Nematodes[index % ga.Nematodes.Count];
		Graphics.CopyTexture(cr.GetTexture(), 0, 0, array, index, 0);
		array.Apply();
	}

	void Build() {
		array = new Texture2DArray(ga.Strokes, 1, count, TextureFormat.RGBAFloat, false);
		array.Apply();

		lines = new FboPingpong(count, 1, RenderTextureFormat.ARGB32, FilterMode.Point);
		Graphics.Blit(null, lines.ReadTex, updateMat, (int)LinesRenderMode.Init);

		feedback = new Texture2D(count, 1, TextureFormat.ARGB32, false);
		feedback.filterMode = FilterMode.Point;
		feedback.Apply();

		for(int i = 0; i < count; i++) {
			var cr = ga.Nematodes[i % ga.Nematodes.Count];
			Graphics.CopyTexture(cr.GetTexture(), 0, 0, array, i, 0);
		}
		array.Apply();

		var gradTex = new Texture2D(count, 1);
		for(int i = 0; i < count; i++) {
			gradTex.SetPixel(i, 0, grad.Evaluate(1f * i / count));
		}
		gradTex.Apply();

		visualizeMat.SetTexture("_Lines", lines.ReadTex);
		visualizeMat.SetTexture("_Nematodes", array);
		visualizeMat.SetFloat("_Depth", count);
		visualizeMat.SetVector("_Strokes", new Vector4(ga.Strokes, 1f / ga.Strokes, (1f / ga.Strokes) * 0.5f, -1f));
		visualizeMat.SetTexture("_Gradient", gradTex);

		var mesh = new Mesh();
		var vertices = new Vector3[count];
		var uv = new Vector2[count];
		var inv = 1f / count;
		var hinv = inv * 0.5f;
		var indices = new int[count];

		for(int i = 0; i < count; i++) {
			var idx = i;
			var t = i * inv + hinv;
			vertices[idx] = Random.insideUnitSphere;
			uv[idx] = new Vector2(0f, t);
			indices[idx] = idx;
		}

		mesh.vertices = vertices;
		mesh.uv = uv;
		mesh.SetIndices(indices, MeshTopology.Points, 0);
		mesh.RecalculateBounds();

		GetComponent<MeshFilter>().sharedMesh = mesh;
	}

	void OnGUI () {
		// GUI.DrawTexture(new Rect(10, 10, 100, 100), points);
		for(int i = 0, n = array.depth; i < n; i++) {
		}
	}

}
