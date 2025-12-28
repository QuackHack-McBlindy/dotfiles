# ❄️🦆 QuackHack-McBLindy – dotfiles NixOS

![NixOS](https://img.shields.io/badge/NixOS-26.05-blue?style=flat-square&logo=NixOS&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-black?style=flat-square&logo=opensourceinitiative&logoColor=white)
![Nix](https://img.shields.io/badge/Nix-2.31.2+1-blue?style=flat-square&logo=nixos&logoColor=white)
![Linux Kernel](https://img.shields.io/badge/Linux-6.12.62-red?style=flat-square&logo=linux&logoColor=white)
![GNOME](https://img.shields.io/badge/GNOME-49.2-purple?style=flat-square&logo=gnome&logoColor=white)
![Bash](https://img.shields.io/badge/bash-5.3.3-red?style=flat-square&logo=gnubash&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12.12-yellow?style=flat-square&logo=python&logoColor=white)
![Rust](https://img.shields.io/badge/Rust-1.91.1-orange?style=flat-square&logo=rust&logoColor=white)
![Mosquitto](https://img.shields.io/badge/Mosquitto-2.0.22-yellow?style=flat-square&logo=eclipsemosquitto&logoColor=white)
![Zigbee2MQTT](https://img.shields.io/badge/Zigbee2MQTT-yellow?style=flat-square&logo=zigbee2mqtt&logoColor=white)

> ⚠️ **ATENÇÃO**  
> Não execute este flake às cegas.  
> **Este é o meu sistema pessoal.**

---

## 📦 O que é isso?

Este repositório contém **configurações NixOS totalmente reproduzíveis** para máquinas domésticas e automações residenciais, organizadas como um **flake Nix**.

Tudo é colado com um utilitário de linha de comando próprio, feito para:
- deploy,
- documentação automática,
- automação,
- e diversão (sim, com patos 🦆).

---

## ✨ O que torna esta configuração diferente?

- Estilo **declarativo extremo**, com módulos avaliados dinamicamente por host  
- **Sem Home Manager** – apenas symlinks automáticos de `./home` → `/home`  
- Automação residencial **nativa no Nix**, sem Home Assistant  
- Zigbee integrado diretamente na configuração do sistema  
- Assistente de voz com latência de **milissegundos**  
- Infraestrutura pensada como **acessibilidade cotidiana**

---

## 📊 Estatísticas (sim, é sério)

- 99 scripts em `/bin` (59 com comandos por voz)
- 2503 regex gerados dinamicamente
- 294.355.243 frases possíveis como comandos
- 41 dispositivos Zigbee, 3 TVs, 6 cenas
- Chatbot frontend **sem LLM**
- Deploy criptografado com Yubikey
- Firmware ESP32 versionado
- Documentação automática

---

## 🦆 Desafio do Pato

Existem **8074 patos escondidos** nos arquivos `.nix`.  
Boa sorte. Você vai precisar.

---

## ❄️ Estrutura do Flake

### Identidade do usuário
Defina em:
