### Jobe-Swift

🏫🔧 Extensão do [Jobe](https://github.com/trampgeek/jobe) usada pelo plugin [CodeRunner](https://github.com/trampgeek/moodle-qtype_coderunner) no Moodle, adicionando suporte à linguagem **Swift 6.1.2**.

## ✨ O que é este projeto?
Este repositório fornece um container Docker personalizado do **Jobe**, configurado para compilar e executar código Swift em ambientes de quiz no Moodle (via CodeRunner).

Ele é baseado no `jobeinabox` oficial, com as seguintes extensões:
- Instalação do **Swift 6.1.2** (Ubuntu 24.04, amd64).
- Criação do handler `swift_task.php` para permitir a compilação/execução de Swift.
- Ajustes de permissões para a pasra `SwiftTask.php`.
- Arquivos prontos para uso com **Dockerfile** e **docker-compose.yml**.


## 🔹 Pontos Críticos:

⚠️ Pacotes no apt-get: sem clang, libicu-dev, libcurl4-openssl-dev → Swift não compila.
⚠️ URL do Swift: precisa bater com a distro (Ubuntu 24.04 = ubuntu2404).
⚠️ Symlinks: sem swiftc em /usr/local/bin, o Jobe não encontra o compilador.
⚠️ SwiftTask.php: deve estar no build context → se faltar, imagem sobe sem suporte a Swift.
⚠️ Healthcheck: garante que o container só fica “healthy” quando o Swift já aparece no Jobe.


## 📦 Como usar
1. Clone o repositório:
   ```bash
   git clone https://github.com/<seu-usuario>/Jobe-Swift.git
   cd Jobe-Swift
