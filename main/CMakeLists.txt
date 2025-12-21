idf_component_register(
  SRCS "main.c" "../app.rb"
  REQUIRES picoruby-esp32
  PRIV_REQUIRES spi_flash
  INCLUDE_DIRS ""
)
