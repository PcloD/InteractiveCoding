using System.Linq;
using System.Collections;
using System.Collections.Generic;

using UnityEngine;

public class Controller : MonoBehaviour {

    [SerializeField] List<MeshRenderer> renderers;
    List<MPB> blocks;

    [SerializeField, Range(-2f, 2f)] float gain = 0.29f;
    [SerializeField, Range(-3f, 3f)] float magnitude = 1.3f;

    class MPB
    {
        Renderer renderer;
        MaterialPropertyBlock block;

        public MPB(Renderer renderer)
        {
            this.renderer = renderer;
            block = new MaterialPropertyBlock();
            this.renderer.GetPropertyBlock(block);
        }

        public void Update ()
        {
            renderer.SetPropertyBlock(block);
        }

        public void SetFloat(string key, float v, float dt)
        {
            var v0 = block.GetFloat(key);
            block.SetFloat(key, Mathf.Lerp(v0, v, dt));
        }

    }

    void Awake ()
    {
        blocks = renderers.Select(renderer =>
        {
            var block = new MPB(renderer);
            block.SetFloat("_Gain", gain, 1f);
            block.SetFloat("_Magnitude", magnitude, 1f);
            return block;
        }).ToList();
    }
	
	void Update () {
        if (blocks == null) return;

        var dt = Time.deltaTime;

        blocks.ForEach(block =>
        {
            block.SetFloat("_Gain", gain, dt);
            block.SetFloat("_Magnitude", magnitude, dt);
            block.Update();
        });

	}

}
