soy el cambio

# 0. Editores de código apalancador con la IA
 - Intellisense con Windsurf
 - VSCode usado con Git Hub Copilot y Claude Desktop, usando MCP's

# 1. Instrucciones generales y equipo de trabajo

## 1.1. Formación de equipo y comunicación

### Roles

| Sofkiano  | Rol  |
| ------------- | ------------- |
| Juan David Franco | Frontend Developer  |
| Omar Ortiz| Frontend Developer   |
| Santiago Angarita  | Backend Developer |
| Javier Luis  | Backend Developer |

Cada miembro del equipo de trabajo en el frontend y en el backend revisan mutuamente las contribuciones

### Canales de comunicación

- WhatsApp
- Reuniones con Meet

## 1.2. Definición de marco de trabajo AI (Investigación)

✅ Metodología
El proyecto adopta una metodología de Desarrollo Guiado por Arquitectura con Asistencia de IA, donde la IA actúa como un desarrollador técnico bajo la dirección del arquitecto del proyecto.
La IA no se usa de forma libre, sino mediante un proceso estructurado que parte siempre del contexto del proyecto, las historias de usuario y las instrucciones de arquitectura definidas por el arquitecto.
El ciclo base de trabajo es:
Arquitecto define junto con IA → IA implementa → Arquitecto valida → IA ajusta → Arquitecto aprueba con pares.
La IA se utiliza de manera distinta según la fase:

### 📌 Planificación
En planificación se construye el entendimiento del sistema usando IA fuera del editor.

**Actividades**:
Redacción del contexto del proyecto.

Definición del flujo funcional.

Creación de historias de usuario.

Identificación de requisitos funcionales y no funcionales.

Ajuste y validación de las historias con un par.

La IA se usa como asistente para estructurar ideas, proponer redacciones y refinar el modelo del dominio, pero la versión final es siempre validada por el arquitecto.
Entregables:
Documento de contexto.

Historias de usuario.

Instrucciones de arquitectura y buenas prácticas.

### 📌 Desarrollo
El desarrollo se realiza historia por historia.
Actividades:
El arquitecto entrega a la IA:

Historia de usuario.

Contexto técnico.

Lineamientos de arquitectura.

La IA genera un Plan de Implementación por historia, indicando:

Capas afectadas.

Componentes a crear.

Flujos técnicos.

La IA propone el código alineado a dichos lineamientos.

El arquitecto revisa diseño, coherencia y calidad.

La IA ajusta según feedback.

Solo después se integra al repositorio.

La IA no escribe código sin referencia a una historia de usuario ni sin respetar las instrucciones de arquitectura del proyecto.

### 📌 QA

La fase de QA valida que cada historia implementada funcione correctamente.
Actividades:
La IA propone:

Casos de prueba.

Tests unitarios.

Escenarios de error.

El arquitecto ejecuta y revisa:

Flujos funcionales.

Manejo de excepciones.

Integración con RabbitMQ.

Se reportan fallos.

La IA corrige y mejora el código.

La historia se marca como lista solo después de pasar validación.

La IA se usa para acelerar la creación de pruebas, pero la verificación final es humana.

### 📌 Despliegue (Instalación)
En despliegue se prepara el sistema para ejecución.
Actividades:
El arquitecto solicita a la IA:

Guía de instalación.

Configuración de entorno.

Scripts de ejecución.

Dockerización.

La IA genera los pasos.

El arquitecto prueba el proceso en un entorno limpio.

Se corrigen errores de configuración.

Se documenta el procedimiento final.

La IA apoya el proceso, pero el arquitecto valida que el sistema quede realmente operativo.

### ✅ Interacciones Clave

Las interacciones con la IA están ligadas directamente al flujo del proyecto:
Definir historias de usuario.

Diseñar arquitectura y eventos RabbitMQ.

Crear planes de implementación.

Generar código backend y frontend.

Crear tests.

Refactorizar.

Documentar.

Cada interacción debe partir de:
Contexto del proyecto.

Historia de usuario.

Lineamientos de arquitectura.

Restricciones técnicas.

Formato esperado.

Ejemplo real de interacción:
“Con base en la HU-BE-MVP-05 y las instrucciones de arquitectura, genera el servicio de creación de órdenes usando Spring Boot y publicando un evento RabbitMQ.”

✅ Documentos Clave y Contextualización
El proyecto mantiene documentos base que siempre se usan como contexto para interactuar con la IA:
Documento de contexto del proyecto.

Historias de usuario.

Instrucciones de arquitectura.

Antes de pedir trabajo a la IA, el arquitecto proporciona:
```
Qué se está construyendo.

En qué capa.


Qué restricciones aplicar.


Qué ya existe en el código.
```
Esto evita soluciones genéricas y mantiene coherencia entre entregables.

✅ Dinámicas de Interacción
La relación Arquitecto–IA se maneja como si la IA fuera un miembro técnico del equipo.
Dinámica:
El arquitecto define la tarea.

Se entrega contexto y HU.

La IA propone solución.

El arquitecto revisa.

Se devuelve feedback.

La IA ajusta.

Se valida.

Se integra.

### Reglas:

La IA no toma decisiones finales.

Ningún código entra sin revisión.

Toda historia pasa por validación.

El arquitecto controla alcance, prioridad y diseño.

La IA es soporte técnico, no autoridad del proyecto.

## 1.3. Definición la razon de ser del aplicativo

La aplicación consiste en **MVP paraq microservicio para e-commerce de carrito**, el proposito de nuestra aplicación es hacer una aplicación AI-first que reproduce el proceso de compra para un usuario,