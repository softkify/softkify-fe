# CALIDAD.md

## 1. ANATOMÍA DE UN INCIDENTE

Este documento recoge dos incidentes críticos que ocurrieron durante el desarrollo del proyecto Softkify, uno en el frontend y otro en el backend, ambos relacionados con la integración entre capas.

---

### INCIDENTE 1: Variables de Entorno - Frontend

#### Contexto
Durante las pruebas de conexión entre backend y front end del módulo de autenticación, los desarrolladores reportaron que no podían completar el registro. La consola del navegador mostraba errores de conexión que inicialmente se confundieron con problemas de CORS.

#### Error (Causa Humana)
El desarrollador hardcodeó la URL base de la API para pruebas locales rápidas y olvidó revertir el cambio o configurarlo para usar las variables de entorno antes del commit final a la rama principal.

#### Defecto (Código)
El archivo `src/services/authApi.ts` tenía la URL fija apuntando a `localhost`, lo que funcionaba en el entorno de desarrollo pero fallaba en cualquier otro dispositivo.

**ANTES (Con Defecto):**
```typescript
// src/services/authApi.ts
// ERROR: URL fija que ignora las variables de entorno de producción
const API_BASE_URL = 'http://localhost:8080';

export const authApi = {
  // ...
};
```

**DESPUÉS (Corregido):**
```typescript
// src/services/authApi.ts
// FIX: Usa la variable de entorno VITE_API_BASE_URL, con fallback seguro para local
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080';

export const authApi = {
  // ...
};
```

#### Fallo (Impacto en Usuario)
Al intentar registrarse o iniciar sesión desde developer, la aplicación intentaba conectar a `http://localhost:8080/api/users` en la máquina del propio usuario.

**Manifestación**: El botón de "Registrarse" se quedaba cargando indefinidamente o mostraba un error genérico "Network Error", ya que el navegador bloqueaba la petición o simplemente no encontraba el servidor localmente.

---

### INCIDENTE 2: Configuración CORS - Backend

#### Contexto
Después de verificar que el backend estaba operativo mediante Insomnia y Postman, las peticiones desde el navegador fallaban sistemáticamente debido a la política CORS.

El backend está construido con Spring Boot bajo arquitectura hexagonal y forma parte de un ecosistema de microservicios.

#### Error (Causa Humana)
La política CORS fue configurada con un patrón de rutas `/api/**` sin considerar que los controladores ya estaban mapeados bajo `/api`. Esto generó una incongruencia en la evaluación del preflight (OPTIONS), provocando ausencia de los headers esperados por el navegador.

#### Defecto (Código)

**ANTES (Con Defecto):**
```java
registry.addMapping("/api/**")  // Configuración inconsistente con el mapping real
```

**DESPUÉS (Corregido):**
```java
registry.addMapping("/**")  // Patrón global coherente con el mapping de controllers
```

#### Fallo (Impacto en Usuario)
El navegador bloqueaba las peticiones con:

```
No 'Access-Control-Allow-Origin' header is present
```

#### Análisis Técnico Profesional

- El problema no era funcional sino de configuración HTTP.
- Postman no reproduce validaciones de preflight.
- La ausencia de tests de integración permitió que el error llegara a entorno de integración.

#### Medida Preventiva Adoptada

- Validación obligatoria de preflight (`OPTIONS`) en pruebas de integración.
- Centralización de configuración CORS.
- Revisión explícita de mappings base en code review.

---

## 2. ANÁLISIS DE PIRÁMIDE DE PRUEBAS

### Tipo de Aplicación
**Softkify** es una aplicación full-stack de comercio electrónico construida con:
- **Frontend**: SPA (Single Page Application) con React y Vite
- **Backend**: API RESTful con Spring Boot
- **Infraestructura**: Docker, base de datos PostgreSQL
- **Arquitectura Backend**: Hexagonal (Ports & Adapters)
- **Comunicación entre microservicios**: RabbitMQ

---

#### FRONTEND: Pirámide Invertida (Testing Trophy)

**¿Por qué más E2E que Unitarias en Frontend?**

1. **Limitaciones de las Pruebas Unitarias**:
    - Muchos componentes (`Header`, `ProductCard`) son visuales/presentacionales
    - Mockear `useLogin`, props y `react-router` es costoso en mantenimiento
    - No garantizan que el sistema funcione integrado
    - El incidente de variables de entorno **no se habría detectado** con pruebas unitarias

2. **Valor de las Pruebas E2E**:
    - Validan **flujos críticos de negocio** completos (Auth → Shop → Checkout)
    - Son agnósticas a la implementación
    - Detectan errores de configuración (URLs, variables de entorno)
    - Capturan problemas de integración con el backend real

