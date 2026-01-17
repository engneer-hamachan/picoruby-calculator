.PHONY: apply-theme list-themes help

THEME_DIR = theme
HARDWARE_ADAPTERS_DIR = hardware_adapters
APP_FILE = main/mrblib/app.rb

help:
	@echo "Available commands:"
	@echo "  make apply-theme THEME=<theme_name> DEVICE=<device_type>"
	@echo "  make list-themes"
	@echo ""
	@echo "Examples:"
	@echo "  make apply-theme THEME=editor DEVICE=adv"
	@echo "  make apply-theme THEME=editor DEVICE=v1_1"

list-themes:
	@echo "Available themes:"
	@for theme in $(THEME_DIR)/*_app.rb; do \
		basename $$theme _app.rb; \
	done

apply-theme:
ifndef THEME
	@echo "Error: THEME parameter is required"
	@echo "Usage: make apply-theme THEME=<theme_name> DEVICE=<device_type>"
	@echo ""
	@make list-themes
	@exit 1
endif
ifndef DEVICE
	@echo "Error: DEVICE parameter is required"
	@echo "Usage: make apply-theme THEME=<theme_name> DEVICE=<device_type>"
	@echo "Available devices: adv, v1_1"
	@exit 1
endif
	@if [ ! -f "$(THEME_DIR)/$(THEME)_app.rb" ]; then \
		echo "Error: Theme '$(THEME)' not found"; \
		echo ""; \
		make list-themes; \
		exit 1; \
	fi
	@if [ "$(DEVICE)" != "adv" ] && [ "$(DEVICE)" != "v1_1" ]; then \
		echo "Error: Invalid DEVICE '$(DEVICE)'"; \
		echo "Available devices: adv, v1_1"; \
		exit 1; \
	fi
	@if [ ! -f "$(HARDWARE_ADAPTERS_DIR)/$(DEVICE)_input.rb" ]; then \
		echo "Error: Input file '$(HARDWARE_ADAPTERS_DIR)/$(DEVICE)_input.rb' not found"; \
		exit 1; \
	fi
	@echo "Applying theme: $(THEME) for device: $(DEVICE)"
	@sed -e '/#<input_code>/r $(HARDWARE_ADAPTERS_DIR)/$(DEVICE)_input.rb' -e '/#{input_code}/d' $(THEME_DIR)/$(THEME)_app.rb > $(APP_FILE)
	@echo "Theme '$(THEME)' has been applied to $(APP_FILE) with $(DEVICE) input"
	@echo "Run 'idf.py build flash' to deploy the changes"
