using UnityEngine;
using System;
using System.Collections;
using System.Text;

public class SalaWebSocket : MonoBehaviour
{
    const string WS_URL = "wss://ventory-worker.daitonaer.workers.dev/sala";
    bool conectado = false;

    void Start()
    {
        StartCoroutine(Conectar());
    }

    IEnumerator Conectar()
    {
        Debug.Log("[WS] Conectando à sala...");
        yield return new WaitForSeconds(0.5f);
        Debug.Log("[WS] WebSocket pronto — aguardando implementação nativa Android");
        conectado = true;
    }

    public void EnviarPosicao(float x, float y)
    {
        if (!conectado) return;
        string msg = $"{{\"tipo\":\"mover\",\"x\":{x:F2},\"y\":{y:F2}}}";
        Debug.Log($"[WS] Enviando posição: {msg}");
    }

    void OnDestroy()
    {
        Debug.Log("[WS] WebSocket desconectado");
    }
}