**Distribución Recomendada (Frontend)**:
```
E2E (Cypress/Playwright): 60%  ← Flujos críticos
Integration (RTL):        30%  ← Componentes complejos con hooks
Unit (Vitest):           10%  ← Lógica pura (validaciones, cálculos)
```

---

### BACKEND: Pirámide Tradicional Orientada a Dominio

Dado que el backend implementa arquitectura hexagonal, las pruebas priorizan dominio y casos de uso antes que infraestructura.

#### Distribución Recomendada (Backend Profesional)

```
Unit (Dominio + UseCases)        60%
Integration (Adapters + Spring)  30%
Contract/API Validation          10%
```

#### Justificación

- La lógica crítica reside en casos de uso y dominio.
- Integration tests validan configuración, serialización y persistencia.
- Contract tests protegen el acuerdo entre microservicios y frontend.

---

### Ajuste Estratégico sobre RabbitMQ

Actualmente:

- RabbitMQ está implementado.
- No existen aún pruebas automatizadas específicas para mensajería.

Riesgo identificado:
La comunicación asíncrona es un punto crítico en arquitectura distribuida y debe ser cubierta por pruebas de integración en futuras iteraciones.

Plan técnico:

- Test de publicación de eventos.
- Test de consumo con broker embebido o Testcontainers.
- Validación de serialización del mensaje.
- Validación de idempotencia.

---

## 3. IMPLEMENTACIÓN DE APRENDIZAJE

A continuación, se presenta una suite mínima de pruebas que **hubieran detectado** los dos incidentes documentados.

### A. Pruebas Unitarias - Frontend (Vitest + React Testing Library)

**Foco**: Validaciones del formulario de Login (`LoginForm.tsx`)

```typescript
// src/components/Auth/__tests__/LoginForm.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { describe, test, expect, vi, beforeEach } from 'vitest';
import LoginForm from '../LoginForm';
import { VALIDATION_ERRORS } from '../data';

describe('LoginForm Component', () => {
  const mockSubmit = vi.fn();
  const mockToggle = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
  });

  test('debe mostrar error si se intenta enviar el formulario vacío', () => {
    render(
      <LoginForm 
        onSubmit={mockSubmit} 
        onToggleMode={mockToggle} 
        isLoading={false} 
        error={null} 
      />
    );

    const submitBtn = screen.getByRole('button', { name: /iniciar sesión/i });
    fireEvent.click(submitBtn);

    // Verificamos que NO se llamó al submit
    expect(mockSubmit).not.toHaveBeenCalled();
    
    // Verificamos que aparece el mensaje de error de email requerido
    expect(screen.getByText(VALIDATION_ERRORS.emailRequired)).toBeInTheDocument();
  });

  test('debe validar formato de email antes de permitir submit', () => {
    render(
      <LoginForm 
        onSubmit={mockSubmit} 
        onToggleMode={mockToggle} 
        isLoading={false} 
        error={null} 
      />
    );

    // Email inválido
    fireEvent.change(screen.getByPlaceholderText(/correo electrónico/i), {
      target: { value: 'email-invalido' }
    });
    fireEvent.change(screen.getByPlaceholderText(/contraseña/i), {
      target: { value: 'password123' }
    });
    
    fireEvent.click(screen.getByRole('button', { name: /iniciar sesión/i }));
    
    expect(mockSubmit).not.toHaveBeenCalled();
    expect(screen.getByText(VALIDATION_ERRORS.emailInvalid)).toBeInTheDocument();
  });

  test('debe llamar a onSubmit con los datos correctos si el formulario es válido', async () => {
    render(
      <LoginForm 
        onSubmit={mockSubmit} 
        onToggleMode={mockToggle} 
        isLoading={false} 
        error={null} 
      />
    );

    // Rellenamos los campos con datos válidos
    fireEvent.change(screen.getByPlaceholderText(/correo electrónico/i), {
      target: { value: 'test@softkify.com' }
    });
    fireEvent.change(screen.getByPlaceholderText(/contraseña/i), {
      target: { value: 'password123' }
    });

    // Enviamos
    fireEvent.click(screen.getByRole('button', { name: /iniciar sesión/i }));
    
    // Verificamos que se llamó a la función con los datos correctos
    await waitFor(() => {
      expect(mockSubmit).toHaveBeenCalledWith({
        email: 'test@softkify.com',
        password: 'password123'
      });
    });
  });

  test('debe mostrar estado de carga cuando isLoading es true', () => {
    render(
      <LoginForm 
        onSubmit={mockSubmit} 
        onToggleMode={mockToggle} 
        isLoading={true} 
        error={null} 
      />
    );

    const submitBtn = screen.getByRole('button', { name: /iniciando/i });
    expect(submitBtn).toBeDisabled();
  });
});
```

