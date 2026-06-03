H Sound: Prototipo de Aplicación Móvil para la Promoción del Talento Artístico Musical en Pasto - Nariño

Autores
Burbano Bastidas Sofia
Ibarra Rosero Esneyder Jesús

Trabajo de grado como requisito para obtener el título de Ingeniero de Sistemas

Asesor
Wilson Andrés Castillo Castro

Universidad Mariana
Facultad de Ingeniería
Programa de Ingeniería de Sistemas
San Juan de Pasto
2026

¿Qué es HSound?

HSound es una aplicación móvil que nació para ayudar a los artistas musicales de la ciudad de Pasto a ser más visibles y para que la gente pueda descubrir el talento que hay en su propia ciudad

La aplicación permite que los artistas locales creen su perfil público con su biografía, su foto, el género musical que interpretan y los instrumentos que tocan también pueden subir sus canciones usando enlaces de YouTube, Spotify o SoundCloud y pueden crear eventos musicales para que la gente sepa dónde y cuándo se van a presentar

Los oyentes por su parte pueden escuchar la música directamente desde la app sin tener que salir de ella pueden buscar canciones por género o por artista pueden marcar sus canciones favoritas y compartir el contenido en sus redes sociales

Además la aplicación cuenta con un panel web de administración donde los administradores pueden gestionar usuarios aprobar o rechazar canciones y eventos y ver estadísticas de la plataforma

HSound no es como Spotify porque no guarda la música en sus propios servidores solo usa enlaces externos de plataformas que ya existen y su valor no está en la cantidad de canciones sino en que es un catálogo exclusivo de artistas de Pasto

---

Tecnologías que usa HSound

La aplicación está construida con Flutter que es un framework creado por Google para hacer aplicaciones móviles y web con un solo código

Para guardar los datos se usa Firebase que es una plataforma de Google que ofrece varios servicios sin necesidad de tener un servidor propio

Firebase Authentication maneja el registro y el inicio de sesión de los usuarios que pueden entrar con correo y contraseña o con su cuenta de Google

Firestore es la base de datos donde se guarda toda la información de usuarios canciones likes y eventos

Firebase Storage se usa para guardar las fotos de perfil que los usuarios suben

Firebase Hosting se usa para publicar el panel web de administración en internet de forma gratuita en la dirección hsound-8aad2.web.app

El panel web de administración también está hecho en Flutter y permite a los administradores gestionar toda la plataforma desde un navegador

---

Estructura de la base de datos

HSound utiliza Firestore que es una base de datos NoSQL la información se organiza en colecciones y documentos

La colección users guarda la información de cada usuario como su nombre su correo si es artista o no su biografía su foto de perfil y los enlaces a sus redes sociales como YouTube Spotify Instagram TikTok WhatsApp y Facebook

La colección songs guarda la información de cada canción como el título el nombre del artista el género musical la plataforma donde está alojada el enlace para reproducirla y un contador de likes

La colección userLikes guarda los likes que los usuarios le dan a las canciones cada registro tiene el identificador del usuario y el identificador de la canción

La colección events guarda la información de los eventos musicales como el título la descripción el lugar la dirección el enlace de Google Maps la fecha y el precio

---

Funcionalidades principales

Los usuarios pueden registrarse con correo y contraseña o con su cuenta de Google

Los artistas pueden crear y editar su perfil agregando su biografía su género musical y los instrumentos que tocan

Los artistas pueden subir canciones usando enlaces de YouTube Spotify y SoundCloud

Los artistas pueden crear eventos musicales con lugar dirección fecha y precio

Los oyentes pueden buscar canciones por título o por género y buscar artistas por nombre género o instrumento

Los oyentes pueden reproducir las canciones directamente dentro de la app usando los reproductores oficiales de cada plataforma

Los oyentes pueden marcar canciones como favoritas y ver su lista de favoritos

Los oyentes pueden compartir canciones y perfiles de artistas en redes sociales

Los administradores pueden gestionar usuarios canciones y eventos desde el panel web

Los administradores pueden aprobar o rechazar las canciones y eventos que suben los artistas antes de que se publiquen

---


Cómo instalar y ejecutar HSound en otra computadora desde GitHub

Si quieres descargar el proyecto desde GitHub y ejecutarlo en otra computadora debes seguir estos pasos

Prerrequisitos

Antes de empezar asegúrate de que la computadora tenga instalado lo siguiente

Flutter en su versión más reciente puedes descargarlo desde la página oficial de Flutter

Un editor de código como Visual Studio Code o Android Studio

Un emulador de Android o un celular real conectado por USB con la depuración USB activada

Git para poder clonar el repositorio

Paso 1 Clonar el repositorio desde GitHub

Abre la terminal en la carpeta donde quieras guardar el proyecto y ejecuta el siguiente comando

```bash
git clone https://github.com/TU-USUARIO/HSound-App.git
```

Reemplaza TU-USUARIO con el nombre de tu usuario de GitHub

Paso 2 Entrar a la carpeta del proyecto

```bash
cd HSound-App
```

Paso 3 Instalar las dependencias del proyecto

Ejecuta este comando para que Flutter descargue todas las bibliotecas y paquetes que necesita la aplicación

```bash
flutter pub get
```

Paso 4 Ejecutar la aplicación móvil

Conecta un celular por USB o inicia un emulador de Android y ejecuta

```bash
flutter run
```

Paso 5 Ejecutar el panel web de administración

Abre otra terminal ve a la carpeta del panel admin y ejecuta

```bash
cd adminpanel_musical
flutter pub get
flutter run -d chrome
```

El panel web se abrirá automáticamente en tu navegador en la dirección localhost



Solución de problemas comunes

Si al ejecutar flutter pub get te sale un error significa que no tienes conexión a internet o que falta instalar Flutter correctamente

Si al ejecutar flutter run te sale un error de que no hay dispositivos conectados significa que no tienes un emulador abierto ni un celular conectado por USB

Si los emojis o íconos no se ven bien significa que debes ejecutar flutter clean y luego flutter pub get nuevamente

---

Enlaces importantes

El panel web de administración está publicado en 
https://hsound-8aad2.web.app

El enlace de descarga del APK está en 

https://drive.google.com/drive/folders/11coN6w5jWHiFhzWn-cMqA5BRtXO1eZn6

---

Contacto

Si tienes preguntas o encuentras algún problema puedes escribir al correo hsoundpasto@gmail.com

---

© 2026 - Universidad Mariana - Programa de Ingeniería de Sistemas

Todos los derechos reservados

---
