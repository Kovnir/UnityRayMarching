using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(ParticleSystem))]
[ExecuteAlways]
public class RayMarchingParticles : MonoBehaviour
{
    private const int PARTICLES_SIZE = 100;
    [SerializeField] private MeshRenderer renderer;
    
    private Material material;
    private ParticleSystem particleSystem;
    ParticleSystem.Particle[] particles = new ParticleSystem.Particle[PARTICLES_SIZE];
    List<Vector4> buffer = new List<Vector4>(PARTICLES_SIZE);
    private static readonly int Particles = Shader.PropertyToID("particles");

    private void Awake()
    {
        particleSystem = GetComponent<ParticleSystem>();
        GetComponent<ParticleSystemRenderer>().enabled = false;
    }

    private void Update()
    {
        if (!EnsureMaterialExist())
        {
            return;
        }
        int numParticlesAlive = particleSystem.GetParticles(particles);
        buffer.Clear();
        for (int i = 0; i < PARTICLES_SIZE; i++)
        {
            if (i < numParticlesAlive)
            {
                var particle = particles[i];
                Vector3 position = transform.TransformDirection(particle.position);
                buffer.Add(new Vector4(position.x, position.y, position.z, particle.GetCurrentSize(particleSystem)));
            }
            else
            {
                buffer.Add(Vector4.zero);
            }
        }

        material.SetVectorArray(Particles, buffer);
    }

    private bool EnsureMaterialExist()
    {
        if (material == null)
        {
            if (renderer == null)
            {
                return false;
            }

            material = renderer.sharedMaterial;

            if (material == null)
            {
                return false;
            }
        }
        return true;
    }
}
