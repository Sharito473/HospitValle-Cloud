# app.py - API de signos vitales HospitValle-Cloud (Avance 2, basada en el laboratorio Sesion 7)
import math
import os
import random
import signal
import socket
import sys
from datetime import datetime
from flask import Flask, jsonify

app = Flask(__name__)
VERSION = os.environ.get("VERSION_APP", "v1")


def apagado_ordenado(signum, frame):
    # Docker y Kubernetes envian SIGTERM antes de detener el contenedor
    print("SIGTERM recibido: cerrando la API de forma ordenada", flush=True)
    sys.exit(0)


signal.signal(signal.SIGTERM, apagado_ordenado)


@app.route("/")
def inicio():
    return jsonify(
        servicio="HospitValle API - signos vitales",
        version=VERSION,
        atendido_por=socket.gethostname(),  # nombre del contenedor o del Pod
        hora=datetime.now().strftime("%H:%M:%S"),
    )


@app.route("/health")
def salud():
    return jsonify(estado="ok")


@app.route("/signos-vitales")
def signos_vitales():
    # Datos simulados de una cama de la UCE (el hospital tiene 10 camas de UCE)
    cama = f"UCE-{random.randint(1, 10):02d}"
    return jsonify(
        cama=cama,
        frecuencia_cardiaca_lpm=random.randint(55, 120),
        saturacion_oxigeno_pct=random.randint(90, 100),
        temperatura_c=round(random.uniform(36.0, 38.5), 1),
        hora=datetime.now().strftime("%H:%M:%S"),
    )


@app.route("/calcular")
def calcular():
    # Trabajo de CPU intencional para provocar el autoescalado (HPA)
    total = sum(math.sqrt(i) for i in range(300_000))
    return jsonify(resultado=round(total, 2), atendido_por=socket.gethostname())


if __name__ == "__main__":
    print(f"HospitValle API signos vitales {VERSION} escuchando en 0.0.0.0:5000", flush=True)
    app.run(host="0.0.0.0", port=5000)
