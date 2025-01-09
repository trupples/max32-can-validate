#include <stdio.h>
#include <zephyr/devicetree.h>
#include <zephyr/drivers/can.h>

static const struct device *can0 = DEVICE_DT_GET(DT_NODELABEL(can0));

int main(void)
{
	can_start(can0);

	struct can_frame frame = { 0 };
	frame.id = 123;
	frame.dlc = can_bytes_to_dlc(2);
	frame.data[0] = 45;
	frame.data[1] = 67;
	can_send(can0, &frame, K_FOREVER, NULL, NULL);
	printf("sent!\n");

	return 0;
}

