# 🐸 Habuu: tracker de hábitos personales

Habuu es una app móvil hecha en **Flutter** para crear hábitos, marcarlos cada día y no perder la racha. La rana de Habuu te acompaña: celebra cuando cumples, te recuerda tus hábitos con notificaciones y te da trofeos por tu constancia.

Proyecto final de **Desarrollo de Aplicaciones Móviles**, ESEN, ciclo 3/2026. Docente: Jaime Mejía.

---

## Equipo (Grupo 10)

| Integrante | Carné |
|---|---|
| Kathleen Abigail Argueta Gómez | 20245083 |
| Alejandro Javier Durón Rodríguez | 20245274 |
| José Roberto Milán Ramos | 20245436 |
| Diego Alejandro Orellana Estrada | 20245281 |
| Reina Arely Sosa Mejia | 20245517 |

---

## Funcionalidades

- **Cuenta de usuario:** registro, verificación por código, inicio de sesión, recuperar y cambiar contraseña. La sesión se guarda cifrada en el teléfono.
- **Landing y onboarding** para usuarios nuevos.
- **Hábitos:**
  - Hábitos **frecuentes** (diario, semanal o mensual) y **fugaces** (de un solo día).
  - Crear, editar, reordenar y eliminar, con mensajes de éxito.
  - Categorías predefinidas y personalizadas, ícono, color y meta diaria.
  - Filtros por tipo, por categoría y por hábitos omitidos.
- **Home del día:** marcar hábitos como hechos u omitidos y subir una foto como evidencia.
- **Verificación de evidencia con IA (opcional):** si el usuario acepta, la foto se revisa con Gemini a través de una Edge Function de Supabase, y la clave nunca queda dentro de la app.
- **Rachas y trofeos:** días seguidos completando hábitos y logros desbloqueables.
- **Recordatorios:** notificaciones locales a la hora elegida para cada hábito, aunque la app esté cerrada.
- **Perfil:** datos del usuario, seguridad y cerrar sesión.

---

## Tecnologías

| Área | Paquetes |
|---|---|
| Interfaz | Flutter (Material 3), `google_fonts`, `flutter_svg`, `table_calendar`, `intl` |
| Estado | `provider` (`ChangeNotifier`) |
| Backend | `supabase_flutter`: Auth, PostgreSQL con RLS, Storage y Edge Functions |
| Almacenamiento local | `shared_preferences`, `flutter_secure_storage` |
| Fotos | `image_picker`, `image` (compresión) |
| Notificaciones | `flutter_local_notifications`, `timezone`, `flutter_timezone` |
| Red | `http` |
| Pruebas | `flutter_test` |

---

## Arquitectura

Usamos el **patrón Repository** con inyección por constructor, como vimos en clase:

```
Pantalla (screens / widgets)
   ↓ lee y llama a
Provider (ChangeNotifier)
   ↓ usa
Repository
   ↓ depende de una interfaz
DataSource ──► Supabase (implementación real)
           └─► Fake (implementación para pruebas)
```

Las pantallas no saben que existe Supabase. Por eso en las pruebas cambiamos el DataSource real por uno **Fake** y todo corre sin internet. Lo mismo hicimos con las notificaciones: el provider depende de la interfaz `HabitReminderScheduler`, no del paquete.

### Estructura de carpetas

```
lib/
├── config/            # Providers de la app, rutas, tema y assets
├── data/
│   ├── datasources/   # Interfaces + implementaciones Supabase / Gemini
│   ├── models/        # Habit, HabitLog, VerificationResult, ...
│   └── repositories/  # HabitRepository, HomeRepository, StreakRepository, ...
├── presentation/
│   ├── providers/     # HabitsProvider, HomeProvider, AuthProvider, ...
│   ├── screens/       # auth, landing, home, habits, streaks, trofeos, profile
│   └── widgets/       # Componentes reutilizables por sección
├── services/          # Notificaciones, plan de recordatorios, fotos
└── utils/             # Validadores, fechas y utilidades
supabase/
├── schema.sql         # Tablas, RLS, vista de racha y datos iniciales
└── email-templates/   # Correos de confirmación y recuperación
test/                  # Pruebas unitarias y de widgets (con Fakes)
```

---

## Cómo correr el proyecto

### 1. Requisitos

- Flutter 3.47 o superior (Dart 3.13).
- Un proyecto de Supabase.
- Para probar en celular: Android Studio (emulador o celular Android) o Xcode (iPhone).

### 2. Base de datos

En Supabase abre **SQL Editor › New query**, pega todo el contenido de [`supabase/schema.sql`](supabase/schema.sql) y dale **Run**. Ese script crea las tablas, las reglas de seguridad (RLS) y los datos iniciales de categorías y trofeos.

### 3. Variables de entorno

Crea un archivo `env.json` en la raíz del proyecto. Ya está en `.gitignore`:

```json
{
  "SUPABASE_URL": "https://bvhmncxhuaustkupwyqi.supabase.co",
  "SUPABASE_KEY": "sb_publishable_lW2V51Ak1GfKeyzvnVyMPA_jcz-qTA0"
}
```

Los dos valores están en Supabase, en **Project Settings › API**.

### 4. Instalar y correr

```bash
flutter pub get
flutter run --dart-define-from-file=env.json
```

Para elegir dónde correrla:

```bash
flutter devices                                              # ver dispositivos
flutter run -d chrome --dart-define-from-file=env.json       # navegador
flutter run -d <id-del-celular> --dart-define-from-file=env.json
```

---

## Pruebas

```bash
flutter test
```

Hay pruebas **unitarias** (modelos, repositories, validadores, plan de recordatorios) y **de widgets** (login, registro, formulario de hábitos, lista de hábitos, home). Todas usan DataSources **Fake**, así que no necesitan internet ni Supabase. Algunas pantallas se prueban a 360 px y 440 px de ancho para revisar que no se desborden.

Si en la consola salen mensajes como `Error simulado de conexión`, es normal: vienen de las pruebas que fingen fallas a propósito.

---

## Notas

- **Recordatorios:** en Android pueden llegar con unos minutos de atraso, porque usamos alarmas "inexactas" para no pedir el permiso especial de alarmas exactas. Después de reiniciar el teléfono se vuelven a programar solos.
- **Verificación con Gemini:** la Edge Function `verify-habit-photo` guarda la clave de Gemini en Supabase. La app solo manda la foto y recibe el resultado.

---
## Uso de IA

Durante el desarrollo usamos asistentes de IA como apoyo para revisar código, escribir pruebas, depurar errores e implementar los recordatorios con notificaciones locales. El detalle está en la declaración de cada integrante en el documento final.

