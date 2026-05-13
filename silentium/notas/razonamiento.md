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
1. Enumeración inicial
Fuzzing de directorios

Comando:

ffuf -u http://silentium.htb/FUZZ \
-w ~/Desktop/SecLists/Discovery/Web-Content/common.txt \
-fs 8753

Resultado relevante:

assets [Status: 301]
2. Análisis de /assets
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
3. Problema de wildcard/falsos positivos

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

4. Enumeración más profunda de assets

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
5. Enumeración de subdominios virtuales

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
6. Análisis de staging
Tecnología identificada

La página devuelve:

<title>Flowise - Build AI Agents, Visually</title>

Tecnología detectada:

Flowise
React
Vite
SPA frontend
7. Superficie funcional identificada

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
8. Confirmación de panel de login

Hallazgo:

staging expone login panel real
no es solo landing page

Implicancias:

autenticación
sesiones
cookies
JWT
APIs backend
