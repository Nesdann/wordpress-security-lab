La IP pública la ve Internet.
Las IPs privadas existen solo dentro de tu red.

11. Qué hace la caja NAT

El router traduce:

192.168.0.5:52341
↓
181.x.x.x:60001

Mantiene una tabla interna.

Cuando vuelven paquetes:

sabe a qué máquina devolverlos.

NAT trabaja con:

IP
puerto
12. Qué pasa cuando abrís un puerto

Ejemplo:

python3 -m http.server 80

Tu PC escucha localmente.

Pero Internet NO puede acceder automáticamente.

El router debe redirigir tráfico:
(port forwarding)

13. Qué hace Nmap

Nmap pregunta:

"¿Hay procesos escuchando en estos puertos?"

Por eso:

22/tcp open ssh
80/tcp open http

significa:

hay sshd
hay nginx/apache/etc
14. Qué pasó con silentium.htb

Cuando conectaste a:

10.129.54.52:80

la conexión de red funcionó PERFECTAMENTE.

La NAT/routing ya habían hecho su trabajo.

Llegaste al servidor.

15. Entonces dónde apareció el problema

El problema apareció DESPUÉS.

El servidor web respondió:

Location: http://silentium.htb/

Eso es una redirección HTTP.

La hace nginx.
NO la hace NAT.
NO la hace DNS.

16. Entonces qué pasó después

Tu navegador intentó abrir:

silentium.htb

y necesitó resolver:

silentium.htb → IP

Ahí entra DNS.

17. Por qué falló

Porque:

silentium.htb no existe públicamente
HTB usa dominios internos

Entonces DNS no encuentra la IP.

18. Cómo se arregla

Agregando:

10.129.54.52 silentium.htb

en:

/etc/hosts
19. Qué hace /etc/hosts

Es una tabla local:

nombre → IP

Antes de consultar DNS:
Linux revisa /etc/hosts.

20. Entonces ahora sí funciona

Cuando escribís:

http://silentium.htb

tu máquina:

revisa /etc/hosts
obtiene IP
conecta a 10.129.54.52
manda:
Host: silentium.htb

Ahora nginx sabe exactamente qué sitio querés.

21. Host Header

En HTTP existe:

Host:

Ejemplo:

GET / HTTP/1.1
Host: silentium.htb

Eso le dice al servidor:

qué sitio web específico querés.

22. Virtual Hosts

Un mismo nginx puede servir MUCHOS sitios en una sola IP.

Ejemplo:

empresa.com
blog.com
api.com

todos desde:

misma IP
mismo puerto 80

El servidor diferencia usando:

Host:
23. Modelo mental correcto
IP

Identifica máquina.

Puerto

Identifica proceso/servicio.

Socket

Conexión real entre procesos.

NAT

Permite compartir IP pública.

DNS

Convierte nombre → IP.

HTTP Host Header

Indica qué sitio web específico querés.

Nginx/Apache

Procesa HTTP y sirve sitios.

24. Idea final importante

La red:

solo transporta paquetes.

Los procesos:

interpretan protocolos
toman decisiones
responden

En ciberseguridad:
TODO termina siendo:

enviar bytes
recibir bytes
explotar cómo un proceso interpreta esos bytes
