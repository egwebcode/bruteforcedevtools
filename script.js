document.getElementById('login-form').addEventListener('submit', async function(e) {
  e.preventDefault();
  const password = document.getElementById('password').value;
  const message = document.getElementById('message');
  message.classList.remove('hidden');
  message.textContent = "Verificando...";
  
  const response = await fetch('/.netlify/functions/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ password })
  });

  const result = await response.json();

  if (result.success) {
    message.textContent = "Login bem-sucedido! Redirecionando...";
    message.style.color = "green";
    setTimeout(() => window.location.href = "/dashboard.html", 2000);
  } else {
    message.textContent = "Senha incorreta.";
    message.style.color = "red";
  }
});
