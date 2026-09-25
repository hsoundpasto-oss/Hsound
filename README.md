# HSound

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Firestore](https://img.shields.io/badge/Firestore-FFA000?style=for-the-badge&logo=firebase&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Universidad Mariana](https://img.shields.io/badge/Trabajo%20de%20grado-7B1FA2?style=for-the-badge&logo=google&logoColor=white)

<p align="center">
  <img src="assets/banner.png" alt="Banner de HSound" width="100%">
</p>

## Descripci├│n

**HSound** es una aplicaci├│n m├│vil desarrollada en Flutter que conecta artistas musicales de **Pasto, Nari├▒o** con su comunidad. Los artistas publican sus canciones mediante enlaces de **YouTube, Spotify y SoundCloud**, y los oyentes descubren m├║sica local, buscan por g├®nero y guardan sus canciones favoritas.

El proyecto est├í compuesto por **dos aplicaciones Flutter** que comparten la misma base de datos en Cloud Firestore:

- **`hsound`** es la app m├│vil dirigida a artistas y oyentes.
- **`adminpanel_musical`** es el panel web de administraci├│n para la gesti├│n de usuarios y contenido.

**HSound** es un **trabajo de grado** del programa de Ingenier├¡a de Sistemas de la **Universidad Mariana**, presentado como requisito para obtener el t├¡tulo de Ingeniero de Sistemas.

## Autores

| Autor | Rol | Perfil |
|-------|-----|--------|
| Burbano Bastidas Sof├¡a | Autora | [![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/sofia-burbano-46a513341) |
| Ibarra Rosero Esneyder Jes├║s | Autor | [![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/esneyder-ibarra-rosero) |

**Asesor:** Wilson Andr├®s Castillo Castro

**Instituci├│n:** [![Universidad Mariana](https://img.shields.io/badge/Universidad%20Mariana-7B1FA2?style=for-the-badge&logo=google&logoColor=white)](https://www.umariana.edu.co) ÔÇö Facultad de Ingenier├¡a, Programa de Ingenier├¡a de Sistemas, San Juan de Pasto

**A├▒o:** 2026

## Demo en vivo

El panel administrativo est├í desplegado y accesible desde:

**https://hsound-8aad2.web.app**

> **Nota:** el panel requiere iniciar sesi├│n con una cuenta de administrador. La app m├│vil no est├í publicada en las tiendas; se ejecuta localmente siguiendo las instrucciones de la secci├│n de instalaci├│n.

## Funcionalidades principales

| M├│dulo | Descripci├│n |
|--------|-------------|
| ![Auth](https://img.shields.io/badge/Autenticaci├│n-7E57C2?style=flat-square&logo=google&logoColor=white) | Registro e inicio de sesi├│n con correo y con Google |
| ![Inicio](https://img.shields.io/badge/Inicio-E53935?style=flat-square&logo=google&logoColor=white) | Feed de canciones y eventos destacados del musically local |
| ![B├║squeda](https://img.shields.io/badge/B├║squeda-1E88E5?style=flat-square&logo=google&logoColor=white) | B├║squeda avanzada con filtros por g├®nero y popularidad |
| ![Favoritos](https://img.shields.io/badge/Favoritos-D81B60?style=flat-square&logo=google&logoColor=white) | Sistema de favoritos sincronizado en tiempo real |
| ![Reproductor](https://img.shields.io/badge/Reproductor-00897B?style=flat-square&logo=google&logoColor=white) | Reproducci├│n de m├║sica desde YouTube, Spotify y SoundCloud |
| ![Perfil de artista](https://img.shields.io/badge/Perfil%20de%20artista-5E35B1?style=flat-square&logo=google&logoColor=white) | Biograf├¡a, foto y enlaces a redes sociales |
| ![Publicaci├│n](https://img.shields.io/badge/Publicaci├│n-F4511E?style=flat-square&logo=google&logoColor=white) | Publicaci├│n de canciones y eventos mediante enlaces externos |
| ![Panel admin](https://img.shields.io/badge/Panel%20admin-6D4C41?style=flat-square&logo=google&logoColor=white) | Aprobaci├│n de contenido, gesti├│n de usuarios y rese├▒as |

## Capturas de pantalla

Las capturas se guardan en `assets/screenshots/` con esta estructura:

```
assets/screenshots/
Ôö£ÔöÇÔöÇ app/       ÔåÆ aplicaci├│n m├│vil
ÔööÔöÇÔöÇ admin/     ÔåÆ panel web de administraci├│n
```

Esta carpeta vive en la ra├¡z del repositorio y **no** forma parte de ninguna de las dos aplicaciones Flutter, por lo que no se empaqueta en los builds ni incrementa su tama├▒o.

### App m├│vil

<p align="center">
  <img src="assets/screenshots/app/inicio.png" alt="Feed de inicio" width="260">
  <img src="assets/screenshots/app/busqueda.png" alt="B├║squeda con filtros" width="260">
  <img src="assets/screenshots/app/reproductor.png" alt="Reproductor de canci├│n" width="260">
</p>

<p align="center">
  <img src="assets/screenshots/app/favoritos.png" alt="Lista de favoritos" width="260">
  <img src="assets/screenshots/app/perfil-artista.png" alt="Perfil de artista" width="260">
  <img src="assets/screenshots/app/registro.png" alt="Registro e inicio de sesi├│n" width="260">
</p>

### Panel administrativo

<p align="center">
  <img src="assets/screenshots/admin/dashboard.png" alt="Dashboard del panel" width="420">
  <img src="assets/screenshots/admin/aprobaciones.png" alt="Aprobaci├│n de contenido" width="420">
</p>

<p align="center">
  <img src="assets/screenshots/admin/usuarios.png" alt="Gesti├│n de usuarios" width="420">
  <img src="assets/screenshots/admin/canciones.png" alt="Gesti├│n de canciones" width="420">
</p>

## Funcionalidades

### App m├│vil (`hsound`)
- **Autenticaci├│n:** registro e inicio de sesi├│n con correo y contrase├▒a, y acceso con cuenta de Google.
- **Inicio:** feed de canciones publicadas por artistas de la regi├│n.
- **B├║squeda:** b├║squeda de canciones con filtros por g├®nero y popularidad.
- **Reproductor:** reproducci├│n de la canci├│n desde la plataforma externa donde el artista la public├│.
- **Favoritos:** marcado y desmarcar de canciones, sincronizado en tiempo real entre dispositivos.
- **Perfil de artista:** foto, biograf├¡a y enlaces a Facebook, Instagram, Spotify, TikTok, YouTube y WhatsApp.
- **Publicaci├│n:** los artistas con rol `isArtist` pueden registrar canciones y eventos mediante enlaces externos.
- **Eventos:** creaci├│n y consulta de eventos con fecha, lugar y descripci├│n.

### Panel administrativo (`adminpanel_musical`)
- **Inicio de sesi├│n:** acceso restringido a cuentas de administrador.
- **Dashboard:** resumen de usuarios, canciones y eventos.
- **Aprobaciones:** revisi├│n y aprobaci├│n de canciones y eventos enviados por los artistas.
- **Usuarios:** gesti├│n de cuentas, activaci├│n y cambio de rol.
- **Canciones:** listado, edici├│n y eliminaci├│n de canciones publicadas.
- **Eventos:** gesti├│n del calendario de eventos.
- **Rese├▒as:** moderaci├│n de comentarios y reportes de los usuarios.

## Base de datos

Cloud Firestore con cinco colecciones. El modelo completo est├í en `hsound_db_diagram.mermaid` y su versi├│n renderizada en `hsound_db_diagram.png`.

```
USERS ||--o{ SONGS     : "artistId -> es el artista"
USERS ||--o{ EVENTS    : "artistId -> es el artista"
USERS ||--o{ USERLIKES : "userId -> da like"
SONGS ||--o{ USERLIKES : "songId -> recibe like"
USERS ||--o{ SONGS     : "reviewedBy -> revisa canciones"
USERS ||--o{ EVENTS    : "reviewedBy -> revisa eventos"
```

| Colecci├│n | Contenido |
|-----------|-----------|
| `users` | Perfiles, roles (`isArtist`, `isAdmin`), biograf├¡as y redes sociales |
| `songs` | Canciones publicadas con su enlace externo y estado de revisi├│n |
| `events` | Eventos con fecha, lugar y estado de revisi├│n |
| `userLikes` | Relaci├│n entre usuario y canci├│n, para el sistema de favoritos |
| `admin` | Documentos de configuraci├│n del panel administrativo |

## Tecnolog├¡as utilizadas

| Capa | Tecnolog├¡a |
|------|------------|
| App m├│vil | Flutter / Dart 3.9, `flutter_riverpod` para el estado |
| Panel web | Flutter Web / Dart 3.9, `provider` para el estado |
| Backend | Cloud Firestore, Firebase Authentication, Cloud Storage |
| Backend serverless | Cloud Functions (`functions/`), callable `syncUserEmails` |
| Integraciones | YouTube, Spotify y SoundCloud mediante `flutter_inappwebview` y `url_launcher` |
| Hosting | Firebase Hosting (panel administrativo) |
| Reglas de seguridad | `firestore.rules` con validaci├│n de roles |

## Estructura del proyecto

```
Hsound/
Ôö£ÔöÇÔöÇ hsound/                          ÔåÆ aplicaci├│n m├│vil Flutter
Ôöé   Ôö£ÔöÇÔöÇ lib/
Ôöé   Ôöé   Ôö£ÔöÇÔöÇ screens/                 ÔåÆ 13 pantallas (auth, home, b├║squeda, favoritos, perfil, canciones, eventos)
Ôöé   Ôöé   Ôö£ÔöÇÔöÇ firebase_options.dart    ÔåÆ configuraci├│n de Firebase (generada por flutterfire)
Ôöé   Ôöé   ÔööÔöÇÔöÇ main.dart                ÔåÆ punto de entrada e inicializaci├│n
Ôöé   Ôö£ÔöÇÔöÇ assets/images/               ÔåÆ logo, ├¡conos de redes sociales y plataformas
Ôöé   Ôö£ÔöÇÔöÇ test/                        ÔåÆ pruebas de los sprints 1, 2, 4, 6 y 7
Ôöé   ÔööÔöÇÔöÇ pubspec.yaml
Ôö£ÔöÇÔöÇ adminpanel_musical/              ÔåÆ panel web de administraci├│n Flutter
Ôöé   Ôö£ÔöÇÔöÇ lib/
Ôöé   Ôöé   Ôö£ÔöÇÔöÇ screens/                 ÔåÆ 7 pantallas (login, dashboard, aprobaciones, usuarios, canciones, eventos, rese├▒as)
Ôöé   Ôöé   Ôö£ÔöÇÔöÇ firebase_options.dart    ÔåÆ configuraci├│n de Firebase
Ôöé   Ôöé   ÔööÔöÇÔöÇ main.dart
Ôöé   Ôö£ÔöÇÔöÇ test/                        ÔåÆ pruebas de los sprints 3 y 5
Ôöé   ÔööÔöÇÔöÇ pubspec.yaml
Ôö£ÔöÇÔöÇ functions/                       ÔåÆ Cloud Functions
Ôöé   Ôö£ÔöÇÔöÇ index.js                     ÔåÆ funci├│n callable syncUserEmails
Ôöé   ÔööÔöÇÔöÇ package.json
Ôö£ÔöÇÔöÇ assets/
Ôöé   Ôö£ÔöÇÔöÇ banner.png                   ÔåÆ portada de este README
Ôöé   ÔööÔöÇÔöÇ screenshots/                 ÔåÆ capturas (no se empaqueta en los builds)
Ôö£ÔöÇÔöÇ firestore.rules                  ÔåÆ reglas de seguridad de Firestore
Ôö£ÔöÇÔöÇ firestore.indexes.json           ÔåÆ ├¡ndices compuestos
Ôö£ÔöÇÔöÇ firebase.json                    ÔåÆ Hosting, Firestore
Ôö£ÔöÇÔöÇ hsound_db_diagram.mermaid        ÔåÆ modelo de datos en Mermaid
Ôö£ÔöÇÔöÇ hsound_db_diagram.png            ÔåÆ modelo de datos renderizado
Ôö£ÔöÇÔöÇ Manual_Usuario_HSound.pdf        ÔåÆ manual de usuario
ÔööÔöÇÔöÇ README.md
```

## Requisitos previos

- **Flutter** con Dart 3.9 o superior
- **Node.js y npm** (para las Cloud Functions)
- **Cuenta de Firebase** y **Firebase CLI** (`npm install -g firebase-tools`)

## Instalaci├│n y ejecuci├│n

El repositorio contiene dos aplicaciones independientes. Ejecuta `flutter pub get` y `flutter run` dentro de cada carpeta.

### 1. Clonar el repositorio

```
git clone https://github.com/hsoundpasto-oss/Hsound.git
cd Hsound
```

### 2. App m├│vil

```
cd hsound
flutter pub get
flutter run
```

Selecciona el emulador o dispositivo Android, iOS, Windows o web. La app usa `flutter_inappwebview`, por lo que **no funciona en el navegador web**; necesita una plataforma m├│vil o de escritorio.

### 3. Panel administrativo

```
cd adminpanel_musical
flutter pub get
flutter run -d chrome
```

### 4. Cloud Functions

```
cd functions
npm install
firebase deploy --only functions
```

### 5. Conectar con tu cuenta de Firebase

Las dos apps incluyen su `firebase_options.dart`. Si vas a usar tu propia cuenta, ejecuta en cada carpeta:

```
dart pub global activate flutterfire_cli
flutterfire configure
```

Esto regenera el archivo de configuraci├│n con las credenciales de tu proyecto.

### 6. Publicar el panel administrativo

El hosting toma los archivos desde `adminpanel_musical/build/web`, as├¡ que primero hay que compilar:

```
cd adminpanel_musical
flutter build web --release
cd ..
firebase deploy --only hosting
```

Las reglas de seguridad se publican por separado:

```
firebase deploy --only firestore:rules,firestore:indexes
```

## Pruebas

Las pruebas est├ín organizadas por sprint de desarrollo y se ejecutan por aplicaci├│n:

```
cd hsound
flutter test

cd ../adminpanel_musical
flutter test
```

| Sprint | Archivo | ├ümbito |
|--------|---------|--------|
| 1 | `hsound/test/sprint1_login_test.dart` | Inicio de sesi├│n |
| 2 | `hsound/test/sprint2_artista_test.dart` | Perfil de artista |
| 3 | `adminpanel_musical/test/sprint3_admin_test.dart` | Panel de administraci├│n |
| 4 | `hsound/test/sprint4_favoritos_test.dart` | Sistema de favoritos |
| 5 | `adminpanel_musical/test/sprint5_gestion_test.dart` | Gesti├│n de contenido |
| 6 | `hsound/test/sprint6_compartir_test.dart` | Compartir contenido |
| 7 | `hsound/test/sprint7_ui_test.dart` | Interfaz de usuario |

## Modelo de datos

![Modelo de datos](hsound_db_diagram.png)

## Manual de usuario

El manual de usuario del proyecto est├í en [`Manual_Usuario_HSound.pdf`](Manual_Usuario_HSound.pdf).

## Estado del proyecto

| Aspecto | Estado |
|---------|--------|
| Aplicaci├│n m├│vil | Funcional, se ejecuta localmente |
| Panel administrativo | Funcional y desplegado en Firebase Hosting |
| Cloud Firestore | Esquema de 5 colecciones definido y con reglas de seguridad |
| Cloud Functions | Implementada la funci├│n `syncUserEmails` |
| Pruebas | 9 archivos de prueba organizados por sprint |
| Publicaci├│n en tiendas | No realizada |

## Notas de seguridad

Este repositorio es p├║blico, por lo que conviene tener presentes los siguientes puntos antes de operar el proyecto:

- **Correos de administrador en el c├│digo.** La funci├│n `isAdmin()` de `firestore.rules` y la lista `adminEmails` de `functions/index.js` incluyen direcciones de correo reales como condici├│n de administrador. Conviene migrar esa validaci├│n al campo `isAdmin` del documento del usuario en la colecci├│n `users`, que ya est├í contemplado en las reglas y evita exponer datos personales en el c├│digo.
- **Lectura de la colecci├│n `users`.** Las reglas permiten que cualquier usuario autenticado lea el conjunto de documentos de `users`, lo que incluye correos y datos de contacto. Si no es necesario para el funcionamiento de la aplicaci├│n, conviene restringir la lectura al propio documento del usuario y a los perfiles p├║blicos que el cliente necesite.
- **`firebase_options.dart`.** Contiene la configuraci├│n p├║blica del proyecto de Firebase. No es una credencial secreta por dise├▒o, pero conviene restringir la clave desde la consola de Google Cloud por dominio.
- **Antes de publicar** en las tiendas, revisa que las capturas y el manual no incluyan correos personales, tokens de acceso ni datos de usuarios reales.

## Preguntas frecuentes

**┬┐Por qu├® la app m├│vil no corre en el navegador?**
Usa `flutter_inappwebview` para reproducir contenido de YouTube, Spotify y SoundCloud, que no est├í soportado en web. Usa el emulador de Android o una plataforma de escritorio.

**┬┐C├│mo agrego un administrador?**
Crea el usuario en Firebase Authentication y luego, en la colecci├│n `users` de Firestore, agrega el campo `isAdmin: true` a su documento. Ese campo ya est├í contemplado en la funci├│n `isAdmin()` de las reglas de seguridad.

**┬┐C├│mo se vincula una canci├│n con su audio?**
El artista no sube el archivo de audio: registra un enlace externo a YouTube, Spotify o SoundCloud, y la app reproduce desde esa plataforma.

**┬┐El panel administrativo es p├║blico?**
No. Requiere iniciar sesi├│n con una cuenta que cumpla la condici├│n de administrador.

**┬┐Hay que subir `firebase_options.dart` a Git?**
Est├í incluido para que el proyecto funcione al clonarlo. Si prefieres no publicarlo, b├│rralo del control de versiones, agr├®galo a `.gitignore` y genera el tuyo con `flutterfire configure`.

---

<p align="center">
  <strong>Trabajo de grado</strong><br>
  Facultad de Ingenier├¡a, Programa de Ingenier├¡a de Sistemas
</p>

<p align="center">
  <a href="https://www.linkedin.com/in/sofia-burbano-46a513341">
    <img src="https://img.shields.io/badge/Burbano%20Bastidas%20Sof%C3%ADa-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white" alt="Burbano Bastidas Sof├¡a">
  </a>
  <a href="https://www.linkedin.com/in/esneyder-ibarra-rosero">
    <img src="https://img.shields.io/badge/Ibarra%20Rosero%20Esneyder%20Jes%C3%BAs-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white" alt="Ibarra Rosero Esneyder Jes├║s">
  </a>
</p>

<p align="center">
  <a href="https://www.umariana.edu.co">
    <img src="https://img.shields.io/badge/Universidad%20Mariana-7B1FA2?style=for-the-badge&logo=google&logoColor=white" alt="Universidad Mariana">
  </a>
  <a href="https://hsound-8aad2.web.app">
    <img src="https://img.shields.io/badge/Panel%20administrativo-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Panel administrativo">
  </a>
  <a href="Manual_Usuario_HSound.pdf">
    <img src="https://img.shields.io/badge/Manual%20de%20usuario-7E57C2?style=for-the-badge&logo=google&logoColor=white" alt="Manual de usuario">
  </a>
</p>
