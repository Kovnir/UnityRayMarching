using UnityEngine;

[ExecuteAlways]
public class RayMarchingCanvas : MonoBehaviour
{
    private static readonly int directionLightProperty = Shader.PropertyToID("_DirectionLight");
    private static readonly int directionLightColorProperty = Shader.PropertyToID("_DirectionLightColor");
    private static readonly int pointLightProperty = Shader.PropertyToID("_PointLight");
    private static readonly int pointLightRangeProperty = Shader.PropertyToID("_PointLightRange");
    private static readonly int pointLightColorProperty = Shader.PropertyToID("_PointLightColor");

    [SerializeField] 
    private Light pointLight;
    [SerializeField]
    private Light directionalLight;
    
    private Material material;

    void Awake()
    {
        material = GetComponent<MeshRenderer>().sharedMaterial;
    }

    void Update()
    {
        if (directionalLight == null || !directionalLight.isActiveAndEnabled)
        {
            material.SetVector(directionLightProperty, Vector4.zero);
        }
        else
        {
            Pass(directionalLight.transform.forward, directionalLight.intensity, directionalLight.color, true);
        }
        if (pointLight == null || !pointLight.isActiveAndEnabled)
        {
            material.SetVector(pointLightProperty, Vector4.zero);
        }
        else
        {
            Pass(pointLight.transform.position, pointLight.intensity, pointLight.color, false);
            material.SetFloat(pointLightRangeProperty, pointLight.range);
        }
    }

    private void Pass(Vector3 point, float intensity, Color color, bool isDirectional)
    {
        Vector4 directional = point;
        directional.w = intensity;
        material.SetVector(isDirectional ? directionLightProperty : pointLightProperty, directional);
        material.SetColor(isDirectional ?directionLightColorProperty : pointLightColorProperty, color);

    }
}
