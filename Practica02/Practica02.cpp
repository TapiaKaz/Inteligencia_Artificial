#include <iostream>
#include <fstream>
#include <string>
#include <cstdlib>
#include <array>
#include <vector>
#include <memory>
#include <stdexcept>
#include <filesystem>
#include <unistd.h>  // Para getpid()

namespace fs = std::filesystem;

/**
 * Clase para ejecutar consultas Prolog y generar árboles LaTeX
 */
class PrologSequentCalculus {
private:
    std::string prolog_file;
    std::string prolog_cmd;

    /**
     * Ejecuta un comando del sistema y captura su salida
     */
    std::string exec_command(const std::string& cmd) {
        std::array<char, 128> buffer;
        std::string result;

        // Usar un deleter personalizado para evitar el warning
        auto pipe_deleter = [](FILE* fp) { if (fp) pclose(fp); };
        std::unique_ptr<FILE, decltype(pipe_deleter)> pipe(popen(cmd.c_str(), "r"), pipe_deleter);

        if (!pipe) {
            throw std::runtime_error("Error ejecutando comando: " + cmd);
        }

        while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr) {
            result += buffer.data();
        }

        return result;
    }

    /**
     * Encuentra qué implementación de Prolog está disponible
     */
    std::string find_prolog() {
        std::vector<std::string> commands = {"swipl", "prolog", "gprolog"};

        for (const auto& cmd : commands) {
            try {
                exec_command(cmd + " --version 2>&1");
                return cmd;
            } catch (...) {
                continue;
            }
        }

        throw std::runtime_error("No se encontró Prolog instalado");
    }

    /**
     * Ejecuta una consulta Prolog usando archivo temporal
     */
    std::string run_prolog_query(const std::string& query) {
        // Crear archivo temporal con la consulta
        std::string temp_file = "/tmp/prolog_query_" + std::to_string(getpid()) + ".pl";
        std::ofstream out(temp_file);
        out << ":- ['" << prolog_file << "'].\n";
        out << ":- " << query << ", halt.\n";
        out << ":- halt(1).\n";  // Si falla, salir con código 1
        out.close();

        // DEBUG: Mostrar contenido del archivo temporal
        std::cout << "DEBUG - Archivo temporal: " << temp_file << std::endl;
        std::ifstream in(temp_file);
        std::string line;
        std::cout << "DEBUG - Contenido:" << std::endl;
        while (std::getline(in, line)) {
            std::cout << "  " << line << std::endl;
        }
        in.close();

        // Ejecutar Prolog con el archivo temporal
        std::string command = prolog_cmd + " -q -s " + temp_file + " 2>&1";
        std::cout << "DEBUG - Comando: " << command << std::endl;

        try {
            std::string result = exec_command(command);
            fs::remove(temp_file);  // Limpiar archivo temporal
            return result;
        } catch (const std::exception& e) {
            fs::remove(temp_file);
            std::cerr << "Error ejecutando Prolog: " << e.what() << std::endl;
            return "";
        }
    }

public:
    /**
     * Constructor
     */
    PrologSequentCalculus(const std::string& pl_file = "Practica02.pl")
        : prolog_file(pl_file) {
        prolog_cmd = find_prolog();
    }

    /**
     * Verifica si una fórmula es válida
     */
    bool check_validity(const std::string& formula) {
        // Modificar la consulta para que imprima el resultado
        std::string query = "(checkExpression(" + formula + ") -> write('VALID') ; write('INVALID'))";
        std::string result = run_prolog_query(query);

        // Debug: muestra la salida de Prolog
        std::cout << "DEBUG - Salida de Prolog: [" << result << "]" << std::endl;

        // Buscar "VALID" en la salida
        return result.find("VALID") != std::string::npos &&
               result.find("INVALID") == std::string::npos;
    }

    /**
     * Genera código LaTeX del árbol de prueba
     */
    std::string generate_latex(const std::string& formula,
                               const std::string& output_file = "proof_tree.tex") {
        std::string query = "checkExpressionLatex(" + formula + ")";
        std::string latex_code = run_prolog_query(query);

        if (!latex_code.empty() && latex_code.find("\\documentclass") != std::string::npos) {
            std::ofstream out(output_file);
            if (out.is_open()) {
                out << latex_code;
                out.close();
                return latex_code;
            }
        }

        return "";
    }

    /**
     * Genera PDF y lo abre automáticamente
     */
    bool generate_and_open_pdf(const std::string& formula,
                               const std::string& output_name = "proof_tree") {
        std::string tex_file = output_name + ".tex";
        std::string pdf_file = output_name + ".pdf";

        std::cout << "Generando árbol de prueba..." << std::endl;
        std::string latex_code = generate_latex(formula, tex_file);

        if (latex_code.empty()) {
            return false;
        }

        // Compilar con pdflatex (silencioso)
        std::cout << "Compilando PDF..." << std::endl;
        std::string compile_cmd = "pdflatex -interaction=nonstopmode " +
                                 tex_file + " > /dev/null 2>&1";

        int result = system(compile_cmd.c_str());

        if (result != 0 || !fs::exists(pdf_file)) {
            std::cout << "✗ Error al compilar LaTeX" << std::endl;
            return false;
        }

        std::cout << "✓ PDF generado: " << pdf_file << std::endl;

        // Limpiar archivos auxiliares
        try {
            fs::remove(output_name + ".aux");
            fs::remove(output_name + ".log");
            fs::remove(tex_file);
        } catch (...) {}

        // Abrir con evince
        std::cout << "Abriendo PDF..." << std::endl;
        std::string open_cmd = "evince " + pdf_file + " &";
        system(open_cmd.c_str());

        return true;
    }
};


/**
 * Función principal simplificada
 */
int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cout << "Uso: " << argv[0] << " <formula>\n\n";
        std::cout << "Ejemplos:\n";
        std::cout << "  " << argv[0] << " '(p imp q) imp (p imp q)'\n";
        std::cout << "  " << argv[0] << " '((p imp q) and (q imp r)) imp (p imp r)'\n";
        std::cout << "  " << argv[0] << " 'neg (p and q) dimp (neg p or neg q)'\n";
        std::cout << "\nSi la fórmula es válida, se generará y abrirá el PDF automáticamente.\n";
        return 1;
    }

    try {
        std::string formula = argv[1];

        PrologSequentCalculus calc;

        std::cout << "\nVerificando fórmula: " << formula << std::endl;

        bool is_valid = calc.check_validity(formula);

        if (is_valid) {
            std::cout << "✓ La fórmula es VÁLIDA" << std::endl;
            std::cout << "\n";
            calc.generate_and_open_pdf(formula, "proof_tree");
        } else {
            std::cout << "✗ La fórmula NO es válida" << std::endl;
            std::cout << "No se generará árbol de prueba." << std::endl;
        }

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}


/*
COMPILACIÓN:
g++ -std=c++17 Practica02.cpp -o test

USO:
./test "(p imp q) imp (p imp q)"
./test "((p imp q) and (q imp r)) imp (p imp r)"
./test "neg (p and q) dimp (neg p or neg q)"

Si la fórmula es válida (true), automáticamente:
1. Genera el árbol de prueba
2. Compila el PDF
3. Abre el PDF con evince
4. Limpia archivos temporales

Si la fórmula no es válida (false):
- Solo muestra el mensaje y termina
*/
