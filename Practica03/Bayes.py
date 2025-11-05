import os
import csv
import pprint
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
# Cargar datos Encabezado de archivo y datos
# ---------------------------------------------------------
def cargar_datos(archivo):
    with open(archivo, "r") as f:
        lector = csv.reader(f)  # comma separate value = valores separados por coma
        encabezados = next(lector)
        datos = [fila for fila in lector if any(fila)]  # eliminar filas vacías
    return encabezados, datos


# ---------------------------------------------------------
# Entrenar Naive Bayes
# ---------------------------------------------------------
def entrenar_naive_bayes(encabezados, datos):
    clases = defaultdict(int)
    # Diccionario tipo mapa
    # Dicionario["hola"]  = "saludar a alguien"

    atributos = defaultdict(lambda: defaultdict(int))
    # Diccionario de Diccionarios
    # atributos[(Genero, Terror)][1] = 1
    # atributos[(Genero, Terror)][3] = 2

    num_atributos = len(encabezados) - 1
    # El numero de atributos es la cantidad de columnas en la tabla
    # menos el de la clase

    columna_clase = num_atributos
    # Los indices empiezan desde cero, por lo tanto la columna clase es igual a num_atributos
    # a len(encabezados)-1 = num_atributos (reutilizamos variables)

    for fila in datos:
        clase = fila[columna_clase]
        # fila[columna_clase] = valor de calificacion de esa fila
        # Clase actual por cada fila
        clases[clase] += 1
        # Va contando la frecuencia de cada clase (Guardandolo en un tipo mapa)

        for i in range(num_atributos):
            atributos[(encabezados[i], fila[i])][clase] += 1

            # Debug para ver como se guardan las frecuencias de clase con atributos :
            # print(
            #     f"Key: [{encabezados[i]},{fila[i]}], Clase: [{clase}] = {atributos[(encabezados[i], fila[i])][clase]}"
            # )
            # [Usuario,M][1]= 1
            # [Genero,Drama][1]= 1
            # [Productora,Warner][2]= 3

    # Debug para ver como se guarda el contenido del diccionario:
    print("\n== Contenido del diccionario 'atributos' ==")
    pprint.pprint(dict(atributos))

    total = len(datos)  # total de datos
    return clases, atributos, total, num_atributos, encabezados
    # Clases: Frecuencia de cada calificacion
    # Atributos: Frecuencia de cada calificación por atributo
    # total: total de datos
    # num_atributos: número de atributos Unicos
    # encabezados: encabezados de los atributos


# ---------------------------------------------------------
# Predicción con manejo de empates
# ---------------------------------------------------------
def predecir(instancia, clases, atributos, total, num_atributos, encabezados):
    # clase : diccionario default de entrenar_naive_bayes
    # atributos: Diccionario de diccionarios de entrenar_naive_bayes
    #
    probabilidades = {}

    for clase in clases:
        prob = clases[clase] / total
        # Inicio de La probabilidad de la Clasificacion Bayesiana
        # P(clase)*...

        # Producto de P(xi|y)
        for i in range(num_atributos):
            key = (encabezados[i], instancia[i])
            # Con el valor de instancia, solo calcula la instancias que le pedimos desde el main
            # Key para acceder a los atributos coon el formato ejemplo de:
            # [Usuario,M][1]= 1, donde [Usuario,M] es la key
            # y acceder por cada clase, para calcular la probabilidad con el
            # Modelo de Clasificación Bayesiana

            count = atributos[key][clase]
            # Accedemos a la frecuencia de atributos por clase
            # Ejemplo: atributos[Usuario,M][1] = 2 # frecuencia que un usuario M, de calificacion de 2
            # count = 1 # Por lo tanto count vale 2

            # Debug para ver como se va realizando la clasificacion bayesiana:
            # print(
            #     f"probabilidad de clase {clase} = {Fraction(prob).limit_denominator()}*{Fraction(count).limit_denominator()}/{Fraction(clases[clase]).limit_denominator()} = {Fraction(prob * count / clases[clase] if clases[clase] > 0 else 0).limit_denominator()}"
            # )

            prob *= count / clases[clase] if clases[clase] > 0 else 0
            # Continua con la multiplicacion de probabilidades de la Clasifiación bayesiana
            # prob = P(clase) en estos momentos, después se van anidando las multiplicaciones por clase

        probabilidades[clase] = prob
        # Guarda las probabilidades por cada clase

    # Debug para ver como se guardan las probabilidades
    # print(f"Impresion de datos probabilidades: {probabilidades}")

    max_prob = max(probabilidades.values())
    mejores = [c for c, p in probabilidades.items() if p == max_prob]

    return mejores, probabilidades


# ---------------------------------------------------------
# Programa principal
# ---------------------------------------------------------
if __name__ == "__main__":
    print("\n==== Clasificador Bayesiano ====\n")

    archivo = seleccionar_archivo_txt()
    print(f"\nArchivo seleccionado: {archivo}\n")

    encabezados, datos = cargar_datos(archivo)

    clases, atributos, total, n, enc = entrenar_naive_bayes(encabezados, datos)
    # clases -> calificaciones | Total = total de filas, n = numero de atributos, enc encabezado
    print("\nAtributos detectados:", enc[:-1])
    print("Clase objetivo:", enc[-1])

    instancia = []  # Valores que vamos a pedir que calcule dependiendo de la cantidad de atributos de la tabla
    print("\nIngrese valores para predecir:")
    for i in range(n):
        valor = input(f"  {enc[i]}: ")
        instancia.append(valor)

    mejores, probs = predecir(instancia, clases, atributos, total, n, enc)

    print("\nProbabilidades:")
    for c, p in probs.items():
        # c = clase | calificacion
        # p = probabilidad
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
