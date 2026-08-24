#!/usr/bin/env bash
set -Eeuo pipefail
WEB_ROOT=/var/www/cft-coquimbo
NGINX_SITE=/etc/nginx/sites-available/cft-coquimbo

info(){ echo "[INFO] $*"; }
ok(){ echo "[ OK ] $*"; }
fail(){ echo "[FAIL] $*" >&2; exit 1; }
trap 'fail "Error en línea $LINENO"' ERR

[[ $EUID -eq 0 ]] || fail "Ejecuta: sudo ./install-cft-coquimbo.sh"
source /etc/os-release
[[ "${ID:-}" == ubuntu ]] || fail "Este instalador requiere Ubuntu Server."

echo "=================================================="
echo "       CFT COQUIMBO - INSTALADOR TODO EN UNO"
echo "=================================================="

info "Instalando dependencias..."
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx curl ufw
ok "Nginx, Curl y UFW instalados."

info "Creando sitio web..."
mkdir -p "$WEB_ROOT/css" "$WEB_ROOT/js" "$WEB_ROOT/img"

cat > "$WEB_ROOT/index.html" <<'HTML'
<!doctype html><html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="description" content="CFT Coquimbo - proyecto académico demostrativo"><title>CFT Coquimbo | Formación Técnica</title><link rel="stylesheet" href="css/style.css"></head><body>
<header><nav class="nav"><a class="brand" href="#inicio"><span class="logo">C</span><span>CFT <b>COQUIMBO</b></span></a><button id="menu">☰</button><div id="links"><a href="#inicio">Inicio</a><a href="#nosotros">Nosotros</a><a href="#carreras">Carreras</a><a href="#admision">Admisión</a><a href="#contacto">Contacto</a></div></nav></header>
<main>
<section class="hero" id="inicio"><div class="wrap hero-grid"><div><small>PROYECTO ACADÉMICO DEMOSTRATIVO</small><h1>Construye tu <span>futuro profesional.</span></h1><p>Formación técnica orientada al desarrollo de competencias prácticas, digitales y profesionales.</p><div class="actions"><a class="btn primary" href="#carreras">Ver carreras</a><a class="btn secondary" href="#contacto">Contáctanos</a></div></div><div class="hero-card"><div>🎓</div><h2>Educación técnica para el futuro</h2><p>Aprendizaje práctico conectado con las necesidades del mundo laboral.</p></div></div></section>
<section class="section" id="nosotros"><div class="wrap"><small>NOSOTROS</small><h2>Educación conectada con la región</h2><p class="muted">Sitio web demostrativo para fines académicos.</p><div class="stats"><div><b>100%</b><span>Enfoque práctico</span></div><div><b>3+</b><span>Áreas formativas</span></div><div><b>1</b><span>Objetivo: tu futuro</span></div></div></div></section>
<section class="section gray" id="carreras"><div class="wrap"><small>OFERTA ACADÉMICA</small><h2>Carreras</h2><div class="cards"><article><div>💻</div><h3>Informática</h3><p>Programación, redes, bases de datos, soporte y administración de sistemas.</p><span>Tecnología</span></article><article><div>📊</div><h3>Administración</h3><p>Gestión, procesos administrativos, finanzas y herramientas digitales.</p><span>Gestión</span></article><article><div>⚙️</div><h3>Electricidad y Automatización</h3><p>Fundamentos eléctricos, control, mantenimiento y automatización.</p><span>Industria</span></article></div></div></section>
<section class="section" id="admision"><div class="wrap admission"><div><small>ADMISIÓN</small><h2>Da el siguiente paso</h2><p class="muted">Conoce las alternativas de formación y comienza tu camino profesional.</p></div><a class="btn primary" href="#contacto">Solicitar información</a></div></section>
<section class="section gray"><div class="wrap"><small>VENTAJAS</small><h2>¿Por qué estudiar?</h2><div class="features"><div>✓ <span><b>Formación práctica</b><br>Aprendizaje orientado a situaciones reales.</span></div><div>✓ <span><b>Competencias digitales</b><br>Herramientas actuales para el mercado laboral.</span></div><div>✓ <span><b>Vinculación</b><br>Conexión entre estudiantes y organizaciones.</span></div><div>✓ <span><b>Desarrollo profesional</b><br>Competencias técnicas y habilidades transversales.</span></div></div></div></section>
<section class="section" id="contacto"><div class="wrap"><small>CONTACTO</small><h2>Solicita información</h2><form id="form"><label>Nombre<input required></label><label>Correo<input type="email" required></label><label>Carrera<select><option>Informática</option><option>Administración</option><option>Electricidad y Automatización</option></select></label><label>Mensaje<textarea rows="5" required></textarea></label><button class="btn primary">Enviar consulta</button><p id="msg"></p></form></div></section>
</main><footer><div class="wrap"><b>CFT COQUIMBO</b><p>Proyecto web demostrativo para fines académicos.</p><p>Coquimbo · Región de Coquimbo · Chile · © <span id="year"></span></p></div></footer><script src="js/app.js"></script></body></html>
HTML

