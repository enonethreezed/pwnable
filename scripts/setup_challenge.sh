#!/usr/bin/env bash
set -euo pipefail

ensure_user() {
  local user="$1"
  local pass="$2"
  if ! id "$user" &>/dev/null; then
    useradd -m -s /bin/bash "$user"
  fi
  echo "$user:$pass" | chpasswd
}

ensure_user user1 user1
ensure_user user2 'A7kP3xQ8nZ1wR5L6'
ensure_user user3 'C9mN4tV2pH7sJ5dE'
ensure_user user4 'Q1w2E3r4T5y6U7i8'
chown user4:user4 /home/user4 || true
chmod 0700 /home/user4 || true
ensure_user user5 'R8nT2pL6sV4yQ1wZ'

extra_users=(
  "user6:S3u7Yp9Lw2Hq4V8X"
  "user7:T8r5Qw1La3Ns7V9K"
  "user8:U2y6Pf4Ka8Md1S3Z"
  "user9:V5t1Hg7Lc2Nb4Q8X"
  "user10:W7p3Xc5Zl9Ty2R4M"
  "user11:X1s4Dv6Fq8Gh0P2B"
  "user12:Y6a8Jk2Lm4Op7S9T"
)

for pair in "${extra_users[@]}"; do
  IFS=":" read -r user pass <<<"$pair"
  ensure_user "$user" "$pass"
  chown "$user:$user" "/home/$user" || true
  chmod 0750 "/home/$user" || true
  cat <<EOF > "/home/$user/secret.txt"
Esta es la nota privada de $user.
Contraseña real: $pass
EOF
  chown "$user:$user" "/home/$user/secret.txt"
  chmod 0600 "/home/$user/secret.txt"
done

if ! command -v gcc >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y build-essential
fi
ensure_user user6 'S3u7Yp9Lw2Hq4V8X'
chown user6:user6 /home/user6 || true
chmod 0750 /home/user6 || true

if ! getent group syncshare >/dev/null; then
  groupadd syncshare
fi
usermod -a -G syncshare user4
usermod -a -G syncshare user5
chown user5:syncshare /home/user5 || true
chmod 0750 /home/user5 || true

install -d -m 0750 -o user5 -g syncshare /opt/user5
install -d -m 0750 -o user5 -g syncshare /opt/user5/bin
install -d -m 0750 -o user5 -g user5 /opt/user5/systemd
install -d -m 0750 -o user5 -g user5 /opt/user5/logs

cat <<'USER5SCRIPT' > /opt/user5/bin/note_sync.sh
#!/usr/bin/env bash
set -euo pipefail

LOGDIR="/opt/user5/logs"
FLAG_FILE="/tmp/user5_service_ok"
mkdir -p "$LOGDIR"
printf "%s - sincronizando notas\n" "$(date '+%F %T')" >> "$LOGDIR/activity.log"
# Marca de salud del servicio; debe recrearse cada ejecución
: > "$FLAG_FILE"
chmod 0600 "$FLAG_FILE"
# TODO: user5 suele añadir comandos extra aquí cuando necesita depurar algo
USER5SCRIPT
chown user5:syncshare /opt/user5/bin/note_sync.sh
chmod 0770 /opt/user5/bin/note_sync.sh

cat <<'USER5SECRET' > /home/user5/secret.txt
Esta es la nota privada de user5.
Contraseña real: R8nT2pL6sV4yQ1wZ
USER5SECRET
chown user5:user5 /home/user5/secret.txt
chmod 0600 /home/user5/secret.txt

cat <<'USER5SERVICE' > /opt/user5/systemd/user5-note-sync.service
[Unit]
Description=Sync notas personales

[Service]
Type=oneshot
User=user5
Group=user5
ExecStart=/opt/user5/bin/note_sync.sh

[Install]
WantedBy=default.target
USER5SERVICE
chown user5:user5 /opt/user5/systemd/user5-note-sync.service
chmod 0644 /opt/user5/systemd/user5-note-sync.service

cat <<'USER5TIMER' > /opt/user5/systemd/user5-note-sync.timer
[Unit]
Description=Ejecución periódica de sync de notas

[Timer]
OnUnitActiveSec=2min
Unit=user5-note-sync.service

