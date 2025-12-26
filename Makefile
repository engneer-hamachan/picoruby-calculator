.PHONY: apply-theme list-themes help

THEME_DIR = theme
APP_FILE = main/mrblib/app.rb

help:
	@echo "Available commands:"
	@echo "  make apply-theme THEME=<theme_name>"
	@echo "  make list-themes"
	@echo ""
	@echo "Examples:"
	@echo "  make apply-theme THEME=geek"

list-themes:
	@echo "Available themes:"
	@for theme in $(THEME_DIR)/*_app.rb; do \
		basename $$theme _app.rb; \
	done

apply-theme:
ifndef THEME
	@echo "Error: THEME parameter is required"
	@echo "Usage: make apply-theme THEME=<theme_name>"
	@echo ""
	@make list-themes
	@exit 1
endif
	@if [ ! -f "$(THEME_DIR)/$(THEME)_app.rb" ]; then \
		echo "Error: Theme '$(THEME)' not found"; \
		echo ""; \
		make list-themes; \
		exit 1; \
	fi
	@echo "Applying theme: $(THEME)"
	@cp $(THEME_DIR)/$(THEME)_app.rb $(APP_FILE)
	@echo "Theme '$(THEME)' has been applied to $(APP_FILE)"
	@echo "Run 'idf.py build flash' to deploy the changes"
