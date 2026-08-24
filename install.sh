from pathlib import Path

path = Path("/mnt/data/install-cft-coquimbo.sh")

content = r'''#!/usr/bin/env bash
set -Eeuo pipefail

# ============================================================
# CFT COQUIMBO - INSTALADOR TODO EN UNO
# Ubuntu Server + Nginx + Web + UFW
#
# Uso:
#   chmod +x install-cft-coquimbo.sh
#   sudo ./install-cft-coquimbo.sh
#
# El script crea TODOS los archivos del sitio automáticamente.
# ============================================================

WEB_ROOT="/var/www/cft-coquimbo"
NGINX_SITE="/etc/nginx/sites-available/cft-coquimbo"
NGINX_LINK="/etc/nginx/sites-enabled/cft-coquimbo"

info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
ok()   { echo -e "\033[1;32m[ OK ]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
fail() { echo -e "\033[1;31m[FAIL]\033[0m $*"; exit 1; }

trap 'fail "Error en la línea $LINENO. Revisa el mensaje anterior."' ERR

[[ $EUID -eq 0 ]] || fail "Debes ejecutar el script con sudo: sudo ./install-cft-coquimbo.sh"

echo
echo "============================================================"
echo "       CFT COQUIMBO - INSTALADOR WEB TODO EN UNO"
echo "============================================================"
echo

# ------------------------------------------------------------
# 1. Verificar Ubuntu
# ------------------------------------------------------------
info "Verificando sistema operativo..."

if [[ -f /etc/os-release ]]; then
    source /etc/os-release
else
    fail "No se pudo determinar el sistema operativo."
fi

[[ "${ID:-}" == "ubuntu" ]] || fail "Este instalador está preparado para Ubuntu Server."

ok "Ubuntu ${VERSION_ID:-desconocido} detectado."

# ------------------------------------------------------------
# 2. Instalar dependencias
# ------------------------------------------------------------
info "Actualizando repositorios..."
apt-get update -y
ok "Repositorios actualizados."

info "Instalando Nginx, Git, Curl y UFW..."
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx git curl ufw
ok "Dependencias instaladas."

# ------------------------------------------------------------
# 3. Crear estructura
# ------------------------------------------------------------
info "Creando estructura del sitio..."

mkdir -p "$WEB_ROOT/css"
mkdir -p "$WEB_ROOT/js"
mkdir -p "$WEB_ROOT/img"

ok "Directorio creado: $WEB_ROOT"

# ------------------------------------------------------------
# 4. Crear index.html
# ------------------------------------------------------------
info "Creando página web..."

cat > "$WEB_ROOT/index.html" <<'HTML'
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="CFT Coquimbo - Proyecto académico demostrativo">
    <title>CFT Coquimbo | Formación Técnica</title>
    <link rel="stylesheet" href="css/style.css">
</head>

<body>

<header class="header">
    <nav class="nav container">

        <a href="#inicio" class="brand">
            <span class="brand-logo">C</span>
            <span>CFT <strong>COQUIMBO</strong></span>
        </a>

        <button class="menu-button" id="menuButton" aria-label="Abrir menú">
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
    <div class="container hero-grid">

        <div>
            <span class="eyebrow">PROYECTO ACADÉMICO</span>

            <h1>
                Construye tu
                <span>futuro profesional.</span>
            </h1>

            <p>
                Una propuesta de formación técnica orientada al desarrollo
                de competencias prácticas, digitales y profesionales.
            </p>

            <div class="buttons">
                <a href="#carreras" class="btn primary">Ver carreras</a>
                <a href="#contacto" class="btn secondary">Contáctanos</a>
            </div>
        </div>

        <div class="hero-card">
            <div class="hero-icon">🎓</div>
            <h2>Educación técnica para el futuro</h2>
            <p>
                Formación práctica y conectada con las necesidades
                del mundo laboral.
            </p>
        </div>

    </div>
</section>

<section class="section" id="nosotros">
    <div class="container">

        <div class="section-title">
            <span class="eyebrow">NOSOTROS</span>
            <h2>Educación conectada con la región</h2>
            <p>
                Este sitio corresponde a una implementación académica
                demostrativa de un Centro de Formación Técnica.
            </p>
        </div>

        <div class="stats">

            <div class="stat">
                <strong>100%</strong>
                <span>Enfoque práctico</span>
            </div>

            <div class="stat">
                <strong>3+</strong>
                <span>Áreas formativas</span>
            </div>

            <div class="stat">
                <strong>1</strong>
                <span>Objetivo: tu futuro</span>
            </div>

        </div>

    </div>
</section>

<section class="section gray" id="carreras">
    <div class="container">

        <div class="section-title">
            <span class="eyebrow">OFERTA ACADÉMICA</span>
            <h2>Carreras</h2>
            <p>
                Programas orientados al desarrollo de competencias
                profesionales.
            </p>
        </div>

        <div class="cards">

            <article class="card">
                <div class="card-icon">💻</div>
                <h3>Informática</h3>
                <p>
                    Programación, redes, bases de datos,
                    soporte y administración de sistemas.
                </p>
                <span class="tag">Tecnología</span>
            </article>

            <article class="card">
                <div class="card-icon">📊</div>
                <h3>Administración</h3>
                <p>
                    Gestión, procesos administrativos,
                    finanzas y herramientas digitales.
                </p>
                <span class="tag">Gestión</span>
            </article>

            <article class="card">
                <div class="card-icon">⚙️</div>
                <h3>Electricidad y Automatización</h3>
                <p>
                    Fundamentos eléctricos, control,
                    mantenimiento y automatización.
                </p>
                <span class="tag">Industria</span>
            </article>

        </div>
    </div>
</section>

<section class="section" id="admision">
    <div class="container admission">

        <div>
            <span class="eyebrow">ADMISIÓN</span>
            <h2>Da el siguiente paso</h2>
            <p>
                Conoce las alternativas de formación y comienza
                tu camino profesional.
            </p>
        </div>

        <a href="#contacto" class="btn primary">
            Solicitar información
        </a>

    </div>
</section>

<section class="section gray">
    <div class="container">

        <div class="section-title">
            <span class="eyebrow">VENTAJAS</span>
            <h2>¿Por qué estudiar?</h2>
        </div>

        <div class="features">

            <div>
                <span>✓</span>
                <div>
                    <h3>Formación práctica</h3>
                    <p>Aprendizaje orientado a situaciones reales.</p>
                </div>
            </div>

            <div>
                <span>✓</span>
                <div>
                    <h3>Competencias digitales</h3>
                    <p>Herramientas actuales para el mercado laboral.</p>
                </div>
            </div>

            <div>
                <span>✓</span>
                <div>
                    <h3>Vinculación</h3>
                    <p>Conexión entre estudiantes y organizaciones.</p>
                </div>
            </div>

            <div>
                <span>✓</span>
                <div>
                    <h3>Desarrollo profesional</h3>
                    <p>Competencias técnicas y habilidades transversales.</p>
                </div>
            </div>

        </div>

    </div>
</section>

<section class="section" id="contacto">
    <div class="container">

        <div class="section-title">
            <span class="eyebrow">CONTACTO</span>
            <h2>Solicita información</h2>
            <p>
                Formulario demostrativo para el proyecto académico.
            </p>
        </div>

        <form class="contact-form" id="contactForm">

            <label>
                Nombre
                <input type="text" required placeholder="Tu nombre">
            </label>

            <label>
                Correo electrónico
                <input type="email" required placeholder="correo@ejemplo.cl">
            </label>

            <label>
                Carrera
                <select>
                    <option>Informática</option>
                    <option>Administración</option>
                    <option>Electricidad y Automatización</option>
                </select>
            </label>

            <label>
                Mensaje
                <textarea rows="5" required placeholder="Escribe tu consulta"></textarea>
            </label>

            <button type="submit" class="btn primary">
                Enviar consulta
            </button>

            <p id="message" class="message"></p>

        </form>

    </div>
</section>

</main>

<footer class="footer">

    <div class="container footer-grid">

        <div>
            <div class="brand">
                <span class="brand-logo">C</span>
                <span>CFT <strong>COQUIMBO</strong></span>
            </div>

            <p>
                Proyecto web demostrativo para fines académicos.
            </p>
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
HTML

ok "index.html creado."

# ------------------------------------------------------------
# 5. Crear CSS
# ------------------------------------------------------------
info "Creando estilos CSS..."

cat > "$WEB_ROOT/css/style.css" <<'CSS'
:root {
    --primary: #075985;
    --primary-dark: #0c4a6e;
    --accent: #f59e0b;
    --dark: #0f172a;
    --text: #172033;
    --muted: #64748b;
    --background: #f7f9fc;
    --white: #ffffff;
    --border: #e2e8f0;
}

* {
    box-sizing: border-box;
}

html {
    scroll-behavior: smooth;
}

body {
    margin: 0;
    font-family:
        Inter,
        system-ui,
        -apple-system,
        BlinkMacSystemFont,
        "Segoe UI",
        sans-serif;
    color: var(--text);
    background: var(--background);
    line-height: 1.6;
}

a {
    text-decoration: none;
    color: inherit;
}

.container {
    width: min(1120px, calc(100% - 40px));
    margin: auto;
}

.header {
    position: sticky;
    top: 0;
    z-index: 100;
    background: rgba(255,255,255,.95);
    backdrop-filter: blur(10px);
    border-bottom: 1px solid var(--border);
}

.nav {
    min-height: 74px;
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.brand {
    display: flex;
    align-items: center;
    gap: 10px;
    font-weight: 700;
}

.brand strong {
    color: var(--primary);
}

.brand-logo {
    width: 40px;
    height: 40px;
    display: grid;
    place-items: center;
    background: var(--primary);
    color: white;
    border-radius: 12px;
    font-weight: 900;
}

.nav-links {
    display: flex;
    gap: 25px;
}

.nav-links a {
    color: #475569;
    font-weight: 600;
}

.nav-links a:hover {
    color: var(--primary);
}

.menu-button {
    display: none;
    background: transparent;
    border: 0;
    font-size: 1.7rem;
}

.hero {
    padding: 110px 0;
    color: white;
    background:
        radial-gradient(
            circle at 80% 20%,
            rgba(245,158,11,.25),
            transparent 30%
        ),
        linear-gradient(135deg, #082f49, #075985);
}

.hero-grid {
    display: grid;
    grid-template-columns: 1.5fr .8fr;
    gap: 70px;
    align-items: center;
}

.eyebrow {
    color: var(--accent);
    font-size: .78rem;
    font-weight: 900;
    letter-spacing: .15em;
}

.hero h1 {
    font-size: clamp(2.6rem, 6vw, 5rem);
    line-height: 1.02;
    letter-spacing: -.04em;
    margin: 18px 0;
}

.hero h1 span {
    color: #fde68a;
}

.hero p {
    color: #dbeafe;
    font-size: 1.1rem;
    max-width: 650px;
}

.buttons {
    display: flex;
    gap: 14px;
    margin-top: 30px;
    flex-wrap: wrap;
}

.btn {
    display: inline-flex;
    justify-content: center;
    align-items: center;
    padding: 12px 20px;
    border-radius: 12px;
    font-weight: 800;
    border: 1px solid transparent;
    cursor: pointer;
}

.primary {
    background: var(--accent);
    color: #172033;
}

.secondary {
    border-color: rgba(255,255,255,.4);
    color: white;
}

.hero-card {
    background: rgba(255,255,255,.1);
    border: 1px solid rgba(255,255,255,.2);
    border-radius: 24px;
    padding: 35px;
}

.hero-icon {
    font-size: 3rem;
}

.section {
    padding: 90px 0;
}

.gray {
    background: #eef5f9;
}

.section-title {
    max-width: 720px;
    margin-bottom: 40px;
}

.section-title h2 {
    font-size: clamp(2rem, 4vw, 3rem);
    line-height: 1.1;
    margin: 10px 0;
}

.section-title p {
    color: var(--muted);
}

.stats {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 20px;
}

.stat {
    background: white;
    border: 1px solid var(--border);
    border-radius: 18px;
    padding: 28px;
}

.stat strong {
    display: block;
    color: var(--primary);
    font-size: 2rem;
}

.stat span {
    color: var(--muted);
}

.cards {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 22px;
}

.card {
    background: white;
    border: 1px solid var(--border);
    border-radius: 18px;
    padding: 30px;
}

.card-icon {
    font-size: 2.2rem;
}

.card p {
    color: var(--muted);
}

.tag {
    display: inline-block;
    margin-top: 10px;
    padding: 5px 10px;
    border-radius: 999px;
    background: #e0f2fe;
    color: var(--primary-dark);
    font-size: .8rem;
    font-weight: 800;
}

.admission {
    background: white;
    border: 1px solid var(--border);
    border-radius: 24px;
    padding: 45px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 30px;
}

.admission h2 {
    font-size: 2.5rem;
    margin: 10px 0;
}

.admission p {
    color: var(--muted);
}

.features {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 25px;
}

.features > div {
    display: grid;
    grid-template-columns: 40px 1fr;
    gap: 12px;
}

.features > div > span {
    color: #16a34a;
    font-size: 1.6rem;
    font-weight: 900;
}

.features h3 {
    margin: 0;
}

.features p {
    color: var(--muted);
    margin-top: 5px;
}

.contact-form {
    max-width: 720px;
    background: white;
    padding: 32px;
    border: 1px solid var(--border);
    border-radius: 18px;
}

.contact-form label {
    display: block;
    margin-bottom: 18px;
    font-weight: 700;
}

input,
select,
textarea {
    width: 100%;
    margin-top: 7px;
    padding: 13px;
    border: 1px solid #cbd5e1;
    border-radius: 10px;
    font: inherit;
}

textarea {
    resize: vertical;
}

.message {
    color: #15803d;
    font-weight: 700;
}

.footer {
    background: var(--dark);
    color: #cbd5e1;
    padding: 45px 0;
}

.footer-grid {
    display: flex;
    justify-content: space-between;
    gap: 30px;
}

.footer .brand {
    color: white;
}

.footer .brand strong {
    color: #7dd3fc;
}

@media (max-width: 800px) {

    .menu-button {
        display: block;
    }

    .nav-links {
        display: none;
        position: absolute;
        top: 70px;
        left: 20px;
        right: 20px;
        padding: 20px;
        background: white;
        border: 1px solid var(--border);
        border-radius: 14px;
        flex-direction: column;
    }

    .nav-links.open {
        display: flex;
    }

    .hero-grid,
    .cards,
    .stats {
        grid-template-columns: 1fr;
    }

    .hero {
        padding: 80px 0;
    }

    .features {
        grid-template-columns: 1fr;
    }

    .admission,
    .footer-grid {
        flex-direction: column;
        align-items: flex-start;
    }
}
CSS

ok "style.css creado."

# ------------------------------------------------------------
# 6. Crear JavaScript
# ------------------------------------------------------------
info "Creando JavaScript..."

cat > "$WEB_ROOT/js/app.js" <<'JS'
const menuButton = document.getElementById("menuButton");
const navLinks = document.getElementById("navLinks");
const contactForm = document.getElementById("contactForm");
const message = document.getElementById("message");
const year = document.getElementById("year");

menuButton?.addEventListener("click", () => {
    navLinks.classList.toggle("open");
});

document.querySelectorAll("#navLinks a").forEach(link => {
    link.addEventListener("click", () => {
        navLinks.classList.remove("open");
    });
});

contactForm?.addEventListener("submit", event => {
    event.preventDefault();

    message.textContent =
        "Consulta registrada correctamente en modo demostrativo.";

    contactForm.reset();
});

if (year) {
    year.textContent = new Date().getFullYear();
}
JS

ok "app.js creado."

# ------------------------------------------------------------
# 7. Crear configuración Nginx
# ------------------------------------------------------------
info "Configurando Nginx..."

cat > "$NGINX_SITE" <<NGINX
server {
    listen 80;
    listen [::]:80;

    server_name _;

    root $WEB_ROOT;
    index index.html;

    access_log /var/log/nginx/cft-coquimbo_access.log;
    error_log /var/log/nginx/cft-coquimbo_error.log;

    server_tokens off;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location ~* \.(css|js|png|jpg|jpeg|gif|svg|webp|ico)$ {
        expires 7d;
        add_header Cache-Control "public, max-age=604800";
        try_files \$uri =404;
    }

    location ~ /\. {
        deny all;
    }

    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
}
NGINX

ln -sfn "$NGINX_SITE" "$NGINX_LINK"
rm -f /etc/nginx/sites-enabled/default

ok "Virtual Host configurado."

# ------------------------------------------------------------
# 8. Permisos
# ------------------------------------------------------------
info "Configurando permisos..."

chown -R www-data:www-data "$WEB_ROOT"

find "$WEB_ROOT" -type d -exec chmod 755 {} \;
find "$WEB_ROOT" -type f -exec chmod 644 {} \;

ok "Permisos configurados."

# ------------------------------------------------------------
# 9. Validar Nginx
# ------------------------------------------------------------
info "Validando configuración Nginx..."

nginx -t

ok "Configuración Nginx correcta."

# ------------------------------------------------------------
# 10. Firewall
# ------------------------------------------------------------
info "Configurando firewall UFW..."

ufw allow OpenSSH >/dev/null
ufw allow 'Nginx Full' >/dev/null

ufw --force enable >/dev/null

ok "Firewall configurado."

# ------------------------------------------------------------
# 11. Iniciar Nginx
# ------------------------------------------------------------
info "Habilitando Nginx..."

systemctl enable nginx
systemctl restart nginx

systemctl is-active --quiet nginx || fail "Nginx no está activo."

ok "Nginx funcionando."

# ------------------------------------------------------------
# 12. Prueba
# ------------------------------------------------------------
info "Realizando prueba HTTP..."

HTTP_STATUS="$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1/)"

if [[ "$HTTP_STATUS" == "200" ]]; then
    ok "Página web responde correctamente: HTTP $HTTP_STATUS"
else
    warn "La página respondió HTTP $HTTP_STATUS"
fi

# ------------------------------------------------------------
# 13. Información final
# ------------------------------------------------------------
IP_ADDR="$(hostname -I | awk '{print $1}')"

echo
echo "============================================================"
echo "              INSTALACIÓN COMPLETADA"
echo "============================================================"
echo
echo "Servidor web : Nginx"
echo "Directorio   : $WEB_ROOT"
echo "IP servidor  : $IP_ADDR"
echo
echo "ABRE DESDE TU PC:"
echo
echo "    http://$IP_ADDR"
echo
echo "Estado Nginx:"
systemctl is-active nginx
echo
echo "Firewall:"
ufw status | sed -n '1,8p'
echo
echo "Logs:"
echo "  /var/log/nginx/cft-coquimbo_access.log"
echo "  /var/log/nginx/cft-coquimbo_error.log"
echo
echo "============================================================"
echo "       CFT COQUIMBO WEB LISTO"
echo "============================================================"
'''
path.write_text(content, encoding="utf-8")
path.chmod(0o755)

print(path)
