# Capturas de pantalla

Imágenes referenciadas por el `README.md` del proyecto. Mantén los nombres exactos.

Esta carpeta está en la raíz del repositorio, fuera de `hsound/` y `adminpanel_musical/`, por lo que **no se incluye en los builds** de ninguna de las dos aplicaciones.

## App móvil (`assets/screenshots/app/`)

Se toman desde el emulador de Android o un dispositivo real. Formato vertical recomendado: 1080x1920 o 720x1280.

| Archivo | Pantalla | Código fuente |
|---------|----------|---------------|
| `inicio.png` | Feed de inicio con canciones locales | `hsound/lib/screens/home/home_screen.dart` |
| `busqueda.png` | Búsqueda con filtros por género y popularidad | `hsound/lib/screens/search/search_screen.dart` |
| `reproductor.png` | Reproductor de la canción | `hsound/lib/screens/songs/song_player_screen.dart` |
| `favoritos.png` | Lista de canciones favoritas | `hsound/lib/screens/favorites/favorites_screen.dart` |
| `perfil-artista.png` | Perfil del artista con bio y redes | `hsound/lib/screens/profile/artist_profile_screen.dart` |
| `registro.png` | Inicio de sesión y registro | `hsound/lib/screens/auth/login_screen.dart` |

Opcionales para ampliar el README:

| Archivo | Pantalla | Código fuente |
|---------|----------|---------------|
| `publicar-cancion.png` | Formulario de publicación de canción | `hsound/lib/screens/songs/add_song_screen.dart` |
| `eventos.png` | Detalle de un evento | `hsound/lib/screens/events/event_detail_screen.dart` |
| `crear-evento.png` | Formulario de creación de evento | `hsound/lib/screens/events/add_event_screen.dart` |
| `perfil.png` | Perfil del usuario oyente | `hsound/lib/screens/profile/profile_screen.dart` |
| `editar-perfil.png` | Edición del perfil | `hsound/lib/screens/profile/edit_profile_screen.dart` |

## Panel administrativo (`assets/screenshots/admin/`)

Se toman desde el navegador con la app en modo release o en el sitio desplegado. Formato horizontal recomendado: 1440x900 o 1920x1080.

| Archivo | Pantalla | Código fuente |
|---------|----------|---------------|
| `dashboard.png` | Dashboard con resumen de usuarios, canciones y eventos | `adminpanel_musical/lib/screens/dashboard_screen.dart` |
| `aprobaciones.png` | Aprobación de canciones y eventos | `adminpanel_musical/lib/screens/approvals_screen.dart` |
| `usuarios.png` | Gestión de usuarios y roles | `adminpanel_musical/lib/screens/users_screen.dart` |
| `canciones.png` | Gestión de canciones | `adminpanel_musical/lib/screens/songs_screen.dart` |

Opcionales para ampliar el README:

| Archivo | Pantalla | Código fuente |
|---------|----------|---------------|
| `login.png` | Inicio de sesión del panel | `adminpanel_musical/lib/screens/login_screen.dart` |
| `eventos.png` | Gestión de eventos | `adminpanel_musical/lib/screens/events_screen.dart` |
| `resenas.png` | Moderación de reseñas | `adminpanel_musical/lib/screens/reviews_screen.dart` |

## Recomendaciones para tomar las capturas

1. **Datos de prueba, no reales.** Usa canciones y artistas ficticios. No publiques correos, teléfonos ni nombres de personas reales.
2. **Sin sesión abierta ajena.** Si alguna pantalla muestra tu correo o tu foto de perfil, cierra sesión o usa una cuenta de prueba antes de capturar.
3. **Carga las listas.** Las capturas de tablas se ven vacías si no hay datos: crea al menos dos o tres registros de prueba en canciones, eventos y usuarios.
4. **Zoom al 100%** y sin la barra de direcciones del navegador si usas el modo captura de Chrome o Edge.
5. **Recorta** el espacio sobrante para que la captura ocupe todo el ancho asignado en el README.
6. **Sin datos de pago ni tokens.** El repositorio es público.
