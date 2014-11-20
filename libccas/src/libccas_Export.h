
#ifndef libccas_EXPORT_H
#define libccas_EXPORT_H

#ifdef libccas_BUILT_AS_STATIC
#  define libccas_EXPORT
#  define LIBCCAS_NO_EXPORT
#else
#  ifndef libccas_EXPORT
#    ifdef libccas_EXPORTS
        /* We are building this library */
#      define libccas_EXPORT __declspec(dllexport)
#    else
        /* We are using this library */
#      define libccas_EXPORT __declspec(dllimport)
#    endif
#  endif

#  ifndef LIBCCAS_NO_EXPORT
#    define LIBCCAS_NO_EXPORT 
#  endif
#endif

#ifndef LIBCCAS_DEPRECATED
#  define LIBCCAS_DEPRECATED __declspec(deprecated)
#endif

#ifndef LIBCCAS_DEPRECATED_EXPORT
#  define LIBCCAS_DEPRECATED_EXPORT libccas_EXPORT LIBCCAS_DEPRECATED
#endif

#ifndef LIBCCAS_DEPRECATED_NO_EXPORT
#  define LIBCCAS_DEPRECATED_NO_EXPORT LIBCCAS_NO_EXPORT LIBCCAS_DEPRECATED
#endif

#define DEFINE_NO_DEPRECATED 0
#if DEFINE_NO_DEPRECATED
# define LIBCCAS_NO_DEPRECATED
#endif

#endif
