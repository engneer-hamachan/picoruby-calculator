idf_component_register(
  SRCS "main.c"
  REQUIRES picoruby-esp32 nvs_flash
  INCLUDE_DIRS "."
)

target_compile_definitions(
  ${COMPONENT_LIB}
  PRIVATE
    -DPICORB_VM_MRUBYC
)

target_include_directories(
  ${COMPONENT_LIB}
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/../components/picoruby-esp32/picoruby/mrbgems/picoruby-mrubyc/include
    ${CMAKE_CURRENT_SOURCE_DIR}/../components/picoruby-esp32/picoruby/mrbgems/mruby-compiler2/include
    ${CMAKE_CURRENT_SOURCE_DIR}/../components/picoruby-esp32/picoruby/mrbgems/mruby-compiler2/lib/prism/include
    ${CMAKE_CURRENT_SOURCE_DIR}/../components/picoruby-esp32/picoruby/build/esp32/mrbgems
)

set(RUBY_FILES app)
set(PICORBC ${CMAKE_CURRENT_SOURCE_DIR}/../components/picoruby-esp32/picoruby/bin/picorbc)
set(GENERATED_C_FILES "")

foreach(rb ${RUBY_FILES})
  set(C_FILE ${CMAKE_CURRENT_SOURCE_DIR}/mrb/${rb}.c)
  set(RB_FILE ${CMAKE_CURRENT_SOURCE_DIR}/mrblib/${rb}.rb)
  add_custom_command(
    OUTPUT ${C_FILE}
    COMMAND ${CMAKE_COMMAND} -E echo "Compiling ${RB_FILE}..."
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_SOURCE_DIR}/mrb
    COMMAND ${PICORBC} -B${rb} -o${C_FILE} ${RB_FILE}
    DEPENDS ${RB_FILE}
    COMMENT "Compiling ${RB_FILE}"
    VERBATIM
  )
  list(APPEND GENERATED_C_FILES ${C_FILE})
endforeach(rb)

target_sources(${COMPONENT_LIB} PRIVATE ${GENERATED_C_FILES})
