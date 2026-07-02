-- Script para crear y poblar la base de datos para la Prueba 3
-- Ejecutar en Oracle SQL Developer en el esquema del estudiante

SET SERVEROUTPUT ON;

-- Eliminar tablas si ya existen
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Asignaciones CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Incidentes CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Agentes CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Crear tabla Agentes
CREATE TABLE Agentes (
    AgenteID     NUMBER PRIMARY KEY,
    Nombre       VARCHAR2(50),
    Especialidad VARCHAR2(50),
    FechaIngreso DATE
);

-- Crear tabla Incidentes
CREATE TABLE Incidentes (
    IncidenteID    NUMBER PRIMARY KEY,
    Descripcion    VARCHAR2(100),
    Severidad      VARCHAR2(20),
    Estado         VARCHAR2(20),
    FechaDeteccion DATE
);

-- Crear tabla Asignaciones
CREATE TABLE Asignaciones (
    AsignacionID NUMBER PRIMARY KEY,
    AgenteID     NUMBER,
    IncidenteID  NUMBER,
    Horas        NUMBER,
    Rol          VARCHAR2(30),
    CONSTRAINT fk_asig_agente    FOREIGN KEY (AgenteID)    REFERENCES Agentes(AgenteID),
    CONSTRAINT fk_asig_incidente FOREIGN KEY (IncidenteID) REFERENCES Incidentes(IncidenteID)
);

-- Insertar datos en Agentes
INSERT INTO Agentes VALUES (101, 'Camila Reyes',     'Pentester',       TO_DATE('2023-03-15','YYYY-MM-DD'));
INSERT INTO Agentes VALUES (102, 'Diego Muñoz',      'Analista SOC',    TO_DATE('2022-07-01','YYYY-MM-DD'));
INSERT INTO Agentes VALUES (103, 'Valentina Soto',   'Analista SOC',    TO_DATE('2024-01-10','YYYY-MM-DD'));
INSERT INTO Agentes VALUES (104, 'Matías Fernández', 'Forense Digital', TO_DATE('2021-11-20','YYYY-MM-DD'));
INSERT INTO Agentes VALUES (105, 'Francisca López',  'Pentester',       TO_DATE('2023-08-05','YYYY-MM-DD'));

