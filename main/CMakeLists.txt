idf_component_register(
  SRCS "main.c"
  REQUIRES picoruby-esp32 # <-- add
  PRIV_REQUIRES spi_flash
  INCLUDE_DIRS ""
)
