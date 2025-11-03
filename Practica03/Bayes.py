import os
import csv
from collections import defaultdict
from fractions import Fraction


# ---------------------------------------------------------
# Función para listar archivos .txt y que el usuario elija
# ---------------------------------------------------------
def seleccionar_archivo_txt():
    archivos = [f for f in os.listdir() if f.endswith(".txt")]

    if not archivos:
        print(" No se encontraron archivos .txt en esta carpeta.")
        exit()

    print("Archivos disponibles:\n")
    for i, archivo in enumerate(archivos, start=1):
        print(f"{i}. {archivo}")

    while True:
        try:
            opcion = int(input("\nSeleccione el número del archivo: "))
            if 1 <= opcion <= len(archivos):
                return archivos[opcion - 1]
            print("Opción inválida, intente de nuevo.")
        except ValueError:
            print("Debe ingresar un número.")


# ---------------------------------------------------------
# Cargar datos desde archivo CSV
# ---------------------------------------------------------
def cargar_datos(archivo):
    with open(archivo, "r") as f:
        lector = csv.reader(f)
        encabezados = next(lector)
        datos = [fila for fila in lector if any(fila)]  # eliminar filas vacías
    return encabezados, datos


# ---------------------------------------------------------
# Entrenar Naive Bayes
# ---------------------------------------------------------
def entrenar_naive_bayes(encabezados, datos):
    clases = defaultdict(int)
    atributos = defaultdict(lambda: defaultdict(int))

    num_atributos = len(encabezados) - 1
    columna_clase = num_atributos

    for fila in datos:
        clase = fila[columna_clase]
        clases[clase] += 1

        for i in range(num_atributos):
            atributos[(encabezados[i], fila[i])][clase] += 1

    total = len(datos)
    return clases, atributos, total, num_atributos, encabezados


# ---------------------------------------------------------
# Predicción con manejo de empates
# ---------------------------------------------------------
def predecir(instancia, clases, atributos, total, num_atributos, encabezados):
    probabilidades = {}

    for clase in clases:
        prob = clases[clase] / total

        # Producto de P(xi|y)
        for i in range(num_atributos):
            key = (encabezados[i], instancia[i])
            count = atributos[key][clase]
            prob *= count / clases[clase] if clases[clase] > 0 else 0

        probabilidades[clase] = prob

    max_prob = max(probabilidades.values())
    mejores = [c for c, p in probabilidades.items() if p == max_prob]

    return mejores, probabilidades


# ---------------------------------------------------------
# Programa principal
# ---------------------------------------------------------
if __name__ == "__main__":
    print("\n=== Clasificador Bayesiano (basado en E. Bárcenas) ===\n")

    archivo = seleccionar_archivo_txt()
    print(f"\nArchivo seleccionado: {archivo}\n")

    encabezados, datos = cargar_datos(archivo)
    clases, atributos, total, n, enc = entrenar_naive_bayes(encabezados, datos)

    print("Atributos detectados:", enc[:-1])
    print("Clase objetivo:", enc[-1])

    instancia = []
    print("\nIngrese valores para predecir:")
    for i in range(n):
        valor = input(f"  {enc[i]}: ")
        instancia.append(valor)

    mejores, probs = predecir(instancia, clases, atributos, total, n, enc)

    print("\nProbabilidades:")
    for c, p in probs.items():
        fr = Fraction(p).limit_denominator()
        print(f"  - {c}: {p:.6f} (≈ {fr})")

    print("\nMejor probabilidad:")
    if len(mejores) > 1:
        print("Las clases con mayor probabilidad son: ")
        for c in mejores:
            print(f"     → {c} (prob. {probs[c]:.6f})")
    else:
        print(f"Clase: {mejores[0]} (prob. {probs[mejores[0]]:.6f})")

    print()
