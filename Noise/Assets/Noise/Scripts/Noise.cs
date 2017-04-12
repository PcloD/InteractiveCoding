using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace InteractiveCoding {

	using Utils;

	[RequireComponent (typeof(Camera))]
	public class Noise : MonoBehaviour {

		public enum Pass {
			Displace = 0,
			Visualize = 1
		};

		protected Texture2D source {
			get {
				return sources[current % sources.Count];
			}
		}

		[SerializeField] List<Texture2D> sources;
		[SerializeField] Cubemap map;
		[SerializeField] protected Shader shader;
		[SerializeField] Vector3 lightDir;

		[SerializeField] Material m;

		protected int current = 0;
		FboPingPong fbo;

		void Start () {
			CheckInit();
		}

		void Update () {
			lightDir.x = Mathf.Sin(Time.timeSinceLevelLoad) * 0.5f;
			lightDir.y = Mathf.Cos(Time.timeSinceLevelLoad * 0.25f);
			m.SetVector("_LightDirection", lightDir);
			Graphics.Blit(fbo.GetReadTex(), fbo.GetWriteTex(), m, (int)Pass.Displace);
			fbo.Swap();
		}

		void OnRenderImage(RenderTexture src, RenderTexture dst) {
			CheckInit();

			var ratio = (1f * Screen.width) / Screen.height;
			m.SetFloat("_Ratio", ratio);
			Graphics.Blit(fbo.GetReadTex(), dst, m, (int)Pass.Visualize);
		}

		void CheckInit () {
			if(m == null) {
				m = new Material(shader);
				m.SetTexture("_OriginTex", source);
				m.SetTexture("_CubeMap", map);
				lightDir = m.GetVector("_LightDirection");
			}

			if(fbo == null) {
				fbo = new FboPingPong(Screen.width, Screen.height, FilterMode.Trilinear, TextureWrapMode.Repeat);
				Graphics.Blit(source, fbo.GetReadTex());
			}
		}

		public void Pressure () {
			current++;
			m.SetTexture("_OriginTex", source);
			StartCoroutine(IPressure(3f));
		}

		IEnumerator IPressure (float duration) {
			float time = 0f;
			while(time < duration) {
				yield return 0;

				time += Time.deltaTime;
				m.SetFloat("_Beta", 0.05f);
			}

			m.SetFloat("_Beta", 0f);
		}

		void OnDestroy () {
			Destroy(m);
		}

	}
		
}

