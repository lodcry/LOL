using UnityEngine;
using UnityEngine.EventSystems;

public class JoystickTouch : MonoBehaviour, IPointerDownHandler, IDragHandler, IPointerUpHandler
{
    public RectTransform fundo;
    public RectTransform cabo;
    public float raio = 80f;
    public Vector2 Direcao { get; private set; }

    int touchId = -1;

    public void OnPointerDown(PointerEventData e)
    {
        touchId = e.pointerId;
        AtualizarCabo(e.position);
    }

    public void OnDrag(PointerEventData e)
    {
        if (e.pointerId != touchId) return;
        AtualizarCabo(e.position);
    }

    public void OnPointerUp(PointerEventData e)
    {
        if (e.pointerId != touchId) return;
        touchId = -1;
        cabo.anchoredPosition = Vector2.zero;
        Direcao = Vector2.zero;
    }

    void AtualizarCabo(Vector2 posicao)
    {
        RectTransformUtility.ScreenPointToLocalPointInRectangle(
            fundo, posicao, null, out Vector2 local);
        local = Vector2.ClampMagnitude(local, raio);
        cabo.anchoredPosition = local;
        Direcao = local / raio;
    }
}
