#!/bin/bash
# havoc-obfuscator.sh
# Script for obfuscation and rebranding of Havoc C2 to MiniMice

set -e

ROOT_DIR="$(pwd)"

echo "[+] Checking and installing system dependencies..."

# Function to check and install a package via apt if it doesn't exist
check_install() {
    PKG="$1"
    dpkg -s "$PKG" &> /dev/null || {
        echo "[+] Installing $PKG..."
        sudo apt-get update
        sudo apt-get install -y "$PKG"
    }
}

check_install libspdlog-dev
check_install libfmt-dev
check_install nlohmann-json3-dev
check_install git

# Install toml11 if needed
if [ ! -f "client/include/toml.hpp" ] || [ ! -d "client/include/toml11" ]; then
    echo "[+] Downloading toml11 (ToruNiina/toml11)..."
    rm -rf /tmp/toml11
    git clone https://github.com/ToruNiina/toml11.git /tmp/toml11
    cp /tmp/toml11/include/toml.hpp client/include/
    cp -r /tmp/toml11/include/toml11 client/include/
    echo "[✓] toml11 installed in client/include/"
else
    echo "[✓] toml11 already present in client/include/"
fi

echo "[✓] Dependencies installed."

echo "[+] Starting automatic copy of Havoc headers and sources to MiniMice..."

# Base directories
BASE="$PWD"
SRC_INC="$BASE/client/include/Havoc"
DST_INC="$BASE/client/include/MiniMice"
SRC_UI="$BASE/client/include/UserInterface"
DST_UI="$BASE/client/include/UserInterface"
SRC_SRC="$BASE/client/src/Havoc"
DST_SRC="$BASE/client/src/MiniMice"
SRC_UI_SRC="$BASE/client/src/UserInterface"
DST_UI_SRC="$BASE/client/src/UserInterface"

# Function to recursively copy and maintain structure
copy_recursive() {
    local src_dir="$1"
    local dst_dir="$2"
    find "$src_dir" -type f | while read -r file; do
        relative="${file#$src_dir/}"
        dst_file="$dst_dir/$relative"
        mkdir -p "$(dirname "$dst_file")"
        if [ ! -e "$dst_file" ]; then
            cp "$file" "$dst_file"
            echo "[+] Copied: $file -> $dst_file"
        fi
    done
}

# 1. Copy includes Havoc -> MiniMice
copy_recursive "$SRC_INC" "$DST_INC"

# 2. Copy UserInterface (includes)
copy_recursive "$SRC_UI" "$DST_UI"

# 3. Copy sources Havoc -> MiniMice (src)
copy_recursive "$SRC_SRC" "$DST_SRC"

# 4. Copy UserInterface sources
copy_recursive "$SRC_UI_SRC" "$DST_UI_SRC"

# 5. Special files: MiniMice.hpp, MiniMiceUi.h, MiniMiceUi.cc, MiniMice.cc
if [ -f "$SRC_INC/Havoc.hpp" ]; then
    cp "$SRC_INC/Havoc.hpp" "$DST_INC/MiniMice.hpp"
    echo "[+] Created: $DST_INC/MiniMice.hpp from $SRC_INC/Havoc.hpp"
fi
if [ -f "$SRC_INC/PythonApi/HavocUi.h" ]; then
    mkdir -p "$DST_INC/PythonApi"
    cp "$SRC_INC/PythonApi/HavocUi.h" "$DST_INC/PythonApi/MiniMiceUi.h"
    echo "[+] Created: $DST_INC/PythonApi/MiniMiceUi.h from $SRC_INC/PythonApi/HavocUi.h"
fi
if [ -f "$SRC_SRC/PythonApi/HavocUi.cc" ]; then
    mkdir -p "$DST_SRC/PythonApi"
    cp "$SRC_SRC/PythonApi/HavocUi.cc" "$DST_SRC/PythonApi/MiniMiceUi.cc"
    echo "[+] Created: $DST_SRC/PythonApi/MiniMiceUi.cc from $SRC_SRC/PythonApi/HavocUi.cc"