[Install]
WantedBy=timers.target
USER5TIMER
chown user5:user5 /opt/user5/systemd/user5-note-sync.timer
chmod 0644 /opt/user5/systemd/user5-note-sync.timer

install -m 0644 /opt/user5/systemd/user5-note-sync.service /etc/systemd/system/user5-note-sync.service
install -m 0644 /opt/user5/systemd/user5-note-sync.timer /etc/systemd/system/user5-note-sync.timer
systemctl daemon-reload
systemctl enable --now user5-note-sync.timer >/dev/null 2>&1 || true
systemctl start user5-note-sync.service >/dev/null 2>&1 || true

cat <<'USER4NOTE' > /home/user4/user5.txt
Notas rápidas:
- user5 dejó en marcha un servicio de systemd que apunta a `/opt/user5/bin/note_sync.sh`.
- Aunque los unit files viven en `/opt/user5/systemd/`, root los instala como `user5-note-sync.service/.timer` y se lanzan cada pocos minutos incluso tras reiniciar.
- Compartimos el grupo `syncshare`, así que puedo editar el script si necesito depurar algo (por ejemplo, añadir un `cat /home/user5/secret.txt > /tmp/user5_secret` temporal). El fichero `/tmp/user5_service_ok` confirma cada ejecución.
USER4NOTE
chown user4:user4 /home/user4/user5.txt
chmod 0644 /home/user4/user5.txt

cat <<'USER5HINT' > /home/user5/user6.txt
Notas rápidas:
- user6 me dejó una copia especial de `awk` para ejecutar comprobaciones como si fuera él.
- Está en `/usr/local/bin/u6awk`. Si necesitas leer algo suyo sin tocar nada más, prueba este truco:
  LFILE=file_to_read
  awk '//' "\$LFILE"
USER5HINT
chown user5:user5 /home/user5/user6.txt
chmod 0600 /home/user5/user6.txt

install -m 0755 /usr/bin/awk /usr/local/bin/u6awk
chown user6:user5 /usr/local/bin/u6awk
chmod 4750 /usr/local/bin/u6awk

cat <<'USER6HINT' > /home/user6/user7.txt
Notas rápidas:
- user7 me dejó acceso a `sudo /usr/local/bin/u7-find` para cuando él no esté.
- `find` tiene truquitos en GTFOBins: si lo lanzas con `-exec /bin/sh \; -quit` puedes hacer cosas interesantes.
- Hazlo desde un directorio accesible para ambos (por ejemplo `/tmp`) para evitar errores de permisos.
- No olvides leer su `secret.txt` sin modificarlo ni dejar pistas extra.
USER6HINT
chown user6:user6 /home/user6/user7.txt
chmod 0644 /home/user6/user7.txt

cat <<'USER7SUDO' > /etc/sudoers.d/user6-u7-find
user6 ALL=(user7) NOPASSWD: /usr/local/bin/u7-find *
USER7SUDO
chmod 0440 /etc/sudoers.d/user6-u7-find

cat <<'USER7FIND' > /usr/local/bin/u7-find
#!/usr/bin/env bash
exec /usr/bin/find "$@"
USER7FIND
chown user7:user6 /usr/local/bin/u7-find
chmod 4750 /usr/local/bin/u7-find

cat <<'USER7HINT' > /home/user7/user8.txt
Notas rápidas:
- user8 dejó `/usr/local/bin/u8-view` para revisar sus logs: solo ejecuta `less /var/log/user8/*.log`.
- Aunque parezca limitado, `less` tiene sorpresas interesantes; revisa GTFOBins por si necesitas refrescar la memoria.
- Los ficheros están en `/var/log/user8/`, así que asegúrate de usar esa ruta.
USER7HINT
chown user7:user7 /home/user7/user8.txt
chmod 0644 /home/user7/user8.txt

install -d -m 0750 -o user8 -g user7 /var/log/user8
cat <<'USER8LOG' > /var/log/user8/activity.log
[INFO] user8 dejó notas importantes aquí.
USER8LOG
chown user8:user7 /var/log/user8/activity.log

cat <<'U8SRC' > /usr/local/src/u8_view.c
#include <unistd.h>
#include <stdio.h>
#include <pwd.h>
#include <sys/types.h>

