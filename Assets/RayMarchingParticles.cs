using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(ParticleSystem))]
[ExecuteAlways]
public class RayMarchingParticles : MonoBehaviour
{
    [SerializeField] private MeshRenderer renderer;
    
    private Material material;
    private ParticleSystem particleSystem;
    ParticleSystem.Particle[] particles = new ParticleSystem.Particle[500];
    List<Vector4> buffer = new List<Vector4>(500);
    private static readonly int Particles = Shader.PropertyToID("particles");

    void Awake()
    {
        particleSystem = GetComponent<ParticleSystem>();
        GetComponent<ParticleSystemRenderer>().enabled = false;
//        particleSystem.re
    }

    // Update is called once per frame
    void Update()
    {
        if (!EnsureMaterialExist())
        {
            return;
        }
        int numParticlesAlive = particleSystem.GetParticles(particles);
        buffer.Clear();
        for (int i = 0; i < numParticlesAlive; i++)
        {
                var particle = particles[i];
                Vector3 position = transform.TransformDirection(particle.position);
//                Vector3 position = transform.localToWorldMatrix * particle.position;
                buffer.Add(new Vector4(position.x,position.y,position.z,particle.GetCurrentSize(particleSystem)));
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
