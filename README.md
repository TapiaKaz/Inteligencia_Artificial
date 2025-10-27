# 🤖 Inteligencia Artificial
Repositorio de prácticas y proyectos desarrollados para la materia de Inteligencia Artificial.

## 📋 Índice
- [Descripción](#descripción)
- [Prácticas](#prácticas)
- [Instalación de Dependencias](#instalación-de-dependencias)
- [Estructura del Proyecto](#estructura-del-proyecto)

---

## 📖 Descripción
Este repositorio contiene la implementación de diversos algoritmos y técnicas de Inteligencia Artificial, incluyendo búsqueda, razonamiento lógico y sistemas de inferencia.

---

## 🎯 Prácticas

### Práctica 01: Caballo Raro (DFS)
Implementación del algoritmo de búsqueda en profundidad (Depth-First Search) para resolver el problema del recorrido del caballo en un tablero.

**Dependencias:** [C++](#c-g)

**Ubicación:** `Practica01/Practica01.cpp`

**Uso:**
```bash
# Compilar
g++ -o caballo Practica01/Practica01.cpp

# Ejecutar
./caballo

# En Windows:
caballo.exe
```

---

### Práctica 02: Cálculo de Secuentes - Lógica Proposicional
Sistema de verificación de validez lógica mediante el cálculo de secuentes, con generación automática de árboles de prueba en LaTeX.

**Dependencias:** [C++](#c-g), [Prolog](#2-swi-prolog), [LaTeX](#3-latex-para-generación-de-pdfs)

**Ubicación:** `Practica02/Practica02.cpp`

**Características:**
- Verificación de fórmulas proposicionales
- Generación automática de árboles de prueba
- Exportación a LaTeX y PDF

**Uso:**
```bash
# Compilar
g++ -std=c++17 Practica02/Practica02.cpp -o secuente

# Usar
./secuente "(p imp q) imp (p imp q)"
./secuente "((p imp q) and (q imp r)) imp (p imp r)" --latex
./secuente "neg (p and q) dimp (neg p or neg q)" --pdf de_morgan
```

---

## 🔧 Instalación de Dependencias

### **C++ (g++)**

<details>
<summary><b>Linux (Fedora/RHEL)</b></summary>

```bash
sudo dnf install gcc-c++
```
</details>

<details>
<summary><b>Linux (Debian/Ubuntu)</b></summary>

```bash
sudo apt install g++
```
</details>

<details>
<summary><b>Windows</b></summary>

Descargar e Instalar [MSYS2](https://www.msys2.org/):
```bash
pacman -S mingw-w64-x86_64-gcc # Desde la terminal de MSYS2
```
</details>

---

##### **2. SWI-Prolog**

<details>
<summary><b>Linux (Fedora/RHEL)</b></summary>

```bash
sudo dnf install pl
swipl --version  # Verificar instalación
```
</details>

<details>
<summary><b>Linux (Debian/Ubuntu)</b></summary>

```bash
sudo apt install swi-prolog
```
</details>

<details>
<summary><b>Windows</b></summary>

Descargar el instalador desde [SWI-Prolog.org](https://www.swi-prolog.org/Download.html)
</details>

##### **3. LaTeX (para generación de PDFs)**

<details>
<summary><b>Linux (Fedora/RHEL) - Versión Ligera</b></summary>

```bash
sudo dnf install texlive-scheme-basic texlive-bussproofs
```
</details>

<details>
<summary><b>Linux (Fedora/RHEL) - Versión Completa</b></summary>

```bash
sudo dnf install texlive-scheme-full
```
</details>

<details>
<summary><b>Linux (Debian/Ubuntu) - Versión Ligera</b></summary>

```bash
sudo apt install texlive-latex-base texlive-latex-extra
```
</details>

<details>
<summary><b>Linux (Debian/Ubuntu) - Versión Completa</b></summary>

```bash
sudo apt install texlive-full
```
</details>

<details>
<summary><b>Windows</b></summary>

Descargar [MiKTeX](https://miktex.org/download) o [TeX Live](https://www.tug.org/texlive/)
</details>

<details>
<summary><b>macOS</b></summary>

```bash
brew install --cask mactex  # Completa
# O versión básica:
brew install --cask basictex
```
</details>

---

## 📝 Notas
- Todas las prácticas incluyen documentación detallada en sus respectivas carpetas
- Se recomienda usar la **versión ligera de LaTeX** si solo se necesita compilar documentos básicos
- El wrapper de Python es más fácil de usar y modificar que el de C++
- Para uso en producción o rendimiento crítico, se recomienda el wrapper de C++

---