int main(void) {
    if (chdir("/var/log/user8") != 0) {
        perror("chdir");
        return 1;
    }
    execl("/usr/bin/less", "less", "activity.log", NULL);
    perror("less");
    return 1;
}
U8SRC
gcc /usr/local/src/u8_view.c -o /usr/local/bin/u8-view
chown user8:user7 /usr/local/bin/u8-view
chmod 4750 /usr/local/bin/u8-view

cat <<'USER8HINT' > /home/user8/user9.txt
Notas rápidas:
- user9 me dejó `sudo /usr/bin/python3 /opt/user9/maintenance.py` para que revise sus scripts.
- Compartimos el grupo `maintops`, así que puedo editar el script si hace falta.
- El código está en `/opt/user9/maintenance.py`.
USER8HINT
chown user8:user8 /home/user8/user9.txt
chmod 0644 /home/user8/user9.txt

if ! getent group maintops >/dev/null; then
  groupadd maintops
fi
usermod -a -G maintops user8
usermod -a -G maintops user9

install -d -m 0770 -o user9 -g maintops /opt/user9
cat <<'MAINT' > /opt/user9/maintenance.py
#!/usr/bin/env python3
print("user9 maintenance placeholder")
MAINT
chown user9:maintops /opt/user9/maintenance.py
chmod 0770 /opt/user9/maintenance.py

cat <<'USER8SUDO' > /etc/sudoers.d/user8-maint
user8 ALL=(user9) NOPASSWD: /usr/bin/python3 /opt/user9/maintenance.py
USER8SUDO
chmod 0440 /etc/sudoers.d/user8-maint

cat <<'USER9HINT' > /home/user9/user10.txt
Notas rápidas:
- user10 me deja ejecutar `sudo /usr/bin/tar -cf /tmp/backup.tar *` cuando necesita empaquetar cosas rápido.
- Revisa GTFOBins para ver cómo abusar de tar bajo sudo y así ejecutar comandos como user10.
- Recuerda limpiar /tmp después de tus pruebas.
USER9HINT
chown user9:user9 /home/user9/user10.txt
chmod 0644 /home/user9/user10.txt

cat <<'USER9SUDO' > /etc/sudoers.d/user9-tar
user9 ALL=(user10) NOPASSWD: /usr/bin/tar -cf /tmp/backup.tar *
USER9SUDO
chmod 0440 /etc/sudoers.d/user9-tar

cat <<'USER10HINT' > /home/user10/user11.txt
Notas rápidas:
- user11 me dejó `/usr/local/bin/u11-cat` para revisar ficheros cuando él no está.
- Es básicamente un cat con SUID; úsalo para leer lo que necesites de su home.
- Asegúrate de no dejar rastros en sus archivos personales.
USER10HINT
chown user10:user10 /home/user10/user11.txt
chmod 0644 /home/user10/user11.txt

cat <<'U11SRC' > /usr/local/src/u11_cat.c
#include <stdio.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Uso: u11-cat <fichero>\n");
        return 1;
    }
    execl("/bin/cat", "cat", argv[1], NULL);
    perror("cat");
    return 1;
}
U11SRC
gcc /usr/local/src/u11_cat.c -o /usr/local/bin/u11-cat
chown user11:user10 /usr/local/bin/u11-cat
chmod 4750 /usr/local/bin/u11-cat

install -d -m 0750 -o user12 -g user12 /var/log/app
cat <<'USER12LOG' > /var/log/app/user12.log
[INFO] user12 log placeholder
USER12LOG
chown user12:user12 /var/log/app/user12.log

cat <<'USER11HINT' > /home/user11/user12.txt
Notas rápidas:
- Necesito editar `/var/log/app/user12.log` a veces, así que tengo sudo para `vim` en ese fichero.
- Si alguna vez tengo que revisar algo más amplio de su home, sé creativo.
- Mira GTFOBins para recordar cómo escapar desde vim con sudo.
USER11HINT
chown user11:user11 /home/user11/user12.txt
chmod 0644 /home/user11/user12.txt

cat <<'USER11SUDO' > /etc/sudoers.d/user11-vim
user11 ALL=(user12) NOPASSWD: /usr/bin/vim /var/log/app/user12.log
USER11SUDO
chmod 0440 /etc/sudoers.d/user11-vim

