# desplegar_hospitvalle.sh - Despliegue de las 8 VM de HospitValle-Cloud 
# Modo diseño (seccion 11) 

cat << 'EOF' > desplegar_hospitvalle.sh
#!/bin/bash

IMG_DIR="/var/lib/libvirt/images"
BASE_IMG="$IMG_DIR/noble-server-cloudimg-amd64.img"

VMS=(
    "vm-historia-clinica-01"
    "vm-historia-clinica-02"
    "vm-uce-monitoreo-01"
    "vm-uce-monitoreo-02"
    "vm-pacs-imagenes-01"
    "vm-pacs-imagenes-02"
    "vm-administrativa-01"
    "vm-administrativa-02"
)

for vm in "${VMS[@]}"; do
    echo "=================================================="
    echo "Procesando nodo crítico: $vm"
    echo "=================================================="

    case "$vm" in
        "vm-historia-clinica-01" | "vm-historia-clinica-02" | "vm-pacs-imagenes-01" | "vm-pacs-imagenes-02")
            RAM=32768 #32 GiB
            VCPUS=4
            ;;
        "vm-uce-monitoreo-01" | "vm-uce-monitoreo-02")
            RAM=16384 #16 GiB
            VCPUS=4
            ;;
        "vm-administrativa-01" | "vm-administrativa-02")
            RAM=8192 # 8 GiB
            VCPUS=2
            ;;
        *)
            RAM=2048
            VCPUS=1
            ;;
    esac

    sed "s/nodo-metromio-1/$vm/" user-data.yaml > user-data-${vm}.yaml

    sudo qemu-img create -f qcow2 -F qcow2 \
      -b "$BASE_IMG" \
      "$IMG_DIR/${vm}.qcow2" 20G

    sudo virt-install \
      --name "$vm" \
      --memory "$RAM" \
      --vcpus "$VCPUS" \
      --disk path="$IMG_DIR/${vm}.qcow2",format=qcow2 \
      --network network=default \
      --graphics none \
      --os-variant ubuntu24.04 \
      --cloud-init user-data=user-data-${vm}.yaml \
      --import \
      --noautoconsole

    echo "¡$vm configurada!"
    echo ""
done

echo "¡Proceso finalizado!"
EOF

# Dar permisos de ejecución nuevamente
chmod +x desplegar_hospitvalle_oficial.sh