-- Insertar datos en Incidentes
INSERT INTO Incidentes VALUES (201, 'Ransomware LockBit en servidor de archivos', 'Critical', 'Abierto',  TO_DATE('2026-03-01','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (202, 'Campaña de Phishing dirigida a RRHH',        'High',     'Abierto',  TO_DATE('2026-03-03','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (203, 'DDoS en portal web institucional',            'High',     'Cerrado',  TO_DATE('2026-03-20','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (204, 'SQL Injection en API de pagos',               'Critical', 'Abierto',  TO_DATE('2026-04-05','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (205, 'Exfiltración de datos via DNS tunneling',     'Medium',   'Cerrado',  TO_DATE('2026-04-10','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (206, 'Acceso no autorizado a base de datos',        'Critical', 'Abierto',  TO_DATE('2026-05-02','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (207, 'Malware en estaciones de trabajo',            'Medium',   'Cerrado',  TO_DATE('2026-05-15','YYYY-MM-DD'));

-- Insertar datos en Asignaciones
INSERT INTO Asignaciones VALUES (1,  101, 201, 40, 'Lider');
INSERT INTO Asignaciones VALUES (2,  102, 201, 35, 'Apoyo');
INSERT INTO Asignaciones VALUES (3,  102, 202, 20, 'Lider');
INSERT INTO Asignaciones VALUES (4,  103, 202, 25, 'Apoyo');
INSERT INTO Asignaciones VALUES (5,  103, 203, 30, 'Lider');
INSERT INTO Asignaciones VALUES (6,  104, 204, 45, 'Lider');
INSERT INTO Asignaciones VALUES (7,  101, 204, 35, 'Apoyo');
INSERT INTO Asignaciones VALUES (8,  105, 205, 25, 'Lider');
INSERT INTO Asignaciones VALUES (9,  104, 201, 20, 'Apoyo');
INSERT INTO Asignaciones VALUES (10, 102, 206, 50, 'Lider');
INSERT INTO Asignaciones VALUES (11, 105, 206, 30, 'Apoyo');
INSERT INTO Asignaciones VALUES (12, 103, 207, 15, 'Lider');

COMMIT;

SELECT 'Tablas creadas y datos insertados correctamente.' AS mensaje FROM dual;

SELECT * FROM Agentes;
SELECT * FROM Incidentes;
SELECT * FROM Asignaciones;

/*
================================================================================
PRUEBA 3 - TÓPICOS AVANZADOS DE BASES DE DATOS
================================================================================

INSTRUCCIONES GENERALES:
- Tiempo: 90 minutos
- Puntaje total: 100 puntos
- Parte 1 (teórica): 40 puntos | Parte 2 (práctica): 60 puntos
- Ejecute el script de datos antes de comenzar la parte práctica
- En la parte teórica, la lógica y el concepto son lo que se evalúa;
  errores menores de sintaxis no penalizan si la idea es correcta

================================================================================
PARTE 1 - PREGUNTAS TEÓRICAS (40 puntos, 10 puntos cada una)
================================================================================

PREGUNTA 1 (10 puntos)
Explica qué es una transacción en una base de datos y describe las propiedades ACID. Luego, muestra a través de un ejemplo cómo usarías múltiples savepoints para
manejar errores parciales en un procedimiento que asigna un agente a un incidente y actualiza simultáneamente el estado del incidente. ¿Qué ocurre si falla solo la actualización del estado?

 Una transacción en una base de datos es una unidad lógica de trabajo que agrupa una o más operaciones de manipulación de datos (como INSERT, UPDATE o DELETE). Para garantizar la integridad y consistencia del sistema frente a errores o accesos simultáneos, toda transacción debe cumplir estrictamente con las propiedades ACID:

A - Atomicidad (Atomicity): Es la propiedad de "todo o nada". La transacción se ejecuta por completo con éxito o no se ejecuta en absoluto. Si una sola instrucción dentro de la transacción falla, todos los cambios realizados hasta ese momento se deshacen (ROLLBACK), regresando la base de datos a su estado original.

C - Consistencia (Consistency): Asegura que una transacción lleve a la base de datos de un estado válido a otro estado válido. Esto significa que cualquier cambio debe respetar todas las reglas del negocio, restricciones de integridad (claves primarias, foráneas, CHECK), tipos de datos y triggers.

I - Aislamiento (Isolation): Permite que múltiples transacciones se ejecuten de forma concurrente sin interferir entre sí. Los cambios provisionales de una transacción no serán visibles para otras transacciones del sistema hasta que esta se haya confirmado formalmente.

D - Durabilidad (Durability): Garantiza que una vez que la transacción ha sido confirmada con éxito (COMMIT), sus efectos serán permanentes en el almacenamiento físico. Los datos no se perderán incluso si ocurre un fallo crítico del sistema, un apagón o un colapso del servidor inmediatamente después.

  Para manejar los errores de manera parcial de acuerdo con los requerimientos planteados (utilizando las tablas Asignaciones e Incidentes del script), diseñamos el siguiente procedimiento almacenado empleando bloques anidados y puntos de control (SAVEPOINT):
  
  CREATE OR REPLACE PROCEDURE asignar_agente_con_savepoints (
    p_AgenteID    IN NUMBER,
    p_IncidenteID IN NUMBER,
    p_Horas       IN NUMBER,
    p_Rol         IN VARCHAR2
) IS
    v_NextAsignacionID NUMBER;
BEGIN
    -- 0. Punto de control inicial para toda la transacción
    SAVEPOINT inicio_transaccion;

    -- Paso 1: Calcular el próximo ID disponible e insertar la asignación
    SELECT NVL(MAX(AsignacionID), 0) + 1 INTO v_NextAsignacionID FROM Asignaciones;
    
    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
    VALUES (v_NextAsignacionID, p_AgenteID, p_IncidenteID, p_Horas, p_Rol);
    
    -- -----------------------------------------------------------------
    -- PUNTO DE CONTROL CLAVE: La asignación se guardó exitosamente en el buffer
    -- -----------------------------------------------------------------
    SAVEPOINT asignacion_ok;

    -- Paso 2: Intentar actualizar el estado del incidente de forma aislada
    BEGIN
        UPDATE Incidentes
        SET Estado = 'En Proceso'
        WHERE IncidenteID = p_IncidenteID;
        
    EXCEPTION
        WHEN OTHERS THEN
            -- SI FALLA SOLO LA ACTUALIZACIÓN DEL ESTADO:
            -- Regresamos exactamente al punto posterior a la inserción exitosa
            ROLLBACK TO asignacion_ok;
            DBMS_OUTPUT.PUT_LINE('AVISO: Falló la actualización del estado del incidente. ' ||
                                 'Sin embargo, la asignación del agente fue preservada.');
    END;

    -- Si el flujo principal continúa, consolidamos los cambios válidos en la BD
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Procedimiento finalizado.');

EXCEPTION
    WHEN OTHERS THEN
        -- Si ocurre un error crítico desde el inicio (ej. falló el INSERT)
        ROLLBACK TO inicio_transaccion;
        DBMS_OUTPUT.PUT_LINE('ERROR CRÍTICO: No se pudo realizar la asignación. Transacción cancelada.');
END;
/

Gracias al uso estratégico de los SAVEPOINTS y al bloque de excepciones anidado (BEGIN ... EXCEPTION ... END), si únicamente la instrucción de actualización (UPDATE) falla (por ejemplo, debido a una restricción de verificación en la columna Estado o porque el registro está bloqueado de forma externa), ocurre lo siguiente:

-Se dispara la excepción del bloque interno.

-Se ejecuta la instrucción ROLLBACK TO asignacion_ok;, la cual deshace de forma exclusiva el cambio fallido del UPDATE.

-Al volver a ese punto de control, la inserción (INSERT) previamente realizada en la tabla Asignaciones se mantiene intacta en la memoria de trabajo de la sesión transaccional.

-El programa continúa su curso hacia la instrucción COMMIT; del bloque principal, lo que provoca que la asignación 
del agente se registre de forma permanente en la base de datos, mientras que el estado del incidente se queda exactamente igual a
como estaba antes de ejecutar el procedimiento.




PREGUNTA 2 (10 puntos)
¿Qué es un Data Warehouse y cómo se diferencia de una base de datos transaccional? Describe cómo diseñarías un modelo dimensional (tabla de hechos y al menos dos dimensiones)
 para analizar las horas trabajadas por agente y por severidad de incidente. ¿Qué ventajas tiene este modelo para consultas analíticas versus consultar directamente las tablas transaccionales?
  
  Un Data Warehouse es un repositorio de datos orientado al análisis, consolidado desde varias fuentes, diseñado para consultas agregadas y reportes históricos. A diferencia de una base de datos transaccional (OLTP), que está optimizada para registrar operaciones diarias de forma rápida y consistente, el Data Warehouse está pensado para lectura analítica, 
  no para alta concurrencia de inserciones/actualizaciones
    Para analizar horas trabajadas por agente y por severidad de incidente, diseñaría un modelo dimensional en esquema tipo estrella:

      Tabla de hechos: Fact_Asignaciones

        .Claves externas a dimensiones: AgenteKey, IncidenteKey, TiempoKey
        .Medida: HorasTrabajadas
        .Opcionalmente: CantidadAsignaciones, HorasPromedio
        .Dimensión Agente

        AgenteKey
        .AgenteID
        .Nombre
        .Especialidad
        .FechaIngreso

        Dimensión Incidente

        .IncidenteKey
        .IncidenteID
        .Descripción
        .Severidad
        .Estado
        .FechaDeteccion
        Dimensión Tiempo (muy útil)

        .Fecha
        .Día
        .Mes
        .Trimestre
        .Año



PREGUNTA 3 (10 puntos)
Explica cómo se implementa la herencia en Oracle usando tipos de objetos. Da un ejemplo de una jerarquía de dos niveles: Agente → AgenteEspecialista → AgentePentester, donde cada nivel agrega atributos y sobreescribe un método calcular_costo(). ¿Qué implicancias tiene declarar un tipo como NOT INSTANTIABLE?

  En Oracle SQL y PL/SQL, la herencia se implementa mediante el uso de Tipos de Objetos (User-Defined Object Types). Para permitir que una jerarquía exista, se deben seguir dos reglas fundamentales de sintaxis:

NOT FINAL: Por defecto, todos los tipos de objetos en Oracle son FINAL (lo que significa que no pueden tener subtipos). Para permitir que un objeto actúe como superclase (clase padre), se debe añadir explícitamente la cláusula NOT FINAL al final de su declaración.

UNDER: Para crear una subclase (clase hija), se utiliza la palabra clave UNDER seguida del nombre de la clase padre. El subtipo heredará automáticamente todos los atributos y métodos del padre, y podrá añadir los suyos propios.

OVERRIDING: Si una subclase necesita modificar el comportamiento de un método heredado, se debe declarar el método en la clase hija anteponiendo la palabra clave OVERRIDING.

  Ejemplo de jerarquía de dos niveles:

  -- Tipo base Agente
  CREATE OR REPLACE TYPE Agente AS OBJECT (
      AgenteID NUMBER,
      Nombre VARCHAR2(50),
      Especialidad VARCHAR2(50),
      MEMBER FUNCTION calcular_costo RETURN NUMBER
  ) NOT FINAL;
  /

  -- Tipo derivado AgenteEspecialista
  CREATE OR REPLACE TYPE AgenteEspecialista UNDER Agente (
      NivelEspecializacion VARCHAR2(20),
      OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER
  );
  /

  -- Tipo derivado AgentePentester
  CREATE OR REPLACE TYPE AgentePentester UNDER AgenteEspecialista (
      Certificacion VARCHAR2(30),
      OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER
  );
  /

  La implicancia de declarar un tipo como NOT INSTANTIABLE es que no se pueden crear instancias directas de ese tipo. Esto significa que no se puede hacer un INSERT INTO o crear un objeto directamente de la clase base. Solo se pueden crear instancias de sus subtipos, lo que permite que la clase base actúe como una plantilla 
  abstracta para las clases derivadas, asegurando que solo los tipos más específicos (como AgenteEspecialista o AgentePentester) puedan ser instanciados y utilizados en la aplicación.

PREGUNTA 4 (10 puntos)
Describe las ventajas y desventajas de usar índices y particiones en una base de datos. ¿Cómo usarías un índice compuesto y una partición por rango para mejorar el rendimiento de consultas en la tabla Incidentes filtradas por Severidad y FechaDeteccion? Explica qué es el partition pruning y cómo impacta en el plan de ejecución.

Índices
    Un índice es una estructura de datos auxiliar (comúnmente un árbol B*) que mejora la velocidad de recuperación de filas.

Ventajas:

  Velocidad de Lectura: Reducen drásticamente el tiempo de ejecución de las consultas SELECT al evitar escaneos completos de la tabla (Full Table Scans).

  Búsquedas Eficientes: Permiten accesos directos por clave primaria o filtros frecuentes y optimizan operaciones de ordenamiento (ORDER BY) y agrupamiento (GROUP BY).

Desventajas:

  Penalización en Escrituras: Degradan el rendimiento de las operaciones INSERT, UPDATE y DELETE, ya que cada modificación en los datos obliga a reorganizar y actualizar el índice de forma síncrona.

  Consumo de Almacenamiento: Requieren espacio adicional en disco y memoria RAM para mantenerse indexados.
Particiones
La partición consiste en dividir una tabla o índice muy grande en piezas más pequeñas y manejables (particiones) a nivel físico, manteniendo una única interfaz lógica.

Ventajas:

Mejora del Rendimiento Analítico: Permite leer únicamente los fragmentos físicos que contienen los datos solicitados (mediante partition pruning).

Mantenimiento Simplificado: Facilita tareas administrativas (mantenimiento de índices, copias de seguridad o purga de datos históricos borrando una partición entera con DROP PARTITION en milisegundos).

Disponibilidad: Si una partición se daña o se desconecta, las demás particiones siguen estando disponibles para los usuarios.

Desventajas:

Complejidad de Diseño: Requiere una planificación minuciosa para elegir la clave de partición correcta. Si una consulta no incluye la clave de partición en sus filtros, el motor tendrá que escanear todas las particiones (Cross-Partition Query), lo cual puede ser más lento que una tabla normal.

  Para mejorar el rendimiento de consultas en la tabla Incidentes filtradas por Severidad y FechaDeteccion, se puede crear un índice compuesto sobre estas dos columnas y particionar la tabla por rango de FechaDeteccion. Esto permite que las consultas que incluyan ambos filtros puedan beneficiarse del índice para localizar rápidamente los registros relevantes y, al mismo tiempo, acceder solo a las particiones que contienen los datos dentro del rango de fechas especificado.

  El partition pruning es una técnica de optimización en la que el motor de base de datos determina qué particiones son relevantes para una consulta específica y descarta automáticamente las demás. Esto reduce significativamente la cantidad de datos que deben ser leídos y procesados, mejorando el tiempo de respuesta y reduciendo la carga en el sistema. En el plan de ejecución, esto se refleja en un menor número de accesos a disco y operaciones de lectura, lo que se traduce en un rendimiento más eficiente para consultas analíticas.



================================================================================
PARTE 2 - EJERCICIOS PRÁCTICOS (60 puntos)
================================================================================

EJERCICIO 1 (20 puntos)
Escribe un procedimiento registrar_asignacion 
que reciba un AgenteID, IncidenteID, Horas y Rol (parámetros IN). 

CREATE OR REPLACE PROCEDURE registrar_asignacion (
    p_AgenteID    IN NUMBER,
    p_IncidenteID IN NUMBER,
    p_Horas       IN NUMBER,
    p_Rol         IN VARCHAR2
) IS
    v_NextAsignacionID NUMBER;
    v_TotalHoras       NUMBER;
    v_TotalAgentes     NUMBER;
    
    -- Excepciones personalizadas para el flujo de negocio
    ex_ExcesoHoras    EXCEPTION;
    ex_ExcesoAgentes  EXCEPTION;
BEGIN
    -- 0. Savepoint inicial antes de alterar cualquier tabla
    SAVEPOINT inicio_procedimiento;

    -- =========================================================================
    -- REQUERIMIENTO A) Insertar nueva asignación con el próximo ID
    -- =========================================================================
    SELECT NVL(MAX(AsignacionID), 0) + 1 INTO v_NextAsignacionID FROM Asignaciones;
    
    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
    VALUES (v_NextAsignacionID, p_AgenteID, p_IncidenteID, p_Horas, p_Rol);

    -- =========================================================================
    -- REQUERIMIENTO B) Validar límite de 100 horas en incidentes 'Abierto'
    -- =========================================================================
    -- Creamos un savepoint justo antes de realizar esta validación
    SAVEPOINT sp_validacion_horas;
    
    SELECT NVL(SUM(a.Horas), 0)
    INTO v_TotalHoras
    FROM Asignaciones a
    JOIN Incidentes i ON a.IncidenteID = i.IncidenteID
    WHERE a.AgenteID = p_AgenteID 
      AND i.Estado = 'Abierto';
      
    IF v_TotalHoras > 100 THEN
        RAISE ex_ExcesoHoras;
    END IF;

    -- =========================================================================
    -- REQUERIMIENTO C) Validar que el incidente no tenga 3 o más agentes
    -- =========================================================================
    -- Creamos un savepoint independiente antes de evaluar la cantidad de agentes
    SAVEPOINT sp_validacion_agentes;
    
    SELECT COUNT(DISTINCT AgenteID)
    INTO v_TotalAgentes
    FROM Asignaciones
    WHERE IncidenteID = p_IncidenteID;
    
    IF v_TotalAgentes >= 3 THEN
        RAISE ex_ExcesoAgentes;
    END IF;

    -- Si ambas validaciones pasan correctamente, consolidamos toda la operación
    DBMS_OUTPUT.PUT_LINE('Asignación registrada exitosamente con ID: ' || v_NextAsignacionID);

-- =============================================================================
-- REQUERIMIENTO D y E) Manejo de excepciones y Savepoints Independientes
-- =============================================================================
EXCEPTION
    WHEN ex_ExcesoHoras THEN
        -- El fallo de horas no deshace el INSERT inicial, pero si requiere control,
        -- volvemos al estado inmediatamente anterior a esta validación específica.
        ROLLBACK TO sp_validacion_horas;
        DBMS_OUTPUT.PUT_LINE('REGLA DE NEGOCIO VIOLADA: El agente ' || p_AgenteID || 
                             ' superaría las 100 horas permitidas en incidentes abiertos (Total proyectado: ' || v_TotalHoras || ').');
        -- Ante un fallo de regla de negocio, deshacemos toda la transacción por seguridad
        ROLLBACK TO inicio_procedimiento;

    WHEN ex_ExcesoAgentes THEN
        -- Volvemos al punto previo a evaluar agentes para aislar el error parcial
        ROLLBACK TO sp_validacion_agentes;
        DBMS_OUTPUT.PUT_LINE('REGLA DE NEGOCIO VIOLADA: El incidente ' || p_IncidenteID || 
                             ' ya cuenta con el límite máximo de agentes asignados (Total: ' || v_TotalAgentes || ').');
        -- Limpiamos el procedimiento completo para evitar registros inválidos
        ROLLBACK TO inicio_procedimiento;

    WHEN OTHERS THEN
        -- Captura de errores técnicos (Claves foráneas inexistentes, tipos de datos, etc.)
        ROLLBACK TO inicio_procedimiento;
        DBMS_OUTPUT.PUT_LINE('ERROR DEL SISTEMA (SQLCODE ' || SQLCODE || '): ' || SQLERRM);
END;
/


EJERCICIO 2 (20 puntos)
Diseña las tablas Fact_Asignaciones, Dim_Agente y Dim_Incidente para un Data Warehouse basado en la base de datos de la prueba. 
Luego, escribe una consulta analítica sobre las tablas transaccionales que muestre, para cada agente, el total de horas trabajadas 
y el número de incidentes atendidos, ordenado de mayor a menor por total de horas.

Diseño de las tablas del Data Warehouse:
  -- 1. Tabla de Dimensión: Agente
CREATE TABLE Dim_Agente (
    AgenteKey    NUMBER PRIMARY KEY, -- Clave sustituta (Surrogate Key)
    AgenteID     NUMBER,             -- Clave de negocio transaccional
    Nombre       VARCHAR2(50),
    Especialidad VARCHAR2(50)
);

-- 2. Tabla de Dimensión: Incidente
CREATE TABLE Dim_Incidente (
    IncidenteKey NUMBER PRIMARY KEY, -- Clave sustituta (Surrogate Key)
    IncidenteID  NUMBER,             -- Clave de negocio transaccional
    Descripcion  VARCHAR2(100),
    Severidad    VARCHAR2(20)
);

-- 3. Tabla de Hechos: Asignaciones
CREATE TABLE Fact_Asignaciones (
    AsignacionKey NUMBER PRIMARY KEY,
    AgenteKey     NUMBER,
    IncidenteKey  NUMBER,
    Horas         NUMBER,            -- Métrica / Hecho cuantitativo
    CONSTRAINT fk_fact_agente    FOREIGN KEY (AgenteKey)    REFERENCES Dim_Agente(AgenteKey),
    CONSTRAINT fk_fact_incidente FOREIGN KEY (IncidenteKey) REFERENCES Dim_Incidente(IncidenteKey)
);

  Consulta analítica sobre las tablas transaccionales para obtener el total de horas trabajadas y el número de incidentes atendidos por cada agente:
SELECT
    a.AgenteID,
    a.Nombre,
    SUM(asig.Horas) AS TotalHorasTrabajadas,
    COUNT(DISTINCT asig.IncidenteID) AS NumeroIncidentesAtendidos 
FROM
    Agentes a 
JOIN
    Asignaciones asig ON a.AgenteID = asig.AgenteID
GROUP BY
    a.AgenteID, a.Nombre
ORDER BY
    TotalHorasTrabajadas DESC; 




EJERCICIO 3 (20 puntos)
Crea un índice compuesto en Incidentes para las columnas Severidad y FechaDeteccion. Luego, 
crea la tabla Incidentes particionada por rango de FechaDeteccion (trimestral para 2026). 
Escribe una consulta que muestre el total de horas asignadas por incidente para incidentes 
'Critical' detectados en el primer trimestre de 2026. Finalmente, muestra el plan de ejecución con 
EXPLAIN PLAN e indica qué ventaja aporta la partición para esta consulta.

CREATE INDEX idx_severidad_fecha ON Incidentes (Severidad, FechaDeteccion);

CREATE TABLE Incidentes_Particionado (
    IncidenteID    NUMBER PRIMARY KEY,
    Descripcion    VARCHAR2(100),
    Severidad      VARCHAR2(20),
    Estado         VARCHAR2(20),
    FechaDeteccion DATE
)
PARTITION BY RANGE (FechaDeteccion) (
    PARTITION p_q1_2026 VALUES LESS THAN (TO_DATE('2026-04-01','YYYY-MM-DD')),
    PARTITION p_q2_2026 VALUES LESS THAN (TO_DATE('2026-07-01','YYYY-MM-DD')),
    PARTITION p_q3_2026 VALUES LESS THAN (TO_DATE('2026-10-01','YYYY-MM-DD')),
    PARTITION p_q4_2026 VALUES LESS THAN (TO_DATE('2027-01-01','YYYY-MM-DD'))
);  

SELECT
    i.IncidenteID,
    i.Descripcion,
    SUM(a.Horas) AS TotalHorasAsignadas
FROM
    Incidentes_Particionado i
JOIN
    Asignaciones a ON i.IncidenteID = a.IncidenteID
WHERE
    i.Severidad = 'Critical' AND 
    i.FechaDeteccion >= TO_DATE('2026-01-01','YYYY-MM-DD') AND
    i.FechaDeteccion < TO_DATE('2026-04-01','YYYY-MM-DD')
GROUP BY
    i.IncidenteID, i.Descripcion;
EXPLAIN PLAN FOR
SELECT 
    i.IncidenteID,
    i.Descripcion,
    SUM(asig.Horas) AS Total_Horas_Asignadas
FROM Incidentes_Particionada i
JOIN Asignaciones asig ON i.IncidenteID = asig.IncidenteID
WHERE i.Severidad = 'Critical'
  AND i.FechaDeteccion >= TO_DATE('2026-01-01', 'YYYY-MM-DD')
  AND i.FechaDeteccion < TO_DATE('2026-04-01', 'YYYY-MM-DD')
GROUP BY 
    i.IncidenteID, 
    i.Descripcion;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);   




================================================================================
*/
