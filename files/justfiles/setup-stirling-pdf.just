# Set up Stirling PDF in a Fedora 44 distrobox and export to host (no internet access)
setup-stirling-pdf:
    #!/usr/bin/env bash
    set -euxo pipefail

    CONTAINER_NAME="stirling-pdf"
    CONTAINER_NAME_INSTALL="stirling-pdf-install"
    IMAGE="quay.io/fedora/fedora:44"

    # Check if final container already exists
    if distrobox list | grep -q "$CONTAINER_NAME"; then
        echo "⚠️  A distrobox named '$CONTAINER_NAME' already exists."
        if ! gum confirm "Recreate it from scratch?"; then
            echo "Aborted."
            exit 0
        fi
        distrobox rm --force "$CONTAINER_NAME"
    fi

    if ! gum confirm "Create a Fedora 44 distrobox, install Stirling PDF, and disable its internet access?"; then
        echo "Aborted."
        exit 0
    fi

    # Clean up any leftover install container from a previous failed run
    if distrobox list | grep -q "$CONTAINER_NAME_INSTALL"; then
        distrobox rm --force "$CONTAINER_NAME_INSTALL"
    fi

    echo ""
    echo "📦 Creating temporary install container..."
    distrobox create \
        --name "$CONTAINER_NAME_INSTALL" \
        --image "$IMAGE"

    echo ""
    echo "⬇️  Downloading and installing Stirling PDF..."
    distrobox enter "$CONTAINER_NAME_INSTALL" -- bash -c "
        set -euxo pipefail
        wget -O /tmp/stirling-pdf-installer.rpm https://files.stirlingpdf.com/linux-installer.rpm
        sudo dnf install -y /tmp/stirling-pdf-installer.rpm
        rm /tmp/stirling-pdf-installer.rpm
    "

    echo ""
    echo "💾 Committing installed image..."
    podman commit "$CONTAINER_NAME_INSTALL" "stirling-pdf-installed"
    distrobox rm --force "$CONTAINER_NAME_INSTALL"

    echo ""
    echo "🔒 Creating final container with no internet access..."
    distrobox create \
        --name "$CONTAINER_NAME" \
        --image "stirling-pdf-installed" \
        --unshare-netns \
        --additional-flags "--network=none"

    echo ""
    echo "🔗 Exporting Stirling PDF to host..."
    distrobox enter "$CONTAINER_NAME" -- bash -c "
        distrobox-export --app Stirling-PDF
    "

    echo ""
    echo "✅ Done! Stirling PDF is available in your app launcher with blocked internet access."
