/**
 * @file error_handling.c
 * @brief Implementering av error handling utilities
 */

#include "error_handling.h"
#include <zephyr/logging/log.h>

LOG_MODULE_REGISTER(error_handling, LOG_LEVEL_DBG);

const char *zh_error_to_string(int error_code)
{
	switch (-error_code) {
	case 0:
		return "Success";
	case EINVAL:
		return "Invalid argument";
	case ENODEV:
		return "No such device";
	case ENOMEM:
		return "Out of memory";
	case EBUSY:
		return "Device or resource busy";
	case ETIMEDOUT:
		return "Timeout";
	case EIO:
		return "I/O error";
	case ENOTSUP:
		return "Operation not supported";
	case EAGAIN:
		return "Try again";
	case EACCES:
		return "Permission denied";
	default:
		return "Unknown error";
	}
}

bool zh_check_error(int ret, const char *context)
{
	if (ret < 0) {
		LOG_ERR("%s failed: %d (%s)", context, ret, zh_error_to_string(ret));
		return true;
	}
	return false;
}
