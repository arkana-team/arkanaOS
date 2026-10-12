#pragma once

#include <glib.h>

#if !GLIB_CHECK_VERSION(2, 80, 0)
static inline void
arkana_g_strv_builder_take_compat(GStrvBuilder *builder, char *value)
{
	g_strv_builder_add(builder, value);
	g_free(value);
}

#define g_strv_builder_take(builder, value) \
	arkana_g_strv_builder_take_compat((builder), (value))
#endif