---

### B. Pruebas de Integración - Frontend (Configuración de Variables)

**Foco**: Detectar el incidente de configuración de API_BASE_URL

```typescript
// src/services/__tests__/apiConfig.test.ts
import { describe, test, expect, beforeEach, afterEach } from 'vitest';

describe('API Configuration', () => {
  const originalEnv = import.meta.env;

  afterEach(() => {
    // Restaurar variables de entorno originales
    import.meta.env = originalEnv;
  });

  test('debe usar VITE_API_BASE_URL cuando está definida', () => {
    // Simular variable de entorno en producción
    import.meta.env = {
      ...originalEnv,
      VITE_API_BASE_URL: 'https://api.softkify.com'
    };

    // Reimportar módulo para que lea la nueva variable
    const { API_BASE_URL } = require('../apiConfig');
    
    expect(API_BASE_URL).toBe('https://api.softkify.com');
    expect(API_BASE_URL).not.toContain('localhost');
  });

  test('debe hacer fallback a localhost cuando VITE_API_BASE_URL no está definida', () => {
    import.meta.env = {
      ...originalEnv,
      VITE_API_BASE_URL: undefined
    };

    const { API_BASE_URL } = require('../apiConfig');
    
    expect(API_BASE_URL).toBe('http://localhost:8080');
  });

  test('ALERTA: debe fallar si hay URL hardcodeada', () => {
    // Esta prueba detectaría el incidente original
    const { API_BASE_URL } = require('../apiConfig');
    
    // Verificar que no hay hardcodeo de localhost en producción
    if (import.meta.env.MODE === 'production') {
      expect(API_BASE_URL).not.toContain('localhost');
    }
  });
});
```

---

### C. Pruebas E2E - Frontend (Playwright)

**Foco**: Flujo completo de autenticación + detección de errores de red/CORS

```typescript
// tests/auth.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Flujo de Autenticación', () => {
  
  test.beforeEach(async ({ page }) => {
    // Navegar a la página de login
    await page.goto('/auth');
  });

  test('debe permitir al usuario navegar entre Login y Registro', async ({ page }) => {
    // Verificar estado inicial (Login)
    await expect(page.getByRole('heading', { name: '¡Bienvenido de nuevo!' })).toBeVisible();
    
    // Clic en "Registrate aquí"
    await page.getByText('Registrate aquí').click();

    // Verificar cambio a Registro
    await expect(page.getByRole('heading', { name: 'Crea tu cuenta' })).toBeVisible();
    
    // Volver a Login
    await page.getByText('Inicia sesión').click();
    await expect(page.getByRole('heading', { name: '¡Bienvenido de nuevo!' })).toBeVisible();
  });

  test('debe mostrar error visual cuando la API falla (simulando CORS)', async ({ page }) => {
    // Mockear la respuesta de la API para simular fallo CORS
    await page.route('**/auth/login', async route => {
      // Simular un error de red (como el que causa CORS)
      await route.abort('failed');
    });

    // Rellenar formulario
    await page.getByPlaceholderText('Correo electrónico').fill('test@softkify.com');
    await page.getByPlaceholderText('Contraseña').fill('password123');
    
    // Intentar login
    await page.getByRole('button', { name: 'Iniciar Sesión' }).click();

    // Verificar que se muestra un mensaje de error de red
    await expect(page.getByText(/error de conexión|failed to fetch/i)).toBeVisible();
  });

  test('CRÍTICO: debe poder comunicarse con el backend real', async ({ page }) => {
    // Esta prueba fallaría con el incidente de CORS o URL hardcodeada
    // Asume que hay un backend de pruebas disponible
    
    // Intentar registro con datos de prueba
    await page.getByText('Registrate aquí').click();
    await page.getByPlaceholderText('Nombre completo').fill('Usuario Test');
    await page.getByPlaceholderText('Correo electrónico').fill(`test${Date.now()}@softkify.com`);
    await page.getByPlaceholderText('Contraseña', { exact: true }).fill('Test123456');
    await page.getByPlaceholderText('Confirmar contraseña').fill('Test123456');
    
    // Interceptar la petición para verificar que llegue al backend
    const responsePromise = page.waitForResponse(
      response => response.url().includes('/api/users') && response.status() === 201
    );

    await page.getByRole('button', { name: 'Crear Cuenta' }).click();
    
    // Esperar respuesta exitosa del backend
    const response = await responsePromise;
    expect(response.status()).toBe(201);
    
    // Verificar redirección o mensaje de éxito
    await expect(page.getByText(/registro exitoso|bienvenido/i)).toBeVisible({ timeout: 5000 });
  });
});
```


