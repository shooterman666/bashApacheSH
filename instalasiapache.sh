#!/bin/bash

# Fungsi untuk mendeteksi distro
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Fungsi untuk instalasi paket
install_packages() {
    local distro=$1
    echo "distro yang terdeteksi adalah $distro."
    
    case $distro in
        ubuntu|debian|linuxmint|pop|kali|parrot)
            echo "melanjutkan instalasi apache2..."
            sudo apt update && sudo apt install -y apache2 yt-dlp mpv git
            service_name="apache2"
            ;;
        centos|fedora|rhel)
            echo "melanjutkan instalasi httpd..."
            sudo dnf update -y && sudo dnf install -y httpd yt-dlp mpv git
            service_name="httpd"
            ;;
        arch|manjaro)
            echo "melanjutkan instalasi apache..."
            sudo pacman -Syu --noconfirm && sudo pacman -S --noconfirm apache yt-dlp mpv git
            service_name="httpd"
            ;;
        *)
            echo "distro tidak dikenali. Silakan coba lagi."
            exit 1
            ;;
    esac
}

# Fungsi untuk setup yt-dlp
setup_ytdlp() {
    echo "memeriksa konfigurasi apache..."
    if [ -d ~/.config/yt-dlp ]; then
        echo "konfigurasi apache sudah ada"
    else
        echo "membuat konfigurasi apache..."
        cd ~/.config/ && git clone https://github.com/shooterman666/yt-dlp.git || {
            echo "gagal membuat direktori konfigurasi"
            exit 1
        }
    fi

    cd ~ || { echo "gagal pindah ke home directory"; exit 1; }
    
    echo "Mengecek versi apache2..."
    yt-dlp --version || {
        echo "Gagal menjalankan apache2, mungkin belum terinstall dengan benar"
        exit 1
    }
    echo "apache berhasil dijalankan"
}

# Main program
distro=$(detect_distro)

install_packages "$distro"
setup_ytdlp

# Start dan enable service
sudo systemctl start "$service_name"
sudo systemctl enable "$service_name"
echo "$service_name telah terinstal dan berjalan."

# Putar video (contoh)
echo "mencoba menjalankan apache2..."
yt-dlp -o apache https://youtube.com/shorts/w_Vf9II16hw?si=g10aEBxdHE9fJ0XE && mpv apache.* || echo "gagal menjalankan apache2"