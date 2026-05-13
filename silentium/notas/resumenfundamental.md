# Redes, NAT, Puertos, Sockets y DNS — Resumen Fundamental

## 1. Qué es realmente Internet

Internet en el fondo es:

- máquinas enviando bytes
- máquinas recibiendo bytes

Nada más.

Toda comunicación termina siendo:
- paquetes
- conexiones
- procesos leyendo/escribiendo datos

---

# 2. Qué identifica una IP

La IP identifica una máquina (o interfaz de red).

Ejemplo:

10.129.54.52

Eso responde:
> "¿A qué computadora quiero llegar?"

Pero NO responde:
> "¿Qué programa dentro de esa computadora quiero usar?"

Ahí entran los puertos.

---

# 3. Qué es un puerto

Un puerto es un identificador lógico de comunicación.

Sirve para distinguir procesos/servicios dentro de una misma máquina.

Ejemplo:

| Puerto | Servicio |
|--------|----------|
| 22 | SSH |
| 80 | HTTP |
| 443 | HTTPS |

La IP identifica la máquina.
El puerto identifica el proceso.

---

# 4. Qué significa "puerto abierto"

Significa:

> hay un proceso escuchando conexiones ahí.

Ejemplo:

- nginx escucha puerto 80
- sshd escucha puerto 22

Entonces cuando llegan paquetes:
- el kernel mira el puerto destino
- entrega los datos al proceso correcto

---

# 5. Qué pasa si NO hay proceso escuchando

El kernel responde:
- closed
o
- filtered

porque:
> nadie quiere esos datos.

---

# 6. Qué es un socket

Un socket es un endpoint de comunicación.

Es la representación de una conexión de red entre procesos.

Una conexión TCP se identifica por:

- IP origen
- puerto origen
- IP destino
- puerto destino

---

# 7. Qué hace realmente un servidor

Ejemplo nginx:

1. crea socket
2. bind puerto 80
3. listen()
4. espera conexiones
5. accept()
6. lee bytes
7. responde bytes

Eso es un servidor.

---

# 8. TCP

TCP aporta:

- orden
- confiabilidad
- retransmisión
- control de errores

O sea:
> los bytes llegan completos y ordenados.

HTTP y SSH usan TCP.

---

# 9. NAT

NAT = Network Address Translation.

Permite que múltiples dispositivos internos compartan una sola IP pública.

---

# 10. Red de casa típica

```text
Internet
   |
IP pública
   |
Router (NAT)
   |
-------------------
|        |        |
PC      celular  notebook
192.168.x.x