# Cleanup legacy artifacts from the removed user12->user13 step.
rm -f /usr/local/bin/u14-edit /usr/local/src/u14_edit.c /home/user12/user13.txt
rm -rf /opt/user12

if [[ ! -x /usr/local/lib/nmap520/nmap ]]; then
  apt-get update -y
  apt-get install -y curl rpm2cpio cpio >/dev/null 2>&1
  tmpdir=$(mktemp -d)
  pushd "$tmpdir" >/dev/null
  curl -fsSL https://nmap.org/dist/nmap-5.20-1.x86_64.rpm -o nmap520.rpm
  rpm2cpio nmap520.rpm | cpio -idmv >/dev/null 2>&1
  install -d -m 0755 /usr/local/lib/nmap520
  install -m 0755 ./usr/bin/nmap /usr/local/lib/nmap520/nmap
  rm -rf /usr/local/lib/nmap520/share || true
  cp -a ./usr/share/nmap /usr/local/lib/nmap520/share
  popd >/dev/null
  rm -rf "$tmpdir"
fi

cat <<'NMAPWRAP' > /usr/local/src/nmap520_wrapper.c
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>

static void run_shell(void) {
    printf("Invocando shell privilegiada...\n");
    fflush(stdout);
    execl("/bin/bash", "bash", "-p", NULL);
    perror("bash");
    exit(1);
}

static void interactive_console(void) {
    char line[256];
    printf("\nStarting Nmap V. 5.20 ( http://nmap.org )\n");
    printf("Welcome to Interactive Mode -- press h <enter> for help\n");
    while (1) {
        printf("nmap> ");
        fflush(stdout);
        if (!fgets(line, sizeof(line), stdin)) {
            break;
        }
        line[strcspn(line, "\r\n")] = 0;
        if (strcmp(line, "!sh") == 0) {
            run_shell();
        } else if (strcmp(line, "exit") == 0 || strcmp(line, "quit") == 0) {
            printf("Quitting by request.\n");
            exit(0);
        } else if (strcmp(line, "h") == 0 || strcmp(line, "help") == 0) {
            printf("Comandos soportados en este modo: !sh, exit, quit\n");
        } else {
            printf("Unknown command (%s) -- press h <enter> for help\n", line);
        }
    }
    exit(0);
}

int main(int argc, char *argv[]) {
    setenv("NMAPDIR", "/usr/local/lib/nmap520/share/nmap", 1);
    if (argc > 1 && strcmp(argv[1], "--interactive") == 0) {
        interactive_console();
    }
    argv[0] = (char *)"nmap";
    execv("/usr/local/lib/nmap520/nmap", argv);
    perror("nmap");
    return 1;
}
NMAPWRAP
gcc /usr/local/src/nmap520_wrapper.c -o /usr/local/bin/nmap520
chown root:user12 /usr/local/bin/nmap520
chmod 4750 /usr/local/bin/nmap520

cat <<'USER12HINT' > /home/user12/root.txt
Notas rápidas:
- Solo tengo acceso a `nmap520`, una versión antigua con el modo `--interactive` vulnerable.
- Ejecuta `nmap520 --interactive` y usa `!sh` para invocar una shell como root.
- Este binario es SUID root y solo nosotros podemos usarlo; úsalo con cuidado.
USER12HINT
chown user12:user12 /home/user12/root.txt
chmod 0644 /home/user12/root.txt

cat <<'ROOTSECRET' > /root/secret.txt
Enhorabuena, has llegado a root. Buen trabajo.
ROOTSECRET
chown root:root /root/secret.txt
chmod 0600 /root/secret.txt

if ! command -v figlet >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y figlet
fi
figlet -f banner "Demencia Shell-nil" >/home/vagrant/motd.txt
cp /home/vagrant/motd.txt /etc/motd

challenge_users=(user1 user2 user3 user4 user5 user6 user7 user8 user9 user10 user11 user12 user0)
for usr in "${challenge_users[@]}"; do
  gpasswd -d "$usr" sudo 2>/dev/null || true
done

