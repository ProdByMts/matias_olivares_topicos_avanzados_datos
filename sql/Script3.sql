ALTER SESSION SET CURRENT_SCHEMA = curso_topicos;

DECLARE
    v_pedido_id NUMBER := 101; 
    v_total_pedido NUMBER;
BEGIN
    SELECT Total INTO v_total_pedido
    FROM Pedidos
    WHERE PedidoID = v_pedido_id;

    IF v_total_pedido > 700 THEN
        DBMS_OUTPUT.PUT_LINE('El Pedido ' || v_pedido_id || ' tiene un total de $' || v_total_pedido || '. Clasificación: ALTO');
    ELSIF v_total_pedido >= 400 THEN
        DBMS_OUTPUT.PUT_LINE('El Pedido ' || v_pedido_id || ' tiene un total de $' || v_total_pedido || '. Clasificación: MEDIO');
    ELSE
        DBMS_OUTPUT.PUT_LINE('El Pedido ' || v_pedido_id || ' tiene un total de $' || v_total_pedido || '. Clasificación: BAJO');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: No se encontró ningún registro para el Pedido ' || v_pedido_id);
END;
