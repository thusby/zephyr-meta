/**
 * @file gpio_helpers.c
 * @brief Implementering av GPIO helper functions
 */

#include "gpio_helpers.h"
#include <zephyr/logging/log.h>

LOG_MODULE_REGISTER(gpio_helpers, LOG_LEVEL_DBG);

int zh_init_led(const struct gpio_dt_spec *led)
{
	if (!led) {
		LOG_ERR("NULL pointer passed to zh_init_led");
		return -EINVAL;
	}

	if (!gpio_is_ready_dt(led)) {
		LOG_ERR("GPIO device not ready");
		return -ENODEV;
	}

	int ret = gpio_pin_configure_dt(led, GPIO_OUTPUT_INACTIVE);
	if (ret < 0) {
		LOG_ERR("Failed to configure LED pin: %d", ret);
		return ret;
	}

	LOG_DBG("LED initialized successfully");
	return 0;
}

int zh_toggle_led(const struct gpio_dt_spec *led)
{
	if (!led) {
		LOG_ERR("NULL pointer passed to zh_toggle_led");
		return -EINVAL;
	}

	int ret = gpio_pin_toggle_dt(led);
	if (ret < 0) {
		LOG_ERR("Failed to toggle LED: %d", ret);
		return ret;
	}

	return 0;
}

int zh_set_led(const struct gpio_dt_spec *led, bool state)
{
	if (!led) {
		LOG_ERR("NULL pointer passed to zh_set_led");
		return -EINVAL;
	}

	int ret = gpio_pin_set_dt(led, state);
	if (ret < 0) {
		LOG_ERR("Failed to set LED state: %d", ret);
		return ret;
	}

	return 0;
}

int zh_init_button(const struct gpio_dt_spec *pin)
{
	if (!pin) {
		LOG_ERR("NULL pointer passed to zh_init_button");
		return -EINVAL;
	}

	if (!gpio_is_ready_dt(pin)) {
		LOG_ERR("GPIO device not ready");
		return -ENODEV;
	}

	int ret = gpio_pin_configure_dt(pin, GPIO_INPUT | GPIO_PULL_UP);
	if (ret < 0) {
		LOG_ERR("Failed to configure button pin: %d", ret);
		return ret;
	}

	LOG_DBG("Button initialized successfully");
	return 0;
}

int zh_read_button(const struct gpio_dt_spec *pin, bool *value)
{
	if (!pin || !value) {
		LOG_ERR("NULL pointer passed to zh_read_button");
		return -EINVAL;
	}

	int ret = gpio_pin_get_dt(pin);
	if (ret < 0) {
		LOG_ERR("Failed to read button state: %d", ret);
		return ret;
	}

	*value = (ret == 1);
	return 0;
}
