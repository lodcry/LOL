using UnityEngine;

public class BootManager : MonoBehaviour
{
    public static BootManager Instance;

    void Awake()
    {
        if (Instance != null) { Destroy(gameObject); return; }
        Instance = this;
        DontDestroyOnLoad(gameObject);
        Application.targetFrameRate = 120;
        QualitySettings.vSyncCount = 0;
        Screen.sleepTimeout = SleepTimeout.NeverSleep;
        int qualidade = PlayerPrefs.GetInt("Qualidade", 1);
        QualitySettings.SetQualityLevel(qualidade, true);
        Debug.Log($"[BOOT] Ventory iniciado | FPS alvo: 120 | Qualidade: {(qualidade == 0 ? "Leve" : "Full")}");
    }
}