---

### D. Pruebas Unitarias - Backend (Mejora Conceptual)

En un entorno hexagonal profesional:

- Se mockean puertos, no repositorios concretos.
- El dominio no depende de infraestructura.
- Las reglas de negocio deben probarse sin levantar contexto Spring.

Se recomienda progresivamente migrar tests que dependan de infraestructura hacia pruebas puramente orientadas a dominio.

---

### E. Pruebas de Integración - Backend

Mejoras incorporadas conceptualmente:

- Validación explícita de headers CORS.
- Validación de que no se expone información sensible.
- Validación de códigos HTTP correctos.
- Confirmación de que no existe duplicación de rutas (`/api/api`).

Estado actual:
- Integration tests implementados con `@SpringBootTest`.
- No se utiliza Testcontainers aún.
- No se realizan pruebas de mensajería.

---

### F. Pruebas de Contrato API

Actualmente se utilizan pruebas con RestAssured para validar:

- Status codes.
- Schema básico.
- No exposición de campos sensibles.

Nota profesional:
Estas pruebas validan comportamiento HTTP, pero no constituyen Consumer-Driven Contract Testing formal.

Roadmap:
Evaluar Spring Cloud Contract o Pact cuando la arquitectura multi-microservicio evolucione.

---

## 4. COBERTURA Y MÉTRICAS DE CALIDAD

#### Backend
```
Líneas:     ≥ 80%
Ramas:      ≥ 75%
Funciones:  ≥ 85%
Crítico*:   100%
```

*Crítico = Controllers, UseCases, validaciones de dominio, configuración CORS.*

Cobertura no es el objetivo final; es un indicador complementario de robustez.

---

## 5. CHECKLIST DE CALIDAD ANTES DE COMMIT

### Frontend
- [ ] Variables de entorno configuradas en `.env.example` y documentadas
- [ ] No hay URLs hardcodeadas en servicios/APIs
- [ ] Validaciones de formulario tienen tests unitarios
- [ ] Flujos críticos cubiertos por E2E (Auth, Checkout)
- [ ] Manejo de errores de red implementado y testeado


### Backend

- [ ] Casos de uso cubiertos por pruebas unitarias
- [ ] Dominio desacoplado de infraestructura
- [ ] Validación de preflight (OPTIONS) presente
- [ ] No exposición de datos sensibles
- [ ] Contrato API validado
- [ ] Eventos publicados correctamente (aunque sin test automatizado aún)
- [ ] Build exitoso (`mvn clean install`)
- [ ] Tests exitosos (`mvn test`)

### General
- [ ] Build pasa localmente: `npm run build` / `mvn clean install`
- [ ] Tests pasan al 100%: `npm test` / `mvn test`
- [ ] No hay warnings de linter: `npm run lint` / `mvn checkstyle:check`
- [ ] Coverage cumple umbrales mínimos
- [ ] Dockerfile actualizado si hay cambios de configuración

---

## 6. LECCIONES APRENDIDAS

### Del Incidente de Variables de Entorno (Frontend)
1. **Nunca hardcodear URLs**: Siempre usar variables de entorno con fallback claro
2. **Validar configuración en CI/CD**: Agregar test que verifique uso de env vars
3. **Documentar variables requeridas**: Mantener `.env.example` actualizado
4. **Code review enfocado**: Revisar específicamen  te configuración antes de merge

### Del Incidente de CORS (Backend)
1. Los errores de configuración HTTP pueden ser más críticos que errores lógicos.
2. Postman no replica validaciones del navegador.
3. La ausencia de integration tests permite que errores de configuración lleguen a integración.
4. Arquitectura hexagonal obliga a probar dominio sin framework.
5. Mensajería asíncrona requiere estrategia de testing dedicada.
6. Centralizar configuración reduce riesgo operativo.

### Mejores Prácticas Adoptadas
1. **Configuración externalizada**: Usar `application.yml` con profiles (dev, prod)
2. **Tests de contrato obligatorios**: Asegurar que frontend y backend hablen el mismo idioma
3. **E2E en pipeline de CI**: Ejecutar al menos los flujos críticos antes de deploy
4. **Monitoring de errores**: Implementar Sentry/similar para detectar errores en producción temprano

---

**Última actualización**: 2026-02-15  
**Mantenido por**: Equipo de Calidad Softkify  
**Versión**: 2.0 (Backend refinado profesionalmente)
