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
        this.dna = new DNA(genes);
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

    public override float ComputeFitness()
    {
        throw new NotImplementedException();
    }

    public override Creature Generate(DNA dna)
    {
        throw new NotImplementedException();
    }

    public override int GetGenesCount()
    {
        throw new NotImplementedException();
    }


}
