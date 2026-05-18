# Enumeración Frontend — HTML, JS y lógica de cliente

# 1. Inspección inicial del HTML

Se inspeccionó el código fuente HTML de la pagina


La página resultó ser:

extremadamente estática
corporativa/fake
sin formularios reales
sin autenticación
sin endpoints visibles
sin interacción backend aparente

Conclusión importante

El JavaScript es:

frontend puro

Toda la lógica:

corre en navegador
es local
no consulta backend
 Qué significa eso

La calculadora:

NO manda requests
NO interactúa con servidor
NO consume API

Entonces:

no parece existir superficie backend visible desde este JS
 Diferencia fundamental
Frontend

Corre:

en el navegador

Tecnologías:

HTML
CSS
JS

Visible para usuario.

Backend

Corre:

en servidor

Tecnologías típicas:

PHP
NodeJS
Python
Java
Go

Ahí suelen vivir:

auth
DB
business logic
vulnerabilidades reales
 Idea importante aprendida

Modificar frontend:

NO compromete servidor

Porque el JS:

corre localmente
en el navegador del atacante

Idea importante sobre frontend

Frontend sirve muchísimo para:

enumeración
reversing
descubrir APIs
descubrir endpoints
entender lógica cliente

Pero:

no toda lógica frontend implica vulnerabilidad
 Conclusión de esta página

La homepage:

parece señuelo/fake
demasiado simple
demasiado estática

No hay evidencia actual de:

APIs
backend expuesto
interacción dinámica
lógica sensible
 Conclusión operativa

Seguir perdiendo tiempo:

leyendo esta homepage
jugando con JS local
modificando DOM

probablemente NO aporte nada.

La superficie interesante probablemente:

esté en otra ruta
esté oculta
requiera enumeración
 Próximo paso correcto
Content Discovery / Directory Fuzzing

Usar:
ffuf

 Objetivo del fuzzing

Buscar:

rutas ocultas
paneles admin
APIs
uploads
backups
endpoints internos
dashboards

# Silentium - Recon Notes

## Objetivo

Host principal:


silentium.htb
 Enumeración inicial
Fuzzing de directorios

Comando:

ffuf -u http://silentium.htb/FUZZ \
-w ~/Desktop/SecLists/Discovery/Web-Content/common.txt \
-fs 8753

Resultado relevante:

assets [Status: 301]
 Análisis de /assets
Redirect observado
curl -I http://silentium.htb/assets

Respuesta:

HTTP/1.1 301 Moved Permanently
Location: http://silentium.htb/assets/

Interpretación:

nginx detecta que assets es un directorio
fuerza trailing slash /
Acceso al directorio
curl http://silentium.htb/assets/

Respuesta:

403 Forbidden

Interpretación:

el directorio existe
listing deshabilitado
nginx bloquea indexado
sigue siendo útil porque confirma superficie real
 Problema de wildcard/falsos positivos

Se detectó que el host respondía:

status 200
mismo tamaño
misma cantidad de palabras

para requests inexistentes.

Ejemplo:

~sysadmin
~tmp
~user

Todos devolvían:

Status: 200
Size: 8753

Conclusión:

fallback page
catch-all routing
SPA frontend
falsos positivos

Solución:

-fs 8753

para filtrar respuestas basura.

 Enumeración más profunda de assets

Comando:

ffuf -u http://silentium.htb/assets/FUZZ \
-w ~/Desktop/SecLists/Discovery/Web-Content/common.txt \
-e .js,.txt,.map,.bak,.old \
-fs 8753

Hallazgo importante:

app.js [Status: 200, Size: 1304]

Conclusión:

existe JS accesible
potencial para extraer:
endpoints
APIs
tokens
rutas ocultas
tecnologías
 Enumeración de subdominios virtuales

Comando:

ffuf -u http://silentium.htb \
-H "Host: FUZZ.silentium.htb" \
-w ~/Desktop/SecLists/Discovery/DNS/subdomains-top1million-5000.txt \
-fs 178

Hallazgo importante:

staging [Status: 200, Size: 3142]

Conclusión:

existe virtual host:
staging.silentium.htb
superficie nueva encontrada
probablemente entorno de testing/dev

Agregar a /etc/hosts:

IP staging.silentium.htb
 Análisis de staging
Tecnología identificada

La página devuelve:

<title>Flowise - Build AI Agents, Visually</title>

Tecnología detectada:

Flowise
React
Vite
SPA frontend
 Superficie funcional identificada

