/**
 * @file error_handling.h
 * @brief Felles error handling utilities for Zephyr prosjekt
 * @author zephyr-meta
 */

#pragma once

#include <zephyr/kernel.h>
#include <errno.h>

/**
 * @brief Konverter Zephyr feilkode til menneskelesbar streng
 *
 * @param error_code Negativ feilkode frå Zephyr API
 * @return Tekststreng som beskriv feilen
 */
const char *zh_error_to_string(int error_code);

/**
 * @brief Sjekk om returverdi er feil og logg i så fall
 *
 * @param ret Returverdi frå Zephyr API
 * @param context Kontekststreng for loggemelding
 * @return true viss feil, false viss suksess
 */
bool zh_check_error(int ret, const char *context);

/**
 * @brief Makro for å sjekke returverdi og returnere ved feil
 *
 * Bruk: ZH_CHECK_RET(gpio_pin_configure_dt(&led, GPIO_OUTPUT));
 */
#define ZH_CHECK_RET(call) \
	do { \
		int _ret = (call); \
		if (_ret < 0) { \
			LOG_ERR("%s failed: %d (%s)", #call, _ret, zh_error_to_string(_ret)); \
			return _ret; \
		} \
	} while (0)

/**
 * @brief Makro for å sjekke returverdi og hoppe til cleanup ved feil
 */
#define ZH_CHECK_GOTO(call, label) \
	do { \
		int _ret = (call); \
		if (_ret < 0) { \
			LOG_ERR("%s failed: %d (%s)", #call, _ret, zh_error_to_string(_ret)); \
			ret = _ret; \
			goto label; \
		} \
	} while (0)
