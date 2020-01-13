using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class rotateGameObject : MonoBehaviour
{
    [SerializeField]
    float speed = 1.0f;


    // Update is called once per frame
    void Update()
    {
//        transform.Rotat(x, y, 0);
        transform.Rotate(speed*Time.deltaTime*.75f, speed*Time.deltaTime*1.5f, 0);

    }
}
