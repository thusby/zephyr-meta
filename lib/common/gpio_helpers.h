/**
 * @file gpio_helpers.h
 * @brief Felles GPIO utility functions for Zephyr prosjekt
 * @author zephyr-meta
 */

#pragma once

#include <zephyr/drivers/gpio.h>

/**
 * @brief Initialiser LED med error handling
 *
 * @param led Peikar til gpio_dt_spec struktur
 * @return 0 ved suksess, negativ feilkode ellers
 */
int zh_init_led(const struct gpio_dt_spec *led);

/**
 * @brief Toggle LED med error handling
 *
 * @param led Peikar til gpio_dt_spec struktur
 * @return 0 ved suksess, negativ feilkode ellers
 */
int zh_toggle_led(const struct gpio_dt_spec *led);

/**
 * @brief Sett LED til ein spesifikk tilstand
 *
 * @param led Peikar til gpio_dt_spec struktur
 * @param state true for på, false for av
 * @return 0 ved suksess, negativ feilkode ellers
 */
int zh_set_led(const struct gpio_dt_spec *led, bool state);

/**
 * @brief Initialiser GPIO pin som input med pull-up
 *
 * @param pin Peikar til gpio_dt_spec struktur
 * @return 0 ved suksess, negativ feilkode ellers
 */
int zh_init_button(const struct gpio_dt_spec *pin);

/**
 * @brief Les tilstand frå GPIO input pin
 *
 * @param pin Peikar til gpio_dt_spec struktur
 * @param value Peikar til variabel for å lagre verdi
 * @return 0 ved suksess, negativ feilkode ellers
 */
int zh_read_button(const struct gpio_dt_spec *pin, bool *value);
