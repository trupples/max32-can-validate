#!/bin/bash

WEST_WORKSPACE=$(west topdir)

[[ -z "$WEST_WORKSPACE" ]] && {
	echo "Must have west loaded"
	exit 1
}

# Clone repos
[[ -d msdk ]] && rm -rf msdk
[[ -d hal_adi ]] && rm -rf hal_adi

git clone https://github.com/trupples/msdk -b feat/zephyr-wrap-max32-can &
git clone https://github.com/analogdevicesinc/hal_adi -b develop &
wait

# Apply changes, as if by the github workflow
bash msdk/.github/workflows/scripts/zephyr-hal.sh # Defaults to ./msdk ./hal_adi

# Prepare west project (T2 topology)
west config manifest.path validate
west update

# Overwrite hal_adi with local variant
rm -rf $WEST_WORKSPACE/modules/hal_adi
cp -r hal_adi $WEST_WORKSPACE/modules/hal_adi

# Test builds
west build -b max32690evkit/max32690/m4 -p always . || {
	echo "MAX32690 build failed"
	exit 1
}
west build -b max32662evkit -p always . || {
	echo "MAX32662 build failed!"
	exit 1
}

