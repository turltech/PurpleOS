# Install my personal Flatpaks
install-my-flatpaks:
    #!/usr/bin/env bash
    set -euxo pipefail

    FLATPAKS=(
        com.belmoussaoui.Decoder
        com.bitwarden.desktop
        com.cakewallet.CakeWallet
        com.calibre_ebook.calibre
        com.github.k4zmu2a.spacecadetpinball
        com.nitrokey.nitrokey-app2
        com.obsproject.Studio
        com.rafaelmardojai.Blanket
        com.ranfdev.DistroShelf
        com.valvesoftware.Steam
        dev.geopjr.Collision
        hu.irl.cameractrls
        info.portfolio_performance.PortfolioPerformance
        io.ente.auth
        io.freetubeapp.FreeTube
        io.github.alainm23.planify
        io.github.celluloid_player.Celluloid
        io.gitlab.metadatacleaner.metadatacleaner
        io.gitlab.theevilskeleton.Upscaler
        it.mijorus.gearlever
        md.obsidian.Obsidian
        me.sanchezrodriguez.passes
        net.mullvad.MullvadBrowser
        org.gnome.Boxes
        org.gnome.gitlab.YaLTeR.VideoTrimmer
        org.keepassxc.KeePassXC
        org.libreoffice.LibreOffice
        org.nickvision.tubeconverter
        org.onlyoffice.desktopeditors
        org.qbittorrent.qBittorrent
        org.signal.Signal
        page.codeberg.libre_menu_editor.LibreMenuEditor
    )

    echo "The following ${#FLATPAKS[@]} Flatpaks will be installed:"
    printf '  - %s\n' "${FLATPAKS[@]}"
    echo ""

    if ! gum confirm "Install all of the above Flatpaks?"; then
        echo "Aborted."
        exit 0
    fi

    echo ""
    echo "Installing Flatpaks..."
    FAILED=()
    for flatpak in "${FLATPAKS[@]}"; do
        flatpak install --noninteractive --assumeyes flathub "$flatpak" || \
            FAILED+=("$flatpak")
    done

    echo ""
    if [ ${#FAILED[@]} -eq 0 ]; then
        echo "✅ All Flatpaks installed successfully."
    else
        echo "⚠️  Done, but the following failed to install:"
        printf '  - %s\n' "${FAILED[@]}"
    fi