Desde JS bundle se identificaron módulos/componentes:

Auth
login
register
forgotPassword
resetPassword
auth
auth0
github
sso
Features internas
assistants
chatflows
documentstore
vectorstore
marketplace
workspace
evaluations
datasets
Componentes sensibles
ExecutionDetails
NodeExecutionDetails
CredentialInputHandler
CredentialListDialog

Interpretación:

posible ejecución de workflows
manejo de credenciales
APIs administrativas
potencial SSRF/RCE
 Confirmación de panel de login

Hallazgo:

staging expone login panel real
no es solo landing page

Implicancias:

autenticación
sesiones
cookies
JWT
APIs backend
El HTML inicial mostraba:

 <script type="module" crossorigin src="/assets/index-C6GKaUTA.js"></script>
Comprensión del frontend moderno

Se identificó que el HTML inicial no contenía funcionalidad real.

El frontend estaba construido como SPA (Single Page Application):

React renderiza dinámicamente
El backend se consume mediante APIs
El JS contiene:
rutas
endpoints
lógica auth
componentes
features internas

Gran parte del HTML encontrado era solo:

metadata
OpenGraph
Twitter cards
fuentes Google
analytics externos
 Descarga del bundle JavaScript

Se descargó el JS principal:

curl -s http://staging.silentium.htb/assets/index-C6GKaUTA.js -o flowise.js
 Problema inicial: JS minimizado

El archivo estaba minificado.

Consecuencia:

todo el JS estaba en una sola línea
grep devolvía prácticamente el archivo entero

Ejemplo:

grep api flowise.js

Resultado:

ilegible
demasiado ruido
 Técnicas usadas para hacerlo legible
Separar por ;
cat flowise.js | tr ';' '\n' | less

Esto mejoró muchísimo la lectura.

Separar por ,
cat flowise.js | tr ',' '\n' | less

Útil para arrays gigantes y dependencias.

Extraer strings
strings flowise.js

y:

strings flowise.js | grep -i api

Esto permitió encontrar rutas y palabras interesantes.

Uso correcto de grep con archivos minificados

En vez de:

grep api flowise.js

se utilizó:

grep -oE '/api/[A-Za-z0-9/_?.=&-]+' flowise.js

-o imprime solo el match y evita mostrar toda la línea.

 Información sensible encontrada
Endpoints API reales
/api/v1
/api/v1/auth/refreshToken
/api/v1/version

Esto confirmó:

existencia de backend REST
sistema de autenticación
refresh tokens
versionado de API
Variables de entorno frontend
VITE_API_BASE_URL
VITE_UI_BASE_URL

Importante porque:

Vite inyecta configuración del entorno
puede revelar infraestructura
puede mostrar backend real

js-beautify flowise.js > pretty.js
# endpoints API
grep -oE '/api/[A-Za-z0-9/_?.=&-]+' flowise.js | sort -u
# rutas interesantes
grep -oiE 'login|register|resetpassword|apikey|credential|workspace|execution|assistant|vectorstore|documentstore|chatflow|admin|user' flowise.js | sort -u# rutas interesantes
grep -oiE 'login|register|resetpassword|apikey|credential|workspace|execution|assistant|vectorstore|documentstore|chatflow|admin|user' flowise.js | sort -u
# URLs completas
grep -oE 'https?://[^"]+' flowise.js | sort -u
# variables de entorno
grep -oE 'VITE_[A-Z0-9_]+' flowise.js | sort -u
# posibles secretos/tokens
grep -oiE 'token|secret|apikey|api_key|jwt|bearer|password|passwd|authorization' flowise.js | sort -u
# llamadas fetch
grep -oE 'fetch\([^)]+' flowise.js
# axios
grep -oiE 'axios\.[a-z]+' flowise.js | sort -u
# métodos HTTP
grep -oiE '"GET"|"POST"|"PUT"|"DELETE"|"PATCH"' flowise.js | sort -u
# paneles o componentes internos
grep -oiE 'Admin|Login|Dashboard|Workspace|Credential|Execution|Webhook|Assistant|Marketplace|UserProfile' flowise.js | sort -u
# nombres largos útiles
grep -oE '[A-Za-z0-9/_-]{15,}' flowise.js | sort -u | less
# romper el archivo por ,
cat flowise.js | tr ',' '\n' | less
# strings relacionadas a auth
strings flowise.js | grep -iE 'auth|login|token|jwt|session|cookie'
# endpoints potenciales limpios
grep -oE '/[A-Za-z0-9/_-]+' flowise.js | sort -u | less
# cosas relacionadas a usuarios
grep -oiE 'user|users|invite|role|permission|auth0|github|sso' flowise.js | sort -u
# dump de posibles endpoints
grep -oE '/api/[A-Za-z0-9/_?.=&-]+' flowise.js | sort -u > apis.txt
# dump de URLs
grep -oE 'https?://[^"]+' flowise.js | sort -u > urls.txt

