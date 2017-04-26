using UnityEngine;
using System.Collections;

namespace mattatz.GeneticAlgorithm {

	public abstract class Creature {

		public float Fitness {
            get; set;
		}

        public float NormalizedFitness
        {
            get; set;
        }
        
		public DNA DNA { get { return dna; } }

		protected DNA dna;

        public Creature () { }

		public Creature (DNA dna) {
			this.dna = dna;
		}

	}

}

