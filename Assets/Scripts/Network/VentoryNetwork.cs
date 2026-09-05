using UnityEngine;
using System;
using System.Text;
using System.Collections;
using UnityEngine.Networking;

public class VentoryNetwork : MonoBehaviour
{
    public static VentoryNetwork Instance;
    public static string Token;
    public static string NomeJogador;
    const string BASE_URL = "https://ventory-worker.daitonaer.workers.dev";

    void Awake()
    {
        if (Instance != null) { Destroy(gameObject); return; }
        Instance = this;
        DontDestroyOnLoad(gameObject);
    }

    public void Registrar(string nome, string senha, Action<bool, string> callback)
    {
        StartCoroutine(Post("/register", $"{{\"nome\":\"{nome}\",\"senha\":\"{senha}\"}}", (ok, resp) =>
        {
            Debug.Log($"[NET] Register → {resp}");
            if (ok)
            {
                var r = JsonUtility.FromJson<RespostaAuth>(resp);
                Token = r.token;
                NomeJogador = r.nome;
            }
            callback(ok, resp);
        }));
    }

    public void Login(string nome, string senha, Action<bool, string> callback)
    {
        StartCoroutine(Post("/login", $"{{\"nome\":\"{nome}\",\"senha\":\"{senha}\"}}", (ok, resp) =>
        {
            Debug.Log($"[NET] Login → {resp}");
            if (ok)
            {
                var r = JsonUtility.FromJson<RespostaAuth>(resp);
                Token = r.token;
                NomeJogador = r.nome;
            }
            callback(ok, resp);
        }));
    }

    IEnumerator Post(string rota, string json, Action<bool, string> callback)
    {
        Debug.Log($"[NET] POST {BASE_URL}{rota}");
        var req = new UnityWebRequest(BASE_URL + rota, "POST");
        req.uploadHandler = new UploadHandlerRaw(Encoding.UTF8.GetBytes(json));
        req.downloadHandler = new DownloadHandlerBuffer();
        req.SetRequestHeader("Content-Type", "application/json");
        if (!string.IsNullOrEmpty(Token))
            req.SetRequestHeader("Authorization", $"Bearer {Token}");
        yield return req.SendWebRequest();
        bool ok = req.result == UnityWebRequest.Result.Success;
        if (!ok) Debug.LogError($"[NET] ERRO {req.responseCode}: {req.error}");
        callback(ok, req.downloadHandler.text);
    }

    [Serializable] class RespostaAuth { public bool sucesso; public string token; public string nome; public string erro; }
}
