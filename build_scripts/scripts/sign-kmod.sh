#!/bin/bash
set -euo pipefail

MODULE_NAME="$1"

if [ -z "$MODULE_NAME" ]; then
    echo "Usage: $0 <module_name>"
    exit 1
fi

# Ensure openssl is available for key generation
if ! command -v openssl &> /dev/null; then
    dnf -y install openssl
fi

# Kmods Signing Logic: Dual-Mode (Secret vs Ephemeral)
PRIV_KEY="/tmp/kmod-signing-key.priv"
PUB_KEY="/run/context/kmod-secure-boot.der"

# Check if the secret key was mounted (Official Build)
if [ -f "$PRIV_KEY" ] && [ -s "$PRIV_KEY" ]; then
    echo "BS:Found secret signing key. Using it."
    if [ ! -f "$PUB_KEY" ]; then
        echo "ERROR: Secret private key found but public key '$PUB_KEY' is missing!"
        exit 1
    fi
else
    # Fallback to Ephemeral Key (Local Build)
    echo "BS:No secret signing key found. Generating ephemeral key for local testing..."
    PRIV_KEY="/tmp/ephemeral-kmod.priv"
    PUB_KEY="/tmp/ephemeral-kmod.der"

    # Generate new detached keypair
    openssl req -x509 -new -nodes -utf8 -sha256 -days 36500 \
        -batch \
        -subj "/CN=Bluefin Ephemeral Kmod Key/" \
        -outform DER -out "$PUB_KEY" \
        -keyout "$PRIV_KEY"

    echo "BS:Ephemeral key generated at $PRIV_KEY"
    echo "WARNING: You are using an ephemeral signing key. You MUST enroll '$PUB_KEY' (MOK) after this install/reboot."
fi

# Perform Signing
if [ -f "$PRIV_KEY" ] && [ -f "$PUB_KEY" ]; then
    echo "BS:Signing ${MODULE_NAME} module..."
    dnf -y install kernel-devel
    
    # Locate sign-file script
    SIGN_FILE=$(find /usr/src/kernels -name sign-file | head -n 1)
    # Find module (supports xz and regular)
    MOD_PATH=$(find /lib/modules -name "${MODULE_NAME}.ko.xz" -o -name "${MODULE_NAME}.ko" | head -n 1)

    if [ -n "$SIGN_FILE" ] && [ -n "$MOD_PATH" ]; then
        echo "BS:Found sign-file at $SIGN_FILE"
        echo "BS:Found module at $MOD_PATH"

        # Handle compression
        IS_XZ=0
        if [[ "$MOD_PATH" == *.xz ]]; then
            IS_XZ=1
            xz -d "$MOD_PATH"
            MOD_KO="${MOD_PATH%.xz}"
        else
            MOD_KO="$MOD_PATH"
        fi

        # Sign the module
        "$SIGN_FILE" sha256 "$PRIV_KEY" "$PUB_KEY" "$MOD_KO"

        # Re-compress if valid
        if [ "$IS_XZ" -eq 1 ]; then
            xz -f "$MOD_KO"
        fi

        # Always install the used public key for enrollment
        mkdir -p /etc/pki/akmods/certs
        cp "$PUB_KEY" /etc/pki/akmods/certs/kmod-secure-boot.der

        echo "BS:${MODULE_NAME} module signed and public key installed."
    else
        echo "ERROR: Could not find sign-file or module ${MODULE_NAME}."
        exit 1
    fi

    # Cleanup
    dnf -y remove kernel-devel
else
    echo "ERROR: Failed to establish signing keys."
    exit 1
fi