fi
if [ -f "$SRC_SRC/../Havoc.cc" ]; then
    cp "$SRC_SRC/../Havoc.cc" "$DST_SRC/../MiniMice.cc"
    echo "[+] Created: $DST_SRC/../MiniMice.cc from $SRC_SRC/../Havoc.cc"
fi
if [ -f "$BASE/client/include/UserInterface/HavocUI.hpp" ]; then
    cp "$BASE/client/include/UserInterface/HavocUI.hpp" "$BASE/client/include/UserInterface/MiniMiceUI.hpp"
    echo "[+] Created: $BASE/client/include/UserInterface/MiniMiceUI.hpp from $BASE/client/include/UserInterface/HavocUI.hpp"
fi
if [ -f "$BASE/client/src/Havoc/PythonApi/Havoc.cc" ]; then
    mkdir -p "$BASE/client/src/MiniMice/PythonApi"
    cp "$BASE/client/src/Havoc/PythonApi/Havoc.cc" "$BASE/client/src/MiniMice/PythonApi/MiniMice.cc"
    echo "[+] Created: $BASE/client/src/MiniMice/PythonApi/MiniMice.cc from $BASE/client/src/Havoc/PythonApi/Havoc.cc"
fi
if [ -f "$BASE/client/src/Havoc/Havoc.cc" ]; then
    mkdir -p "$BASE/client/src/MiniMice"
    cp "$BASE/client/src/Havoc/Havoc.cc" "$BASE/client/src/MiniMice/MiniMice.cc"
    echo "[+] Created: $BASE/client/src/MiniMice/MiniMice.cc from $BASE/client/src/Havoc/Havoc.cc"
fi
if [ -f "$BASE/client/src/UserInterface/HavocUi.cc" ]; then
    cp "$BASE/client/src/UserInterface/HavocUi.cc" "$BASE/client/src/UserInterface/MiniMiceUi.cc"
    echo "[+] Created: $BASE/client/src/UserInterface/MiniMiceUi.cc from $BASE/client/src/UserInterface/HavocUi.cc"
fi

# Fix MiniMice.hpp: using toml::value instead of basic_value
MMICE_HEADER="$BASE/client/include/MiniMice/MiniMice.hpp"
if [ -f "$MMICE_HEADER" ]; then
    sed -i 's|using toml_t = toml::basic_value<toml::discard_comments, unordered_map, vector>;|using toml_t = toml::value;|' "$MMICE_HEADER"
    echo "[+] Fixed: toml_t line in $MMICE_HEADER"
fi

# Fix MiniMice.hpp: using toml::value instead of basic_value
MMICE_HEADER="$BASE/client/include/MiniMice/MiniMice.hpp"
if [ -f "$MMICE_HEADER" ]; then
    sed -i 's|using toml_t = toml::basic_value<toml::discard_comments, unordered_map, vector>;|using toml_t = toml::value;|' "$MMICE_HEADER"
    echo "[+] Fixed: toml_t line in $MMICE_HEADER"
fi

# Add find_package at the beginning of CMakeLists.txt
CMAKE="$BASE/client/CMakeLists.txt"
if [ -f "$CMAKE" ]; then
    # Add after the last include_directories
    TMP=$(mktemp)
    awk '
        { print }
        /include_directories/ { last_inc=NR }
        END {
            for (i=last_inc+1; i<=NR; i++) print lines[i]
        }
    ' "$CMAKE" > "$TMP"

    awk '
        BEGIN {added=0}
        /include_directories/ && !added { print; nextline=1; next }
        nextline && !added {
            print "find_package(spdlog REQUIRED)\nfind_package(fmt REQUIRED)"
            nextline=0; added=1
        }
        { print }
    ' "$CMAKE" > "$TMP"
    mv "$TMP" "$CMAKE"
    echo "[+] find_package(spdlog/fmt) added to CMakeLists.txt"
fi

