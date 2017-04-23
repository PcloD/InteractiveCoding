using UnityEngine;
using System.Collections;

namespace mattatz.GeneticAlgorithm {

	public abstract class Creature {

		public float Fitness { 
			get { return fitness; } 
			set { fitness = value; } 
		}
		public DNA DNA { get { return dna; } }

		protected DNA dna;
		protected float fitness;

        public Creature () { }

		public Creature (DNA dna) {
			this.dna = dna;
		}

	}

}