cat > "$WEB_ROOT/css/style.css" <<'CSS'
:root{--p:#075985;--a:#f59e0b;--dark:#0f172a;--text:#172033;--muted:#64748b;--bg:#f7f9fc;--border:#e2e8f0}*{box-sizing:border-box}html{scroll-behavior:smooth}body{margin:0;font-family:system-ui,-apple-system,"Segoe UI",sans-serif;color:var(--text);background:var(--bg);line-height:1.6}a{text-decoration:none;color:inherit}.wrap{width:min(1120px,calc(100% - 40px));margin:auto}header{position:sticky;top:0;z-index:10;background:#fffffff2;border-bottom:1px solid var(--border)}.nav{min-height:74px;width:min(1120px,calc(100% - 40px));margin:auto;display:flex;align-items:center;justify-content:space-between}.brand{display:flex;align-items:center;gap:10px;font-weight:700}.brand b{color:var(--p)}.logo{width:40px;height:40px;display:grid;place-items:center;background:var(--p);color:#fff;border-radius:12px;font-weight:900}.nav a{margin-left:24px;color:#475569;font-weight:600}.nav a:hover{color:var(--p)}#menu{display:none;border:0;background:none;font-size:1.6rem}.hero{padding:110px 0;color:#fff;background:radial-gradient(circle at 80% 20%,#f59e0b40,transparent 30%),linear-gradient(135deg,#082f49,#075985)}.hero-grid{display:grid;grid-template-columns:1.5fr .8fr;gap:70px;align-items:center}.hero small,.section small{color:var(--a);font-weight:900;letter-spacing:.15em}.hero h1{font-size:clamp(2.6rem,6vw,5rem);line-height:1.02;letter-spacing:-.04em;margin:18px 0}.hero h1 span{color:#fde68a}.hero p{color:#dbeafe;font-size:1.1rem}.actions{display:flex;gap:14px;margin-top:30px;flex-wrap:wrap}.btn{display:inline-flex;align-items:center;justify-content:center;padding:12px 20px;border-radius:12px;font-weight:800;border:1px solid transparent;cursor:pointer}.primary{background:var(--a);color:#172033}.secondary{border-color:#ffffff66;color:#fff}.hero-card{background:#ffffff1a;border:1px solid #ffffff33;border-radius:24px;padding:35px}.hero-card div{font-size:3rem}.section{padding:90px 0}.gray{background:#eef5f9}h2{font-size:clamp(2rem,4vw,3rem);line-height:1.1;margin:10px 0 30px}.muted{color:var(--muted)}.stats{display:grid;grid-template-columns:repeat(3,1fr);gap:20px;margin-top:40px}.stats div,.cards article,form,.admission{background:#fff;border:1px solid var(--border);border-radius:18px;padding:28px}.stats b{display:block;font-size:2rem;color:var(--p)}.stats span{color:var(--muted)}.cards{display:grid;grid-template-columns:repeat(3,1fr);gap:22px}.cards article>div{font-size:2.2rem}.cards p{color:var(--muted)}.cards span{display:inline-block;background:#e0f2fe;color:var(--p);padding:5px 10px;border-radius:999px;font-size:.8rem;font-weight:800}.admission{display:flex;justify-content:space-between;align-items:center;gap:30px}.features{display:grid;grid-template-columns:repeat(2,1fr);gap:25px}.features>div{display:flex;gap:12px;color:#16a34a;font-size:1.5rem}.features span{color:var(--text);font-size:1rem}form{max-width:720px}label{display:block;font-weight:700;margin-bottom:18px}input,select,textarea{width:100%;margin-top:7px;padding:13px;border:1px solid #cbd5e1;border-radius:10px;font:inherit}textarea{resize:vertical}#msg{color:#15803d;font-weight:700}footer{background:var(--dark);color:#cbd5e1;padding:45px 0}footer b{color:#7dd3fc}@media(max-width:800px){#menu{display:block}.nav>div{display:none}.nav>div.open{display:flex;position:absolute;top:70px;left:20px;right:20px;padding:20px;background:#fff;border:1px solid var(--border);border-radius:14px;flex-direction:column}.nav a{margin:8px}.hero-grid,.cards,.stats,.features{grid-template-columns:1fr}.hero{padding:80px 0}.admission{flex-direction:column;align-items:flex-start}}
CSS

cat > "$WEB_ROOT/js/app.js" <<'JS'
const menu=document.getElementById('menu');const links=document.getElementById('links');const form=document.getElementById('form');const msg=document.getElementById('msg');const year=document.getElementById('year');menu?.addEventListener('click',()=>links.classList.toggle('open'));document.querySelectorAll('#links a').forEach(a=>a.addEventListener('click',()=>links.classList.remove('open')));form?.addEventListener('submit',e=>{e.preventDefault();msg.textContent='Consulta registrada correctamente en modo demostrativo.';form.reset()});year.textContent=new Date().getFullYear();
JS

chown -R www-data:www-data "$WEB_ROOT"
find "$WEB_ROOT" -type d -exec chmod 755 {} \;
find "$WEB_ROOT" -type f -exec chmod 644 {} \;
ok "Web creada en $WEB_ROOT."

info "Creando configuración Nginx..."
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
    location / { try_files \$uri \$uri/ /index.html; }
    location ~* \.(css|js|png|jpg|jpeg|gif|svg|webp|ico)\$ { expires 7d; add_header Cache-Control "public, max-age=604800"; try_files \$uri =404; }
    location ~ /\. { deny all; }
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
}
NGINX
ln -sfn "$NGINX_SITE" /etc/nginx/sites-enabled/cft-coquimbo
rm -f /etc/nginx/sites-enabled/default
nginx -t
ok "Nginx configurado."

info "Configurando firewall..."
ufw allow OpenSSH >/dev/null
ufw allow 'Nginx Full' >/dev/null
ufw --force enable >/dev/null
ok "UFW configurado."

info "Activando Nginx..."
systemctl enable nginx >/dev/null
systemctl restart nginx
systemctl is-active --quiet nginx
ok "Nginx activo."

STATUS=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1/ || true)
IP=$(hostname -I | awk '{print $1}')

echo
echo "=================================================="
echo "          INSTALACIÓN COMPLETADA"
echo "=================================================="
echo "IP del servidor : $IP"
echo "Sitio web       : http://$IP"
echo "HTTP local      : $STATUS"
echo "Directorio      : $WEB_ROOT"
echo "Nginx           : $(systemctl is-active nginx)"
echo "=================================================="
