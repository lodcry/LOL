using UnityEngine;
using System.Collections.Generic;
using System;

public class VentoryConsole : MonoBehaviour
{
    public static VentoryConsole Instance;

    struct LogEntry
    {
        public string msg;
        public LogType tipo;
        public string hora;
    }

    readonly List<LogEntry> logs = new();
    Vector2 scroll;
    bool visivel = false;
    bool minimizado = false;
    Rect janela = new Rect(0, 0, Screen.width, Screen.height * 0.45f);
    Rect btnAbrir;
    GUIStyle estiloLog, estiloErro, estiloWarn, estiloFundo, estiloBotao, estiloTitulo;
    bool estilosProntos = false;
    int filtro = 0;
    readonly string[] filtros = { "TUDO", "LOG", "ERRO", "WARN" };

    void Awake()
    {
        if (Instance != null) { Destroy(gameObject); return; }
        Instance = this;
        DontDestroyOnLoad(gameObject);
        Application.logMessageReceived += CapturarLog;
        AndroidLogCapture();
        btnAbrir = new Rect(Screen.width - 110, 10, 100, 40);
        Debug.Log("[CONSOLE] VentoryConsole ativo — capturando tudo");
    }

    void AndroidLogCapture()
    {
        try
        {
            using var logcat = new AndroidJavaClass("android.util.Log");
            Debug.Log("[CONSOLE] AndroidJava bridge ativo");
        }
        catch (Exception e)
        {
            Debug.LogWarning($"[CONSOLE] AndroidJava bridge: {e.Message}");
        }
    }

    void CapturarLog(string msg, string stack, LogType tipo)
    {
        logs.Add(new LogEntry
        {
            msg = msg,
            tipo = tipo,
            hora = DateTime.Now.ToString("HH:mm:ss.fff")
        });
        if (logs.Count > 500) logs.RemoveAt(0);
        if (tipo == LogType.Error || tipo == LogType.Exception)
        {
            visivel = true;
            minimizado = false;
        }
    }

    void IniciarEstilos()
    {
        if (estilosProntos) return;
        estiloFundo = new GUIStyle(GUI.skin.box);
        estiloFundo.normal.background = CriarTextura(new Color(0.05f, 0.05f, 0.1f, 0.97f));

        estiloLog = new GUIStyle(GUI.skin.label);
        estiloLog.fontSize = 11;
        estiloLog.normal.textColor = new Color(0.8f, 0.9f, 1f);
        estiloLog.wordWrap = true;

        estiloErro = new GUIStyle(estiloLog);
        estiloErro.normal.textColor = new Color(1f, 0.3f, 0.3f);

        estiloWarn = new GUIStyle(estiloLog);
        estiloWarn.normal.textColor = new Color(1f, 0.85f, 0.2f);

        estiloBotao = new GUIStyle(GUI.skin.button);
        estiloBotao.fontSize = 11;
        estiloBotao.normal.textColor = Color.white;
        estiloBotao.normal.background = CriarTextura(new Color(0.2f, 0.2f, 0.5f, 0.95f));

        estiloTitulo = new GUIStyle(GUI.skin.label);
        estiloTitulo.fontSize = 12;
        estiloTitulo.fontStyle = FontStyle.Bold;
        estiloTitulo.normal.textColor = new Color(0.4f, 0.8f, 1f);

        estilosProntos = true;
    }

    Texture2D CriarTextura(Color cor)
    {
        var t = new Texture2D(1, 1);
        t.SetPixel(0, 0, cor);
        t.Apply();
        return t;
    }

    void OnGUI()
    {
        IniciarEstilos();

        if (!visivel)
        {
            if (GUI.Button(btnAbrir, "🖥 CONSOLE", estiloBotao))
                visivel = true;
            return;
        }

        if (minimizado)
        {
            if (GUI.Button(new Rect(0, 0, 200, 36), $"▲ VENTORY LOG ({logs.Count})", estiloBotao))
                minimizado = false;
            return;
        }

        GUI.Box(janela, "", estiloFundo);
        GUILayout.BeginArea(janela);

        GUILayout.BeginHorizontal();
        GUILayout.Label("⚡ VENTORY CONSOLE", estiloTitulo, GUILayout.Width(200));
        GUILayout.FlexibleSpace();
        filtro = GUILayout.SelectionGrid(filtro, filtros, 4, estiloBotao, GUILayout.Width(240));
        GUILayout.FlexibleSpace();
        if (GUILayout.Button("LIMPAR", estiloBotao, GUILayout.Width(70))) logs.Clear();
        if (GUILayout.Button("▼ MIN", estiloBotao, GUILayout.Width(60))) minimizado = true;
        if (GUILayout.Button("✕", estiloBotao, GUILayout.Width(36))) visivel = false;
        GUILayout.EndHorizontal();

        scroll = GUILayout.BeginScrollView(scroll);
        for (int i = logs.Count - 1; i >= 0; i--)
        {
            var log = logs[i];
            if (filtro == 1 && log.tipo != LogType.Log) continue;
            if (filtro == 2 && log.tipo != LogType.Error && log.tipo != LogType.Exception) continue;
            if (filtro == 3 && log.tipo != LogType.Warning) continue;

            var estilo = log.tipo == LogType.Error || log.tipo == LogType.Exception
                ? estiloErro : log.tipo == LogType.Warning ? estiloWarn : estiloLog;
            GUILayout.Label($"[{log.hora}] {log.msg}", estilo);
        }
        GUILayout.EndScrollView();
        GUILayout.EndArea();
    }

    void OnDestroy()
    {
        Application.logMessageReceived -= CapturarLog;
    }
}
