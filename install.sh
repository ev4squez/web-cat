from pathlib import Path
import zipfile, textwrap, os

base = Path("/mnt/data/cft-coquimbo-web")
(base / "web/css").mkdir(parents=True, exist_ok=True)
(base / "web/js").mkdir(parents=True, exist_ok=True)
(base / "web/img").mkdir(parents=True, exist_ok=True)
(base / "nginx").mkdir(parents=True, exist_ok=True)

files = {
"install.sh": r'''#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_NAME="cft-coquimbo-web"
WEB_ROOT="/var/www/cft-coquimbo"
NGINX_SITE="/etc/nginx/sites-available/cft-coquimbo"
NGINX_LINK="/etc/nginx/sites-enabled/cft-coquimbo"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log()  { echo -e "\033[1;34m[INFO]\033[0m $*"; }
ok()   { echo -e "\033[1;32m[ OK ]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
fail() { echo -e "\033[1;31m[FAIL]\033[0m $*"; exit 1; }

trap 'fail "Error en la línea $LINENO. Revisa la salida anterior."' ERR

[[ $EUID -eq 0 ]] || fail "Ejecuta este script con sudo: sudo ./install.sh"

log "Verificando Ubuntu..."
source /etc/os-release
[[ "${ID:-}" == "ubuntu" ]] || fail "Este instalador está preparado para Ubuntu Server."
ok "Ubuntu ${VERSION_ID:-desconocido} detectado."

log "Actualizando repositorios..."
apt-get update -y
ok "Repositorios actualizados."

log "Instalando dependencias..."
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx git curl ufw
ok "Nginx, Git, Curl y UFW instalados."

log "Creando directorio web..."
mkdir -p "$WEB_ROOT"

log "Copiando sitio web..."
rm -rf "${WEB_ROOT:?}"/*
cp -a "$SCRIPT_DIR/web/." "$WEB_ROOT/"
chown -R www-data:www-data "$WEB_ROOT"
find "$WEB_ROOT" -type d -exec chmod 755 {} \;
find "$WEB_ROOT" -type f -exec chmod 644 {} \;
ok "Sitio instalado en $WEB_ROOT."

log "Instalando configuración Nginx..."
install -m 644 "$SCRIPT_DIR/nginx/cft-coquimbo.conf" "$NGINX_SITE"

rm -f /etc/nginx/sites-enabled/default
ln -sfn "$NGINX_SITE" "$NGINX_LINK"

log "Validando configuración Nginx..."
nginx -t
ok "Configuración Nginx válida."

log "Configurando firewall..."
ufw allow OpenSSH >/dev/null
ufw allow 'Nginx Full' >/dev/null
ufw --force enable >/dev/null
ok "UFW configurado para SSH y HTTP/HTTPS."

log "Habilitando e iniciando Nginx..."
systemctl enable nginx
systemctl restart nginx
systemctl is-active --quiet nginx || fail "Nginx no quedó activo."
ok "Nginx activo."

IP_ADDR="$(hostname -I | awk '{print $1}')"

echo
echo "=============================================="
echo "       CFT COQUIMBO - INSTALACIÓN OK"
echo "=============================================="
echo "Directorio web : $WEB_ROOT"
echo "Servidor       : $IP_ADDR"
echo "Sitio          : http://$IP_ADDR"
echo
echo "Estado Nginx:"
systemctl --no-pager --full status nginx | sed -n '1,8p'
echo
echo "Prueba local:"
curl -I --max-time 5 http://127.0.0.1/ | sed -n '1,5p'
echo "=============================================="
''',

"deploy.sh": r'''#!/usr/bin/env bash
set -Eeuo pipefail

WEB_ROOT="/var/www/cft-coquimbo"
NGINX_SITE="/etc/nginx/sites-available/cft-coquimbo"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
ok()  { echo -e "\033[1;32m[ OK ]\033[0m $*"; }
fail(){ echo -e "\033[1;31m[FAIL]\033[0m $*"; exit 1; }

[[ $EUID -eq 0 ]] || fail "Ejecuta: sudo ./deploy.sh"

if [[ -d "$SCRIPT_DIR/.git" ]]; then
    log "Actualizando repositorio Git..."
    git -C "$SCRIPT_DIR" pull --ff-only
    ok "Repositorio actualizado."
else
    log "No se detectó un repositorio Git local. Se usarán los archivos actuales."
fi

log "Desplegando archivos web..."
mkdir -p "$WEB_ROOT"
rm -rf "${WEB_ROOT:?}"/*
cp -a "$SCRIPT_DIR/web/." "$WEB_ROOT/"
chown -R www-data:www-data "$WEB_ROOT"
find "$WEB_ROOT" -type d -exec chmod 755 {} \;
find "$WEB_ROOT" -type f -exec chmod 644 {} \;
ok "Archivos desplegados."

log "Instalando configuración Nginx..."
install -m 644 "$SCRIPT_DIR/nginx/cft-coquimbo.conf" "$NGINX_SITE"
ln -sfn "$NGINX_SITE" /etc/nginx/sites-enabled/cft-coquimbo
rm -f /etc/nginx/sites-enabled/default

log "Validando Nginx..."
nginx -t

log "Recargando Nginx..."
systemctl reload nginx
systemctl is-active --quiet nginx || fail "Nginx no está activo."

ok "Despliegue finalizado correctamente."
echo "Sitio: http://$(hostname -I | awk '{print $1}')"
''',

"nginx/cft-coquimbo.conf": r'''server {
    listen 80;
    listen [::]:80;

    server_name _;

    root /var/www/cft-coquimbo;
    index index.html;

    access_log /var/log/nginx/cft-coquimbo_access.log;
    error_log  /var/log/nginx/cft-coquimbo_error.log;

    server_tokens off;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(css|js|png|jpg|jpeg|gif|svg|webp|ico)$ {
        expires 7d;
        add_header Cache-Control "public, max-age=604800";
        try_files $uri =404;
    }

    location ~ /\. {
        deny all;
    }

    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
}
''',

"web/index.html": r'''<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="Sitio demostrativo académico del CFT Coquimbo.">
  <title>CFT Coquimbo | Formación Técnica</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
  <header class="header">
    <nav class="nav container">
      <a class="brand" href="#inicio" aria-label="CFT Coquimbo">
        <span class="brand-mark">C</span>
        <span>CFT <strong>COQUIMBO</strong></span>
      </a>

      <button class="menu-toggle" id="menuToggle" aria-label="Abrir menú" aria-expanded="false">
        ☰
      </button>

      <div class="nav-links" id="navLinks">
        <a href="#inicio">Inicio</a>
        <a href="#nosotros">Nosotros</a>
        <a href="#carreras">Carreras</a>
        <a href="#admision">Admisión</a>
        <a href="#contacto">Contacto</a>
      </div>
    </nav>
  </header>

  <main>
    <section class="hero" id="inicio">
      <div class="container hero-content">
        <div>
          <span class="eyebrow">PROYECTO ACADÉMICO DEMOSTRATIVO</span>
          <h1>Forma tu futuro con <span>educación técnica.</span></h1>
          <p>
            Una propuesta web demostrativa para un Centro de Formación Técnica
            de la Región de Coquimbo, orientada a tecnología, empleabilidad y
            formación práctica.
          </p>
          <div class="hero-actions">
            <a class="btn btn-primary" href="#carreras">Ver carreras</a>
            <a class="btn btn-secondary" href="#contacto">Contáctanos</a>
          </div>
        </div>

        <div class="hero-card">
          <div class="hero-icon">🎓</div>
          <h3>Tu próximo desafío comienza aquí</h3>
          <p>Formación práctica, competencias digitales y conexión con el mundo laboral.</p>
        </div>
      </div>
    </section>

    <section class="section" id="nosotros">
      <div class="container">
        <div class="section-heading">
          <span class="eyebrow">NOSOTROS</span>
          <h2>Educación conectada con la región</h2>
          <p>
            Este sitio presenta una propuesta ficticia para fines educativos.
            El contenido puede adaptarse posteriormente a información oficial.
          </p>
        </div>

        <div class="stats">
          <div class="stat"><strong>100%</strong><span>Enfoque práctico</span></div>
          <div class="stat"><strong>3+</strong><span>Áreas formativas</span></div>
          <div class="stat"><strong>1</strong><span>Objetivo: tu futuro</span></div>
        </div>
      </div>
    </section>

    <section class="section section-alt" id="carreras">
      <div class="container">
        <div class="section-heading">
          <span class="eyebrow">OFERTA ACADÉMICA</span>
          <h2>Carreras para el mundo laboral</h2>
        </div>

        <div class="cards">
          <article class="card">
            <div class="card-icon">💻</div>
            <h3>Informática</h3>
            <p>Programación, redes, bases de datos, soporte y administración de sistemas.</p>
            <span class="tag">Tecnología</span>
          </article>

          <article class="card">
            <div class="card-icon">📊</div>
            <h3>Administración</h3>
            <p>Gestión, procesos administrativos, finanzas y herramientas digitales.</p>
            <span class="tag">Gestión</span>
          </article>

          <article class="card">
            <div class="card-icon">⚙️</div>
            <h3>Electricidad y Automatización</h3>
            <p>Fundamentos eléctricos, control, mantenimiento y automatización industrial.</p>
            <span class="tag">Industria</span>
          </article>
        </div>
      </div>
    </section>

    <section class="section" id="admision">
      <div class="container admission">
        <div>
          <span class="eyebrow">ADMISIÓN 2026</span>
          <h2>Da el siguiente paso</h2>
          <p>
            Conoce los requisitos de ingreso, alternativas de financiamiento
            y opciones de matrícula disponibles.
          </p>
        </div>
        <a class="btn btn-primary" href="#contacto">Solicitar información</a>
      </div>
    </section>

    <section class="section section-alt">
      <div class="container">
        <div class="section-heading">
          <span class="eyebrow">VENTAJAS</span>
          <h2>¿Por qué estudiar con nosotros?</h2>
        </div>

        <div class="features">
          <div><span>✓</span><h3>Formación práctica</h3><p>Aprendizaje orientado a situaciones reales.</p></div>
          <div><span>✓</span><h3>Competencias digitales</h3><p>Herramientas actuales para el mercado laboral.</p></div>
          <div><span>✓</span><h3>Vinculación</h3><p>Acercamiento entre estudiantes y organizaciones.</p></div>
          <div><span>✓</span><h3>Desarrollo profesional</h3><p>Competencias técnicas y habilidades transversales.</p></div>
        </div>
      </div>
    </section>

    <section class="section contact" id="contacto">
      <div class="container">
        <div class="section-heading">
          <span class="eyebrow">CONTACTO</span>
          <h2>¿Quieres saber más?</h2>
          <p>Completa el formulario demostrativo y te contactaremos.</p>
        </div>

        <form class="contact-form" id="contactForm">
          <label>
            Nombre
            <input type="text" name="name" required placeholder="Tu nombre">
          </label>

          <label>
            Correo electrónico
            <input type="email" name="email" required placeholder="nombre@correo.cl">
          </label>

          <label>
            Carrera de interés
            <select name="career">
              <option>Informática</option>
              <option>Administración</option>
              <option>Electricidad y Automatización</option>
            </select>
          </label>

          <label>
            Mensaje
            <textarea name="message" rows="5" required placeholder="Escribe tu consulta"></textarea>
          </label>

          <button class="btn btn-primary" type="submit">Enviar consulta</button>
          <p class="form-message" id="formMessage" role="status"></p>
        </form>
      </div>
    </section>
  </main>

  <footer class="footer">
    <div class="container footer-content">
      <div>
        <div class="brand brand-footer"><span class="brand-mark">C</span><span>CFT <strong>COQUIMBO</strong></span></div>
        <p>Proyecto web demostrativo para fines académicos.</p>
      </div>
      <div>
        <p>Coquimbo · Región de Coquimbo · Chile</p>
        <p>© <span id="year"></span> CFT Coquimbo Demo</p>
      </div>
    </div>
  </footer>

  <script src="js/app.js"></script>
</body>
</html>
''',

"web/css/style.css": r''':root {
  --bg: #f7f9fc;
  --surface: #ffffff;
  --text: #172033;
  --muted: #64748b;
  --primary: #075985;
  --primary-dark: #0c4a6e;
  --accent: #f59e0b;
  --border: #e2e8f0;
  --shadow: 0 20px 50px rgba(15, 23, 42, .10);
  --radius: 18px;
}

* { box-sizing: border-box; }
html { scroll-behavior: smooth; }
body {
  margin: 0;
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  color: var(--text);
  background: var(--bg);
  line-height: 1.6;
}
a { color: inherit; text-decoration: none; }
.container { width: min(1120px, calc(100% - 40px)); margin: auto; }

.header {
  position: sticky;
  top: 0;
  z-index: 20;
  background: rgba(255,255,255,.92);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid var(--border);
}
.nav {
  min-height: 74px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
}
.brand { display: flex; align-items: center; gap: 10px; font-weight: 700; letter-spacing: .02em; }
.brand strong { color: var(--primary); }
.brand-mark {
  width: 38px; height: 38px; display: grid; place-items: center;
  border-radius: 12px; background: var(--primary); color: white; font-weight: 900;
}
.nav-links { display: flex; gap: 24px; align-items: center; }
.nav-links a { color: #475569; font-weight: 600; font-size: .95rem; }
.nav-links a:hover { color: var(--primary); }
.menu-toggle { display: none; border: 0; background: transparent; font-size: 1.6rem; }

.hero {
  background:
    radial-gradient(circle at 80% 20%, rgba(245,158,11,.18), transparent 30%),
    linear-gradient(135deg, #082f49, #075985);
  color: white;
  padding: 110px 0;
}
.hero-content { display: grid; grid-template-columns: 1.5fr .8fr; gap: 70px; align-items: center; }
.eyebrow { font-size: .78rem; font-weight: 800; letter-spacing: .14em; color: var(--accent); }
.hero h1 { font-size: clamp(2.5rem, 6vw, 4.8rem); line-height: 1.02; margin: 18px 0; letter-spacing: -.04em; }
.hero h1 span { color: #fde68a; }
.hero p { color: #dbeafe; max-width: 650px; font-size: 1.1rem; }
.hero-actions { display: flex; gap: 14px; flex-wrap: wrap; margin-top: 30px; }
.btn {
  display: inline-flex; justify-content: center; align-items: center;
  border-radius: 12px; padding: 12px 20px; font-weight: 800;
  border: 1px solid transparent; cursor: pointer;
}
.btn-primary { background: var(--accent); color: #172033; }
.btn-primary:hover { filter: brightness(.95); }
.btn-secondary { border-color: rgba(255,255,255,.35); color: white; }
.hero-card {
  background: rgba(255,255,255,.1);
  border: 1px solid rgba(255,255,255,.2);
  padding: 32px; border-radius: 24px; box-shadow: var(--shadow);
}
.hero-icon { font-size: 3rem; }

.section { padding: 90px 0; }
.section-alt { background: #eef5f9; }
.section-heading { max-width: 720px; margin-bottom: 40px; }
.section-heading h2 { margin: 8px 0 12px; font-size: clamp(2rem, 4vw, 3rem); line-height: 1.1; }
.section-heading p { color: var(--muted); }

.stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
.stat { background: var(--surface); padding: 28px; border: 1px solid var(--border); border-radius: var(--radius); }
.stat strong { display: block; font-size: 2rem; color: var(--primary); }
.stat span { color: var(--muted); }

.cards { display: grid; grid-template-columns: repeat(3, 1fr); gap: 22px; }
.card {
  background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius);
  padding: 30px; box-shadow: 0 8px 30px rgba(15,23,42,.05);
}
.card-icon { font-size: 2rem; }
.card h3 { margin-bottom: 8px; }
.card p { color: var(--muted); }
.tag {
  display: inline-block; margin-top: 10px; padding: 5px 10px;
  background: #e0f2fe; color: var(--primary-dark); border-radius: 999px; font-size: .8rem; font-weight: 800;
}

.admission {
  background: var(--surface); border: 1px solid var(--border); border-radius: 24px;
  padding: 45px; display: flex; justify-content: space-between; align-items: center; gap: 30px;
  box-shadow: var(--shadow);
}
.admission h2 { margin: 8px 0; font-size: 2.5rem; }
.admission p { color: var(--muted); }

.features { display: grid; grid-template-columns: repeat(2, 1fr); gap: 24px; }
.features > div { display: grid; grid-template-columns: 36px 1fr; column-gap: 12px; }
.features span { grid-row: span 2; font-size: 1.5rem; color: #16a34a; font-weight: 900; }
.features h3 { margin: 0; }
.features p { margin-top: 4px; color: var(--muted); }

.contact-form {
  max-width: 720px; background: var(--surface); padding: 32px;
  border: 1px solid var(--border); border-radius: var(--radius); box-shadow: var(--shadow);
}
.contact-form label { display: block; margin-bottom: 18px; font-weight: 700; }
input, select, textarea {
  width: 100%; margin-top: 7px; padding: 13px 14px;
  border: 1px solid #cbd5e1; border-radius: 10px; font: inherit; background: white;
}
input:focus, select:focus, textarea:focus { outline: 3px solid rgba(7,89,133,.12); border-color: var(--primary); }
.form-message { min-height: 24px; color: #15803d; font-weight: 700; }

.footer { background: #0f172a; color: #cbd5e1; padding: 45px 0; }
.footer-content { display: flex; justify-content: space-between; gap: 30px; }
.brand-footer { color: white; }
.brand-footer strong { color: #7dd3fc; }

@media (max-width: 800px) {
  .menu-toggle { display: block; }
  .nav-links {
    display: none; position: absolute; left: 20px; right: 20px; top: 68px;
    background: white; padding: 18px; border: 1px solid var(--border);
    border-radius: 14px; box-shadow: var(--shadow); flex-direction: column; align-items: flex-start;
  }
  .nav-links.open { display: flex; }
  .hero-content, .cards, .stats { grid-template-columns: 1fr; }
  .hero { padding: 80px 0; }
  .features { grid-template-columns: 1fr; }
  .admission, .footer-content { flex-direction: column; align-items: flex-start; }
}
''',

"web/js/app.js": r'''const menuToggle = document.getElementById("menuToggle");
const navLinks = document.getElementById("navLinks");
const form = document.getElementById("contactForm");
const formMessage = document.getElementById("formMessage");
const year = document.getElementById("year");

menuToggle?.addEventListener("click", () => {
  const open = navLinks.classList.toggle("open");
  menuToggle.setAttribute("aria-expanded", String(open));
});

document.querySelectorAll("#navLinks a").forEach(link => {
  link.addEventListener("click", () => navLinks.classList.remove("open"));
});

form?.addEventListener("submit", (event) => {
  event.preventDefault();
  formMessage.textContent =
    "Consulta registrada en modo demostrativo. En una implementación real, aquí se conectaría un backend.";
  form.reset();
});

if (year) year.textContent = new Date().getFullYear();
''',

"README.md": r'''# CFT Coquimbo Web

Proyecto académico demostrativo para desplegar una página web estática en Ubuntu Server utilizando Nginx y automatización mediante Bash + Git.

> **Importante:** este proyecto es una demostración educativa. El contenido no representa necesariamente a una institución oficial.

## 1. Requisitos

- Ubuntu Server 22.04 LTS o 24.04 LTS recomendado
- Acceso sudo
- Conectividad a Internet
- Git instalado si se clona el repositorio manualmente

## 2. Instalación desde Git

```bash
git clone https://github.com/TU-USUARIO/cft-coquimbo-web.git
cd cft-coquimbo-web
chmod +x install.sh deploy.sh
sudo ./install.sh
