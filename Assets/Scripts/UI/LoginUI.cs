using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.SceneManagement;
using System.Collections;

public class LoginUI : MonoBehaviour
{
    [Header("Campos")]
    public TMP_InputField campoNome;
    public TMP_InputField campoSenha;
    public Button btnEntrar;
    public Button btnRegistrar;

    [Header("Feedback")]
    public TMP_Text txtStatus;
    public Image painelStatus;
    public GameObject loadingSpinner;

    [Header("Visual")]
    public CanvasGroup canvasGeral;
    public RectTransform painelLogin;

    bool processando = false;

    void Start()
    {
        Application.targetFrameRate = 120;
        QualitySettings.vSyncCount = 0;

        if (VentoryConsole.Instance == null)
        {
            var go = new GameObject("VentoryConsole");
            go.AddComponent<VentoryConsole>();
        }

        if (VentoryNetwork.Instance == null)
        {
            var go = new GameObject("VentoryNetwork");
            go.AddComponent<VentoryNetwork>();
        }

        if (BootManager.Instance == null)
        {
            var go = new GameObject("BootManager");
            go.AddComponent<BootManager>();
        }

        btnEntrar.onClick.AddListener(OnEntrar);
        btnRegistrar.onClick.AddListener(OnRegistrar);
        campoSenha.contentType = TMP_InputField.ContentType.Password;

        SetStatus("", false);
        if (loadingSpinner) loadingSpinner.SetActive(false);

        StartCoroutine(AnimacaoEntrada());
        Debug.Log("[LOGIN] Tela de login iniciada");
    }

    IEnumerator AnimacaoEntrada()
    {
        canvasGeral.alpha = 0;
        painelLogin.localScale = Vector3.one * 0.85f;
        float t = 0;
        while (t < 0.6f)
        {
            t += Time.deltaTime;
            float p = t / 0.6f;
            canvasGeral.alpha = p;
            painelLogin.localScale = Vector3.Lerp(Vector3.one * 0.85f, Vector3.one, p);
            yield return null;
        }
        canvasGeral.alpha = 1;
        painelLogin.localScale = Vector3.one;
    }

    void OnEntrar()
    {
        if (processando) return;
        string nome = campoNome.text.Trim();
        string senha = campoSenha.text;
        if (string.IsNullOrEmpty(nome) || string.IsNullOrEmpty(senha))
        {
            SetStatus("Preencha nome e senha", true);
            return;
        }
        processando = true;
        SetStatus("Conectando...", false);
        if (loadingSpinner) loadingSpinner.SetActive(true);
        btnEntrar.interactable = false;
        btnRegistrar.interactable = false;
        Debug.Log($"[LOGIN] Tentando login: {nome}");
        VentoryNetwork.Instance.Login(nome, senha, (ok, resp) =>
        {
            processando = false;
            if (loadingSpinner) loadingSpinner.SetActive(false);
            btnEntrar.interactable = true;
            btnRegistrar.interactable = true;
            if (ok && resp.Contains("sucesso"))
            {
                SetStatus($"Bem-vindo, {VentoryNetwork.NomeJogador}!", false);
                Debug.Log($"[LOGIN] Login OK → {VentoryNetwork.NomeJogador}");
                StartCoroutine(EntrarNaPartida());
            }
            else
            {
                SetStatus("Nome ou senha incorretos", true);
                Debug.LogError($"[LOGIN] Falha: {resp}");
            }
        });
    }

    void OnRegistrar()
    {
        if (processando) return;
        string nome = campoNome.text.Trim();
        string senha = campoSenha.text;
        if (string.IsNullOrEmpty(nome) || string.IsNullOrEmpty(senha))
        {
            SetStatus("Preencha nome e senha", true);
            return;
        }
        if (senha.Length < 4)
        {
            SetStatus("Senha precisa ter ao menos 4 caracteres", true);
            return;
        }
        processando = true;
        SetStatus("Criando conta...", false);
        if (loadingSpinner) loadingSpinner.SetActive(true);
        btnEntrar.interactable = false;
        btnRegistrar.interactable = false;
        Debug.Log($"[LOGIN] Registrando: {nome}");
        VentoryNetwork.Instance.Registrar(nome, senha, (ok, resp) =>
        {
            processando = false;
            if (loadingSpinner) loadingSpinner.SetActive(false);
            btnEntrar.interactable = true;
            btnRegistrar.interactable = true;
            if (ok && resp.Contains("sucesso"))
            {
                SetStatus($"Conta criada! Bem-vindo, {VentoryNetwork.NomeJogador}!", false);
                Debug.Log($"[LOGIN] Registro OK → {VentoryNetwork.NomeJogador}");
                StartCoroutine(EntrarNaPartida());
            }
            else if (resp.Contains("já existe"))
            {
                SetStatus("Nome já em uso, tente outro", true);
            }
            else
            {
                SetStatus("Erro ao criar conta", true);
                Debug.LogError($"[LOGIN] Erro registro: {resp}");
            }
        });
    }

    IEnumerator EntrarNaPartida()
    {
        yield return new WaitForSeconds(1f);
        SceneManager.LoadScene("Partida");
    }

    void SetStatus(string msg, bool erro)
    {
        if (txtStatus) txtStatus.text = msg;
        if (painelStatus)
        {
            painelStatus.color = erro
                ? new Color(0.8f, 0.1f, 0.1f, 0.85f)
                : new Color(0.1f, 0.6f, 0.3f, 0.85f);
            painelStatus.gameObject.SetActive(!string.IsNullOrEmpty(msg));
        }
    }
}