lockdown_sudoers() {
  local -a allowed=(00-ctf-sudo README user6-u7-find user8-maint user9-tar user11-vim)
  cat <<'SUDOGROUP' >/etc/sudoers.d/00-ctf-sudo
# Solo el grupo sudo tiene privilegios administrativos.
%sudo ALL=(ALL:ALL) ALL
SUDOGROUP
  chmod 0440 /etc/sudoers.d/00-ctf-sudo
  shopt -s nullglob
  for dropin in /etc/sudoers.d/*; do
    base=$(basename "$dropin")
    if printf '%s\0' "${allowed[@]}" | grep -Fxqz "$base"; then
      continue
    fi
    rm -f "$dropin"
  done
  shopt -u nullglob
}

lockdown_sudoers

if ! getent group backupops >/dev/null; then
  groupadd backupops
fi
usermod -a -G backupops user2
usermod -a -G backupops user3

secret="Nlk1RWoxTWE4RGszQ3g3Tg=="
cat <<EOF2 > /var/tmp/secret.txt
$secret
EOF2
chown root:user2 /var/tmp/secret.txt
chmod 0644 /var/tmp/secret.txt

cat <<'USER3NOTE' > /home/user3/secret.txt
Nota para el regreso:
- Contraseña temporal para user3: C9mN4tV2pH7sJ5dE
- Recuerda no dejarla tirada por ahí; solo debería estar en este fichero.
Por favor, bórrala una vez te acuerdes.
USER3NOTE
chown user3:user3 /home/user3/secret.txt
chmod 0600 /home/user3/secret.txt

install -d -m 0775 -o user3 -g backupops /opt/backup
install -d -m 0700 -o user3 -g user3 /home/user3/notes
cat <<'INCLUDE' > /opt/backup/include.list
/home/user3/notes
/home/user3/secret.txt
INCLUDE
chown user3:backupops /opt/backup/include.list
chmod 0664 /opt/backup/include.list

cat <<'BACKUP' > /opt/backup_user3.sh
#!/usr/bin/env bash
set -euo pipefail

INCLUDE_FILE="/opt/backup/include.list"
mkdir -p /home/user3/backups

if [[ ! -f "$INCLUDE_FILE" ]]; then
  echo "[!] Falta $INCLUDE_FILE" >&2
  exit 1
fi

DIRS=$(cat "$INCLUDE_FILE")
if [[ -z "$DIRS" ]]; then
  echo "[!] No hay rutas para copiar" >&2
  exit 0
fi

tar czf /home/user3/backups/backup.tar.gz $DIRS || true
BACKUP
chown user3:backupops /opt/backup_user3.sh
chmod 0770 /opt/backup_user3.sh

cat <<'CRON' > /etc/cron.d/backup_user3
*/5 * * * * user3 /opt/backup_user3.sh >/dev/null 2>&1
CRON
chown root:backupops /etc/cron.d/backup_user3
chmod 0640 /etc/cron.d/backup_user3

cat <<'USER2NOTE' > /home/user2/user3.txt
Notas rápidas:
- `/etc/cron.d/backup_user3` lanza `/opt/backup_user3.sh` cada 5 minutos.
- user3 dejó `/opt/backup_user3.sh` y `/opt/backup/include.list` accesibles para el grupo `backupops`, así que basta con editar el script o la lista para colar comandos (por ejemplo volcar `/home/user3/secret.txt` a un directorio en /tmp).
- Revisa `/opt/backup/include.list` para entender qué copia el script antes de meter mano.
USER2NOTE
chown user2:user2 /home/user2/user3.txt
chmod 0644 /home/user2/user3.txt

cat <<'U4SRC' > /usr/local/src/u4view.c
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <pwd.h>
#include <string.h>
#include <dirent.h>

static int ensure_owner(const char *path, uid_t uid) {
    struct stat st;
    if (stat(path, &st) != 0) {
        perror("stat");
        return 0;
    }
    if (st.st_uid != uid) {
        fprintf(stderr, "Solo se permiten rutas propiedad de user4\n");
        return 0;
    }
    return 1;
}

static int show_file(const char *path) {
    FILE *fp = fopen(path, "r");
    if (!fp) {
        perror("fopen");
        return 1;
    }
    char buf[256];
    while (fgets(buf, sizeof(buf), fp)) {
        fputs(buf, stdout);
    }
    fclose(fp);
    return 0;
}

static int list_dir(const char *path) {
    DIR *dir = opendir(path);
    if (!dir) {
        perror("opendir");
        return 1;
    }
    struct dirent *ent;
    while ((ent = readdir(dir)) != NULL) {
        printf("%s\n", ent->d_name);
    }
    closedir(dir);
    return 0;
}

int main(int argc, char *argv[]) {
    struct passwd *pwd = getpwnam("user4");
    if (!pwd) {
        fprintf(stderr, "[!] user4 no encontrado\n");
        return 1;
    }
    if (argc != 3) {
        fprintf(stderr, "Uso: u4view [-f fichero | -d directorio] <ruta>\n");
        return 1;
    }

    if (!ensure_owner(argv[2], pwd->pw_uid)) {
        return 1;
    }

    if (strcmp(argv[1], "-f") == 0) {
        return show_file(argv[2]);
    } else if (strcmp(argv[1], "-d") == 0) {
        return list_dir(argv[2]);
    }

    fprintf(stderr, "Opción no válida. Usa -f o -d\n");
    return 1;
}
U4SRC
if ! command -v gcc >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y gcc
fi
gcc /usr/local/src/u4view.c -o /usr/local/bin/u4view
chown user4:user3 /usr/local/bin/u4view
chmod 4770 /usr/local/bin/u4view
cat <<'U4SECRET' > /home/user4/secret.txt
Esta es la nota privada de user4.
Contraseña real: Q1w2E3r4T5y6U7i8
U4SECRET
chown user4:user4 /home/user4/secret.txt
chmod 0600 /home/user4/secret.txt


cat <<'U3HINT' > /home/user3/user4.txt
Nota:
- Tengo que aprender a programar en C como user4 y hacer herramientas para leer mis cosas en otros servidores.
- Me dijo que él tenía algo ya hecho en este servidor; a ver si lo encuentro y aprendo algo. Decía que su herramienta podía listar su home y luego leer los archivos.
U3HINT
chown user3:user3 /home/user3/user4.txt
chmod 0644 /home/user3/user4.txt

cat <<'ROT13' > /usr/local/bin/rot13.sh
#!/usr/bin/env bash
set -euo pipefail

show_help() {
cat <<'USAGE'
rot13.sh - Codifica o decodifica cadenas con ROT13.
Uso:
  rot13.sh -r "texto"   # Aplica ROT13 a la cadena facilitada
  rot13.sh -u "texto"   # Invierte ROT13 (equivalente a decodificar)
USAGE
}

if [[ $# -eq 0 ]]; then
  show_help
  exit 0
fi

opt="$1"
shift || true

case "$opt" in
  -r|-u) ;;
  -h|--help)
    show_help
    exit 0
    ;;
  *)
    echo "Opción no válida. Usa -r o -u." >&2
    exit 1
    ;;