# Update target_link_libraries to use spdlog/fmt
if [ -f "$CMAKE" ]; then
    # Remove old block (maintains original indentation)
    sed -i '/target_link_libraries(/,/)/c\target_link_libraries(\n    ${PROJECT_NAME}\n    ${REQUIRED_LIBS_QUALIFIED}\n    ${PYTHON_LIBRARIES}\n    spdlog::spdlog\n    fmt::fmt\n)' "$CMAKE"
    echo "[+] target_link_libraries() updated for spdlog/fmt in CMakeLists.txt"
fi

# 6. Mass replacements (IGNORING data and stylesheets folders and .qrc/.rc files)
echo "[+] Replacing 'Havoc' with 'MiniMice' in headers, sources and CMakeLists.txt (ignoring data, stylesheets, .qrc and .rc)..."
find "$BASE/client" \
    \( -name '*.h' -o -name '*.hpp' -o -name '*.cc' -o -name '*.cpp' -o -name 'CMakeLists.txt' \) \
    ! -path "$BASE/client/data/*" \
    ! -path "$BASE/client/stylesheets/*" \
    ! -name '*.qrc' \
    ! -name '*.rc' \
    -exec sed -i 's/Havoc/MiniMice/g' {} +

# 7. Restore qrc and rc references in CMakeLists.txt to ensure it always uses the correct file
for cmakefile in "$BASE/client/CMakeLists.txt" "$BASE/client/data/CMakeLists.txt" "$BASE/client/src/CMakeLists.txt"; do
    if [ -f "$cmakefile" ]; then
        sed -i 's/data\/MiniMice.qrc/data\/Havoc.qrc/g' "$cmakefile"
        sed -i 's/data\/MiniMice.rc/data\/Havoc.rc/g' "$cmakefile"
    fi
done

echo "[✓] Automatic obfuscation completed."

# 8. Patch Teamserver for custom 404 response (IIS 8.5)

TEAMSERVER_GO="$BASE/teamserver/cmd/server/teamserver.go"
TEAMSERVER_404="$BASE/teamserver/pkg/handlers/404.html"
IIS_404_HTML="404_iis.html"

if [ -f "$TEAMSERVER_GO" ]; then
    # Replace Redirect with call to fake404 handler
    sed -i 's/context\.Redirect(http\.StatusMovedPermanently, "home\/")/handlers.Fake404(context)/' "$TEAMSERVER_GO"
    echo "[+] Modified: $TEAMSERVER_GO to show custom 404 page."
fi

# Target file
FILE="teamserver/pkg/handlers/http.go"

if [ ! -f "$FILE" ]; then
    echo "Error: File $FILE not found!"
    exit 1
fi

perl -0777 -i -pe '
s|// fake nginx 404 page.*?^\}|func (h *HTTP) Fake404(ctx *gin.Context) {
    ctx.Header("Server", "Microsoft-IIS/8.5")
    html, err := os.ReadFile("teamserver/pkg/handlers/404.html")
    if err != nil {
        ctx.String(404, "")
        return
    }
    ctx.Data(404, "text/html; charset=utf-8", html)
}|ms
' "$FILE"

echo "[+] Changing X-Havoc: true header to mimic IIS 8.5"

if [ -f "$IIS_404_HTML" ]; then
    cp "$IIS_404_HTML" "$TEAMSERVER_404"
    echo "[+] Copied: IIS 8.5 HTML to $TEAMSERVER_404"
fi

# 1. Remove net/http import from teamserver.go
sed -i '/import .*net\/http/d' teamserver/cmd/server/teamserver.go

# If import is in block import (import ( ... )), remove only net/http line
# Or use this command for exact lines:
sed -i '/"net\/http"/d' teamserver/cmd/server/teamserver.go

echo "[+] net/http import removed from teamserver.go"

# Rename fake* functions to Fake*
sed -i -E 's/func (fake[a-zA-Z0-9_]+)\(/func \u\1(/g' teamserver/pkg/handlers/http.go

# Rename method calls h.fake* to h.Fake*
grep -rl 'h.fake' . | xargs sed -i -E 's/h\.fake([a-zA-Z0-9_]+)/h.Fake\1/g'

echo "[+] fake* functions renamed to Fake* in http.go and calls adjusted"

