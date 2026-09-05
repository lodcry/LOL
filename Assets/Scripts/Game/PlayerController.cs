using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public JoystickTouch joystick;
    public float velocidade = 5f;
    public SpriteRenderer spriteRenderer;
    Rigidbody2D rb;

    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        Debug.Log($"[PLAYER] PlayerController iniciado");
    }

    void FixedUpdate()
    {
        Vector2 dir = joystick != null ? joystick.Direcao : Vector2.zero;
        rb.linearVelocity = dir * velocidade;
        if (dir.x != 0 && spriteRenderer)
            spriteRenderer.flipX = dir.x < 0;
    }
}