esac

if [[ $# -lt 1 ]]; then
  echo "Debes proporcionar la cadena a transformar." >&2
  exit 1
fi

input="$*"
result=$(printf "%s" "$input" | tr 'A-Za-z' 'N-ZA-Mn-za-m')
printf "%s\n" "$result"
ROT13
chmod 0755 /usr/local/bin/rot13.sh

# Limpia el artefacto temporal que deja Vagrant tras ejecutar los provisioners
rm -rf /tmp/vagrant-shell || true

cat <<'EOF3' > /home/user1/user2.txt
Para hacer parte de las tareas de user2 me pasó la contraseña antes de irse de vacaciones, y está cifrada para evitar que la viesen otros.
El problema es que él dejó el fichero en algún lugar del sistema escondido con permisos de su usuario y/o grupo, y ahora ninguno recuerda la ruta exacta.
Al menos conservo las notas para descifrarla:
1. Revisa la página del manual de `rev` para invertir cadenas.
2. En `/usr/local/bin/rot13.sh` tienes un script para practicar ROT13 paso a paso.
3. Lee `man base64` para ver cómo codificar y decodificar.
EOF3
chown user1:user1 /home/user1/user2.txt
chmod 0644 /home/user1/user2.txt

if ! command -v ufw >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y ufw
fi
ufw --force reset
ufw default deny incoming
ufw default deny outgoing
ufw allow in on lo
ufw allow out on lo
ufw allow 22/tcp comment 'Allow SSH access'
ufw --force enable