awk '
BEGIN { inserted=0 }
/^[[:space:]]*func[[:space:]]+\(t[[:space:]]*\*[[:space:]]*Teamserver\)[[:space:]]+Start[[:space:]]*\(\)[[:space:]]*{/ && inserted==0 {
    print
    match($0, /^[[:space:]]*/)
    indent = substr($0, RSTART, RLENGTH)
    print indent "    var h handlers.HTTP"
    inserted=1
    next
}
{
    if ($0 ~ /t\.Server\.Engine\.GET\("\/", func\(context \*gin\.Context\)/) {
        getline
        getline
        print "    t.Server.Engine.GET(\"/\", h.Fake404)"
    } else {
        print
    }
}
' teamserver/cmd/server/teamserver.go > teamserver/cmd/server/teamserver.go.tmp

mv teamserver/cmd/server/teamserver.go.tmp teamserver/cmd/server/teamserver.go

echo "[✓] Fix teamserver"

# Go to teamserver folder inside current folder where script is being executed
cd "$(dirname "$0")/teamserver" || { echo "Error: teamserver folder not found"; exit 1; }

# Function to check if a package is installed
is_installed() {
    dpkg -s "$1" &> /dev/null
}

# List of packages you want to ensure are installed
packages=(golang-go nasm mingw-w64 wget)

# Packages that still need to be installed
to_install=()

for pkg in "${packages[@]}"; do
    if ! is_installed "$pkg"; then
        to_install+=("$pkg")
    fi
done

# If there are packages to install, install them
if [ ${#to_install[@]} -ne 0 ]; then
    echo "Installing packages: ${to_install[*]}"
    sudo apt update
    sudo apt install -y "${to_install[@]}"
else
    echo "[✓] All packages are already installed."
fi

# Create data directory if it doesn't exist
if [ ! -d "../data" ]; then
    mkdir ../data
fi

# Download and extract mingw-musl-64.tgz
if [ -f /tmp/mingw-musl-64.tgz ]; then
    rm -f /tmp/mingw-musl-64.tgz
fi
wget --inet4-only https://musl.cc/x86_64-w64-mingw32-cross.tgz -O /tmp/mingw-musl-64.tgz
if [ ! -s /tmp/mingw-musl-64.tgz ]; then
    echo "Error: mingw-musl-64.tgz is empty or corrupted"
    exit 1
fi
tar zxf /tmp/mingw-musl-64.tgz -C ../data

# Download and extract mingw-musl-32.tgz
if [ -f /tmp/mingw-musl-32.tgz ]; then
    rm -f /tmp/mingw-musl-32.tgz
fi
wget --inet4-only https://musl.cc/i686-w64-mingw32-cross.tgz -O /tmp/mingw-musl-32.tgz
if [ ! -s /tmp/mingw-musl-32.tgz ]; then
    echo "Error: mingw-musl-32.tgz is empty or corrupted"
    exit 1
fi
tar zxf /tmp/mingw-musl-32.tgz -C ../data

echo "[✓] Teamserver Updated"

DEST_DIR="$ROOT_DIR/client/client/Modules"
REPO_URL="https://github.com/HavocFramework/Modules.git"

# Create client folder if it doesn't exist
if [ ! -d "$ROOT_DIR/client" ]; then
    echo "[+] Creating client directory..."
    mkdir -p "$ROOT_DIR/client"
fi

# Clone or update
if [ -d "$DEST_DIR/.git" ]; then
    echo "[+] Repository already exists. Updating..."
    git -C "$DEST_DIR" pull
else
    echo "[+] Cloning Havoc modules..."
    git clone "$REPO_URL" "$DEST_DIR"
fi

echo "[+] Download completed in $DEST_DIR"

echo "[+] Patch applied to teamserver for IIS 8.5 404 response. Recompile the teamserver!"
echo "cd teamserver"
echo "go build -o havoc-teamserver"
echo "Execute build with:"
echo "    cd client && rm -rf Build && mkdir Build && cd Build && cmake .. && make -j2"