El análisis comenzó con la inspección del JavaScript del frontend. A partir del archivo minificado se logró identificar información relevante sobre la aplicación y su backend. Esto permitió inferir que la instancia correspondía a una API expuesta bajo /api/v1/, asociada a una versión vulnerable del sistema.

Un punto crítico del análisis fue la identificación explícita de la versión del software. Mediante la revisión del código JavaScript se obtuvo la versión de Flowise expuesta por la aplicación, identificada como Flowise 3.0.5, la cual resulta crítica debido a la existencia de vulnerabilidades conocidas en ese rango de versiones. Este hallazgo determinó el enfoque posterior del análisis hacia la búsqueda de exposición de secretos y bypass de autenticación.

A partir de este punto se profundizó en la revisión del frontend con el objetivo de encontrar información sensible embebida en el código. Se buscaron patrones típicos como correos electrónicos, tokens de sesión, claves API y credenciales residuales. Esta fase no arrojó correos adicionales ni credenciales reutilizables directas, pero sí permitió identificar la presencia de un valor denominado DefaultKey, lo que sugería la existencia de un mecanismo alternativo de autenticación basado en API keys además del flujo de login convencional.

Con este contexto, el siguiente paso fue analizar el sistema de autenticación de la aplicación. El endpoint de login se encontraba operativo, pero correctamente protegido contra credenciales inválidas, devolviendo respuestas de acceso denegado. Esto confirmó que el flujo de autenticación principal no era trivialmente explotable.

Posteriormente se exploró el endpoint de recuperación de contraseña. Al interactuar con el mecanismo de “forgot password” utilizando un correo válido, la API respondió exponiendo el objeto completo del usuario. Dentro de esta respuesta se incluían datos sensibles como el hash de la contraseña y un tempToken asociado al proceso de reseteo. Este comportamiento evidenció una vulnerabilidad crítica de fuga de información en el backend, ya que el token de recuperación era devuelto directamente por la API.

Con el tempToken obtenido se intentó acceder a endpoints internos relacionados con MCP y carga de nodos, específicamente el endpoint node-load-method/customMCP. Sin embargo, todas las solicitudes fueron rechazadas con errores de autorización, indicando que dicho token no otorgaba privilegios sobre la funcionalidad administrativa o de ejecución.

En paralelo se continuó la investigación sobre las credenciales expuestas en el frontend. El valor DefaultKey fue reutilizado como posible API key o credencial de servicio en los headers de autorización. A pesar de esto, el acceso a los endpoints protegidos continuó fallando, devolviendo nuevamente respuestas de “Unauthorized Access”.

En este punto se concluye que, aunque se logró la extracción de información sensible crítica (versión del sistema, API key interna y token de reseteo de contraseña), el acceso a funcionalidades de ejecución en MCP aún requiere un mecanismo de autenticación adicional o un contexto privilegiado distinto al obtenido hasta el momento

(CVE-2025-59528  https://github-com.translate.goog/advisories/GHSA-3gcm-f6qx-ff7p?_x_tr_sl=en&_x_tr_tl=es-419&_x_tr_hl=es-419&_x_tr_pto=sc)

nf@nf-To-Be-Filled-By-O-E-M:~/Desktop/wordpress-security-lab/silentium/content$ curl -X POST \
http://staging.silentium.htb/api/v1/account/forgot-password \
-H "Content-Type: application/json" \
-d '{"user":{"email":"ben@silentium.htb"}}'


va a devolver el tokentemp luego cambiamos la contrasena y accedemos 

luego en el panel vamos a encontrar una api key por lo cual podemos explotar el cve2025-53528
accedemos al conetedor docket hacemos un printenv obtenemos la contrasena de ben y entramos atravez de ssh
HOST REAL (Ubuntu)
└── Docker daemon
    └── Contenedor Flowise (Alpine)
FLOWISE_USERNAME=ben
FLOWISE_PASSWORD=F1l3_d0ck3r

shh ben@silentium.htb 
